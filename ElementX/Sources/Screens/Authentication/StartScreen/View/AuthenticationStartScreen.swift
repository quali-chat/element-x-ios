//
// Copyright 2022-2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

/// The screen shown at the beginning of the onboarding flow.
struct AuthenticationStartScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    let context: AuthenticationStartScreenViewModel.Context
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: UIConstants.spacerHeight(in: geometry))
                
                content
                    .frame(width: geometry.size.width)
                    .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.hidden)
                
                buttons
                    .frame(width: geometry.size.width)
                    .padding(.bottom, UIConstants.actionButtonBottomPadding)
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 16)
                    .padding(.top, 8)
                
                Spacer()
                    .frame(height: UIConstants.spacerHeight(in: geometry))
            }
            .frame(maxHeight: .infinity)
            #if !QUALICHAT
                .safeAreaInset(edge: .bottom) {
                    versionText
                        .font(.compound.bodySM)
                        .foregroundColor(.compound.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                        .onTapGesture(count: 7) {
                            context.send(viewAction: .reportProblem)
                        }
                        .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.appVersion)
                }
            #endif
        }
        .navigationBarHidden(true)
        #if QUALICHAT
            .background()
            .backgroundStyle(.compound.bgCanvasDefault)
        #else
            .background {
                AuthenticationStartScreenBackgroundImage()
            }
        #endif
            .introspect(.window, on: .supportedVersions) { window in
                context.send(viewAction: .updateWindow(window))
            }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            Spacer()
            
            #if QUALICHAT
            QualiOnboardingSlidesView()
                .padding()
                .fixedSize(horizontal: false, vertical: true)
            #else
            if verticalSizeClass == .regular {
                Spacer()
                
                AuthenticationStartLogo(isOnGradient: true)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Text(L10n.screenOnboardingWelcomeTitle)
                    .font(.compound.headingLGBold)
                    .foregroundColor(.compound.textPrimary)
                    .multilineTextAlignment(.center)
                Text(L10n.screenOnboardingWelcomeMessage(InfoPlistReader.main.productionAppName))
                    .font(.compound.bodyLG)
                    .foregroundColor(.compound.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .fixedSize(horizontal: false, vertical: true)
            #endif
            
            Spacer()
        }
        .padding(.bottom)
        .padding(.horizontal, 16)
        .readableFrame()
    }
    
    /// The main action buttons.
    var buttons: some View {
        VStack(spacing: 16) {
            #if !QUALICHAT
            if context.viewState.showQRCodeLoginButton {
                Button { context.send(viewAction: .loginWithQR) } label: {
                    Label(L10n.screenOnboardingSignInWithQrCode, icon: \.qrCode)
                }
                .buttonStyle(.compound(.primary))
                .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.signInWithQr)
            }
            #endif
            
            #if QUALICHAT
            Button { context.send(viewAction: .loginWithWallet) } label: {
                Text("Login with Wallet")
            }
            .buttonStyle(.compound(.primary))
            .accessibilityIdentifier("signInWithWallet")
            #endif
            
            Button { context.send(viewAction: .login) } label: {
                Text(context.viewState.loginButtonTitle)
            }
            .buttonStyle(.compound(.primary))
            .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.signIn)
            
            if context.viewState.showCreateAccountButton {
                Button { context.send(viewAction: .register) } label: {
                    Text(L10n.screenCreateAccountTitle)
                }
                .buttonStyle(.compound(.tertiary))
            }
        }
        .padding(.horizontal, verticalSizeClass == .compact ? 128 : 24)
        .readableFrame()
    }
    
    var versionText: Text {
        // Let's not deal with snapshotting a changing version string.
        let shortVersionString = ProcessInfo.isRunningTests ? "0.0.0" : InfoPlistReader.main.bundleShortVersionString
        return Text(L10n.screenOnboardingAppVersion(shortVersionString))
    }
}

// MARK: - Previews

struct AuthenticationStartScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = makeViewModel()
    static let provisionedViewModel = makeViewModel(provisionedServerName: "example.com")
    
    static var previews: some View {
        AuthenticationStartScreen(context: viewModel.context)
            .previewDisplayName("Default")
        AuthenticationStartScreen(context: provisionedViewModel.context)
            .previewDisplayName("Provisioned")
    }
    
    static func makeViewModel(provisionedServerName: String? = nil) -> AuthenticationStartScreenViewModel {
        AuthenticationStartScreenViewModel(authenticationService: AuthenticationService.mock,
                                           provisioningParameters: provisionedServerName.map { .init(accountProvider: $0, loginHint: nil) },
                                           isBugReportServiceEnabled: true,
                                           appSettings: ServiceLocator.shared.settings,
                                           userIndicatorController: UserIndicatorControllerMock())
    }
}

#if QUALICHAT

// MARK: - QualiChat Onboarding Slides

private struct QualiOnboardingSlide: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

private struct QualiOnboardingSlidesView: View {
    private let slides: [QualiOnboardingSlide] = [
        .init(imageName: "images/onboarding-1",
              title: "Enter your exclusive token-gated chats",
              subtitle: "All communities of the tokens you own instantly in one chat & collaboration dApp."),
        .init(imageName: "images/onboarding-2",
              title: "Secure Wallet-to-wallet messaging",
              subtitle: "Decentalized, end-to-end encrypted communication for ultimate privacy."),
        .init(imageName: "images/onboarding-3",
              title: "Name service identity control",
              subtitle: "If you own a Name Service domain, your display name is automatically set to it.")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            TabView {
                ForEach(slides) { slide in
                    VStack(spacing: 16) {
                        Image(slide.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .accessibilityHidden(true)
                        Text(slide.title.uppercased())
                            .font(.compound.headingLGBold)
                            .foregroundColor(.compound.textActionAccent)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                        Text(slide.subtitle)
                            .font(.compound.bodyLG)
                            .foregroundColor(.compound.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(maxWidth: .infinity, minHeight: 500)
        }
    }
}
#endif

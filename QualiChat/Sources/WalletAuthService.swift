//
// Copyright 2025
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
//

import Combine
import Foundation
import ReownAppKit

class WalletAuthService {
    static let shared = WalletAuthService()

    private init() { }

    private var dispose = Set<AnyCancellable>()

    func configure(appDisplayName: String,
                   baseBundleIdentifier: String) {
        let nativeScheme = "\(baseBundleIdentifier)://"
        let universalLink = "https://quali.chat/ios"

        let metadata = AppMetadata(name: appDisplayName,
                                   description: "QualiChat",
                                   url: "https://quali.chat",
                                   icons: ["https://quali.chat/mobile-icon.png"],
                                   redirect: try! .init(native: nativeScheme,
                                                        universal: universalLink,
                                                        linkMode: false))

        Networking.configure(groupIdentifier: InfoPlistReader.app.appGroupIdentifier,
                             projectId: Secrets.reownProjectId ?? "",
                             socketFactory: DefaultSocketFactory())

        AppKit.configure(projectId: Secrets.reownProjectId ?? "",
                         metadata: metadata,
                         crypto: DefaultCryptoProvider(),
                         authRequestParams: nil)

        // Observers are managed by the caller to coordinate signing flow.
        addObservers()
        
        AppKit.instance.logger.setLogging(level: .debug)
        Sign.instance.setLogging(level: .debug)
        Networking.instance.setLogging(level: .debug)
        Relay.instance.setLogging(level: .debug)
    }

    func present() {
        Task {
            await disconnectAnyExistingWallet()
            await MainActor.run {
                AppKit.present()
            }
        }
    }

    private func addObservers() {
        // Intentionally left blank to avoid auto-triggering signature requests.
    }
    
    private func disconnectAnyExistingWallet() async {
        do {
            try await AppKit.instance.cleanup()
            if let currentSession = AppKit.instance.getSessions().first {
                let topic = currentSession.topic
                try await AppKit.instance.disconnect(topic: topic)
            }
        } catch {
            print(error)
        }
    }
    
    func requestPersonalSignWithDelay(message: String) async {
        Task {
            try? await Task.sleep(for: .seconds(2))
            await requestPersonalSign(message: message)
        }
    }

    func requestPersonalSign(message: String) async {
        do {
            guard let address = AppKit.instance.getAddress() else { return }
            AppKit.instance.launchCurrentWallet()
            try await AppKit.instance.request(
                .personal_sign(address: address,
                               message: message)
            )
        } catch {
            MXLog.debug("AppKit is not configured yet in walletConnectService")
        }
    }
}

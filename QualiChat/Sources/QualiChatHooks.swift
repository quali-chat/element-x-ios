//
// Copyright 2025
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
//

import Compound
import SwiftUI
import UIKit

#if QUALICHAT
struct QualiChatCompoundHook: CompoundHookProtocol {
    func override(colors: CompoundColors, uiColors: CompoundUIColors) {
        let brand = Color(red: 0.608, green: 0.686, blue: 0.969)

        colors.override(\.iconAccentTertiary, with: brand)
        colors.override(\.textActionAccent, with: brand)
        colors.override(\.bgCanvasDefault, with: Color(red: 0, green: 0, blue: 0))
        colors.override(\.bgDecorative1,
                        with: Color(red: 0.502, green: 0.831, blue: 0.871))
        colors.override(\.textDecorative1,
                        with: Color(red: 0.102, green: 0.102, blue: 0.102))

        colors.override(\.bgDecorative2,
                        with: Color(red: 0.973, green: 0.824, blue: 0.533))
        colors.override(\.textDecorative2,
                        with: Color(red: 0.102, green: 0.102, blue: 0.102))

        colors.override(\.bgDecorative3,
                        with: Color(red: 0.678, green: 0.576, blue: 0.973))
        colors.override(\.textDecorative3,
                        with: Color(red: 0.102, green: 0.102, blue: 0.102))

        colors.override(\.bgDecorative4,
                        with: Color(red: 0.502, green: 0.831, blue: 0.871))
        colors.override(\.textDecorative4,
                        with: Color(red: 0.102, green: 0.102, blue: 0.102))

        colors.override(\.bgDecorative5,
                        with: Color(red: 0.973, green: 0.824, blue: 0.533))
        colors.override(\.textDecorative5,
                        with: Color(red: 0.102, green: 0.102, blue: 0.102))

        colors.override(\.bgDecorative6,
                        with: Color(red: 0.678, green: 0.576, blue: 0.973))
        colors.override(\.textDecorative6,
                        with: Color(red: 0.102, green: 0.102, blue: 0.102))
    }
}

struct QualiChatAppSettingsHook: AppSettingsHookProtocol {
    func configure(_ appSettings: AppSettings) -> AppSettings {
        appSettings.override(accountProviders: ["http://localhost:8008"],
                             allowOtherAccountProviders: false,
                             pushGatewayBaseURL: "https://matrix.org",
                             oidcRedirectURL: "https://localhost/oidc/login",
                             websiteURL: "http://localhost",
                             logoURL: "https://localhost/mobile-icon.png",
                             copyrightURL: "https://localhost/copyright",
                             acceptableUseURL:
                             "https://localhost/acceptable-use-policy-terms",
                             privacyURL: "https://localhost/privacy",
                             encryptionURL: "https://localhost/help#encryption",
                             deviceVerificationURL:
                             "https://localhost/help#encryption-device-verification",
                             chatBackupDetailsURL: "https://localhost/help#encryption5",
                             identityPinningViolationDetailsURL:
                             "https://localhost/help#encryption18",
                             elementWebHosts: ["chat.localhost"],
                             accountProvisioningHost: "mobile.localhost",
                             bugReportApplicationID: "element-x-ios",
                             analyticsTermsURL: "https://element.io/cookie-policy",
                             mapTilerConfiguration: MapTilerConfiguration(baseURL: "https://api.maptiler.com/maps",
                                                                          apiKey: Secrets.mapLibreAPIKey,
                                                                          lightStyleID: "9bc819c8-e627-474a-a348-ec144fe3d810",
                                                                          darkStyleID: "dea61faf-292b-4774-9660-58fcef89a7f3"))
        return appSettings
    }
}

/* struct QualiChatAppSettingsHook: AppSettingsHookProtocol {
     func configure(_ appSettings: AppSettings) -> AppSettings {
         appSettings.override(accountProviders: ["quali.chat"],
                              allowOtherAccountProviders: false,
                              pushGatewayBaseURL: "https://matrix.org",
                              oidcRedirectURL: "https://quali.chat/oidc/login",
                              websiteURL: "https://quali.chat",
                              logoURL: "https://quali.chat/mobile-icon.png",
                              copyrightURL: "https://quali.chat/copyright",
                              acceptableUseURL:
                              "https://squali.chat/acceptable-use-policy-terms",
                              privacyURL: "https://quali.chat/privacy",
                              encryptionURL: "https://quali.chat/help#encryption",
                              deviceVerificationURL:
                              "https://quali.chat/help#encryption-device-verification",
                              chatBackupDetailsURL: "https://quali.chat/help#encryption5",
                              identityPinningViolationDetailsURL:
                              "https://quali.chat/help#encryption18",
                              elementWebHosts: ["app.quali.chat"],
                              accountProvisioningHost: "mobile.quali.chat",
                              bugReportApplicationID: "element-x-ios",
                              analyticsTermsURL: "https://element.io/cookie-policy",
                              mapTilerConfiguration: MapTilerConfiguration(baseURL: "https://api.maptiler.com/maps",
                                                                           apiKey: Secrets.mapLibreAPIKey,
                                                                           lightStyleID: "9bc819c8-e627-474a-a348-ec144fe3d810",
                                                                           darkStyleID: "dea61faf-292b-4774-9660-58fcef89a7f3"))
         return appSettings
     }
 } */

extension AppHooks {
    func setUp() {
        registerCompoundHook(QualiChatCompoundHook())
        registerAppSettingsHook(QualiChatAppSettingsHook())
    }
}
#endif

//
// Copyright 2025
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
//

import Combine
import Foundation
import ReownAppKit

enum WalletAuthService {
    static func configure(appDisplayName: String,
                          baseBundleIdentifier: String) {
        let nativeScheme = "\(baseBundleIdentifier)://"
        let universalLink = "https://quali.chat/ios"

        let metadata = AppMetadata(name: appDisplayName,
                                   description: "QualiChat",
                                   url: "https://quali.chat",
                                   icons: ["https://quali.chat/mobile-icon.png"],
                                   redirect: try! .init(native: nativeScheme,
                                                        universal: universalLink,
                                                        linkMode: true))

        Networking.configure(groupIdentifier: InfoPlistReader.app.appGroupIdentifier,
                             projectId: Secrets.reownProjectId ?? "",
                             socketFactory: DefaultSocketFactory())

        AppKit.configure(projectId: Secrets.reownProjectId ?? "",
                         metadata: metadata,
                         crypto: DefaultCryptoProvider(),
                         authRequestParams: nil)

        // Observe One-Click Auth responses
        /* cancellable = AppKit.instance.authResponsePublisher.sink { (_, result) in
             switch result {
             case .success:
                 // Notification only; actual Matrix login continues elsewhere.
                 ServiceLocator.shared.userIndicatorController
                     .submitIndicator(UserIndicator(title: "Wallet authenticated"))
             case .failure:
                 ServiceLocator.shared.userIndicatorController
                     .submitIndicator(UserIndicator(title: "Wallet auth failed"))
             }
         }*/
    }

    static func present() {
        AppKit.present()
    }
}

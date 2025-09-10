//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

protocol QualiChatApiProtocol {
    var authApi: QualiChatAuthApiProtocol { get }
}

class QualiChatApi: QualiChatApiProtocol {
    var authApi: QualiChatAuthApiProtocol
    
    init(authApi: QualiChatAuthApiProtocol) {
        self.authApi = authApi
    }
}

extension QualiChatApi {
    convenience init(appSettings: AppSettings) {
        self.init(authApi: QualiChatAuthApi(appSettings: appSettings))
    }
}

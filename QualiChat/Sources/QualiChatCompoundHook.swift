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
        // let brandUI = UIColor(red: 0.608, green: 0.686, blue: 0.969, alpha: 1.0)
        
        colors.override(\.iconAccentTertiary, with: brand)
        colors.override(\.bgDecorative1, with: Color(red: 0.502, green: 0.831, blue: 0.871))
        colors.override(\.textDecorative1, with: Color(red: 0.102, green: 0.102, blue: 0.102))

        colors.override(\.bgDecorative2, with: Color(red: 0.973, green: 0.824, blue: 0.533))
        colors.override(\.textDecorative2, with: Color(red: 0.102, green: 0.102, blue: 0.102))

        colors.override(\.bgDecorative3, with: Color(red: 0.678, green: 0.576, blue: 0.973))
        colors.override(\.textDecorative3, with: Color(red: 0.102, green: 0.102, blue: 0.102))

        colors.override(\.bgDecorative4, with: Color(red: 0.502, green: 0.831, blue: 0.871))
        colors.override(\.textDecorative4, with: Color(red: 0.102, green: 0.102, blue: 0.102))

        colors.override(\.bgDecorative5, with: Color(red: 0.973, green: 0.824, blue: 0.533))
        colors.override(\.textDecorative5, with: Color(red: 0.102, green: 0.102, blue: 0.102))

        colors.override(\.bgDecorative6, with: Color(red: 0.678, green: 0.576, blue: 0.973))
        colors.override(\.textDecorative6, with: Color(red: 0.102, green: 0.102, blue: 0.102))
    }
}

extension AppHooks {
    func setUp() {
        registerCompoundHook(QualiChatCompoundHook())
    }
}
#endif

//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation
import WalletConnectSigner

struct DefaultCryptoProvider: CryptoProvider {
    func recoverPubKey(signature: EthereumSignature, message: Data)
        throws -> Data {
        //        let publicKey = try EthereumPublicKey(
        //            message: message.bytes,
        //            v: EthereumQuantity(quantity: BigUInt(signature.v)),
        //            r: EthereumQuantity(signature.r),
        //            s: EthereumQuantity(signature.s)
        //        )
        //        return Data(publicKey.rawPublicKey)
        Data()
    }

    func keccak256(_ data: Data) -> Data {
        //        let digest = SHA3(variant: .keccak256)
        //        let hash = digest.calculate(for: [UInt8](data))
        //        return Data(hash)
        //
        Data()
    }
}

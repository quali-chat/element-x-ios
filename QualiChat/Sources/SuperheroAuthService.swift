//
// Copyright 2025
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
//

import Combine
import Foundation
import UIKit

/// Lightweight deep link bridge for Superhero Wallet (Aeternity)
final class SuperheroAuthService {
    static let shared = SuperheroAuthService()
    private init() { }
    
    enum CallbackEvent {
        case connected(address: String, networkId: String?)
        case signed(address: String, signature: String)
        case error(String)
    }
    
    private let subject = PassthroughSubject<CallbackEvent, Never>()
    var events: AnyPublisher<CallbackEvent, Never> { subject.eraseToAnyPublisher() }
    
    // MARK: - Public API
    
    /// Open wallet to connect and return the Aeternity address via callback
    func openConnect() {
        guard let url = buildConnectURL() else { return }
        UIApplication.shared.open(url)
    }
    
    /// Open wallet to sign an arbitrary message and return signature via callback
    func openSign(message: String, address: String) {
        guard let url = buildSignURL(message: message, address: address) else { return }
        UIApplication.shared.open(url)
    }
    
    /// Returns true if the URL was handled as a Superhero callback
    @discardableResult
    func handleCallback(url: URL) -> Bool {
        guard url.scheme == InfoPlistReader.app.appScheme, url.host() == "superhero" else { return false }
        let path = url.path
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
        let query = components.queryItems ?? []
        func value(_ name: String) -> String? { query.first { $0.name == name }?.value }
        
        if path.hasSuffix("/connect"), let address = value("address") {
            let networkId = value("networkId")
            subject.send(.connected(address: address, networkId: networkId))
            return true
        }
        if path.hasSuffix("/signed"), let address = value("address"), let signature = value("signature") {
            subject.send(.signed(address: address, signature: signature))
            return true
        }
        if let error = value("error") {
            subject.send(.error(error))
            return true
        }
        return false
    }
    
    // MARK: - Deep link builders

    // Reference deep link schema: see Superhero Wallet docs.
    // https://github.com/superhero-com/superhero-wallet/tree/develop
    
    private func callbackBaseURL() -> URL {
        var components = URLComponents()
        components.scheme = InfoPlistReader.app.appScheme
        components.host = "superhero"
        components.path = "/callback"
        return components.url! // safe
    }
    
    private func buildConnectURL() -> URL? {
        // Format: https://wallet.superhero.com/address?x-success=<SUCCESS_URL>&x-cancel=<CANCEL_URL>
        // SUCCESS_URL must include placeholders {address} and {networkId}
        var success = URLComponents(url: callbackBaseURL(), resolvingAgainstBaseURL: false)!
        success.path = "/connect"
        success.queryItems = [
            .init(name: "address", value: "{address}"),
            .init(name: "networkId", value: "{networkId}")
        ]
        let successString = success.url?.absoluteString
        var cancel = URLComponents(url: callbackBaseURL(), resolvingAgainstBaseURL: false)!
        cancel.path = "/cancel"
        cancel.queryItems = [.init(name: "op", value: "connect")]
        let cancelString = cancel.url?.absoluteString
        var components = URLComponents()
        components.scheme = "https"
        components.host = "wallet.superhero.com"
        components.path = "/address"
        components.queryItems = [
            .init(name: "x-success", value: successString),
            .init(name: "x-cancel", value: cancelString)
        ]
        return components.url
    }
    
    private func buildSignURL(message: String, address: String) -> URL? {
        // Format: https://wallet.superhero.com/sign-message?message=<MESSAGE>&encoding=<ENCODING>&x-success=<SUCCESS_URL>&x-cancel=<CANCEL_URL>
        // SUCCESS_URL must include placeholders {signature} and {address}
        var success = URLComponents(url: callbackBaseURL(), resolvingAgainstBaseURL: false)!
        success.path = "/signed"
        success.queryItems = [
            .init(name: "address", value: "{address}"),
            .init(name: "signature", value: "{signature}")
        ]
        let successString = success.url?.absoluteString
        var cancel = URLComponents(url: callbackBaseURL(), resolvingAgainstBaseURL: false)!
        cancel.path = "/cancel"
        cancel.queryItems = [.init(name: "op", value: "sign")]
        let cancelString = cancel.url?.absoluteString
        var components = URLComponents()
        components.scheme = "https"
        components.host = "wallet.superhero.com"
        components.path = "/sign-message"
        let encodedMessage = message
        components.queryItems = [
            .init(name: "message", value: encodedMessage),
            // .init(name: "encoding", value: "hex") // Only set if message is hex; omitted for plain text
            .init(name: "x-success", value: successString),
            .init(name: "x-cancel", value: cancelString)
        ]
        return components.url
    }
}

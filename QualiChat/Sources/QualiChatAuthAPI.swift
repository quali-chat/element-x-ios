//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation

protocol QualiChatAuthApiProtocol {
    func nonce(address: String) async throws -> Result<String, Error>
    func verify(address: String, nonce: String, signature: String) async throws -> Result<String, Error>
    func sso(token: String) async throws -> Result<String, Error>
}

class QualiChatAuthApi: QualiChatAuthApiProtocol {
    private let appSettings: AppSettings
    
    init(appSettings: AppSettings) {
        self.appSettings = appSettings
    }
    
    func nonce(address: String) async throws -> (Result<String, Error>) {
        do {
            let requestBody = NonceRequest(address: address)
            let data = try await postJSON(to: "auth/nonce", payload: requestBody)
            let response = try decodeJSON(NonceResponse.self, from: data)
            return .success(response.nonce)
        } catch {
            return .failure(error)
        }
    }
    
    func verify(address: String, nonce: String, signature: String) async throws -> (Result<String, Error>) {
        do {
            let requestBody = VerifyRequest(address: address, nonce: nonce, signature: signature)
            let data = try await postJSON(to: "auth/verify", payload: requestBody)
            let response = try decodeJSON(VerifyResponse.self, from: data)
            return .success(response.token)
        } catch {
            return .failure(error)
        }
    }
    
    func sso(token: String) async throws -> (Result<String, Error>) {
        do {
            let requestBody = SSORequest(token: token)
            let data = try await postJSON(to: "auth/sso", payload: requestBody)
            let response = try decodeJSON(SSOResponse.self, from: data)
            return .success(response.matrixJwt)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - Private helpers

private extension QualiChatAuthApi {
    struct NonceRequest: Encodable { let address: String }
    struct NonceResponse: Decodable { let nonce: String }
    struct VerifyRequest: Encodable { let address: String; let nonce: String; let signature: String }
    struct VerifyResponse: Decodable { let token: String }
    struct SSORequest: Encodable { let token: String }
    struct SSOResponse: Decodable { let matrixJwt: String }
    struct ErrorResponse: Decodable { let error: String }
    
    enum QualiChatAuthApiError: Error, LocalizedError {
        case invalidURL
        case httpStatus(Int)
        case server(String)
        case decoding
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid URL"
            case .httpStatus(let code): return "HTTP error (status: \(code))"
            case .server(let message): return message
            case .decoding: return "Failed to decode server response"
            }
        }
    }
    
    func postJSON<T: Encodable>(to endpointPath: String, payload: T) async throws -> Data {
        guard let url = URL(string: endpointPath, relativeTo: appSettings.websiteURL)?.absoluteURL else {
            throw QualiChatAuthApiError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            return data
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try decode error message
            if let serverError = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw QualiChatAuthApiError.server(serverError.error)
            }
            throw QualiChatAuthApiError.httpStatus(httpResponse.statusCode)
        }
        return data
    }
    
    func decodeJSON<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw QualiChatAuthApiError.decoding
        }
    }
}

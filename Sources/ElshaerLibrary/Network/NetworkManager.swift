//
//  NetworkManager.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation
import Alamofire

// MARK: - NetworkError
public enum NetworkError: LocalizedError {
    case invalidBaseURL
    case noInternetConnection
    case decodingError(Error)
    case serverError(Int, String?)
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return "Invalid base URL"
        case .noInternetConnection:
            return "No internet connection"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return message ?? "Server error with code: \(code)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - NetworkManager
@MainActor
public final class NetworkManager {
    
    // MARK: - Singleton
    public static let shared = NetworkManager()
    
    // MARK: - Properties
    /// Base URL for API requests. Set this in your AppDelegate or SceneDelegate.
    public var baseURL: String?
    
    /// Enable debug logging (default: false)
    public var isDebugEnabled: Bool = false
    
    /// Optional base URL for debug logging (only logs if matches)
    public var debugBaseURL: String?
    
    private init() {}
    
    // MARK: - Nonisolated Accessors for Network Layer
    /// Thread-safe storage for baseURL (accessed from nonisolated context)
    // Note: baseURLQueue is nonisolated because it's used from nonisolated context
    nonisolated(unsafe) private static let baseURLQueue = DispatchQueue(label: "com.elshaerlibrary.network.baseURL")
    // Note: This property is marked as nonisolated(unsafe) because access is synchronized via baseURLQueue
    private nonisolated(unsafe) static var _baseURL: String?
    
    /// Nonisolated accessor for baseURL (for use in APIRouter)
    nonisolated public static func getBaseURL() -> String? {
        return baseURLQueue.sync {
            return _baseURL
        }
    }
    
    /// Set baseURL in thread-safe manner
    nonisolated public static func setBaseURL(_ url: String?) {
        baseURLQueue.sync {
            _baseURL = url
        }
        Task { @MainActor in
            shared.baseURL = url
        }
    }
    
    // MARK: - Configuration
    /// Configure the network manager with base URL
    public func configure(baseURL: String, debugEnabled: Bool = false, debugBaseURL: String? = nil) {
        self.baseURL = baseURL
        Self.setBaseURL(baseURL) // Also set in thread-safe storage
        self.isDebugEnabled = debugEnabled
        self.debugBaseURL = debugBaseURL
    }
    
    // MARK: - Request Method
    /// Performs a network request and decodes the response
    /// - Parameters:
    ///   - router: The API router conforming to APIRouter protocol
    ///   - completion: Completion handler with Result containing decoded data or error
    public func request<T: Decodable>(
        _ router: APIRouter,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // Check internet connectivity
        if !Connectivity.isConnectedToInternet() {
            completion(.failure(.noInternetConnection))
            return
        }
        
        // Perform request
        AF.request(router).responseData { [weak self] response in
            guard let self = self else { return }
            
            // Debug logging
            if self.isDebugEnabled {
                self.logRequest(response: response)
            }
            
            // Handle response
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch DecodingError.keyNotFound(let key, let context) {
                    if self.isDebugEnabled {
                        print("Key '\(key.stringValue)' not found:", context.debugDescription)
                        print("CodingPath:", context.codingPath)
                    }
                    completion(.failure(.decodingError(DecodingError.keyNotFound(key, context))))
                } catch DecodingError.typeMismatch(let type, let context) {
                    if self.isDebugEnabled {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("CodingPath:", context.codingPath)
                    }
                    completion(.failure(.decodingError(DecodingError.typeMismatch(type, context))))
                } catch DecodingError.valueNotFound(let value, let context) {
                    if self.isDebugEnabled {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("CodingPath:", context.codingPath)
                    }
                    completion(.failure(.decodingError(DecodingError.valueNotFound(value, context))))
                } catch DecodingError.dataCorrupted(let context) {
                    if self.isDebugEnabled {
                        print("Data corrupted:", context.debugDescription)
                        print("CodingPath:", context.codingPath)
                    }
                    completion(.failure(.decodingError(DecodingError.dataCorrupted(context))))
                } catch let error {
                    if self.isDebugEnabled {
                        print("Unknown decoding error:", error.localizedDescription)
                    }
                    completion(.failure(.decodingError(error)))
                }
            case .failure(let error):
                if let httpResponse = response.response {
                    let statusCode = httpResponse.statusCode
                    let errorMessage = String(data: response.data ?? Data(), encoding: .utf8)
                    completion(.failure(.serverError(statusCode, errorMessage)))
                } else {
                    completion(.failure(.unknown(error)))
                }
            }
        }
    }
    
    // MARK: - Debug Logging
    private func logRequest(response: AFDataResponse<Data>) {
        // Only log if debugBaseURL matches or is nil
        if let debugBaseURL = debugBaseURL,
           let requestURL = response.request?.url?.absoluteString,
           !requestURL.contains(debugBaseURL) {
            return
        }
        
        if let urlRequest = response.request {
            print("📡 Request URL: \(urlRequest.url?.absoluteString ?? "No URL")")
            
            // Print Parameters
            if let httpBody = urlRequest.httpBody,
               let paramsString = String(data: httpBody, encoding: .utf8) {
                print("📤 Request Parameters: \(paramsString)")
            } else {
                print("📤 No Parameters in the request body")
            }
            
            // Print Headers
            if let headers = urlRequest.allHTTPHeaderFields {
                print("📋 Request Headers:")
                prettyPrintKeyValue(headers)
            } else {
                print("📋 No Headers")
            }
        }
        
        if let data = response.data {
            printPrettyJSON(data: data)
        } else {
            print("📥 No response data")
        }
    }
    
    private func printPrettyJSON(data: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let prettyData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                print("📥 Response:")
                print("************************** Start of Response **************************")
                print(prettyString)
                print("************************** End of Response **************************")
            }
        } catch {
            print("❌ Failed to pretty print JSON: \(error.localizedDescription)")
        }
    }
    
    private func prettyPrintKeyValue(_ keyValueDict: [String: String]) {
        print("{")
        for (key, value) in keyValueDict {
            print("  \"\(key)\": \"\(value)\"")
        }
        print("}")
    }
}



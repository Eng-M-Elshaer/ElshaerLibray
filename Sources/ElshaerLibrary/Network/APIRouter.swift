//
//  APIRouter.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation
import Alamofire

// MARK: - APIRouter Protocol
/// Protocol that defines the structure for API routing.
/// Implement this protocol in your project to define your API endpoints.
public protocol APIRouter: URLRequestConvertible {
    /// The HTTP method for the request
    var method: HTTPMethod { get }
    
    /// The path component of the URL
    var path: String { get }
    
    /// Optional parameters for the request
    var parameters: Parameters? { get }
    
    /// Optional headers specific to this route
    var headers: HTTPHeaders? { get }
}

// MARK: - APIRouter Default Headers
public extension APIRouter {
    /// Default implementation returns nil (no custom headers)
    var headers: HTTPHeaders? {
        return nil
    }
}

// MARK: - APIRouter Default Implementation
public extension APIRouter {
    /// Default implementation that builds the URLRequest
    /// This method is nonisolated to allow access from network contexts
    nonisolated func asURLRequest() throws -> URLRequest {
        // Base URL should be configured in your project
        // Use thread-safe accessor
        guard let baseURL = NetworkManager.getBaseURL() else {
            throw NetworkError.invalidBaseURL
        }
        
        let url = try baseURL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP method
        urlRequest.httpMethod = method.rawValue
        
        // Default headers
        var defaultHeaders = HTTPHeaders()
        defaultHeaders[HeaderKeys.accept] = HeaderValues.applicationJson
        defaultHeaders[HeaderKeys.clientVersion] = HeaderValues.clientVersion
        defaultHeaders[HeaderKeys.clientType] = HeaderValues.clientType
        
        // Add language header - access UserDefaults directly (thread-safe)
        #if canImport(UIKit)
        if let locale = UserDefaults.standard.string(forKey: "Locale"),
           !locale.isEmpty {
            defaultHeaders[HeaderKeys.acceptLanguage] = locale
        }
        #endif
        
        // Add authorization header - access Keychain directly (thread-safe)
        if let token = KeychainManager.getToken(), !token.isEmpty {
            defaultHeaders[HeaderKeys.authorization] = "Bearer \(token)"
        }
        
        // Merge with custom headers
        if let customHeaders = headers {
            customHeaders.forEach { defaultHeaders[$0.name] = $0.value }
        }
        
        urlRequest.headers = defaultHeaders
        
        // Parameter encoding
        let encoding: ParameterEncoding = {
            switch method {
            case .get, .delete:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()
        
        return try encoding.encode(urlRequest, with: parameters)
    }
}


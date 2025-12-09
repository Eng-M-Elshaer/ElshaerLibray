//
//  DataModel.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation

// MARK: - DataModel
/// Generic envelope used throughout the API. Accepts two generic type parameters:
/// - `T` represents the main payload contained in the `data` field.
/// - `A` represents the type of the `additional_data` payload. By default most API
///   endpoints return a `StatusModel` here, but the generic allows callers to
///   customise this type when needed.
public struct DataModel<T: Codable, A: Codable>: Codable {
    /// HTTP or application specific status code returned by the backend.
    public let statusCode: Int?
    /// Human readable message provided by the backend.
    public let message: String?
    /// The primary payload returned from the request.
    public let data: T?
    /// Metadata such as pagination information.
    public let meta: Meta?
    /// Additional payload returned by the request. Its concrete type is defined by `A`.
    public let additionalData: A?

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case message, data, meta
        case additionalData = "additional_data"
    }
}

extension DataModel where A == EmptyCodable {
    public init(statusCode: Int?, message: String?, data: T?, meta: Meta?) {
        self.statusCode = statusCode
        self.message = message
        self.data = data
        self.meta = meta
        self.additionalData = nil
    }
}

// MARK: - Meta
public struct Meta: Codable {
    public let currentPage, from, lastPage: Int?
    public let perPage, to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to, total
    }
}

// MARK: - EmptyCodable
public struct EmptyCodable: Codable {}

// MARK: - Response Aliases
/// Convenience alias for responses where the `additional_data` field contains a
/// `StatusModel`. Most endpoints return this type.
public typealias APIResponse<T: Codable> = DataModel<T, StatusModel>

/// Convenience alias for responses where the `additional_data` field is empty.
public typealias APIResponseNone<T: Codable> = DataModel<T, EmptyCodable>

// MARK: - StatusModel
/// Default model for `additional_data` field in API responses.
/// Implement this in your project or replace with your own model.
public struct StatusModel: Codable {
    // Add your status model properties here
    // This is a placeholder that can be replaced in your project
}


//
//  BaseViewModel.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation

/// Base view model with common validation and utility methods
open class BaseViewModel {
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Validation Methods
    
    /// Checks if all boolean values in array are true
    /// - Parameter isValidArray: Array of boolean values
    /// - Returns: True if all values are true, false otherwise
    public func isValid(isValidArray: [Bool]) -> Bool {
        return isValidArray.allSatisfy { $0 }
    }
    
    /// Validates multiple conditions
    /// - Parameter conditions: Array of validation conditions
    /// - Returns: True if all conditions are met
    public func validate(_ conditions: Bool...) -> Bool {
        return conditions.allSatisfy { $0 }
    }
    
    // MARK: - String Utilities
    
    /// Extracts first and last name from a full name string
    /// - Parameter fullName: Full name string
    /// - Returns: Tuple containing firstName and lastName
    public func extractFirstAndLastName(from fullName: String) -> (firstName: String, lastName: String) {
        // Split the full name into components based on whitespace
        let nameComponents = fullName.split(separator: " ").map { String($0) }
        
        // Check if there's at least one name
        guard !nameComponents.isEmpty else {
            return (firstName: "", lastName: "")
        }
        
        // First name is always the first component
        let firstName = nameComponents.first ?? ""
        
        // Last name is everything after the first name
        let lastName = nameComponents.dropFirst().joined(separator: " ")
        
        return (firstName: firstName, lastName: lastName)
    }
    
    /// Splits a string into components
    /// - Parameters:
    ///   - string: String to split
    ///   - separator: Separator character (default: space)
    /// - Returns: Array of string components
    public func splitString(_ string: String, separator: Character = " ") -> [String] {
        return string.split(separator: separator).map { String($0) }
    }
    
    // MARK: - Array Utilities
    
    /// Checks if array is not empty
    /// - Parameter array: Array to check
    /// - Returns: True if array has elements
    public func isNotEmpty<T>(_ array: [T]) -> Bool {
        return !array.isEmpty
    }
    
    /// Checks if array is empty
    /// - Parameter array: Array to check
    /// - Returns: True if array is empty
    public func isEmpty<T>(_ array: [T]) -> Bool {
        return array.isEmpty
    }
    
    // MARK: - Optional Utilities
    
    /// Unwraps optional value or returns default
    /// - Parameters:
    ///   - value: Optional value
    ///   - defaultValue: Default value if nil
    /// - Returns: Unwrapped value or default
    public func unwrapOrDefault<T>(_ value: T?, defaultValue: T) -> T {
        return value ?? defaultValue
    }
    
    /// Checks if optional is not nil
    /// - Parameter value: Optional value
    /// - Returns: True if value is not nil
    public func isNotNil<T>(_ value: T?) -> Bool {
        return value != nil
    }
}


//
//  Validator.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

#if canImport(UIKit)
import UIKit
#endif

@MainActor
public final class Validator {
    
    //MARK: - Singleton.
    public static let shared = Validator()
    
    // Private init to prevent external instantiation
    private init() {}
    private let selfMatch: String = "SELF MATCHES %@"
    
    // MARK: - Validation Methods
    
    // FullName Validation
    public func isValidFullName(_ name: String) -> Bool {
        let nameRegEx = "^[a-zA-Z\\s]+$"
        let nameTest = NSPredicate(format: selfMatch, nameRegEx)
        return nameTest.evaluate(with: name)
    }
    
    // Username Validation
    public func isValidUsername(_ username: String) -> Bool {
        let usernameRegEx = "^[a-zA-Z0-9_]{3,}$"
        let usernameTest = NSPredicate(format: selfMatch, usernameRegEx)
        return usernameTest.evaluate(with: username)
    }
    
    // Email Validation
    public func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,64}$"
        let emailTest = NSPredicate(format: selfMatch, emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    // Phone Number Validation (Basic for example purposes)
    public func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegEx = "^[0-9]{10}$"
        let phoneTest = NSPredicate(format: selfMatch, phoneRegEx)
        return phoneTest.evaluate(with: phoneNumber)
    }
    public func isValidEgyptianPhoneNumber(_ phoneNumber: String) -> Bool {
        // Egyptian mobile numbers start with 010, 011, 012, or 015 and have 11 digits total
        let phoneRegEx = "^(010|011|012|015)[0-9]{8}$"
        let phoneTest = NSPredicate(format: selfMatch, phoneRegEx)
        return phoneTest.evaluate(with: phoneNumber)
    }
    
    // Password Validation (Example: at least 8 characters, 1 uppercase, 1 lowercase, and 1 number)
    public func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$"
        let passwordTest = NSPredicate(format: selfMatch, passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    // URL Validation
    public func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        #if canImport(UIKit)
        return UIApplication.shared.canOpenURL(url)
        #else
        // In non-UIKit contexts, just validate the URL format
        return true
        #endif
    }

    // InstaPay Link Validation
    // Supports:
    //  - https://instapay.me/username
    //  - https://instapay.eg/username
    //  - https://ipn.eg/S/.../instapay/...
    public func isValidInstaPayLink(_ link: String) -> Bool {
        let trimmedLink = link.trimmingCharacters(in: .whitespacesAndNewlines)
        let instapayRegEx = "^https?://(www\\.)?((instapay\\.me|instapay\\.eg)/[A-Za-z0-9._-]+|ipn\\.eg/.*/instapay/.+)$"
        let instapayTest = NSPredicate(format: selfMatch, instapayRegEx)
        return instapayTest.evaluate(with: trimmedLink)
    }
    
    // Empty Field Validation
    public func isEmpty(_ text: String) -> Bool {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

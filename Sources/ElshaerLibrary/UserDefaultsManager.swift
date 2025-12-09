//
//  UserDefaultsManager.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation
import KeychainAccess
import CryptoKit

// MARK: - EncryptionManager for secure storage in UserDefaults
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class EncryptionManager {
    static let key = SymmetricKey(size: .bits256)
    
    public static func encrypt(_ text: String) -> Data? {
        let data = text.data(using: .utf8)!
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    
    public static func decrypt(_ data: Data) -> String? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
}

// MARK: - KeychainManager for storing sensitive information like tokens
public final class KeychainManager {
    // Note: These properties are marked as nonisolated(unsafe) because access is synchronized via keychainQueue
    private nonisolated(unsafe) static var serviceName: String = Bundle.main.bundleIdentifier ?? "default.keychain.service"
    private static let keychainQueue = DispatchQueue(label: "com.elshaerlibrary.keychain", qos: .utility)
    private nonisolated(unsafe) static var _keychain: Keychain = Keychain(service: serviceName)
    
    private static var keychain: Keychain {
        return keychainQueue.sync {
            return _keychain
        }
    }

    /// Configure the Keychain service name once at app start (e.g., in AppDelegate/SceneDelegate).
    /// - Parameter service: A unique service string, typically your bundle identifier.
    public static func configure(service: String) {
        keychainQueue.sync {
            serviceName = service
            _keychain = Keychain(service: service)
        }
    }
    
    public static func saveToken(token: String) {
        keychainQueue.async {
            do {
                try self._keychain.set(token, key: "token")
            } catch let error {
                print("Error saving token: \(error)")
            }
        }
    }
    
    nonisolated public static func getToken() -> String? {
        return keychainQueue.sync {
            return try? _keychain.get("token")
        }
    }
    
    public static func deleteToken() {
        keychainQueue.async {
            do {
                try self._keychain.remove("token")
            } catch let error {
                print("Error deleting token: \(error)")
            }
        }
    }
    
    public static func saveFCMToken(fcmToken: String) {
        keychainQueue.async {
            do {
                try self._keychain.set(fcmToken, key: "fcmToken")
            } catch let error {
                print("Error saving FCM token: \(error)")
            }
        }
    }
    
    nonisolated public static func getFCMToken() -> String? {
        return keychainQueue.sync {
            return try? _keychain.get("fcmToken")
        }
    }
    
    public static func deleteFCMToken() {
        keychainQueue.async {
            do {
                try self._keychain.remove("fcmToken")
            } catch let error {
                print("Error deleting FCM token: \(error)")
            }
        }
    }
}

// MARK: - UserDefaultsManager with EncryptionManager and KeychainManager
@MainActor
public final class UserDefaultsManager {
    
    // MARK: - Singleton.
    public static let shared = UserDefaultsManager()
    
    // Private init to prevent external instantiation
    private init() {}
    
    // MARK: - Properties.
    // For non-sensitive data, store it in UserDefaults with encryption
    public var isLoggedIn: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isLoggedIn")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isLoggedIn")
        }
    }
    
    public var isAppOpenedBefore: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "firstTime")
        }
        get {
            return UserDefaults.standard.bool(forKey: "firstTime")
        }
    }
    
    // For sensitive data like tokens, store it securely in Keychain
    public var token: String? {
        set {
            if let token = newValue {
                KeychainManager.saveToken(token: token)
            }
            if newValue == nil {
                KeychainManager.deleteToken()
            }
        }
        get {
            return KeychainManager.getToken()
        }
    }
    
    public var fcmToken: String? {
        set {
            if let fcmToken = newValue {
                KeychainManager.saveFCMToken(fcmToken: fcmToken)
            }
            if newValue == nil {
                KeychainManager.deleteFCMToken()
            }
        }
        get {
            return KeychainManager.getFCMToken()
        }
    }
    
    // Encrypt non-sensitive values before storing them in UserDefaults
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public var appLang: String? {
        set {
            if let lang = newValue, let encryptedLang = EncryptionManager.encrypt(lang) {
                UserDefaults.standard.set(encryptedLang, forKey: "appLang")
            }
        }
        get {
            guard let encryptedLang = UserDefaults.standard.data(forKey: "appLang") else { return nil }
            return EncryptionManager.decrypt(encryptedLang)
        }
    }
    public var isNotificationOn: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "pushNotificationsEnabled")
        }
        get {
            return UserDefaults.standard.bool(forKey: "pushNotificationsEnabled")
        }
    }
    public var notificationCount: Int? {
        set {
            UserDefaults.standard.set(newValue, forKey: "notificationCount")
        }
        get {
            guard UserDefaults.standard.object(forKey: "notificationCount") != nil else {
                return nil
            }
            return UserDefaults.standard.integer(forKey: "notificationCount")
        }
    }
    public var isFaceIDOn: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "faceIDEnabled")
        }
        get {
            return UserDefaults.standard.bool(forKey: "faceIDEnabled")
        }
    }
    public var isEyeOn: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "eyeOn")
        }
        get {
            return UserDefaults.standard.bool(forKey: "eyeOn")
        }
    }
}

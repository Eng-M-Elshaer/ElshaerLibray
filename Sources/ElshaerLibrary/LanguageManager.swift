//
//  LanguageManager.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

#if canImport(UIKit)
import UIKit
#endif

/// Supported application languages.
/// The raw value is used as the language code (e.g. "ar", "en") when saving to UserDefaults and loading `.lproj` bundles.
public enum Language: String {
    case ar = "ar"
    case en = "en"
}

/// Key container used for associated objects in the language system.
/// Using a `UInt8` stored property and passing its address to the Objective‑C
/// runtime is the recommended pattern for associated-object keys.
@MainActor
private struct AssociatedKeys {
    static var languageBundleKey: UInt8 = 0
}

/// Central language manager responsible for:
/// - Reading and writing the current language to `UserDefaults`.
/// - Applying the correct `semanticContentAttribute` for all `UIView` appearances.
/// - Providing helpers such as `isRTL()` and human‑readable language descriptions.
@MainActor
public final class LanguageManager {
    
    // MARK: - Singleton
    /// Shared singleton instance used across the app.
    public static let shared = LanguageManager()
    
    private init () {
        // set default language
        let currentLocale = getCurrentLanguage()
        setLanguage(to: currentLocale)
    }
    
    // MARK: - Public Methods
    /// Change the current application language.
    /// Updates:
    /// - Global `UIView` semantic content attribute (LTR / RTL).
    /// - `UserDefaults` keys `"Locale"` and `"AppleLanguages"`.
    public func setLanguage (to newLang: Language) {
        #if canImport(UIKit)
        switch newLang {
        case .ar:
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        default:
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        #endif
        UserDefaults.standard.set(newLang.rawValue, forKey: "Locale")
        UserDefaults.standard.set([newLang.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    /// Returns the currently stored language.
    /// Defaults to `.en` if nothing is stored or the value is invalid.
    public func getCurrentLanguage () -> Language {
        guard let locale = UserDefaults.standard.string(forKey: "Locale") else {
            return .en
        }
        return Language(rawValue: locale) ?? .en
    }
    /// Human‑readable language name for UI display.
    public func getDescription (of lang: Language) -> String {
        switch lang {
        case .en:
            return "English"
        default:
            return "العربية"
        }
    }
    /// Returns `true` when the stored language is right‑to‑left (currently only `"ar"`).
    public func isRTL () -> Bool {
        guard let locale = UserDefaults.standard.string(forKey: "Locale") else {
            return true
        }
        return locale == "ar"
    }
}

#if canImport(UIKit)

@MainActor
extension UIApplication {
    /// Convenience helper to check whether the current interface layout direction is RTL.
    class func isRTL() -> Bool{
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    }
}

@MainActor
extension UIApplication {
    /// Swizzled implementation of `userInterfaceLayoutDirection` that forces RTL when the app language is Arabic.
    @objc var cstm_userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
        get {
            var direction = UIUserInterfaceLayoutDirection.leftToRight
            if LanguageManager.shared.getCurrentLanguage().rawValue == "ar" {
                direction = .rightToLeft
            }
            return direction
        }
    }
}

/// Helper responsible for performing all required method swizzling
/// to make localization and RTL/LTR layout work automatically.
@MainActor
public final class LanguageManagerHelper: NSObject {
    /// Call once (e.g. from `AppDelegate`) to swizzle `Bundle`, `UIApplication`,
    /// `UITextField`, and `UILabel` for dynamic language and alignment handling.
    public class func DoTheMagic() {
        MethodSwizzleGivenClassName(cls: Bundle.self,
                                    originalSelector: #selector(Bundle.localizedString(forKey:value:table:)),
                                    overrideSelector: #selector(Bundle.specialLocalizedStringForKey(_:value:table:)))
        
        MethodSwizzleGivenClassName(cls: UIApplication.self,
                                    originalSelector: #selector(getter: UIApplication.userInterfaceLayoutDirection),
                                    overrideSelector: #selector(getter: UIApplication.cstm_userInterfaceLayoutDirection))
        
        MethodSwizzleGivenClassName(cls: UITextField.self,
                                    originalSelector: #selector(UITextField.layoutSubviews),
                                    overrideSelector: #selector(UITextField.cstmlayoutSubviews))
        
        MethodSwizzleGivenClassName(cls: UILabel.self,
                                    originalSelector: #selector(UILabel.layoutSubviews),
                                    overrideSelector: #selector(UILabel.cstmlayoutSubviews))
    }
}

extension UILabel {
    /// Swizzled layout for `UILabel` that automatically adjusts `textAlignment`
    /// based on the current layout direction when `tag <= 0`.
    @objc public func cstmlayoutSubviews() {
        self.cstmlayoutSubviews()
        if self.isKind(of: NSClassFromString("UITextFieldLabel")!) {
            return // handle special case with uitextfields
        }
        if self.tag <= 0  {
            if UIApplication.isRTL()  {
                if self.textAlignment == .right {
                    return
                } else if self.textAlignment == .center {
                    return
                }
            } else {
                if self.textAlignment == .left {
                    return
                }  else if self.textAlignment == .center {
                    return
                }
            }
        }
        if self.tag <= 0 {
            if UIApplication.isRTL()  {
                self.textAlignment = .right
            } else {
                self.textAlignment = .left
            }
        }
    }
}

extension UITextField {
    /// Swizzled layout for `UITextField` to keep the text aligned with the current RTL / LTR direction.
    @objc public func cstmlayoutSubviews() {
        self.cstmlayoutSubviews()
        if self.tag <= 0 {
            if UIApplication.isRTL()  {
                if self.textAlignment == .right { return }
                self.textAlignment = .right
            } else {
                if self.textAlignment == .left { return }
                self.textAlignment = .left
            }
        }
    }
}

extension UITextView {
    /// Swizzled layout for `UITextView` to keep the text aligned with the current RTL / LTR direction.
    @objc public func cstmlayoutSubviews() {
        self.cstmlayoutSubviews()
        if self.tag <= 0 {
            if UIApplication.isRTL()  {
                if self.textAlignment == .right { return }
                self.textAlignment = .right
            } else {
                if self.textAlignment == .left { return }
                self.textAlignment = .left
            }
        }
    }
}

extension Bundle {
    /// Custom localized string lookup used after swizzling `Bundle.localizedString(forKey:value:table:)`.
    /// It loads the correct `.lproj` bundle based on the current language managed by `LanguageManager`.
    @MainActor @objc func specialLocalizedStringForKey(_ key: String, value: String?, table tableName: String?) -> String {
        if self == Bundle.main {
            var bundle = Bundle()
            if let _path = Bundle.main.path(forResource: LanguageManager.shared.getCurrentLanguage().rawValue, ofType: "lproj") {
                bundle = Bundle(path: _path)!
            } else {
                let _path = Bundle.main.path(forResource: "Base", ofType: "lproj")!
                bundle = Bundle(path: _path)!
            }
            return (bundle.specialLocalizedStringForKey(key, value: value, table: tableName))
        } else {
            return (self.specialLocalizedStringForKey(key, value: value, table: tableName))
        }
    }
}
#endif

/// Dummy function kept to make it easy to disable swizzling at link time if needed.
@MainActor
func disableMethodSwizzling() {}

/// Exchanges implementations of two instance methods on a given class at runtime.
/// Used to intercept UIKit and Bundle behaviors for localization and alignment.
@MainActor
func MethodSwizzleGivenClassName(cls: AnyClass, originalSelector: Selector, overrideSelector: Selector) {
    guard let origMethod: Method = class_getInstanceMethod(cls, originalSelector),
        let overrideMethod: Method = class_getInstanceMethod(cls, overrideSelector) else {
        return
    }
    if (class_addMethod(cls, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(cls, overrideSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}


@MainActor
final class PrivateBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle = objc_getAssociatedObject(self, &AssociatedKeys.languageBundleKey) as? Bundle
        return bundle != nil ? (bundle?.localizedString(forKey: key, value: value, table: tableName))! :
            super.localizedString(forKey: key, value: value, table: tableName)
    }
}

@MainActor
extension Bundle {
    class func setLanguage(language: String) {
        DispatchQueue.once {
            object_setClass(main, PrivateBundle.classForCoder())
        }
        var bundle = Bundle()
        if let _path = Bundle.main.path(forResource: language, ofType: "lproj") {
            bundle = Bundle(path: _path)!
        } else {
            let _path = Bundle.main.path(forResource: "Base", ofType: "lproj")!
            bundle = Bundle(path: _path)!
        }
        objc_setAssociatedObject(
            main,
            &AssociatedKeys.languageBundleKey,
            language.isEmpty ? nil : bundle,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}

@MainActor
public extension DispatchQueue {
    private static var _onceTracker = [String]()
    
    class func once(file: String = #file, function: String = #function, line: Int = #line, block:()->Void) {
        let token = file + ":" + function + ":" + String(line)
        once(token: token, block: block)
    }
    class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
}

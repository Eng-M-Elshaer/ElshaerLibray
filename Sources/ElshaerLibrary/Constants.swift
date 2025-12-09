//
//  Constants.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

#if canImport(UIKit)
import UIKit
#endif

// Header Keys
public struct HeaderKeys {
    static let localization: String = "x-localization"
    static let acceptLanguage: String = "Accept-Language"
    static let contentType: String = "Content-Type"
    static let authorization: String = "Authorization"
    static let accept: String = "Accept"
    static let paymentMode: String = "PaymentMode"
    static let clientType: String = "CLIENT-TYPE"
    static let clientVersion: String = "CLIENT-VERSION"
}

// Header Values
public struct HeaderValues {
    static let applicationJson: String = "application/json"
    static let applicationURL: String = "application/x-www-form-urlencoded"
    static let clientType: String = "ios"
    static let clientVersion: String = "1.0.0"
}

#if canImport(UIKit)
// View Constants
public struct ViewConstants {
    static let corners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
    static let radius: CGFloat = 15
    static let borderWidth: CGFloat = 1
    // Z Postion
    static let checkerViewZPostion: CGFloat = 888
    // Tags
    static let checkerViewTag: Int = 888
    static let scrollViewTag: Int = 777
    static let tableViewTag: Int = 666
    static let centerImageViewTag: Int = 555
    static let centerImageLabelTag: Int = 5555
}
#endif


// SystemImageName
public struct SystemImageName {
    static let chevronBackward: String = "chevron.backward"
    static let chevronForward: String = "chevron.forward"
    static let chevronDown: String = "chevron.down"
    static let chevronUp: String = "chevron.up"
    static let plusCircleFill: String = "plus.circle.fill"
    static let minusCircle: String = "minus.circle"
    static let appleLogo: String = "apple.logo"
    static let plus: String = "plus"
    static let checkmarkSquare: String = "checkmark.square"
    static let square: String = "square"
    static let circle: String = "circle"
    static let dotCircle : String = "dot.circle"
    static let circleInsetFilled: String = "circle.inset.filled"
    static let checkmarkCircleFill: String = "checkmark.circle.fill"
    static let envelopeFill: String = "envelope.fill"
    static let paperplaneFill: String = "paperplane.fill"
    static let magnifyingglass: String = "magnifyingglass"
    static let creditcardFill: String = "creditcard.fill"
    static let eye: String = "eye"
    static let eyeSlash: String = "eye.slash"
    static let squareAndArrowUp: String = "square.and.arrow.up"
    static let listBulletClipboardFill: String = "list.bullet.clipboard.fill"
    static let lockOpenFill: String = "lock.open.fill"
    static let circleFill: String = "circle.fill"
    static let heartFill: String = "heart.fill"
    static let heart: String = "heart"
}

#if canImport(UIKit)
/// Common app bundle information exposed to the rest of the app.
/// This struct reads values from `Bundle.main` so it can be reused across different apps.
public struct AppBundle {
    /// e.g. "1.0.0"
    static let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    /// e.g. "1"
    static let build: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    /// CFBundleName (internal bundle name)
    static let name: String = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    /// CFBundleDisplayName (user-facing app name)
    static let shortName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    /// The bundle identifier of the running app, e.g. "com.company.app".
    static let bundle: String = Bundle.main.bundleIdentifier ?? ""
}
#endif

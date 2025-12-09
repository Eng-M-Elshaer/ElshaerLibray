# ElshaerLibrary

UIKit-ready utility library for iOS 15+ that bundles common building blocks: language management with automatic RTL/LTR swizzling, IBDesignable UI components, ready-made toast and popup view controllers, secure token storage via Keychain, image loading with Kingfisher, and validators for strings and numbers. Written in modern Swift and easy to plug into MVC/DI setups.

## Requirements
- iOS 15 or later.
- Swift Package Manager (project uses Swift 6.2 tools).
- Dependencies: Alamofire, Kingfisher, KeychainAccess, IQKeyboardManagerSwift, NVActivityIndicatorView, PhoneNumberKit.

## Installation (Swift Package Manager)
1) Xcode → `File` → `Add Packages...`  
2) URL: `https://github.com/Eng-M-Elshaer/ElshaerLibray.git`  
3) Select `ElshaerLibrary` for your target.

Or in `Package.swift`:
```swift
.package(url: "https://github.com/Eng-M-Elshaer/ElshaerLibray.git", from: "1.0.0")
```

## Quick Start
```swift
import ElshaerLibrary

// 1) App language + RTL/LTR swizzling
LanguageManager.shared.setLanguage(to: .ar)
LanguageManagerHelper.DoTheMagic() // call once from AppDelegate/SceneDelegate

// 2) Store token in Keychain
UserDefaultsManager.shared.token = "JWT/TOKEN"

// 3) Validation
let isValidEmail = Validator.shared.isValidEmail("user@example.com")

// 4) Quick toast
ToatsVC.show(message: "Saved", type: .success)

// 5) Confirmation popup (call after the presenting VC is visible, e.g. in viewDidAppear)
DispatchQueue.main.async {
    self.showConfirmationPopup(
        title: "Delete item?",
        message: "This action cannot be undone",
        confirmTitle: "Delete",
        cancelTitle: "Cancel",
        style: .destructive,
        onConfirm: { /* delete */ },
        onCancel: nil
    )
}
```

## Key Features
- **Language & RTL**: `LanguageManager` stores language, swizzles `Bundle`, `UIApplication`, `UILabel`, `UITextField`, `UITextView` so direction/alignment auto-adjust.
-, **Secure storage**: `UserDefaultsManager` simple API for token/FCM token (Keychain) plus flags like login state, counters, notifications. `EncryptionManager` (AES.GCM) for non-sensitive values in UserDefaults.
- **Validators**: email, Egyptian phone, strong password, username, InstaPay links, URL checks.
- **UI components**: @IBDesignable buttons/text fields/views with gradients, underline, stroke, corner radius, shadow; self-sized collection/table/text views with placeholder; gradient stack view; badges; round corners; animations; built-in activity indicator helper.
- **Image loading**: `UIImageView.loadImage` and `loadImageProfile` using Kingfisher with HTTPS auto-upgrade and error logging.
- **Networking**: `Connectivity.isConnectedToInternet()` via Alamofire reachability.
- **Files**: `PDFVC` for viewing/sharing PDFs, `TextVC` to display text/HTML in a scroll view.
- **Maps**: `openMapsWith` offers Apple Maps or Google Maps when available.
- **Helpers**: `Double.formattedCurrency/rounded/degreesToRadians` and `String` date/time/html/number formatting.

## Popups & Toasts
- `CheckerVC`: card with info/success/warning/error, optional button, dimmed background.
- `InfoPopUpVC`: single-action message popup.
- `ConfrimationVC`: two-button confirm/cancel with destructive style.
- `TextFieldPopUpVC`: text input with min-length validation.
- `ToatsVC`: bottom toast (info/success/error) with optional button.

### Example: success message
```swift
showInfoPopup(
    image: UIImage(systemName: SystemImageName.checkmarkCircleFill),
    title: "Success",
    message: "Operation completed",
    style: .success
)
```

### Example: short toast with action
```swift
ToatsVC.show(
    message: "No internet",
    type: .error,
    buttonTitle: "Settings",
    onButtonTap: { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }
)
```

## Usage Notes
- All UI classes are wrapped in `#if canImport(UIKit)`; the module targets iOS.
- Some constants are sample defaults (e.g., `KeychainManager.service = "restart.breakfast.app"` and header values); change to fit your app.
- `EncryptionManager` generates an in-memory key; if you need persistence, store your own key securely.
- Most views expose @IBInspectable knobs, so you can style them directly from Interface Builder.

## Tests
No bundled tests yet—consider adding unit tests for pieces you use (e.g., Validator, LanguageManager).

## License
No license file found; confirm with the owner before commercial use.
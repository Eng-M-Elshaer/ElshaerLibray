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
self.showConfirmationPopup(
    title: "Delete item?",
    message: "This action cannot be undone",
    confirmTitle: "Delete",
    cancelTitle: "Cancel",
    style: .destructive,
    onConfirm: { /* delete */ },
    onCancel: nil
)
```

## Key Features
- **Language & RTL**: `LanguageManager` stores language, swizzles `Bundle`, `UIApplication`, `UILabel`, `UITextField`, `UITextView` so direction/alignment auto-adjust.
- **Secure storage**: `UserDefaultsManager` simple API for token/FCM token (Keychain) plus flags like login state, counters, notifications. `EncryptionManager` (AES.GCM) for non-sensitive values in UserDefaults.
- **Validators**: email, Egyptian phone, strong password, username, InstaPay links, URL checks.
- **UI components**: @IBDesignable buttons/text fields/views with gradients, underline, stroke, corner radius, shadow; self-sized collection/table/text views with placeholder; gradient stack view; badges; round corners; animations; built-in activity indicator helper.
- **Image loading**: `UIImageView.loadImage` and `loadImageProfile` using Kingfisher with HTTPS auto-upgrade and error logging.
- **Networking**: Generic `NetworkManager` with `APIRouter` protocol, `DataModel<T, A>` response wrapper, automatic token injection, debug logging, and connectivity checks.
- **Base Classes**: `BaseViewController` with navigation helpers, popup methods, loading indicators, and UI utilities. `BaseViewModel` with validation and string utilities.
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

## Base Classes

The library provides `BaseViewController` and `BaseViewModel` classes that you can inherit from to get common functionality.

### BaseViewController

A base view controller with navigation helpers, popup methods, loading indicators, and UI utilities.

#### Features
- Automatic navigation bar hiding/showing
- Popup helpers (error, success, info, checker)
- Loading indicator management
- Center image with label
- View type showing/hiding (table/scroll)
- Navigation helpers

#### Example Usage
```swift
import ElshaerLibrary

class MyViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show loading
        showMainLoader()
        
        // Load data
        loadData()
    }
    
    func loadData() {
        // Your data loading logic
        NetworkManager.shared.request(MyAPIRouter.getData) { [weak self] result in
            self?.hideMainLoader()
            
            switch result {
            case .success(let response):
                self?.showSuccessPopup(
                    title: "Success",
                    message: "Data loaded successfully"
                )
            case .failure(let error):
                self?.showErrorPopup(
                    title: "Error",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    func showEmptyState() {
        setCenterImage(
            named: "empty_state",
            labelText: "No data available"
        )
    }
    
    func hideEmptyState() {
        removeCenterImage()
    }
    
    @IBAction func logoutTapped() {
        showConfirmationPopup(
            title: "Logout?",
            message: "Are you sure you want to logout?",
            confirmTitle: "Logout",
            cancelTitle: "Cancel",
            style: .destructive,
            onConfirm: { [weak self] in
                self?.logOutAction {
                    // Navigate to login
                }
            }
        )
    }
}
```

#### Available Methods

**Popup Methods:**
```swift
// Error popup
showErrorPopup(title: "Error", message: "Something went wrong")

// Success popup with completion
showSuccessPopup(
    title: "Success",
    message: "Operation completed",
    completion: { /* handle completion */ }
)

// Custom style popup
showPopup(
    style: .warning,
    title: "Warning",
    message: "Please check your input"
)

// Checker popup
showChecker(
    image: UIImage(systemName: "checkmark.circle.fill"),
    title: "Done",
    message: "Operation completed successfully",
    buttonTitle: "OK"
)

// Unauthenticated popup
showUnauthenticatedPopup(onLogin: {
    // Navigate to login
})

// Update alert
showUpdateAlert(appStoreURL: "https://apps.apple.com/app/id123456")

// Info sheet with HTML
showInfoSheet(htmlString: "<h1>About Us</h1><p>Content...</p>")
```

**Navigation Methods:**
```swift
// Go back
goToBackScreen()

// Logout (override to customize)
override func logOutAction(completion: (() -> Void)?) {
    // Custom logout logic
    UserDefaultsManager.shared.isLoggedIn = false
    UserDefaultsManager.shared.token = nil
    completion?()
}
```

**UI Helper Methods:**
```swift
// Show/hide loader
showMainLoader()
hideMainLoader()

// Show/hide views
showView(for: .table)  // Shows table view
showView(for: .scroll) // Shows scroll view

// Center image
setCenterImage(named: "empty_state", labelText: "No data")
removeCenterImage()

// Handle hint label
handleHint(
    for: errorLabel,
    stackView: inputStackView,
    show: hasError,
    errorColor: .systemRed,
    normalColor: .systemBlue
)
```

### BaseViewModel

A base view model with validation and utility methods.

#### Features
- Validation helpers
- String utilities (name extraction, splitting)
- Array utilities
- Optional utilities

#### Example Usage
```swift
import ElshaerLibrary

class MyViewModel: BaseViewModel {
    
    func validateForm(name: String, email: String, phone: String) -> Bool {
        let nameValid = !name.isEmpty
        let emailValid = Validator.shared.isValidEmail(email)
        let phoneValid = Validator.shared.isValidEgyptianPhoneNumber(phone)
        
        return isValid(isValidArray: [nameValid, emailValid, phoneValid])
        // Or: return validate(nameValid, emailValid, phoneValid)
    }
    
    func processFullName(_ fullName: String) {
        let (firstName, lastName) = extractFirstAndLastName(from: fullName)
        print("First: \(firstName), Last: \(lastName)")
    }
    
    func checkData(_ data: [String]?) {
        if let data = data, isNotEmpty(data) {
            // Process data
        }
    }
}
```

#### Available Methods

**Validation:**
```swift
// Check all validations
let isValid = isValid(isValidArray: [true, true, false]) // false

// Validate multiple conditions
let isValid = validate(true, true, false) // false
```

**String Utilities:**
```swift
// Extract first and last name
let (firstName, lastName) = extractFirstAndLastName(from: "John Doe Smith")
// firstName: "John", lastName: "Doe Smith"

// Split string
let components = splitString("one two three", separator: " ")
// ["one", "two", "three"]
```

**Array Utilities:**
```swift
// Check if array is not empty
if isNotEmpty(items) {
    // Process items
}

// Check if array is empty
if isEmpty(items) {
    // Show empty state
}
```

**Optional Utilities:**
```swift
// Unwrap with default
let value = unwrapOrDefault(optionalValue, defaultValue: "default")

// Check if not nil
if isNotNil(optionalValue) {
    // Use value
}
```

## Network Layer

The library provides a generic network layer that you can extend in your projects.

### Setup
```swift
// In AppDelegate or SceneDelegate
NetworkManager.shared.configure(
    baseURL: "https://api.example.com/v1",
    debugEnabled: true, // Enable request/response logging
    debugBaseURL: "https://api.example.com" // Optional: only log requests to this domain
)
```

### Define Your Router
```swift
import ElshaerLibrary
import Alamofire

enum MyAPIRouter: APIRouter {
    // Auth endpoints
    case login(phone: String, password: String)
    case register(name: String, email: String, phone: String, password: String)
    case logout
    case forgotPassword(email: String)
    
    // User endpoints
    case getUserProfile
    case updateProfile(name: String, email: String)
    case deleteAccount(password: String)
    
    // Data endpoints with pagination
    case getUsers(page: Int, size: Int)
    case getUserById(id: Int)
    case createUser(name: String, email: String)
    
    // Custom headers example
    case uploadFile(data: Data)
    
    var method: HTTPMethod {
        switch self {
        case .login, .register, .forgotPassword, .createUser, .uploadFile:
            return .post
        case .updateProfile:
            return .put
        case .deleteAccount:
            return .delete
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .register: return "/auth/register"
        case .logout: return "/auth/logout"
        case .forgotPassword: return "/auth/forgot-password"
        case .getUserProfile: return "/user/profile"
        case .updateProfile: return "/user/profile"
        case .deleteAccount: return "/user/account"
        case .getUsers: return "/users"
        case .getUserById(let id): return "/users/\(id)"
        case .createUser: return "/users"
        case .uploadFile: return "/files/upload"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .login(let phone, let password):
            return ["phone": phone, "password": password]
        case .register(let name, let email, let phone, let password):
            return [
                "name": name,
                "email": email,
                "phone": phone,
                "password": password,
                "password_confirmation": password
            ]
        case .forgotPassword(let email):
            return ["email": email]
        case .updateProfile(let name, let email):
            return ["name": name, "email": email]
        case .deleteAccount(let password):
            return ["password": password]
        case .getUsers(let page, let size):
            return ["page": page, "size": size]
        case .createUser(let name, let email):
            return ["name": name, "email": email]
        default:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .uploadFile:
            // Custom header for file upload
            return ["Content-Type": "multipart/form-data"]
        default:
            return nil
        }
    }
}
```

### Example 1: Simple GET Request
```swift
// Get user profile
NetworkManager.shared.request(MyAPIRouter.getUserProfile) { 
    (result: Result<APIResponseNone<UserModel>, NetworkError>) in
    switch result {
    case .success(let response):
        if let user = response.data {
            print("User: \(user.name)")
            print("Email: \(user.email)")
        }
        if let message = response.message {
            print("Server message: \(message)")
        }
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### Example 2: POST Request with Parameters
```swift
// Login request
NetworkManager.shared.request(
    MyAPIRouter.login(phone: "01234567890", password: "pass123")
) { (result: Result<APIResponseNone<LoginResponse>, NetworkError>) in
    switch result {
    case .success(let response):
        if let loginData = response.data {
            // Save token
            UserDefaultsManager.shared.token = loginData.token
            UserDefaultsManager.shared.isLoggedIn = true
            
            // Navigate to home
            print("Login successful!")
        }
    case .failure(let error):
        switch error {
        case .noInternetConnection:
            ToatsVC.show(message: "No internet connection", type: .error)
        case .serverError(let code, let message):
            if code == 401 {
                showInfoPopup(
                    title: "Login Failed",
                    message: message ?? "Invalid credentials",
                    style: .error
                )
            }
        default:
            print("Error: \(error.localizedDescription)")
        }
    }
}
```

### Example 3: Paginated Request
```swift
// Get users with pagination
NetworkManager.shared.request(
    MyAPIRouter.getUsers(page: 1, size: 20)
) { (result: Result<APIResponseNone<[UserModel]>, NetworkError>) in
    switch result {
    case .success(let response):
        if let users = response.data {
            print("Loaded \(users.count) users")
            
            // Check pagination metadata
            if let meta = response.meta {
                print("Total users: \(meta.total ?? 0)")
                print("Current page: \(meta.currentPage ?? 1)")
                print("Last page: \(meta.lastPage ?? 1)")
                
                // Load next page if available
                if let currentPage = meta.currentPage,
                   let lastPage = meta.lastPage,
                   currentPage < lastPage {
                    // Load page \(currentPage + 1)
                }
            }
        }
    case .failure(let error):
        print("Error loading users: \(error.localizedDescription)")
    }
}
```

### Example 4: PUT Request (Update)
```swift
// Update user profile
NetworkManager.shared.request(
    MyAPIRouter.updateProfile(name: "New Name", email: "new@email.com")
) { (result: Result<APIResponseNone<UserModel>, NetworkError>) in
    switch result {
    case .success(let response):
        if let updatedUser = response.data {
            showInfoPopup(
                title: "Success",
                message: response.message ?? "Profile updated successfully",
                style: .success
            )
        }
    case .failure(let error):
        showInfoPopup(
            title: "Error",
            message: error.localizedDescription,
            style: .error
        )
    }
}
```

### Example 5: DELETE Request
```swift
// Delete account with confirmation
showConfirmationPopup(
    title: "Delete Account?",
    message: "This action cannot be undone",
    confirmTitle: "Delete",
    cancelTitle: "Cancel",
    style: .destructive,
    onConfirm: {
        NetworkManager.shared.request(
            MyAPIRouter.deleteAccount(password: "userPassword")
        ) { (result: Result<APIResponseNone<EmptyModel>, NetworkError>) in
            switch result {
            case .success:
                // Clear user data
                UserDefaultsManager.shared.isLoggedIn = false
                UserDefaultsManager.shared.token = nil
                
                // Navigate to login
                showInfoPopup(
                    title: "Account Deleted",
                    message: "Your account has been deleted successfully",
                    style: .info
                )
            case .failure(let error):
                showInfoPopup(
                    title: "Error",
                    message: error.localizedDescription,
                    style: .error
                )
            }
        }
    },
    onCancel: nil
)
```

### Example 6: Request with Custom Response Type
```swift
// Using APIResponse (with StatusModel in additionalData)
NetworkManager.shared.request(MyAPIRouter.someEndpoint) { 
    (result: Result<APIResponse<SomeModel>, NetworkError>) in
    switch result {
    case .success(let response):
        if let data = response.data {
            // Main data
            print("Data: \(data)")
        }
        if let additionalData = response.additionalData {
            // StatusModel or custom type
            print("Additional data: \(additionalData)")
        }
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### Example 7: Comprehensive Error Handling
```swift
func makeRequest() {
    NetworkManager.shared.request(MyAPIRouter.getUserProfile) { 
        (result: Result<APIResponseNone<UserModel>, NetworkError>) in
        switch result {
        case .success(let response):
            handleSuccess(response: response)
        case .failure(let error):
            handleError(error: error)
        }
    }
}

func handleSuccess(response: APIResponseNone<UserModel>) {
    guard let user = response.data else {
        showInfoPopup(
            title: "Error",
            message: "No user data received",
            style: .error
        )
        return
    }
    
    // Process user data
    print("User loaded: \(user.name)")
}

func handleError(error: NetworkError) {
    switch error {
    case .noInternetConnection:
        ToatsVC.show(
            message: "No internet connection",
            type: .error,
            buttonTitle: "Retry",
            onButtonTap: { self.makeRequest() }
        )
        
    case .invalidBaseURL:
        showInfoPopup(
            title: "Configuration Error",
            message: "Please configure the base URL",
            style: .error
        )
        
    case .decodingError(let decodingError):
        #if DEBUG
        print("Decoding error: \(decodingError)")
        #endif
        showInfoPopup(
            title: "Data Error",
            message: "Failed to parse server response",
            style: .error
        )
        
    case .serverError(let code, let message):
        switch code {
        case 401:
            // Unauthorized - logout user
            UserDefaultsManager.shared.isLoggedIn = false
            UserDefaultsManager.shared.token = nil
            showInfoPopup(
                title: "Session Expired",
                message: "Please login again",
                style: .warning
            )
            
        case 403:
            showInfoPopup(
                title: "Access Denied",
                message: "You don't have permission",
                style: .error
            )
            
        case 404:
            showInfoPopup(
                title: "Not Found",
                message: message ?? "Resource not found",
                style: .error
            )
            
        case 500...599:
            showInfoPopup(
                title: "Server Error",
                message: "Please try again later",
                style: .error
            )
            
        default:
            showInfoPopup(
                title: "Error",
                message: message ?? "An error occurred",
                style: .error
            )
        }
        
    case .unknown(let error):
        #if DEBUG
        print("Unknown error: \(error)")
        #endif
        showInfoPopup(
            title: "Error",
            message: error.localizedDescription,
            style: .error
        )
    }
}
```

### Example 8: Using Connectivity Check Before Request
```swift
func loadData() {
    // Check connectivity first
    guard Connectivity.isConnectedToInternet() else {
        ToatsVC.show(
            message: "No internet connection",
            type: .error,
            buttonTitle: "Settings",
            onButtonTap: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        )
        return
    }
    
    // Make request
    NetworkManager.shared.request(MyAPIRouter.getUserProfile) { result in
        // Handle result...
    }
}
```

### Response Models

The library provides generic response wrappers that match your backend structure:

#### Basic Response Structure
```swift
// Your backend returns:
{
    "status_code": 200,
    "message": "Success",
    "data": { /* your model */ },
    "meta": { /* pagination */ },
    "additional_data": { /* optional */ }
}
```

#### Using Response Types
```swift
// 1. APIResponseNone<T> - When additional_data is empty or not needed
struct UserModel: Codable {
    let id: Int
    let name: String
    let email: String
}

NetworkManager.shared.request(MyAPIRouter.getUserProfile) { 
    (result: Result<APIResponseNone<UserModel>, NetworkError>) in
    // response.data is UserModel?
    // response.additionalData is nil
}

// 2. APIResponse<T> - When additional_data contains StatusModel
NetworkManager.shared.request(MyAPIRouter.someEndpoint) { 
    (result: Result<APIResponse<SomeModel>, NetworkError>) in
    // response.data is SomeModel?
    // response.additionalData is StatusModel?
}

// 3. DataModel<T, A> - Custom additional_data type
struct CustomStatus: Codable {
    let code: Int
    let details: String
}

NetworkManager.shared.request(MyAPIRouter.customEndpoint) { 
    (result: Result<DataModel<UserModel, CustomStatus>, NetworkError>) in
    // response.data is UserModel?
    // response.additionalData is CustomStatus?
}
```

#### Pagination Example
```swift
struct ProductModel: Codable {
    let id: Int
    let name: String
    let price: Double
}

NetworkManager.shared.request(
    MyAPIRouter.getProducts(page: 1, size: 20)
) { (result: Result<APIResponseNone<[ProductModel]>, NetworkError>) in
    switch result {
    case .success(let response):
        let products = response.data ?? []
        let meta = response.meta
        
        print("Products: \(products.count)")
        print("Total: \(meta?.total ?? 0)")
        print("Page \(meta?.currentPage ?? 1) of \(meta?.lastPage ?? 1)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### Error Handling

`NetworkError` enum provides comprehensive error types:

#### Error Types
```swift
public enum NetworkError: LocalizedError {
    case invalidBaseURL              // Base URL not configured
    case noInternetConnection        // No connectivity
    case decodingError(Error)       // JSON decoding failed
    case serverError(Int, String?)  // HTTP error with status code
    case unknown(Error)             // Other errors
}
```

#### Error Handling Patterns
```swift
// Pattern 1: Simple error handling
NetworkManager.shared.request(router) { result in
    if case .failure(let error) = result {
        print("Error: \(error.localizedDescription)")
    }
}

// Pattern 2: Detailed error handling
NetworkManager.shared.request(router) { result in
    switch result {
    case .success(let response):
        // Handle success
        break
    case .failure(let error):
        switch error {
        case .noInternetConnection:
            // Show offline message
            break
        case .serverError(let code, let message):
            // Handle specific HTTP codes
            break
        case .decodingError(let error):
            // Handle parsing errors
            break
        default:
            // Handle other errors
            break
        }
    }
}

// Pattern 3: Error handling with user feedback
func handleNetworkError(_ error: NetworkError) {
    switch error {
    case .noInternetConnection:
        ToatsVC.show(
            message: "No internet connection",
            type: .error,
            duration: 3.0
        )
        
    case .serverError(let code, let message):
        let title: String
        let style: InfoPopupStyle
        
        switch code {
        case 400:
            title = "Bad Request"
            style = .warning
        case 401:
            title = "Unauthorized"
            style = .error
            // Logout user
            UserDefaultsManager.shared.isLoggedIn = false
        case 403:
            title = "Forbidden"
            style = .error
        case 404:
            title = "Not Found"
            style = .info
        case 500...599:
            title = "Server Error"
            style = .error
        default:
            title = "Error"
            style = .error
        }
        
        showInfoPopup(
            title: title,
            message: message ?? "An error occurred",
            style: style
        )
        
    case .decodingError(let error):
        #if DEBUG
        print("Decoding error: \(error)")
        #endif
        showInfoPopup(
            title: "Data Error",
            message: "Failed to parse response",
            style: .error
        )
        
    case .invalidBaseURL:
        showInfoPopup(
            title: "Configuration Error",
            message: "Please configure the base URL",
            style: .error
        )
        
    case .unknown(let error):
        showInfoPopup(
            title: "Error",
            message: error.localizedDescription,
            style: .error
        )
    }
}
```

### Best Practices

#### 1. Centralized API Manager
```swift
// Create a centralized API manager in your project
class APIManager {
    static func login(phone: String, password: String, completion: @escaping (Result<APIResponseNone<UserModel>, NetworkError>) -> Void) {
        let router = MyAPIRouter.login(phone: phone, password: password)
        NetworkManager.shared.request(router, completion: completion)
    }
    
    static func getUserProfile(completion: @escaping (Result<APIResponseNone<UserModel>, NetworkError>) -> Void) {
        NetworkManager.shared.request(MyAPIRouter.getUserProfile, completion: completion)
    }
    
    // Add more methods...
}

// Usage in ViewController
APIManager.login(phone: "01234567890", password: "pass123") { result in
    // Handle result
}
```

#### 2. Request with Loading Indicator
```swift
func loadUserProfile() {
    // Show loading
    view.showActivityIndicator()
    
    NetworkManager.shared.request(MyAPIRouter.getUserProfile) { [weak self] result in
        // Hide loading
        self?.view.hideActivityIndicator()
        
        switch result {
        case .success(let response):
            if let user = response.data {
                // Update UI
                self?.updateUI(with: user)
            }
        case .failure(let error):
            self?.handleError(error)
        }
    }
}
```

#### 3. Retry Logic
```swift
func loadDataWithRetry(maxRetries: Int = 3, currentRetry: Int = 0) {
    NetworkManager.shared.request(MyAPIRouter.getData) { [weak self] result in
        switch result {
        case .success(let response):
            // Handle success
            break
        case .failure(let error):
            if currentRetry < maxRetries,
               case .serverError(let code, _) = error,
               code >= 500 {
                // Retry on server errors
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self?.loadDataWithRetry(maxRetries: maxRetries, currentRetry: currentRetry + 1)
                }
            } else {
                // Handle other errors
                self?.handleError(error)
            }
        }
    }
}
```

#### 4. Request Cancellation
```swift
class ViewController: UIViewController {
    private var currentRequest: DataRequest?
    
    func loadData() {
        // Cancel previous request if exists
        currentRequest?.cancel()
        
        // Store new request
        currentRequest = AF.request(MyAPIRouter.getData)
        currentRequest?.responseData { [weak self] response in
            // Handle response
            self?.currentRequest = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Cancel request when leaving screen
        currentRequest?.cancel()
    }
}
```

#### 5. Environment-Based Configuration
```swift
// In AppDelegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    #if DEBUG
    NetworkManager.shared.configure(
        baseURL: "https://api-dev.example.com/v1",
        debugEnabled: true,
        debugBaseURL: "https://api-dev.example.com"
    )
    #else
    NetworkManager.shared.configure(
        baseURL: "https://api.example.com/v1",
        debugEnabled: false
    )
    #endif
    
    return true
}
```

## Usage Notes
- All UI classes are wrapped in `#if canImport(UIKit)`; the module targets iOS.
- Some constants are sample defaults (e.g., `KeychainManager.service = "restart.breakfast.app"` and header values); change to fit your app.
- `EncryptionManager` generates an in-memory key; if you need persistence, store your own key securely.
- Most views expose @IBInspectable knobs, so you can style them directly from Interface Builder.
- **Network Layer**: Configure `NetworkManager.shared.baseURL` before making any requests. The library automatically injects authorization tokens from `UserDefaultsManager.shared.token` and language headers from `LanguageManager`.
- **Error Handling**: Always check for `.noInternetConnection` first, then handle specific HTTP status codes (401, 403, 500, etc.) appropriately.
- **Debugging**: Enable `debugEnabled` in development to see request/response logs. Use `debugBaseURL` to filter logs to specific domains.

## Tests
No bundled tests yet—consider adding unit tests for pieces you use (e.g., Validator, LanguageManager).

## License
No license file found; confirm with the owner before commercial use.
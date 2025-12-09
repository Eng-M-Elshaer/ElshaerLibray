//
//  BaseViewController.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation
#if canImport(UIKit)
import UIKit

/// Enum to identify different view types for showing/hiding
public enum ShowViewType {
    case table
    case scroll
}

/// Base view controller with common functionality for navigation, popups, and UI helpers
@MainActor
open class BaseViewController: UIViewController {
    
    // MARK: - Properties
    /// Refresh control for pull-to-refresh functionality
    public let refreshControl = UIRefreshControl()
    
    /// Whether to hide navigation bar when view appears (default: true)
    public var shouldHideNavigationBar: Bool = true
    
    // MARK: - Lifecycle Methods
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldHideNavigationBar {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if shouldHideNavigationBar {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    // MARK: - Popup Methods
    
    /// Shows an error popup with title and message
    /// - Parameters:
    ///   - title: Title text
    ///   - message: Error message
    ///   - buttonText: Button title (default: "OK")
    public func showErrorPopup(title: String, message: String, buttonText: String = "OK") {
        showInfoPopup(
            title: title,
            message: message,
            buttonTitle: buttonText,
            style: .error
        )
    }
    
    /// Shows a success popup with title and message
    /// - Parameters:
    ///   - title: Title text
    ///   - message: Success message
    ///   - buttonText: Button title (default: "OK")
    ///   - completion: Optional completion handler
    public func showSuccessPopup(
        title: String,
        message: String,
        buttonText: String = "OK",
        completion: (() -> Void)? = nil
    ) {
        showInfoPopup(
            title: title,
            message: message,
            buttonTitle: buttonText,
            style: .success,
            onAction: completion
        )
    }
    
    /// Shows an info popup with custom style
    /// - Parameters:
    ///   - style: Popup style (info, success, warning, error)
    ///   - title: Title text
    ///   - message: Message text
    ///   - buttonText: Button title (default: "OK")
    ///   - completion: Optional completion handler
    public func showPopup(
        style: InfoPopupStyle,
        title: String,
        message: String,
        buttonText: String = "OK",
        completion: (() -> Void)? = nil
    ) {
        showInfoPopup(
            title: title,
            message: message,
            buttonTitle: buttonText,
            style: style,
            onAction: completion
        )
    }
    
    /// Shows a checker popup (similar to CheckerVC)
    /// - Parameters:
    ///   - image: Image to display
    ///   - title: Title text
    ///   - message: Message text
    ///   - buttonTitle: Optional button title (nil hides button)
    ///   - style: Checker style
    ///   - completion: Optional completion handler
    public func showChecker(
        image: UIImage?,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        style: CheckerStyle = .info,
        completion: (() -> Void)? = nil
    ) {
        showChecker(
            image: image,
            title: title,
            message: message,
            buttonTitle: buttonTitle,
            style: style,
            isBackgroundTapDismissEnabled: true,
            onButtonTap: completion,
            onDismiss: nil
        )
    }
    
    /// Shows an unauthenticated popup (session expired)
    /// - Parameters:
    ///   - title: Title text (default: "Session Expired")
    ///   - message: Message text (default: "Please login again")
    ///   - buttonText: Button title (default: "Login Again")
    ///   - onLogin: Handler called when login button is tapped
    public func showUnauthenticatedPopup(
        title: String = "Session Expired",
        message: String = "Please login again",
        buttonText: String = "Login Again",
        onLogin: (() -> Void)? = nil
    ) {
        showInfoPopup(
            title: title,
            message: message,
            buttonTitle: buttonText,
            style: .error,
            onAction: onLogin
        )
    }
    
    /// Shows an update alert (forces user to update app)
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    ///   - updateButtonText: Update button text
    ///   - appStoreURL: App Store URL for the app
    public func showUpdateAlert(
        title: String = "Update Required",
        message: String = "A new version of the app is required. Please update to continue.",
        updateButtonText: String = "Update",
        appStoreURL: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: updateButtonText, style: .default) { _ in
            if let url = URL(string: appStoreURL) {
                UIApplication.shared.open(url)
            }
        })
        
        presentSafely(alert, animated: true)
    }
    
    /// Shows info sheet with HTML content
    /// - Parameters:
    ///   - htmlString: HTML string to display
    ///   - title: Optional navigation title
    public func showInfoSheet(htmlString: String, title: String? = nil) {
        let vc = TextVC(htmlString: htmlString)
        
        if let title = title {
            vc.title = title
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        vc.modalPresentationStyle = .pageSheet
        presentSafely(vc, animated: true)
    }
    
    // MARK: - Navigation Methods
    
    /// Pops the current view controller from navigation stack
    public func goToBackScreen() {
        navigationController?.popViewController(animated: true)
    }
    
    /// Logs out the user (clears token and login state)
    /// Override this method to add custom logout logic
    /// - Parameter completion: Optional completion handler
    open func logOutAction(completion: (() -> Void)? = nil) {
        UserDefaultsManager.shared.isLoggedIn = false
        UserDefaultsManager.shared.token = nil
        
        // Call completion if provided
        completion?()
    }
    
    // MARK: - UI Helper Methods
    
    /// Shows or hides hint label and updates stack view border
    /// - Parameters:
    ///   - label: Hint label to show/hide
    ///   - stackView: Stack view to update border
    ///   - show: Whether to show the hint
    ///   - errorColor: Color for error state
    ///   - normalColor: Color for normal state
    public func handleHint(
        for label: UILabel,
        stackView: UIStackView,
        show: Bool,
        errorColor: UIColor = .systemRed,
        normalColor: UIColor = .systemBlue
    ) {
        label.isHidden = !show
        stackView.layer.borderColor = show ? errorColor.cgColor : normalColor.cgColor
        stackView.layer.borderWidth = 1
    }
    
    /// Shows main loader (activity indicator) on the view
    public func showMainLoader() {
        view.showActivityIndicator()
    }
    
    /// Hides main loader (activity indicator) from the view
    public func hideMainLoader() {
        view.hideActivityIndicator()
    }
    
    /// Shows the specified view type (table or scroll)
    /// - Parameter type: View type to show
    public func showView(for type: ShowViewType) {
        removeLayerAtZPosition(view: view)
        removeCenterImage()
        
        switch type {
        case .table:
            handleViewWithTag(view: view, isHidden: false, tag: ViewConstants.tableViewTag)
        case .scroll:
            handleViewWithTag(view: view, isHidden: false, tag: ViewConstants.scrollViewTag)
        }
    }
    
    /// Sets a center image with label text
    /// - Parameters:
    ///   - imageName: Name of the image asset
    ///   - labelText: Text to display below image
    public func setCenterImage(named imageName: String, labelText: String) {
        guard let image = UIImage(named: imageName) else { return }
        setCenterImage(image: image, labelText: labelText)
    }
    
    /// Sets a center image with label text
    /// - Parameters:
    ///   - image: UIImage to display
    ///   - labelText: Text to display below image
    public func setCenterImage(image: UIImage, labelText: String) {
        guard let view = self.view else { return }
        
        // Remove existing center image if any
        removeCenterImage()
        
        let imageView = UIImageView(image: image)
        imageView.tag = ViewConstants.centerImageViewTag
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let label = UILabel()
        label.text = labelText
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.tag = ViewConstants.centerImageLabelTag
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    /// Removes center image and label from view
    public func removeCenterImage() {
        view.viewWithTag(ViewConstants.centerImageViewTag)?.removeFromSuperview()
        view.viewWithTag(ViewConstants.centerImageLabelTag)?.removeFromSuperview()
    }
}

#endif


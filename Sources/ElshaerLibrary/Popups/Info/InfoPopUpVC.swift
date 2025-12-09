//
//  InfoPopUpVC.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation
#if canImport(UIKit)
import UIKit

/// Visual style for the info popup, used to tint the icon and button.
public enum InfoPopupStyle {
    case info
    case success
    case warning
    case error
}

// MARK: - InfoPopUpVC
/// A reusable popup that displays an optional image, title, message and a single action button.
///
/// Presented modally over the current context with a dimmed background.
@MainActor
public final class InfoPopUpVC: UIViewController {
    
    // MARK: - UI
    private let dimmingView = UIView()
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = CustomButton(type: .system)
    
    // MARK: - Configuration
    private let image: UIImage?
    private let titleText: String
    private let messageText: String
    private let buttonTitle: String
    private let style: InfoPopupStyle
    private let isBackgroundTapDismissEnabled: Bool
    private let onAction: (() -> Void)?
    private let onDismiss: (() -> Void)?
    
    // MARK: - Init
    /// Creates a new info popup.
    /// - Parameters:
    ///   - image: Optional image shown at the top of the card.
    ///   - title: Title text displayed below the image.
    ///   - message: Message body displayed under the title.
    ///   - buttonTitle: Title of the action button.
    ///   - style: Visual style (info / success / warning / error) used to tint the UI.
    ///   - isBackgroundTapDismissEnabled: If `true`, tapping outside the card will dismiss the popup.
    ///   - onAction: Called when the action button is tapped.
    ///   - onDismiss: Called when the popup is dismissed without tapping the action button.
    public init(image: UIImage? = nil,
                title: String,
                message: String,
                buttonTitle: String = "OK",
                style: InfoPopupStyle = .info,
                isBackgroundTapDismissEnabled: Bool = true,
                onAction: (() -> Void)? = nil,
                onDismiss: (() -> Void)? = nil) {
        self.image = image
        self.titleText = title
        self.messageText = message
        self.buttonTitle = buttonTitle
        self.style = style
        self.isBackgroundTapDismissEnabled = isBackgroundTapDismissEnabled
        self.onAction = onAction
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    @available(*, unavailable, message: "Use init(image:title:message:buttonTitle:style:isBackgroundTapDismissEnabled:onAction:onDismiss:) instead.")
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyContent()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear
        
        // Dimming background
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(dimmingView)
        
        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if isBackgroundTapDismissEnabled {
            let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
            dimmingView.addGestureRecognizer(tap)
        }
        
        // Container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 14
        containerView.layer.masksToBounds = true
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
        
        // StackView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        // Image view
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 120).isActive = true
        
        // Title label
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        // Message label
        messageLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        // Action button
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        actionButton.layer.cornerRadius = 8
        actionButton.layer.masksToBounds = true
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        
        // Build hierarchy
        if image != nil {
            stackView.addArrangedSubview(imageView)
        }
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(actionButton)
    }
    
    private func applyContent() {
        imageView.image = image
        titleLabel.text = titleText
        messageLabel.text = messageText
        actionButton.setTitle(buttonTitle, for: .normal)
        
        // Style tint
        let tintColor: UIColor
        switch style {
        case .info:
            tintColor = .systemBlue
        case .success:
            tintColor = .systemGreen
        case .warning:
            tintColor = .systemOrange
        case .error:
            tintColor = .systemRed
        }
        
        imageView.tintColor = tintColor
        actionButton.backgroundColor = tintColor
    }
    
    // MARK: - Actions
    @objc private func backgroundTapped() {
        dismiss(animated: true) { [onDismiss] in
            onDismiss?()
        }
    }
    
    @objc private func actionTapped() {
        dismiss(animated: true) { [onAction] in
            onAction?()
        }
    }
}

// MARK: - UIViewController helper
@MainActor
public extension UIViewController {
    
    /// Presents an info popup from the current view controller.
    /// - Parameters:
    ///   - image: Optional image shown at the top of the card.
    ///   - title: Title text displayed below the image.
    ///   - message: Message body displayed under the title.
    ///   - buttonTitle: Title of the action button.
    ///   - style: Visual style (info / success / warning / error) used to tint the UI.
    ///   - isBackgroundTapDismissEnabled: If `true`, tapping outside the card will dismiss the popup.
    ///   - onAction: Called when the action button is tapped.
    ///   - onDismiss: Called when the popup is dismissed without tapping the action button.
    func showInfoPopup(image: UIImage? = nil,
                       title: String,
                       message: String,
                       buttonTitle: String = "OK",
                       style: InfoPopupStyle = .info,
                       isBackgroundTapDismissEnabled: Bool = true,
                       onAction: (() -> Void)? = nil,
                       onDismiss: (() -> Void)? = nil) {
        let vc = InfoPopUpVC(image: image,
                             title: title,
                             message: message,
                             buttonTitle: buttonTitle,
                             style: style,
                             isBackgroundTapDismissEnabled: isBackgroundTapDismissEnabled,
                             onAction: onAction,
                             onDismiss: onDismiss)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    /// Dismisses a presented `InfoPopUpVC` if it exists.
    func hideInfoPopup(completion: (() -> Void)? = nil) {
        if let popup = presentedViewController as? InfoPopUpVC {
            popup.dismiss(animated: true) {
                completion?()
            }
        } else {
            completion?()
        }
    }
}

#endif

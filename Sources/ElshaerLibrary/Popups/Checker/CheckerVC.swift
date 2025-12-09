//
//  CheckerVC.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation
#if canImport(UIKit)
import UIKit

/// Visual style for the checker view, used to adjust colors.
public enum CheckerStyle {
    case info
    case success
    case warning
    case error
}

// MARK: - CheckerVC
/// A reusable overlay that displays an image, title, message and an optional action button.
///
/// Presented modally over the current context with a dimmed background.
@MainActor
public final class CheckerVC: UIViewController {
    
    // MARK: - UI
    private let dimmingView = UIView()
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let button = CustomButton(type: .system)
    
    // MARK: - Configuration
    private let image: UIImage?
    private let titleText: String
    private let messageText: String
    private let buttonTitle: String?
    private let style: CheckerStyle
    private let isBackgroundTapDismissEnabled: Bool
    private let onButtonTap: (() -> Void)?
    private let onDismiss: (() -> Void)?
    
    // MARK: - Init
    /// Creates a new checker overlay.
    /// - Parameters:
    ///   - image: Optional image shown at the top of the card.
    ///   - title: Title text displayed below the image.
    ///   - message: Message body displayed under the title.
    ///   - buttonTitle: Optional title for the action button. If `nil`, the button is hidden.
    ///   - style: Visual style (info / success / warning / error) used to tint the UI.
    ///   - isBackgroundTapDismissEnabled: If `true`, tapping outside the card will dismiss the overlay.
    ///   - onButtonTap: Called when the action button is tapped.
    ///   - onDismiss: Called when the overlay is dismissed without tapping the action button.
    public init(image: UIImage?,
                title: String,
                message: String,
                buttonTitle: String? = nil,
                style: CheckerStyle = .info,
                isBackgroundTapDismissEnabled: Bool = true,
                onButtonTap: (() -> Void)? = nil,
                onDismiss: (() -> Void)? = nil) {
        self.image = image
        self.titleText = title
        self.messageText = message
        self.buttonTitle = buttonTitle
        self.style = style
        self.isBackgroundTapDismissEnabled = isBackgroundTapDismissEnabled
        self.onButtonTap = onButtonTap
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    @available(*, unavailable, message: "Use init(image:title:message:buttonTitle:style:isBackgroundTapDismissEnabled:onButtonTap:onDismiss:) instead.")
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
        
        // Button
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Build hierarchy
        if image != nil {
            stackView.addArrangedSubview(imageView)
        }
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        
        if buttonTitle != nil {
            stackView.addArrangedSubview(button)
        }
    }
    
    private func applyContent() {
        imageView.image = image
        titleLabel.text = titleText
        messageLabel.text = messageText
        button.setTitle(buttonTitle, for: .normal)
        
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
        button.backgroundColor = tintColor
    }
    
    // MARK: - Actions
    @objc private func backgroundTapped() {
        dismiss(animated: true) { [onDismiss] in
            onDismiss?()
        }
    }
    
    @objc private func buttonTapped() {
        dismiss(animated: true) { [onButtonTap] in
            onButtonTap?()
        }
    }
}

// MARK: - UIViewController helper
@MainActor
public extension UIViewController {
    
    /// Presents a `CheckerVC` overlay from the current view controller.
    /// - Parameters:
    ///   - image: Optional image shown at the top of the card.
    ///   - title: Title text displayed below the image.
    ///   - message: Message body displayed under the title.
    ///   - buttonTitle: Optional title for the action button. If `nil`, the button is hidden.
    ///   - style: Visual style (info / success / warning / error) used to tint the UI.
    ///   - isBackgroundTapDismissEnabled: If `true`, tapping outside the card will dismiss the overlay.
    ///   - onButtonTap: Called when the action button is tapped.
    ///   - onDismiss: Called when the overlay is dismissed without tapping the action button.
    func showChecker(image: UIImage?,
                     title: String,
                     message: String,
                     buttonTitle: String? = nil,
                     style: CheckerStyle = .info,
                     isBackgroundTapDismissEnabled: Bool = true,
                     onButtonTap: (() -> Void)? = nil,
                     onDismiss: (() -> Void)? = nil) {
        let vc = CheckerVC(image: image,
                           title: title,
                           message: message,
                           buttonTitle: buttonTitle,
                           style: style,
                           isBackgroundTapDismissEnabled: isBackgroundTapDismissEnabled,
                           onButtonTap: onButtonTap,
                           onDismiss: onDismiss)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    /// Dismisses a presented `CheckerVC` if it exists.
    func hideCheckerView(completion: (() -> Void)? = nil) {
        if let checker = presentedViewController as? CheckerVC {
            checker.dismiss(animated: true) {
                completion?()
            }
        } else {
            completion?()
        }
    }
}

#endif

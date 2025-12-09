//
//  ConfrimationVC.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation
#if canImport(UIKit)
import UIKit

/// Visual style for the confirmation action.
public enum ConfirmationStyle {
    /// Standard primary action (e.g. blue button).
    case normal
    /// Destructive action (e.g. red button).
    case destructive
}

// MARK: - ConfrimationVC
/// A reusable confirmation popup view controller (title + message + two buttons).
///
/// The view controller is presented modally over the current context with a dimmed background
/// and a centered container view.
@MainActor
public final class ConfrimationVC: UIViewController {
    
    // MARK: - UI
    private let dimmingView = UIView()
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonsStackView = UIStackView()
    private let cancelButton = UIButton(type: .system)
    private let confirmButton = CustomButton(type: .system)
    
    // MARK: - Data
    private let titleText: String
    private let messageText: String
    private let confirmTitle: String
    private let cancelTitle: String
    private let style: ConfirmationStyle
    private let onConfirm: (() -> Void)?
    private let onCancel: (() -> Void)?
    
    // MARK: - Init
    /// Creates a new confirmation popup.
    /// - Parameters:
    ///   - title: Title text displayed at the top.
    ///   - message: Message body shown under the title.
    ///   - confirmTitle: Title of the primary (confirm) button.
    ///   - cancelTitle: Title of the secondary (cancel) button.
    ///   - style: Visual style for the confirm button (normal / destructive).
    ///   - onConfirm: Called when the confirm button is tapped.
    ///   - onCancel: Called when the cancel button is tapped or the popup is dismissed.
    public init(title: String,
                message: String,
                confirmTitle: String = "Yes",
                cancelTitle: String = "No",
                style: ConfirmationStyle = .normal,
                onConfirm: (() -> Void)?,
                onCancel: (() -> Void)? = nil) {
        self.titleText = title
        self.messageText = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.style = style
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    @available(*, unavailable, message: "Use init(title:message:confirmTitle:cancelTitle:style:onConfirm:onCancel:) instead.")
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
        
        // Dimming view
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(dimmingView)
        
        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
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
        
        // StackView (vertical)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        // Title label
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        // Message label
        messageLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        // Buttons stack
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 8
        buttonsStackView.alignment = .fill
        buttonsStackView.distribution = .fillEqually
        
        // Cancel button
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemGray4.cgColor
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        // Confirm button
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        confirmButton.layer.cornerRadius = 8
        confirmButton.layer.masksToBounds = true
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        
        // Add arranged subviews
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        stackView.addArrangedSubview(spacer)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(confirmButton)
        stackView.addArrangedSubview(buttonsStackView)
    }
    
    private func applyContent() {
        titleLabel.text = titleText
        messageLabel.text = messageText
        
        cancelButton.setTitle(cancelTitle, for: .normal)
        confirmButton.setTitle(confirmTitle, for: .normal)
        
        switch style {
        case .normal:
            confirmButton.backgroundColor = .systemBlue
        case .destructive:
            confirmButton.backgroundColor = .systemRed
        }
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true) { [onCancel] in
            onCancel?()
        }
    }
    
    @objc private func confirmTapped() {
        dismiss(animated: true) { [onConfirm] in
            onConfirm?()
        }
    }
}

// MARK: - UIViewController helper
@MainActor
public extension UIViewController {
    
    /// Convenience helper to present a `ConfrimationVC` from any view controller.
    /// - Parameters:
    ///   - title: Title text displayed at the top.
    ///   - message: Message body shown under the title.
    ///   - confirmTitle: Title of the primary (confirm) button.
    ///   - cancelTitle: Title of the secondary (cancel) button.
    ///   - style: Visual style for the confirm button (normal / destructive).
    ///   - onConfirm: Called when the confirm button is tapped.
    ///   - onCancel: Called when the cancel button is tapped or the popup is dismissed.
    func showConfirmationPopup(title: String,
                               message: String,
                               confirmTitle: String = "Yes",
                               cancelTitle: String = "No",
                               style: ConfirmationStyle = .normal,
                               onConfirm: (() -> Void)?,
                               onCancel: (() -> Void)? = nil) {
        let vc = ConfrimationVC(title: title,
                                message: message,
                                confirmTitle: confirmTitle,
                                cancelTitle: cancelTitle,
                                style: style,
                                onConfirm: onConfirm,
                                onCancel: onCancel)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        presentSafely(vc, animated: true)
    }
}

#endif

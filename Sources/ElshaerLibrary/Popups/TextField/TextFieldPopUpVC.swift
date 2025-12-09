
//
//  TextFieldPopUpVC.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation
#if canImport(UIKit)
import UIKit

// MARK: - TextFieldPopUpVC
/// A reusable popup that presents a title, a single text field and two buttons (confirm / cancel).
///
/// The confirm button is enabled only when the input length meets the configured minimum.
@MainActor
public final class TextFieldPopUpVC: UIViewController {
    
    // MARK: - UI
    private let dimmingView = UIView()
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let hintLabel = UILabel()
    private let buttonsStackView = UIStackView()
    private let cancelButton = UIButton(type: .system)
    private let confirmButton = CustomButton(type: .system)
    
    // MARK: - Configuration
    private let titleText: String
    private let placeholderText: String
    private let yesText: String
    private let noText: String
    private let minLength: Int
    private let onConfirm: ((String?) -> Void)?
    private let onCancel: (() -> Void)?
    
    // MARK: - Init
    /// Creates a new text field popup.
    /// - Parameters:
    ///   - titleText: Title text displayed at the top.
    ///   - placeholderText: Placeholder for the text field.
    ///   - yesText: Title of the primary (confirm) button.
    ///   - noText: Title of the secondary (cancel) button.
    ///   - minLength: Minimum required length for the input to enable the confirm button.
    ///   - onConfirm: Called with the entered text when the confirm button is tapped.
    ///   - onCancel: Called when the cancel button is tapped or the popup is dismissed.
    public init(titleText: String,
                placeholderText: String = "",
                yesText: String = "OK",
                noText: String = "Cancel",
                minLength: Int = 8,
                onConfirm: ((String?) -> Void)?,
                onCancel: (() -> Void)? = nil) {
        self.titleText = titleText
        self.placeholderText = placeholderText
        self.yesText = yesText
        self.noText = noText
        self.minLength = minLength
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    @available(*, unavailable, message: "Use init(titleText:placeholderText:yesText:noText:minLength:onConfirm:onCancel:) instead.")
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        textField.removeTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
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
        
        // Text field
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        
        // Hint label
        hintLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        hintLabel.textColor = .systemRed
        hintLabel.textAlignment = .left
        hintLabel.numberOfLines = 0
        hintLabel.isHidden = true
        
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
        confirmButton.backgroundColor = .systemBlue
        confirmButton.isEnabled = false
        confirmButton.alpha = 0.5
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        
        // Build hierarchy
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(hintLabel)
        
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
        textField.placeholder = placeholderText
        cancelButton.setTitle(noText, for: .normal)
        confirmButton.setTitle(yesText, for: .normal)
        
        // Default hint text can be customized by the caller later if needed.
        hintLabel.text = "Minimum \(minLength) characters required."
    }
    
    // MARK: - Actions
    @objc private func textDidChange(_ textField: UITextField) {
        let length = textField.text?.count ?? 0
        let isValid = length >= minLength
        
        hintLabel.isHidden = isValid
        confirmButton.isEnabled = isValid
        confirmButton.alpha = isValid ? 1.0 : 0.5
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true) { [onCancel] in
            onCancel?()
        }
    }
    
    @objc private func confirmTapped() {
        let text = textField.text
        dismiss(animated: true) { [onConfirm] in
            onConfirm?(text)
        }
    }
}

// MARK: - UIViewController helper
@MainActor
public extension UIViewController {
    
    /// Presents a text field popup from the current view controller.
    /// - Parameters:
    ///   - titleText: Title text displayed at the top.
    ///   - placeholderText: Placeholder for the text field.
    ///   - yesText: Title of the primary (confirm) button.
    ///   - noText: Title of the secondary (cancel) button.
    ///   - minLength: Minimum required length for the input to enable the confirm button.
    ///   - onConfirm: Called with the entered text when the confirm button is tapped.
    ///   - onCancel: Called when the cancel button is tapped or the popup is dismissed.
    func showTextFieldPopup(titleText: String,
                            placeholderText: String = "",
                            yesText: String = "OK",
                            noText: String = "Cancel",
                            minLength: Int = 8,
                            onConfirm: ((String?) -> Void)?,
                            onCancel: (() -> Void)? = nil) {
        let vc = TextFieldPopUpVC(titleText: titleText,
                                  placeholderText: placeholderText,
                                  yesText: yesText,
                                  noText: noText,
                                  minLength: minLength,
                                  onConfirm: onConfirm,
                                  onCancel: onCancel)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        presentSafely(vc, animated: true)
    }
    
    /// Hides the currently presented `TextFieldPopUpVC` if it exists.
    func hideTextFieldVCView() {
        if let popup = presentedViewController as? TextFieldPopUpVC {
            popup.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

#endif


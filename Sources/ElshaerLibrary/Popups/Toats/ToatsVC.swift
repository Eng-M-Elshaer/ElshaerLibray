//
//  ToatsVC.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation
#if canImport(UIKit)
import UIKit

#if canImport(UIKit)
public enum ToastType {
    case info
    case success
    case error
}

@MainActor
public final class ToatsVC: UIViewController {
    
    // MARK: - Properties
    private let message: String
    private let type: ToastType
    private let duration: TimeInterval
    private let completion: (() -> Void)?
    private let buttonTitle: String?
    private let buttonAction: (() -> Void)?
    
    // MARK: - UI
    private let containerView = UIView()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    // MARK: - Init
    public init(message: String,
                type: ToastType = .info,
                duration: TimeInterval = 2.0,
                buttonTitle: String? = nil,
                buttonAction: (() -> Void)? = nil,
                completion: (() -> Void)? = nil) {
        self.message = message
        self.type = type
        self.duration = duration
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methodsز
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        animateIn()
        scheduleDismiss()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .clear
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.alpha = 0
        
        switch type {
        case .info:
            containerView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        case .success:
            containerView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        case .error:
            containerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        }
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        if let title = buttonTitle {
            actionButton.setTitle(title, for: .normal)
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            actionButton.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
        
        containerView.addSubview(messageLabel)
        containerView.addSubview(actionButton)
        view.addSubview(containerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            actionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Animations
    private func animateIn() {
        containerView.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.25) {
            self.containerView.alpha = 1.0
            self.containerView.transform = .identity
        }
    }
    private func scheduleDismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.animateOutAndDismiss()
        }
    }
    private func animateOutAndDismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: 20)
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: false) {
                self.completion?()
            }
        })
    }
    
    @objc private func handleButtonTap() {
        dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            self.buttonAction?()
            self.completion?()
        }
    }
    
    // MARK: - Public API
    /// Presents a small toast-style message from the topmost view controller or a specific presenter.
    /// - Parameters:
    ///   - message: The text to display.
    ///   - type: Visual style (info / success / error).
    ///   - duration: Time interval before automatic dismissal.
    ///   - buttonTitle: Optional action button title.
    ///   - viewController: Optional presenter; if `nil`, the top-most controller is used.
    ///   - onButtonTap: Called when the action button is tapped.
    ///   - onDismiss: Called after the toast has fully disappeared.
public static func show(message: String,
                            type: ToastType = .info,
                            duration: TimeInterval = 2.0,
                            buttonTitle: String? = nil,
                            in viewController: UIViewController? = nil,
                            onButtonTap: (() -> Void)? = nil,
                            onDismiss: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            guard let presenter = viewController ?? UIApplication.topMostViewController() else { return }
            
            let toastVC = ToatsVC(message: message,
                                  type: type,
                                  duration: duration,
                                  buttonTitle: buttonTitle,
                                  buttonAction: onButtonTap,
                                  completion: onDismiss)
            presenter.present(toastVC, animated: false, completion: nil)
        }
    }
}
#endif
#endif

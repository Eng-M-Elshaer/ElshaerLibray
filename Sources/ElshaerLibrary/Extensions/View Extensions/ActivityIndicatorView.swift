//
//  UIView.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import NVActivityIndicatorView
#if canImport(UIKit)
import UIKit

@MainActor
public extension UIView {
    /// loads a full view from a xib file
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIView>() -> T {
            Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
        }
        return instantiateFromNib()
    }

    @MainActor
    @objc
    func showActivityIndicator(color: UIColor = UIColor.blue,
                                      centerOffSet: UIOffset = .zero,
                                      padding: CGFloat = 10) {
        var activityIndicator = self.viewWithTag(98_765_354) as? NVActivityIndicatorView

        if activityIndicator == nil {
            activityIndicator = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, padding: padding)

            activityIndicator?.color = color

            activityIndicator?.tag = 98_765_354

            addSubview(activityIndicator!)

            activityIndicator?.translatesAutoresizingMaskIntoConstraints = false

            activityIndicator?.centerXAnchor.constraint(equalTo: centerXAnchor, constant: centerOffSet.horizontal).isActive = true
            activityIndicator?.centerYAnchor.constraint(equalTo: centerYAnchor, constant: centerOffSet.vertical).isActive = true
            activityIndicator?.heightAnchor.constraint(equalToConstant: min(60,     frame.height)).isActive = true

            if let button = self as? UIButton {
                let title = Array(
                    repeating: " ",
                    count: button.title(for: .normal)?.count ?? 0
                ).joined()

                button.setTitle(title, for: .disabled)
                button.setImage(UIImage(), for: .disabled)

                button.isEnabled = false
                activityIndicator?.color = button.currentTitleColor
            }
        }

        activityIndicator?.startAnimating()
    }

    @objc func hideActivityIndicator() {
        if let activityIndicator = viewWithTag(98_765_354) as? NVActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()

            if let button = self as? UIButton {
                button.isEnabled = true
            }
        }
    }
}

@MainActor
public extension UIView {
    func animateScale(withDuration duration: TimeInterval, scaleX: CGFloat, scaleY: CGFloat) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        }) { _ in
            UIView.animate(withDuration: duration, animations: {
                self.transform = .identity
            })
        }
    }
}

@MainActor
public extension UIView {
    func tap(action: @escaping () -> Void) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewClicked))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true

        // Store the action closure as an associated object
        objc_setAssociatedObject(self, &AssociatedKeys.clickActionKey, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }

    @objc private func viewClicked() {
        if let action = objc_getAssociatedObject(self, &AssociatedKeys.clickActionKey) as? () -> Void {
            action()
        }
    }
}

@MainActor
private struct AssociatedKeys {
    /// Unique key used for storing tap action closures via associated objects.
    static var clickActionKey: UInt8 = 0
}

@MainActor
public extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

@MainActor
public extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
#endif

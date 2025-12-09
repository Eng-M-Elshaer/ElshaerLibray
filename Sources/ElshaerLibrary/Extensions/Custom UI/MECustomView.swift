//
//  MECustomView.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@IBDesignable
@MainActor
class MECustomView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var topLeftCornerRadius: Bool = false {
        didSet {
            updateCorners()
        }
    }
    @IBInspectable var topRightCornerRadius: Bool = false {
        didSet {
            updateCorners()
        }
    }
    @IBInspectable var bottomLeftCornerRadius: Bool = false {
        didSet {
            updateCorners()
        }
    }
    @IBInspectable var bottomRightCornerRadius: Bool = false {
        didSet {
            updateCorners()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        didSet {
            applyShadow()
        }
    }
    @IBInspectable var shadowOpacity: Float = 0.0 {
        didSet {
            applyShadow()
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            applyShadow()
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            applyShadow()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    private func updateCorners() {
        var corners: CACornerMask = []
        if topLeftCornerRadius { corners.insert(.layerMinXMinYCorner) }
        if topRightCornerRadius { corners.insert(.layerMaxXMinYCorner) }
        if bottomLeftCornerRadius { corners.insert(.layerMinXMaxYCorner) }
        if bottomRightCornerRadius { corners.insert(.layerMaxXMaxYCorner) }

        layer.maskedCorners = corners
    }
    private func applyShadow() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
    }
}
#endif

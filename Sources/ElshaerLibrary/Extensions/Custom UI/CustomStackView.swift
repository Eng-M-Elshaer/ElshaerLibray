//
//  CustomStackView.swift
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
class CustomStackView: UIStackView {
    
    private let gradientLayer = CAGradientLayer()
    
    @IBInspectable var firstGradientColor: UIColor = .blue {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var secondGradientColor: UIColor = .red {
        didSet {
            updateGradient()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updateGradient()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateGradient()
    }
    
    private func updateGradient() {
        gradientLayer.colors = [firstGradientColor.cgColor, secondGradientColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    public func setGradientBackground(firstColor: UIColor = .blue, secondColor: UIColor = .red) {
        firstGradientColor = firstColor
        secondGradientColor = secondColor
        updateGradient()
    }
}
#endif

#if canImport(UIKit)
@IBDesignable
@MainActor
class MECustomStackView: UIStackView {
    
    // MARK: - Corner Radius
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
        }
    }
    @IBInspectable var topLeftCornerRadius: CGFloat = 0.0 {
        didSet {
            updateCorners()
        }
    }
    @IBInspectable var topRightCornerRadius: CGFloat = 0.0 {
        didSet {
            updateCorners()
        }
    }
    @IBInspectable var bottomLeftCornerRadius: CGFloat = 0.0 {
        didSet {
            updateCorners()
        }
    }
    @IBInspectable var bottomRightCornerRadius: CGFloat = 0.0 {
        didSet {
            updateCorners()
        }
    }
    
    // MARK: - Border
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            applyBorder()
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            applyBorder()
        }
    }
    
    // MARK: - Shadow
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
    
    private func updateCorners() {
        layer.cornerRadius = 0
        layer.mask = nil
        
        if topLeftCornerRadius > 0 || topRightCornerRadius > 0 || bottomLeftCornerRadius > 0 || bottomRightCornerRadius > 0 {
            var corners: CACornerMask = []
            if topLeftCornerRadius > 0 { corners.insert(.layerMinXMinYCorner) }
            if topRightCornerRadius > 0 { corners.insert(.layerMaxXMinYCorner) }
            if bottomLeftCornerRadius > 0 { corners.insert(.layerMinXMaxYCorner) }
            if bottomRightCornerRadius > 0 { corners.insert(.layerMaxXMaxYCorner) }
            
            layer.cornerRadius = 0
            layer.mask = nil
            
            let maskLayer = CAShapeLayer()
            layer.mask = maskLayer
        }
    }
    private func applyBorder() {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
    private func applyShadow() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
    }
}
#endif

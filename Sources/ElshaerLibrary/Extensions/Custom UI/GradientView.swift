//
//  GradientView.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@IBDesignable
class GradientView: UIView {

    // Define two colors that will form the gradient
    @IBInspectable var startColor: UIColor = UIColor.white {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor.black {
        didSet {
            setNeedsLayout()
        }
    }

    // Optional: Define a start and end point for the gradient direction
    @IBInspectable var startPointX: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var startPointY: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var endPointX: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var endPointY: CGFloat = 1.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // Overriding layoutSubviews to update the gradient
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient()
    }

    // Applying the gradient
    private func applyGradient() {
        // Remove any existing gradient layers
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.removeFromSuperlayer()
        }

        // Create a new gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        // Define the start and end points based on the IBInspectables
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        
        // Apply the gradient to the entire view's bounds
        gradientLayer.frame = self.bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
#endif

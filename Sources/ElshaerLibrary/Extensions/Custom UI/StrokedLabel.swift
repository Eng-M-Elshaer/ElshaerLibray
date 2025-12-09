//
//  StrokedLabel.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@IBDesignable
public class StrokedLabel: UILabel {

    /// The color of the stroke
    @IBInspectable public var strokeColor: UIColor = .black
    
    /// The width of the stroke
    @IBInspectable public var strokeWidth: CGFloat = 2.0
    
    /// Toggle for enabling/disabling the stroke effect
    @IBInspectable public var isStrokeEnabled: Bool = true {
        didSet {
            setNeedsDisplay()  // Redraw the label when the toggle changes
            updateBlurEffect()  // Add/remove blur based on the toggle
        }
    }
    
    private var blurEffectView: UIVisualEffectView?

    public override func draw(_ rect: CGRect) {
        guard isStrokeEnabled else {
            super.draw(rect)  // Draw normally if stroke is disabled
            return
        }
        
        // Apply stroke effect
        let text = self.text ?? ""
        let textAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: strokeColor,
            .foregroundColor: self.textColor ?? .black,
            .strokeWidth: -strokeWidth,  // Negative for outer stroke
            .font: self.font ?? UIFont.systemFont(ofSize: 17)
        ]
        
        // Draw the stroked text
        let attributedString = NSAttributedString(string: text, attributes: textAttributes)
        attributedString.draw(in: rect)
    }

    private func updateBlurEffect() {
        if isStrokeEnabled {
            // Add blur effect if enabled
            if blurEffectView == nil {
                let blurEffect = UIBlurEffect(style: .extraLight)  // Choose desired blur style
                blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView?.frame = bounds
                blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                addSubview(blurEffectView!)
                sendSubviewToBack(blurEffectView!)
            }
            blurEffectView?.isHidden = false
        } else {
            // Remove or hide blur effect if disabled
            blurEffectView?.isHidden = true
        }
    }
}
#endif

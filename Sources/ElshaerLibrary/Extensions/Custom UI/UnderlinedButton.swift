//
//  UnderlinedButton.swift
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
public class UnderlinedButton: UIButton {

    @IBInspectable public var lineColor: UIColor = .black

    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(1.0)

        // Draw the line at the bottom of the button
        context.move(to: CGPoint(x: 0, y: rect.height))
        context.addLine(to: CGPoint(x: rect.width, y: rect.height))

        context.strokePath()
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: size.height + 0.5) // Add space for the underline
    }
}
#endif

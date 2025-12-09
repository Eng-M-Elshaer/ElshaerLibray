//
//  AddBadge.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@MainActor
public extension UIView {
    /// Unique tag identifier used to find and remove the badge label.
    private static let badgeTag = 101

    func addBadge(count: Int,
                         backgroundColor: UIColor = .white,
                         bottomOffset: CGFloat = 12,
                         minFontSize: CGFloat = 9) {
        // If count is zero or less, remove any existing badge and exit
        if count <= 0 {
            removeBadge()
            return
        }
        
        // Remove any existing badge before adding a new one
        removeBadge()
        
        // Create a label for the badge
        let badgeLabel = UILabel()
        badgeLabel.tag = Self.badgeTag  // Assign unique tag to badge label
        badgeLabel.text = "\(count)"
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = backgroundColor
        badgeLabel.textAlignment = .center
        badgeLabel.layer.masksToBounds = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.adjustsFontSizeToFitWidth = true
        badgeLabel.minimumScaleFactor = minFontSize / badgeLabel.font.pointSize

        // Add the badge label as a subview
        self.addSubview(badgeLabel)
        
        // Define the constraints for the badge label
        let badgeSize: CGFloat = 18.0
        let trailingConstraint = NSLayoutConstraint(item: badgeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.2, constant: UIApplication.isRTL() ?  -5 : -10)
        let bottomConstraint = NSLayoutConstraint(item: badgeLabel,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .top,
                                                  multiplier: 1.0,
                                                  constant: 5 + bottomOffset)
        let widthConstraint = NSLayoutConstraint(item: badgeLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: badgeSize)
        let heightConstraint = NSLayoutConstraint(item: badgeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: badgeSize)
        
        NSLayoutConstraint.activate([trailingConstraint, bottomConstraint, widthConstraint, heightConstraint])
        badgeLabel.layer.cornerRadius = badgeSize / 2
        badgeLabel.font = badgeLabel.font.withSize(badgeSize * 0.6)
    }

    func removeBadge() {
        // Find the badge label by tag and remove it
        self.subviews.first(where: { $0.tag == Self.badgeTag })?.removeFromSuperview()
    }
}
#endif

//
//  CustomButton.swift
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
public class CustomButton: UIButton {
    private let gradientLayer = CAGradientLayer()

    @IBInspectable public var firstGradientColor: UIColor = .blue {
        didSet { updateGradientColors() }
    }

    @IBInspectable public var secondGradientColor: UIColor = .red {
        didSet { updateGradientColors() }
    }

    @IBInspectable public var cornerRadius: CGFloat = ViewConstants.radius {
        didSet {
            layer.cornerRadius = cornerRadius
            setNeedsLayout()
        }
    }

    @IBInspectable public var isHasObserver: Bool = true {
        didSet {
            if isDanger && isHasObserver {
                setLightGreyBackground()
            } else if isDanger && !isHasObserver {
                setDangerBackground()
            } else if isHasObserver {
                setLightGreyBackground()
            } else {
                setGradientBackground()
            }
        }
    }

    @IBInspectable public var isDanger: Bool = false {
        didSet {
            if isDanger && isEnabled {
                setDangerBackground()
            } else if isDanger && !isEnabled {
                setLightGreyBackground()
            } else {
                if isEnabled {
                    if isHasObserver {
                        setLightGreyBackground()
                    } else {
                        setGradientBackground()
                    }
                } else {
                    setLightGreyBackground()
                }
            }
        }
    }

    public override var isEnabled: Bool {
        didSet {
            if isDanger && isEnabled {
                setDangerBackground()
            } else if isDanger && !isEnabled {
                setLightGreyBackground()
            } else if isEnabled {
                setGradientBackground()
            } else {
                setLightGreyBackground()
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    private func setupButton() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true

        if isDanger {
            setDangerBackground()
        } else if isHasObserver {
            setLightGreyBackground()
        } else {
            setGradientBackground()
        }
    }

    private func updateGradientColors() {
        gradientLayer.colors = [firstGradientColor.cgColor, secondGradientColor.cgColor]
        setNeedsLayout()
    }

    public func setLightGreyBackground() {
        backgroundColor = .lightGray
        gradientLayer.isHidden = true
    }

    public func setGradientBackground() {
        gradientLayer.isHidden = false
        updateGradientColors()
    }

    public func setDangerBackground() {
        backgroundColor = .red
        gradientLayer.isHidden = true
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        layer.cornerRadius = cornerRadius
        if let imageView = imageView {
            bringSubviewToFront(imageView)
        }
        if let titleLabel = titleLabel {
            bringSubviewToFront(titleLabel)
        }
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupButton()
    }
}
#endif


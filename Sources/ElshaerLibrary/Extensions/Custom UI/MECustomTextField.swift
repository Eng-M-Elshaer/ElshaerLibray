//
//  MECustomTextField.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
@MainActor
class MSCustomTextField: UITextField {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
        }
    }

    @IBInspectable var halfCornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.layer.frame.height / 2
            self.clipsToBounds = true
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
}

//MARK: - CustomTextField For Verify Code.
class CustomTextField: UITextField {
    
    var textFieldOne: UITextField = UITextField()
    var textFieldTwo: UITextField = UITextField()
    var textFieldThree: UITextField = UITextField()
    var textFieldFour: UITextField = UITextField()
    
    override func deleteBackward() {
        super.deleteBackward()
        if text?.isEmpty ?? true {
            switch tag {
            case 1:
                textFieldOne.resignFirstResponder()
            case 2:
                textFieldOne.becomeFirstResponder()
            case 3:
                textFieldTwo.becomeFirstResponder()
            case 4:
                textFieldThree.becomeFirstResponder()
            default:
                break
            }
        }
    }
}
#endif

//
//  RoundButton.swift
//  FMEAR
//
//  Created by Angus Lau on 2019-09-03.
//  Copyright © 2019 Safe Software Inc. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var textAlignmentCenter: Bool = false {
        didSet {
            if (textAlignmentCenter) {
                titleLabel?.textAlignment = .center
            } else {
                titleLabel?.textAlignment = .natural
            }
        }
    }
}

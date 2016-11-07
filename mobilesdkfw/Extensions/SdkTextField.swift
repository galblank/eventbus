//
//  SdkTextField.swift
//  mobilesdkfw
//
//  Created by Gal Blank on 5/9/16.
//  Copyright © 2016 Goemerchant. All rights reserved.
//

import UIKit

open class SdkTextField: UITextField {

    
        let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
        
        override open func textRect(forBounds bounds: CGRect) -> CGRect {
            return UIEdgeInsetsInsetRect(bounds, padding)
        }
        
        override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return UIEdgeInsetsInsetRect(bounds, padding)
        }
        
        override open func editingRect(forBounds bounds: CGRect) -> CGRect {
            return UIEdgeInsetsInsetRect(bounds, padding)
        }
    

        open func addBottomBorderLine()
        {
            let border = CALayer()
            let width = CGFloat(2.0)
            border.borderColor = UIColor.darkGray.cgColor
            border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
            
            border.borderWidth = width
            self.layer.addSublayer(border)
            self.layer.masksToBounds = true
        }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

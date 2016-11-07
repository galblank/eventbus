//
//  AlignableLabel.swift
//  mobilesdkfw
//
//  Created by Gal Blank on 5/23/16.
//  Copyright © 2016 Goemerchant. All rights reserved.
//

import UIKit

open class AlignableLabel: UILabel {

   
        open override func drawText(in rect: CGRect) {
            
            var newRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height)
            let fittingSize = sizeThatFits(rect.size)
            
            if contentMode == UIViewContentMode.top {
                newRect.size.height = min(newRect.size.height, fittingSize.height)
            } else if contentMode == UIViewContentMode.bottom {
                newRect.origin.y = max(0, newRect.size.height - fittingSize.height)
            }
            
            super.drawText(in: newRect)
        }

}

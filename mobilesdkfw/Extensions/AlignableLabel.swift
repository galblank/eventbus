//
//  AlignableLabel.swift
//  mobilesdkfw
//
//  Created by Gal Blank on 5/23/16.
//  Copyright © 2016 Goemerchant. All rights reserved.
//

import UIKit

public class AlignableLabel: UILabel {

   
        public override func drawTextInRect(rect: CGRect) {
            
            var newRect = CGRectMake(rect.origin.x, rect.origin.y, rect.width, rect.height)
            let fittingSize = sizeThatFits(rect.size)
            
            if contentMode == UIViewContentMode.Top {
                newRect.size.height = min(newRect.size.height, fittingSize.height)
            } else if contentMode == UIViewContentMode.Bottom {
                newRect.origin.y = max(0, newRect.size.height - fittingSize.height)
            }
            
            super.drawTextInRect(newRect)
        }

}

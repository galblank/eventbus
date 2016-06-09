//
//  WaitingOverlay.swift
//  POS
//
//  Created by Gal Blank on 12/14/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

import Foundation
import UIKit

public class WaitingOverlay:UIView  {
    
    public var  caption:String = ""
    public var isCurrentlyActive:Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
        self.alpha = 0.7
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        let activityWheel: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityWheel.center = self.center
        activityWheel.startAnimating()
        self.addSubview(activityWheel)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }
    
    public override func drawRect(rect: CGRect) {
        let labelCaption: UILabel = UILabel(frame: CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10))
        // /*CGRectMake(0, 500, 768,100)*/
        labelCaption.text = caption
        labelCaption.layer.cornerRadius = 10.0
        labelCaption.textColor = UIColor.whiteColor()
        labelCaption.font = UIFont.systemFontOfSize(14)
        labelCaption.backgroundColor = UIColor.clearColor()
        labelCaption.numberOfLines = 0
        labelCaption.textAlignment = .Center
        self.addSubview(labelCaption)
    }
    
}
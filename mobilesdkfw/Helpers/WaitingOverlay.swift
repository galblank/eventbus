//
//  WaitingOverlay.swift
//  POS
//
//  Created by Gal Blank on 12/14/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

import Foundation
import UIKit

open class WaitingOverlay:UIView  {
    
    open var  caption:String = ""
    open var isCurrentlyActive:Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.alpha = 0.7
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        let activityWheel: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityWheel.center = self.center
        activityWheel.startAnimating()
        self.addSubview(activityWheel)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }
    
    open override func draw(_ rect: CGRect) {
        let labelCaption: UILabel = UILabel(frame: CGRect(x: 5, y: 5, width: self.frame.size.width - 10, height: self.frame.size.height - 10))
        // /*CGRectMake(0, 500, 768,100)*/
        labelCaption.text = caption
        labelCaption.layer.cornerRadius = 10.0
        labelCaption.textColor = UIColor.white
        labelCaption.font = UIFont.systemFont(ofSize: 14)
        labelCaption.backgroundColor = UIColor.clear
        labelCaption.numberOfLines = 0
        labelCaption.textAlignment = .center
        self.addSubview(labelCaption)
    }
    
}

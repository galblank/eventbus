//
//  ImageLabel.swift
//  mobilesdkfw
//
//  Created by Gal Blank on 6/20/16.
//  Copyright © 2016 PeopleLinx. All rights reserved.
//

import UIKit

public class ImageLabel: UIView {

    public var image:UIImage? = nil
    public var text:String = ""
    
    public  func initLabel(_image:UIImage, _text:String, _font:UIFont) {
        image = _image
        text = _text
        
        let imageview = UIImageView(frame: CGRect(origin: CGPointMake(0, 0), size: CGSizeMake(20, 20)))
        imageview.image = image
        addSubview(imageview)
        
        let label = UILabel(frame: CGRect(x: imageview.frame.size.width, y: 0, width: self.frame.size.width - 20, height: self.frame.size.height))
        label.font = _font
        label.text = _text
        label.textColor = UIColor(red: 18.0 / 255.0, green: 163.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0)
        addSubview(label)
    }
   

}

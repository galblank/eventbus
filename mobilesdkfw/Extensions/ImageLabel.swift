//
//  ImageLabel.swift
//  mobilesdkfw
//
//  Created by Gal Blank on 6/20/16.
//  Copyright © 2016 PeopleLinx. All rights reserved.
//

import UIKit

open class ImageLabel: UIView {

    open var image:UIImage? = nil
    open var text:String = ""
    open var label:UILabel!
    open var imageview:UIImageView? = nil
    open  func initLabel(_ _image:UIImage, _text:String, _font:UIFont) {
        image = _image
        text = _text
        let fr = image?.size
        imageview = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: image!.size))
        imageview!.image = image
        addSubview(imageview!)
 
        let frame = CGRect(x: imageview!.frame.size.width + 5, y: 0, width: self.frame.size.width - (imageview!.frame.size.width + 5), height: self.frame.size.height)
        label = UILabel(frame: frame)
        label.textAlignment = .left
        label.font = _font
        label.text = _text
        addSubview(label)
    }
   


    override open func layoutSubviews() {
        super.layoutSubviews()
        let lblframe = CGRect(x: imageview!.frame.size.width + 5, y: 0, width: self.frame.size.width - (imageview!.frame.size.width + 5), height: self.frame.size.height)
        label.frame = lblframe
        label.sizeToFit()
        
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: imageview!.frame.size.width + label.frame.size.width, height: frame.size.height)
    }

}

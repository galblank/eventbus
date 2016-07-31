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
    public var label:UILabel!
    public var imageview:UIImageView? = nil
    public  func initLabel(_image:UIImage, _text:String, _font:UIFont) {
        image = _image
        text = _text
        
        imageview = UIImageView(frame: CGRect(origin: CGPointMake(0, 0), size: image!.size))
        imageview!.image = image
        addSubview(imageview!)
 
        let frame = CGRect(x: imageview!.frame.size.width + 5, y: 0, width: self.frame.size.width - (imageview!.frame.size.width + 5), height: self.frame.size.height)
        label = UILabel(frame: frame)
        label.textAlignment = .Left
        label.font = _font
        label.text = _text
        addSubview(label)
    }
   


    override public func layoutSubviews() {
        super.layoutSubviews()
        let frame = CGRect(x: imageview!.frame.size.width + 5, y: 0, width: self.frame.size.width - (imageview!.frame.size.width + 5), height: self.frame.size.height)
        label.frame = frame
        label.sizeToFit()
    }

}

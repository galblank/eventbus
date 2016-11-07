//
//  DynamicTextView.swift
//  mobilesdkfw
//
//  Created by Gal Blank on 6/9/16.
//  Copyright © 2016 PeopleLinx. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public protocol DynamicTextViewDelegate {
    func dynamicTextViewDidResizeHeight(_ textview: DynamicTextView, height: CGFloat)
}

open class DynamicTextView: UITextView {
    
    open var dynamicDelegate: DynamicTextViewDelegate?
    open var addBottomBorder = false
    var minHeight: CGFloat!
    var maxHeight: CGFloat?
    fileprivate var contentOffsetCenterY: CGFloat!
    var bottomborder:CALayer? = nil
    
    public init(frame: CGRect, offset: CGFloat = 0.0) {
        super.init(frame: frame, textContainer: nil)
        minHeight = frame.size.height
        
        //center first line
        let size = self.sizeThatFits(CGSize(width: self.bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        contentOffsetCenterY = (-(frame.size.height - size.height * self.zoomScale) / 2.0) + offset
        
        //listen for text changes
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        //update offsets
        layoutSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func applyaBottomBorder()
    {
        let height = CGFloat(1.0)
        if(bottomborder == nil){
            bottomborder = CALayer()
            bottomborder!.borderColor = UIColor.darkGray.cgColor
            bottomborder!.borderWidth = 1.0
            self.layer.addSublayer(bottomborder!)
            self.layer.masksToBounds = false
        }
        bottomborder!.frame = CGRect(x: 0, y: self.frame.size.height - height, width:  self.frame.size.width, height: height)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if(addBottomBorder == true){
            applyaBottomBorder()
        }
        //Use content size if more than min size, compensate for Y offset
        var height = max(self.contentSize.height - (contentOffsetCenterY * 2.0), minHeight)
        var updateContentOffsetY: CGFloat?
        //Max Height
        if maxHeight != nil && height > maxHeight {
            //Cap at maxHeight
            height = maxHeight!
        } else {
            //constrain Y to prevent odd skip and center content to view.
            updateContentOffsetY = contentOffsetCenterY
        }
        //update frame if needed & notify delegate
        if self.frame.size.height != height {
            self.frame.size.height = height
            dynamicDelegate?.dynamicTextViewDidResizeHeight(self, height: height)
        }
        //constrain Y must be done after setting frame
        if updateContentOffsetY != nil {
            self.contentOffset.y = updateContentOffsetY!
        }
    }
    
    func textChanged() {
        let caretRect = self.caretRect(for: self.selectedTextRange!.start)
        let overflow = caretRect.size.height + caretRect.origin.y - (self.contentOffset.y + self.bounds.size.height - self.contentInset.bottom - self.contentInset.top)
        if overflow > 0 {
            //Fix wrong offset when cursor jumps to next line un explisitly
            let seekEndY = self.contentSize.height - self.bounds.size.height
            if self.contentOffset.y != seekEndY {
                self.contentOffset.y = seekEndY
            }
        }
    }
}

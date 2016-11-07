//
//  PolymorphicScannerService.swift
//  POS
//
//  Created by Gal Blank on 12/15/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

import UIKit



class PolymorphicPrinterService: NSObject {
    
    func startService(){}
    
    func consumeMessage(notif:NSNotification){}
    
    func searchForAllConnectedPrinters(){}
    
    func printerDidConnect(notif:NSNotification){}
    
    /**
     *  Process Non-Enhanced/Plain Text Receipts
     *
     *  @param slipData NSString the raw slip data.
     *  @param job POSPrintQueueJob the job queue.
     *
     */
     
     // The output below is limited by 1 KB.
     // Please Sign Up (Free!) to remove this limitation.
    
    func textToPrinterImage(printString: NSString, withFontSize textSize: CGFloat) -> UIImage {
        let width: CGFloat = 576.0
        let fontName: String = "Courier"
        var fontSize: CGFloat = textSize
        fontSize *= 2
        let font: UIFont = UIFont(name: fontName, size: fontSize)!
        let size: CGSize = CGSizeMake(width, CGFloat.max)
        let tmpRect: CGRect = printString.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        var messuredSize: CGSize = tmpRect.size
        messuredSize.height += 100
        if UIScreen.mainScreen().respondsToSelector("scale") {
            if UIScreen.mainScreen().scale == 2.0 {
                UIGraphicsBeginImageContextWithOptions(messuredSize, false, 1)
            }
            else {
                UIGraphicsBeginImageContext(messuredSize)
            }
        }
        else {
            UIGraphicsBeginImageContext(messuredSize)
        }
        let ctr: CGContextRef = UIGraphicsGetCurrentContext()!
        
        var color: UIColor = UIColor.whiteColor()
        color.set()
        let rect: CGRect = CGRectMake(0, 0, messuredSize.width, messuredSize.height + 100)
        CGContextFillRect(ctr, rect)
        
        color = UIColor.blackColor()
        color.set()
        let style: NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .Center
        var attr: [String : AnyObject] = [String : AnyObject]()
        attr[NSFontAttributeName] = font
        printString.drawInRect(CGRectMake(rect.origin.x, rect.origin.y + 44, rect.size.width, rect.size.height), withAttributes: attr)
        let imageToPrint: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return imageToPrint
    }
    
}

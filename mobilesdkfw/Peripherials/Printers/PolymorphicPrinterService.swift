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
    
    func consumeMessage(_ notif:Notification){}
    
    func searchForAllConnectedPrinters(){}
    
    func printerDidConnect(_ notif:Notification){}
    
    /**
     *  Process Non-Enhanced/Plain Text Receipts
     *
     *  @param slipData NSString the raw slip data.
     *  @param job POSPrintQueueJob the job queue.
     *
     */
     
     // The output below is limited by 1 KB.
     // Please Sign Up (Free!) to remove this limitation.
    
    func textToPrinterImage(_ printString: NSString, withFontSize textSize: CGFloat) -> UIImage {
        let width: CGFloat = 576.0
        let fontName: String = "Courier"
        var fontSize: CGFloat = textSize
        fontSize *= 2
        let font: UIFont = UIFont(name: fontName, size: fontSize)!
        let size: CGSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let tmpRect: CGRect = printString.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        var messuredSize: CGSize = tmpRect.size
        messuredSize.height += 100
        if UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale)) {
            if UIScreen.main.scale == 2.0 {
                UIGraphicsBeginImageContextWithOptions(messuredSize, false, 1)
            }
            else {
                UIGraphicsBeginImageContext(messuredSize)
            }
        }
        else {
            UIGraphicsBeginImageContext(messuredSize)
        }
        let ctr: CGContext = UIGraphicsGetCurrentContext()!
        
        var color: UIColor = UIColor.white
        color.set()
        let rect: CGRect = CGRect(x: 0, y: 0, width: messuredSize.width, height: messuredSize.height + 100)
        ctr.fill(rect)
        
        color = UIColor.black
        color.set()
        let style: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .center
        var attr: [String : AnyObject] = [String : AnyObject]()
        attr[NSFontAttributeName] = font
        printString.draw(in: CGRect(x: rect.origin.x, y: rect.origin.y + 44, width: rect.size.width, height: rect.size.height), withAttributes: attr)
        let imageToPrint: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return imageToPrint
    }
    
}

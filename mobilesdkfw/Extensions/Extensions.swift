//
//  Extensions.swift
//  POS
//
//  Created by Gal Blank on 12/7/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

import Foundation

extension String{
    func urlEncode(toencode:String) -> String
    {
        let str:String = CFURLCreateStringByAddingPercentEscapes(
            nil,
            toencode,
            nil,
            "!*'();:@&=+$,/?%#[]",
            CFStringBuiltInEncodings.UTF8.rawValue
        ) as String
        
        return str
    }
}

extension NSObject {
    var theClassName: String {
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
}


extension Character {
    func utf8Value() -> UInt8 {
        for s in String(self).utf8 {
            return s
        }
        return 0
    }
    
    func utf16Value() -> UInt16 {
        for s in String(self).utf16 {
            return s
        }
        return 0
    }
    
    func unicodeValue() -> UInt32 {
        for s in String(self).unicodeScalars {
            return s.value
        }
        return 0
    }
}



extension String {    

    subscript(integerIndex: Int) -> Character {
        let index = startIndex.advancedBy(integerIndex)
        return self[index]
    }
    
    subscript(integerRange: Range<Int>) -> String {
        let start = startIndex.advancedBy(integerRange.startIndex)
        let end = startIndex.advancedBy(integerRange.endIndex)
        let range = start..<end
        return self[range]
    }
    
    subscript (i: Int) -> String {
        let index = self.startIndex.advancedBy(i)
        return String(self[index] as! Character) // returns Character 'o'
        //return String(self[i] as Character)
    }
    

    public func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
                return from ..< to
        }
        return nil
    }
    
    public func urlDecode() -> String? {
        return stringByRemovingPercentEncoding
    }
    
    public func urlEncodedString() -> String? {
        let customAllowedSet =  NSCharacterSet.URLQueryAllowedCharacterSet()
        let escapedString = self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())
        return escapedString
    }
    
    
    public func validateEmail(email:String) -> Bool{
        let emailRegex:String = String("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(email)
    }
    
    public var first: String {
        return String(characters.prefix(1))
    }
    
    public var last: String {
        return String(characters.suffix(1))
    }
    
    public var uppercaseFirst: String {
        return first.uppercaseString + String(characters.dropFirst())
    }
    
  
    public func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
   /* public static func stripHTML(html:String) -> String
    {
        let HTMLTags = "<[^>]*>"; //regex to remove any html tag
        
        var stringWithoutHTML = NSString(string: html)
        stringWithoutHTML = stringWithoutHTML.stringByReplacingOccurrencesOfRegex(HTMLTags, withString: "")
        
        return String(stringWithoutHTML)
    }*/
    
    
}

extension Dictionary {
    mutating public func merge<K, V>(dict: [K: V]){
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}

extension UIButton{

    public func centerImageAndTitleEx()
    {
        var frame = self.imageView!.frame;
        var tranced = truncf((Float(self.bounds.size.width) - Float(frame.size.width)) / 2)
        frame = CGRect(x: CGFloat(tranced), y: 7, width: frame.size.width, height: frame.size.height)
        
        self.imageView!.frame = frame
        frame = self.titleLabel!.frame
        
        tranced = truncf((Float(self.bounds.size.width) - Float(frame.size.width)) / 2)
        
        frame = CGRect(x:CGFloat(tranced), y:self.imageView!.frame.origin.y + self.imageView!.frame.size.height + 5, width:frame.size.width, height:frame.size.height);
        
        self.titleLabel!.frame = frame;
        
    }
}


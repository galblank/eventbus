//
//  PolymorphicScannerService.swift
//  POS
//
//  Created by Gal Blank on 12/15/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

import UIKit

class PolymorphicScannerService: NSObject {

    func startService(){}
    
    func consumeMessage(notif:NSNotification){}
    
    func calculateCheckDigitOfUPC(upc: String) -> Float {
        var total: Int = 0
        var characters: [AnyObject] = NSMutableArray(capacity: upc.characters.count) as [AnyObject]
        for var i = 0; i < upc.characters.count; i++ {
            characters.append(upc[i])
        }
        for var x = 0; x < characters.count; x += 2 {
            total = total + Int(characters[x] as! NSNumber)
        }
        total = total * 3
        for var x = 1; x < characters.count; x += 2 {
            total = total + Int(characters[x] as! NSNumber)
        }
        
        
        return ceilf(Float(total) / 10.0) * 10.0 - Float(total)
    }
    
    func convertUPCEToUPCA(upce: String) -> String {
        var ManufacturerNumber: String = ""
        var ItemNumber: String = ""
        var UPCEstring: String = ""
        // = [upce mutableCopy];
        if upce.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 7 {
            UPCEstring = upce.substringToIndex(upce.startIndex.advancedBy(6))
            //DLog(@"it is 7");
        }
        else {
            if upce.characters.count == 8 || upce.characters.count == 9 {
                UPCEstring = upce.substringWithRange(upce.rangeFromNSRange(NSMakeRange(1, 6))!)
                //DLog(@"it is 8 or 9");
            }
            else {
                UPCEstring = upce.mutableCopy() as! String
            }
        }
        /**
        * Fix for defect 1271  - GOS - 05/01/15
        */
        //DLog(@"UPCEstring:%@", UPCEstring);
        //    CLS_LOG(@"UPCEstring:%@", UPCEstring);
        // Add in a check to ensure that the UPCEstring is at least 6 character in length.
        if UPCEstring.characters.count >= 6 {
            let digit1 = Array(arrayLiteral: UPCEstring)[0]
            let digit2 = Array(arrayLiteral: UPCEstring)[1]
            let digit3 = Array(arrayLiteral: UPCEstring)[2]
            let digit4 = Array(arrayLiteral: UPCEstring)[3]
            let digit5 = Array(arrayLiteral: UPCEstring)[4]
            let digit6 = Array(arrayLiteral: UPCEstring)[5]
            
            if(Int(digit6)! == 0 || Int(digit6)! == 1 || Int(digit6)! == 2)
            {
                ManufacturerNumber = "\(digit1)\(digit2)\(digit6)00"
                ItemNumber = "00\(digit3)\(digit4)\(digit5)"
            }
            else if(Int(digit6)! == 3){
                ManufacturerNumber = "\(digit1)\(digit2)\(digit3)00"
                ItemNumber = "000\(digit4)\(digit5)"
            }
            else if(Int(digit6)! == 4){
                ManufacturerNumber = "\(digit1)\(digit2)\(digit3)\(digit4)0"
                ItemNumber = "0000\(digit5)"
            }
            else{
                ManufacturerNumber = "\(digit1)\(digit2)\(digit3)\(digit4)\(digit5)"
                ItemNumber = "0000\(digit6)"
            }
            var upca: String = "0\(ManufacturerNumber)\(ItemNumber)"
            upca = "\(upca)\(self.calculateCheckDigitOfUPC(upca))"
            return upca
        }
        else {
            return ""
        }
    }
    
    
    func handleBarcodeScan(var scannedUPC: String) {
        //DLog(@"scannedUPC:%@", scannedUPC);
        if scannedUPC.hasPrefix("DS") {
            
        }
        else {
            if scannedUPC.characters.count < 12 {
                scannedUPC = self.convertUPCEToUPCA(scannedUPC)
                //DLog(@"Converted UPC:%@", scannedUPC);
            }
            else {
                if scannedUPC.characters.count >= 13 {
                    scannedUPC = scannedUPC.substringWithRange(scannedUPC.rangeFromNSRange(NSMakeRange(1, 12))!)
                }
            }
            
            NSLog("Dispatching scanned product message %@", scannedUPC)
            let msg:Message = Message(routKey: "internal.messageTypeProductScanned")
            //msg.ttl = DEFAULT_TTL
            msg.params = [
                "productUPC" : scannedUPC
            ]
            MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
        }
    }
    
}

//
//  IngenicoDriver.swift
//  mobilesdkfw
//
//  Created by Gal Blank on 3/3/16.
//  Copyright © 2016 Goemerchant. All rights reserved.
//

import UIKit


public struct EMVTags {
    var tagfullid = ""
    var tagshortid = ""
    var taglen = ""
    var tagdata = ""
    
    //{"length":"07","tag":"84","value":"A0000000031010"}
    public func tagToDic() -> [String:String]
    {
        let dic = ["tag":tagshortid,"value":tagdata,"length":taglen]
        return dic
    }
}

@objc public enum RBAStates:Int {
    case Idle
    case TxnInitiated
    case TxnWaitingForUserAmountConfirmation
    case TxnCancelled
    case TxnAmountConfirmed
    case TxnAuthorizing
    case TxnAuthorized
}

public class TxnStateMachine:NSObject{
    
    override init() {
        super.init()
    }
    
    
    
    public var currentState = RBAStates.Idle
}

public class IngenicoDriver: PolymorphicSwiperService,NSStreamDelegate {
    public static let sharedIngenicoInstance = IngenicoDriver()
    var inputStream:NSInputStream!
    var outputStream:NSOutputStream!
    var statemachine:Observable<RBAStates> = Observable<RBAStates>(RBAStates.Idle)
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IngenicoDriver.consumeMessage(_:)), name:"internal.discovernetowrkswipers", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IngenicoDriver.consumeMessage(_:)), name:"internal.acceptcard", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IngenicoDriver.consumeMessage(_:)), name:"internal.connectrba", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IngenicoDriver.consumeMessage(_:)), name:"internal.sendresponsetorba", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IngenicoDriver.consumeMessage(_:)), name:"internal.txndetails", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IngenicoDriver.consumeMessage(_:)), name:"internal.amountconfirmed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IngenicoDriver.consumeMessage(_:)), name:"internal.closerbaconnection", object: nil)
        devicesArray.didChange.addHandler(self, handler: IngenicoDriver.foundDevices)
        statemachine.didChange.addHandler(self, handler: IngenicoDriver.stateChanged)
    }
    
    
    public func stream(aStream: NSStream, handleEvent aStreamEvent: NSStreamEvent) {
        switch aStreamEvent {
        case NSStreamEvent.OpenCompleted:
            if(aStream.isKindOfClass(NSOutputStream) == true){
                NSLog("Initiating EMV Transaction")
                statemachine.set(RBAStates.TxnInitiated)
                let msg:Message = Message(routKey: "internal.rbaconnected")
                MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
            }
        case NSStreamEvent.HasBytesAvailable:
            self.read()
        case NSStreamEvent.HasSpaceAvailable:
            break
        case NSStreamEvent.EndEncountered:
            break
        case NSStreamEvent.None:
          break
        case NSStreamEvent.ErrorOccurred:
            print("NSStreamEvent.ErrorOccurred")
        default:
            print("# something weird happend")
        }
    }
    
    public func parseEMVStatus(data:String){
        //33.01.000000IS-MA-------------------S--I-----?
        let flags = data.substringFromIndex(data.startIndex.advancedBy(13))
        for i in 0 ..< flags.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
            switch (i)
            {
            case RBAProtocolConst.sharedRBAConstsInstance.CHIP_CARD:
                NSLog("CHIP_CARD: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.EMV_PROCESS_STATUS:
                NSLog("EMV_PROCESS_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.EMV_COMPLETION_STATUS:
                NSLog("EMV_COMPLETION_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.LANG_SELECT_STATUS:
                NSLog("LANG_SELECT_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.APP_SELECT_STATUS:
                NSLog("APP_SELECT_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.APP_CONFIRM_STATUS:
                NSLog("APP_CONFIRM_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.RWRDS_REQ_STATUS:
                NSLog("RWRDS_REQ_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.PYMT_TYPE_STATUS:
                NSLog("PYMT_TYPE_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.AMT_CONFIRM_STATUS:
                NSLog("AMT_CONFIRM_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.LAST_PIN_ENTRY_TRY:
                NSLog("LAST_PIN_ENTRY_TRY: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.OFFLINE_PIN_ENTERED:
                NSLog("OFFLINE_PIN_ENTERED: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.ACCNT_TYPE_SELECTED:
                NSLog("ACCNT_TYPE_SELECTED: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.AUTH_REQ_SENT:
                NSLog("AUTH_REQ_SENT: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.AUTH_RESP_RECEIVED:
                NSLog("AUTH_RESP_RECEIVED: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.CONFIRM_RESP_SENT:
                NSLog("CONFIRM_RESP_SENT: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.TRANS_CANCELLED:
                NSLog("TRANS_CANCELLED: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.CARD_READ_STATUS:
                NSLog("CARD_READ_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.CARD_LOCKED_STATUS:
                NSLog("CARD_LOCKED_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.ERROR_DETECTED_STATUS:
                NSLog("ERROR_DETECTED_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.PREMATURE_CARD_REMOVAL:
                NSLog("PREMATURE_CARD_REMOVAL: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.CARD_NOT_SUPPORTED:
                NSLog("CARD_NOT_SUPPORTED: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.MAC_VERIFICATION_STATUS:
                NSLog("MAC_VERIFICATION_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.POST_CONFIRM_WAIT_START_STATUS:
                NSLog("POST_CONFIRM_WAIT_START_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.SIGNATURE_REQUESTED:
                NSLog("SIGNATURE_REQUESTED: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.TRANS_PREP_RESP_SENT:
                NSLog("TRANS_PREP_RESP_SENT: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.EMV_FLOW_SUSPENDED:
                NSLog("EMV_FLOW_SUSPENDED: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.ONLINE_PIN_ENETERED:
                NSLog("ONLINE_PIN_ENETERED: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.EMV_STATE:
                NSLog("EMV_STATE: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.CLESS_TRANS_STARTED:
                NSLog("CLESS_TRANS_STARTED: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.CLESS_ERROR_FLAG:
                NSLog("CLESS_ERROR_FLAG: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.EMV_CASHBACK_STATUS:
                NSLog("EMV_CASHBACK_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.CLESS_STATUS:
                NSLog("CLESS_STATUS: %@", flags[i])
                break;
            case RBAProtocolConst.sharedRBAConstsInstance.CLESS_ERROR:
                NSLog("CLESS_ERROR: %@", flags[i])
                break
            default:
                break;
            }
        }
    }

    
    
    func sendNack()
    {
        var buffer = [UInt8](count: 2048, repeatedValue: 0)
        buffer[0] = 0x06
        self.send(nil, buffer: buffer)
    }
    
    func read(){
        var buffer = [UInt8](count: 2048, repeatedValue: 0)
        var output: String = ""
        while (self.inputStream.hasBytesAvailable){
            let bytesRead: Int = inputStream.read(&buffer, maxLength: buffer.count)
            if bytesRead >= 0 {
                if(buffer[0] == 0x06){
                    //NSLog("RECEVIED ACK", "")
                }
                else{
                    output += NSString(bytes: UnsafePointer(buffer), length: bytesRead, encoding: NSUTF8StringEncoding)! as String
                }
            } else {
                print("# error")
            }
        }
        
        if(output.characters.count > 0){
            self.sendNack()
            self.processResponseBytes(output)
        }
    }
    
    func send(message:NSData?,buffer:[UInt8]?){
        if (self.outputStream.hasSpaceAvailable){
            var bytesWritten = 0
            if(buffer != nil){
                bytesWritten = self.outputStream.write(UnsafePointer(buffer!), maxLength: buffer!.count)
            }
            else{
                bytesWritten = self.outputStream.write(UnsafePointer(message!.bytes), maxLength: message!.length)
            }
            
            if(bytesWritten == 0){
                print("error sending \(errno)")
            }
            
        } else {
            print("# stream busy")
        }
    }
    
    func consumeMessage(notif:NSNotification){
        let msg:Message = notif.userInfo!["message"] as! Message
        switch(msg.routingKey){
        case "internal.closerbaconnection":
            statemachine.set(RBAStates.Idle)
            self.hardReset()
            break
        case "internal.discovernetowrkswipers":
            let device:String = msg.params!["device"] as! String
            selfIP = msg.params!["selfip"] as! String
            if(device.caseInsensitiveCompare("ipp320") == NSComparisonResult.OrderedSame){
                var buf: Array<CChar> = Array(count: 7, repeatedValue: 0)
                //DISCOVERY PACKET
                buf[0] = 0x02;
                buf[1] = 0x35;
                buf[2] = 0x38;
                buf[3] = 0x2E;
                buf[4] = 0x30;
                buf[5] = 0x03;
                buf[6] = 0x10;
                //self.discovernetworkswipers(12000,discoveryPacket: buf)  //ingenico port is always 12000 ( go figure... )
            }
            break
        case "internal.acceptcard":
            let msg:String = msg.params!["displaymessage"] as! String
            self.initiateTransaction(msg)
            break
        case "internal.sendresponsetorba":
            self.sendEmvResponseToTerminal(msg.params as! NSDictionary)
            break
        case "internal.connectrba":
            self.connectToIngenico("192.168.100.118")
            break
        case "internal.txndetails":
            var amount:String = msg.params!["amount"] as! String
            amount = amount.stringByReplacingOccurrencesOfString(".", withString: "")
            let txnType:String = msg.params!["txntype"] as! String
            self.sendEMVTransactionTypeToTerminal(txnType)
            self.sendAmount(amount)
            break
        case "internal.amountconfirmed":
            var amount:String = msg.params!["amount"] as! String
            amount = amount.stringByReplacingOccurrencesOfString(".", withString: "")
            self.sendAmount(amount)
        default:
            break
        }
    }
    
    
    func stateChanged(newstate: RBAStates) {
        NSLog("stateChanged", "")
        
    }
    
    func foundDevices(devices: [AnyObject]) {
        NSLog("Found ingenico devices %@", devices)
        let msg:Message = Message(routKey: "internal.discovereddevices")
        msg.params = ["devices":devices]
        MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
        
        for device:NSDictionary in devices as! [NSDictionary]{
            self.connectToIngenico(device.objectForKey("ip") as! String)
        }
        
    }
    
    
    func initiateTransaction(data: String) {
        let str: String = "23.".stringByAppendingString(data)
        let msg: NSData = self.buildMessage(str)
        NSLog("%@", msg)
        self.send(msg,buffer: nil)
    }
    
    func sendEmvResponseToTerminal(response:NSDictionary){
        var str:String = "33.04.0000\u{1C}"
        let emvtags = response["emvTags"] as? NSDictionary
        var emvtagsarray:[[String:String]] = [[String:String]]()
        if(emvtags != nil){
            emvtagsarray = emvtags!["emvtags"] as! [[String:String]]
            for onetag:[String:String] in emvtagsarray{
                if(onetag["tag"]! == "8A"){
                    str += String(format: "T%@:%@:a%@",onetag["tag"]!,onetag["length"]!,onetag["value"]!)
                }
                else if(onetag["tag"]! == "91"){
                    str += String(format: "T%@:%@:h%@",onetag["tag"]!,onetag["length"]!,onetag["value"]!)
                }
                str += "\u{1C}"
            }
        }
        str += "\u{1C}"
        let msg: NSData = self.buildMessage(str)
        self.send(msg,buffer: nil)
    }
    
    func initiateEMVTransaction()
    {
        statemachine.set(RBAStates.TxnInitiated)
        NSLog("Initiated Smart EMV", "")
        var str = "33.00.0000"
        str += "\u{1C}\u{1C}\u{1C}"
        str += "\u{1C}\u{1C}"
        let msg: NSData  = self.buildMessage(str)
        self.send(msg,buffer: nil)
    }
    
    
    func sendEMVTransactionTypeToTerminal(txnType:String)
    {
        var str = "14."
        str += txnType
        let msg: NSData = self.buildMessage(str)
        self.send(msg,buffer: nil)
    }
    
    func sendPaymentRequestTypeToTerminal()
    {
        var str = "04.0"
        str += RBAProtocolConst.sharedRBAConstsInstance.creditCardType
        let msg: NSData = self.buildMessage(str)
        self.send(msg,buffer: nil)
    }
    
    func sendAmount(amount:String)
    {
        var str = "13."
        str += amount
        let msg: NSData = self.buildMessage(str)
        self.send(msg,buffer: nil)
    }
    
    
    func setavailability(running: Bool) {
        var data: NSData
        if running {
            data  = self.buildMessage("01.00000000")
        }
        else {
            data = self.buildMessage("00.00000000")
        }
        self.send(data,buffer: nil)
    }
    
    func requestTerminalStatus()
    {
        var str = "33.01.0000"
        str += "\u{1C}\u{1C}\u{1C}\u{1C}"
        let msg: NSData = self.buildMessage(str)
        self.send(msg,buffer: nil)
    }
    
    func buildMessage(text: String) -> NSData {
        //NSLog("MSG->OUT: %@", text)
        let bytes = self.stringToHex(text)
        let lrc = self.calculateLRC(bytes)
        var sendStr:String = "02"
        sendStr += bytes
        sendStr = sendStr.stringByAppendingFormat("%02x", lrc)
        let sendData = self.hexToBytes(sendStr)
        return sendData
    }
    
    func connectToIngenico(address:String) {
        /*NSString *thePath = [[NSBundle mainBundle] pathForResource:@"CLIENT2" ofType:@"p12"];
         NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
         CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;
         
         SecIdentityRef identity;
         // extract the ideneity from the certificate
         [self extractIdentity :inPKCS12Data :&identity];
         
         certificate = NULL;
         SecIdentityCopyCertificate (identity, &certificate);
         // this disables certificate chain validation in ssl settings.*/
        
        NSLog("Connecting to Ingenico %@", address)
        
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil,address,12000, &readStream, &writeStream)
        
        // Documentation suggests readStream and writeStream can be assumed to
        // be non-nil. If you believe otherwise, you can test if either is nil
        // and implement whatever error-handling you wish.
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        
        self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        self.inputStream.open()
        self.outputStream.open()
        //[self attachSSL];
    }
    
    
    func clearDisplay()
    {
        self.send(nil,buffer: RBAProtocolConst.sharedRBAConstsInstance.CLR_15)
    }
    
    func hardReset()
    {
        self.send(nil,buffer: RBAProtocolConst.sharedRBAConstsInstance.OFFLINE)
    }
    
    func processResponseBytes(output: String) {
        let byteArray = output.utf8
        let data: NSMutableData = NSMutableData()
        for value in byteArray{
            if(value == 0x02){
                //message start flag
            }
            else{
                var int:UInt32 = UInt32(value)
                data.appendBytes(&int, length: 1)
            }
        }
        
        let newstring = String(data: data, encoding: NSUTF8StringEncoding)!
        NSLog("MSG->IN: %@", newstring)
        
        let cmdrange = Range(start: newstring.startIndex, end: newstring.startIndex.advancedBy(2))
        let cmd:String = newstring.substringWithRange(cmdrange)
        let command:Int = Int(cmd)!
        
        if newstring.rangeOfString("23.0S") != nil {
            self.clearDisplay()
            self.initiateEMVTransaction()
            return;
        }
        else if(newstring.rangeOfString("23.1S") != nil) {
            NSLog("BAD EMV CARD", "")
            self.hardReset()
            return;
        }
        else if(cmd.caseInsensitiveCompare("04") == NSComparisonResult.OrderedSame){
            statemachine.set(RBAStates.TxnWaitingForUserAmountConfirmation)
            let msg:Message = Message(routKey: "internal.confirmamountrequest")
            MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
            return
        }
        else if(cmd.caseInsensitiveCompare("00") == NSComparisonResult.OrderedSame){
            NSLog("Offline Response Message %@", newstring)
            return
        }
        
        
        switch command {
        case 1:
            break
        case 9:
  
            if(output.rangeOfString("09.020201R") != nil){
                NSLog("Card removed", "")
                self.clearDisplay()
                self.hardReset()
            }
        case 4:
            statemachine.set(RBAStates.TxnInitiated)
            let msg:Message = Message(routKey: "internal.confirmamountrequest")
            MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
        case 7:
        break
        //self.lblOutput.text = [@"Terminal stats: " stringByAppendingString:output];
        case 10:
            NSLog("User cancelled transaction", "")
            statemachine.set(RBAStates.TxnCancelled)
            self.hardReset()
        case 33:
            var subcommand = 0
            let subcmdrange = Range(start:newstring.startIndex.advancedBy(4), end: newstring.startIndex.advancedBy(6))
            let subcmd: String = output.substringWithRange(subcmdrange)
            subcommand = Int(subcmd)!
            switch subcommand {
            case 0:
                let msg:Message = Message(routKey: "internal.emviniitated")
                MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
                break
            case 1:
                break
            case 2:
                self.sendPaymentRequestTypeToTerminal()
            case 3:
                statemachine.set(RBAStates.TxnAuthorizing)
                self.parseEMVCardData(output,messagetype: RBAProtocolConst.sharedRBAConstsInstance.AuthorizationRequestMessage)
            case 5:
                if(statemachine.get() == RBAStates.TxnAuthorizing){
                    statemachine.set(RBAStates.TxnAuthorized)
                    self.parseEMVCardData(output,messagetype: RBAProtocolConst.sharedRBAConstsInstance.AuthorizationConfirmationResponseMessage)
                    self.hardReset()
                }
                else{
                    NSLog("33.05 with invalid state", "")
                }
            default:
                break
            }
        case 23:
            let range = Range(start: output.startIndex.advancedBy(5), end: output.endIndex.advancedBy(-7))
            let carddata = output.substringWithRange(range)
            self.parseCardData(carddata)
            break
        case 50:
            //NSLog("Card swiped %@", output.substringWithRange(NSMakeRange(5, ln - 6)))
            //self.parseCardData(output.substringWithRange(NSMakeRange(2, ln - 3)))
            break
        case 29:
            //NSLog("Card data %@", output.substringWithRange(NSMakeRange(12, ln - 13)))
            break
        default:
            NSLog("default- not handled.")
        }
        
    }
    
    
    
    func parseEMVCardData(param:String, messagetype:String)
    {
        let components = param.componentsSeparatedByString("\u{1C}")
        var tags:[NSString:AnyObject] = [NSString:AnyObject]()
        
        var arrayOfTagsToSend:[[String:String]] = [[String:String]]()
        
        var i = 0
        for nstr:NSString in components{
            var matched:[String]? = nstr.componentsSeparatedByString(":")
            if(matched != nil && matched!.count > 1 && matched![0].substringToIndex(matched![0].startIndex.advancedBy(1)) == "T"){
                var emvtag = EMVTags()
                emvtag.tagfullid = matched![0]
                emvtag.tagshortid = matched![0].substringFromIndex(matched![0].startIndex.advancedBy(1))
                emvtag.taglen = matched![1]
                
                
                var value:NSString = matched![2]
                
                let key:NSString = matched![0]
                if(value.substringToIndex(1) == "a" || value.substringToIndex(1) == "h"){
                    value = value.substringFromIndex(1)
                    matched![2] = value as String
                }
                
                emvtag.tagdata = value as String
                arrayOfTagsToSend.append(emvtag.tagToDic())
                
                if(key.caseInsensitiveCompare(RBAProtocolConst.sharedRBAConstsInstance.emvTrack2Data) == NSComparisonResult.OrderedSame){
                    let emvtrack = value.componentsSeparatedByString("=")
                    var expdate = emvtrack[1] as! NSString
                    expdate = expdate.substringToIndex(4)
                    tags[RBAProtocolConst.sharedRBAConstsInstance.ExpirationDate] = expdate
                }
                else if(key.caseInsensitiveCompare(RBAProtocolConst.sharedRBAConstsInstance.track3Data) == NSComparisonResult.OrderedSame){
                    tags[RBAProtocolConst.sharedRBAConstsInstance.track3Data] = [matched![2],matched![4],matched![5]]
                }
                if(tags[key] == nil){
                    tags[key] = value
                }
            }
        }
        
        if(tags.count > 0){
            NSLog("%@", tags)
            //send data to emv switch
            let msg:Message = Message(routKey: "internal.carddata")
            let st = NSNumber(integer: statemachine.get().rawValue)
            msg.params = ["carddata":tags,"emvtags":arrayOfTagsToSend,"messagetype":messagetype,"currentstate":st]
            MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
        }
    }
    
    
    func parseCardData(param:String)
    {
        let byteArray = param.utf8
        let data: NSMutableData = NSMutableData()
        var source:UInt32 = 0
        
        var cardData:[String:String] = [String:String]()
        
        for value in byteArray{
            source = UInt32(value)
            break
        }
        
        if (source == 0x63 || source == 0x43)
        {
            cardData["Source"] = "Contacless"
        }
        else if(source == 0x4d || source == 0x4d)
        {
            cardData["Source"] = "Magstripe"
        }
        else if(source == 0x35)
        {
            cardData["Source"] = "ApplePay"
            /*
             NSDictionary *applepayData = [self parseApplePay:parm];
             [cardDat addEntriesFromDictionary:applepayData];
             return cardData
             */
        }
        
        if (source != 0x35)
        {
            var tracks = param.componentsSeparatedByString("\u{1C}")
            if(param.characters.count > 12 && param.characters.count < 30){
                if(tracks.count > 0){
                    cardData["Data"] = tracks[1]
                }
            }
            else if((tracks[1] + tracks[2]).characters.count > 50){
                let track2 = tracks[1] + tracks[2]
                let p2pestr = tracks[2]
                let track1data = self.parseTrack1(tracks[0])
                print(track1data)
                let track2data = self.parseTrack2(track2)
                print(track2data)
            }
            else{
                let track1data = self.parseTrack1(tracks[0])
                let track2data = self.parseTrack2(tracks[1] + tracks[2])
                print(track1data)
                print(track2data)
            }
        }
    }
    
    
    func parseTrack2(track2:String) -> [String : String]
    {
        var track2Data:[String : String] = [String : String]()
        
        if (track2.characters.count > 0)
        {
            let accountNumber = track2.substringToIndex((track2.rangeOfString("=")?.startIndex)!)
            var range:Range = Range(start: (track2.rangeOfString("=")?.startIndex.advancedBy(1))!, end:(track2.rangeOfString("=")?.startIndex.advancedBy(4))!)
            let expirationDate = track2.substringWithRange(range)
            range = Range(start: (track2.rangeOfString("=")?.startIndex)!.advancedBy(5), end: (track2.rangeOfString("=")?.startIndex)!.advancedBy(5+3))
            let serviceCode = track2.substringWithRange(range)
            range = Range(start: (track2.rangeOfString("=")?.startIndex)!.advancedBy(8), end: (track2.rangeOfString("=")?.startIndex)!.advancedBy(8+5))
            let pvv = track2.substringWithRange(range)
            
            range = Range(start: (track2.rangeOfString("=")?.startIndex)!.advancedBy(13), end: track2.endIndex)
            let discretionaryData = track2.substringWithRange(range)
            
            track2Data = [
                "Track2Data" : track2,
                "AccountNumber" : accountNumber,
                "ExpirationDate" : expirationDate,
                "ServiceCode" : serviceCode,
                "PVV" : pvv,
                "DiscretionaryData" : discretionaryData]
        }
        
        return track2Data
    }
    
    
    
    
    func parseTrack1(track1: String) -> [String : String] {
        var track1Data: [String : String]?
        if track1.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            let components = track1.componentsSeparatedByString("^")
            var range = Range(start: track1.startIndex.advancedBy(2), end: (track1.rangeOfString("^")?.startIndex)!)
            let accountNumber: String = components[0]
            let name : String = components[1]
            let restdata : String = components[2]
            
            let restcomps = restdata.componentsSeparatedByString("\u{1C}")
            var expirationDate: String = ""
            
            range = Range(start: restcomps[0].startIndex, end: restcomps[0].startIndex.advancedBy(4))
            expirationDate =  restcomps[0].substringWithRange(range)
            
            range = Range(start: restcomps[0].startIndex.advancedBy(4), end: restcomps[0].startIndex.advancedBy(7))
            let serviceCode = restcomps[0].substringWithRange(range)
            var fnamlastname = name.componentsSeparatedByString("/")
            
            let lastName: String = fnamlastname[0]
            let firstName: String = fnamlastname[1]
            
            track1Data = ["Track1Data": track1, "AccountNumber": accountNumber, "ExpirationDate": expirationDate, "ServiceCode": serviceCode, "Name": name, "LastName": lastName, "FirstName": firstName]
        }
        return track1Data!
    }
    
    
}

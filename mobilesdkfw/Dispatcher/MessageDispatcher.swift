//
//  MessageDispatcher.swift
//  POS
//
//  Created by Gal Blank on 1/15/16.
//

import UIKit

public class MessageDispatcher:NSObject {
    
    public static let sharedDispacherInstance = MessageDispatcher()
    
    var dispsatchTimer:NSTimer?
    var messageBus:[Message] = [Message]()
    var dispatchedMessages:[Message] = [Message]()
    struct Static {
        static var token: dispatch_once_t = 0
    }
    
    func consumeMessage(notif:NSNotification){
        let msg:Message = notif.userInfo!["message"] as! Message
        switch(msg.routingKey){
        case "msg.selfdestruct":
            let Index = messageBus.indexOf(msg)
            if(Index >= 0){
                messageBus.removeAtIndex(Index!)
            }
            break
        default:
            break
        }
    }
    
    public func addMessageToBus(newmessage: Message) {
        if(newmessage.shouldselfdestruct == false && newmessage.routingKey.caseInsensitiveCompare("msg.selfdestruct") == NSComparisonResult.OrderedSame)
        {
            let index:Int = messageBus.indexOf(newmessage)!
            if(index >= 0 ){
                messageBus.removeAtIndex(index)
            }
        }
        
        messageBus.append(newmessage)
        dispatch_once(&Static.token) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.dispsatchTimer == nil {
                    self.startDispatching()
                }
            })
            
        }
    }
    
    func clearDispastchedMessages() {
        for msg:Message in dispatchedMessages {
            let Index = messageBus.indexOf(msg)
            if(Index >= 0){
                messageBus.removeAtIndex(Index!)
            }
        }
        dispatchedMessages.removeAll()
    }
    
    
    func startDispatching() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "consumeMessage:", name: "msg.selfdestruct", object: nil)
        dispsatchTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "leave", userInfo: nil, repeats: true)
    }
    
    func stopDispathing() {
        if dispsatchTimer != nil {
            dispsatchTimer!.invalidate()
            dispsatchTimer = nil
        }
    }
    
    func leave() {
        let goingAwayBus:[Message] = NSArray(array: messageBus) as! [Message]
        for msg: Message in goingAwayBus {
            if(msg.shouldselfdestruct == false){
                self.dispatchMessage(msg)
                msg.shouldselfdestruct = true
                let index:Int = messageBus.indexOf(msg)!
                if(index != NSNotFound){
                    messageBus.removeAtIndex(index)
                }
            }
            
        }
    }
    
    func dispatchMessage(message: Message) {
        var messageDic: [NSObject : AnyObject] = [NSObject : AnyObject]()
        messageDic["message"] = message
        NSNotificationCenter.defaultCenter().postNotificationName(message.routingKey, object: nil, userInfo: messageDic)
    }
    
    func routeMessageToServerWithType(message: Message) {
        if message.params == nil {
            message.params? = [NSObject : AnyObject]()
        }
        let sectoken: String? = NSUserDefaults.standardUserDefaults().objectForKey("securitytoken") as? String
        if sectoken != nil && sectoken?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            message.params?.setObject(sectoken, forKey: "securitytoken")
        }
    }
    
    func canSendMessage(message: Message) -> Bool {
        return true
    }
}
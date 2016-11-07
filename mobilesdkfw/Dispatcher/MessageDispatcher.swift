//
//  MessageDispatcher.swift
//  POS
//
//  Created by Gal Blank on 1/15/16.
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

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
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


open class MessageDispatcher:NSObject {
    
    open var dispsatchTimer:Timer?
    open var messageBus:[Message] = [Message]()
    open var dispatchedMessages:[Message] = [Message]()
    
    private static var __once: () = { () -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if MessageDispatcher.sharedDispacherInstance.dispsatchTimer == nil {
                    MessageDispatcher.sharedDispacherInstance.startDispatching()
                }
            })
            
        }()
    
    open static let sharedDispacherInstance = MessageDispatcher()
    
    open let wtchdog = Watchdog.sharedInstance
    
    
    struct Static {
        static var token: Int = 0
    }
    
    open func consumeMessage(_ notif:Notification){
        let msg:Message = (notif as NSNotification).userInfo!["message"] as! Message
        switch(msg.routingKey){
        case "msg.selfdestruct":
            let Index = messageBus.index(of: msg)
            if(Index >= 0){
                messageBus.remove(at: Index!)
            }
            break
        default:
            break
        }
    }
    
    open func addMessageToBus(_ newmessage: Message) {
        if(newmessage.shouldselfdestruct == false && newmessage.routingKey.caseInsensitiveCompare("msg.selfdestruct") == ComparisonResult.orderedSame)
        {
            let index:Int = messageBus.index(of: newmessage)!
            if(index >= 0 ){
                messageBus.remove(at: index)
            }
        }
        
        messageBus.append(newmessage)
        _ = MessageDispatcher.__once
    }
    
    open func clearDispastchedMessages() {
        for msg:Message in dispatchedMessages {
            let Index = messageBus.index(of: msg)
            if(Index >= 0){
                messageBus.remove(at: Index!)
            }
        }
        dispatchedMessages.removeAll()
    }
    
    
    open func startDispatching() {
        NotificationCenter.default.addObserver(self, selector: #selector(MessageDispatcher.consumeMessage(_:)), name: NSNotification.Name(rawValue: "msg.selfdestruct"), object: nil)
        dispsatchTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MessageDispatcher.leave), userInfo: nil, repeats: true)
    }
    
    open func stopDispathing() {
        if dispsatchTimer != nil {
            dispsatchTimer!.invalidate()
            dispsatchTimer = nil
        }
    }
    
    open func leave() {
        let goingAwayBus:[Message] = NSArray(array: messageBus) as! [Message]
        for msg: Message in goingAwayBus {
            if(msg.shouldselfdestruct == false){
                self.dispatchMessage(msg)
                msg.shouldselfdestruct = true
                let index:Int = messageBus.index(of: msg)!
                if(index != NSNotFound){
                    messageBus.remove(at: index)
                }
            }
            
        }
    }
    
    open func dispatchMessage(_ message: Message) {
        var messageDic: [AnyHashable: Any] = [AnyHashable: Any]()
        messageDic["message"] = message
        if(message.routingKey == "api.*"){
            //make sure comms are initialized
            //CommManager.sharedCommSingletonDelegate
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: message.routingKey), object: nil, userInfo: messageDic)
    }
    
    open func routeMessageToServerWithType(_ message: Message) {
        if message.params == nil {
            message.params? = [AnyHashable: Any]() as AnyObject
        }
        let sectoken: String? = UserDefaults.standard.object(forKey: "securitytoken") as? String
        if sectoken != nil && sectoken?.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            message.params?.set(sectoken, forKey: "securitytoken")
        }
    }
    
    open func canSendMessage(_ message: Message) -> Bool {
        return true
    }
}

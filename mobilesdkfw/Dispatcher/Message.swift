//
//  Message.swift
//  POS
//
//  Created by Gal Blank on 1/27/16.
//  Copyright © 2016 1stPayGateway. All rights reserved.
//

import UIKit

public class Message:NSObject {
    public var routingKey:String = String("")
    public var httpMethod:String = String("")
    public var passthruAPI:String = String("")
    public var passthruParams:AnyObject?
    public var callBackPoint:String = String("")
    public var authtoken:String = String("")
    public var params:AnyObject?
    public var ttl:Float = 0.1
    public var shouldselfdestruct:Bool = false
    public init(routKey:String) {
        super.init()
        self.routingKey = routKey
    }
    
    
    public func routeFromRoutingKey() -> String {
        var keyitems:[AnyObject]? = self.routingKey.componentsSeparatedByString(".")
        if keyitems != nil {
            return keyitems![0] as! String
        }
        return ""
    }
    
    public func messageFromRoutingKey() -> String {
        let keyitems:[AnyObject]? = self.routingKey.componentsSeparatedByString(".")
        if keyitems != nil {
            return (keyitems?.last)! as! String
        }
        return ""
    }
    
    public func selfDestruct()
    {
        routingKey = "msg.selfdestruct"
        MessageDispatcher.sharedDispacherInstance.addMessageToBus(self)
    }
}
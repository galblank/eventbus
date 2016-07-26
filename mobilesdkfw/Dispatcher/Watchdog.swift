//
//  Watchdog.swift
//  mobilesdkfw
//
//  Created by Blank, Gal (Contractor) on 7/26/16.
//  Copyright © 2016 PeopleLinx. All rights reserved.
//

import UIKit

public class Watchdog: NSObject {

    public static let sharedInstance = Watchdog()
    
    public var dispsatchTimer:NSTimer?

    struct Static {
        static var token: dispatch_once_t = 0
    }
    
    
    public func registerSelf(anytype:AnyObject)
    {
        
    }
    
}

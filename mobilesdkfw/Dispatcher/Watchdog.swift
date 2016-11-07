//
//  Watchdog.swift
//  mobilesdkfw
//
//  Created by Blank, Gal (Contractor) on 7/26/16.
//  Copyright © 2016 PeopleLinx. All rights reserved.
//

import UIKit

open class Watchdog: NSObject {

    open static let sharedInstance = Watchdog()
    
    open var dispsatchTimer:Timer?

    struct Static {
        static var token: Int = 0
    }
    
    
    open func registerSelf(_ anytype:AnyObject)
    {
        
    }
    
}

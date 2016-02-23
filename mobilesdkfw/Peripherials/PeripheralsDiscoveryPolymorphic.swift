//
//  PeripheralsDiscoveryPolymorphic.swift
//  POS
//
//  Created by Gal Blank on 1/13/16.
//  Gal Blank All rights reserved.
//

import Foundation

class PeripheralDiscoveryPolymorphic: NSObject {
    
    var connectedAccessories = [AnyObject]()
    
    var entitledHardware: NSDictionary?
    
    func consumeMessage(notif:NSNotification){}
    
}
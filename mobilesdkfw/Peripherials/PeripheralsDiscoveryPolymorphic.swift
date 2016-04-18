//
//  PeripheralsDiscoveryPolymorphic.swift
//  POS
//
//  Created by Gal Blank on 1/13/16.
//  Copyright © 2016 1stPayGateway. All rights reserved.
//

import Foundation

class PeripheralDiscoveryPolymorphic: NSObject {
    
    var connectedAccessories = [AnyObject]()
    
    var entitledHardware: NSDictionary?
    
    func consumeMessage(notif:NSNotification){}
    
}
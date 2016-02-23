//
//  PolymorphicScannerService.swift
//  POS
//
//  Created by Gal Blank on 12/15/15.
//  Gal Blank. All rights reserved.
//

import UIKit
import Foundation

public class PolymorphicSwiperService: NSObject,NSNetServiceBrowserDelegate,NSNetServiceDelegate {

    
    public static let sharedSwiperServiceInstance = PolymorphicSwiperService()
    
    
    var netServiceBrowser = NSNetServiceBrowser()
    
    var services = [NSNetService]()
    var index:Int = 0
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "consumeMessage:", name:"internal.discovernetowrkswipers", object: nil)
    }
    
    func consumeMessage(notif:NSNotification){
        let msg:Message = notif.userInfo!["message"] as! Message
        switch(msg.routingKey){
        case "internal.discovernetowrkswipers":
            self.discoverswipers()
            break
        default:
            break
        }
    }
    
    
    func discoverswipers(){
        self.netServiceBrowser.includesPeerToPeer = true
        self.netServiceBrowser.delegate = self
        //self.netServiceBrowser.searchForBrowsableDomains()
        self.netServiceBrowser.searchForServicesOfType("_services._dns-sd._udp.", inDomain: "local.")
    }
    
    public func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        NSLog("Domain %@", domainString)
    }
    
    public func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        //prepare the start of the search
    }
    
    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        //Find a service, remember that after that you have to resolve the service to know the address
        NSLog("%@", aNetService.name)
        NSLog("%@", aNetService.type)
        NSLog("%d", aNetService.port)
        if(moreComing == false){
            NSLog("Found all services on network", "")
            self.netServiceBrowser.stop()
            let oneservice:NSNetService = services[index]
            oneservice.delegate = self
            oneservice.resolveWithTimeout(5)
        }
        else{
            services.append(aNetService)
        }

    }
    
    public func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        //NSLog("didNotSearch", "")
    }
    

    public func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        NSLog("netServiceBrowserDidStopSearch", "")
    }
    
    
    public func netServiceDidResolveAddress(sender: NSNetService) {
        NSLog("netServiceDidResolveAddress", "")
    }
    

    
    /*func getStringFromAddressData(dataIn: NSData) -> String {
        //Function to parse address from NSData
        var socketAddress: structsockaddr_in? = nil
        var ipString: String? = nil
        socketAddress = dataIn.bytes() as! structsockaddr_in
        ipString = "\(inet_ntoa(socketAddress->sin_addr))"
        ///problem here
        return ipString!
    }
    
   
    */
}

//
//  PolymorphicScannerService.swift
//  POS
//
//  Created by Gal Blank on 12/15/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

import UIKit
import Foundation
import CFNetwork

public class PolymorphicSwiperService: NSObject {
    
    var listeningSocket:CInt = 0
    /// The address family of the UDP socket.
    var addressFamily: Int32 = AF_UNSPEC
    
    /// A dispatch source for reading data from the UDP socket.
    var responseSource: dispatch_source_t?
    var deviceIp:String = ""
    var deviceMAC:String = ""
    
    var devicesArray:Observable<[AnyObject]> =  Observable<[AnyObject]>([])
    
    var selfIP:String = ""
    
    var index:Int = 0
    
    func initStruct<S>() -> S {
        let struct_pointer = UnsafePointer<S>(bitPattern: 1)
        let struct_memory = struct_pointer.memory
        return struct_memory
    }
    
    
    func sockaddr_cast(p: UnsafePointer<sockaddr_in>) -> UnsafePointer<sockaddr> {
        return UnsafePointer<sockaddr>(p)
    }
    
    func socklen_t_cast(p: UnsafePointer<Int>) -> UnsafePointer<socklen_t> {
        return UnsafePointer<socklen_t>(p)
    }
    
    func discovernetworkswipers(port:UInt16,discoveryPacket:Array<CChar>)
    {
        NSLog("Dispaching broadcast message", "")
        listeningSocket = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)
        if (listeningSocket <= 0) {
            NSLog("Error: Could not open socket.")
            return
        }
        
        // set socket options enable broadcast
        var broadcastEnable:UInt32 = 1;
        let ret = setsockopt(listeningSocket, SOL_SOCKET,SO_BROADCAST, &broadcastEnable, socklen_t(sizeofValue(broadcastEnable)))
        if (ret != 0) {
            NSLog("Error: Could not set socket to broadcast mode")
            close(listeningSocket)
            return
        }
        
        
        
        var  broadcastAddr:sockaddr_in = sockaddr_in()
        broadcastAddr.sin_family = sa_family_t(AF_INET)
        broadcastAddr.sin_port = htons(port)
        broadcastAddr.sin_addr.s_addr = UInt32(0x00000000)    //INADDR_ANY = (u_int32_t)0x00000000 ----- <netinet/in.h>
        let status = bind(listeningSocket, sockaddr_cast(&broadcastAddr), socklen_t(sizeofValue(broadcastAddr)))
        
        
        if(status == -1){
            NSLog("bind error %d",errno)
            return
        }
        else{
            // receive
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                var socketAddress = sockaddr_storage()
                var socketAddressLength = socklen_t(sizeof(sockaddr_storage.self))
                
                var response: Array<CChar> = Array(count: 1024, repeatedValue: 0)
                while(true)
                {
                    NSLog("Listenning...", "")
                    let bytesRead = withUnsafeMutablePointer(&socketAddress) {
                        
                        recvfrom(self.listeningSocket, UnsafeMutablePointer<Void>(response), response.count, 0, UnsafeMutablePointer($0), &socketAddressLength)
                        
                    }
                    
                    guard bytesRead >= 0 else {
                        if let errorString = String(UTF8String: strerror(errno)) {
                            NSLog("recvfrom failed: \(errorString)")
                        }
                        return
                    }
                    
                    guard bytesRead > 0 else {
                        NSLog("recvfrom returned EOF")
                        return
                    }
                    
                    guard let endpoint = withUnsafePointer(&socketAddress, { self.getEndpointFromSocketAddress(UnsafePointer($0)) }) else {
                        NSLog("Failed to get the address and port from the socket address received from recvfrom")
                        return
                    }
                    
                    if(self.selfIP.caseInsensitiveCompare(endpoint.host) == NSComparisonResult.OrderedSame){
                        NSLog("received data from self, ignoring", "")
                        continue
                    }
                    
                    let resultData = NSData(bytes: UnsafePointer<Void>(response), length: bytesRead)
                    
                    let resultString = NSString(data: resultData, encoding: NSUTF8StringEncoding)!
                    
                    NSLog("%@",resultString)
                    var msg:String = "";
                    
                    
                    for(var i=0;i<bytesRead;i++){
                        let c:Int32 = Int32(response[i])
                        if((c == 46 || c == 58) || (response[i] != 0x02 && response[i] != 0x03 && isxdigit(c) != 0)){ //46 - . ( dot ), 58 - :
                            msg = msg.stringByAppendingFormat("%c", response[i])
                        }
                        else if(msg.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0){
                            msg = msg.stringByAppendingString("|")
                        }
                    }
                    NSLog("%@", msg)
                    self.didReceiveMessage(msg, fromAddress: endpoint.host)
                }
            })
        }
        
        
        
        
        let serverAddress = SocketAddress()
        serverAddress.setFromString("255.255.255.255")
        serverAddress.setPort(Int(port))
        
        let sent = withUnsafePointer(&serverAddress.sin) {
            sendto(listeningSocket, discoveryPacket,Int(strlen(discoveryPacket)), 0, UnsafePointer($0), socklen_t(serverAddress.sin.sin_len))
        }
        
        if (sent < 0) {
            if let errorString = String(UTF8String: strerror(errno)) {
                NSLog("send failed: \(errorString)")
            }
        }
    }
    
    
    /// Convert a sockaddr structure into an IP address string and port.
    func getEndpointFromSocketAddress(socketAddressPointer: UnsafePointer<sockaddr>) -> (host: String, port: Int)? {
        let socketAddress = UnsafePointer<sockaddr>(socketAddressPointer).memory
        
        switch Int32(socketAddress.sa_family) {
        case AF_INET:
            var socketAddressInet = UnsafePointer<sockaddr_in>(socketAddressPointer).memory
            let length = Int(INET_ADDRSTRLEN) + 2
            var buffer = [CChar](count: length, repeatedValue: 0)
            let hostCString = inet_ntop(AF_INET, &socketAddressInet.sin_addr, &buffer, socklen_t(length))
            let port = Int(UInt16(socketAddressInet.sin_port).byteSwapped)
            return (String.fromCString(hostCString)!, port)
            
        case AF_INET6:
            var socketAddressInet6 = UnsafePointer<sockaddr_in6>(socketAddressPointer).memory
            let length = Int(INET6_ADDRSTRLEN) + 2
            var buffer = [CChar](count: length, repeatedValue: 0)
            let hostCString = inet_ntop(AF_INET6, &socketAddressInet6.sin6_addr, &buffer, socklen_t(length))
            let port = Int(UInt16(socketAddressInet6.sin6_port).byteSwapped)
            return (String.fromCString(hostCString)!, port)
            
        default:
            return nil
        }
    }
    
    func didReceiveMessage(message: String, fromAddress address: String) {
        if message.containsString("58.") {
            var ingenicoDetails: [AnyObject] = message.componentsSeparatedByString("|")
            if ingenicoDetails.count > 1 {
                let device = ["mac":ingenicoDetails[1] as! String,"ip":ingenicoDetails[2] as! String]
                var devices = devicesArray.get()
                devices.append(device)
                devicesArray.set(devices)
                NSLog("Ingenico: %@", ingenicoDetails)
            }
        }
        NSLog("didReceiveMessage: %@ from %@", message, address)
    }
    
    func stringToHex(str: String) -> String {
        var hexBits = "" as String
        let byteArray = str.utf8
        for value in byteArray{
            hexBits += NSString(format:"%2x", value) as String
        }
        hexBits += "03"
        return hexBits
    }
    
    
    func calculateLRC(text: String) -> UInt8 {
        let data:NSData = self.hexToBytes(text)
        var buffer = [UInt8](count: data.length, repeatedValue: 0x0)
        data.getBytes(&buffer, length: data.length)
        var lrc:UInt8 = 0
        
        for char:UInt8 in buffer{
            lrc = lrc ^ char
        }

        
        return lrc
    }
    
    func hexToBytes(hexaStr: String) -> NSData {
        let data: NSMutableData = NSMutableData()
        var idx: Int = 0
        let byteArray = hexaStr.utf8
        for idx = 0; idx + 2 <= byteArray.count; idx += 2 {
            let hexStrTmp: String = hexaStr.substringWithRange(Range(start: hexaStr.startIndex.advancedBy(idx), end: hexaStr.startIndex.advancedBy(idx+2)))
            let scanner = NSScanner(string: hexStrTmp)
            var intValue = UInt32()
            if(scanner.scanHexInt(&intValue) == true){
                data.appendBytes(&intValue, length: 1)
            }
        }
        return data
    }
    
}

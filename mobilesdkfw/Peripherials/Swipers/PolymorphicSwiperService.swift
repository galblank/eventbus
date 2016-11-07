//
//  PolymorphicScannerService.swift
//  POS
//
//  Created by Gal Blank on 12/15/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

import UIKit
import Foundation
import CFNetwork

open class PolymorphicSwiperService: NSObject {
    
    var listeningSocket:CInt = 0
    /// The address family of the UDP socket.
    var addressFamily: Int32 = AF_UNSPEC
    
    /// A dispatch source for reading data from the UDP socket.
    var responseSource: DispatchSource?
    var deviceIp:String = ""
    var deviceMAC:String = ""
    
    var devicesArray:Observable<[AnyObject]> =  Observable<[AnyObject]>([])
    
    var selfIP:String = ""
    
    var index:Int = 0
    
    func initStruct<S>() -> S {
        let struct_pointer = UnsafePointer<S>(bitPattern: 1)
        let struct_memory = struct_pointer?.pointee
        return struct_memory!
    }
    
    
    func sockaddr_cast(_ p: UnsafePointer<sockaddr_in>) -> UnsafePointer<sockaddr> {
        return UnsafePointer<sockaddr>(p)
    }
    
    func socklen_t_cast(_ p: UnsafePointer<Int>) -> UnsafePointer<socklen_t> {
        return UnsafePointer<socklen_t>(p)
    }
    
    func discovernetworkswipers(_ port:UInt16,discoveryPacket:Array<CChar>)
    {
        NSLog("Dispaching broadcast message", "")
        listeningSocket = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)
        if (listeningSocket <= 0) {
            NSLog("Error: Could not open socket.")
            return
        }
        
        // set socket options enable broadcast
        var broadcastEnable:UInt32 = 1;
        let ret = setsockopt(listeningSocket, SOL_SOCKET,SO_BROADCAST, &broadcastEnable, socklen_t(MemoryLayout.size(ofValue: broadcastEnable)))
        if (ret != 0) {
            NSLog("Error: Could not set socket to broadcast mode")
            close(listeningSocket)
            return
        }
        
        
        
        var  broadcastAddr:sockaddr_in = sockaddr_in()
        broadcastAddr.sin_family = sa_family_t(AF_INET)
        broadcastAddr.sin_port = htons(port)
        broadcastAddr.sin_addr.s_addr = UInt32(0x00000000)    //INADDR_ANY = (u_int32_t)0x00000000 ----- <netinet/in.h>
        let status = bind(listeningSocket, sockaddr_cast(&broadcastAddr), socklen_t(MemoryLayout.size(ofValue: broadcastAddr)))
        
        
        if(status == -1){
            NSLog("bind error %d",errno)
            return
        }
        else{
            // receive
            DispatchQueue.global(priority: 0).async(execute: { () -> Void in
                var socketAddress = sockaddr_storage()
                var socketAddressLength = socklen_t(sizeof(sockaddr_storage.self))
                
                var response: Array<CChar> = Array(repeating: 0, count: 1024)
                while(true)
                {
                    NSLog("Listenning...", "")
                    let bytesRead = withUnsafeMutablePointer(to: &socketAddress) {
                        
                        recvfrom(self.listeningSocket, UnsafeMutableRawPointer(response), response.count, 0, UnsafeMutablePointer($0), &socketAddressLength)
                        
                    }
                    
                    guard bytesRead >= 0 else {
                        if let errorString = String(validatingUTF8: strerror(errno)) {
                            NSLog("recvfrom failed: \(errorString)")
                        }
                        return
                    }
                    
                    guard bytesRead > 0 else {
                        NSLog("recvfrom returned EOF")
                        return
                    }
                    
                    guard let endpoint = withUnsafePointer(to: &socketAddress, { self.getEndpointFromSocketAddress(UnsafePointer($0)) }) else {
                        NSLog("Failed to get the address and port from the socket address received from recvfrom")
                        return
                    }
                    
                    if(self.selfIP.caseInsensitiveCompare(endpoint.host) == ComparisonResult.orderedSame){
                        NSLog("received data from self, ignoring", "")
                        continue
                    }
                    
                    let resultData = Data(bytes: UnsafePointer<UInt8>(UnsafeRawPointer(response)), count: bytesRead)
                    
                    let resultString = NSString(data: resultData, encoding: String.Encoding.utf8)!
                    
                    NSLog("%@",resultString)
                    var msg:String = "";
                    
                    
                    for(var i=0;i<bytesRead;i++){
                        let c:Int32 = Int32(response[i])
                        if((c == 46 || c == 58) || (response[i] != 0x02 && response[i] != 0x03 && isxdigit(c) != 0)){ //46 - . ( dot ), 58 - :
                            msg = msg.stringByAppendingFormat("%c", response[i])
                        }
                        else if(msg.lengthOfBytes(using: String.Encoding.utf8) > 0){
                            msg = msg + "|"
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
        
        let sent = withUnsafePointer(to: &serverAddress.sin) {
            sendto(listeningSocket, discoveryPacket,Int(strlen(discoveryPacket)), 0, UnsafePointer($0), socklen_t(serverAddress.sin.sin_len))
        }
        
        if (sent < 0) {
            if let errorString = String(validatingUTF8: strerror(errno)) {
                NSLog("send failed: \(errorString)")
            }
        }
    }
    
    
    /// Convert a sockaddr structure into an IP address string and port.
    func getEndpointFromSocketAddress(_ socketAddressPointer: UnsafePointer<sockaddr>) -> (host: String, port: Int)? {
        let socketAddress = UnsafePointer<sockaddr>(socketAddressPointer).pointee
        
        switch Int32(socketAddress.sa_family) {
        case AF_INET:
            var socketAddressInet = UnsafePointer<sockaddr_in>(socketAddressPointer).pointee
            let length = Int(INET_ADDRSTRLEN) + 2
            var buffer = [CChar](repeating: 0, count: length)
            let hostCString = inet_ntop(AF_INET, &socketAddressInet.sin_addr, &buffer, socklen_t(length))
            let port = Int(UInt16(socketAddressInet.sin_port).byteSwapped)
            return (String(cString: hostCString!), port)
            
        case AF_INET6:
            var socketAddressInet6 = UnsafePointer<sockaddr_in6>(socketAddressPointer).pointee
            let length = Int(INET6_ADDRSTRLEN) + 2
            var buffer = [CChar](repeating: 0, count: length)
            let hostCString = inet_ntop(AF_INET6, &socketAddressInet6.sin6_addr, &buffer, socklen_t(length))
            let port = Int(UInt16(socketAddressInet6.sin6_port).byteSwapped)
            return (String(cString: hostCString!), port)
            
        default:
            return nil
        }
    }
    
    func didReceiveMessage(_ message: String, fromAddress address: String) {
        if message.contains("58.") {
            var ingenicoDetails: [AnyObject] = message.components(separatedBy: "|")
            if ingenicoDetails.count > 1 {
                let device = ["mac":ingenicoDetails[1] as! String,"ip":ingenicoDetails[2] as! String]
                var devices = devicesArray.get()
                devices.append(device as AnyObject)
                devicesArray.set(devices)
                NSLog("Ingenico: %@", ingenicoDetails)
            }
        }
        NSLog("didReceiveMessage: %@ from %@", message, address)
    }
    
    func stringToHex(_ str: String) -> String {
        var hexBits = "" as String
        let byteArray = str.utf8
        for value in byteArray{
            hexBits += NSString(format:"%2x", value) as String
        }
        hexBits += "03"
        return hexBits
    }
    
    
    func calculateLRC(_ text: String) -> UInt8 {
        let data:Data = self.hexToBytes(text)
        var buffer = [UInt8](repeating: 0x0, count: data.count)
        (data as NSData).getBytes(&buffer, length: data.count)
        var lrc:UInt8 = 0
        
        for char:UInt8 in buffer{
            lrc = lrc ^ char
        }

        
        return lrc
    }
    
    func hexToBytes(_ hexaStr: String) -> Data {
        let data: NSMutableData = NSMutableData()
        var idx: Int = 0
        let byteArray = hexaStr.utf8
        for idx = 0; idx + 2 <= byteArray.count; idx += 2 {
            let hexStrTmp: String = hexaStr.substring(with: (hexaStr.characters.index(hexaStr.startIndex, offsetBy: idx) ..< hexaStr.characters.index(hexaStr.startIndex, offsetBy: idx+2)))
            let scanner = Scanner(string: hexStrTmp)
            var intValue = UInt32()
            if(scanner.scanHexInt32(&intValue) == true){
                data.append(&intValue, length: 1)
            }
        }
        return data as Data
    }
    
}

//
//  endian.swift
//  mobilesdkfw
//
//  Created by Gal Blank on 3/2/16.
//  Copyright © 2016 Goemerchant. All rights reserved.
//

import Foundation

import Darwin

let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian

let htons  = isLittleEndian ? _OSSwapInt16 : { $0 }
let htonl  = isLittleEndian ? _OSSwapInt32 : { $0 }
let htonll = isLittleEndian ? _OSSwapInt64 : { $0 }
let ntohs  = isLittleEndian ? _OSSwapInt16 : { $0 }
let ntohl  = isLittleEndian ? _OSSwapInt32 : { $0 }
let ntohll = isLittleEndian ? _OSSwapInt64 : { $0 }


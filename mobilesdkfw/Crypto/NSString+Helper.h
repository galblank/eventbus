//
//  NSString+Helper.h
//  SnapSecure
//
//  Created by Haemish Graham on 16/11/2012.
//  Copyright (c) 2013 SnapOne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSString (Helper)

- (NSString*)urlEncode;
- (NSString*)urlDecode;
- (NSString*)encryptWithKey:(NSString*)key;
- (NSString*)decryptWithKey:(NSString*)key;
- (BOOL)isEmpty;

@end

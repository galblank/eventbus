//
//  NSData+Helper.m
//  SnapSecure
//
//  Created by Haemish Graham on 19/11/2012.
//  Copyright (c) 2013 SnapOne. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "NSData+Helper.h"

@implementation NSData (Helper)

-(NSData*) transform:(CCOperation)encryptOrDecrypt key:(NSData*)keyData
{
    CCCryptorStatus status = kCCSuccess;
	size_t bufferSize = [self length] + kCCBlockSizeAES128;
	size_t resultSize = 0;
    void *buffer = malloc(bufferSize * sizeof(uint8_t));
    memset(buffer, 0x0, bufferSize);
	
	status = CCCrypt(encryptOrDecrypt,
                     kCCAlgorithmAES128,
                     kCCOptionPKCS7Padding | kCCOptionECBMode,
                     [keyData bytes],
                     kCCKeySizeAES128,
                     NULL,
                     [self bytes],
                     [self length],
                     buffer,
                     bufferSize,
                     &resultSize);
	
	if (status == kCCSuccess)
	{
		NSMutableData *output = [NSMutableData dataWithBytesNoCopy:buffer length:resultSize];
		return output;
	}
	return nil;
}
@end

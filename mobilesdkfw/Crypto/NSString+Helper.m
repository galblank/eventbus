//
//  NSString+Helper.m
//  SnapSecure
//
//  Created by Haemish Graham on 16/11/2012.
//  Copyright (c) 2013 SnapOne. All rights reserved.
//

#import "NSString+Helper.h"
#import "NSData+Helper.h"
#import "GTMBase64.h"

@implementation NSString (Helper)

- (NSString *)urlDecode
{
    NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (NSString*)urlEncode
{
    NSString *result = self;
	static CFStringRef leaveAlone = CFSTR(" ");
	static CFStringRef toEscape = CFSTR("\n\r:/=,!$&'()*+;[]@#?%");
    
	CFStringRef escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, leaveAlone, toEscape, kCFStringEncodingUTF8);
    
	if (escapedStr)
    {
		NSMutableString *mutable = [NSMutableString stringWithString:(__bridge NSString *)escapedStr];
		CFRelease(escapedStr);
		[mutable replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutable length])];
		result = mutable;
	}
	return result;
}

- (NSString*)encryptWithKey:(NSString*)key
{
	NSData *keyData    = [GTMBase64 decodeString:key];
    NSData *plainData  = [self dataUsingEncoding:NSISOLatin1StringEncoding];
    NSData *cipherData = [plainData transform:kCCEncrypt key:keyData];
	return [GTMBase64 stringByEncodingData:cipherData];
}


- (NSString*)decryptWithKey:(NSString*)key
{
	NSData *keyData    = [GTMBase64 decodeString:key];
	NSData *cipherData = [GTMBase64 decodeString:self];
    NSData *plainData  = [cipherData transform:kCCDecrypt key:keyData];
	return [[NSString alloc] initWithData:plainData encoding:NSISOLatin1StringEncoding];
}

- (BOOL)isEmpty
{
    return (self.length == 0);
}

@end

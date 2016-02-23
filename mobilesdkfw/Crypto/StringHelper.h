//
//  StringHelper.h
//  SmrtGuard
//
//  Created by Haemish Graham on 17/07/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


								 
@interface NSString(Helper)


-(BOOL)isFuzzyEqual:(NSString*)a_value;
-(BOOL)isValidEmail;
-(NSString*)urlEncode;
- (NSString *)urlDecode;
@end

@interface NSMutableString(Helper)
-(void)appendParams:(NSDictionary*)a_params;
@end



@interface NSData(Helper)
-(unsigned int) crc32;
@end


@interface NSDate(Helper)
-(NSString*) toStringWithDateStyle:(NSDateFormatterStyle)a_dateStyle andTimeStyle:(NSDateFormatterStyle)a_timeStyle;
@end



@interface NSString(MD5)
- (NSString *)MD5;
@end


@interface NSData(MD5)
- (NSString *)MD5;
@end
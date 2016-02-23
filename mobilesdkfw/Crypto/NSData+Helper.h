//
//  NSData+Helper.h
//  SnapSecure
//
//  Created by Haemish Graham on 19/11/2012.
//  Copyright (c) 2013 SnapOne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Helper)

-(NSData*) transform:(CCOperation)encryptOrDecrypt key:(NSData*)keyData;

@end

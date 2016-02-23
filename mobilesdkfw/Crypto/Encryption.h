//
//  Encryption.h
//  VivatToday
//
//  Created by Gal Blank on 4/26/10.
//  Copyright 2010 Mobixie. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Encryption : NSObject {

}

+ (Encryption *)sharedInstance;


- (NSData*) encryptString:(NSString*)plaintext withKey:(NSString*)key;
- (NSString*) decryptData:(NSData*)ciphertext withKey:(NSString*)key;
-(NSString*) generateSignature:(NSString*) data secretToBeSignedWith:(NSString*)secret;
-(NSString*) generateSignature:(NSString*) httpMethod baseURLString:(NSString*) baseURL querystringParams:(NSMutableArray*) querystringParameters Secret:(NSString*) secret;
-(NSString*) generateSignature:(NSMutableArray *)querystringParams Secret:(NSString *)secret;
-(NSString*) encodeUrl:(NSString*)string;
- (NSMutableData*)DecryptAES:(NSString*)key andForData:(NSMutableData*)objEncryptedData;
- (NSString *)decipherData:(NSData *)data :(NSString*)key;
@end

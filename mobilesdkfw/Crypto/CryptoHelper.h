//
// 20100716_Haemish_Graham
//
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
@import Foundation;

@interface CryptoHelper : NSObject
{
}


+(NSString*) generateKey;

+(NSString*) encryptMap:(NSMutableDictionary*)plainMap withKey:(NSString*)key;

+(NSString*) encrypt:(NSString*)plainText key:(NSString*)key;
+(NSString*) decrypt:(NSString*)cipherText key:(NSString*)key;


@end

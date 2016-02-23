#import <CommonCrypto/CommonCryptor.h>
#import "CryptoHelper.h"
#import "StringHelper.h"
#import "GTMBase64.h"

@implementation CryptoHelper


+(NSString*)generateKey
{
	NSString *key = nil;
    
	uint8_t *bytes = malloc(kCCKeySizeAES128);
    
	if (bytes)
	{
		if (SecRandomCopyBytes(kSecRandomDefault, kCCKeySizeAES128, bytes) == 0)
		{
			key = [GTMBase64 stringByEncodingBytes:bytes length:kCCKeySizeAES128];
		}
		free(bytes);
	}
    
	return key;
}


+(NSData*) transform:(CCOperation)encryptOrDecrypt data:(NSData*)inputData key:(NSData*)keyData
{  	
    CCCryptorStatus status = kCCSuccess;  
	size_t bufferSize = [inputData length] + kCCBlockSizeAES128;
	size_t resultSize = 0;
    void *buffer = malloc(bufferSize * sizeof(uint8_t));  
    memset(buffer, 0x0, bufferSize);  
	
	status = CCCrypt(encryptOrDecrypt,
		kCCAlgorithmAES128,
		kCCOptionPKCS7Padding | kCCOptionECBMode,
		[keyData bytes],
		kCCKeySizeAES128,
		NULL,
		[inputData bytes],
		[inputData length],
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


+(NSString*) encryptMap:(NSMutableDictionary*)plainMap withKey:(NSString*)key
{
	NSMutableString *buffer = [[NSMutableString alloc] init];
	for (NSString *key in plainMap)
	{
		NSString *value = [plainMap valueForKey:key]; 
		[buffer appendFormat:@"&%@=%@", key, value];
	}

	// Add UUID to make the string unique.
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef newID = CFUUIDCreateString(NULL, theUUID);
	[buffer appendFormat:@"&%@", newID];
	CFRelease (newID);
	CFRelease(theUUID);
	
	NSString *result = [[self encrypt:buffer key:key] urlEncode];
	return result;
}

+(NSString*) encrypt:(NSString*)plainText key:(NSString*)key
{

	NSData *keyData    = [GTMBase64 decodeString:key];
    NSData *plainData  = [plainText dataUsingEncoding:NSISOLatin1StringEncoding];
    NSData *cipherData = [self transform:kCCEncrypt data:plainData key:keyData];  
	return [GTMBase64 stringByEncodingData:cipherData];
}  


+(NSString*) decrypt:(NSString*)cipherText key:(NSString*)key
{
    
	NSData *keyData    = [GTMBase64 decodeString:key];
	NSData *cipherData = [GTMBase64 decodeString:cipherText];
    NSData *plainData  = [self transform:kCCDecrypt data:cipherData key:keyData];  
	return [[NSString alloc] initWithData:plainData encoding:NSISOLatin1StringEncoding];
}  


@end
//
//  Encryption.m
//  VivatToday
//
//  Created by Gal Blank on 4/26/10.
//  Copyright 2010 Mobixie. All rights reserved.
//

#import "Encryption.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+Helper.h"
#import "NSData+Helper.h"
#import "NSData+Base64.h"
#import "GTMBase64.h"

static Encryption *sharedSampleSingletonDelegate = nil;

@implementation Encryption

+ (Encryption *)sharedInstance {
	@synchronized(self) {
		if (sharedSampleSingletonDelegate == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return sharedSampleSingletonDelegate;
}


+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedSampleSingletonDelegate == nil) {
			sharedSampleSingletonDelegate = [super allocWithZone:zone];
			// assignment and return on first allocation
			return sharedSampleSingletonDelegate;
		}
	}
	// on subsequent allocation attempts return nil
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (NSData*) encryptString:(NSString*)plaintext withKey:(NSString*)key {
    NSData * result = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    return [self AES256EncryptData:result WithKey:key];
}

- (NSString*) decryptData:(NSData*)ciphertext withKey:(NSString*)key {
    NSData *cipherData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSString *returnStr = [[NSString alloc] initWithData:cipherData encoding:NSUTF8StringEncoding];
	return returnStr;
}
                          
- (NSData *)cipherData:(NSData *)data :(NSData*)key {
    return [self aesOperation:kCCEncrypt OnData:data :key];
}

- (NSString *)decipherData:(NSData *)data :(NSString*)key{
    NSData *cipherKey = [GTMBase64 decodeString:key];
    NSData *plainData  = [data transform:kCCDecrypt key:cipherKey];
    NSData *retData = [self aesOperation:kCCDecrypt OnData:data :cipherKey];
    NSString * retString = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
    return retString;
}

- (NSData *)aesOperation:(CCOperation)op OnData:(NSData *)data :(NSData*)cipherKey{
    NSData *outData = nil;
    
    // Data in parameters
    const void *key = cipherKey.bytes;
    const void *dataIn = data.bytes;
    size_t dataInLength = data.length;
    // Data out parameters
    size_t outMoved = 0;
    
    // Init out buffer
    unsigned char outBuffer[10000];
    memset(outBuffer, 0, 10000);
    CCCryptorStatus status = -1;
    
    status = CCCrypt(op, kCCAlgorithmAES128, kCCOptionPKCS7Padding, key, kCCKeySizeAES256, NULL,
                     dataIn, dataInLength, &outBuffer, 10000, &outMoved);
    
    if(status == kCCSuccess) {
        outData = [NSData dataWithBytes:outBuffer length:outMoved];
    } else if(status == kCCBufferTooSmall) {
        // Resize the out buffer
        size_t newsSize = outMoved;
        void *dynOutBuffer = malloc(newsSize);
        memset(dynOutBuffer, 0, newsSize);
        outMoved = 0;
        
        status = CCCrypt(op, kCCAlgorithmAES128, kCCOptionPKCS7Padding, key, kCCKeySizeAES256, NULL,
                         dataIn, dataInLength, &outBuffer, 10000, &outMoved);
        
        if(status == kCCSuccess) {
            outData = [NSData dataWithBytes:outBuffer length:outMoved];
        }
    }
    
    return outData;
}


-(NSString*) generateSignature:(NSString*) data secretToBeSignedWith:(NSString*)secret
{

        NSString* hash = nil;
        
        if(data == nil || secret == nil || data.length <= 0 || secret.length <= 0){
            return @"";
        }
        
        const char *cKey = [secret cStringUsingEncoding:NSUTF8StringEncoding];
        const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
        
        unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
        
        NSData *pHmacData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
        
        unsigned int data_length = (unsigned int)[pHmacData length];
        hash = [[pHmacData base64EncodingWithLineLength:data_length] copy];
        
        pHmacData = nil;
        
        return hash;

}

-(NSString*) encodeUrl:(NSString*)string
{

        //BOOL bRetVal = FALSE;
        NSString* output_string = nil;
        
        if(string == nil || string.length <= 0){
            return @"";
        }
        
        CFStringRef castCFStringRef = (__bridge CFStringRef) string;
        NSString* escapeString = @"!*'\"();:@&=+$,/?%#[]% ";
        CFStringRef castescapeString = (__bridge CFStringRef)escapeString;
        
        
        CFStringRef cfstringEncodedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                    castCFStringRef,
                                                                                    NULL,
                                                                                    castescapeString,
                                                                                    CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        
        NSString* pEncodedNSString = (__bridge NSString*)cfstringEncodedString;
        
        output_string = [NSString stringWithFormat:@"%@",pEncodedNSString];
        
        //CFRelease(castCFStringRef);
        CFRelease(castescapeString);
        CFRelease(cfstringEncodedString);
        
        return output_string;

}

- (NSMutableData*)DecryptAES:(NSString*)key andForData:(NSMutableData*)objEncryptedData
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero( keyPtr, sizeof(keyPtr) );
    
    [key getCString: keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF8StringEncoding];
    
    size_t numBytesEncrypted = 0;
    
    NSUInteger dataLength = [objEncryptedData length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer_decrypt = malloc(bufferSize);
    NSMutableData *output_decrypt = [[NSMutableData alloc] init];
    
    CCCryptorStatus result = CCCrypt( kCCDecrypt , kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     keyPtr, kCCKeySizeAES256,
                                     NULL,
                                     [objEncryptedData mutableBytes], [objEncryptedData length],
                                     buffer_decrypt, bufferSize,
                                     &numBytesEncrypted );
    
    output_decrypt = [NSMutableData dataWithBytesNoCopy:buffer_decrypt length:numBytesEncrypted];
    if( result == kCCSuccess )
    {
        return output_decrypt;
    }
    
    return(NULL);
}

- (NSData *)AES256EncryptData:(NSData*)dataToEncrypt WithKey:(NSString *)key {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [dataToEncrypt length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [dataToEncrypt bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData*)AES256Decrypt:(NSData*)dataToDecrypt WithKey:(NSString *)key {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [dataToDecrypt length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [dataToDecrypt bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSMutableData *) decryptData:(NSData*)data WithAES128Key: (NSString *) key {
    CCCryptorStatus ccStatus = kCCSuccess;
    // Symmetric crypto reference.
    CCCryptorRef thisEncipher = NULL;
    // Cipher Text container.
    NSData * cipherOrPlainText = nil;
    // Pointer to output buffer.
    uint8_t * bufferPtr = NULL;
    // Total size of the buffer.
    size_t bufferPtrSize = 0;
    // Remaining bytes to be performed on.
    size_t remainingBytes = 0;
    // Number of bytes moved to buffer.
    size_t movedBytes = 0;
    // Length of plainText buffer.
    size_t plainTextBufferSize = 0;
    // Placeholder for total written.
    size_t totalBytesWritten = 0;
    // A friendly helper pointer.
    uint8_t * ptr;
    
    // Initialization vector; dummy in this case 0's.
    uint8_t iv[kCCBlockSizeAES128];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    plainTextBufferSize = [data length];
    
    ccStatus = CCCryptorCreate(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, (const void *)[key UTF8String], kCCKeySizeAES128, (const void *)iv, &thisEncipher);
    
    // Calculate byte block alignment for all calls through to and including final.
    bufferPtrSize = 5000;//CCCryptorGetOutputLength(thisEncipher, plainTextBufferSize, true);
    
    // Allocate buffer.
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) );
    
    // Zero out buffer.
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    // Initialize some necessary book keeping.
    
    ptr = bufferPtr;
    
    // Set up initial size.
    remainingBytes = bufferPtrSize;
    
    // Actually perform the encryption or decryption.
    ccStatus = CCCryptorUpdate(thisEncipher, (const void *) [data bytes], plainTextBufferSize, ptr, remainingBytes, &movedBytes);
    
    ptr += movedBytes;
    remainingBytes -= movedBytes;
    totalBytesWritten += movedBytes;
    
    // Finalize everything to the output buffer.
    ccStatus = CCCryptorFinal(thisEncipher, ptr, remainingBytes, &movedBytes);
    
    cipherOrPlainText = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)totalBytesWritten];
    NSLog(@"data: %@", cipherOrPlainText);
    
    NSLog(@"buffer: %s", bufferPtr);
    
    CCCryptorRelease(thisEncipher);
    thisEncipher = NULL;
    if(bufferPtr) free(bufferPtr);
    
    return [NSMutableData dataWithData:cipherOrPlainText];
}


@end


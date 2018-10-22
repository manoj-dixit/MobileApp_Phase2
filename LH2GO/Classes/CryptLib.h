//
//  CryptLib.h
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>



@interface StringEncryption : NSObject

+ (id)sharedManager;


-  (NSData *)encrypt:(NSData *)plainText key:(NSString *)key iv:(NSString *)iv;
-  (NSData *)decrypt:(NSData *)encryptedText key:(NSString *)key iv:(NSString *)iv;
-  (NSData *)generateRandomIV:(size_t)length;
-  (NSString *) md5:(NSString *) input;
-  (NSString*) sha256:(NSString *)key length:(NSInteger) length;

-  (NSString *) encryptPlainTextWithData:(NSData *)plainData key:(NSString *)key iv:(NSString *)iv;
-  (NSString *) encryptPlainTextWith:(NSString *)plainText key:(NSString *)key iv:(NSString *)iv;
-  (NSString *) decryptCipherTextWith:(NSString *)cipherText key:(NSString *)key iv:(NSString *)iv;

@end

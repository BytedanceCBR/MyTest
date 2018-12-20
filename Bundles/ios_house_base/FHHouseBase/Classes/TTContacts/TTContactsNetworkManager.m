//
//  TTContactsNetworkManager.m
//  Article
//
//  Created by Zuopeng Liu on 7/26/16.
//
//

#import "TTContactsNetworkManager.h"
#import "FHURLSettings.h"
#import <TTNetworkManager.h>
#import <NSDataAdditions.h>
#import <CommonCrypto/CommonCrypto.h>
#import <TTSandBoxHelper.h>
#import "FHURLSettings.h"

#import "CocoaSecurity.h"


NSString * const kTTUploadContactsTimestampKey = @"kTTUploadContactsTimestampKey";

const TTContactProperty kTTContactsOfPropertiesV2 = kTTContactPropertyFullName | kTTContactPropertyNickname | kTTContactPropertyOrganizationName | kTTContactPropertyNote | kTTContactPropertyPhoneNumbers | kTTContactPropertyEmailAddresses | kTTContactPropertyUrlAddresses | kTTContactPropertyInstantMessageAddresses | kTTContactPropertySocialProfiles | kTTContactPropertyJobTitle | kTTContactPropertyDepartmentName | kTTContactPropertyPostalAddresses | kTTContactPropertyBirthday | kTTContactPropertyCreationDate | kTTContactPropertyModificationDate | kTTContactPropertyInstantMessageAddresses;

@implementation TTContactsNetworkManager

+ (void)postContacts:(NSArray<TTABContact *> *)contacts
              source:(TTContactsUploadSource)source
          userActive:(BOOL)userActive
          completion:(void (^)(NSError *error, id jsonObj))completion {

    // 记录上传时间
    [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kTTUploadContactsTimestampKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSMutableDictionary *postParameters = [NSMutableDictionary dictionaryWithCapacity:10];
    [postParameters setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
    [postParameters setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    if (userActive) {
        [postParameters setValue:@(1) forKey:@"is_user_active"];
    }else {
        [postParameters setValue:@(0) forKey:@"is_user_active"];
    }
    [postParameters setValue:@(source) forKey:@"from"];
    
    [[TTNetworkManager shareInstance] uploadWithURL:[FHURLSettings uploadAddressBookV2URLString] parameters:postParameters constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
        /**
         *  key Generator
         */
        NSData *randomKeyData = [self randomKeyDataOfLength:kCCKeySizeAES256];
        NSData *randomIVData  = [self randomKeyDataOfLength:kCCBlockSizeAES128];
        
        NSData *encryptedKey = [self RSAEncryptData:randomKeyData publicKey:[self RSAPublicKey]];
        NSData *encryptedContacts = [self AESEncryptContacts:contacts privateKey:randomKeyData IV:randomIVData];
        NSMutableData *newContactsData = [NSMutableData dataWithData:randomIVData];
        [newContactsData appendData:encryptedContacts];

        // 模拟器存在加密之后值为空导致 body 异常的问题
        if (encryptedKey) {
            [formData appendPartWithFileData:encryptedKey name:@"adle" fileName:@"adle" mimeType:@"application/x-binary"];
        }

        if (newContactsData) {
            [formData appendPartWithFileData:newContactsData name:@"contacts" fileName:@"contacts" mimeType:@"application/x-binary"];
        }
    } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (completion) completion(error, jsonObj);
    }];
}


/**
 * RSA: 非对称加密算法
 */
+ (NSData *)RSAEncryptData:(NSData *)keyData publicKey:(NSString *)publicKey {
    if (!keyData || !publicKey) return nil;
    
    return [NSData encryptData:keyData publicKey:publicKey error:nil];
}

/**
 *  AES(对称加密): 加密通讯录数据
 *
 *  @param dataString 待加密数据
 *  @param privateKey 私钥(256bits)
 *  @param iv         初始IV向量(相当于128bits的CString)
 *
 *  @return 加密的通讯录数据
 */
+ (NSData *)AESEncryptContacts:(NSArray<TTABContact *> *)contacts privateKey:(NSData *)privateKey IV:(NSData *)iv {
    if (!contacts || !privateKey) return nil;
    if (!iv) {
        iv = [NSMutableData dataWithLength:kCCBlockSizeAES128];
    }
    
    NSArray *newArray = [contacts toJSONFormattedArrayOfFieldMask:kTTContactsOfPropertiesV2];
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:newArray options:NSJSONWritingPrettyPrinted error:nil];
    CocoaSecurityResult *result = [CocoaSecurity aesEncryptWithData:jsonData key:privateKey iv:iv];
    NSData *encryptedDataOfAES = result.data;
    
    return encryptedDataOfAES;
}

+ (NSString *)RSAPublicKey {
    return @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDQwuhlG2hSvAH1pxaCawFQTHQPEa+MLm0muwhkPd6hCTxmodQOCTbwWzaZazk8GDtV4AwBAM8jIeHP7z9bYxmZeT/lKjgvbplEWURevOQ4O6rYahjL8i4vyf431ocW+POx+kQbJ8Tr4EAuqjEUmP2nw6WUQ6/hMjQv/CS6SfqpEQIDAQAB";
}

static int TT_SecRandomCopyBytes(void *rnd, size_t count, uint8_t *bytes) {
    static int kSecRandomFD;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kSecRandomFD = open("/dev/random", O_RDONLY);
    });
    
    if (kSecRandomFD < 0)
        return -1;
    while (count) {
        ssize_t bytes_read = read(kSecRandomFD, bytes, count);
        if (bytes_read == -1) {
            if (errno == EINTR)
                continue;
            return -1;
        }
        if (bytes_read == 0) {
            return -1;
        }
        bytes += bytes_read;
        count -= bytes_read;
    }
    
    return 0;
}

/**
 *  Random key generator
 *
 *  @param length key length of bytes
 *
 *  @return random data
 */
+ (NSData *)randomKeyDataOfLength:(NSUInteger)length {
    NSMutableData *data = [NSMutableData dataWithLength:length];
    int result;
    if ((&SecRandomCopyBytes) != NULL) {
        result = SecRandomCopyBytes(NULL, length, data.mutableBytes);
    }
    if (!data) {
        result = TT_SecRandomCopyBytes(NULL, length, data.mutableBytes);
    }
    NSAssert(result == 0, @"Unable to generate random bytes: %d", errno);
    return data;
}

+ (NSData *)defaultIVData {
    return [NSMutableData dataWithLength:kCCBlockSizeAES128]; // 0
}

@end

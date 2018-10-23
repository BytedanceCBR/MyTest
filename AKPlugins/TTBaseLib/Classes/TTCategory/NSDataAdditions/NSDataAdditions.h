/**
 * @file NSDataAdditions
 * @author David<gaotianpo@songshulin.net>
 *
 * @brief NSData的扩展
 * 
 * @details NSData 一些功能的扩展
 * 
 */


#import <Foundation/Foundation.h>

extern NSString * const kRSADecryptionErrorDomain;

typedef NS_ENUM(NSInteger, TTFingerprintType) {
    TTFingerprintTypeXOR,       // 按位异或(data[i] ^= finger)
    TTFingerprintTypeEnumXOR,   // 按位异或(data[i] ^= fingers[for i in range(0, 4)] )
};

@interface NSData(TTAdditions)

/**
 *  RSA加密数据
 *
 *  @param data   待加密数据
 *  @param pubKey 公钥
 *  @param error  错误
 *
 *  @return 加密后的数据
 */
+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey error:(NSError **)error;

/**
 *  使用RSA对数据进行认证
 *
 *  @param data   待认证的数据
 *  @param pubKey 公钥
 *  @param error  错误信息
 *
 *  @return 认证后的数据
 */
+ (NSData *)decryptData:(NSData *)data publicKey:(NSString *)pubKey error:(NSError **)error;

/**
 *  将Base64格式的字符串转换成NSData
 *
 *  @param base64String Base64格式的字符串
 *
 *  @return 转换后的数据
 */
+ (NSData *)ss_dataWithBase64EncodedString:(NSString *)base64String;

/**
 *  将NSData转换成Base64格式字符串
 *
 *  @return 转换后的字符串
 */
- (NSString *)ss_base64EncodedString;

/**
 *  根据TTFingerprintType转换为相应的NSData
 *
 *  @param type TTFingerprintType
 *
 *  @return 转换后的数据
 */
- (NSData *)tt_dataWithFingerprintType:(TTFingerprintType)type;

/**
 *  将NSData转换成MD5加密的字符串
 *
 *  @return 转换后的字符串
 */
- (NSString *)md5String;

/**
 *  将NSData数据转换成十六进制字符串
 *
 *  @return 转换后的字符串
 */
- (NSString *)hexadecimalString;
@end

@interface NSData (JSONExtensions)

- (id)JSONValue;

@end

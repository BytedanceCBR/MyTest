//
//  TTNetworkProvider.h
//  Pods
//
//  Created by muhuai on 2017/4/18.
//
//

#import <Foundation/Foundation.h>

@protocol TTNetworkProvider <NSObject>

@required
/**
 添加公共参数

 @param urlStr 待添加的url
 @param supportedMix 是否需要ssmix参数
 @return 包含公共参数的url
 */
+ (NSString *)customURLStringFromString:(NSString *)urlStr
                                    supportedMix:(BOOL)supportedMix;


/**
 去掉url中的公共参数

 @param urlStr 待去掉参数的url
 @return 去掉参数后的url
 */
+ (NSString *)substringCutOffCommonParasStringFromURLString:(NSString *)urlStr;


/**
 公用参数dic

 @param supportedMix 是否需要ssmix参数
 @return dic
 */
+ (NSDictionary *)commonHeaderDictionaryWithSupportedMix:(BOOL)supportedMix;



/**
 http转换到https,
 @warning 如果满足内部规则才转换https, 否则不转
 @param url 待转换的url
 @return 转换后的url
 */
+ (NSURL *)transferedURLFrom:(NSURL *)url;
@end

//
//  FHEnvContext.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "FHClient.h"

//字符串是否为空
#define kIsNSString(str) ([str isKindOfClass:[NSString class]])
//数组是否为空
#define kIsNSArray(array) ([array isKindOfClass:[NSArray class]])
//字典是否为空
#define kIsNSDictionary(dic) ([dic isKindOfClass:[NSDictionary class]])

#define MAIN_SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define MAIN_SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

static NSString *const kUserDefaultCityName = @"kUserDefaultCityName";


NS_ASSUME_NONNULL_BEGIN

@interface FHEnvContext : NSObject
{
    
}

@property(nonatomic,strong)FHClient * client;

+ (instancetype)sharedInstance;
/*
 *  埋点
 *  @param: param 参数
 *  @param: traceKey key
 *  @param: searchId 请求id
 */
+ (void)recordEvent:(NSDictionary *)params andKey:(NSString *)traceKey;

- (void)setTraceValue:(NSString *)value forKey:(NSString *)key;

+ (NSString *)getCurrentUserDeaultCityName;

+ (void)setCurrentUserDeaultCityName:(NSString *)cityName;

@end

NS_ASSUME_NONNULL_END

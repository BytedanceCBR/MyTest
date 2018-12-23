//
//  FHEnvContext.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "FHClient.h"
#import "TTBaseMacro.h"

//字符串是否为空
#define kIsNSString(str) ([str isKindOfClass:[NSString class]])
//数组是否为空
#define kIsNSArray(array) ([array isKindOfClass:[NSArray class]])
//字典是否为空
#define kIsNSDictionary(dic) ([dic isKindOfClass:[NSDictionary class]])

#define MAIN_SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define MAIN_SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

static NSString *const kUserDefaultCityName = @"kUserDefaultCityName";

static NSString *const kUserDefaultCityId = @"kUserDefaultCityId";

static NSString *const kTracerEventType = @"house_app2c_v2";

static NSString *const kFHBaseColorBlue = @"#299cff";




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

//获取当前保存的城市名称
+ (NSString *)getCurrentUserDeaultCityNameFromLocal;

//保存当前城市名称
+ (void)saveCurrentUserDeaultCityName:(NSString *)cityName;

//获取当前选中城市cityid
+ (NSString *)getCurrentSelectCityIdFromLocal;

//保存当前城市id
+ (void)saveCurrentUserCityId:(NSString *)cityId;

@end

NS_ASSUME_NONNULL_END

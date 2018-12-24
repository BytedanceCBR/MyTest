//
//  FHEnvContext.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "FHClient.h"
#import "TTBaseMacro.h"
#import "FHHomeConfigManager.h"

//字符串是否为空
#define kIsNSString(str) ([str isKindOfClass:[NSString class]])
//数组是否为空
#define kIsNSArray(array) ([array isKindOfClass:[NSArray class]])
//字典是否为空
#define kIsNSDictionary(dic) ([dic isKindOfClass:[NSDictionary class]])

#define MAIN_SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define MAIN_SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

static NSString *const kUserDefaultCityName = @"kUserDefaultCityName";

static NSString *const kUserDefaultCityId = @"config_key_select_city_id";

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

/*
  判断是否联网
 */
+ (BOOL)isNetworkConnected;

/*
  app启动调用
 */
- (void)onStartApp;

/*
  config变化更新cache
 */
- (void)updateConfigCache;

/*
 
 */
- (void)setTraceValue:(NSString *)value forKey:(NSString *)key;

//从缓存中获取config数据
- (FHConfigDataModel *)getConfigFromCache;

//从本地磁盘获取config数据
- (FHConfigDataModel *)getConfigFromLocal;


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

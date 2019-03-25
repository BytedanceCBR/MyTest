//
//  FHEnvContext.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "TTBaseMacro.h"
#import "FHGeneralBizConfig.h"
#import "FHClientModel.h"
#import "FHSearchConfigModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

//字符串是否为空
#define kIsNSString(str) ([str isKindOfClass:[NSString class]])
//数组是否为空
#define kIsNSArray(array) ([array isKindOfClass:[NSArray class]])
//字典是否为空
#define kIsNSDictionary(dic) ([dic isKindOfClass:[NSDictionary class]])

#define MAIN_SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define MAIN_SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

static NSString *const kFHUserSelectCityNotification = @"k_fh_user_select_city";

static NSString *const kUserDefaultCityName = @"kUserDefaultCityName";

static NSString *const kUserDefaultCityId = @"k_fh_config_key_select_city_id";

static NSString *const kUserHasSelectedCityKey = @"k_fh_has_sel_city";

static NSString *const kTracerEventType = @"house_app2c_v2";

static NSString *const kFHSwitchGetLightFinishedNotification = @"k_fh_get_light_finish";

@class FHMessageManager;

NS_ASSUME_NONNULL_BEGIN

@interface FHEnvContext : NSObject
{
    
}
@property (nonatomic, strong)FHGeneralBizConfig *generalBizConfig;
@property (nonatomic, assign) BOOL isSendConfigFromFirstRemote;
@property (nonatomic, assign) BOOL isRefreshFromAlertCitySwitch;
@property (nonatomic, assign) BOOL isRefreshFromCitySwitch;
@property (nonatomic, copy) void (^homeConfigCallBack)(FHConfigDataModel *configModel);
@property(nonatomic , strong) RACReplaySubject *configDataReplay;
@property (nonatomic , strong) FHMessageManager *messageManager;


+ (instancetype)sharedInstance;
/*
 *  埋点
 *  @param: param 参数
 *  @param: traceKey key
 *  @param: searchId 请求id
 */
+ (void)recordEvent:(NSDictionary *)params andEventKey:(NSString *)traceKey;


+ (void)openSwitchCityURL:(NSString *)urlString completion:(void(^)(BOOL isSuccess))completion;

+ (void)openLogoutSuccessURL:(NSString *)urlString completion:(void(^)(BOOL isSuccess))completion;

/*
  判断是否联网
 */
+ (BOOL)isNetworkConnected;

/*
 判断找房当前城市是否开通
 */
+ (BOOL)isCurrentCityNormalOpen;

/*
 判断用户选择城市和当前城市是否是同一个
 */
+ (BOOL)isSameLocCityToUserSelect;

/*
  app启动调用
 */
- (void)onStartApp;

/*
   更新公共参数
*/

- (void)updateRequestCommonParams;

/*
 获取请求公共参数
 */
- (NSDictionary *)getRequestCommonParams;

 
- (void)setTraceValue:(NSString *)value forKey:(NSString *)key;


//保存config数据
- (void)saveGeneralConfig:(FHConfigModel *)model;

//从缓存中获取config数据
- (nullable FHConfigDataModel *)getConfigFromCache;

//从本地磁盘获取config数据
- (FHConfigDataModel *)readConfigFromLocal;

//获取当前保存的城市名称
+ (NSString *)getCurrentUserDeaultCityNameFromLocal;

//保存当前城市名称
+ (void)saveCurrentUserDeaultCityName:(NSString *)cityName;

//获取当前选中城市cityid
+ (NSString *)getCurrentSelectCityIdFromLocal;

//保存当前城市id
+ (void)saveCurrentUserCityId:(NSString *)cityId;

//返回origin_search id

//接受config数据
- (void)acceptConfigDataModel:(FHConfigDataModel *)configModel;

- (void)acceptConfigDictionary:(NSDictionary *)configDict;

/*
 获取首页埋点公共参数
*/

- (FHClientHomeParamsModel *)getCommonParams;

- (void)updateOriginFrom:(NSString *)originFrom originSearchId:(NSString *)originSearchid;


- (NSDictionary *)getGetOriginFromAndOriginId;

@end

NS_ASSUME_NONNULL_END

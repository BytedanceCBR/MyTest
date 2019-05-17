//
//  TTVFlowStatisticsManager.m
//  Article
//
//  Created by wangdi on 2017/6/29.
//
//

#import "TTVFlowStatisticsManager.h"
#import <TTNetworkManager.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <NSStringAdditions.h>
#import <TTURLUtils.h>
#import <JSONModel.h>
#import "TTVGetSystemFlowManager.h"
//#import <TTInstallService/TTInstallIDManager.h>
#import <TTNetworkHelper.h>
#import "TTVPlayerEnvironmentContext.h"

@interface TTVFlowStatisticsResponseModel : JSONModel

@property (nonatomic, strong) NSNumber *is_order_flow;
@property (nonatomic, assign) double flow;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, assign) int64_t cache_time;
@property (nonatomic, assign) int64_t current_time;
@property (nonatomic, strong) NSNumber *is_support;
@property (nonatomic, copy) NSString *order_flow_button;
@property (nonatomic, copy) NSString *flow_reminder_msg;

@end

@implementation TTVFlowStatisticsResponseModel

@end

NSString * const ttv_kExcessFlowNotification = @"excessFlowNotification";
NSString * const ttv_kFreeFlowOrderFinishedNotification = @"freeFlowOrderFinishedNotification";

NSInteger const ttv_kDefaultAutoTrimInterval = 600;
NSInteger const ttv_kDefaultCheckTimeInterval = 180;

static NSString * const kFlowSourceFromTouTiao = @"toutiao";
static NSString * const kFlowSourceFromCarrier = @"carrier";

@implementation TTVFlowStatisticsManager

static id _instance;

#pragma mark - public
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

#pragma mark - setting开关
- (void)setFlowStatisticsEnable:(BOOL)isEnable
{
    [[NSUserDefaults standardUserDefaults] setBool:isEnable forKey:@"flow_statistics_enable_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)flowStatisticsEnable
{
    return  [[NSUserDefaults standardUserDefaults] boolForKey:@"flow_statistics_enable_key"];
}

- (void)setFlowOrderEntranceIsEnable:(BOOL)isEnable
{
    [[NSUserDefaults standardUserDefaults] setBool:isEnable forKey:@"flow_order_entrance_enable_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)flowOrderEntranceEnable
{
    return  [[NSUserDefaults standardUserDefaults] boolForKey:@"flow_order_entrance_enable_key"];
}

- (void)setFlowStatisticsRequestInterval:(int64_t)interval
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:interval] forKey:@"flow_statistics_request_interval_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int64_t)flowStatisticsRequestInterval
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"flow_statistics_request_interval_key"] longLongValue];
}

- (void)setFlowStatisticsRemainTipValue:(int64_t)remainTipValue
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:remainTipValue] forKey:@"flow_statistics_remain_tip_value_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int64_t)flowStatisticsRemainTipValue
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"flow_statistics_remain_tip_value_key"] longLongValue];
}

- (void)setFlowDefaultCheckTimeInterval:(int64_t)checkTimeInterval
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:checkTimeInterval] forKey:@"flow_default_check_time_intetval"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int64_t)flowDefaultCheckTimeInterval
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"flow_default_check_time_intetval"] longLongValue];
}

- (void)setFlowStatisticsOptions:(NSDictionary *)dict
{
    BOOL flowStatisticsEnable = [[dict valueForKey:@"is_enable"] integerValue];
    [self setFlowStatisticsEnable:flowStatisticsEnable];
    
    BOOL flowOrderEntranceEnable = [[dict valueForKey:@"is_show_order_tips"] integerValue];
    [self setFlowOrderEntranceIsEnable:flowOrderEntranceEnable];
    
    int64_t flowStatisticsRequestInterval = [[dict valueForKey:@"server_request_interval"] longLongValue];
    [self setFlowStatisticsRequestInterval:flowStatisticsRequestInterval];
    
    int64_t flowStatisticsRemainTipValue = [[dict valueForKey:@"remain_flow_thold"] longLongValue];
    [self setFlowStatisticsRemainTipValue:flowStatisticsRemainTipValue];
    
    int64_t flowDefaultCheckTimeInterval = [[dict valueForKey:@"local_query_interval"] longLongValue];
    [self setFlowDefaultCheckTimeInterval:flowDefaultCheckTimeInterval];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"flow_statistics_options_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSString *)orderButtonTitle
{
    return [self _getOrderButtonTitle];
}

- (NSString *)flowReminderTitle
{
    return [self _getFlowReminderTitle];
}

- (NSDictionary *)flowStatisticsOptions
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"flow_statistics_options_key"];
}

- (BOOL)isSupportFreeFlow
{
    return [self _getIsSupport];
}

- (BOOL)isOpenFreeFlow
{
    return [self _getIsOrderFlow];
}

- (BOOL)isExcessFlow
{
    return [self isExcessFlowWithSize:0];
}

- (BOOL)isExcessFlowWithSize:(double)size
{
    double localAvailableFlow = [self _getLocalAvailableFlow];
    double currentUsingFlow = [self _getSystemFlow];
    double delta = localAvailableFlow - currentUsingFlow - size;
    return delta <= 0;
}

- (BOOL)isExcessCriticalValueFlow:(double)criticalValue
{
    return [self isExcessCriticalValueFlow:criticalValue withSize:0];
}

- (BOOL)isExcessCriticalValueFlow:(double)criticalValue withSize:(double)size
{
    double localAvailableFlow = [self _getLocalAvailableFlow];
    double currentUsingFlow = [self _getSystemFlow];
    double delta = localAvailableFlow - currentUsingFlow - size;
    return delta <= criticalValue;
}

- (void)registerMonitorFlowChangeWithCompletion:(void (^)(BOOL))completion
{
    if(![self flowStatisticsEnable]) return;
    [self _requestAvailableFlowWithCompletion:^(TTVFlowStatisticsResponseModel *responseModel) {
        if(responseModel) {
            [self _setLocalAvailableFlow:responseModel.flow];
        }
        [self _trimRecursively];
        [self _registerNotification];
        if(completion) {
            completion(YES);
        }
    }];
}

- (void)setFlowData:(NSDictionary *)data
{
    if(![data isKindOfClass:[NSDictionary class]]) return;
    double flow = [[data valueForKey:@"flow"] doubleValue];
    BOOL isOrderFlow = [[data valueForKey:@"isOrder"] integerValue];
    [self _setLocalAvailableFlow:flow];
    [self _setIsOrderFlow:isOrderFlow];
    [self _setIsSupport:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:ttv_kFreeFlowOrderFinishedNotification object:nil];
    [self registerMonitorFlowChangeWithCompletion:nil];
}

- (NSString *)freeFlowEntranceURL
{
    NSString *code = [self _getMobileNetworkCode];
    if(code.length <= 0) code = @"";
    NSString *str = [NSString stringWithFormat:@" https://i.snssdk.com/activity/carrier_flow/?app_source=xigua&app_name=video_article&device_id=%@&carrier=%@", [[TTInstallIDManager sharedInstance] deviceID], code];
    NSString *encodingStr = [TTURLUtils queryItemAddingPercentEscapes:str];
    return [NSString stringWithFormat:@"sslocal://webview?url=%@",encodingStr];
    
}

- (NSDate *)recentUpdateDataTime
{
    int64_t time = [self _getCurrentUpdateTime];
    if(time == 0) return [NSDate date];
    return [NSDate dateWithTimeIntervalSince1970:time];
}

- (void)_trimRecursively
{
    int64_t time = [self flowStatisticsRequestInterval] > 0 ? [self flowStatisticsRequestInterval] : ttv_kDefaultAutoTrimInterval;
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        [self _trimInBackgroundWithCompletion:^(BOOL continueRecurively) {
            if(continueRecurively) {
                [self _trimRecursively];
            }
        }];
    });
}

- (void)_trimInBackgroundWithCompletion:(void (^)(BOOL continueRecurively))completion
{
    __block BOOL continueRecurively = YES;
    [self _requestAvailableFlowWithCompletion:^(TTVFlowStatisticsResponseModel *responseModel) {
        int64_t timeInterval = responseModel.current_time - responseModel.cache_time;
        int64_t defaultChcekTimeInterval = [self flowDefaultCheckTimeInterval] > 0 ? [self flowDefaultCheckTimeInterval]  : ttv_kDefaultCheckTimeInterval;
        if(responseModel && (![self isSupportFreeFlow] || ![self isOpenFreeFlow])) {
            continueRecurively = NO;
        } else if (responseModel && [responseModel.source isEqualToString:kFlowSourceFromCarrier] && timeInterval < defaultChcekTimeInterval) {
            if(responseModel.flow <= 0) {
                [self _setLocalAvailableFlow:0];
                continueRecurively = NO;
            } else {
                [self _setLocalAvailableFlow:responseModel.flow];
                continueRecurively = YES;
            }
        } else {
            double localAvailableFlow = [self _getLocalAvailableFlow];
            double currentUsingFlow = [self _getSystemFlow];
            double delta = localAvailableFlow - currentUsingFlow;
            delta = delta <= 0 ? 0 : delta;
            [self _setLocalAvailableFlow:delta];
        }
        if(completion) {
            completion(continueRecurively);
        }
    }];
}

- (void)_registerNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)_appWillEnterForegroundNotification
{
    [self _requestAvailableFlowWithCompletion:^(TTVFlowStatisticsResponseModel *responseModel) {
        if(responseModel) {
            [self _setLocalAvailableFlow:responseModel.flow];
        }
    }];
}

- (void)_appDidEnterBackgroundNotification
{
    if(![self _getIsOrderFlow]) return;
    double localAvailableFlow = [self _getLocalAvailableFlow];
    double currentUsingFlow = [self _getSystemFlow];
    double delta = localAvailableFlow - currentUsingFlow;
    delta = delta <= 0 ? 0 : delta;
    [self _setLocalAvailableFlow:delta];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[NSString stringWithFormat:@"%.0lf",delta] forKey:@"flow"];
    [param setValue:kFlowSourceFromTouTiao forKey:@"source"];
    NSArray *array = @[[NSString stringWithFormat:@"%.0lf",delta],kFlowSourceFromTouTiao,@"carrier_flow_sign"];
    NSString *md5Str = [[array componentsJoinedByString:@"_"] MD5HashString];
    [param setValue:md5Str forKey:@"sign"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[self _getUpdateResidualFlowURLString] params:param method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
    }];
}


- (double)_getSystemFlow
{
    double result = [TTVGetSystemFlowManager getCurrentUsingFlow];
    return result;
}

- (void)_resetSystemFlow
{
    [TTVGetSystemFlowManager resetFlowData];
}

- (void)_setLocalAvailableFlow:(double)localAvailableFlow
{
    if(localAvailableFlow == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ttv_kExcessFlowNotification object:nil];
    }
    [[NSUserDefaults standardUserDefaults] setDouble:localAvailableFlow forKey:NSStringFromSelector(@selector(_getLocalAvailableFlow))];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self _resetSystemFlow];
}

- (double)_getLocalAvailableFlow
{
    double result = [[NSUserDefaults standardUserDefaults] doubleForKey:NSStringFromSelector(_cmd)];
    return result;
}

- (void)_setIsOrderFlow:(BOOL)isOrder
{
    [[NSUserDefaults standardUserDefaults] setBool:isOrder forKey:NSStringFromSelector(@selector(_getIsOrderFlow))];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)_getIsOrderFlow
{
    BOOL result = [[NSUserDefaults standardUserDefaults] boolForKey:NSStringFromSelector(_cmd)];
    return  result;
}

- (void)_setIsSupport:(BOOL)isSupport
{
    [[NSUserDefaults standardUserDefaults] setBool:isSupport forKey:NSStringFromSelector(@selector(_getIsSupport))];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)_getIsSupport
{
    BOOL result = [[NSUserDefaults standardUserDefaults] boolForKey:NSStringFromSelector(_cmd)];
    return result;
    
}

- (void)_setCurrentUpdateTime:(int64_t)time
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:time] forKey:NSStringFromSelector(@selector(_getCurrentUpdateTime))];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int64_t)_getCurrentUpdateTime
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromSelector(_cmd)] longLongValue];
}

- (void)_requestAvailableFlowWithCompletion:(void (^)(TTVFlowStatisticsResponseModel *responseModel))completion
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[self _getMobileNetworkCode] forKey:@"carrier"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[self _getQueryResidualFlowURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSError *serizerError = nil;
        TTVFlowStatisticsResponseModel *responseModel = [[TTVFlowStatisticsResponseModel alloc] initWithDictionary:jsonObj error:&serizerError];
        if(!error && !serizerError && completion) {
            [self _setIsSupport:responseModel.is_support.integerValue];
            [self _setIsOrderFlow:responseModel.is_order_flow.integerValue];
            [self _setCurrentUpdateTime:responseModel.current_time];
            [self _setOrderButtonTitle:responseModel.order_flow_button];
            [self _setFlowReminderTitle:responseModel.flow_reminder_msg];
            completion(responseModel);
        } else if(completion) {
            completion(nil);
        }
    }];
    
}

- (NSString *)_getQueryResidualFlowURLString
{
    NSString *domain = [TTVPlayerEnvironmentContext sharedInstance].host;//[CommonURLSetting baseURL];
    return [NSString stringWithFormat:@"%@/activity/carrier_flow/query_flow/",domain];
}

- (NSString *)_getUpdateResidualFlowURLString
{
    NSString *domain = [TTVPlayerEnvironmentContext sharedInstance].host;
    return [NSString stringWithFormat:@"%@/activity/carrier_flow/update_flow/",domain];
}


- (void)_setFlowReminderTitle:(NSString *)title
{
    [[NSUserDefaults standardUserDefaults] setObject:title forKey:NSStringFromSelector(@selector(_getFlowReminderTitle))];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)_getFlowReminderTitle
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromSelector(_cmd)];
}

- (void)_setOrderButtonTitle:(NSString *)title
{
    [[NSUserDefaults standardUserDefaults] setObject:title forKey:NSStringFromSelector(@selector(_getOrderButtonTitle))];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)_getOrderButtonTitle
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromSelector(_cmd)];
}

- (NSString *)_getMobileNetworkCode
{
#if !TARGET_OS_SIMULATOR
    NSString *countryCode = [TTNetworkHelper carrierMCC];
    NSString *code = [TTNetworkHelper carrierMNC];
    NSMutableString *tmpStr = [NSMutableString string];
    if(countryCode.length > 0) {
        [tmpStr appendString:countryCode];
    }
    if(code.length > 0) {
        [tmpStr appendString:code];
    }
    NSString *result = [tmpStr copy];
    return result.length > 0 ? result : nil;
#else
    return @"46001";
#endif
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

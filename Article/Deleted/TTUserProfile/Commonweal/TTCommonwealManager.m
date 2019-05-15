//
//  CommonwealManager.m
//  Article
//
//  Created by wangdi on 2017/8/7.
//
//

#import "TTCommonwealManager.h"
#import "TTNetworkManager.h"
#import <TTAccountManager.h>

@interface TTCommonwealManager ()

@property (nonatomic, strong) NSDate *appEnterForegroundDate;

@end

@implementation TTCommonwealManager

static id _instance;

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

- (void)startMonitor
{
    self.appEnterForegroundDate = [NSDate date];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (NSTimeInterval)todayUsingTime
{
    NSTimeInterval interval =  [self _appDidEnterBackgroundNotification];
    [self _appWillEnterForegroundNotification];
    return interval;
}

- (NSString *)commonwealSkipURL
{
    return [self _getCommonwealURL];
}

- (void)trackerWithSource:(NSString *)source
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:source forKey:@"welfare_position"];
    [param setValue:@([TTAccountManager isLogin]) forKey:@"is_log_in"];
    [param setValue:@([self receiveMoneyEnable])  forKey:@"is_prize"];
    [param setValue:[NSString stringWithFormat:@"%.0lf",[self todayUsingTime]] forKey:@"read_time"];
    [param setValue:[NSString stringWithFormat:@"%.0lf",[self receiveMoney]] forKey:@"prize"];
    [TTTracker eventV3:@"welfare_click" params:param];

}

- (BOOL)receiveMoneyEnable
{
    return [self _getReceiveMoneyEnable];
}

- (double)receiveMoney
{
    return [self _getReceiveMoney];
}

- (BOOL)shouldShowTips
{
    BOOL entranceEnable = [SSCommonLogic commonwealEntranceEnable];
    double todayUsingTime = [self todayUsingTime];
    BOOL timeEnable = todayUsingTime > [SSCommonLogic commonwealDefaultShowTipTime] ? YES : NO;
    BOOL hasTips = [SSCommonLogic commonwealTips].length > 0 ? YES : NO;
    BOOL hasShow = [self getHasShowCommonwealTips];
    return entranceEnable && timeEnable && hasTips && !hasShow;
}

- (void)setHasShowCommonwealTips:(BOOL)hasShow
{
    [self _setHasShowTips:hasShow];
}

- (BOOL)getHasShowCommonwealTips
{
    return [self _getHasShowTips];
}

- (void)uploadTodayUsingTimeWithCompletion:(void (^)(BOOL, double, NSTimeInterval))completion
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSTimeInterval time = [self todayUsingTime];
    [param setValue:[NSString stringWithFormat:@"%.0lf",time] forKey:@"st_time"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting uploadUsingTimeURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if([jsonObj isKindOfClass:[NSDictionary class]] && [[jsonObj valueForKey:@"err_no"] integerValue] == 0 && !error) {
            id data = [jsonObj valueForKey:@"data"];
            double money = [[data valueForKey:@"money"] doubleValue];
            BOOL canGetMoney = [[data valueForKey:@"is_enough"] integerValue];
            NSString *url = [data valueForKey:@"url"];
            if(completion) {
                completion(canGetMoney,money,time);
            }
            [self _setReceiveMoneyEnable:canGetMoney];
            [self _setReceiveMoney:money];
            [self _setCommonwealURL:url];
        } else if(completion) {
            completion([self _getReceiveMoneyEnable],[self _getReceiveMoney],time);
        }
    }];
}

- (NSTimeInterval)_updateTodayUsingTimeWithInterval:(NSTimeInterval)interval currentDate:(NSDate *)currentDate
{
    NSMutableDictionary *dict = [self _timeDict];
    NSString *dateStr = [self _dateStrWithDate:currentDate];
    NSString *usingTime = [dict valueForKey:dateStr];
    if(usingTime) { //没有隔天
        usingTime = [NSString stringWithFormat:@"%lf",usingTime.doubleValue + interval];
    } else { //隔天了，要清空数据，重新计时间 或者是第一次使用
        [dict removeAllObjects];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *recentlyDateStr = [NSString stringWithFormat:@"%@ 00:00:00",dateStr];
        NSDate *recentlyDate = [formatter dateFromString:recentlyDateStr];
        NSTimeInterval recentlyTimeInterval = [currentDate timeIntervalSinceDate:recentlyDate];
        if(interval > recentlyTimeInterval) { //手机一直在前台导致隔天
            usingTime = [NSString stringWithFormat:@"%lf",recentlyTimeInterval];
            [self _appWillEnterForegroundNotification];
        } else { //正常隔天
            usingTime = [NSString stringWithFormat:@"%lf",interval];
        }
    }
    if(!isEmptyString(dateStr) && !isEmptyString(usingTime)) {
        [dict setValue:usingTime forKey:dateStr];
    }
    [self _setTimeDict:dict];
    return usingTime.doubleValue;
}

- (void)_setTimeDict:(NSMutableDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"tt_commonweal_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableDictionary *)_timeDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"tt_commonweal_key"]];
    if(!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    return dict;
}

- (void)_setReceiveMoneyEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:NSStringFromSelector(@selector(_getReceiveMoneyEnable))];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)_getReceiveMoneyEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:NSStringFromSelector(_cmd)];
}

- (void)_setReceiveMoney:(double)money
{
    [[NSUserDefaults standardUserDefaults] setDouble:money forKey:NSStringFromSelector(@selector(_getReceiveMoney))];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (double)_getReceiveMoney
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NSStringFromSelector(_cmd)];
}

- (void)_setCommonwealURL:(NSString *)url
{
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:NSStringFromSelector(@selector(_getCommonwealURL))];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)_getCommonwealURL
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromSelector(_cmd)];
}

- (void)_setHasShowTips:(BOOL)hasShowTips
{
    [[NSUserDefaults standardUserDefaults] setBool:hasShowTips forKey:NSStringFromSelector(@selector(_getHasShowTips))];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)_getHasShowTips
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:NSStringFromSelector(_cmd)];
}

- (NSString *)_dateStrWithDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter stringFromDate:date];
}

- (void)_appWillEnterForegroundNotification
{
    self.appEnterForegroundDate = [NSDate date];
}

- (NSTimeInterval)_appDidEnterBackgroundNotification
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.appEnterForegroundDate];
    return [self _updateTodayUsingTimeWithInterval:timeInterval currentDate:currentDate];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

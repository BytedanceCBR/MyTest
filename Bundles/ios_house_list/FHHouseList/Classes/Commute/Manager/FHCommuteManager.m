//
//  FHCommuteManager.m
//  FHHouseList
//
//  Created by 春晖 on 2019/4/1.
//

#import "FHCommuteManager.h"
#import <TTBaseLib/TTSandBoxHelper.h>
#import <FHHouseBase/FHBaseViewController.h>
#import <FHHouseBase/FHUserTrackerDefine.h>
#import <FHHouseBase/FHEnvContext.h>

#define COMMUTE_CONFIG    @"_COMMUTE_CONFIG_"
#define COMMUTE_LOCATION  @"LOCATION"
#define COMMUTE_DUARTION  @"DURATION"
#define COMMUTE_TYPE      @"type"
#define COMMUTE_LATITUDE  @"LATITUDE"
#define COMMUTE_LONGITUDE @"LONGITUDE"
#define COMMUTE_CITY_ID   @"CITY_ID"

extern NSString *const COMMUTE_CONFIG_DELEGATE;


@interface FHCommuteManager ()

@property(nonatomic , strong) NSMutableDictionary *configDict;

@property(nonatomic , copy) NSString *openUrl;
@property(nonatomic , strong) NSDictionary *logParam;

@end

@implementation FHCommuteManager

+(instancetype)sharedInstance
{
    static FHCommuteManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHCommuteManager alloc]init];
    });
    return manager;
}

-(instancetype)init
{
    self = [super init];
    if (self) {        
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:COMMUTE_CONFIG];
        _configDict = [[NSMutableDictionary alloc]init];
        if (dict) {
            [_configDict addEntriesFromDictionary:dict];
        }
    }
    return self;
}

-(NSString *)destLocation
{
    return _configDict[COMMUTE_LOCATION];
}

-(void)setDestLocation:(NSString *)destLocation
{
    _configDict[COMMUTE_LOCATION] = destLocation;
}

-(void)setLatitude:(CGFloat)latitude
{
    _configDict[COMMUTE_LATITUDE] = @(latitude);
}

-(CGFloat)latitude
{
    return [_configDict[COMMUTE_LATITUDE] floatValue];
}

-(void)setLongitude:(CGFloat)longitude
{
    _configDict[COMMUTE_LONGITUDE] = @(longitude);
}

-(CGFloat)longitude
{
    return [_configDict[COMMUTE_LONGITUDE] floatValue];
}

-(void)setDuration:(NSString *)duration
{
    _configDict[COMMUTE_DUARTION] = duration;
}

-(NSString *)duration
{
    return _configDict[COMMUTE_DUARTION];
}

-(FHCommuteType) commuteType
{
    NSNumber *type = _configDict[COMMUTE_TYPE];
    if (type) {
        return type.integerValue;
    }
    return -1;
}

-(void)setCommuteType:(FHCommuteType)commuteType
{
    _configDict[COMMUTE_TYPE] = @(commuteType);
}

-(NSString *)commuteTypeName
{
    switch (self.commuteType) {
        case FHCommuteTypeBus:
            return @"公交";
        case FHCommuteTypeDrive:
            return @"驾车";
        case FHCommuteTypeRide:
            return @"骑行";
        case FHCommuteTypeWalk:
            return @"步行";
        default:
            break;
    }
    return @"公交";    
}

-(NSString *)cityId
{
    return _configDict[COMMUTE_CITY_ID];
}

-(void)setCityId:(NSString *)cityId
{
    _configDict[COMMUTE_CITY_ID] = cityId;
}

-(void)clear
{
    [_configDict removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:COMMUTE_CONFIG];
}

-(void)sync
{
    [[NSUserDefaults standardUserDefaults] setObject:_configDict forKey:COMMUTE_CONFIG];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)tryEnterCommutePage:(NSString *)openUrl logParam:(NSDictionary *)logParam
{
    self.openUrl = openUrl;
    self.logParam = logParam;
    
    NSString *destLocation = [[FHCommuteManager sharedInstance] destLocation];
    NSString *cityId = [[FHCommuteManager sharedInstance] cityId];
    NSString *currentCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if (cityId.length == 0 || ![cityId isEqualToString:currentCityId] || destLocation.length == 0) {
        [[FHCommuteManager sharedInstance] clear];
        [self showCommuteConfigPage];
    }else{
        [self gotoCommuteList:nil];
    }
    
}

-(void)showCommuteConfigPage
{
    id delegate = WRAP_WEAK(self);
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[COMMUTE_CONFIG_DELEGATE] = delegate;
    
    NSMutableDictionary *tracer = [NSMutableDictionary new];
//    tracer[UT_ENTER_FROM] = @"renting";
//    tracer[UT_ELEMENT_FROM] = @"commuter_info";
//    tracer[UT_ORIGIN_FROM] = UT_OF_COMMUTE;

    [tracer addEntriesFromDictionary:self.logParam];
    
    
    param[TRACER_KEY] = tracer;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:param];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://commute_config"];
    [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
    
}

-(void)commuteWithDest:(NSString *)location type:(FHCommuteType)type duration:(NSString *)duration inController:(UIViewController *)controller
{
    [self gotoCommuteList:controller];
}

-(void)gotoCommuteList:(UIViewController *)popController
{
    NSURL *url = [NSURL URLWithString:_openUrl];
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:self.logParam];
    
    NSMutableDictionary *userInfoDict = [NSMutableDictionary new];
    userInfoDict[TRACER_KEY] = param;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:userInfoDict];
    if (popController) {
        __weak typeof(self) wself = self;
        [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo pushHandler:^(UINavigationController *nav, TTRouteObject *routeObj) {
            NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:nav.viewControllers];
            [controllers removeObject:popController];
            [controllers addObject:routeObj.instance];
            [nav setViewControllers:controllers animated:YES];
        }];
    }else{
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
    
    self.openUrl = nil;
    self.logParam = nil;
    
}


@end

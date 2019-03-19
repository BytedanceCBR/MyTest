//
//  FHHouseEvnContextBridgeImp.m
//  Article
//
//  Created by 谷春晖 on 2018/11/19.
//

#import "FHHouseEvnContextBridgeImp.h"
//#import "Bubble-Swift.h"
#import "FHEnvContext.h"
#import "TTTabBarManager.h"
#import "TTTabBarItem.h"
#import <FHHomeConfigManager.h>
#import <FHEnvContext.h>
#import <FHLocManager.h>
#import <ToastManager.h>
#import "ArticleURLSetting.h"
#import "TTArticleCategoryManager.h"
#import "TTCategoryBadgeNumberManager.h"
#import "TTTabBarProvider.h"
#import "TTLocationManager.h"
#import <FHUtils.h>

@implementation FHHouseEvnContextBridgeImp

-(void)setTraceValue:(NSString *)value forKey:(NSString *)key
{
    //    [[EnvContext shared] setTraceValueWithValue:value key:key];
}

-(NSDictionary *)homePageParamsMap
{
    return [[FHEnvContext sharedInstance] getGetOriginFromAndOriginId];
}

-(void)recordEvent:(NSString *)key params:(NSDictionary *)params
{
    [FHEnvContext recordEvent:params andEventKey:key];
    //    [[EnvContext shared]recordEventWithKey:key params:params];
}


-(NSString *)currentCityName
{
    return [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
    //    return [[[EnvContext shared] client] currentCityName];
}

-(NSString *)currentProvince
{
    NSString *province = [FHLocManager sharedInstance].currentReGeocode.province;
    return province;
    //    return [[[EnvContext shared] client] currentProvince];
}

- (BOOL)isCurrentTabFirst
{
    if ([[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey]) {
        return YES;
    }
    return NO;
}

-(BOOL)locationSameAsChooseCity
{
    return [FHEnvContext isSameLocCityToUserSelect];
}

-(CLLocationCoordinate2D)currentLocation
{
    return [FHLocManager sharedInstance].currentLocaton.coordinate;
    //    return [[[EnvContext shared] client] currentLocation];
}

-(NSDictionary *_Nullable)appConfig
{
    return nil;
}

-(NSDictionary *)appConfigRentOpData
{
    return nil;
}

-(void)showToast:(NSString *)toast duration:(CGFloat)duration inView:(UIView *)view
{
    return [[ToastManager manager] showToast:toast duration:duration isUserInteraction:NO];
    //    return [[[EnvContext shared]toast] showToast:toast duration:duration isUserInteraction:NO];
}

- (void)setMessageTabBadgeNumber:(NSInteger)number {
    TTTabBarItem *tabBarItem = [[TTTabBarManager sharedTTTabBarManager] tabItemWithIdentifier:kFHouseMessageTabKey];
    if(number > 0){
        tabBarItem.ttBadgeView.badgeNumber = number;
    }else{
        tabBarItem.ttBadgeView.badgeNumber = TTBadgeNumberHidden;
    }
}

- (NSString *)getRefreshTipURLString
{
    return [ArticleURLSetting refreshTipURLString];
}

- (void)updateNotifyBadgeNumber:(NSString *)categoryId isShow:(BOOL)isShow
{
    [[TTCategoryBadgeNumberManager sharedManager] updateNotifyBadgeNumberOfCategoryID:categoryId withShow:isShow];
}

//首页推荐红点请求时间间隔
- (NSInteger)getCategoryBadgeTimeInterval
{
    return [SSCommonLogic categoryBadgeTimeInterval];
}

- (NSString *)getCurrentSelectCategoryId
{
    NSString * currentCategoryName = [TTArticleCategoryManager currentSelectedCategoryID];
    return currentCategoryName;
}

- (NSString *)getFeedStartCategoryName
{
    NSString * categoryStartName = [SSCommonLogic feedStartCategory];
    return categoryStartName;
}

- (void)setUpLocationInfo:(NSDictionary *)dict
{
    [[TTLocationManager sharedManager] setUpAmapInfo:dict];
}

- (BOOL)isNeedSwitchCityCompare
{
    NSInteger daysCount = [SSCommonLogic configSwitchTimeDaysCount];
    
    if (daysCount == 0) {
        return YES;
    }
    
    NSString *stringDate = (NSString *)[FHUtils contentForKey:@"f_save_switch_local_time"];
    if(stringDate)
    {
        NSDate *saveDate = [FHUtils dateFromString:stringDate];
        
        NSInteger timeCount = [FHUtils numberOfDaysWithFromDate:saveDate toDate:[NSDate date]];
        
        if (timeCount >= daysCount) {
            return YES;
        }else
        {
            return NO;
        }
    }
    
    return YES;
}


@end

//
//  TTLBSServiceLogicManager.m
//  Article
//
//  Created by 王双华 on 17/2/17.
//
//

#import "TTLBSServiceLogicManager.h"
#import "TTNetworkUtilities.h"
#import "CommonURLSetting.h"
#import "SSLocationPickerController.h"
#import "SSDebugViewController.h"
#import "TTFetchGuideSettingManager.h"
#import "ArticleCategoryManager.h"
#import "TTLocationCommandItem.h"
#import "TTThemedAlertController.h"
#import "ExploreExtenstionDataHelper.h"
#import "TTNetworkManager.h"
#import "SSHorizenScrollView.h"
#import "TTAuthorizeManager.h"
#import "TTLocationFeedback.h"
#import "TTUIResponderHelper.h"

@implementation TTLBSServiceLogicManager

+ (void)uploadUserCityWithName:(NSString *)name completionHandler:(void(^)(NSError *))completionHandler {
    NSMutableDictionary *parameters = [[TTNetworkUtilities commonURLParameters] mutableCopy];
    NSMutableDictionary *cityParameters = [NSMutableDictionary dictionaryWithCapacity:2];
    if (!isEmptyString(name)) {
        cityParameters[@"city_name"] = name;
    }
    cityParameters[@"submit_time"] = @([[NSDate date] timeIntervalSince1970]);
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:cityParameters options:NSJSONWritingPrettyPrinted error:&error];
    if (!error && JSONData.length > 0) {
        NSString *csinfo = [[JSONData tt_dataWithFingerprintType:(TTFingerprintTypeXOR)] ss_base64EncodedString];
        if (!isEmptyString(csinfo)) {
            parameters[@"csinfo"] = csinfo;
        }
    }
    
    NSString * url = [[NSURL tt_URLWithString:[CommonURLSetting uploadUserCityURLString] parameters:@{@"timestamp": @([[NSDate date] timeIntervalSince1970])}] absoluteString];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:parameters method:@"POST" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

- (void)registerLBSServiceManagerDelegate
{
    [TTLBSService sharedService].delegate = self;
}

#pragma mark -- TTLBSServiceLogicDelegate

- (NSDictionary *)getCommonURLParameters
{
    return [TTNetworkUtilities commonURLParameters];
}

- (NSString *)getUploadLocationURLString
{
    return [CommonURLSetting uploadLocationURLString];
}

- (CLLocationCoordinate2D)getCachedFakeLocationCoordinate
{
    CLLocationCoordinate2D coordinate = [SSLocationPickerController cachedFakeLocationCoordinate];
    return coordinate;
}

- (NSTimeInterval)getMinimumLocationUploadTimeInterval
{
    return [SSCommonLogic minimumLocationUploadTimeInterval];
}

- (BOOL)isSupportDebug
{
    return [SSDebugViewController supportDebugSubitem:SSDebugSubitemFakeLocation];
}

- (void)applicationDidFinishLaunching{
    //判断是否从弹窗控制接口获取过弹窗控制策略
    if([TTFetchGuideSettingManager sharedInstance_tt].isSystemAuthorizationFlagEnabled){
        [[TTLBSService sharedService] reportLocationIfNeeded];
    }
}

- (void)applicationWillEnterForeground
{
    if([TTFetchGuideSettingManager sharedInstance_tt].isSystemAuthorizationFlagEnabled){
        [[TTLBSService sharedService] reportLocationIfNeeded];
        [[TTLBSService sharedService] processLocationCommandIfNeeded];
    }
}

- (void)changeCityAutomatically:(TTLocationCommandItem *)commandItem;
{
    ArticleCategoryManager *manager = [ArticleCategoryManager sharedManager];
    manager.localCategory.name = commandItem.currentCity;
    [manager save];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kArticleCityDidChangedNotification" object:self];
}

- (id)changeCityWithAlertConfirm:(TTLocationCommandItem *)commandItem
{
    NSString *message = commandItem.alertTitle;
    if (isEmptyString(message)) {
        message = [NSString stringWithFormat:@"自动切换至当前城市「%@」，智能推荐当地资讯", commandItem.currentCity];
    }
    TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"切换城市" message:message preferredType:TTThemedAlertControllerTypeAlert];
    WeakSelf;
    [alertController addActionWithTitle:@"切换" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        StrongSelf;
        NSString *cityName = commandItem.currentCity;
        [[self class] uploadUserCityWithName:cityName completionHandler:^(NSError *error) {
            if (!error) {
                ArticleCategoryManager *manager = [ArticleCategoryManager sharedManager];
                manager.localCategory.name = cityName;
                [manager save];
                [ArticleCategoryManager setUserSelectedLocalCity];
                [ExploreExtenstionDataHelper saveSharedUserSelectCity:cityName];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kArticleCityDidChangedNotification" object:self];
            }
        }];
        ssTrackEvent(@"pop", @"locate_change_category_open");
    }];
    [alertController addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        ssTrackEvent(@"pop", @"locate_change_category_cancel");
        if (!isEmptyString(commandItem.identifier)) {
            NSMutableDictionary *parameters = [[TTNetworkUtilities commonURLParameters] mutableCopy];
            [parameters setValue:commandItem.identifier forKey:TTLocationID];
            
            NSString * url = [[NSURL tt_URLWithString:[CommonURLSetting locationCancelURLString] parameters:@{@"timestamp": @([[NSDate date] timeIntervalSince1970])}] absoluteString];
            [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:parameters method:@"POST" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
                // do nothing
            }];
        }
    }];
    [alertController showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
    ssTrackEvent(@"pop", @"locate_change_category_show");
    return alertController;
}

- (BOOL)canChangeCityWithAlertConfirm:(TTLocationCommandItem *)commandItem
{
    BOOL canChange = ![[ArticleCategoryManager sharedManager].localCategory.name isEqualToString:commandItem.currentCity];
    if (canChange && [self isInMainListView]) {
        return YES;
    }
    return NO;
}

- (BOOL)isInMainListView {
    UIViewController *rootViewController = [TTUIResponderHelper topmostViewController];
    NSArray *listViews = [rootViewController.view viewWithClass:[SSHorizenScrollView class]];
    if (SSIsEmptyArray(listViews)) {
        return NO;
    }
    SSHorizenScrollView *mixedListView = [listViews firstObject];
    if (mixedListView.window) {
        return YES;
    }
    return NO;
}

- (id)permissionDenied
{
     return [[TTAuthorizeManager sharedManager].locationObj showAlertWhenLocationChanged:NULL];
}

- (BOOL)needAlertWithCommandItem:(TTLocationCommandItem *)commandItem feedback:(TTLocationFeedback *)feedback
{
    BOOL needAlert = NO;
    
    NSDate *lastDate = nil;
    if (commandItem.commandType == TTLocationCommandTypeChangeCityWithAlertConfirm) {
        lastDate = feedback.changeLocationAlertLastShowTime;
    }
    else if (commandItem.commandType == TTLocationCommandTypePermissionDenied) {
        lastDate = feedback.delayAlertLastShowTime;
    }
    
    if (![lastDate isKindOfClass:[NSDate class]]) {
        needAlert = YES;
    } else {
        NSTimeInterval timeElasped = [[NSDate date] timeIntervalSinceDate:lastDate];
        needAlert = (timeElasped >= [SSCommonLogic minimumLocationAlertTimeInterval]);
        
#ifdef kTestLocation
        LOGD(@"timeElasped %f  minimum %f needAlert %d",timeElasped ,[SSCommonLogic minimumLocationAlertTimeInterval],needAlert);
#endif
    }
    return needAlert;
}

- (void)processLocationCommand:(TTLocationCommandItem *)commandItem feedback:(TTLocationFeedback *)feedback  alertShowed:(BOOL)alertShowed completion:(TTCommandProcessCompletionHandle)completion
{
    BOOL timeOut = NO;
    BOOL alertShow = alertShowed;
    BOOL isOperationed = NO;
    
    NSDate *date = commandItem.date;
    if (commandItem && date) {
        /// 每个弹框5分钟超时，客户端写死
        if ([[NSDate date] timeIntervalSinceDate:date] < 300) {
            if (commandItem.currentCity)
            {
                [[TTLocationManager sharedManager] saveCityToUserDefault:commandItem.currentCity];
                switch (commandItem.commandType) {
                    case TTLocationCommandTypeChangeCityAutomatically:
                        [self changeCityAutomatically:commandItem];
                        isOperationed = YES;
                        break;
                    case TTLocationCommandTypePermissionDenied:
                        if ([self needAlertWithCommandItem:commandItem feedback:feedback] && !alertShow)
                        {
                            if (![[TTLocationManager class] isLocationServiceEnabled]) {
                                alertShow = [[self permissionDenied] boolValue];
                                isOperationed = YES;
                            }
                        }
                        break;
                    case TTLocationCommandTypeChangeCityWithAlertConfirm:
                        if ([self needAlertWithCommandItem:commandItem feedback:feedback] && !alertShow) {
                            if ([self canChangeCityWithAlertConfirm:commandItem]) {
                                alertShow = [self changeCityWithAlertConfirm:commandItem];
                                isOperationed = YES;
                            }
                        }
                        break;
                    default:
                        break;
                }
            }
        }
        else
        {
            timeOut = YES;
        }
    }
    completion(timeOut, alertShow, isOperationed);
}

- (void)regeocodeWithCompletionHandler:(void (^)(NSArray *))completionHandler
{
    [[TTAuthorizeManager sharedManager].locationObj filterAuthorizeStrategyWithCompletionHandler:completionHandler];
}

@end

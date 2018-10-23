//
//  TTAdSplashMediator.m
//  Article
//
//  Created by yin on 2017/11/13.
//

#import "TTAdSplashMediator.h"
#import "NewsBaseDelegate.h"
#import "TTAdSplashDelegate.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTTrackerProxy.h"
#import "TTNetworkHelper.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import "TTExtensions.h"
#import "UIDevice+TTAdditions.h"
#import "NSDictionary+TTAdditions.h"
#import "TTABHelper.h"
#import "TTLocationManager.h"
#import "TTABManagerUtil.h"
#import "TTURLUtils.h"
#import "TTAdTrackManager.h"
#import "TTAppLinkManager.h"
#import "TTStringHelper.h"
#import "TTRoute.h"
#import "ArticleDetailHeader.h"
#import "SSWebViewController.h"
#import "TTAdAppDownloadManager.h"
#import "SSActionManager.h"
#import "NSObject+FBKVOController.h"
#import "TTURLTracker.h"
#import "TTAdAction.h"
#import "TTAdDetailActionModel.h"
#import "TTASettingConfiguration.h"

const static NSInteger splashCallbackPatience = 30000; // 从第三方app召回最长忍耐时间 30 000ms

@interface TTAdSplashMediator()<TTAdSplashDelegate>

@end

@implementation TTAdSplashMediator

+ (TTAdSplashMediator *)shareInstance
{
    static TTAdSplashMediator * adMediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adMediator = [[self alloc] init];
    });
    return adMediator;
}

- (BOOL)displaySplashOnWindow:(UIView *)keyWindow splashShowType:(TTAdSplashShowType)type
{
    if ([TTAdSplashMediator useSplashSDK]) {
        static dispatch_once_t once_t;
        dispatch_once(&once_t, ^{
            [TTAdSplashMediator registerParamas];
        });
        
        [TTAdSplashManager shareInstance].ignoreFirstLaunch = NO;
        [[TTAdSplashManager shareInstance] displaySplashOnWindow:keyWindow splashShowType:type];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self detectCallbackFromThirdApp];
        });
    }
    else{
        
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        if ([adManagerInstance splashADShowType] != SSSplashADShowTypeIgnore) {
            if (!SharedAppDelegate.window.rootViewController) {
                UIViewController *blankVC = [[UIViewController alloc] init];
                UIImageView *bgView = [[UIImageView alloc] initWithFrame:blankVC.view.bounds];
                
                [bgView setImage:[TTAdSplashMediator splashImageForPrefix:@"Default" extension:@"png"]];
                bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [blankVC.view addSubview:bgView];
                SharedAppDelegate.window.rootViewController = blankVC;
            }
            if ([TTDeviceHelper isPadDevice] && [TTDeviceHelper OSVersionNumber] < 8) {
                [adManagerInstance applicationDidBecomeActiveShowOnWindow:SharedAppDelegate.window splashShowType:adManagerInstance.splashADShowType];
            }
            else {
                [adManagerInstance applicationDidBecomeActiveShowOnWindow:SharedAppDelegate.window splashShowType:adManagerInstance.splashADShowType];
            }
        }else{
            LOGD(@"ingore....");
        }
        LOGD(@"ingore....");
        [adManagerInstance setSplashADShowType:SSSplashADShowTypeIgnore];
    }
    return YES;
}

+ (void)registerParamas
{
    [[TTAdSplashManager shareInstance] registerDelegate:[TTAdSplashMediator shareInstance] paramsBlock:^NSDictionary *{
        float scale = [[UIScreen mainScreen] scale];
        NSString * displayDensity = [NSString stringWithFormat:@"%ix%i", (int)([TTUIResponderHelper screenSize].width * scale), (int)([TTUIResponderHelper screenSize].height * scale)];
        NSString *ipString = [[[TTNetworkHelper getIPAddresses] allValues] firstObject];
        TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItem;
        NSMutableDictionary *dict = [@{} mutableCopy];
        
        [dict setValue:[TTDeviceHelper openUDID] forKey:TT_OPEN_UDID];
        [dict setValue:displayDensity forKey:TT_DIS_DENSITY];
        [dict setValue:[TTExtensions carrierName] forKey:TT_CARRIER];
        [dict setValue:[TTNetworkHelper carrierMNC] forKey:TT_MCC_MNC];
        [dict setValue:[TTSandBoxHelper getCurrentChannel] forKey:TT_CHANNEL];
        [dict setValue:[TTSandBoxHelper ssAppID] forKey:TT_APP_ID];
        [dict setValue:[TTSandBoxHelper appName] forKey:TT_APP_NAME];
        [dict setValue:[TTSandBoxHelper versionName] forKey:TT_VERSION_CODE];
        [dict setValue:[TTExtensions buildVersion] forKey:TT_UPDATE_VERSION];
        [dict setValue:[TTDeviceHelper platformName] forKey:TT_DEVICE_PLATFORM];
        [dict setValue:[UIDevice currentDevice].platformString forKey:TT_DEVICE_TYPE];
        [dict setValue:[TTDeviceHelper currentLanguage] forKey:TT_LANGUAGE];
        [dict setValue:[[UIDevice currentDevice] systemVersion] forKey:TT_OS_VERSION];
        [dict setValue:[TTDeviceHelper resolutionString] forKey:TT_RESOLUTION];
        [dict setValue:[TTDeviceHelper MACAddress] forKey:TT_MAC_ADDRESS];
        [dict setValue:[TTSandBoxHelper versionName] forKey:TT_OS];
        [dict setValue:ipString forKey:TT_IP_ADDRESS];
        [dict setValue:@(placemarkItem.coordinate.latitude) forKey:TT_LATITUDE];
        [dict setValue:@(placemarkItem.coordinate.longitude) forKey:TT_LONGITUDE];
        [dict setValue:[TTDeviceHelper idfvString] forKey:TT_IDFV];
#ifndef SS_TODAY_EXTENSTION
        [dict setValue:[[TTABHelper sharedInstance_tt] ABVersion] forKey:TT_AB_VERSION];
        [dict setValue:[[TTABHelper sharedInstance_tt] ABFeature] forKey:TT_AB_FEATURE];
        [dict setValue:[[TTABHelper sharedInstance_tt] ABGroup] forKey:TT_AB_GROUP];
        [dict setValue:[TTABManagerUtil ABTestClient] forKey:TT_AB_CLIENT];
#endif
        return dict;
    }];
}

- (void)didEnterBackground
{
    if (![TTAdSplashMediator useSplashSDK]) {
        [[SSADManager shareInstance] didEnterBackground];
    }
}

#pragma mark -- TTAdSplashDelegate

- (void)requestWithUrl:(NSString *)urlString responseBlock:(TTAdSplashResponseBlock)responseBlock
{
    [[TTNetworkManager shareInstance] requestForBinaryWithResponse:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj, TTHttpResponse *response) {
        responseBlock(obj, error,response.statusCode);
    }];

}


- (NSString *)splashBaseUrl
{
    return [CommonURLSetting baseURL];
}

- (NSString *)deviceId
{
    return [[TTInstallIDManager sharedInstance] deviceID];
}


- (NSString *)installId
{
    return [[TTInstallIDManager sharedInstance] installID];
}


- (NSNumber *)ntType
{
    return @([[TTTrackerProxy sharedProxy] connectionType]);
}

- (NSString *)splashNetwokType
{
    return [TTNetworkHelper connectMethodName];
}

- (NSString *)splashBgImageName
{
    NSString *imgName = @"LaunchImage-800-Portrait-736h@3x.png";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        imgName = @"LaunchImage-800-Portrait-736h@3x.png";
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 &&
        ([UIScreen mainScreen].bounds.size.height == 480)) {
        imgName = @"LaunchImage-700@2x.png";
    }
    return imgName;
}

- (NSString *)splashVideoLogoName
{
    return @"logo";
}

- (NSString *)splashWifiImageName
{
    return @"wifi_splash";
}

- (NSString *)splashViewMoreImageName
{
    return @"viewicon_splash";
}

- (NSString *)splashArrowImageName
{
    return @"right_arrow_ad";
}

- (void)splashViewWillAppear
{
    
}

- (void)splashViewDidDisappear
{
    
}

- (void)trackWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra
{
    [TTAdTrackManager trackWithTag:tag label:label value:nil extraDic:extra];
}


- (void)trackURLs:(NSArray *)URLs dict:(NSDictionary *)trackDict
{
    NSString *ad_id = [trackDict valueForKey:TT_ADID];
    NSString *log_extra = [trackDict valueForKey:TT_LOG_EXTRA];
    TTURLTrackerModel *trackModel = [[TTURLTrackerModel alloc] initWithAdId:ad_id logExtra:log_extra];
    ttTrackURLsModel(URLs, trackModel);
}

- (void)splashActionWithCondition:(NSDictionary *)condition
{
    NSString *ad_id = [condition valueForKey:TT_ADID];
    NSString *log_extra = [condition valueForKey:TT_LOG_EXTRA];
    NSNumber *display_viewbutton = [condition valueForKey:TT_DISPLAY_VIEWBUTTON];
    NSString *open_url = [condition valueForKey:TT_OPEN_URL];
    NSString *web_url = [condition valueForKey:TT_WEB_URL];
    NSString *app_open_url = [condition valueForKey:TT_OPEN_URL];
    BOOL click_banner = [condition tt_boolValueForKey:TT_CLICK_BANNER];
    BOOL result = NO;
    NSString * const sourceTag = @"splash_ad";
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:1];
    [extra setValue:log_extra forKey:@"log_extra"];
    [extra setValue:@"1" forKey:@"is_ad_event"];
    if (display_viewbutton.integerValue == TTSplashClikButtonStyleStripAction && click_banner) {//banner区域支持调起三方app,使用app_open_url
        result = [TTAppLinkManager dealWithWebURL:web_url openURL:app_open_url sourceTag:sourceTag value:ad_id extraDic:extra];
    }
    else{//普通区域都支持调起三方app,使用open_url
        result = [TTAppLinkManager dealWithWebURL:web_url openURL:open_url  sourceTag:sourceTag value:ad_id extraDic:extra];
    }
    if (result) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self markLaunchThirdApp:ad_id logExtra:log_extra];
        });
    }
    if (!result) {
        [self performActionForSplashADModel:condition];
    }
}

- (void)performActionForSplashADModel:(NSDictionary *)condition {
    
    if (emptyDictionary(condition)) {
        return;
    }
    NSString *ad_id = [condition valueForKey:TT_ADID];
    NSString *log_extra = [condition valueForKey:TT_LOG_EXTRA];
    NSString *open_url = [condition valueForKey:TT_OPEN_URL];
    NSString *web_url = [condition valueForKey:TT_WEB_URL];
    NSString *web_title = [condition valueForKey:TT_WEB_TITLE];
    NSString *actionType = [condition valueForKey:TT_ACTION_TYPE];
    NSString *appleid = [condition valueForKey:TT_APPLE_ID];
    NSString *download_url = [condition valueForKey:TT_DOWN_URL];
    if (!isEmptyString(open_url) && [[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:open_url]]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
        [params setValue:@"splash" forKey:@"gd_label"];
        [params setValue:@(NewsGoDetailFromSourceSplashAD) forKey:kNewsGoDetailFromSourceKey];
        [params setValue:ad_id forKey:@"ad_id"];
        [params setValue:log_extra forKey:@"log_extra"];
        
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:open_url] userInfo:TTRouteUserInfoWithDict(params)];
    }
    else if ([actionType isEqualToString:@"web"] && !isEmptyString(web_url)) {
        NSMutableDictionary *conditions = [NSMutableDictionary dictionaryWithCapacity:5];
        [conditions setValue:@"splash" forKey:@"gd_label"];
        [conditions setValue:@(NewsGoDetailFromSourceSplashAD) forKey:kNewsGoDetailFromSourceKey];
        TTAdDetailActionModel *actionModel = [[TTAdDetailActionModel alloc] initWithAdId:ad_id logExtra:log_extra webUrl:web_url openUrl:open_url webTitle:web_title extraDict:conditions];
        [TTAdAction handleWebActionModel:actionModel];
    }
    else if ([actionType isEqualToString:@"app"] && !isEmptyString(download_url)) {
        if (appleid.length && [SSCommonLogic isAppPreloadEnable]) {
            [[TTAdAppDownloadManager sharedManager] initStayTrackerWithAd_id:ad_id log_extra:log_extra];
        }
        TTAdAppModel *model = [[TTAdAppModel alloc] init];
        model.ad_id = ad_id;
        model.log_extra = log_extra;
        model.open_url = open_url;
        model.download_url = download_url;
        model.apple_id = appleid;
        [TTAdAppDownloadManager downloadApp:model];
    }
    else {
        //do nothing
    }
}

//统计app_open_url跳出头条到回来的时长间隔
- (void)markLaunchThirdApp:(NSString *)adId logExtra:(NSString *)logExtra {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:3];
    [extra setValue:adId forKey:@"value"];
    [extra setValue:logExtra forKey:@"log_extra"];
    [extra setValue:@(now) forKey:kAdSpalshOpenURLLeave];
    [[NSUserDefaults standardUserDefaults] setObject:extra forKey:kAdSpalshOpenURLLeave];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)detectCallbackFromThirdApp {
    NSDictionary *lastGoAwayExtra = [[NSUserDefaults standardUserDefaults] objectForKey:kAdSpalshOpenURLLeave];
    if (lastGoAwayExtra && [lastGoAwayExtra isKindOfClass:[NSDictionary class]]) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval lastGoAway = [lastGoAwayExtra tt_doubleValueForKey:kAdSpalshOpenURLLeave]; //内层key
        NSInteger duration = (NSInteger)((now - lastGoAway) * 1000); //ms
        if (duration > 0 && duration <= splashCallbackPatience) {
            NSMutableDictionary *lastExtra = [lastGoAwayExtra mutableCopy];
            [lastExtra removeObjectForKey:kAdSpalshOpenURLLeave];
            NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:3];
            [extra setValue:@(duration) forKey:@"duration"];
            if (lastExtra) {
                [extra addEntriesFromDictionary:lastExtra];
            }
            [self eventTrack4ImageADActionButtonCallBack:extra];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAdSpalshOpenURLLeave];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)eventTrack4ImageADActionButtonCallBack:(NSDictionary *)extra {
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:4];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:@"splash_ad" forKey:@"tag"];
    [events setValue:@"open_url_appback" forKey:@"label"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [events setValue:@(connectionType) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    if (!SSIsEmptyDictionary(extra)) {
        [events addEntriesFromDictionary:extra];
    }
    [TTTrackerWrapper eventData:events];
}


#pragma mark --getter & setter

- (void)setSplashADShowType:(TTAdSplashShowType)splashADShowType
{
    if ([TTAdSplashMediator useSplashSDK]) {
        [TTAdSplashManager shareInstance].splashADShowType = splashADShowType;
    }
    else{
        [SSADManager shareInstance].splashADShowType = (SSSplashADShowType)splashADShowType;
    }
}

- (TTAdSplashShowType)splashADShowType
{
    if ([TTAdSplashMediator useSplashSDK]) {
        return [TTAdSplashManager shareInstance].splashADShowType;
    }
    else{
        return (TTAdSplashShowType)[SSADManager shareInstance].splashADShowType;
    }
    return [TTAdSplashManager shareInstance].splashADShowType;
}

- (TTAdSplashResouceType)resouceType
{
    if ([TTAdSplashMediator useSplashSDK]) {
        return [TTAdSplashManager shareInstance].resouceType;
    }
    else{
        return (TTAdSplashResouceType)[SSADManager shareInstance].resouceType;
    }
    return [TTAdSplashManager shareInstance].resouceType;
}

- (BOOL)showByForground
{
    if ([TTAdSplashMediator useSplashSDK]) {
        return [TTAdSplashManager shareInstance].showByForground;
    }
    else{
        return [SSADManager shareInstance].showByForground;
    }
    return [TTAdSplashManager shareInstance].showByForground;
}

- (void)setShowByForground:(BOOL)showByForground
{
    if ([TTAdSplashMediator useSplashSDK]) {
        [TTAdSplashManager shareInstance].showByForground = showByForground;
    }
    else{
        [SSADManager shareInstance].showByForground = showByForground;
    }
}

- (BOOL)adWillShow
{
    if ([TTAdSplashMediator useSplashSDK]) {
        return [TTAdSplashManager shareInstance].adWillShow;
    }
    else{
        return [SSADManager shareInstance].adShow;
    }
    return [TTAdSplashManager shareInstance].adWillShow;
}

- (BOOL)isAdShowing
{
    if ([TTAdSplashMediator useSplashSDK]) {
        return [TTAdSplashManager shareInstance].isAdShowing;
    }
    else{
        return [SSADManager shareInstance].isSplashADShowed;
    }
    return [TTAdSplashManager shareInstance].isAdShowing;
}

- (BOOL)finishCheck
{
    if ([TTAdSplashMediator useSplashSDK]) {
        return [TTAdSplashManager shareInstance].finishCheck;
    }
    else{
        return [SSADManager shareInstance].finishCheck;
    }
    return [TTAdSplashManager shareInstance].finishCheck;
}

- (BOOL)discardAd:(NSArray<NSString *> *)adIDs
{
    if ([TTAdSplashMediator useSplashSDK]) {
        return [[TTAdSplashManager shareInstance] discardAd:adIDs];
    }
    return [[SSADManager shareInstance] discardAd:adIDs];
}

+ (BOOL)useSplashSDK
{
    return ttas_isSplashSDKEnable();
}

+ (void)clearResouceCache
{
    if ([TTAdSplashMediator useSplashSDK]) {
        [TTAdSplashManager clearResouceCache];
    }
}


+ (UIImage *)splashImageForPrefix:(NSString*)prefix extension:(NSString*)extension
{
    NSMutableString *imageName = [NSMutableString stringWithString:prefix];
    if (![TTDeviceHelper isPadDevice])
    {
        if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen])
        {
            [imageName appendString:@"-568h"];
        }
        else if([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice])
        {
            [imageName appendString:@"-667h"];
        }
        else if([TTDeviceHelper is736Screen])
        {
            [imageName appendString:@"-736h"];
        }
    }
    else {
        if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        {
            [imageName appendString:@"-Portrait"];
        }
        else
        {
            [imageName appendString:@"-Landscape"];
        }
    }
    
    if(isEmptyString(extension)) extension = @"png";
    [imageName appendFormat:@".%@", extension];
    return [UIImage imageNamed:imageName];
}

@end

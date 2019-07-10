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
#import <TTABManager/TTABHelper.h>
#import "TTLocationManager.h"
#import <TTABManager/TTABManagerUtil.h>
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
#import "TTAdCanvasPreloader.h"
#import "FHLocManager.h"
#import "FHEnvContext.h"
#import "TTAdSplashManager+request.h"
#import <TTBaseLib/TTSandBoxHelper.h>
#import <TTMonitor/TTMonitor.h>
#import <TTArticleBase/SSCommonLogic.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>

const static NSInteger splashCallbackPatience = 30000; // 从第三方app召回最长忍耐时间 30 000ms

@interface TTAdSplashMediator()<TTAdSplashDelegate>

@property (nonatomic, assign) BOOL isNotFirst;

@property (nonatomic, assign) BOOL isNotClicked;

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

- (BOOL)displaySplashOnWindow:(UIView *)keyWindow splashShowType:(TTAdSplashShowType)type {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [TTAdSplashMediator registerParamas];
        [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
            if (_isNotFirst) {
                [TTAdSplashManager clearResouceCache];
                [[TTAdSplashManager shareInstance] fetchADControlInfo];
            }
            _isNotFirst = YES;
        }];
    });
    
    [TTAdSplashManager shareInstance].ignoreFirstLaunch = NO;
    [TTAdSplashManager shareInstance].enableMonitor = YES;
    [[TTAdSplashManager shareInstance] displaySplashOnWindow:keyWindow splashShowType:type];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self detectCallbackFromThirdApp];
    });
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
        [dict setValue:[[TTInstallIDManager sharedInstance] installID] forKey:TT_IID];
        [dict setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:TT_DEVICE_ID];
        
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

}

- (BOOL)ignoreFirstLaunch {
    return NO;
}

//端监控
- (void)monitorService:(NSString *)serviceName status:(NSUInteger)status extra:(NSDictionary *)extra
{
    [[TTMonitor shareManager] trackService:serviceName status:status extra:extra];
}

- (void)monitorService:(NSString *)serviceName value:(NSDictionary *)params extra:(NSDictionary *)extra{
    [[TTMonitor shareManager] trackService:serviceName value:params extra:extra];
}

- (BOOL)enableTrackV3Format {
    return YES;
}

- (void)trackV3WithEvent:(NSString *)event params:(NSDictionary *)params isDoubleSending:(BOOL)isDoubleSending {
    if (params) {
        [params setValue:[TTSandBoxHelper ssAppID] forKey:TT_APP_ID];
        [params setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
        [params setValue:[TTExtensions buildVersion] forKey:@"app_version"];
        [params setValue:[TTSandBoxHelper getCurrentChannel] forKey:@"app_channel"];
        [params setValue:[FHLocManager sharedInstance].currentReGeocode.city forKey:@"city_name"];
        [params setValue:[FHLocManager sharedInstance].currentReGeocode.province forKey:@"province_name"];
        [TTTracker eventV3:event params:params];
    }
}

#pragma mark -- TTAdSplashDelegate

- (void)requestWithUrl:(NSString *)urlString responseBlock:(TTAdSplashResponseBlock)responseBlock
{
    [[TTNetworkManager shareInstance] requestForBinaryWithResponse:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        responseBlock(obj, error,response.statusCode);
    }];
}

//设置域名,app实现选路
- (NSString *)splashBaseUrl
{
    return @"http://i.haoduofangs.com";
}

//接入方可自由定制path,拼接后url:https://is.snssdk.com/api/ad/splash/news_article_inhouse/v15/
- (NSString *)splashPathUrl
{
    return @"f100/api/ad/splash";
}

- (BOOL)enableSplashGifKadunOptimize {
    return YES;
}

- (NSString *)deviceId
{
    return [[TTInstallIDManager sharedInstance] deviceID];
}


- (NSString *)installId
{
    return [[TTInstallIDManager sharedInstance] installID];
}

- (NSString *)splashSkipBtnName
{
    return @"跳过";
}

- (NSNumber *)ntType
{
    return @([[TTTrackerProxy sharedProxy] connectionType]);
}

- (NSString *)splashNetwokType
{
    return [TTNetworkHelper connectMethodName];
}

- (UIImage *)splashBgImage
{
    NSString *imgName = @"LaunchImage-800-Portrait-736h";
    if ([TTDeviceHelper is667Screen]) {
        imgName = @"LaunchImage-800-667h";
    }
    if ([TTDeviceHelper is568Screen]) {
         imgName = @"LaunchImage-700-568h";
    }
    if ([TTDeviceHelper is812Screen]) {
        imgName = @"LaunchImage-1100-Portrait-2436h";
    }
    if ([TTDeviceHelper is896Screen2X]) {
        imgName = @"LaunchImage-1200-Portrait-1792h";
    }
    if ([TTDeviceHelper is896Screen3X]) {
        imgName = @"LaunchImage-1200-Portrait-2688h";
    }
    return [UIImage imageNamed:imgName];
}

- (UIImage *)splashVideoLogo
{
    return [UIImage imageNamed:@"logo"];
}

- (UIImage *)splashWifiImage
{
    return [UIImage imageNamed:@"wifi_splash"];
}

- (UIImage *)splashViewMoreImage
{
    return [UIImage imageNamed:@"viewicon_splash"];
}

- (UIImage *)splashArrowImage
{
    return [UIImage imageNamed:@"right_arrow_ad"];
}

- (void)splashViewWillAppear
{
    [FHLocManager sharedInstance].isShowSplashAdView = YES;
    self.isNotClicked = NO;
}

- (void)splashViewDidDisappear
{
    FHConfigDataModel *model = [[FHEnvContext sharedInstance] getConfigFromCache];
    if ([FHLocManager sharedInstance].isShowSwitch) {
        if ([model.citySwitch.enable respondsToSelector:@selector(boolValue)] && [model.citySwitch.enable boolValue]) {
            [[FHLocManager sharedInstance] showCitySwitchAlert:[NSString stringWithFormat:@"是否切换到当前城市:%@",model.citySwitch.cityName] openUrl:model.citySwitch.openUrl];
        }
    }
    
//    if (self.adShowCompletion) {
//        self.adShowCompletion(self.isNotClicked);
//    }
//
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
    
    self.isNotClicked = YES;
    
    if (!isEmptyString(open_url) && [[[TTStringHelper URLWithURLString:open_url] host] isEqualToString:@"main"]) {
        //处理开屏点击后进入其他tab的逻辑
        NSURL *handledOpenURL = [TTStringHelper URLWithURLString:open_url];
        TTRouteParamObj* obj = [[TTRoute sharedRoute] routeParamObjWithURL:handledOpenURL];
        NSDictionary* params = [obj queryParams];
        if (params != nil) {
            NSString* target = params[@"select_tab"];
            if (target != nil && target.length > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TTArticleTabBarControllerChangeSelectedIndexNotification" object:nil userInfo:@{@"tag": target}];
            } else {
                NSAssert(false, @"开屏广告的tag为空");
            }
        }
    }
    else if (!isEmptyString(open_url) && [[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:open_url]]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
        [params setValue:@"splash" forKey:@"gd_label"];
        [params setValue:@(NewsGoDetailFromSourceSplashAD) forKey:kNewsGoDetailFromSourceKey];
        [params setValue:ad_id forKey:@"ad_id"];
        [params setValue:log_extra forKey:@"log_extra"];
        
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:open_url] userInfo:TTRouteUserInfoWithDict(params)];
    }
    else if ([actionType isEqualToString:@"web"] && !isEmptyString(web_url) && [web_url hasPrefix:@"http"]) {
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

- (void)downloadCanvasResource:(NSDictionary *)dict {
   // 沉浸式广告需要的内容 暂时不需要实现
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
    [TTAdSplashManager shareInstance].splashADShowType = splashADShowType;
}

- (TTAdSplashShowType)splashADShowType
{
    return [TTAdSplashManager shareInstance].splashADShowType;
}

- (TTAdSplashResouceType)resouceType
{
    return [TTAdSplashManager shareInstance].resouceType;
}

- (BOOL)showByForground
{
    return [TTAdSplashManager shareInstance].showByForground;
}

- (void)setShowByForground:(BOOL)showByForground
{
    [TTAdSplashManager shareInstance].showByForground = showByForground;
}

- (BOOL)adWillShow
{
    return [TTAdSplashManager shareInstance].adWillShow;
}

- (BOOL)isAdShowing
{
    return [TTAdSplashManager shareInstance].isAdShowing;
}

- (BOOL)finishCheck
{
    return [TTAdSplashManager shareInstance].finishCheck;
}

- (BOOL)discardAd:(NSArray<NSString *> *)adIDs
{
    return [[TTAdSplashManager shareInstance] discardAd:adIDs];
}

+ (BOOL)useSplashSDK
{
    return YES;
}

+ (void)clearResouceCache
{
    [TTAdSplashManager clearResouceCache];
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

- (NSUInteger)logoAreaHeight {
    if (![TTDeviceHelper isPadDevice])
    {
        if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen])
        {
            return 218;
        }
        else if([TTDeviceHelper is667Screen])
        {
            return 246;
        }
        else if([TTDeviceHelper is736Screen])
        {
            return 394;
        }
        else if ([TTDeviceHelper isIPhoneXDevice])
        {
            return 406;
        }
    }
    else {
        if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        {
            //区分 单双倍屏
            if ([TTDeviceHelper screenScale] == 2.f) {
                return 360;
            } else {
                return 180;
            }
        }
        else
        {
            //区分 单双倍屏
            if ([TTDeviceHelper screenScale] == 2.f) {
                return 262;
            } else {
                return 131;
            }
        }
    }
    return 0;
}

- (NSUInteger)skipButtonCenterYOffset {
    if (![TTDeviceHelper isPadDevice])
    {
        if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen])
        {
            return 47;
        }
        else if([TTDeviceHelper is667Screen])
        {
            return 65;
        }
        else if([TTDeviceHelper is736Screen])
        {
            return 70;
        }
        else if ([TTDeviceHelper isIPhoneXDevice])
        {
            return 74;
        }
    }
    else {
        if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        {
            //区分 单双倍屏
            if ([TTDeviceHelper screenScale] == 2.f) {
                return 107;
            } else {
                return 106;
            }
        }
        else
        {
            //区分 单双倍屏
            if ([TTDeviceHelper screenScale] == 2.f) {
                return 79;
            } else {
                return 72;
            }
        }
    }
    return 0;
}

@end

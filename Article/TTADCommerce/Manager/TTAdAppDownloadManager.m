//
//  TTAdAppDownloadManager.m
//  Article
//
//  Created by yin on 2017/1/4.
//
//

#import "TTAdAppDownloadManager.h"

#import <StoreKit/StoreKit.h>
#import "TTTrackerProxy.h"
#import "TTRoute.h"
#import "SSAppStore.h"
#import "TTIndicatorView.h"
#import "TTAdMonitorManager.h"
#import "TTAdTrackManager.h"
#import "TTAppLinkManager.h"
#import "SSCommonLogic.h"

#define separtor @"://"

@implementation TTAdAppModel

- (NSString<Optional>*)appUrl
{
    NSString* app_url = nil;
    NSRange seperateRange = [_open_url rangeOfString:separtor];
    if (seperateRange.length > 0) {
        app_url = [_open_url substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];
    }
    else {
        app_url = _open_url;
    }
    return app_url;
}

- (NSString<Optional>*)tabUrl
{
    if ([_open_url rangeOfString:separtor].location!=NSNotFound) {
        NSRange seperateRange = [_open_url rangeOfString:separtor];
        NSInteger length = [_open_url length] - NSMaxRange(seperateRange);
        if (!isEmptyString(_open_url)&&length>0) {
            NSRange range = NSMakeRange(NSMaxRange(seperateRange), length);
            NSString* tab_url = [_open_url substringWithRange:range];
            return tab_url;
        }
    }
    return nil;
}

@end


@interface TTAdSKVC : NSObject

@property (nonatomic, strong) SKStoreProductViewController* skController;
@property (nonatomic, strong) NSString* appleId;
@property (nonatomic, assign) BOOL loadFinish;

@end


@implementation TTAdSKVC

- (instancetype)initWithAppleId:(NSString*)appleId
{
    self = [super init];
    if (self) {
        _skController = [[SKStoreProductViewController alloc] init];
        
        _appleId = appleId;
    }
    return self;
}

- (void)dealloc
{
    
}

@end


@interface TTAdAppDownloadManager()<SKStoreProductViewControllerDelegate, TTAppStoreProtocol>

@property (nonatomic, strong) NSString* appleId;
@property (nonatomic, copy)  NSString* ad_id;
@property (nonatomic, copy)  NSString* log_extra;
// 统计stay_page时用来记录ad_id的字段，为了防止干扰原有逻辑新增一个字段
@property (nonatomic, copy)  NSString* ad_id_for_tracker;

@property (nonatomic, strong) TTAdSKVC* skVc;
@property (nonatomic, assign) BOOL isPreloading;
// 控制skcontroller的退出时是否做动画
@property (nonatomic, assign) BOOL dissmissAnimated;
@property (nonatomic, assign) BOOL skVCAppear;  //skVC是否推出

@end

@implementation TTAdAppDownloadManager

+ (void)load
{
    [[SSAppStore shareInstance] registerService:[TTAdAppDownloadManager sharedManager]];
}

+ (instancetype)sharedManager{
    static TTAdAppDownloadManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        _sharedManager.isPreloading = NO;
        _sharedManager.dissmissAnimated = YES;
    });
    return _sharedManager;
}

+ (void)downloadAppDict:(NSDictionary *)dict
{
    TTAdAppModel* appModel = [[TTAdAppModel alloc] init];
    appModel.download_url = [dict valueForKey:@"download_url"];
    appModel.apple_id = [dict valueForKey:@"apple_id"];
    appModel.open_url = [dict valueForKey:@"open_url"];
    appModel.ipa_url = [dict valueForKey:@"ipa_url"];
    [self downloadApp:appModel];
}

+ (BOOL)downloadApp:(id<TTAd, TTAdAppAction>) adModel {
    if (![adModel conformsToProtocol:@protocol(TTAdAppAction)] || ![adModel conformsToProtocol:@protocol(TTAd)]) {
        NSAssert([adModel conformsToProtocol:@protocol(TTAdAppAction)], @"%@ 没有实现 TTAdAppAction ", adModel);
        NSAssert([adModel conformsToProtocol:@protocol(TTAd)], @"%@ 没有实现 TTAd", adModel);
        return NO;
    }
    
    BOOL canOpenApp = NO;
    if (!isEmptyString(adModel.open_url)) {
        NSURL *openURL = [TTStringHelper URLWithURLString:adModel.open_url];
        if ([[UIApplication sharedApplication] canOpenURL:openURL]) {
            [self openAppURL:adModel.appUrl tabURL:adModel.tabUrl adID:adModel.ad_id logExtra:adModel.log_extra];
            canOpenApp = YES;
        }
        if (!canOpenApp && [TTRoute conformsToRouteWithScheme:adModel.appUrl]) {
            [self openAppURL:adModel.appUrl tabURL:adModel.tabUrl adID:adModel.ad_id logExtra:adModel.log_extra];
            canOpenApp = YES;
        }
        
        if (!canOpenApp) {
            canOpenApp = [[UIApplication sharedApplication] openURL:openURL];
        }
    }
    
    if (!canOpenApp) {
        if ([TTDeviceHelper isJailBroken] && !isEmptyString(adModel.ipa_url)) {
            [self openDownloadURL:adModel.ipa_url appleID:nil appName:@""];
        } else {
            [[TTAdAppDownloadManager sharedManager] initStayTrackerWithAd_id:adModel.ad_id log_extra:adModel.log_extra];
            [self openDownloadURL:adModel.download_url appleID:adModel.apple_id appName:@""];
        }
    }
    return canOpenApp;
}

+ (void)openDownloadURL:(NSString *)downloadURL appleID:(NSString *)appleID appName:(NSString *)appName
{
    if (appleID) {
        UIViewController *topViewController = [TTUIResponderHelper topNavigationControllerFor:nil];
        [[SSAppStore shareInstance] openAppStoreByActionURL:downloadURL itunesID:appleID presentController:topViewController appName:appName];
    } else {
        [[UIApplication sharedApplication] openURL:[TTStringHelper URLWithURLString:downloadURL]];
    }
}

+ (void)openAppURL:(NSString *)appURL tabURL:(NSString *)tabURL adID:(NSString *)adID logExtra:(NSString *)logExtra {
    if ([TTRoute conformsToRouteWithScheme:appURL]) {
        NSDictionary *condation = nil;
        NSMutableDictionary *condition = [NSMutableDictionary dictionaryWithCapacity:2];
        [condition setValue:adID forKey:@"ad_id"];
        [condition setValue:logExtra forKey:@"log_extra"];
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:tabURL] userInfo:TTRouteUserInfoWithDict(condation)];
    } else {
        NSString *openURLStr = [NSString stringWithFormat:@"%@%@", appURL, tabURL];
        NSString *escapesBackURL = [TTAppLinkManager escapesBackURL:nil value:adID extraDic:nil];
        NSURL *openURL = [NSURL URLWithString:[openURLStr stringByReplacingOccurrencesOfString:kAppLinkBackURLPlaceHolder withString:escapesBackURL]];
        [[UIApplication sharedApplication] openURL:openURL];
    }
}

- (void)initStayTrackerWithAd_id:(NSString *)ad_id log_extra:(NSString *)log_extra
{
    self.ad_id_for_tracker = ad_id;
    self.log_extra = log_extra;
}

- (void)preloadAppStoreAppleId:(NSString *)appleId
{
    if (!TTNetworkWifiConnected()) {
        return;
    }
    if (isEmptyString(appleId)) {
        return;
    }
    if (self.skVCAppear == YES) {
        return;
    }
    if (self.isPreloading == YES) {
        return;
    }
    if (![self.appleId isEqualToString:appleId]) {
        self.appleId = appleId;
        //更新预加载的appleId时候才更新ad_id和log_extra
        self.ad_id = nil;
        self.log_extra = nil;
        
        [self preloadSkViewControllerAppleId:appleId];
    }
    
}

- (void)preloadAppStoreDict:(NSDictionary*)dict
{
    NSString* appleID = [dict valueForKey:@"apple_id"];
    NSString* ad_id = [dict valueForKey:@"ad_id"];
    NSString* log_extra = [dict valueForKey:@"log_extra"];
    if (!TTNetworkWifiConnected()) {
        return;
    }
    if (isEmptyString(appleID)) {
        return;
    }
    if (self.skVCAppear == YES) {
        return;
    }
    if (self.isPreloading == YES) {
        return;
    }
    if (![self.appleId isEqualToString:appleID]) {
        self.appleId = appleID;
        //更新预加载的appleId时候才更新ad_id和log_extra
        self.ad_id = ad_id;
        self.log_extra = log_extra;
        
        [self preloadSkViewControllerAppleId:appleID];
    }
}



- (void)preloadSkViewControllerAppleId:(NSString *)appleID
{
    self.skVc = [[TTAdSKVC alloc] initWithAppleId:appleID];
    self.skVc.skController.delegate = self;
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:appleID, SKStoreProductParameterITunesItemIdentifier, nil];
    //标记预加载的状态
    self.skVc.loadFinish = NO;
    self.isPreloading = YES;
    WeakSelf;
    [self.skVc.skController loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
        StrongSelf;
        self.isPreloading = NO;
        if (result == YES) {
            self.skVc.loadFinish = YES;
            
            //iOS11上恶心的bug,预加载完成推出后会导致skVC内部刷新页面变空,解决方式:再load一次
            //条件:iOS11+、预加载成功
            if (@available(iOS 11.0, *)){
                if ([SSCommonLogic isSKVCLoadEnable]) {
                    UIViewController *topVC = [TTUIResponderHelper topNavigationControllerFor:nil];
                    UIStatusBarStyle barStyle = [UIApplication sharedApplication].statusBarStyle;
                    [topVC presentViewController:self.skVc.skController animated:NO completion:^{
                        if (barStyle == UIStatusBarStyleLightContent) {
                            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                        }
                    }];
                    [self.skVc.skController dismissViewControllerAnimated:NO completion:nil];
                }
            }
            if (!isEmptyString(self.ad_id)) {
                [self trackPreloadAdWithTag:@"appstore_preload" label:@"preload_success" appleId:appleID];
            }
        }
        else {
            if (!isEmptyString(self.ad_id)) {
                [self trackPreloadAdWithTag:@"appstore_preload" label:@"preload_fail" appleId:appleID];
            }
            
        }
    }];
}

- (BOOL)openAppStoreAppleID:(NSString*)appleID controller:(UIViewController*)controller
{
    if ([self.skVc.appleId isEqualToString:appleID] && self.skVc.loadFinish == NO) {
        if (!isEmptyString(self.ad_id)) {
            [self trackPreloadAdWithTag:@"appstore_preload" label:@"preload_break" appleId:appleID];
        }
    }
    TTAdSKVC* skVc = nil;
    if ([self.skVc.appleId isEqualToString:appleID] && self.skVc.loadFinish == YES && self.skVc.skController) {
        skVc = self.skVc;
    }
    else
    {
        self.skVc = nil;
        skVc = [[TTAdSKVC alloc] initWithAppleId:appleID];
        skVc.skController.delegate = self;
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:appleID, SKStoreProductParameterITunesItemIdentifier, nil];
        [TTAdMonitorManager beginTrackIntervalService:@"tt_ad_appstore"];
        WeakSelf;
        __weak TTAdSKVC* wSkVC = skVc;
        [skVc.skController loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
            StrongSelf;
            
            if (result == YES) {
                wSkVC.loadFinish = YES;
                
                [TTAdMonitorManager endTrackIntervalService:@"tt_ad_appstore" extra:nil];
            }
            if (error && error.code != 0) {
                [self failAppleId:appleID];
            }
        }];
    }
    
    [self pushSkController:skVc.skController controller:controller completion:nil];
    self.isPreloading = NO;
    if ([SSCommonLogic isAppPreloadEnable]) {
        return YES;
    }
    return NO;
}

- (SKStoreProductViewController *)SKViewControllerPreloadId:(NSString *)appleID
                                            dismissAnimated:(BOOL)animated
                                            completionBlock:(nullable void(^)(BOOL result))block
{
    self.dissmissAnimated = animated;
    if ([self.skVc.appleId isEqualToString:appleID] && self.skVc.loadFinish == NO) {
        if (!isEmptyString(self.ad_id)) {
            [self trackPreloadAdWithTag:@"appstore_preload" label:@"preload_break" appleId:appleID];
        }
    }
    TTAdSKVC* skVc = nil;
    if ([self.skVc.appleId isEqualToString:appleID] && self.skVc.loadFinish == YES && self.skVc.skController) {
        skVc = self.skVc;
        block(YES);
    }
    else{
        self.skVc = nil;
        skVc = [[TTAdSKVC alloc] initWithAppleId:appleID];
        skVc.skController.delegate = self;
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:appleID, SKStoreProductParameterITunesItemIdentifier, nil];
        [TTAdMonitorManager beginTrackIntervalService:@"tt_ad_appstore"];
        WeakSelf;
        __weak TTAdSKVC* wSkVC = skVc;
        [skVc.skController loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
            StrongSelf;
            
            if (result == YES) {
                wSkVC.loadFinish = YES;
                [TTAdMonitorManager endTrackIntervalService:@"tt_ad_appstore" extra:nil];
            }
            block(result);
            if (error && error.code != 0) {
                [self failAppleId:appleID];
            }
        }];
    }
    return skVc.skController;
}

- (void)appStoreDidAppear:(UIViewController *)viewController {
}


- (void)appStoreDidDisappear:(UIViewController *)viewController {
}


- (void)appStoreLoad:(BOOL)result error:(NSError *)error appleId:(NSString *)appleId {
}


- (void)failAppleId:(NSString *)appleId
{
    NSMutableDictionary *extra = @{}.mutableCopy;
    [extra setValue:appleId forKey:@"appleID"];
    [extra setValue:self.ad_id forKey:@"ad_id"];
    [extra setValue:self.log_extra forKey:@"log_extra"];
    [TTAdMonitorManager trackService:@"appstore_loadfail" status:1 extra:extra];
}

- (void)pushSkController:(SKStoreProductViewController*)skController controller:(UIViewController*)controller  completion:(void(^)(void))completion
{
    [self pushSkController:skController controller:controller completion:completion postNoti:YES];
}

- (void)pushSkController:(SKStoreProductViewController*)skController controller:(UIViewController*)controller  completion:(void(^)(void))completion postNoti:(BOOL)post
{
    //解决crash  skVC很奇怪,点起过快会重复被present出来导致crash
    if ([SSCommonLogic isSKVCBugFixEnable]) {
        if (controller.presentedViewController && [controller.presentedViewController isKindOfClass:[SKStoreProductViewController class]]) {
            WeakSelf;
            [controller.presentedViewController dismissViewControllerAnimated:NO completion:^{
                StrongSelf;
                self.skVc = nil;
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:SKStoreProductViewDidDisappearKey object:nil];
            return;
        }
    }
    
    if (controller&&skController&&[skController isKindOfClass:[SKStoreProductViewController class]]) {
        self.skVCAppear = YES;
        if ([controller isKindOfClass:[UINavigationController class]]) {
            WeakSelf;
            [controller presentViewController:skController animated:YES completion:^{
                StrongSelf;
                [self pushSKViewController:skController postNotification:post completion:completion];
            }];
            
        }
        else if (!controller.navigationController) {
            WeakSelf;
            [controller presentViewController:skController animated:YES completion:^{
                 StrongSelf;
                [self pushSKViewController:skController postNotification:post completion:completion];
            }];
        }
        else {
            WeakSelf;
            [controller.navigationController presentViewController:skController animated:YES completion:^{
                StrongSelf;
                [self pushSKViewController:skController postNotification:post completion:completion];
            }];
        }
        if ([self.stay_page_traker respondsToSelector:@selector(startStayTracker)]) {
            [self.stay_page_traker startStayTracker];
        }
    }
}

- (void)pushSKViewController:(SKStoreProductViewController*)skController postNotification:(BOOL)post completion:(void(^)(void))completion
{
    if (post) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SKStoreProductViewDidAppearKey object:skController];
    }
    if (completion) {
        completion();
    }
}

- (SKStoreProductViewController *)SKViewControllerPreloadId:(NSString *)appleID
{
    if ([self.skVc.appleId isEqualToString:appleID] && self.skVc.loadFinish == NO) {
        if (!isEmptyString(self.ad_id)) {
            [self trackPreloadAdWithTag:@"appstore_preload" label:@"preload_break" appleId:appleID];
        }
    }
    TTAdSKVC* skVc = nil;
    if ([self.skVc.appleId isEqualToString:appleID] && self.skVc.loadFinish == YES && self.skVc.skController) {
        skVc = self.skVc;
    }
    else{
        self.skVc = nil;
        skVc = [[TTAdSKVC alloc] initWithAppleId:appleID];
        skVc.skController.delegate = self;
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:appleID, SKStoreProductParameterITunesItemIdentifier, nil];
        [TTAdMonitorManager beginTrackIntervalService:@"tt_ad_appstore"];
        WeakSelf;
        __weak TTAdSKVC* wSkVC = skVc;
        [skVc.skController loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
            StrongSelf;
            
            if (result == YES) {
                wSkVC.loadFinish = YES;
                [TTAdMonitorManager endTrackIntervalService:@"tt_ad_appstore" extra:nil];
            }
            if (error && error.code != 0) {
                [self failAppleId:appleID];
            }
        }];
    }
    return skVc.skController;
}


#pragma mark -- SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SKStoreProductViewWillDisappearKey object:viewController];
    WeakSelf;
    [viewController dismissViewControllerAnimated:self.dissmissAnimated completion:^{
        StrongSelf;
        [[NSNotificationCenter defaultCenter] postNotificationName:SKStoreProductViewDidDisappearKey object:viewController];
        [self clearResource];
    }];
}

- (void)clearResource {
    self.skVc = nil;
    self.appleId = nil;
    self.skVCAppear = NO;
    self.isPreloading = NO;
    self.dissmissAnimated = YES;
    
    if ([self.stay_page_traker respondsToSelector:@selector(endStayTrackerWithAd_id:log_extra:)]) {
        [self.stay_page_traker endStayTrackerWithAd_id:self.ad_id_for_tracker log_extra:self.log_extra];
    }
    self.ad_id_for_tracker = nil;
    self.log_extra = nil;
}

-(void)trackPreloadAdWithTag:(NSString*)tag
                       label:(NSString*)label
                     appleId:(NSString*)apple_id
{
    NSMutableDictionary* mDict = [NSMutableDictionary dictionary];
    [mDict setValue:self.log_extra forKey:@"log_extra"];
    [mDict setValue:apple_id forKey:@"apple_id"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [mDict setValue:@(connectionType) forKey:@"nt"];
    [mDict setValue:@"1" forKey:@"is_ad_event"];
    [TTAdTrackManager trackWithTag:tag label:label value:self.ad_id extraDic:mDict];
}

@end




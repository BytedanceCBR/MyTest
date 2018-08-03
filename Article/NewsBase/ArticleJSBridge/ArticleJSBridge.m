//
//  ArticleJSBridge.m
//  Article
//
//  Created by Dianwei on 14-10-23.
//
//

// refer to: https://wiki.bytedance.com/pages/viewpage.action?pageId=15860559

#import "ArticleJSBridge.h"
#import "SSPayManager.h"
#import "NetworkUtilities.h"
#import "ArticleAddressBridger.h"
#import "TTActivityShareManager.h"
#import <TTImage/TTWebImageManager.h>
#import "TTPhotoScrollViewController.h"
#import "TTImageInfosModel.h"
#import "SDWebImageManager.h"
#import "ExploreEntryManager.h"
#import "TTQQShare.h"
#import "ExploreEntryManager.h"
#import "ExploreFetchEntryManager.h"
#import "SSActivityView.h"
#import "ArticleShareManager.h"
#import "SSActivityView.h"
#import "FriendDataManager.h"
#import "JSAuthManager.h"
#import "FRConcernEntity.h"
#import <TTAccountBusiness.h>

#import "ExploreOrderedData.h"
#import "ExploreMixListDefine.h"
#import "ExploreArticleWebCellView.h"
#import "TTArticleCategoryManager.h"
#import "TTInstallIDWrapperManager.h"
#import "TTNavigationController.h"
#import "NSDictionary+TTAdditions.h"
//#import "ExploreEntryHelper.h"
#import "ShareOne.h"
#import "TTIndicatorView.h"
#import "TTBlockManager.h"

#import "TTTemaiLinkManager.h"
#import "TTURLUtils.h"
#import "TTDetailContainerViewModel.h"
#import "TTDetailModel.h"

#import "TTStringHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"

#import "TTFollowNotifyServer.h"

#import "TTProfileShareService.h"
#import "TTAdManager.h"

#import "TTRoute.h"

#import "TTInteractExitHelper.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
#import <TTInteractExitHelper.h>

extern NSString *const kForumLikeStatusChangeNotification;
extern NSString *const kForumLikeStatusChangeForumIDKey;
extern NSString *const kForumLikeStatusChangeForumLikeKey;

extern NSString * const WDAnswerEntityRemoveNotification;
extern NSString * const WDAnswerEntityRemoveNotificationStatusKey;
extern NSString * const WDAnswerEntityRemoveNotificationIDKey;

NSString * const kArticleJSBridgePauseVideoNotification = @"kArticleJSBridgePauseVideoNotification";
NSString * const kArticleJSBridgePlayVideoNotification = @"kArticleJSBridgePlayVideoNotification";
NSString * const kArticleJSBrdigeChooseForumNotification = @"kArticleJSBrdigeChooseForumNotification";

NSString * const kArticleJSBrdigePGCDonateFinishedNotification = @"kArticleJSBrdigePGCDonateFinishedNotification";

static NSInteger subscribeCount = 0;

@interface ArticleJSBridge()<SSActivityViewDelegate, TTAccountMulticastProtocol>

@property (nonatomic, strong) SDWebImageManager *imageManager;
@property (nonatomic, strong) NSTimer           *imageDownloadTimeoutTimer;
@property (nonatomic, strong) NSString          *loginCallbackID;
@property (nonatomic, strong) NSString          *sharePGCCallbackID;
@property (nonatomic, strong) id                closeReference;
@property (nonatomic, strong) SSActivityView    *phoneShareView;
@property (nonatomic, strong) NSDictionary      *shareData;
@property (nonatomic, copy)   NSString          *mediaID;
@property (nonatomic, copy)   NSString          *userID;

@property (nonatomic, strong) TTActivityShareManager     *shareManager;
@property (nonatomic, strong) TTDetailContainerViewModel *detailModel;
@property (nonatomic, assign) TTShareSourceObjectType    curShareSourceType;

@end

@implementation ArticleJSBridge
@synthesize shareManager = _shareManager;

- (void)dealloc
{
    _shareManager = nil;
    [_imageDownloadTimeoutTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (instancetype)initWithWebView:(YSWebView *)webview {
    self = [super initWithWebView:webview];
    if (self) {
        [self articleCommonInit];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if(self) {
        [self articleCommonInit];
    }
    
    return self;
}

- (void)articleCommonInit {
    [self registerPay];
    [self registerAppInstalled];
    [self registerLogin];
    [self registerShareHandler];
    [self registerClose];
    [self registerGallery];
    [self registerMediaLike];
    [self registerMediaUnlike];
    [self registerOpenAction];
    [self registerOpenHotsoon];
    [self registerAccountStatus];
    [self registerSharePGC];
    [self registerSharePanel];
    [self registerAddEventListener];
    [self registerPageStateChange];
    
    [self registerPlayNativeVideo];
    [self registerPlayVideo];
    [self registerPauseVideo];
    
    [self registerAddChannel];
    [self registerGetSubScribedChannelList];
    
    [self registerIsVisibleJSBridgeHandler];
    
    [self registerToast];
    
    [self registerTemaiLinkService];
    [self registerCallNativePhone];
    [self registerCopyToClipboard];
    
    // 监听用户登录状态的变化，用户退出登录的通知
    [TTAccount addMulticastDelegate:self];
}

- (void)registerIsVisibleJSBridgeHandler
{
    __weak typeof(self) wself = self;
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        __strong typeof(wself) self = wself;
        return @{@"code" : @(!!self.webView.window)};
    } forJSMethod:@"is_visible" authType:SSJSBridgeAuthPublic];
}

- (void)registerPay
{
    __weak ArticleJSBridge *weakself = self;
    
    [self registerHandlerBlock:^NSDictionary *(NSString * callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL * executeCallback) {
        
        if (executeCallback) {
            *executeCallback = NO;
        }
        NSDictionary * dictionary = [[result valueForKey:@"data"] valueForKey:@"data"];
        if ([[SSPayManager sharedPayManager] canPayForTrade:dictionary]) {
            [[SSPayManager sharedPayManager] payForTrade:dictionary finishHandler:^(NSDictionary *trade, NSInteger errorCode) {
                [weakself invokeJSWithCallbackID:callbackId parameters:@{@"code":@(errorCode)}];
            }];
        }
        return (NSDictionary *) nil;
    } forJSMethod:@"pay" authType:SSJSBridgeAuthProtected];
}

- (void)registerPlayNativeVideo
{
    __weak ArticleJSBridge *weakself = self;
    
    [self registerHandlerBlock:^NSDictionary *(NSString * callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL * executeCallback) {
        if (executeCallback) {
            *executeCallback = NO;
        }
        
        if ([result isKindOfClass:[NSDictionary class]] && [result count] > 0) {
            NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:result];
            [[NSNotificationCenter defaultCenter] postNotificationName:kArticleJSBridgePlayVideoNotification object:weakself userInfo:userInfo];
        }
        return (NSDictionary *) nil;
    } forJSMethod:@"playNativeVideo" authType:SSJSBridgeAuthPrivate];
}

- (void)registerPlayVideo
{
    __weak ArticleJSBridge *weakself = self;
    
    [self registerHandlerBlock:^NSDictionary *(NSString * callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL * executeCallback) {
        wrapperTrackEventWithCustomKeys(@"jsbridge", @"playVideo", nil, self.webView.request.URL.absoluteString, nil);
        if (executeCallback) {
            *executeCallback = NO;
        }
        
        if ([result isKindOfClass:[NSDictionary class]] && [result count] > 0) {
            NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:result];
            [[NSNotificationCenter defaultCenter] postNotificationName:kArticleJSBridgePlayVideoNotification object:weakself userInfo:userInfo];
        }
        return (NSDictionary *) nil;
    } forJSMethod:@"playVideo" authType:SSJSBridgeAuthPublic];
}

- (void)registerPauseVideo
{
    __weak ArticleJSBridge *weakself = self;
    
    [self registerHandlerBlock:^NSDictionary *(NSString * callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL * executeCallback) {
        if (executeCallback) {
            *executeCallback = NO;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kArticleJSBridgePauseVideoNotification object:weakself userInfo:nil];
        
        return (NSDictionary *) nil;
    } forJSMethod:@"pauseVideo" authType:SSJSBridgeAuthPublic];
}

- (void)registerAppInstalled
{
    // isAppInstalled
    [self registerHandlerBlock:^NSDictionary *(NSString * callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL * executeCallback) {
        NSString * openURL = [result valueForKey:@"open_url"];
        NSURL * URL = [TTStringHelper URLWithURLString:openURL];
        BOOL installed = NO;
        if (URL && [[UIApplication sharedApplication] canOpenURL:URL]) {
            installed = YES;
        }
        
        return @{@"installed":@(installed)};
    } forJSMethod:@"isAppInstalled" authType:SSJSBridgeAuthProtected];//此处按照文档http://wiki.bytedance.com/pages/viewpage.action?pageId=15860559修改
}

- (void)registerLogin
{
    __weak ArticleJSBridge *weakSelf = self;
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        if (executeCallback) {
            *executeCallback = NO;
        }
        
        weakSelf.loginCallbackID = callbackId;
        
        NSString *platform = [result objectForKey:@"platform"];
        TTAccountLoginAlertTitleType type = [result tt_integerValueForKey:@"title_type"];
        NSString *source = [result tt_stringValueForKey:@"login_source"];
        
        // 已登录并且不是qq、微信、weibo等其他登录方式时，直接返回登录成功
        if ([TTAccountManager isLogin] && isEmptyString(platform))
        {
            [weakSelf invokeJSWithCallbackID:_loginCallbackID parameters:@{@"code": @1}];
            weakSelf.loginCallbackID = nil;
            return @{@"code": @1};
        }
        
        // 确保监听accountStateChanged（详情页不调用addEventListener)，收到通知时callback页面
        [TTAccount addMulticastDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidAuthCompletion:) name:TTAccountPlatformDidAuthorizeCompletionNotification object:nil];
        
        // shareone cancel login
        [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(loginClosed:) name:NOTIFICATION_SHARE_ONE_DISMISS object:nil];
        
        NSDictionary *callbackResult = nil;
        if(isEmptyString(platform)) //全平台
        {
            [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                if (type == TTAccountAlertCompletionEventTypeTip) {
                    [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:weakSelf.webView] type:TTAccountLoginDialogTitleTypeDefault source:source completion:^(TTAccountLoginState state) {
                    }];
                }
            }];
        }
        else if([platform isEqualToString:@"qq"])
        {
            [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_QZONE completion:^(BOOL success, NSError *error) {
                
            }];
        }
        else if([platform isEqualToString:@"weibo"])
        {
            [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_SINA_WEIBO completion:^(BOOL success, NSError *error) {
                
            }];
        }
        else if([platform isEqualToString:@"weixin"])
        {
            [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_WEIXIN completion:^(BOOL success, NSError *error) {
                
            }];
        }
        else if([platform isEqualToString:@"qq_weibo"])
        {
            [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_QQ_WEIBO completion:^(BOOL success, NSError *error) {
                
            }];
        }
        else
        {
            callbackResult = @{@"code": @0};
        }
        
        return callbackResult;
        
    } forJSMethod:@"login" authType:SSJSBridgeAuthPublic];
}

- (void)registerToast
{
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        
        NSString *text = [result objectForKey:@"text"];
        // `icon_type` 可选，目前仅一种 type ，即 `icon_success`。
        if (text.length > 0) {
            NSString *iconType = [result objectForKey:@"icon_type"];
            if (!isEmptyString(iconType)) {
                if ([iconType isEqualToString:@"icon_success"]) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                } else {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                }
            } else {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            }
        }
        return (NSDictionary *)nil;
        
    } forJSMethod:@"toast" authType:SSJSBridgeAuthProtected];
}

- (void)registerTemaiLinkService {
    __weak ArticleJSBridge *weakSelf = self;
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        UIViewController *topVC = [TTUIResponderHelper topViewControllerFor:weakSelf.webView];
        BOOL isHandled = [[TTTemaiLinkManager sharedManager] handleLinkInfo:result inViewController:topVC];
        NSString *urlString = result[@"url"];
        if (!isHandled && !isEmptyString(urlString)) { // SDK 不能处理的，使用内置浏览器打开
            NSURL *url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:@{@"url" : urlString}];
            if ([[TTRoute sharedRoute] canOpenURL:url]) {
                [[TTRoute sharedRoute] openURLByPushViewController:url];
            }
        }
        return nil;
    } forJSMethod:@"openCommodity" authType:SSJSBridgeAuthPublic];
}

- (void)registerCallNativePhone {
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        NSString *phoneNumber = [result stringValueForKey:@"tel_num" defaultValue:nil];
        NSInteger dialActionType = [result tt_intValueForKey:@"dial_action_type"];
        if (!isEmptyString(phoneNumber)) {
            NSURL *URL = [TTStringHelper URLWithURLString:[NSString stringWithFormat:@"tel://%@", phoneNumber]];
            if ([TTDeviceHelper OSVersionNumber] < 8) {
                [self listenCall:dialActionType];
                UIWebView * callWebview = [[UIWebView alloc] init];
                [callWebview loadRequest:[NSURLRequest requestWithURL:URL]];
                [[UIApplication sharedApplication].keyWindow addSubview:callWebview];
                // 这里delay1s之后把callWebView干掉，不能直接干掉，否则不能打电话。
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [callWebview removeFromSuperview];
                });
                return nil;
            }
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [self listenCall:dialActionType];
                [[UIApplication sharedApplication] openURL:URL];
            }
        }
        return nil;
    } forJSMethod:@"callNativePhone" authType:SSJSBridgeAuthProtected];
    
}

//监听电话状态
- (void)listenCall:(NSInteger)dialActionType
{
    void (^callBlock)(NSString *status) =  ^(NSString *status){
        if (!isEmptyString(status)) {
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
            NSString* jsString = [NSString stringWithFormat:@"window.__toutiaoNativePhoneCallback('%@', '%@');", status, @(timeStamp*1000).stringValue];
            if([NSThread isMainThread])
            {
                [self.webView evaluateJavaScriptFromString:jsString completionBlock:nil];
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.webView evaluateJavaScriptFromString:jsString completionBlock:nil];
                });
            }
        }
    };
    
    //ad_id、log_extra无用,因为只给web传状态,无需打点
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:@"1" forKey:@"ad_id"];
    [dict setValue:@"1" forKey:@"log_extra"];
    [dict setValue:[NSDate date] forKey:@"dailTime"];
    [dict setValue:@"detail_call" forKey:@"position"];
    [dict setValue:@(dialActionType) forKey:@"dailActionType"];
    [dict setValue:callBlock forKey:@"block"];
    [dict setValue:@(YES) forKey:@"web_call"];
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance call_callAdDict:dict];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountLogout
{
    subscribeCount = 0;
}

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    //忽略从js bridge抛出的通知
    BOOL login = [TTAccountManager isLogin];
    if (login) {
        //if([self isAuthorizedForEvent:@"login"] && ![self isInnerDomain])
        //{
        [self invokeJSWithEventID:@"login" parameters:@{@"code":@1} finishBlock:nil];
        //}
    } else {
        //if([self isAuthorizedForEvent:@"logout"] && ![self isInnerDomain])
        //{
        [self invokeJSWithEventID:@"logout" parameters:@{@"code":@1} finishBlock:nil];
        //}
    }
    
    switch (reasonType) {
        case TTAccountStatusChangedReasonTypeLogout:
        case TTAccountStatusChangedReasonTypeSessionExpiration: {
            if(_loginCallbackID) {
                [self invokeJSWithCallbackID:_loginCallbackID parameters:@{@"code": @0}];
            }
        }
            break;
        case TTAccountStatusChangedReasonTypeAutoSyncLogin:
        case TTAccountStatusChangedReasonTypeFindPasswordLogin:
        case TTAccountStatusChangedReasonTypePasswordLogin:
        case TTAccountStatusChangedReasonTypeSMSCodeLogin:
        case TTAccountStatusChangedReasonTypeEmailLogin:
        case TTAccountStatusChangedReasonTypeTokenLogin:
        case TTAccountStatusChangedReasonTypeSessionKeyLogin:
        case TTAccountStatusChangedReasonTypeAuthPlatformLogin: {
            if(_loginCallbackID) {
                [self invokeJSWithCallbackID:_loginCallbackID parameters:@{@"code": @1}];
            }
        }
            break;
    }
    
    self.loginCallbackID = nil;
    [self removeAccountNotification];
}

#pragma mark - events of notifications

- (void)loginClosed:(NSNotification*)notification
{
    if(![TTAccountManager isLogin])
    {
        [self invokeJSWithCallbackID:_loginCallbackID parameters:@{@"code": @0}];
        self.loginCallbackID = nil;
        [self removeAccountNotification];
    }
}

- (void)notificationDidAuthCompletion:(NSNotification *)notification
{
    NSDictionary *userInfoInNot = notification.userInfo;
    TTAccountAuthErrCode authErrCode = [userInfoInNot[TTAccountStatusCodeKey] integerValue];
    
    if (authErrCode != TTAccountAuthSuccess) {
        [self cancelLogin:notification];
    }
}

- (void)cancelLogin:(NSNotification*)notification
{
    [self invokeJSWithCallbackID:_loginCallbackID parameters:@{@"code": @0}];
    self.loginCallbackID = nil;
    [self removeAccountNotification];
}

- (void)registerAccountStatus {
    //    is_login
    
    [self registerHandlerBlock:^NSDictionary *(NSString * callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL * executeCallback) {
        return @{@"is_login":@([TTAccountManager isLogin])};
    } forJSMethod:@"is_login" authType:SSJSBridgeAuthPublic];//此处按照文档http://wiki.bytedance.com/pages/viewpage.action?pageId=15860559修改
}

- (void)registerShareHandler
{
    __weak ArticleJSBridge *weakSelf = self;
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion,  BOOL *executeCallback) {
        wrapperTrackEventWithCustomKeys(@"jsbridge", @"share", nil, self.webView.request.URL.absoluteString, nil);
        
        NSString *platform = [result objectForKey:@"platform"];
        if(([platform isEqualToString:@"qzone"] || [platform isEqualToString:@"qq"]) && ![[TTQQShare sharedQQShare] isAvailable])
        {
            return @{@"code": @0};
        }
        
        [weakSelf startShareWithData:result];
        return @{@"code": @1};
        
    } forJSMethod:@"share" authType:SSJSBridgeAuthProtected];
}

- (void)startShareWithData:(NSDictionary*)data
{
    // download image first
    NSDictionary *replacedData = [self replacedSharedDataForData:data];
    NSString *imageURLString = [replacedData objectForKey:@"image"];
    
    if(!isEmptyString(imageURLString))
    {
        [self shareManager].shareImage = [TTWebImageManager imageForURLString:imageURLString];
        
        if([self shareManager].shareImage)
        {
            [self shareWithImage:[self shareManager].shareImage data:replacedData];
        }
        else
        {
            if (!_imageManager) {
                self.imageManager = [[SDWebImageManager alloc] init];
            }
            
            [self.imageManager cancelAll];
            
            __weak ArticleJSBridge *wself = self;
            
            [self.imageManager loadImageWithURL:[TTStringHelper URLWithURLString:imageURLString] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                ArticleJSBridge *sself = wself;
                if (image) {
                    [sself.imageDownloadTimeoutTimer invalidate];
                    [sself shareWithImage:image data:replacedData];
                } else {
                    [sself.imageDownloadTimeoutTimer invalidate];
                    [sself shareWithImage:[ArticleJSBridge defaultIconImg] data:replacedData];
                }
            }];
            
            [_imageDownloadTimeoutTimer invalidate];
            self.imageDownloadTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(timeoutTimer:) userInfo:replacedData repeats:NO];
        }
    }
    else
    {
        [self shareWithImage:[ArticleJSBridge defaultIconImg] data:replacedData];
    }
}

- (void)timeoutTimer:(NSTimer*)timer
{
    //  download image timeout
    NSDictionary *data = [timer userInfo];
    [_imageManager cancelAll];
    [self shareWithImage:[ArticleJSBridge defaultIconImg] data:data];
}

//默认Icon
+ (UIImage *)defaultIconImg
{
    UIImage * img;
    //优先使用share_icon.png分享
    if (!img) {
        img = [UIImage imageNamed:@"share_icon.png"];
    }
    if (!img) {
        img = [UIImage imageNamed:@"Icon.png"];
    }
    return img;
}

- (NSString*)sharedPlatformForData:(NSDictionary*)data
{
    NSString *platform = [data objectForKey:@"platform"];
    if(isEmptyString(platform))
    {
        platform = @"weixin_moments";
    }
    
    return platform;
}

- (void)shareWithImage:(UIImage*)image data:(NSDictionary*)data
{
    NSString *platform = [self sharedPlatformForData:data];
    NSString *title = [data objectForKey:@"title"];;
    NSString *content = [data objectForKey:@"desc"];
    NSString *shareURLString = [data objectForKey:@"url"];
    
    
    [[self shareManager] clearCondition];
    
    [self shareManager].shareImage = image;
    
    [self shareManager].hasImg = image == nil ? NO : YES;
    
    [self shareManager].shareURL = shareURLString;
    
    
    UIViewController *topVC = [TTUIResponderHelper topViewControllerFor: self.webView];
    
    if([platform isEqualToString:@"qzone"])
    {
        [self shareManager].qqZoneTitleText = title;
        [self shareManager].qqZoneText = content;
        [self shareManager].qqShareTitleText = title;
        [[self shareManager] performActivityActionByType:TTActivityTypeQQZone inViewController:topVC sourceObjectType:self.curShareSourceType];
        
    }
    else if([platform isEqualToString:@"weixin"])
    {
        [self shareManager].weixinTitleText = title;
        [self shareManager].weixinText = content;
        [[self shareManager] performActivityActionByType:TTActivityTypeWeixinShare inViewController:topVC sourceObjectType:self.curShareSourceType uniqueId:self.userID];
    }
    else if([platform isEqualToString:@"weixin_moments"])
    {
        [self shareManager].weixinMomentText = title;
        [[self shareManager] performActivityActionByType:TTActivityTypeWeixinMoment inViewController:topVC sourceObjectType:self.curShareSourceType];
    }
    else if([platform isEqualToString:@"qq"])
    {
        [self shareManager].qqShareText = content;
        [self shareManager].qqShareTitleText = title;
        [[self shareManager] performActivityActionByType:TTActivityTypeQQShare inViewController:topVC sourceObjectType:self.curShareSourceType];
    }else if([platform isEqualToString:@"dingding"]){
        [self shareManager].dingtalkText = content;
        [self shareManager].dingtalkTitleText = title;
        [[self shareManager] performActivityActionByType:TTActivityTypeDingTalk inViewController:topVC sourceObjectType:self.curShareSourceType];
    }
}

- (void)registerClose
{
    __weak ArticleJSBridge *weakSelf = self;
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        
        BOOL needCallback = *executeCallback;
        *executeCallback = NO;
        if([weakSelf.webView isKindOfClass:[YSWebView class]])
        {
            // 如果有回调，保证回调前webview不被释放
            weakSelf.closeReference = weakSelf.webView;
            UIViewController *topVC = [TTUIResponderHelper topViewControllerFor: weakSelf.webView];
            if(topVC.navigationController)
            {
                [topVC.navigationController popViewControllerAnimated:YES];
                if(needCallback)
                {
                    [weakSelf invokeJSWithCallbackID:callbackId parameters:@{@"code": @0}];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        weakSelf.closeReference = nil;
                    });
                }
                else
                {
                    weakSelf.closeReference = nil;
                }
            }
            else
            {
                [topVC dismissViewControllerAnimated:YES completion:^{
                    if(needCallback)
                    {
                        [weakSelf invokeJSWithCallbackID:callbackId parameters:@{@"code": @0}];
                        weakSelf.closeReference = nil;
                    }
                }];
                
                if(!needCallback)
                {
                    weakSelf.closeReference = nil;
                }
            }
        }
        
        
        return @{@"code": @1};
    } forJSMethod:@"close" authType:SSJSBridgeAuthPublic];
}

- (void)registerGallery
{
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        
        NSArray *images = [result objectForKey:@"images"];
        NSArray *imageList = [result objectForKey:@"image_list"];
        if(images.count > 0 || imageList.count > 0)
        {
            TTPhotoScrollViewController *vc = [[TTPhotoScrollViewController alloc] init];
            vc.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
            vc.startWithIndex = [[result objectForKey:@"index"] intValue];
            if(imageList.count > 0)
            {
                NSMutableArray *models = [NSMutableArray arrayWithCapacity:imageList.count];
                for(NSDictionary *dict in imageList)
                {
                    TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
                    if (model) {
                        [models addObject:model];
                    }
                }
                vc.imageInfosModels = models;
            }
            else if(images.count > 0)
            {
                vc.imageURLs = images;
            }
            
            [vc presentPhotoScrollView];
        }
        
        return @{@"code": @1};
    } forJSMethod:@"gallery" authType:SSJSBridgeAuthPublic];
}

// 订阅
- (void)registerMediaLike
{
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        NSString *mediaID = [result objectForKey:@"id"];
        [[ExploreEntryManager sharedManager] fetchEntryFromMediaID:mediaID notifySubscribedStatus:YES finishBlock:nil];
        wrapperTrackEventWithCustomKeys(@"jsbridge", @"media_like", nil, self.webView.request.URL.absoluteString, nil);
        return @{@"code": @1};
    } forJSMethod:@"media_like" authType:SSJSBridgeAuthProtected];
}

// 取消订阅
- (void)registerMediaUnlike
{
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        NSString *mediaID = [result objectForKey:@"id"];
        [[ExploreEntryManager sharedManager] fetchEntryFromMediaID:mediaID notifySubscribedStatus:YES finishBlock:nil];
        wrapperTrackEventWithCustomKeys(@"jsbridge", @"media_unlike", nil, self.webView.request.URL.absoluteString, nil);
        return @{@"code": @1};
    } forJSMethod:@"media_unlike" authType:SSJSBridgeAuthProtected];
}


- (void)registerSharePGC
{
    __weak typeof(self) wself = self;
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        wrapperTrackEventWithCustomKeys(@"jsbridge", @"share_pgc", nil, self.webView.request.URL.absoluteString, nil);
        __strong typeof(wself) self = wself;
        if (executeCallback) {
            *executeCallback = NO;
        }
        
        NSString *pgcID = [NSString stringWithFormat:@"%@", [result objectForKey:@"id"]];
        self.mediaID = pgcID;
        if(isEmptyString(pgcID))
        {
            [self invokeJSWithCallbackID:callbackId parameters:@{@"code": @NO}];
        }
        else
        {
            self.sharePGCCallbackID = callbackId;
            [[ExploreFetchEntryManager sharedManager] fetchEntryByMediaID:pgcID finishBlock:^(ExploreEntry *entry, NSError *error) {
                if(error)
                {
                    [self invokeJSWithCallbackID:callbackId parameters:@{@"code": @NO}];
                }
                else
                {
                    UIImage *image = [TTWebImageManager imageForURLString:entry.imageURLString];
                    if(image)
                    {
                        [self shareWithExploreEntry:entry];
                    }
                    else
                    {
                        if (!self.imageManager) {
                            self.imageManager = [[SDWebImageManager alloc] init];
                        }
                        
                        [self.imageManager cancelAll];
                        __weak typeof(self) wself = self;
                        [self.imageManager loadImageWithURL:[TTStringHelper URLWithURLString:entry.imageURLString] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                            __strong typeof(wself) self = wself;
                            [self shareWithExploreEntry:entry];
                        }];
                        
                    }
                }
            }];
            
            [self shareWithmediaID:pgcID callbackId:callbackId];
        }
        
        return nil;
    } forJSMethod:@"share_pgc" authType:SSJSBridgeAuthPrivate];
}

- (void)registerSharePanel
{
    __weak typeof(self) wself = self;
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        __strong typeof(wself) self = wself;
        if (executeCallback) {
            *executeCallback = NO;
        }
        
        NSString *ID = [NSString stringWithFormat:@"%@", [result objectForKey:@"id"]];
        NSString *type = [result objectForKey:@"type"];
        
        // 视频专题
        if ([type isEqualToString:@"video_subject"] && ID) {
            self.mediaID = ID;
            self.detailModel = [[TTDetailContainerViewModel alloc] initWithRouteParamObj:TTRouteParamObjWithDict(@{@"groupid" : ID})];
            __weak typeof(self) wself = self;
            [self.detailModel fetchContentFromRemoteIfNeededWithComplete:^(ExploreDetailManagerFetchResultType type) {
                __strong typeof(wself) self = wself;
                [self shareWithArticle:self.detailModel.detailModel.article];
            }];
        }
        // 媒体主页
        else if ([type isEqualToString:@"media_profile"]) {
            self.mediaID = ID;
            [self shareWithmediaID:ID callbackId:nil];
        }
        // 个人动态(个人主页)
        else if ([type isEqualToString:@"update"]) {
            self.userID = ID;
            [self shareWithUserID:ID callbackId:nil];
        }
        
        return nil;
    } forJSMethod:@"sharePanel" authType:SSJSBridgeAuthPrivate];
}

- (void)shareWithArticle:(Article *)article
{
    self.curShareSourceType = TTShareSourceObjectTypeArticleTop;
    NSArray * activityItems = [ArticleShareManager shareActivityManager:[self shareManager] setArticleCondition:article adID:nil];
    self.phoneShareView = [[SSActivityView alloc] init];
    [self.phoneShareView refreshCancelButtonTitle:@"取消"];
    self.phoneShareView.delegate = self;
    [self.phoneShareView setActivityItemsWithFakeLayout:activityItems];
    [self.phoneShareView show];
    [self sendVideoSubjectShareTrackWithItemType:TTActivityTypeShareButton];
    self.detailModel = nil;
}

- (void)shareWithExploreEntry:(ExploreEntry*)entry
{
    self.curShareSourceType = TTShareSourceObjectTypePGC;
    NSArray * activityItems = [ArticleShareManager shareActivityManager:[self shareManager] exploreEntry:entry];
    self.phoneShareView = [[SSActivityView alloc] init];
    self.phoneShareView.delegate = self;
    self.phoneShareView.activityItems = activityItems;
    //    UIViewController *topVC = [TTUIResponderHelper topViewControllerFor: self.webView];
    [self.phoneShareView showOnViewController:[TTUIResponderHelper mainWindowRootViewController]];
    [self sendPGCShareTrackWithItemType:TTActivityTypeShareButton];
}

- (void)shareWithmediaID:(NSString *)mediaID callbackId:(NSString *)callbackId {
    [[ExploreFetchEntryManager sharedManager] fetchEntryByMediaID:mediaID finishBlock:^(ExploreEntry *entry, NSError *error) {
        if(error)
        {
            if (callbackId) {
                [self invokeJSWithCallbackID:callbackId parameters:@{@"code": @NO}];
            }
        }
        else
        {
            UIImage *image = [TTWebImageManager imageForURLString:entry.imageURLString];
            if(image)
            {
                [self shareWithExploreEntry:entry];
            }
            else
            {
                if (!self.imageManager) {
                    self.imageManager = [[SDWebImageManager alloc] init];
                }
                
                [self.imageManager cancelAll];
                WeakSelf;
                [self.imageManager loadImageWithURL:[TTStringHelper URLWithURLString:entry.imageURLString] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    StrongSelf;
                    [self shareWithExploreEntry:entry];
                }];
                
            }
        }
    }];
}

#pragma mark - action of share

- (void)shareWithUserID:(NSString *)uid callbackId:(NSString *)callbackId {
    if (isEmptyString(self.userID)) {
        self.userID = uid;
    }
    NSDictionary *shareObject = [TTProfileShareService shareObjectForUID:uid];
    if(!shareObject) {
        if (callbackId) {
            [self invokeJSWithCallbackID:callbackId parameters:@{@"code": @(NO)}];
        }
    } else {
        if (!self.imageManager) {
            self.imageManager = [[SDWebImageManager alloc] init];
        } else {
            [self.imageManager cancelAll];
        }
        
        __weak typeof(self) wself = self;
        void (^TTProfileShareBlock)() = ^() {
            __strong typeof(wself) sself = wself;
            
            BOOL isAccountUser = [[TTAccountManager sharedManager] isAccountUserOfUID:uid];
            NSArray *activityItems = [ArticleShareManager shareActivityManager:sself.shareManager profileShareObject:shareObject isAccountUser:isAccountUser];
            sself.curShareSourceType = TTShareSourceObjectTypeProfile;
            sself.phoneShareView = [[SSActivityView alloc] init];
            sself.phoneShareView.activityItems = activityItems;
            sself.phoneShareView.delegate = sself;
            
            [sself.phoneShareView showOnViewController:[TTUIResponderHelper mainWindowRootViewController]];
        };
        
        if ([[SDImageCache sharedImageCache] imageFromCacheForKey:[shareObject valueForKey:@"avatar_url"]]) {
            if (TTProfileShareBlock) TTProfileShareBlock();
        } else {
            [self.imageManager loadImageWithURL:[TTStringHelper URLWithURLString:[shareObject valueForKey:@"avatar_url"]] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (TTProfileShareBlock) TTProfileShareBlock();
            }];
            
        }
    }
}

- (void)registerOpenAction
{
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        NSMutableString * openURL = nil;
        NSString * type = [result objectForKey:@"type"];
        if ([type isEqualToString:@"detail"]) {
            NSString * groupID = [(NSDictionary *)[result objectForKey:@"args"] objectForKey:@"groupid"];
            if ([groupID longLongValue] != 0) {
                openURL = [NSMutableString stringWithFormat:@"sslocal://detail?groupid=%@", groupID];
                NSString * gdLabel = [(NSDictionary *)[result objectForKey:@"args"] objectForKey:@"gd_label"];
                if (!isEmptyString(gdLabel)) {
                    [openURL appendFormat:@"&gd_label=%@", gdLabel];
                }
                id itemID = [(NSDictionary *)[result objectForKey:@"args"] objectForKey:@"item_id"];
                if (itemID) {
                    [openURL appendFormat:@"&item_id=%@", itemID];
                    id aggrType = [(NSDictionary *)[result objectForKey:@"args"] objectForKey:@"aggr_type"];
                    if (aggrType) {
                        [openURL appendFormat:@"&aggr_type=%@", aggrType];
                    }
                }
            }
        }
        else if([type isEqualToString:@"webview"]) {
            NSString * urlStr = [(NSDictionary *)[result objectForKey:@"args"] objectForKey:@"url"];
            if (!isEmptyString(urlStr)) {
                openURL = [NSMutableString stringWithFormat:@"sslocal://webview?url=%@", urlStr];
                BOOL rotate = [[(NSDictionary *)[result objectForKey:@"args"] objectForKey:@"rotate"] boolValue];
                if (rotate) {
                    [openURL appendString:@"&supportRotate=1"];
                }
            }
        }
        else if([type isEqualToString:@"media_account"]) {
            NSString * entryID = [(NSDictionary *)[result objectForKey:@"args"] objectForKey:@"entry_id"];
            if ([entryID longLongValue] != 0) {
                openURL = [NSMutableString stringWithFormat:@"sslocal://media_account?mediaID=%@", entryID];
            }
        }
        else if([type isEqualToString:@"profile"]) {
            NSString * uid = [(NSDictionary *)[result objectForKey:@"args"] objectForKey:@"uid"];
            if ([uid longLongValue] != 0) {
                openURL = [NSMutableString stringWithFormat:@"sslocal://profile?uid=%@", uid];
            }
        }
        else if([type isEqualToString:@"feedback"] && ![TTDeviceHelper isPadDevice]) {
            openURL = [NSMutableString stringWithString:@"sslocal://feedback"];;
        }
        
        if (!isEmptyString(openURL)) {
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL]];
            return @{@"code": @1};
        }
        return @{@"code": @0};
        
    } forJSMethod:@"open" authType:SSJSBridgeAuthProtected];
}

/**
 *  打开火山直播间，充值页
 */
- (void)registerOpenHotsoon {
    WeakSelf;
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        __unused StrongSelf;
        if (executeCallback) {
            *executeCallback = NO;
        }
        
        NSString *type = [result tt_stringValueForKey:@"type"];
        NSString *schema = nil;
        
        // 打开直播间
        if ([type isEqualToString:@"room"]) {
            schema = @"sslocal://huoshan";
        }
        // 充值
        else if ([type isEqualToString:@"charge"]) {
            if ([TTAccountManager isLogin]) {
                schema = @"sslocal://huoshancharge";
            } else {
                schema = @"sslocal://login";
            }
        }
        
        if (!isEmptyString(schema)) {
            NSDictionary *args = [result tt_dictionaryValueForKey:@"args"];
            NSURL *url = [TTURLUtils URLWithString:schema queryItems:args];
            if ([[TTRoute sharedRoute] canOpenURL:url]) {
                [[TTRoute sharedRoute] openURLByPushViewController:url];
                return @{@"code": @1};
            }
        }
        
        return @{@"code": @0};
        
    } forJSMethod:@"openHotsoon" authType:SSJSBridgeAuthProtected];
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (view == _phoneShareView) {
        if (self.curShareSourceType == TTShareSourceObjectTypePGC) {
            [self shareManager].isShareMedia = YES;
            [[self shareManager] performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor: self.webView] sourceObjectType:self.curShareSourceType uniqueId:self.mediaID];
            self.phoneShareView = nil;
            
            if (self.curShareSourceType == TTShareSourceObjectTypePGC) {
                [self sendPGCShareTrackWithItemType:itemType];
                if(!isEmptyString(_sharePGCCallbackID))
                {
                    BOOL result = (itemType != TTActivityTypeNone);
                    [self invokeJSWithCallbackID:_sharePGCCallbackID parameters:@{@"code": @(result)}];
                    self.sharePGCCallbackID = nil;
                }
            } else {
                [self sendVideoSubjectShareTrackWithItemType:itemType];
            }
        } else if (self.curShareSourceType == TTShareSourceObjectTypeProfile) {
            if (itemType == TTActivityTypeNightMode){
                BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
                NSString *eventID = nil;
                if (isDayMode){
                    [[TTThemeManager sharedInstance_tt] switchThemeModeto:TTThemeModeNight];
                    eventID = @"click_to_night";
                }
                else{
                    [[TTThemeManager sharedInstance_tt] switchThemeModeto:TTThemeModeDay];
                    eventID = @"click_to_day";
                }
                wrapperTrackEvent(@"profile", eventID);
                
                //做一个假的动画效果 让夜间渐变
                UIView *imageScreenshot = [[TTUIResponderHelper mainWindow] snapshotViewAfterScreenUpdates:NO];
                [[TTUIResponderHelper mainWindow] addSubview:imageScreenshot];
                [UIView animateWithDuration:0.5f animations:^{
                    imageScreenshot.alpha = 0;
                } completion:^(BOOL finished) {
                    [imageScreenshot removeFromSuperview];
                }];
            }
            else if (itemType == TTActivityTypeFontSetting){
                [self.phoneShareView fontSettingPressed];
            }
            else { // Share
                [[self shareManager] performActivityActionByType:itemType inViewController:[TTUIResponderHelper topNavigationControllerFor:self.webView] sourceObjectType:self.curShareSourceType uniqueId:self.userID adID:nil platform:TTSharePlatformTypeOfMain groupFlags:self.detailModel.detailModel.article.groupFlags];
                self.phoneShareView = nil;
                
                NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:self.curShareSourceType];
                NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
                if (itemType == TTActivityTypeNone) {
                    tag = @"profile";
                }
                
                NSDictionary *profileDict = [TTProfileShareService shareObjectForUID:self.userID];
                
                NSString *mediaID = [profileDict tt_stringValueForKey:@"media_id"];
                if (!isEmptyString(mediaID) && ![mediaID isEqualToString:@"0"]) {
                    self.mediaID = mediaID;
                }
                
                //ugly code 个人主页的取消分享需要单独修改label
                if ([tag isEqualToString:@"profile"] && [label isEqualToString:@"share_cancel_button"]) {
                    label = @"profile_more_close";
                }
                
                [TTTrackerWrapper event:tag label:label value:self.mediaID extValue:self.userID extValue2:nil];
            }
        } else {
            [[self shareManager] performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor: self.webView] sourceObjectType:self.curShareSourceType uniqueId:self.userID];
            self.phoneShareView = nil;
            
            if (self.curShareSourceType == TTShareSourceObjectTypePGC) {
                [self sendPGCShareTrackWithItemType:itemType];
                if(!isEmptyString(_sharePGCCallbackID))
                {
                    BOOL result = (itemType != TTActivityTypeNone);
                    [self invokeJSWithCallbackID:_sharePGCCallbackID parameters:@{@"code": @(result)}];
                    self.sharePGCCallbackID = nil;
                }
            } else {
                [self sendVideoSubjectShareTrackWithItemType:itemType];
            }
        }
    }
}

- (TTActivityShareManager*)shareManager
{
    @synchronized(self)
    {
        if(!_shareManager)
        {
            _shareManager = [[TTActivityShareManager alloc] init];
        }
        
        return _shareManager;
    }
}

- (void)removeAccountNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SHARE_ONE_DISMISS object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTAccountPlatformDidAuthorizeCompletionNotification object:nil];
}

- (void)registerStatusRelatedNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kEntrySubscribeStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeStatusChangedNotification:) name:kEntrySubscribeStatusChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RelationActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relationActionNotification:) name:RelationActionSuccessNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kForumLikeStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forumLikeStatusChangedNotification:) name:kForumLikeStatusChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FRConcernEntityCareStateChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(concernCareStatusChangedNotification:) name:FRConcernEntityCareStateChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kArticleJSBrdigePGCDonateFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pgcArticleDonateFinishedNotification:) name:kArticleJSBrdigePGCDonateFinishedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHasBlockedUnblockedUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUnblockUserNotification:) name:kHasBlockedUnblockedUserNotification object:nil];
    
    [TTAccount removeMulticastDelegate:self];
    [TTAccount addMulticastDelegate:self];
}

// web 通知app注册状态改变通知
- (void)registerAddEventListener
{
    __weak ArticleJSBridge *weakself = self;
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        if ([result[@"name"] isEqualToString:@"page_state_change"]) {
            [weakself registerStatusRelatedNotification];
        }
        return @{@"code": @1};
        
    } forJSMethod:@"addEventListener" authType:SSJSBridgeAuthPublic];
}

- (void)subscribeStatusChangedNotification:(NSNotification*)notification
{
    if(![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain])
    {
        return;
    }
    
    //忽略从js bridge抛出的通知
    if([notification.object isKindOfClass:[ArticleJSBridge class]])
    {
        return;
    }
    
    ExploreEntry *entry = [notification.userInfo objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    if(entry)
    {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:entry.entryID forKey:@"id"];
        [param setValue:([entry.subscribed boolValue] ? @1 : @0) forKey:@"status"];
        [param setValue:@"pgc_action" forKey:@"type"];
        [self invokeJSWithEventID:@"page_state_change" parameters:param finishBlock:nil];
    }
}


- (void)relationActionNotification:(NSNotification*)notification
{
    if(![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain])
    {
        return;
    }
    
    //忽略从js bridge抛出的通知
    if([notification.object isKindOfClass:[ArticleJSBridge class]])
    {
        return;
    }
    
    FriendActionType tType = [[notification.userInfo objectForKey:kRelationActionSuccessNotificationActionTypeKey] intValue];
    if(tType == FriendActionTypeFollow || tType == FriendActionTypeUnfollow)
    {
        NSString *userID = [notification.userInfo objectForKey:kRelationActionSuccessNotificationUserIDKey];
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:tType == FriendActionTypeFollow ? @1 : @0 forKey:@"status"];
        [param setValue:userID forKey:@"id"];
        [param setValue:@"user_action" forKey:@"type"];
        [self invokeJSWithEventID:@"page_state_change" parameters:param finishBlock:nil];
    }
}

- (void)forumLikeStatusChangedNotification:(NSNotification*)notification
{
    if(![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain])
    {
        return;
    }
    
    //忽略从js bridge抛出的通知
    if (notification.object == self)
    {
        return;
    }
    
    NSString *forumID = [notification.userInfo objectForKey:kForumLikeStatusChangeForumIDKey];
    NSNumber *liked = [notification.userInfo objectForKey:kForumLikeStatusChangeForumLikeKey];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:forumID forKey:@"id"];
    [param setValue:liked forKey:@"status"];
    [param setValue:@"forum_action" forKey:@"type"];
    [self invokeJSWithEventID:@"page_state_change" parameters:param finishBlock:nil];
}

- (void)concernCareStatusChangedNotification:(NSNotification *)notification {
    if(![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain])
    {
        return;
    }
    
    //忽略从js bridge抛出的通知
    if (notification.object == self)
    {
        return;
    }
    NSString *concernID = [notification.userInfo objectForKey:FRConcernEntityCareStateChangeConcernIDKey];
    NSNumber *careState = [notification.userInfo objectForKey:FRConcernEntityCareStateChangeConcernStateKey];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:concernID forKey:@"id"];
    [param setValue:careState forKey:@"status"];
    [param setValue:@"concern_action" forKey:@"type"];
    [self invokeJSWithEventID:@"page_state_change" parameters:param finishBlock:nil];
}

- (void)pgcArticleDonateFinishedNotification:(NSNotification *)notification {
    if((![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain]) ||
       notification.object == self) {
        return;
    }
    
    NSDictionary *params = @{@"type":   notification.userInfo[@"type"],
                             @"id":     notification.userInfo[@"id"],
                             @"status": notification.userInfo[@"status"]
                             };
    
    [self invokeJSWithEventID:@"page_state_change" parameters:params finishBlock:nil];
}

- (void)blockUnblockUserNotification:(NSNotification *)notification
{
    if((![self isAuthorizedForEvent:@"page_state_change"] && ![self isInnerDomain]) ||
       notification.object == self) {
        return;
    }
    
    NSDictionary * userInfo = [notification userInfo];
    NSString * userID = [userInfo valueForKey:kBlockedUnblockedUserIDKey];
    NSNumber *isBlocking = [userInfo valueForKey:kIsBlockingKey];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:userID forKey:@"id"];
    [param setValue:isBlocking forKey:@"status"];
    [param setValue:@"block_action" forKey:@"type"];
    
    [self invokeJSWithEventID:@"page_state_change" parameters:param finishBlock:nil];
}

- (void)registerPageStateChange
{
    __weak ArticleJSBridge *weakself = self;
    
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        NSString *type = [result objectForKey:@"type"];
        NSString *entryID = [NSString stringWithFormat:@"%@", [result objectForKey:@"id"]];
        NSNumber *status = [result objectForKey:@"status"];
        int code = 1;
        if([type isEqualToString:@"pgc_action"])
        {
            if(!isEmptyString(entryID))
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPGCSubscribeStatusChangedNotification object:nil];
                NSArray *entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];
                
                ExploreEntry *entry;
                
                if(entries.count > 0)
                {
                    entry = entries[0];
                } else {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setValue:entryID forKey:@"id"];
                    [dic setValue:@1 forKey:@"type"];
                    [dic setValue:@0 forKey:@"subscribed"];
                    [dic setValue:[NSNumber numberWithInteger:entryID.integerValue] forKey:@"media_id"];
                    [dic setValue:entryID forKey:@"entry_id"];
                    
                    entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
                }
                
                if ([status intValue] == 1)
                {
//                    //第一次关注头条号动画
//                    if([TTFirstConcernManager firstTimeGuideEnabled]){
//                        TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                        [manager showFirstConcernAlertViewWithDismissBlock:nil];
//                    }
                    
                    entry.subscribed = @(NO);
                    [[ExploreEntryManager sharedManager] subscribeExploreEntry:entry notify:NO notifyFinishBlock:nil];
                }
                else
                {
                    entry.subscribed = @(YES);
                    [[ExploreEntryManager sharedManager] unsubscribeExploreEntry:entry notify:NO notifyFinishBlock:nil];
                }
                [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                                 actionType:[status intValue] == 1?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                                   itemType:TTFollowItemTypeDefault
                                                                   userInfo:nil];
            }
        }
        else if ([type isEqualToString:@"donate_action"]) { // 头条号文章赞赏
            if (!isEmptyString(entryID)) {
                
                NSDictionary *userInfo = @{@"type":   type,
                                           @"id":     entryID,
                                           @"status": status ? : @""
                                           };
                [[NSNotificationCenter defaultCenter] postNotificationName:kArticleJSBrdigePGCDonateFinishedNotification object:weakself userInfo:userInfo];
            }
        }
        else if([type isEqualToString:@"user_action"])
        {
//            //第一次关注用户引导动画
//            if ([status boolValue]) {
//                if ([TTFirstConcernManager firstTimeGuideEnabled]) {
//                    TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                    [manager showFirstConcernAlertViewWithDismissBlock:nil];
//                }
//            }
            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                             actionType:status.boolValue?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                               itemType:TTFollowItemTypeDefault
                                                               userInfo:nil];
            FriendActionType actionType = ([status intValue] == 0 ? FriendActionTypeUnfollow : FriendActionTypeFollow);
            [[NSNotificationCenter defaultCenter] postNotificationName:RelationActionSuccessNotification object:weakself userInfo:@{kRelationActionSuccessNotificationActionTypeKey : @(actionType), kRelationActionSuccessNotificationUserIDKey: (isEmptyString(entryID)?@"":entryID)}];
        }
        else if ([type isEqualToString:@"block_action"])
        {
            if (!isEmptyString(entryID)) {
                NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
                [userInfo setValue:entryID forKey:kBlockedUnblockedUserIDKey];
                [userInfo setValue:status forKey:kIsBlockingKey];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kHasBlockedUnblockedUserNotification object:weakself userInfo:userInfo];
            }
        }
        else if([type isEqualToString:@"forum_action"])
        {
            //            NSString *from = [result objectForKey:@"from"];
            //            [ExploreForumManager trackForumFollow:(status.intValue != 0) forumID:entryID groupModel:nil enterFrom:from];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kForumLikeStatusChangeNotification
                                                                object:weakself
                                                              userInfo:@{kForumLikeStatusChangeForumLikeKey: ([status intValue] == 0 ? @NO : @YES),  kForumLikeStatusChangeForumIDKey: (isEmptyString(entryID)?@"":entryID)}];
        }else if ([type isEqualToString:@"concern_action"])
        {
            if (entryID) {
//                //第一次关注实体词引导动画
//                if ([status boolValue]) {
//                    if ([TTFirstConcernManager firstTimeGuideEnabled]){
//                        TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                        [manager showFirstConcernAlertViewWithDismissBlock:nil];
//                    }
//                }
                [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                                 actionType:status.boolValue?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                                   itemType:TTFollowItemTypeDefault
                                                                   userInfo:nil];
                NSDictionary * userInfo = @{FRNeedUpdateConcernEntityConcernIDKey:entryID,
                                            FRNeedUpdateConcernEntityConcernStateKey:([status intValue] == 0 ? @NO : @YES)};
                [[NSNotificationCenter defaultCenter] postNotificationName:FRNeedUpdateConcernEntityCareStateNotification object:weakself userInfo:userInfo];
            }
        }
        else if ([type isEqualToString:@"wenda_rm"]) {
            if (entryID) {
                NSDictionary * userInfo = @{WDAnswerEntityRemoveNotificationIDKey:entryID,
                                            WDAnswerEntityRemoveNotificationStatusKey:([status intValue] == 0 ? @NO : @YES)};
                [[NSNotificationCenter defaultCenter] postNotificationName:WDAnswerEntityRemoveNotification object:weakself userInfo:userInfo];
            }
        }
        else if ([type isEqualToString:@"stock_action"]){
//            if ([status boolValue]){
//                if ([TTFirstConcernManager firstTimeGuideEnabled]){
//                    TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                    [manager showFirstConcernAlertViewWithDismissBlock:nil];
//                }
//            }
            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                             actionType:status.boolValue?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                               itemType:TTFollowItemTypeDefault
                                                               userInfo:nil];
        }
        else if ([type isEqualToString:@"live_follow_action"]) {
            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                             actionType:status.boolValue?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                               itemType:TTFollowItemTypeDefault
                                                               userInfo:nil];
        }
        else
        {
            code = 0;
        }
        
        return @{@"code": @(code)};
        
        
    } forJSMethod:@"page_state_change" authType:SSJSBridgeAuthProtected];
}

- (void)registerAddChannel
{
    __weak ArticleJSBridge *weakself = self;
    
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        
        NSString *categoryID = [result objectForKey:@"category"];
        if(isEmptyString(categoryID))
        {
            return @{@"code": @0};
        }
        
        TTCategory *categoryModel = [TTArticleCategoryManager categoryModelByCategoryID:categoryID];
        if (!categoryModel) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:categoryID forKey:@"category"];
            [dict setValue:[result objectForKey:@"name"] forKey:@"name"];
            [dict setValue:[result objectForKey:@"type"] forKey:@"type"];
            [dict setValue:[result objectForKey:@"web_url"] forKey:@"web_url"];
            [dict setValue:[result objectForKey:@"flags"] forKey:@"flags"];
            categoryModel = [TTArticleCategoryManager insertCategoryWithDictionary:dict];
        }
        
        NSMutableDictionary * extraDict = [[NSMutableDictionary alloc] initWithDictionary:result];
        [extraDict setValue:categoryID forKey:@"category_name"];
        [extraDict setValue:nil forKey:@"category"];
        wrapperTrackEventWithCustomKeys(@"add_channel", @"click", nil, nil, extraDict);
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:categoryModel forKey:kTTInsertCategoryNotificationCategoryKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTInsertCategoryToLastPositionNotification object:weakself userInfo:userInfo];
        
        return @{@"code": @1};
        
    } forJSMethod:@"addChannel" authType:SSJSBridgeAuthProtected];
}

- (void)registerGetSubScribedChannelList
{
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        NSArray *categories = [[TTArticleCategoryManager sharedManager] subScribedCategories];
        __block NSMutableArray *list = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[TTCategory class]]) {
                TTCategory *category = (TTCategory *)obj;
                if (!isEmptyString(category.categoryID)) {
                    [list addObject:category.categoryID];
                }
            }
        }];
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
        [data setValue:@(1) forKey:@"code"];
        [data setValue:list forKey:@"list"];
        return data;
    } forJSMethod:@"getSubScribedChannelList" authType:SSJSBridgeAuthProtected];
}

- (void)registerSystemShare
{
    __weak ArticleJSBridge *weakself = self;
    
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        
        weakself.shareData = result;
        return @{@"code": @1};
        
    } forJSMethod:@"systemShare" authType:SSJSBridgeAuthProtected];
}

- (void)registerCopyToClipboard
{
    [self registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        NSString *content = [result stringValueForKey:@"content" defaultValue:nil];
        NSDictionary *callbackResult = nil;
        if (!isEmptyString(content)) {
            [[UIPasteboard generalPasteboard] setString:content];
            callbackResult = @{@"code": @1};
        }
        else {
            callbackResult = @{@"code": @0};
        }
        return callbackResult;
    } forJSMethod:@"copyToClipboard" authType:SSJSBridgeAuthProtected];
}

- (NSDictionary*)replacedSharedDataForData:(NSDictionary*)data
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithDictionary:data];
    NSString *sharedPlatform = [self sharedPlatformForData:data];
    if([self shouldReplaceShareData:sharedPlatform])
    {
        [ret setValuesForKeysWithDictionary:_shareData];
    }
    
    return ret;
}

- (BOOL)shouldReplaceShareData:(NSString*)targetPlatform
{
    NSString *platform = [_shareData objectForKey:@"platform"];
    if(isEmptyString(platform) || [platform isEqualToString:[_shareData objectForKey:@"platform"]])
    {
        return YES;
    }
    
    return NO;
}

- (void)sendPGCShareTrackWithItemType:(TTActivityType)itemType
{
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypePGC];
    NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
    wrapperTrackEventWithCustomKeys(tag, label, _mediaID, nil, nil);
}

- (void)sendVideoSubjectShareTrackWithItemType:(TTActivityType)itemType
{
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeVideoSubject];
    NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
    wrapperTrackEventWithCustomKeys(tag, label, _mediaID, nil, nil);
}

@end

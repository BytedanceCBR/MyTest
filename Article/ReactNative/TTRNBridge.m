//
//  TTRNBridgeModule.m
//  Article
//
//  Created by Chen Hong on 16/7/15.
//
//

#import "TTRNBridge.h"

// toast
#import "TTIndicatorView.h"

#import "RCTConvert.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "TTRoute.h"

// login/account
#import <TTAccountBusiness.h>
#import "ArticleAddressBridger.h"
#import "ArticleAddressManager.h"
#import "UIImage+TTThemeExtension.h"
#import "TTStringHelper.h"

#import "TTRNBridge+Cell.h"
#import "TTRNBridge+Call.h"

#import "ExploreEntryManager.h"
#import "TTNetworkManager.h"

#import "FriendDataManager.h"
//#import "FRForumOnlooksManager.h"
//#import "FRConcernEntity.h"
#import "TTBlockManager.h"
#import "TTFollowNotifyServer.h"
#import "WDDefines.h"
#import "SSUserSettingManager.h"
#import "NewsUserSettingManager.h"
#import "NSString+URLEncoding.h"
#import <TTBaseLib/JSONAdditions.h>
#import "ExploreMovieView.h"
#import "SSWebViewController.h"


#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
#import "TTAdCanvasFormViewController.h"
#import "TTAdAppointAlertView.h"

/* 打包命令
 react-native bundle --platform ios --entry-file index.ios.js --bundle-output ./index.ios.bundle --assets-dest ./ --dev false --minify
 */


@interface TTRNBridge ()
<
TTAccountMulticastProtocol
>

@property (nonatomic, copy) RCTResponseSenderBlock loginCallback;

@end

@implementation TTRNBridge

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged:) name:kSettingFontSizeChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookChanged:) name:kAddressBookHasGotNotification object:nil];
        
        // Account Notifications
        [TTAccount addMulticastDelegate:self];
        
        [self registerStatusRelatedNotification];
        
        [self registerCommonHandlers];
        
    }
    return self;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport {
    NSString * model = [[UIDevice currentDevice] model];
    return @{@"deviceModel" : model};
}

//- (NSArray<NSString *> *)supportedEvents
//{
//    return @[@"accountChanged",
//             @"themeChanged",
//             @"addressbookSynced"];
//}

- (void)registerCommonHandlers {
    __weak typeof(self) wself = self;
    
    // back
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself close];
    } forMethod:@"close"];
    
    // log
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself log:result];
    } forMethod:@"log"];
    
    // log_v3
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself log_v3:result];
    } forMethod:@"log_v3"];
    
    // toast
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself toast:result];
    } forMethod:@"toast"];
    
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSString *url = [result tt_stringValueForKey:@"url"];
        [wself open:url callback:callback];
    } forMethod:@"open"];
    
    // login
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself login:result callback:callback];
    } forMethod:@"login"];
    
    // do_media_like
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself doMediaLike:result callback:callback];
    } forMethod:@"do_media_like"];
    
    // do_media_unlike
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself doMediaUnLike:result callback:callback];
    } forMethod:@"do_media_unlike"];
    
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself request:result callback:callback];
    } forMethod:@"request"];
    
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself addEventListener];
    } forMethod:@"addEventListener"];
    
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself registerPageStateChange:result];
    } forMethod:@"page_state_change"];
    
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        NSString *phoneNumber = [result tt_stringValueForKey:@"tel_num"];
        [wself callNativePhone:phoneNumber];
    } forMethod:@"callNativePhone"];
    
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself downloadApp:result];
    } forMethod:@"downloadApp"];
    
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself showFormDialog:result];
    } forMethod:@"showFormDialog"];
    
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself isWifi:result callback:callback];
    } forMethod:@"isWifi"];
    
    [self registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        [wself canvasLog:result];
    } forMethod:@"canvasLog"];
}

RCT_EXPORT_METHOD(ReportPageStatus:(NSDictionary *)dict) {
    if ([SSCommonLogic isRNMonitorEnable]) {
        TTRNMethod method = [self.methodHandlers valueForKey:@"ReportPageStatus"];
        if (method && [dict isKindOfClass:[NSDictionary class]]) {
            method(dict, nil);
        }
    }
}

/**
 *  log
 */
RCT_EXPORT_METHOD(log:(NSDictionary *)dict) {
    NSDictionary *data = dict;
    if (![dict valueForKey:@"category"]) {
        NSMutableDictionary *mDict = [dict mutableCopy];
        [mDict setValue:@"umeng" forKey:@"category"];
        data = mDict;
    }
    
    NSString *extraString = [data tt_stringValueForKey:@"extra"];
    
    if (!isEmptyString(extraString)) {
        extraString = [extraString URLDecodedString];
        
        NSError *error = nil;
        NSDictionary *extraDict = [NSString tt_objectWithJSONString:extraString error:&error];
        if (!error && [extraDict isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:data];
            [parameters setValue:nil forKey:@"extra"];
            [parameters addEntriesFromDictionary:extraDict];
            data = parameters;
        }
    }
    
    [TTTrackerWrapper eventData:data];
}

RCT_EXPORT_METHOD(log_v3:(NSDictionary *)dict) {
    NSString *event = [dict tt_stringValueForKey:@"event"];
    NSDictionary *params = [dict tt_dictionaryValueForKey:@"params"];
    BOOL isDoubleSending = [dict tt_boolValueForKey:@"is_double_sending"];
    
    if (!isEmptyString(event)) {
         [TTTrackerWrapper eventV3:event params:params isDoubleSending:isDoubleSending];
    }
}

/**
 *  toast
 */
RCT_EXPORT_METHOD(toast:(NSDictionary *)result) {
    NSString *text = [RCTConvert NSString:result[@"text"]];
    // `icon_type` 可选，目前仅一种 type ，即 `icon_success`。
    if (!isEmptyString(text)) {
        NSString *iconType = [RCTConvert NSString:result[@"icon_type"]];
        if ([iconType isKindOfClass:[NSString class]] && [iconType isEqualToString:@"icon_success"]) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
        else if ([iconType isKindOfClass:[NSString class]] && [iconType isEqualToString:@"icon_close"]) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
        else {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
    }
}

/**
 *  open
 */
RCT_EXPORT_METHOD(open:(NSString *)url callback:(RCTResponseSenderBlock)callback) {
    BOOL flag = NO;
    if (!isEmptyString(url)) {
        if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:url]]) {
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:url]];
            // TODO: 升级TTRoute
            flag = YES;
        } else {
            SSWebViewController * controller = [[SSWebViewController alloc] initWithSupportIPhoneRotate:YES];
            [controller requestWithURL:[TTStringHelper URLWithURLString:url]];
            UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor: nil];
            [topController pushViewController:controller animated:YES];
            flag = YES;
        }
    }
    
    if (callback) {
        callback(@[ @(flag) ]);
    }
}

/**
 *  phone
 */
RCT_EXPORT_METHOD(callNativePhone:(NSString *)phoneNumber) {
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [[adManagerInstance class] call_callWithNumber:phoneNumber];
    [adManagerInstance canvas_canvasCall];
}

/**
 *  downloadApp
 */
RCT_EXPORT_METHOD(downloadApp:(NSDictionary*)result) {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[RCTConvert NSString:result[@"download_url"]] forKey:@"download_url"];
    [dict setValue:[RCTConvert NSString:result[@"apple_id"]] forKey:@"apple_id"];
    [dict setValue:[RCTConvert NSString:result[@"open_url"]] forKey:@"open_url"];
    [dict setValue:[RCTConvert NSString:result[@"ipa_url"]] forKey:@"ipa_url"];
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [[adManagerInstance class] app_downloadAppDict:dict];
    [adManagerInstance canvas_trackCanvasTag:@"detail_immersion_ad" label:@"click" dict:nil];
}

/**
 *  打开Form
 */
RCT_EXPORT_METHOD(showFormDialog:(NSDictionary*)result) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (result[@"adId"]) {
        dict[@"adId"] = [NSString stringWithFormat:@"%@", result[@"adId"]];
    }
    [dict setValue:[RCTConvert NSString:result[@"logExtra"]] forKey:@"logExtra"];
    [dict setValue:[RCTConvert NSString:result[@"url"]] forKey:@"url"];
    [dict setValue:[RCTConvert NSString:result[@"jscript"]] forKey:@"jscript"];
    [dict setValue:[RCTConvert NSNumber:result[@"width"]] forKey:@"width"];
    [dict setValue:[RCTConvert NSNumber:result[@"height"]] forKey:@"height"];
    if (dict[@"url"] == nil) {
        return;
    }
    TTAdAppointAlertScriptModel *model = [[TTAdAppointAlertScriptModel alloc] initWithFormUrl:dict[@"url"] width:dict[@"width"] height:dict[@"height"] sizeValid:@(0)];
    model.log_extra = dict[@"logExtra"];
    model.ad_id = dict[@"adId"];
    model.javascriptString = dict[@"jscript"];
    if (model == nil) {
        return;
    }
    TTAdCanvasFormViewController *formVC = [[TTAdCanvasFormViewController alloc] initWithNibName:nil bundle:nil];
    formVC.model = model;
    [[TTUIResponderHelper topmostViewController] presentViewController:formVC animated:YES completion:^{
        
    }];
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance canvas_trackCanvasTag:@"detail_immersion_ad" label:@"click" dict:nil];
}

/**
 *  isWifi
 */
RCT_EXPORT_METHOD(isWifi:(NSDictionary*)result callback:(RCTResponseSenderBlock)callback) {
    callback(@[@(TTNetworkWifiConnected())]);
}

/**
 *  沉浸式统计
 */
RCT_EXPORT_METHOD(canvasLog:(NSDictionary *)dict) {
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance canvas_trackRN:dict];
}

/**
 *  login
 */
RCT_EXPORT_METHOD(login:(NSDictionary *)result callback:(RCTResponseSenderBlock)callback) {
    
    self.loginCallback = callback;
    
    NSString *platform = [RCTConvert NSString:result[@"platform"]];
    TTAccountLoginAlertTitleType type = [result tt_integerValueForKey:@"title_type"];
    NSString *source = [result tt_stringValueForKey:@"login_source"];
    NSString *title = [result tt_stringValueForKey:@"title"];
    NSString *alertTitle = [result tt_stringValueForKey:@"alert_title"];
    
    // 已登录并且不是qq、微信、weibo等其他登录方式时，直接返回登录成功
    if ([TTAccountManager isLogin] && isEmptyString(platform)) {
        if (self.loginCallback) {
            self.loginCallback(@[@{@"code": @1}]);
            self.loginCallback = nil;
        }
        return;
    }
    
    [self addAccountNotification];
    
    //全平台
    if (isEmptyString(platform)) {
        WeakSelf;
        if (title.length > 0 || alertTitle.length > 0) {
            [TTAccountLoginManager showLoginAlertWithTitle:alertTitle source:source completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
                StrongSelf;
                if (type == TTAccountAlertCompletionEventTypeTip) {
                    [TTAccountLoginManager presentLoginViewControllerFromVC:[TTUIResponderHelper topNavigationControllerFor:self.rnView] title:title source:source completion:^(TTAccountLoginState state) {
                        
                    }];
                }
            }];
        } else {
            [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                StrongSelf;
                if (type == TTAccountAlertCompletionEventTypeTip) {
                    [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self.rnView] type:TTAccountLoginDialogTitleTypeDefault source:source completion:^(TTAccountLoginState state) {
                    }];
                }
            }];
        }
    }
    else if([platform isEqualToString:@"qq"])
    {
        [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_QZONE completion:^(BOOL success, NSError * _Nonnull error) {
            
        }];
    }
    else if([platform isEqualToString:@"weibo"])
    {
        [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_SINA_WEIBO completion:^(BOOL success, NSError * _Nonnull error) {
            
        }];
    }
    else if([platform isEqualToString:@"weixin"])
    {
        [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_WEIXIN completion:^(BOOL success, NSError * _Nonnull error) {
            
        }];
    }
    else if([platform isEqualToString:@"qq_weibo"])
    {
        [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_QQ_WEIBO completion:^(BOOL success, NSError * _Nonnull error) {
            
        }];
    }
    else
    {
        if (self.loginCallback) {
            self.loginCallback(@[@{@"code": @0}]);
            self.loginCallback = nil;
        }
    }
}

/**
 *  syncFeedInterestWords
 */
RCT_EXPORT_METHOD(syncFeedInterestWords:(NSDictionary *)result) {
    if ([result isKindOfClass:[NSDictionary class]] && result.count > 0) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setValue:@(2) forKey:kUserDefaultNewUserActionKey];
        [userDefault setValue:result forKey:kRNCellNewUserActionInterestWordsDictionary];
        [userDefault synchronize];
    }
}

/**
 *  refreshFeedList
 */
RCT_EXPORT_METHOD(refreshFeedList) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTRNBridgeActiveRefreshListViewNotification object:nil userInfo:nil];
    });
}

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    BOOL isLogin = [TTAccountManager isLogin];
    
    NSNumber *state = isLogin ? @1 : @0;
    
    [self invokeJSWithEventID:@"accountChanged" parameters:@{@"islogin": state}];
    
    switch (reasonType) {
        case TTAccountStatusChangedReasonTypeLogout:
        case TTAccountStatusChangedReasonTypeSessionExpiration:
        {
            if (self.loginCallback)
            {
                self.loginCallback(@[@{@"code": @0}]);
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
        case TTAccountStatusChangedReasonTypeAuthPlatformLogin:
        {
            if(self.loginCallback)
            {
                self.loginCallback(@[@{@"code": @1}]);
            }
        }
            break;
    }
    
    self.loginCallback = nil;
}

- (void)loginClosed:(NSNotification*)notification {
    if(![TTAccountManager isLogin])
    {
        if (self.loginCallback) {
            self.loginCallback(@[@{@"code": @0}]);
            self.loginCallback = nil;
        }
        [self removeAccountNotification];
    }
}

- (void)cancelLogin:(NSNotification*)notification {
    if (self.loginCallback) {
        self.loginCallback(@[@{@"code": @0}]);
        self.loginCallback = nil;
    }
    [self removeAccountNotification];
}

- (void)notificationDidAuthCompletion:(NSNotification *)notification
{
    NSDictionary *userInfoInNot = notification.userInfo;
    TTAccountAuthErrCode authErrCode = [userInfoInNot[TTAccountStatusCodeKey] integerValue];
    
    if (authErrCode != TTAccountAuthSuccess) {
        [self cancelLogin:notification];
    }
}

- (void)addAccountNotification {
    // shareone cancel login
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginClosed:) name:@"notification_share_one_dismiss" object:nil];
    
    // third platform authorize completion
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidAuthCompletion:) name:TTAccountPlatformDidAuthorizeCompletionNotification object:nil];
}

- (void)removeAccountNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notification_share_one_dismiss" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTAccountPlatformDidAuthorizeCompletionNotification object:nil];
}

- (void)invokeJSWithEventID:(NSString *)eventID parameters:(NSDictionary *)params {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self.bridge.eventDispatcher sendAppEventWithName:eventID body:params];
#pragma clang diagnostic pop
}

/**
 *  themeChanged
 */
- (void)themeChanged:(NSNotification *)notification {
    NSString *daymode = nil;
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        daymode = @"night";
    } else {
        daymode = @"day";
    }
    [self invokeJSWithEventID:@"themeChangedEvent" parameters:@{@"daymode": daymode}];
}

/**
 *  fontSizeChanged
 */
- (void)fontSizeChanged:(NSNotification *)notification {
    NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
    [self invokeJSWithEventID:@"fontSizeEvent" parameters:@{@"font": fontSizeType}];
}

/**
 *  通讯录已获取
 */
- (void)addressBookChanged:(NSNotification *)notification {
    [self invokeJSWithEventID:@"addressbookSynced" parameters:@{@"code": @1}];
}


// 订阅操作
- (void)subscribe:(BOOL)isSubscribe params:(NSDictionary *)result {
    __weak typeof(self) wself = self;
    ExploreEntry *entry;
    NSString *entryID = [result tt_stringValueForKey:@"id"];
    NSArray *entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];
    
    if (entries.count > 0) {
        entry = entries[0];
    }
    else {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:entryID forKey:@"id"];
        [dic setValue:@1 forKey:@"type"];
        [dic setValue:(isSubscribe?@0:@1) forKey:@"subscribed"];
        [dic setValue:[NSNumber numberWithLongLong:entryID.longLongValue] forKey:@"media_id"];
        [dic setValue:entryID forKey:@"entry_id"];
        
        entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
    }
    
    
    [[ExploreEntryManager sharedManager] exploreEntry:entry changeToSubscribed:YES notify:YES notifyFinishBlock:^(ExploreEntry * _Nullable entry, NSError * _Nullable error) {
        if (!wself) {
            return;
        }
        //失败提示
        if (error ) {
            NSString *msg = [NSString stringWithFormat:@"%@%@失败", (isSubscribe?@"":@"取消"), @"关注"];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            return ;
        }
    }];
}

//do_media_like
//关注
- (void)doMediaLike:(NSDictionary *)result callback:(RCTResponseSenderBlock)callback {
    [self subscribe:YES params:result];
}

//do_media_unlike
//取消关注
- (void)doMediaUnLike:(NSDictionary *)result callback:(RCTResponseSenderBlock)callback {
    [self subscribe:NO params:result];
}


- (void)close {
    UIViewController *topVC = [TTUIResponderHelper topViewControllerFor:self.rnView];
    if (topVC.navigationController) {
        [topVC.navigationController popViewControllerAnimated:YES];
    } else {
        [topVC dismissViewControllerAnimated:YES completion:nil];
    }
}

RCT_EXPORT_METHOD(request:(NSDictionary *)result callback:(RCTResponseSenderBlock)callback) {
    NSString *url = [result tt_stringValueForKey:@"url"];
    NSString *method = [result tt_stringValueForKey:@"type"];
    NSDictionary *params = [result tt_dictionaryValueForKey:@"params"];
    BOOL needCommonParams = [result integerValueForKey:@"needCommonParams" defaultValue:1] != 0;
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:method needCommonParams:needCommonParams callback:^(NSError *error, id jsonObj) {
        if (!callback) return;
        
        if (error) {
            callback(@[jsonObj?:@{@"message": @"error"}]);
        } else {
            callback(@[jsonObj?:@{}]);
        }
    }];
}

- (void)registerPageStateChange:(NSDictionary *)result
{
    NSString *type = [result objectForKey:@"type"];
    NSString *entryID = [NSString stringWithFormat:@"%@", [result objectForKey:@"id"]];
    NSNumber *status = [result objectForKey:@"status"];
    
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
//                //第一次关注头条号动画
//                if([TTFirstConcernManager firstTimeGuideEnabled]){
//                    TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                    [manager showFirstConcernAlertViewWithDismissBlock:nil];
//                }
                
                entry.subscribed = @(NO);
                [[ExploreEntryManager sharedManager] subscribeExploreEntry:entry notify:NO notifyFinishBlock:nil];
            }
            else
            {
                //                    ExploreEntry *entry = [self subscribe:result];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kArticleJSBrdigePGCDonateFinishedNotification" object:nil userInfo:userInfo];
        }
    }
    else if([type isEqualToString:@"user_action"])
    {
//        //第一次关注用户引导动画
//        if ([status boolValue]) {
//            if ([TTFirstConcernManager firstTimeGuideEnabled]) {
//                TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                [manager showFirstConcernAlertViewWithDismissBlock:nil];
//            }
//        }
        [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                         actionType:status.boolValue?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                           itemType:TTFollowItemTypeDefault
                                                           userInfo:nil];
        FriendActionType actionType = ([status intValue] == 0 ? FriendActionTypeUnfollow : FriendActionTypeFollow);
        [[NSNotificationCenter defaultCenter] postNotificationName:RelationActionSuccessNotification object:self userInfo:@{kRelationActionSuccessNotificationActionTypeKey : @(actionType), kRelationActionSuccessNotificationUserIDKey: (isEmptyString(entryID)?@"":entryID)}];
    }
    else if ([type isEqualToString:@"block_action"])
    {
        if (!isEmptyString(entryID)) {
            NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            [userInfo setValue:entryID forKey:kBlockedUnblockedUserIDKey];
            [userInfo setValue:status forKey:kIsBlockingKey];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kHasBlockedUnblockedUserNotification object:self userInfo:userInfo];
        }
    }
//    else if([type isEqualToString:@"forum_action"])
//    {
//        //            NSString *from = [result objectForKey:@"from"];
//        //            [ExploreForumManager trackForumFollow:(status.intValue != 0) forumID:entryID groupModel:nil enterFrom:from];
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:kForumLikeStatusChangeNotification
//                                                            object:self
//                                                          userInfo:@{kForumLikeStatusChangeForumLikeKey: ([status intValue] == 0 ? @NO : @YES),  kForumLikeStatusChangeForumIDKey: (isEmptyString(entryID)?@"":entryID)}];
//    }else if ([type isEqualToString:@"concern_action"])
//    {
//        if (entryID) {
////            //第一次关注实体词引导动画
////            if ([status boolValue]) {
////                if ([TTFirstConcernManager firstTimeGuideEnabled]){
////                    TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
////                    [manager showFirstConcernAlertViewWithDismissBlock:nil];
////                }
////            }
//            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
//                                                             actionType:status.boolValue?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
//                                                               itemType:TTFollowItemTypeDefault
//                                                               userInfo:nil];
//            NSDictionary * userInfo = @{FRNeedUpdateConcernEntityConcernIDKey:entryID,
//                                        FRNeedUpdateConcernEntityConcernStateKey:([status intValue] == 0 ? @NO : @YES)};
//            [[NSNotificationCenter defaultCenter] postNotificationName:FRNeedUpdateConcernEntityCareStateNotification object:self userInfo:userInfo];
//        }
//    }
    else if ([type isEqualToString:@"wenda_rm"]) {

    }
    else if ([type isEqualToString:@"stock_action"]){
//        if ([status boolValue]){
//            if ([TTFirstConcernManager firstTimeGuideEnabled]){
//                TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                [manager showFirstConcernAlertViewWithDismissBlock:nil];
//            }
//        }
        [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                         actionType:status.boolValue?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                           itemType:TTFollowItemTypeDefault
                                                           userInfo:nil];
    }
}

//addEventListener
RCT_EXPORT_METHOD(addEventListener) {
    //[self registerStatusRelatedNotification];
}

- (void)observe:(NSString *)name selector:(SEL)aSelector {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:name object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aSelector name:name object:nil];
}

- (void)registerStatusRelatedNotification
{
    [self observe:kEntrySubscribeStatusChangedNotification selector:@selector(subscribeStatusChangedNotification:)];
    [self observe:RelationActionSuccessNotification selector:@selector(relationActionNotification:)];
//    [self observe:kForumLikeStatusChangeNotification selector:@selector(forumLikeStatusChangedNotification:)];
//    [self observe:FRConcernEntityCareStateChangeNotification selector:@selector(concernCareStatusChangedNotification:)];
    [self observe:@"kArticleJSBrdigePGCDonateFinishedNotification" selector:@selector(pgcArticleDonateFinishedNotification:)];
    [self observe:kHasBlockedUnblockedUserNotification selector:@selector(blockUnblockUserNotification:)];
    
    [TTAccount addMulticastDelegate:self];
}

- (void)subscribeStatusChangedNotification:(NSNotification*)notification
{
    ExploreEntry *entry = [notification.userInfo objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    if (entry) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:entry.entryID forKey:@"id"];
        [param setValue:([entry.subscribed boolValue] ? @1 : @0) forKey:@"status"];
        [param setValue:@"pgc_action" forKey:@"type"];
        [self invokeJSWithEventID:@"page_state_change" parameters:param];
    }
}

- (void)relationActionNotification:(NSNotification*)notification {
    FriendActionType tType = [[notification.userInfo objectForKey:kRelationActionSuccessNotificationActionTypeKey] intValue];
    if (tType == FriendActionTypeFollow || tType == FriendActionTypeUnfollow) {
        NSString *userID = [notification.userInfo objectForKey:kRelationActionSuccessNotificationUserIDKey];
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:tType == FriendActionTypeFollow ? @1 : @0 forKey:@"status"];
        [param setValue:userID forKey:@"id"];
        [param setValue:@"user_action" forKey:@"type"];
        [self invokeJSWithEventID:@"page_state_change" parameters:param];
    }
}

//- (void)forumLikeStatusChangedNotification:(NSNotification*)notification {
//    NSString *forumID = [notification.userInfo objectForKey:kForumLikeStatusChangeForumIDKey];
//    NSNumber *liked = [notification.userInfo objectForKey:kForumLikeStatusChangeForumLikeKey];
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    [param setValue:forumID forKey:@"id"];
//    [param setValue:liked forKey:@"status"];
//    [param setValue:@"forum_action" forKey:@"type"];
//    [self invokeJSWithEventID:@"page_state_change" parameters:param];
//}
//
//- (void)concernCareStatusChangedNotification:(NSNotification *)notification {
//    NSString *concernID = [notification.userInfo objectForKey:FRConcernEntityCareStateChangeConcernIDKey];
//    NSNumber *careState = [notification.userInfo objectForKey:FRConcernEntityCareStateChangeConcernStateKey];
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    [param setValue:concernID forKey:@"id"];
//    [param setValue:careState forKey:@"status"];
//    [param setValue:@"concern_action" forKey:@"type"];
//    [self invokeJSWithEventID:@"page_state_change" parameters:param];
//}

- (void)pgcArticleDonateFinishedNotification:(NSNotification *)notification {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:notification.userInfo[@"type"] forKey:@"type"];
    [param setValue:notification.userInfo[@"id"] forKey:@"id"];
    [param setValue:notification.userInfo[@"status"] forKey:@"status"];
    [self invokeJSWithEventID:@"page_state_change" parameters:param];
}

- (void)blockUnblockUserNotification:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString * userID = [userInfo valueForKey:kBlockedUnblockedUserIDKey];
    NSNumber *isBlocking = [userInfo valueForKey:kIsBlockingKey];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:userID forKey:@"id"];
    [param setValue:isBlocking forKey:@"status"];
    [param setValue:@"block_action" forKey:@"type"];
    [self invokeJSWithEventID:@"page_state_change" parameters:param];
}


@end

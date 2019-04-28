//
//  TTToutiaoFantasyManager.m
//  Article
//
//  Created by 王霖 on 2017/12/25.
//

#import "TTToutiaoFantasyManager.h"
#import <TTFantasy.h>
#import "TTFantasyWebviewAdaptor.h"
#import <TTReachability.h>
#import <TTInstallIDManager.h>
#import <TTSandBoxHelper.h>
#import <TTDeviceHelper.h>
#import "SSFeedbackViewController.h"
#import <TTAccountManager.h>
#import <TTAccount+Multicast.h>
#import <TTNavigationController.h>
#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>
//#import <SDWebImagePrefetcher.h>
#import <UIDevice+TTAdditions.h>
#import <TTShareManager.h>
#import <TTWechatContentItem.h>
#import <TTQQZoneContentItem.h>
#import <TTQQFriendContentItem.h>
#import <TTWechatTimelineContentItem.h>
#import <WXApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "TTWeChatShare.h"
#import "TTQQShare.h"
#import "TTVVideoURLParser.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "TTFingerprintManager.h"

static NSString *kTTToutiaoFantasyManagerHProjectSettingsKey = @"kTTToutiaoFantasyManagerHProjectSettingsKey";
static NSString *kTTVideoFantasyEntryIconUrlKey = @"entry_icon_url";

static NSString *kTTVideoFantasyEntryIconPath = @"video_fantasy/entry_icon";

@interface TTToutiaoFantasyManager()
<TTFantasyServiceProtocol,
TTFShareServiceProtocol,
TTFLoginServiceProtocol,
TTFWebServiceProtocol,
TTFLogServiceProtocol,
TTAccountMulticastProtocol,
TTShareManagerDelegate>

@property (nonatomic, strong) TTShareManager *shareManager;

@end

@implementation TTToutiaoFantasyManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static TTToutiaoFantasyManager * sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self cleanNoUseEntryIconImage];
        NSString *channelName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"];
        if ([channelName isEqualToString:@"_test"] || [channelName isEqualToString:@"local_test"]) {
            [TTFantasy ttf_enableDebugLog];
        }
    }
    return self;
}

- (void)cleanNoUseEntryIconImage {
    NSDictionary *hpSettings = [[NSUserDefaults standardUserDefaults] objectForKey:kTTToutiaoFantasyManagerHProjectSettingsKey];
    if (!hpSettings || ![hpSettings isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *iconUrlStr = [hpSettings tt_stringValueForKey:kTTVideoFantasyEntryIconUrlKey];
    if (![iconUrlStr isKindOfClass:[NSString class]]) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:[kTTVideoFantasyEntryIconPath stringCachePath]];
    for (NSString *fileName in enumerator) {
        if (![fileName isEqualToString:[iconUrlStr MD5HashString]]) {
            // url发生变化，移除图片
            [fileManager removeItemAtPath:[[kTTVideoFantasyEntryIconPath stringCachePath] stringByAppendingPathComponent:fileName]
                                    error:nil];
        }
    }
}

- (void)downloadEntryIconImageIfNeedWithIconURL:(NSString *)iconURL {
    if (isEmptyString(iconURL)) {
        return;
    }
    
    NSString *iconDirectoryPath = [kTTVideoFantasyEntryIconPath stringCachePath];
    NSString *iconPath = [iconDirectoryPath stringByAppendingPathComponent:[iconURL MD5HashString]];
    [[NSFileManager defaultManager] removeItemAtPath:iconPath error:nil];
    [[SDWebImageAdapter sharedAdapter] prefetchURLs:@[iconURL]
                                                      progress:nil
                                                     completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
                                                         UIImage * icon = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:iconURL];
                                                         if (icon) {
                                                             dispatch_async(dispatch_queue_create("com.bytedance.saveentryicon", DISPATCH_QUEUE_SERIAL), ^{
                                                                 //保存图片到沙盒中
                                                                 NSFileManager * fileManager = [NSFileManager defaultManager];
                                                                 BOOL isDirectory = NO;
                                                                 BOOL isExists = [fileManager fileExistsAtPath:iconDirectoryPath
                                                                                                   isDirectory:&isDirectory];
                                                                 BOOL needCreateIconDirectory = NO;
                                                                 if (isExists) {
                                                                     //icon目录存在
                                                                     if (!isDirectory) {
                                                                         //非目录，删除之
                                                                         [fileManager removeItemAtPath:iconDirectoryPath
                                                                                                 error:nil];
                                                                         needCreateIconDirectory = YES;
                                                                     }
                                                                 }else {
                                                                     //icon目录不存在
                                                                     needCreateIconDirectory = YES;
                                                                 }
                                                                 if (needCreateIconDirectory) {
                                                                     [fileManager createDirectoryAtPath:iconDirectoryPath
                                                                            withIntermediateDirectories:YES
                                                                                             attributes:nil
                                                                                                  error:nil];
                                                                 }
                                                                 [UIImagePNGRepresentation(icon) writeToFile:iconPath
                                                                                                  atomically:YES];
                                                             });
                                                         }
                                                     }];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType
                      platform:(NSString * _Nullable)platformName {
    [TTFantasy ttf_accountStatusChange];
}

#pragma mark - Public

- (void)fantasyConfig {
    [TTFantasy ttf_configureServiceWithDelegate:self];
    [TTFantasy ttf_configureShareServiceDelegation:self];
    [TTFantasy ttf_configureLoginServiceDelegation:self];
    [TTFantasy ttf_configureWebServiceDelegation:self];
    [TTFantasy ttf_configureLogServiceDelegation:self];
    [TTAccount addMulticastDelegate:self];
}

- (void)updateHProjectSettings:(NSDictionary *)settings {
    if (!settings
        || ![settings isKindOfClass:[NSDictionary class]]
        || 0 == settings.count) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:settings
                                              forKey:kTTToutiaoFantasyManagerHProjectSettingsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // 触发图片更新
    [self entryIconImage];
}

- (UIImage *)entryIconImage {
    NSDictionary *hpSettings = [[NSUserDefaults standardUserDefaults] objectForKey:kTTToutiaoFantasyManagerHProjectSettingsKey];
    if (!hpSettings || ![hpSettings isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *iconUrlStr = [hpSettings tt_stringValueForKey:kTTVideoFantasyEntryIconUrlKey];
    if (isEmptyString(iconUrlStr)) {
        return nil;
    }
    UIImage *iconImage = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:iconUrlStr];
    if (iconImage) {
        return iconImage;
    }
    NSData *iconData = [[NSFileManager defaultManager] contentsAtPath:[[kTTVideoFantasyEntryIconUrlKey stringCachePath] stringByAppendingPathComponent:[iconUrlStr MD5HashString]]];
    if (iconData) {
        iconImage = [UIImage imageWithData:iconData];
    }
    if (!iconImage) {
        [[NSFileManager defaultManager] removeItemAtPath:[[kTTVideoFantasyEntryIconUrlKey stringCachePath] stringByAppendingPathComponent:[iconUrlStr MD5HashString]]
                                                   error:nil];
        [self downloadEntryIconImageIfNeedWithIconURL:iconUrlStr];
    }
    return iconImage;
}

#pragma mark - TTFantasyServiceProtocol

- (nullable NSString *)getSessionID {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://.snssdk.com"]];
    
    if ([cookies count] > 0) {
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.name isEqualToString:@"sessionid"]) {
                return cookie.value;
            }
        }
    }
    
    cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://.toutiao.com"]];
    if ([cookies count] > 0) {
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.name isEqualToString:@"sessionid"]) {
                return cookie.value;
            }
        }
    }
    return nil;
}

- (nullable NSString *)getDeviceID {
    return [[TTInstallIDManager sharedInstance] deviceID];
}

- (nullable NSString *)getAppID {
    return [[TTInstallIDManager sharedInstance] appID];
}

- (nullable NSString *)getInstallID {
    return [[TTInstallIDManager sharedInstance] installID];
}

- (NSString *)getChannel {
    return [[TTInstallIDManager sharedInstance] channel];
}

- (NSString *)getAppName {
    return [TTSandBoxHelper appName];
}

- (NSString *)getVersionName {
    return [TTSandBoxHelper versionName];
}

- (NSString *)getVersionCode {
    return [TTSandBoxHelper buildVerion];
}

- (NSString *)getDeviceType {
    return [[UIDevice currentDevice] platformString];
}

- (NSString *)getOpenUDID {
    return [TTDeviceHelper openUDID];
}

- (NSString *)getUserID {
    return [TTAccountManager userID];
}

- (NSString *)getUserName {
    return [TTAccountManager userName];
}

- (NSString *)getUserAvatarURL {
    return [TTAccountManager avatarURLString];
}

- (BOOL)isLogin {
    return [TTAccountManager isLogin];
}

- (TTFReachabilityStatus)getNetworkReachabilityStatus {
    if (TTNetworkWifiConnected()) {
        return TTFReachabilityStatusReachableViaWiFi;
    }
    if (TTNetwork2GConnected()) {
        return TTFReachabilityStatusReachableVia2G;
    }
    if (TTNetwork3GConnected()) {
        return TTFReachabilityStatusReachableVia3G;
    }
    if (TTNetwork4GConnected()) {
        return TTFReachabilityStatusReachableVia4G;
    }
    if (!TTNetworkConnected()) {
        return TTFReachabilityStatusNotReachable;
    }
    return TTFReachabilityStatusUnknown;
}

- (NSString *)getReachabilityDidChangeNotificationName {
    return kReachabilityChangedNotification;
}

- (void)openFeedbackFromViewController:(UIViewController *)viewController {
    SSFeedbackViewController *vc = [[SSFeedbackViewController alloc] init];
    TTNavigationController *nv = [[TTNavigationController alloc] initWithRootViewController:vc];
    [viewController presentViewController:nv animated:YES completion:nil];
}

- (void)setImageForTargetImageView:(UIImageView *)targetImageView
                               URL:(NSURL *)url
                  placeholderImage:(UIImage *)placeholder
                         completed:(void (^)(UIImage * _Nonnull, NSError * _Nonnull, NSURL * _Nonnull))completedBlock {
    [targetImageView sda_setImageWithURL:url
                       placeholderImage:placeholder
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  (!completedBlock) ?: completedBlock(image, error, imageURL);
                              }];
    ;
}

- (void)setImageForTargetButton:(UIButton *)targetButton
                            URL:(NSURL *)url
                          state:(UIControlState)state
               placeholderImage:(UIImage *)placeholder
                      completed:(void (^)(UIImage * _Nonnull, NSError * _Nonnull, NSURL * _Nonnull))completedBlock {
    [targetButton sda_setImageWithURL:url
                            forState:state
                    placeholderImage:placeholder
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                               (!completedBlock) ?: completedBlock(image, error, imageURL);
                           }];
}

#pragma mark - TTFShareServiceProtocol
- (void)shareToDest:(TTFShareDest)dst
          withTitle:(NSString *)title
        description:(NSString *)dsc
              image:(UIImage *)image
                URL:(NSString *)URL
         completion:(void (^)(BOOL, NSDictionary * _Nonnull))completion {
    self.shareManager = [[TTShareManager alloc] init];
    self.shareManager.delegate = self;
    id <TTActivityContentItemShareProtocol> shareContent;
    if (dst == TTFShareDestMoment) {
        shareContent = [[TTWechatTimelineContentItem alloc] initWithTitle:title
                                                                     desc:dsc
                                                               webPageUrl:URL
                                                               thumbImage:image
                                                                shareType:TTShareWebPage];
    } else if (dst == TTFShareDestWechat) {
        shareContent = [[TTWechatContentItem alloc] initWithTitle:title
                                                             desc:dsc
                                                       webPageUrl:URL
                                                       thumbImage:image
                                                        shareType:TTShareWebPage];
    } else if (dst == TTFShareDestQQ) {
        shareContent = [[TTQQFriendContentItem alloc] initWithTitle:title
                                                               desc:dsc
                                                         webPageUrl:URL
                                                         thumbImage:image
                                                           imageUrl:nil
                                                           shareTye:TTShareWebPage];
    } else if (dst == TTFShareDestQzone) {
        shareContent = [[TTQQZoneContentItem alloc] initWithTitle:title
                                                             desc:dsc
                                                       webPageUrl:URL
                                                       thumbImage:image
                                                         imageUrl:nil
                                                         shareTye:TTShareWebPage];
    }
    
    if (shareContent) {
        [self.shareManager shareToActivity:shareContent
                  presentingViewController:nil];
    }
}

- (void)shareSingleImageToDest:(TTFShareDest)dst withImage:(UIImage *)image completion:(void (^)(BOOL, NSDictionary * _Nonnull))completion {
    self.shareManager = [[TTShareManager alloc] init];
    self.shareManager.delegate = self;
    id <TTActivityContentItemShareProtocol> shareContent;
    if (dst == TTFShareDestMoment) {
        shareContent = [[TTWechatTimelineContentItem alloc] init];
        [(TTWechatTimelineContentItem *)shareContent setShareType:TTShareImage];
        [(TTWechatTimelineContentItem *)shareContent setImage:image];
    } else if (dst == TTFShareDestWechat) {
        shareContent = [[TTWechatContentItem alloc] init];
        [(TTWechatContentItem *)shareContent setShareType:TTShareImage];
        [(TTWechatContentItem *)shareContent setImage:image];
    } else if (dst == TTFShareDestQQ || dst == TTFShareDestQzone) {
        shareContent = [[TTQQFriendContentItem alloc] init];
        [(TTQQFriendContentItem *)shareContent setShareType:TTShareImage];
        [(TTQQFriendContentItem *)shareContent setImage:image];
    }
    if (shareContent) {
        [self.shareManager shareToActivity:shareContent
                  presentingViewController:nil];
    }
}

- (BOOL)ttf_canOpenThirdPartApp:(TTFShareDest)dst {
    // in order to trigger [WXApi registerApp:]
    __unused BOOL x = [[TTWeChatShare sharedWeChatShare] isAvailable];
    __unused BOOL y = [[TTQQShare sharedQQShare] isAvailable];
    BOOL canOpen = NO;
    if (dst == TTFShareDestMoment || dst == TTFShareDestWechat) {
        if (![WXApi isWXAppInstalled]) {
            NSString *errMsg = NSLocalizedString(@"您未安装微信", nil);
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:errMsg indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        } else if (![WXApi isWXAppSupportApi]) {
            NSString *errMsg = NSLocalizedString(@"您的微信版本过低，无法支持分享", nil);
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:errMsg indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        } else {
            canOpen = YES;
        }
    } else if (dst == TTFShareDestQQ || dst == TTFShareDestQzone) {
        if (![QQApiInterface isQQInstalled]) {
            NSString *errMsg = NSLocalizedString(@"您未安装QQ", nil);
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:errMsg indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        } else if (![QQApiInterface isQQSupportApi]) {
            NSString *errMsg = NSLocalizedString(@"您的QQ版本过低，无法支持分享", nil);
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:errMsg indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        } else {
            canOpen = YES;
        }
    }
    return canOpen;
}

- (void)shareTeamBattlePhraseToDest:(TTFShareDest)dst withTeamBattlePhrase:(NSString *)teamBattlePhrase completion:(void (^)())completion {
    if (dst == TTFShareDestMoment || dst == TTFShareDestWechat) {
        [WXApi openWXApp];
    } else if (dst == TTFShareDestQQ || dst == TTFShareDestQzone) {
        [QQApiInterface openQQ];
    }
    [[UIPasteboard generalPasteboard] setString:teamBattlePhrase];
    completion ? completion() : nil;
}

- (NSString *)urlWithVideoId:(NSString *)videoId
{
    return [TTVVideoURLParser urlWithVideoID:videoId categoryID:nil itemId:nil adID:nil sp:TTVPlayerSPToutiao base:nil];
}

- (NSString *)getRequestFingerPrint {
    return [TTFingerprintManager sharedInstance].fingerprint;
}

#pragma mark - TTFLoginServiceProtocol

- (void)loginFromViewController:(UIViewController *)vc completion:(void (^)(TTFLoginState))compeltion {
    [self loginFromViewController:vc trackerDic:nil completion:compeltion];
}

- (void)loginFromViewController:(nullable UIViewController *)vc
                     trackerDic:(nullable NSDictionary *)trackerDic
                     completion:(nullable void(^)(TTFLoginState state))compeltion {
    if (!vc) {
        return;
    }
    UIView *superView = vc.navigationController.view;
    if (!superView) {
        superView = vc.view;
    }
    if (![TTAccountManager isLogin]) {
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault
                                          source:nil
                                     inSuperView:superView
                                      completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
                                          if (type == TTAccountAlertCompletionEventTypeDone) {
                                              // 登录成功
                                              if (compeltion) {
                                                  compeltion(TTFLoginStateLoginSuccess);
                                              }
                                          } else if (type == TTAccountAlertCompletionEventTypeTip){
                                              [TTAccountManager presentQuickLoginFromVC:vc
                                                                                   type:TTAccountLoginDialogTitleTypeDefault
                                                                                 source:nil
                                                                             completion:^(TTAccountLoginState state) {
                                                                                 if (compeltion) {
                                                                                     switch (state) {
                                                                                         case TTAccountLoginStateNotLogin:
                                                                                             compeltion(TTFLoginStateNotLogin);
                                                                                             break;
                                                                                         case TTAccountLoginStateLogin:
                                                                                             compeltion(TTFLoginStateLoginSuccess);
                                                                                             break;
                                                                                         case TTAccountLoginStateCancelled:
                                                                                             compeltion(TTFLoginStateCanceled);
                                                                                             break;
                                                                                         default:
                                                                                             break;
                                                                                     }
                                                                                 }
                                                                             }];
                                          }
                                      }];
    }else {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
        params[@"category_name"] = @"";
        params[@"group_id"] = @"";
        params[@"position"] = @"fantasy",
        params[@"section"] = @"list_more";
        params[@"cache_status"] = @"available";
        [TTTrackerWrapper eventV3:@"click_video_cache" params:[params copy]];
    }
}

#pragma mark - TTFWebServiceProtocol

- (id<TTFWebViewProtocol>)getWebViewInstance {
    return [[TTFantasyWebviewAdaptor alloc] init];
}

#pragma mark - TTFLogServiceProtocol

- (void)didReceivedHeartbeatEvents:(NSArray<NSDictionary *> *)events withEventName:(NSString *)eventName {
    if (events.count == 0) {
        return;
    }
    if ([TTFantasy ttf_isFantasyEnabled]) {
        [TTTrackerWrapper eventV3:eventName params:@{@"fantasy": events}];
    }
}

- (void)didReceivedTraceEvents:(NSArray<NSDictionary *> *)events withEventName:(NSString *)eventName {
    if (events.count == 0) {
        return;
    }
    if ([TTFantasy ttf_isFantasyEnabled]) {
        [TTTrackerWrapper eventV3:eventName params:@{@"fantasy": events}];
    }
}

@end

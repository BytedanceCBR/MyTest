//
//  TTSFShareManager.m
//  Article
//
//  Created by 冯靖君 on 2017/11/26.
//  SF分享管理

#import "TTSFShareManager.h"
#import <TTUIWidget/TTIndicatorView.h>
#import "TTRepostViewController.h"
#import "TTSFNetworkManager.h"
#import "TTSFRedpacketManager.h"
#import <TTInstallIDManager.h>
#import "TTSFTokenShareTipView.h"
#import "NewsBaseDelegate.h"
#import "TTSFResourcesManager.h"
#import <TTSettingsManager.h>
#import <TTKeyboardListener.h>
#import <TTVBasePlayVideo.h>
#import "TTVPlayVideo.h"

//@interface TTSFSharePassword ()
//
//@property (nonatomic, copy) NSString *plainText;
//@property (nonatomic, copy) NSString *encryptText;
//
//@end
//
//@implementation TTSFSharePassword
//
//- (instancetype)initWithPlainText:(NSString *)plainText encryptText:(NSString *)encryptText
//{
//    if (self = [super init]) {
//        _plainText = plainText;
//        _encryptText = encryptText;
//    }
//    return self;
//}
//
//@end

@interface TTSFShareManager ()

@property (nonatomic, assign) TTSFSharePlatform sharePlatform;
@property (nonatomic, strong) NSDictionary *extra;
@property (nonatomic, copy) TTSFShareCompletionBlock completion;
@property (nonatomic, copy) TTSFNewbeeRedPackageCheckBlock newbeeRPCheckBlock;
@property (nonatomic, copy) TTSFShareManagerDelayHandleBlock delayHandleBlock;

// 端内复制的剪贴板内容。如果下次app回前台时内容一致，则不做处理，同时清掉
@property (nonatomic, copy) NSString *inAppPastboardContent;

@end

@implementation TTSFShareManager

static TTSFShareManager *_instance = nil;

+ (void)load
{
    // 确保初始化
    [TTSFShareManager sharedManager];
    
    //业务相关性小，通用处理的route action在此处注册,直接执行动作
//    [TTRoute registerAction:^(NSDictionary *params) {
//        // 如各类弹窗
//    } withIdentifier:@"toast"];

}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[TTSFShareManager alloc] init];
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResourceReadyForUse) name:TTSFResourcesReadyForUseNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAppAlertSuccessNotification:) name:@"kAppAlertSuccessNotification" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onAppBecomeActive:(NSNotification *)notification
{
    NSString *command = [[UIPasteboard generalPasteboard] string];
    
    [TTSFShareManager sharedManager].delayHandleBlock = ^(NSDictionary *context) {
        // 加个延迟，优先让回流响应。同时不在启动阶段增加网络请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([command isEqualToString:[TTSFShareManager sharedManager].inAppPastboardContent]) {
                // 剪贴板内容是app复制的，不处理，并清除
                [self.class clearPastboardIfNeed];
            } else {
                BOOL isVideoFullScreen = [TTVBasePlayVideo currentPlayingPlayVideo].player.context.isFullScreen || [TTVPlayVideo currentPlayingPlayVideo].player.context.isFullScreen;
                // 视频不在全屏状态，才处理剪贴板口令。否则不处理，也不清除，下次来前台时处理
                if ([SSCommonLogic ttsfActivityAvailable] && !isVideoFullScreen) {
                    [self.class handlePastboardShareActionWithToken:command];
                }
            }
        });
        
        return YES;
    };
    
    if ([TTSFResourcesManager isReadyForUse]) {
        [self onResourceReadyForUse];
    } else {
        // 等资源下载完成的通知
    }
}

- (BOOL)onResourceReadyForUse
{
    if (self.delayHandleBlock) {
        return self.delayHandleBlock(nil);
    } else {
        return NO;
    }
}

#pragma mark - public

+ (NSString *)checkAvailableOnPlatform:(TTSFSharePlatform)platform
{
    if (platform == TTSFSharePlatformWeChat ||
        platform == TTSFSharePlatformWeChatTimeLine) {
        if (![WXApi isWXAppInstalled]) {
            return NSLocalizedString(@"您未安装微信", nil);
        } else if (![WXApi isWXAppSupportApi]) {
            return NSLocalizedString(@"您的微信版本过低，无法支持分享", nil);
        } else {
            return nil;
        }
    } else if (platform == TTSFSharePlatformQQ) {
        if (![QQApiInterface isQQInstalled]) {
            return NSLocalizedString(@"您未安装QQ", nil);
        } else if (![QQApiInterface isQQSupportApi]) {
            return NSLocalizedString(@"您的QQ版本过低，无法支持分享", nil);
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (void)shareToPlatform:(TTSFSharePlatform)platform
            contentType:(TTSFShareContentType)contentType
                   text:(NSString *)text
                  title:(NSString *)title
            description:(NSString *)description
             webPageURL:(NSString *)webPageURLString
                  ttURL:(NSString *)weitoutiaoURL
             thumbImage:(UIImage *)thumbImage
          thumbImageURL:(NSString *)thumbImageURL
                  image:(UIImage *)image
               videoURL:(NSString *)videoURLString
                  extra:(NSDictionary *)extra
        completionBlock:(TTSFShareCompletionBlock)completion
{
    self.sharePlatform = platform;
    self.completion = completion;
    TTWeChatShare *wxShare = [TTWeChatShare sharedWeChatShare];
    wxShare.delegate = self;
//    wxShare.requestDelegate = self;
    TTQQShare *qqShare = [TTQQShare sharedQQShare];
    qqShare.delegate = self;
//    qqShare.requestDelegate = self;
    
    //微头条
    void (^shareToUGCBlock)() = ^() {
        NSMutableDictionary *repostInfo = [NSMutableDictionary dictionary];
        [repostInfo setValue:weitoutiaoURL forKey:@"schema"];
//        [repostInfo setValue:webPageURLString forKey:@"schema"];
        [repostInfo setValue:thumbImageURL forKey:@"cover_url"];
        [repostInfo setValue:@(TTThreadRepostTypeLink) forKey:@"repost_type"];
        [repostInfo setValue:@(NO) forKey:@"is_video"];
        [repostInfo setValue:title forKey:@"title"];
//        [repostInfo setValue:[NSString stringWithFormat:@"%@: %@", title, description] forKey:@"title"];
//        [dict setValue:thumbImageURL forKey:@"cover_url"];
        NSURL *openURL = [NSURL URLWithString:@"sslocal://repost_page"];
        // TTModalContainerViewController dismiss动画有个时间，做一个延时
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
                [[TTRoute sharedRoute] openURLByPresentViewController:openURL userInfo:TTRouteUserInfoWithDict(repostInfo)];
            }
            
            if (self.completion) {
                self.completion(nil, nil);
            }
        });
    };
    
    void (^showTokenTipBlock)(NSDictionary *) = ^(NSDictionary *userInfo) {
        TTInterfaceTipHProjectBaseModel *model = [[TTInterfaceTipHProjectBaseModel alloc] init];
        model.interfaceTipViewIdentifier = @"TTSFTokenShareTipView";
        model.gameTaskCompletion = ^(BOOL go, NSDictionary *userInfo) {
            if (platform == TTSFSharePlatformOthers) {
                if (go) {
                    NSInteger jumpToPlatform = [extra tt_integerValueForKey:@"jump_to"];
                    if (jumpToPlatform == 1) {
                        if ([[TTWeChatShare sharedWeChatShare] isAvailable]) {
                            [WXApi openWXApp];
                        } else {
                            showIndicatorWithTip(@"您未安装微信");
                        }
                    } else if (jumpToPlatform == 2) {
                        if ([[TTQQShare sharedQQShare] isAvailable]) {
                            [QQApiInterface openQQ];
                        } else {
                            showIndicatorWithTip(@"您未安装QQ");
                        }
                    }
                }
            } else {
                if (go) {
                    // 跳转
                    if (platform == TTSFSharePlatformWeChat || platform == TTSFSharePlatformWeChatTimeLine) {
                        if ([[TTWeChatShare sharedWeChatShare] isAvailable]) {
                            [WXApi openWXApp];
                        } else {
                            showIndicatorWithTip(@"您未安装微信");
                        }
                    } else if (platform == TTSFSharePlatformQQ) {
                        if ([[TTQQShare sharedQQShare] isAvailable]) {
                            [QQApiInterface openQQ];
                        } else {
                            showIndicatorWithTip(@"您未安装QQ");
                        }
                    }
                }
            }
        };
        model.nonTask = YES;
        model.customInfo = [userInfo copy];
        
        [TTInterfaceTipManager appendNonDirectorTipWithModel:model];
        
        [[UIPasteboard generalPasteboard] setString:text];
        [TTSFShareManager sharedManager].inAppPastboardContent = text;
    };
    
    switch (contentType) {
        case TTSFShareContentTypeText: {
            if (SSIsEmptyDictionary(extra)) {
                if (platform == TTSFSharePlatformWeChat || platform == TTSFSharePlatformWeChatTimeLine) {
                    showTokenTipBlock(({
                        NSMutableDictionary *params = [NSMutableDictionary dictionary];
                        [params setValue:@"去微信粘贴" forKey:@"vendor"];
                        [params setValue:text forKey:@"token"];
                        [params copy];
                    }));
                } else if (platform == TTSFSharePlatformQQ) {
                    showTokenTipBlock(({
                        NSMutableDictionary *params = [NSMutableDictionary dictionary];
                        [params setValue:@"去QQ粘贴" forKey:@"vendor"];
                        [params setValue:text forKey:@"token"];
                        [params copy];
                    }));
                } else {
                    // 微头条作为webURL处理
                    shareToUGCBlock();
                }
            } else {
                // token分享可配
                showTokenTipBlock(({
                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    [params setValue:[extra tt_stringValueForKey:@"command_btn_title"] forKey:@"vendor"];
                    [params setValue:[extra tt_stringValueForKey:@"command_title"] forKey:@"command_title"];
                    [params setValue:text forKey:@"token"];
                    [params setValue:[extra objectForKey:@"disable_click"] forKey:@"disable_click"];
                    [params setValue:[extra objectForKey:@"disable_jump"] forKey:@"disable_jump"];
                    [params setValue:[extra objectForKey:@"jump_to"] forKey:@"jump_to"];
                    [params copy];
                }));
            }
        }
            break;
        case TTSFShareContentTypeWebPage: {
            if (platform == TTSFSharePlatformWeChat || platform == TTSFSharePlatformWeChatTimeLine) {
                [wxShare sendWebpageToScene:[self wxsceneWithPlatform:platform] withWebpageURL:webPageURLString thumbnailImage:thumbImage title:title description:description customCallbackUserInfo:extra];
            } else if (platform == TTSFSharePlatformQQ) {
                [qqShare sendNewsWithURL:webPageURLString thumbnailImage:thumbImage thumbnailImageURL:thumbImageURL title:title description:description customCallbackUserInfo:extra];
            } else {
                // 微头条
                shareToUGCBlock();
            }
        }
            break;
        case TTSFShareContentTypeImage: {
            if (platform == TTSFSharePlatformWeChat || platform == TTSFSharePlatformWeChatTimeLine) {
                [wxShare sendImageToScene:[self wxsceneWithPlatform:platform] withImage:image customCallbackUserInfo:extra];
            } else if (platform == TTSFSharePlatformQQ) {
                [qqShare sendImage:image withTitle:title description:description customCallbackUserInfo:extra];
            } else {
                
            }
        }
            break;
        case TTSFShareContentTypeVideo: {
            if (platform == TTSFSharePlatformWeChat || platform == TTSFSharePlatformWeChatTimeLine) {
                [wxShare sendVideoToScene:[self wxsceneWithPlatform:platform] withVideoURL:videoURLString thumbnailImage:thumbImage title:title description:description customCallbackUserInfo:extra];
            } else if (platform == TTSFSharePlatformWeitoutiao) {
                //微头条视频分享
            } else {
                // do nothing
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - private

- (enum WXScene)wxsceneWithPlatform:(TTSFSharePlatform)platform
{
    if (platform == TTSFSharePlatformWeChat) {
        return WXSceneSession;
    } else if (platform == TTSFSharePlatformWeChatTimeLine) {
        return WXSceneTimeline;
    } else {
        return -1;
    }
}

- (void)commonHandleWithError:(NSError *)error
{
    // 弹分享结果toast
    NSString *shareResultTip = [self shareResultTipWithError:error];
    if (!isEmptyString(shareResultTip)) {
        TTIndicatorView *indicateView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:shareResultTip indicatorImage:[self shareResultImageWithError:error] dismissHandler:nil];
        indicateView.autoDismiss = YES;
        [indicateView showFromParentView:[UIApplication sharedApplication].delegate.window];
    }
}

- (NSString *)shareResultTipWithError:(NSError *)error
{
    NSString *shareResultTip = nil;
    if (self.sharePlatform == TTSFSharePlatformQQ) {
        if (error) {
            switch (error.code) {
                case kTTQQShareErrorTypeNotInstalled:
                    shareResultTip = NSLocalizedString(@"您未安装QQ", nil);
                    break;
                case kTTQQShareErrorTypeNotSupportAPI:
                    shareResultTip = NSLocalizedString(@"您的QQ版本过低，无法支持分享", nil);
                    break;
                default:
//                    shareResultTip = NSLocalizedString(@"分享失败", nil);
                    shareResultTip = nil;
                    break;
            }
        } else {
            shareResultTip = NSLocalizedString(@"QQ分享成功", nil);
        }
    } else if (self.sharePlatform == TTSFSharePlatformWeitoutiao) {
        // 微头条错误处理
        
    } else {
        if(error) {
            switch (error.code) {
                case kTTWeChatShareErrorTypeNotInstalled:
                    shareResultTip = NSLocalizedString(@"您未安装微信", nil);
                    break;
                case kTTWeChatShareErrorTypeNotSupportAPI:
                    shareResultTip = NSLocalizedString(@"您的微信版本过低，无法支持分享", nil);
                    break;
                case kTTWeChatShareErrorTypeExceedMaxImageSize:
                    shareResultTip = NSLocalizedString(@"图片过大，分享图片不能超过10M", nil);
                    break;
                default:
//                    shareResultTip = NSLocalizedString(@"分享失败", nil);
                    shareResultTip = nil;
                    break;
            }
        } else {
            shareResultTip = NSLocalizedString(@"分享成功", nil);
        }
    }
    return shareResultTip;
}

- (UIImage *)shareResultImageWithError:(NSError *)error
{
    return [UIImage themedImageNamed:error ? @"close_popup_textpage.png" : @"doneicon_popup_textpage.png"];
}

/**
 *  处理剪贴板命令
 */
+ (void)handlePastboardShareActionWithToken:(NSString *)command
{
    if (!isEmptyString(command) && [self shouldHandlePastboardWithString:command]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:command forKey:@"command"];
        [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:[self.class commandTranslatePath] params:[params copy] method:@"GET" callback:^(NSError *error, id jsonObj) {
            if (!error && jsonObj && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
                TTSFResponseModel *responseModel = (TTSFResponseModel *)jsonObj;
                NSString *scheme = [responseModel.dataDict stringValueForKey:@"schema_url" defaultValue:nil];
                if (!isEmptyString(scheme)) {
                    NSURL *actionURL = [TTStringHelper URLWithURLString:scheme];
                    if ([[TTRoute sharedRoute] canOpenURL:actionURL]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // 处理剪贴板时如果键盘处于弹出状态，先resign。主线程异步调用
                            if ([[TTKeyboardListener sharedInstance] isVisible]) {
                                [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
                            }
                        });
                        BOOL opened = [[TTRoute sharedRoute] openURLByPushViewController:actionURL userInfo:nil];
                        
                        // 检测是否要申请新人红包（春节）
                        if (opened && ![self checkWXNewbeeRedpacketURL:actionURL]) {
                            [self applyNewbeeRedpacketWithType:TTSFNewbeeRedPacketTypeSF];
                        }
                    }
                } else {
                    LOGD(@"command invalid, error num : %d,  msg : %@", responseModel.serviceErrNum, responseModel.serviceErrDesc);
                }
                
                //识别后清空剪贴板
                [self clearPastboardIfNeed];
                
            } else {
                LOGD(@"translate api return error : %@", error.localizedDescription);
            }
        }];
    } else {
        // 剪贴板为空，通过判断渠道确认是否需要领取新人红包（微信）
        BOOL hasApply = NO;
        if ([[TTSFShareManager sharedManager] isSpecificVendor]) {
            hasApply = YES;
            [TTSFShareManager applyNewbeeRedpacketWithType:TTSFNewbeeRedPacketTypeWX];
        }
        
        // 记录到block，等app_alert成功回调后再次尝试调用
        [TTSFShareManager sharedManager].newbeeRPCheckBlock = ^() {
            if (!hasApply) {
                [TTSFShareManager applyNewbeeRedpacketWithType:TTSFNewbeeRedPacketTypeWX];
            }
        };
    }
}

// 剪贴板内容是否符合活动格式
+ (BOOL)shouldHandlePastboardWithString:(NSString *)pastBoardString
{
//    NSString *tokenRegex = @"^.*##.{16}##.*$";
    NSString *tokenRegex = @"^.*##.{1,100}##.*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", tokenRegex];
    return [predicate evaluateWithObject:pastBoardString];
}

+ (void)clearPastboardIfNeed
{
    NSString *command = [[UIPasteboard generalPasteboard] string];
    if (!isEmptyString(command) && [self shouldHandlePastboardWithString:command]) {
        [[UIPasteboard generalPasteboard] setString:@""];
        [TTSFShareManager sharedManager].inAppPastboardContent = nil;
    }
}

+ (void)applyNewbeeRedpacketWithType:(TTSFNewbeeRedPacketType)type
{
    if (![[TTSFRedpacketManager sharedManager] hasShownNewBeeRedPacket]) {
        [[TTSFRedpacketManager sharedManager] applyNewbeeRedPacketWithType:type invitorUserID:nil];
    }
}

+ (NSString *)commandTranslatePath
{
    return @"/command/translate/";
}

+ (BOOL)checkWXNewbeeRedpacketURL:(NSURL *)url
{
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
    if ([[paramObj.allParams tt_stringValueForKey:@"action"] isEqualToString:@"newbee_rp"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)checkSpecificNewbeeRedPacketVendorPath
{
    return @"/source_valid/";
}

/**
 *  app_alert接口成功回调
 */
- (void)receiveAppAlertSuccessNotification:(NSNotification *)notification
{
    // 如果春节活动配置未下发，就直接返回
    if (![SSCommonLogic ttsfActivityAvailable]) {
        return;
    }
    
    // 已申请过新人红包则不再请求
    if ([[TTSFRedpacketManager sharedManager] hasShownNewBeeRedPacket]) {
        return;
    }
    
    [[TTInstallIDManager sharedInstance] setDidRegisterBlock:^(NSString *deviceID, NSString *installID) {
        NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
        [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:[self.class checkSpecificNewbeeRedPacketVendorPath] params:requestParams method:@"GET" callback:^(NSError *error, id jsonObj) {
            if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
                TTSFResponseModel *response = (TTSFResponseModel *)jsonObj;
                if (response.serviceErrNum == 0) {
                    BOOL isSpecificVendor = [response.dataDict tt_boolValueForKey:@"is_valid"];
                    [[TTSFShareManager sharedManager] setIsSpecificVendor:isSpecificVendor];
                    
                    if (isSpecificVendor && self.newbeeRPCheckBlock) {
                        self.newbeeRPCheckBlock();
                        self.newbeeRPCheckBlock = nil;
                    }
                }
            }
        }];
    }];
}


static NSString *const kSpecificNewbeeRedpacketVendorKey = @"kSpecificNewbeeRedpacketVendorKey";
- (BOOL)isSpecificVendor
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSpecificNewbeeRedpacketVendorKey];
}

- (void)setIsSpecificVendor:(BOOL)isSpecificVendor
{
    [[NSUserDefaults standardUserDefaults] setBool:isSpecificVendor forKey:kSpecificNewbeeRedpacketVendorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSMutableArray *)shareActionWhiteList
{
    // 路由表项是entryName-classString格式
    static NSMutableArray <NSString*> *_shareActionWhiteList;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareActionWhiteList = [NSMutableArray array];
    });
    return _shareActionWhiteList;
}

+ (void)addToShareWhiteListWithAction:(NSString *)actionIdentifier
{
    if (!isEmptyString(actionIdentifier)) {
        [self.shareActionWhiteList addObject:actionIdentifier];
    }
}

+ (BOOL)canHandleAction:(NSString *)actionIdentifier
{
    if (isEmptyString(actionIdentifier)) {
        return NO;
    } else {
        return [self.shareActionWhiteList containsObject:actionIdentifier];
    }
}

#pragma mark - share platform delegate methods

- (void)weChatShare:(TTWeChatShare *)weChatShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo
{
    // 收到微信分享结果
    if (self.completion) {
        self.completion(customCallbackUserInfo, error);
    }
    [self commonHandleWithError:error];
}

//- (void)weChatShare:(TTWeChatShare *)weChatShare receiveRequest:(BaseReq *)request
//{
//    // 收到微信分享请求
//}

- (void)qqShare:(TTQQShare *)qqShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo
{
    // 收到qq分享结果
    if (self.completion) {
        self.completion(customCallbackUserInfo, error);
    }
    [self commonHandleWithError:error];
}

//- (void)qqShare:(TTQQShare *)qqShare receiveRequest:(QQBaseReq *)request
//{
//    // 收到qq分享请求
//}

@end

@implementation TTSFShareManager (OpenURLRouteAction)

+ (void)registerOpenURLAction:(TTSFShareRouteAction)action
               withIdentifier:(NSString *)routeActionIdentifier
{
    // 业务相关性强，回调给业务方处理的route action在此注册
    if (!isEmptyString(routeActionIdentifier)) {
        [TTRoute registerAction:^(NSDictionary *params) {
            // 如收牌
            if (action) {
                action(params);
            }
        } withIdentifier:routeActionIdentifier];
        
        // 添加到处理白名单
        [self addToShareWhiteListWithAction:routeActionIdentifier];
    }
}

+ (BOOL)openUniversalLinkWithURL:(NSURL *)url
{
    return [self handleOpenURLActionWithURL:url];
}

+ (BOOL)openSchemeWithURL:(NSURL *)url
{
    return [self handleOpenURLActionWithURL:url];
}

+ (BOOL)openRemoteNotificationWithURL:(NSURL *)url
{
    return [self handleOpenURLActionWithURL:url];
}

+ (BOOL)handleOpenURLActionWithURL:(NSURL *)url
{
    if (!url) {
        return NO;
    }
    
    // 春节活动只判断action类型路由。如果是普通页面路由，在外层也可以处理
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
    if (![paramObj hasRouteAction]) {
        return NO;
    }
    
    NSString *actionValue = [paramObj routeActionIdentifier];
    if (![self canHandleAction:actionValue]) {
        return NO;
    }
    
    // 处理url
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        
        // 清剪贴板，防止openURL跳转进入app后再监测剪贴板
        [self clearPastboardIfNeed];
        
        // 注册处理block
        [TTSFShareManager sharedManager].delayHandleBlock = ^(NSDictionary *context) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 处理openURL时如果键盘处于弹出状态，先resign。主线程异步调用
                if ([[TTKeyboardListener sharedInstance] isVisible]) {
                    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
                }
            });
            BOOL executed = [[TTRoute sharedRoute] executeRouteActionURL:url userInfo:nil];
            
            // 检测是否要申请新人红包（春节）
            if (executed && ![self checkWXNewbeeRedpacketURL:url]) {
                [self applyNewbeeRedpacketWithType:TTSFNewbeeRedPacketTypeSF];
            }
            
            return executed;
        };
        
        if ([TTSFResourcesManager isReadyForUse]) {
            return [[TTSFShareManager sharedManager] onResourceReadyForUse];
        } else {
            // 等待资源下完完成通知再处理，直接返回true
            return YES;
        }
    } else {
        return NO;
    }
}

@end

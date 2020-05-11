//
//  FHLoginViewModel.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/14.
//

#import "FHLoginViewModel.h"
#import "TTRoute.h"
#import "FHMineAPI.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "FHMineAPI.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "FHUserTracker.h"
#import <FHHouseBase/FHEnvContext.h>
#import "YYLabel.h"
#import <YYText/NSAttributedString+YYText.h>
#import "TTAccountMobileCaptchaAlertView.h"
#import "TTThemedAlertController.h"
#import "FHLoginContainerViewController.h"
#import "FHBindContainerViewController.h"
#import <TTRoute/TTRoute.h>
#import <BDABTestSDK/BDABTestManager.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTBaseLib/TTSandBoxHelper.h>
#import <FHWebView/SSWebViewController.h>
#import <ByteDanceKit/NSString+BTDAdditions.h>
#import "FHLoginConflictBridgePlugin.h"
#import <TTInstallService/TTInstallIDManager.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import "FHLoginConflictBridgePlugin.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import <ByteDanceKit/BTDWeakProxy.h>

extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHPLoginhoneNumberCacheKey;

NSString * const kFHLoginSIMStatusChangeNotification = @"kFHLoginSIMStatusChangeNotification";

@interface FHLoginSharedModel : NSObject

+ (instancetype)sharedModel;

@property (nonatomic, assign) BOOL hasPushedLoginProcess;
@property (nonatomic, assign) BOOL hasRequestedApis;

- (void)loadOneKayAndDouyinConfigs:(void (^)(void))completion;

@property (nonatomic, assign) BOOL disableDouyinOneClickLoginSetting;
@property (nonatomic, assign) BOOL disableDouyinIconLoginSetting;

@property (nonatomic, assign) BOOL isOneKeyLogin;
@property (nonatomic, copy) NSString *mobileNumber;
@property (nonatomic, assign) BOOL *douyinCanQucikLogin;

@property (nonatomic, strong) CTTelephonyNetworkInfo *telephoneInfo;
@end

@implementation FHLoginSharedModel

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _telephoneInfo = nil;
}

static FHLoginSharedModel *_sharedModel = nil;

+ (instancetype)sharedModel {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[FHLoginSharedModel alloc] init];
    });
    return _sharedModel;
}

- (instancetype)init {
    if (self = [super init]) {
        _telephoneInfo = [[CTTelephonyNetworkInfo alloc] init];
        if (@available(iOS 12.0, *)) {
            [_telephoneInfo setServiceSubscriberCellularProvidersDidUpdateNotifier:^(NSString * _Nonnull info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFHLoginSIMStatusChangeNotification object:nil];
                });
            }];
        } else {
            [_telephoneInfo setSubscriberCellularProviderDidUpdateNotifier:^(CTCarrier *carrier){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFHLoginSIMStatusChangeNotification object:nil];
                });
            }];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netReachabilityChanged:) name:TTReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simChanedNotification:) name:kFHLoginSIMStatusChangeNotification object:nil];
        
        NSDictionary *fhSettings = [self.class fhSettings];
        NSDictionary *loginSettings = [fhSettings btd_dictionaryValueForKey:@"login_settings"];
        if (loginSettings) {
            self.disableDouyinIconLoginSetting = [loginSettings btd_boolValueForKey:@"disable_douyin_icon" default:NO];
            self.disableDouyinOneClickLoginSetting = [loginSettings btd_boolValueForKey:@"disable_douyin_oneclick" default:NO];
        }
    }
    return self;
}

+ (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]) {
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

- (void)loadOneKayAndDouyinConfigs:(void (^)(void))completion {
    
    //如果在一个app开启周期内，重复进入登录页，优先查看是否有记录，这个记录为内存缓存
    if (![TTReachability isNetworkConnected]) {
        self.douyinCanQucikLogin = NO;
        self.mobileNumber = nil;
        self.isOneKeyLogin = NO;
        if (completion) {
            completion();
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    __block NSError *requestError = nil;
    self.hasRequestedApis = NO;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL disableOneKeyLogin = [self getOneKeyLoginSwitchOff];
        if (disableOneKeyLogin) {
            self.isOneKeyLogin = NO;
            dispatch_group_leave(group);
            return;
        }
        
        NSString *serviceName = [TTAccount sharedAccount].service;
        if (serviceName.length < 1) {
            self.isOneKeyLogin = NO;
            dispatch_group_leave(group);
            return;
        }
        // 注意获取完手机号之后长期不登录的异常结果
        [TTAccount getOneKeyLoginPhoneNumberCompleted:^(NSString * _Nullable phoneNumber, NSString * _Nullable serviceName, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.isOneKeyLogin = !error && phoneNumber.length > 0;
            strongSelf.mobileNumber = phoneNumber;
            if (error) {
                requestError = error;
            }
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TTAccount canQuickLoginWithAweme:^(BOOL canQucikLogin, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.douyinCanQucikLogin = canQucikLogin;
            if (error) {
                requestError = error;
            }
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (requestError) {
            self.hasRequestedApis = NO;
        } else {
            self.hasRequestedApis = YES;
        }
        if (completion) {
            completion();
        }
    });

}

/// 运营商一键登录开关
- (BOOL)getOneKeyLoginSwitchOff {
    BOOL disableOneKeyLogin = NO;
    BOOL disableTelecom = NO;
    BOOL disableUnicom = NO;
    BOOL disableMobile = NO;
    NSDictionary *fhSettings = [self.class fhSettings];
    NSDictionary *loginSettings = [fhSettings tt_dictionaryValueForKey:@"login_settings"];
    if (loginSettings) {
        disableOneKeyLogin = [loginSettings tt_boolValueForKey:@"disable_onekeylogin"];
        disableTelecom = [loginSettings tt_boolValueForKey:@"disable_telecom"];
        disableUnicom = [loginSettings tt_boolValueForKey:@"disable_unicom"];
        disableMobile = [loginSettings tt_boolValueForKey:@"disable_mobile"];
    }
    if (disableOneKeyLogin) {
        return disableOneKeyLogin;
    }
    NSString *service = [TTAccount sharedAccount].service;
    if ([service isEqualToString:TTAccountMobile]) {
        return disableMobile;
    }else if ([service isEqualToString:TTAccountUnion]) {
        return disableUnicom;
    }else if ([service isEqualToString:TTAccountTelecom]) {
        return disableTelecom;
    }
    return disableOneKeyLogin;
}

- (void)netReachabilityChanged:(NSNotification *)aNotification {
    self.hasRequestedApis = NO;
    if (self.hasPushedLoginProcess) {
        [self loadOneKayAndDouyinConfigs:nil];
    }
}

- (void)simChanedNotification:(NSNotification *)aNotification {
    self.hasRequestedApis = NO;
    if (self.hasPushedLoginProcess) {
        [self loadOneKayAndDouyinConfigs:nil];
    }
}

@end

@interface FHLoginViewModel()

@property(nonatomic , weak) FHLoginViewController *viewController;
@property (nonatomic, assign) FHLoginViewType currentViewType;
@property(nonatomic , assign) BOOL isRequestingSMS;
@property(nonatomic , strong) NSTimer *timer;
@property(nonatomic , assign) NSInteger verifyCodeRetryTime;
//是否重新是重新发送验证码
@property(nonatomic , assign) BOOL isVerifyCodeRetry;

/// 首推登录方式 douyin_one_click 、one_click、phone_sms
@property (nonatomic, copy) NSString *login_suggest_method;
@property (nonatomic, assign) BOOL isOtherLogin;
@end

@implementation FHLoginViewModel

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [FHLoginSharedModel sharedModel].hasPushedLoginProcess = NO;
}

- (instancetype)initWithController:(FHLoginViewController *)viewController;
{
    self = [super init];
    if (self) {
        [FHLoginSharedModel sharedModel].hasPushedLoginProcess = YES;
        _needPopVC = YES;
        _isNeedCheckUGCAdUser = NO;
        _processType = FHLoginProcessOrigin;
        _viewController = viewController;
        id res = [BDABTestManager getExperimentValueForKey:@"f_douyin_login_type" withExposure:YES];
        if ([res isKindOfClass:[NSNumber class]]) {
            _processType = [(NSNumber *)res integerValue];
        }
//        NSLog(@"BDClientABTest f_douyin_login_type is %@",res);
        [self addObserver];
    }
    return self;
}

#pragma mark - UI
- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginConflictResolvedSuccess:) name:kFHLoginConflictResolvedSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginConflictResolvedFail:) name:kFHLoginConflictResolvedFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginConflictResolvedBindMobile:) name:kFHLoginConflictResolvedBindMobile object:nil];
}

- (void)startLoadData {
    [self.viewController startLoading];

    __weak typeof(self) weakSelf = self;
    void(^syncInfoBlock)(void) = ^(void) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.mobileNumber = [FHLoginSharedModel sharedModel].mobileNumber;
        [strongSelf.viewController endLoading];
        [strongSelf updateViewType];
    };
    
    if ([FHLoginSharedModel sharedModel].hasRequestedApis) {
        syncInfoBlock();
    } else {
        [[FHLoginSharedModel sharedModel] loadOneKayAndDouyinConfigs:syncInfoBlock];
    }

}

/// 是否显示运营商一键登录
/// @param isOneKeyLogin YES：显示运营商一键登录 NO：显示手机号快捷登录
/// @param phoneNum 手机号
//- (void)showOneKeyLoginView:(BOOL)isOneKeyLogin phoneNum:(NSString *)phoneNum {
//    [self.viewController endLoading];
//    self.isOneKeyLogin = isOneKeyLogin;
//    self.mobileNumber = phoneNum;
//    [self.view showOneKeyLoginView:isOneKeyLogin];
//    [self.view updateOneKeyLoginWithPhone:phoneNum service:isOneKeyLogin ? [self serviceNameStr] : nil];
//    [self.view.acceptCheckBox setSelected:NO];
//    [self checkToEnableConfirmBtn];
//    if (isOneKeyLogin) {
//        [self.view enableSendVerifyCodeBtn:NO];
//    }
//    [self addEnterCategoryLog];
//
//    [self updateViewType];
//}

//- (void)checkToEnableConfirmBtn {
//    BOOL hasPhoneInput = self.view.phoneInput.text.length > 0;
//    BOOL hasVerifyCodeInput = self.view.varifyCodeInput.text.length > 0;
//    BOOL confirmEnable = hasPhoneInput && (self.view.isOneKeyLogin || hasVerifyCodeInput);
//    [self.view enableConfirmBtn:confirmEnable];
//}

//- (void)acceptCheckBoxChange:(BOOL)selected {
//    self.view.acceptCheckBox.selected = !selected;
//    [self checkToEnableConfirmBtn];
//}

- (void)popViewController {
    if(self.present){
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    }else{
        if ([self.viewController.navigationController.viewControllers containsObject:self.viewController]) {
            NSUInteger index = [self.viewController.navigationController.viewControllers indexOfObject:self.viewController];
            if (index > 0) {
                index -= 1;
            }
            [self.viewController.navigationController popToViewController:self.viewController.navigationController.childViewControllers[index] animated:YES];
        } else {
            [self.viewController.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)sendVerifyCodeWithCaptcha:(NSString *)captcha needPushVerifyCodeView:(BOOL )needPushVerifyCodeView isForBindMobile:(BOOL )isForBindMobile{
//    [self.view endEditing:YES];
//
    __weak typeof(self) weakSelf = self;
    NSString *phoneNumber = self.mobileNumber;

    if (![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]) {
        [[ToastManager manager] showToast:@"手机号错误"];
        return;
    }

    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络错误"];
        return;
    }

    //如果是已发送验证码，就不继续发送了，直接进去验证码界面
    if (self.isRequestingSMS) {
        if (isForBindMobile) {
            [self goToBindContainerController:FHBindViewTypeVerify navigationType:FHBindContainerViewNavigationTypePop];
        } else {
            [self goToLoginContainerController:FHLoginViewTypeVerify];
        }
        return;
    }

    self.isRequestingSMS = YES;
    [[ToastManager manager] showToast:@"正在获取验证码"];
    [self traceVerifyCode];

    [FHMineAPI requestSendVerifyCode:phoneNumber captcha:captcha isForBindMobile:isForBindMobile completion:^(NSNumber *_Nonnull retryTime, UIImage *_Nonnull captchaImage, NSError *_Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [strongSelf blockRequestSendMessage:[retryTime integerValue]];
            [[ToastManager manager] showToast:@"短信验证码发送成功"];
            strongSelf.isVerifyCodeRetry = YES;
            if (needPushVerifyCodeView) {
                if (isForBindMobile) {
                    [strongSelf goToBindContainerController:FHBindViewTypeVerify navigationType:FHBindContainerViewNavigationTypePop];
                } else {
                    [strongSelf goToLoginContainerController:FHLoginViewTypeVerify];
                }
            }
        } else if (captchaImage) {
            strongSelf.isRequestingSMS = NO;
            [strongSelf showCaptcha:captchaImage error:error isForBindMobile:isForBindMobile];
        } else {
            NSString *errorMessage = [FHMineAPI errorMessageByErrorCode:error];
            [[ToastManager manager] showToast:errorMessage];
            strongSelf.isRequestingSMS = NO;
        }
    }];
}

- (void)showCaptcha:(UIImage *)captchaImage error:(NSError *)error isForBindMobile:(BOOL )isForBindMobile{
    TTAccountMobileCaptchaAlertView *alertView = [[TTAccountMobileCaptchaAlertView alloc] initWithCaptchaImage:captchaImage];
    alertView.error = error;
    __weak typeof(self) wself = self;
    [alertView showWithDismissBlock:^(TTAccountMobileCaptchaAlertView *alertView, NSInteger buttonIndex) {
        if (alertView.captchaValue.length > 0) {
            [wself sendVerifyCodeWithCaptcha:alertView.captchaValue needPushVerifyCodeView:YES isForBindMobile:isForBindMobile];
        }
#if DEBUG
        else {
            NSLog(@"%@-%@ > Error", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
#endif
        
    }];
}

- (void)updateViewType {
    //判断 self.processType
    FHLoginViewType viewType = FHLoginViewTypeOneKey;
    switch (self.processType) {
        case FHLoginProcessOrigin:
            if ([FHLoginSharedModel sharedModel].isOneKeyLogin) {
                viewType = FHLoginViewTypeOneKey;
            } else {
                viewType = FHLoginViewTypeMobile;
            }
            break;
        case FHLoginProcessTestA:
            if ([FHLoginSharedModel sharedModel].isOneKeyLogin) {
                viewType = FHLoginViewTypeOneKey;
            } else if([FHLoginSharedModel sharedModel].douyinCanQucikLogin && ![FHLoginSharedModel sharedModel].disableDouyinOneClickLoginSetting) {
                viewType = FHLoginViewTypeDouYin;
            } else {
                viewType = FHLoginViewTypeMobile;
            }
            break;
        case FHLoginProcessTestB:
            if ([FHLoginSharedModel sharedModel].douyinCanQucikLogin && ![FHLoginSharedModel sharedModel].disableDouyinOneClickLoginSetting) {
                viewType = FHLoginViewTypeDouYin;
            } else if([FHLoginSharedModel sharedModel].isOneKeyLogin) {
                viewType = FHLoginViewTypeOneKey;
            } else {
                viewType = FHLoginViewTypeMobile;
            }
            break;
        default:
            break;
    }
    self.currentViewType = viewType;
    if (self.loginViewViewTypeChanged) {
        self.loginViewViewTypeChanged(viewType);
    }
    switch (viewType) {
        case FHLoginViewTypeDouYin:
            self.login_suggest_method = @"douyin_one_click";
            break;
        case FHLoginViewTypeOneKey:
            self.login_suggest_method = @"one_click";
            break;
        case FHLoginViewTypeMobile:
            self.login_suggest_method = @"phone_sms";
            break;
        default:
            break;
    }
    
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict].mutableCopy;
    tracerDict[@"login_suggest_method"] = self.login_suggest_method?:@"";
    [FHLoginTrackHelper loginShow:tracerDict];
}

- (BOOL)shouldShowDouyinIcon {
    if (self.processType == FHLoginProcessOrigin) {
        return NO;
    }else {
        if ([FHLoginSharedModel sharedModel].disableDouyinIconLoginSetting) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 运营商一键登录
- (NSString *)serviceName {
    NSString *service = [TTAccount sharedAccount].service;
    if ([service isEqualToString:TTAccountMobile]) {
        return @"中国移动认证";
    } else if ([service isEqualToString:TTAccountUnion]) {
        return @"中国联通认证";
    } else if ([service isEqualToString:TTAccountTelecom]) {
        return @"中国电信认证";
    } else {
        return @"";
    }
}

- (NSAttributedString *)protocolAttrTextByIsOneKeyLoginViewType:(FHLoginViewType )viewType{
    __weak typeof(self) wself = self;
    NSMutableAttributedString *attrText = [NSMutableAttributedString new];
    NSRange serviceRange;
    NSRange userProtocolRange;
    NSRange privacyRange;
    NSString *urlStr = nil;
    NSDictionary *commonTextStyle = @{
                                      NSFontAttributeName: [UIFont themeFontRegular:13],
                                      NSForegroundColorAttributeName: [UIColor themeGray3],
                                      };
    UIColor *linkTextColor = [UIColor themeGray2];
    switch (viewType) {
        case FHLoginViewTypeDouYin:{
            attrText = [[NSMutableAttributedString alloc] initWithString:@"登录即同意 《幸福里用户协议》及《隐私政策》"];
            [attrText addAttributes:commonTextStyle range:NSMakeRange(0, attrText.length)];
            userProtocolRange = [attrText.string rangeOfString:@"幸福里用户协议"];
            if (userProtocolRange.location == NSNotFound) {
                userProtocolRange = NSMakeRange(7, 7);
            }
            privacyRange = [attrText.string rangeOfString:@"隐私政策"];
            if (privacyRange.location == NSNotFound) {
                privacyRange = NSMakeRange(17, 4);
            }
//            YYTextDecoration *decoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle];
            [attrText yy_setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, attrText.length)];
//            [attrText yy_setTextUnderline:decoration range:userProtocolRange];
//            [attrText yy_setTextUnderline:decoration range:privacyRange];
            [attrText yy_setTextHighlightRange:userProtocolRange color:linkTextColor backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
                [wself goToUserProtocol];
            }];
            [attrText yy_setTextHighlightRange:privacyRange color:linkTextColor backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
                [wself goToSecretProtocol];
            }];
            break;
        }
        case FHLoginViewTypeOneKey:{
            if ([[TTAccount sharedAccount].service isEqualToString:TTAccountMobile]) {
                attrText = [[NSMutableAttributedString alloc] initWithString:@"登录即同意 《中国移动认证服务条款》以及\n《幸福里用户协议》和《隐私政策》"];
                serviceRange = [attrText.string rangeOfString:@"中国移动认证服务条款"];
                if (serviceRange.location == NSNotFound) {
                    serviceRange = NSMakeRange(7, 10);
                }
                userProtocolRange = [attrText.string rangeOfString:@"幸福里用户协议"];
                if (userProtocolRange.location == NSNotFound) {
                    userProtocolRange = NSMakeRange(21, 7);
                }
                privacyRange = [attrText.string rangeOfString:@"隐私政策"];
                if (privacyRange.location == NSNotFound) {
                    privacyRange = NSMakeRange(31, 4);
                }
                urlStr = [NSString stringWithFormat:@"https://wap.cmpassport.com/resources/html/contract.html"];
            } else if ([[TTAccount sharedAccount].service isEqualToString:TTAccountTelecom]) {
                attrText = [[NSMutableAttributedString alloc] initWithString:@"登录即同意 《中国电信认证服务协议》以及\n《幸福里用户协议》和《隐私政策》"];
                serviceRange = [attrText.string rangeOfString:@"中国电信认证服务协议"];
                if (serviceRange.location == NSNotFound) {
                    serviceRange = NSMakeRange(7, 10);
                }
                userProtocolRange = [attrText.string rangeOfString:@"幸福里用户协议"];
                if (userProtocolRange.location == NSNotFound) {
                    userProtocolRange = NSMakeRange(21, 7);
                }
                privacyRange = [attrText.string rangeOfString:@"隐私政策"];
                if (privacyRange.location == NSNotFound) {
                    privacyRange = NSMakeRange(31, 4);
                }
                urlStr = [NSString stringWithFormat:@"https://e.189.cn/sdk/agreement/detail.do?hidetop=true"];
            } else if ([[TTAccount sharedAccount].service isEqualToString:TTAccountUnion]) {
                attrText = [[NSMutableAttributedString alloc] initWithString:@"登录即同意 《中国联通服务与隐私协议》以及\n《幸福里用户协议》和《隐私政策》"];
                serviceRange = [attrText.string rangeOfString:@"中国联通服务与隐私协议"];
                if (serviceRange.location == NSNotFound) {
                    serviceRange = NSMakeRange(7, 11);
                }
                userProtocolRange = [attrText.string rangeOfString:@"幸福里用户协议"];
                if (userProtocolRange.location == NSNotFound) {
                    userProtocolRange = NSMakeRange(22, 7);
                }
                privacyRange = [attrText.string rangeOfString:@"隐私政策"];
                if (privacyRange.location == NSNotFound) {
                    privacyRange = NSMakeRange(32, 4);
                }
                urlStr = [NSString stringWithFormat:@"https://opencloud.wostore.cn/authz/resource/html/disclaimer.html?fromsdk=true"];
            }
            [attrText addAttributes:commonTextStyle range:NSMakeRange(0, attrText.length)];
            [attrText yy_setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, attrText.length)];
//            YYTextDecoration *decoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle];
//            [attrText yy_setTextUnderline:decoration range:serviceRange];
//            [attrText yy_setTextUnderline:decoration range:userProtocolRange];
//            [attrText yy_setTextUnderline:decoration range:privacyRange];
            
            [attrText yy_setTextHighlightRange:serviceRange color:linkTextColor backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
                [wself goToServiceProtocol:urlStr];
            }];
            [attrText yy_setTextHighlightRange:userProtocolRange color:linkTextColor backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
                [wself goToUserProtocol];
            }];
            [attrText yy_setTextHighlightRange:privacyRange color:linkTextColor backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
                [wself goToSecretProtocol];
            }];
            break;
        }
        case FHLoginViewTypeMobile:{
            attrText = [[NSMutableAttributedString alloc] initWithString:@"登录即同意 《幸福里用户协议》及《隐私政策》"];
            [attrText addAttributes:commonTextStyle range:NSMakeRange(0, attrText.length)];
            userProtocolRange = [attrText.string rangeOfString:@"幸福里用户协议"];
            if (userProtocolRange.location == NSNotFound) {
                userProtocolRange = NSMakeRange(7, 7);
            }
            privacyRange = [attrText.string rangeOfString:@"隐私政策"];
            if (privacyRange.location == NSNotFound) {
                privacyRange = NSMakeRange(17, 4);
            }
//            YYTextDecoration *decoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle];
//            [attrText yy_setTextUnderline:decoration range:userProtocolRange];
//            [attrText yy_setTextUnderline:decoration range:privacyRange];
            [attrText yy_setTextHighlightRange:userProtocolRange color:linkTextColor backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
                [wself goToUserProtocol];
            }];
            [attrText yy_setTextHighlightRange:privacyRange color:linkTextColor backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
                [wself goToSecretProtocol];
            }];
            break;
        }
        default:
            break;
    }
    return attrText.copy;
}

#pragma mark - FHLoginViewDelegate
- (void)popLastViewController {
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

- (void)confirm {
//    [self.view endEditing:YES];
//    [self quickLogin:self.view.phoneInput.text smsCode:self.view.varifyCodeInput.text captcha:nil];
}

- (void)sendVerifyCode:(NSString *)mobileNumber needPush:(BOOL)needPush isForBindMobile:(BOOL)isForBindMobile{
    self.mobileNumber = mobileNumber;
    [self sendVerifyCodeWithCaptcha:nil needPushVerifyCodeView:needPush isForBindMobile:isForBindMobile];
}

- (void)goToUserProtocol {
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@/f100/download/user_agreement.html&title=幸福里用户协议&hide_more=1",[FHMineAPI host]];
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

- (void)goToSecretProtocol {
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@/f100/download/private_policy.html&title=隐私政策&hide_more=1",[FHMineAPI host]];
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

- (void)goToLoginContainerController:(FHLoginViewType )viewType {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"viewType"] = @(viewType);
    dict[@"viewModel"] = self;
    FHLoginContainerViewController *vc = [[FHLoginContainerViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(dict.copy)];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (void)goToBindContainerController:(FHBindViewType )viewType navigationType:(FHBindContainerViewNavigationType )navigationType {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"viewType"] = @(viewType);
    dict[@"navigationType"] = @(navigationType);
    dict[@"viewModel"] = self;
    FHBindContainerViewController *vc = [[FHBindContainerViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(dict.copy)];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (void)goToOneKeyLogin {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"login_suggest_method"] = self.login_suggest_method?:@"";
    [FHLoginTrackHelper loginMore:tracerDict];
    if ([FHLoginSharedModel sharedModel].isOneKeyLogin) {
        [self goToLoginContainerController:FHLoginViewTypeOneKey];
    } else {
        [self goToMobileLogin];
    }
}

- (void)goToMobileLogin {
    self.isOtherLogin = YES;
    [self goToLoginContainerController:FHLoginViewTypeMobile];
}

- (void)goToOneKeyBind {
    if ([FHLoginSharedModel sharedModel].isOneKeyLogin) {
        [self goToBindContainerController:FHBindViewTypeOneKey navigationType:FHBindContainerViewNavigationTypeClose];
    } else {
        [self goToBindContainerController:FHBindViewTypeMobile navigationType:FHBindContainerViewNavigationTypeClose];
    }
}

/// 跳转手机号绑定界面
- (void)goToMobileBind {
    [self goToBindContainerController:FHBindViewTypeMobile navigationType:FHBindContainerViewNavigationTypePop];
}

- (void)oneKeyLoginAction {
    [self traceLogin];
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"login_method"] = @"one_click";
    [FHLoginTrackHelper loginSubmit:tracerDict];

//    if (!self.view.acceptCheckBox.selected) {
//        [[ToastManager manager] showToast:@"请阅读并同意《隐私政策》和相关协议"];
//        return;
//    }
    [[NSUserDefaults standardUserDefaults] setObject:@"one_click" forKey:FHLoginTrackLastLoginMethodKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    __weak typeof(self) wself = self;
    [[ToastManager manager] showToast:@"正在登录中"];
    [TTAccount oneKeyLoginWithCompleted:^(NSError *_Nullable error) {
        //运营商一键登录，自带手机号，不需要绑定流程
        [wself handleLoginResult:nil phoneNum:nil smsCode:nil error:error isOneKeyLogin:YES];
        [FHLoginTrackHelper loginResult:tracerDict error:error];
    }];
}

- (void)appleLoginAction {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"login_method"] = @"apple_login";
    [FHLoginTrackHelper loginSubmit:tracerDict];

    [[NSUserDefaults standardUserDefaults] setObject:@"apple_login" forKey:FHLoginTrackLastLoginMethodKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    __weak typeof(self) weakSelf = self;
    [TTAccount requestLoginForPlatform:TTAccountAuthTypeApple completion:^(BOOL success, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error && error.code == TTAccountErrCodeAuthUserCancel) {
            tracerDict[@"status"] = @"cancel";
        }
        [FHLoginTrackHelper loginResult:tracerDict error:error];
        if (error) {
            //失败则提示
            [strongSelf handleLoginResult:nil phoneNum:nil smsCode:nil error:error isOneKeyLogin:NO];
        } else {
            if ([TTAccount sharedAccount].user.mobile.length) {
                [strongSelf handleLoginResult:nil phoneNum:nil smsCode:nil error:error isOneKeyLogin:NO];
            } else {
                //苹果登录成功，判定没有手机号，进入绑定流程
                [strongSelf goToOneKeyBind];
            }
        }
    }];
}

- (void)douyinLoginAction {
    //douyin_one_click or douyin icon
    __weak typeof(self) weakSelf = self;
    TTAccountAuthRequest *request = [[TTAccountAuthRequest alloc] init];
    request.requestReason = TTAccountRequestAuthForLoginWithBindMobile;
    request.needMobile = YES;
    request.permissions = [NSOrderedSet orderedSetWithObjects:@"user_info",@"mobile", nil];
//    request.extraInfo = @{@"skip_tel_num_bind":@(YES)};
    [TTAccount requestAuthForPlatform:TTAccountAuthTypeDouyin request:request willLogin:^(NSString * _Nonnull platformName) {
        NSLog(@"platformName:%@",platformName);
    } completion:^(TTAccountAuthResponse * _Nullable resp, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSMutableDictionary *tracerDict = [strongSelf.viewController.tracerModel logDict];
        tracerDict[@"is_native"] = resp.sdkAuth ? @(1):@(0);
        tracerDict[@"login_method"] = @"douyin_one_click";
        [FHLoginTrackHelper loginSubmit:tracerDict.copy];
        if (error && error.code == TTAccountErrCodeAuthUserCancel) {
            tracerDict[@"status"] = @"cancel";
        }
        [FHLoginTrackHelper loginResult:tracerDict error:error];
        [[NSUserDefaults standardUserDefaults] setObject:@"douyin_one_click" forKey:FHLoginTrackLastLoginMethodKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        if (error) {
            //失败则提示
            //登录冲突处理
            if (error.code == TTAccountErrCodeAuthPlatformBoundForbid) {
                void(^goDetailBlock)(void) = ^(void) {
                    NSString *profileKey = error.userInfo[@"profile_key"];
                    NSString *mobile = error.userInfo[@"mobile"];
                    NSString *screen_name = error.userInfo[@"screen_name"];
                    NSString *avatar_url = error.userInfo[@"avatar_url"];
                    avatar_url = [avatar_url btd_stringByURLEncode];
                    NSString *platform_screen_name_current = error.userInfo[@"platform_screen_name_current"];
                    NSString *platform_screen_name_conflict = error.userInfo[@"platform_screen_name_conflict"];
                    NSInteger last_login_time = [error.userInfo[@"last_login_time"] integerValue];
                    NSString *enter_from = tracerDict[@"enter_from"];
                    NSString *device_id = [[TTInstallIDManager sharedInstance] deviceID];
                    NSString *URLString = [NSString stringWithFormat:@" http://m.haoduofangs.com/passport/auth_bind_conflict/index/?aid=1370&enter_from=%@&mobile=%@&screen_name=%@&avatar_url=%@&last_login_time=%@&platform_screen_name_current=%@&platform_screen_name_conflict=%@&profile_key=%@&device_id=%@",enter_from, mobile, screen_name, avatar_url, @(last_login_time), platform_screen_name_current, platform_screen_name_conflict, profileKey, device_id];
                    
                    ssOpenWebView([TTStringHelper URLWithURLString:URLString], nil, strongSelf.viewController.navigationController, NO, @{@"hide_nav_bar": @"1",@"hide_back_button": @"1"});
                };
                NSString *message = @"";
                if ([error.userInfo[@"screen_name"] isKindOfClass:[NSString class]] && [error.userInfo[@"mobile"] isKindOfClass:[NSString class]] ) {
                    message = [NSString stringWithFormat:@"检查到%@已绑定\n幸福里帐号【%@】",error.userInfo[@"mobile"], error.userInfo[@"screen_name"]];
                }
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"帐号冲突提醒"
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消授权"
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                                         // 点击取消按钮，调用此block
                                                                     }];
                [alertController addAction:cancelAction];
                
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"查看详情"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                                          // 点击按钮，调用此block
                                                                          if(goDetailBlock){
                                                                              goDetailBlock();
                                                                          }
                                                                      }];
                [alertController addAction:defaultAction];
                [[TTUIResponderHelper visibleTopViewController] presentViewController:alertController animated:YES completion:nil];
                

            } else if (error.code == 1060) {
                NSString *profileKey = error.userInfo[@"profile_key"];
                if (profileKey.length) {
                    strongSelf.profileKey = profileKey;
                    [strongSelf goToOneKeyBind];
                }
            } else {
                [strongSelf handleLoginResult:nil phoneNum:nil smsCode:nil error:error isOneKeyLogin:NO];
            }
        } else {
            if ([TTAccount sharedAccount].user.mobile.length) {
                [strongSelf handleLoginResult:nil phoneNum:nil smsCode:nil error:error isOneKeyLogin:NO];
            } else {
                //登录成功，判定没有手机号，进入绑定流程
                [strongSelf goToOneKeyBind];
            }
        }
    }];
}

- (void)loginCancelAction {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"login_suggest_method"] = self.login_suggest_method?:@"";
    [FHLoginTrackHelper loginExit:tracerDict];
    [self popViewController];
}

- (void)bindCancelAction {
    //登出账号，并且退出所有页面
    NSString *userID = [TTAccount sharedAccount].user.userID;
    __weak typeof(self) weakSelf = self;
    [TTAccount logoutInScene:TTAccountLogoutSceneNormal completion:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = self;
        BOOL shouldIgnoreError = NO;
        //未设置密码也可以退出登录
        if (error.code == 1037) {
            shouldIgnoreError = YES;
        }
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:error.description forKey:@"error_description"];
        [extra setValue:@(error.code) forKey:@"error_code"];
        [extra setValue:userID forKey:@"user_id"];
        
        if (error && !shouldIgnoreError) {
            [[TTMonitor shareManager] trackService:@"account_logout" status:2 extra:extra];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"退出登录失败，请稍后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        } else {
            [[TTMonitor shareManager] trackService:@"account_logout" status:1 extra:extra];
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                wrapperTrackerEvent([TTSandBoxHelper appName], @"xiangping", @"account_setting_signout");
            }
            // LogV3
            [TTTrackerWrapper eventV3:@"login_account_exit" params:nil isDoubleSending:YES];
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
            [sendPhoneNumberCache removeObjectForKey:kFHPLoginhoneNumberCacheKey];
        }
        [strongSelf popViewController];
    }];
}

- (void)oneKeyBindAction {
    __weak typeof(self) weakSelf = self;
    if (self.profileKey.length) {
        [TTAccount oneKeyBindPhoneWithProfileKey:self.profileKey completed:^(NSError * _Nullable error) {
            [weakSelf handleLoginResult:nil phoneNum:nil smsCode:nil error:error isOneKeyLogin:NO];
        }];
    } else {
        [TTAccount oneKeyBindPhoneWithPassword:nil unbind:NO completed:^(NSError * _Nullable error) {
            [weakSelf handleLoginResult:nil phoneNum:nil smsCode:nil error:error isOneKeyLogin:NO];
        }];
    }
}

- (void)mobileBind:(NSString *)mobileNumber smsCode:(NSString *)smsCode captcha:(NSString *)captcha {
    if (![mobileNumber hasPrefix:@"1"] || mobileNumber.length != 11 || ![self isPureInt:mobileNumber]) {
        [[ToastManager manager] showToast:@"手机号错误"];
        return;
    }
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络错误"];
        return;
    }
    if(smsCode.length == 0){
        [[ToastManager manager] showToast:@"验证码为空"];
        return;
    }
    [[ToastManager manager] showToast:@"正在绑定中"];
    __weak typeof(self) weakSelf = self;
    if (self.profileKey.length) {
        [TTAccount requesetBindAndLogingWithPhonenumber:mobileNumber SMSCode:smsCode profileKey:self.profileKey SMSCodeType:TTASMSCodeScenarioBindPhoneSubmit captcha:captcha completion:^(UIImage * _Nullable captchaImage, NSError * _Nullable error) {
            [weakSelf handleLoginResult:captchaImage phoneNum:mobileNumber smsCode:smsCode error:error isOneKeyLogin:NO];
        }];
    } else {
        [TTAccount bindPhoneWithPhone:mobileNumber SMSCode:smsCode password:nil captcha:captcha unbind:NO completion:^(UIImage * _Nullable captchaImage, NSError * _Nullable error) {
            [weakSelf handleLoginResult:captchaImage phoneNum:mobileNumber smsCode:smsCode error:error isOneKeyLogin:NO];
        }];
    }
}

- (void)goToServiceProtocol:(NSString *)urlStr {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://webview?url=%@",urlStr]];
    NSString *title = @"";
    if ([[TTAccount sharedAccount].service isEqualToString:TTAccountMobile]) {
        title = @"中国移动认证服务条款";
    }else if ([[TTAccount sharedAccount].service isEqualToString:TTAccountTelecom]) {
        title = @"中国电信认证服务协议";
    }else if ([[TTAccount sharedAccount].service isEqualToString:TTAccountUnion]) {
        title = @"中国联通服务与隐私协议";
    }
    NSMutableDictionary *info = @{}.mutableCopy;
    info[@"url"] = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    info[@"title"] = title;
    NSString *jsCodeStr = [NSString stringWithFormat:@"var importStyle=function importStyle(b){var a=document.createElement(\"style\"),c=document;c.getElementsByTagName(\"head\")[0].appendChild(a);if(a.styleSheet){a.styleSheet.cssText=b}else{a.appendChild(c.createTextNode(b))}};importStyle('.ag-faq-lists { box-sizing: border-box;} .ag-faq-lists .faq-lists-li .icons-next { right:15px !important}')"];
    info[@"extra_js"] = jsCodeStr;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)mobileLogin:(NSString *)mobileNumber smsCode:(NSString *)smsCode captcha:(NSString *)captcha {
    [[NSUserDefaults standardUserDefaults] setObject:@"phone_sms" forKey:FHLoginTrackLastLoginMethodKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    __weak typeof(self) weakSelf = self;
    if (![mobileNumber hasPrefix:@"1"] || mobileNumber.length != 11 || ![self isPureInt:mobileNumber]) {
        [[ToastManager manager] showToast:@"手机号错误"];
        return;
    }
    
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络错误"];
        return;
    }
    
    if(smsCode.length == 0){
        [[ToastManager manager] showToast:@"验证码为空"];
        return;
    }
    
    [self traceLogin];
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"login_method"] = @"phone_sms";
    [FHLoginTrackHelper loginSubmit:tracerDict];
//    if (!self.view.acceptCheckBox.selected) {
//        [[ToastManager manager] showToast:@"请阅读并同意《用户协议》和《隐私政策》"];
//        return;
//    }
    
    [[ToastManager manager] showToast:@"正在登录中"];
    
    [FHMineAPI requestQuickLogin:mobileNumber smsCode:smsCode captcha:captcha completion:^(UIImage *_Nonnull captchaImage, NSNumber *_Nonnull newUser, NSError *_Nonnull error) {
        [weakSelf handleLoginResult:captchaImage phoneNum:mobileNumber smsCode:smsCode error:error isOneKeyLogin:NO];
        [FHLoginTrackHelper loginResult:tracerDict error:error];
    }];
}

- (void)handleLoginResult:(UIImage *)captchaImage phoneNum:(NSString *)phoneNumber smsCode:(NSString *)smsCode error:(NSError *)error isOneKeyLogin:(BOOL)isOneKeyLogin {
    
    [self traceLoginResult:captchaImage phoneNum:phoneNumber smsCode:smsCode error:error isOneKeyLogin:isOneKeyLogin];
    
    if (!error) {
        [[ToastManager manager] showToast:@"登录成功"];
        if (phoneNumber.length > 0) {
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
//            [sendPhoneNumberCache setObject:phoneNumber forKey:kFHPhoneNumberCacheKey];
            [sendPhoneNumberCache setObject:phoneNumber forKey:kFHPLoginhoneNumberCacheKey];
        }
        if (self.needPopVC) {
            [self popViewController];
        }
        [self loginSuccessedWithPhoneNum:phoneNumber];
        
        if (self.isNeedCheckUGCAdUser) {
            [[FHEnvContext sharedInstance] checkUGCADUserIsLaunch:YES];
        }
        
    } else if (captchaImage) {
        [self loginShowCaptcha:captchaImage error:error phoneNumber:phoneNumber smsCode:smsCode];
    } else {
        if (error.code == 1039) {
            TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"登录信息" message:[error.userInfo objectForKey:@"toutiao.account.errmsg_key"] preferredType:TTThemedAlertControllerTypeAlert];
            [alertController addActionWithTitle:@"确认" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                [self goToMobileLogin];
            }];
            [alertController showFrom:self.viewController animated:YES];
        } else if (isOneKeyLogin) {
            //如果是运营商一键登录失败，则跳转手机号验证码登录
            [self goToMobileLogin];
        } else {
            NSString *errorMessage = @"啊哦，服务器开小差了";
            if (!isOneKeyLogin) {
                errorMessage = [FHMineAPI errorMessageByErrorCode:error];
            }
            [[ToastManager manager] showToast:errorMessage];
            if (error.code == TTAccountErrCodeSMSCodeError && self.clearVerifyCodeWhenError) {
                //验证码错误
                self.clearVerifyCodeWhenError();
            }
        }
    }
}

- (void)loginSuccessedWithPhoneNum:(NSString *)phoneNumber {
    if (self.loginDelegate.completeAlert) {
        self.loginDelegate.completeAlert(TTAccountAlertCompletionEventTypeDone, phoneNumber);
    }
}

- (void)loginShowCaptcha:(UIImage *)captchaImage error:(NSError *)error phoneNumber:(NSString *)phoneNumber smsCode:(NSString *)smsCode {
    TTAccountMobileCaptchaAlertView *alertView = [[TTAccountMobileCaptchaAlertView alloc] initWithCaptchaImage:captchaImage];
    alertView.error = error;
    __weak typeof(self) wself = self;
    [alertView showWithDismissBlock:^(TTAccountMobileCaptchaAlertView *alertView, NSInteger buttonIndex) {
        if (alertView.captchaValue.length > 0) {
            [wself mobileLogin:phoneNumber smsCode:smsCode captcha:alertView.captchaValue];
        }
#if DEBUG
        else {
            NSLog(@"%@-%@ > Error", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
#endif
        
    }];
}

#pragma mark - Notification
- (void)loginConflictResolvedSuccess:(NSNotification *)aNotification {
    if ([TTAccount sharedAccount].user.mobile.length) {
        [self handleLoginResult:nil phoneNum:nil smsCode:nil error:nil isOneKeyLogin:NO];
    } else {
        //登录成功，判定没有手机号，进入绑定流程
        [self goToOneKeyBind];
    }
}

- (void)loginConflictResolvedFail:(NSNotification *)aNotification {
    //冲突处理失败，没有用户信息，需要跳转手机号登录或者运营商一键登录
    [self.viewController.navigationController popViewControllerAnimated:NO];
    if ([self.viewController.navigationController.viewControllers containsObject:self.viewController]) {
        NSUInteger index = [self.viewController.navigationController.viewControllers indexOfObject:self.viewController];
        if (index > 0) {
            if (self.currentViewType != FHLoginViewTypeDouYin) {
                [self.viewController.navigationController popToViewController:self.viewController.navigationController.childViewControllers[index] animated:YES];
            }else {
                [self.viewController.navigationController popToViewController:self.viewController.navigationController.childViewControllers[index] animated:NO];
                [self goToOneKeyLogin];
            }
        }
        
    } else {
        [self.viewController.navigationController popToRootViewControllerAnimated:NO];
        [FHLoginSharedModel sharedModel].douyinCanQucikLogin = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"enter_from"] = @"minetab";
            dict[@"enter_type"] = @"login";
            dict[@"isCheckUGCADUser"] = @(1);
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            NSURL* url = [NSURL URLWithString:@"snssdk1370://flogin"];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        });
    }
}

- (void)loginConflictResolvedBindMobile:(NSNotification *)aNotification {
    if (aNotification.object && [aNotification.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *info = (NSDictionary *)aNotification.object;
        if (info[@"profile_key"]) {
            NSString *profileKey = [info btd_stringValueForKey:@"profile_key"];
            if (profileKey.length) {
                self.profileKey = profileKey;
                [self goToOneKeyBind];
            }
        }
    }
}

#pragma mark - textFieldDidChange

//- (void)textFieldDidChange:(NSNotification *)notification {
//    UITextField *textField = (UITextField *)notification.object;
//    if (textField != self.view.phoneInput && textField != self.view.varifyCodeInput) {
//        return;
//    }
//    NSString *text = textField.text;
//    NSInteger limit = 0;
//    if(textField == self.view.phoneInput){
//        limit = 11;
//        if(!self.isRequestingSMS){
//            [self.view enableSendVerifyCodeBtn:self.view.phoneInput.text.length > 0];
//        }
//    } else if (textField == self.view.varifyCodeInput) {
//        limit = 6;
//    }
//
//    if(text.length > limit){
//        textField.text = [text substringToIndex:limit];
//    }
    //设置登录和获取验证码是否可点击
//    [self checkToEnableConfirmBtn];
//}

#pragma mark - 埋点
- (void)traceAnnounceAgreement {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict].mutableCopy;
    tracerDict[@"origin_enter_from"] = tracerDict[@"enter_from"] ? : @"be_null";
    tracerDict[@"origin_enter_type"] = tracerDict[@"enter_type"] ? : @"be_null";
    if ([FHLoginSharedModel sharedModel].isOneKeyLogin) {
        tracerDict[@"login_type"] = @"quick_login";
    }else {
        tracerDict[@"login_type"] = @"other_login";
    }
    if (self.isOtherLogin) {
        tracerDict[@"enter_from"] = @"quick_login";
        tracerDict[@"enter_type"] = @"other_login";
    }
    tracerDict[@"click_position"] = @"login_agreement";
    TRACK_EVENT(@"click_login_agreement", tracerDict);
}

- (void)traceLogin {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"origin_enter_from"] = tracerDict[@"enter_from"] ? : @"be_null";
    tracerDict[@"origin_enter_type"] = tracerDict[@"enter_type"] ? : @"be_null";
    if ([FHLoginSharedModel sharedModel].isOneKeyLogin) {
        tracerDict[@"click_position"] = @"quick_login";
    }else {
        tracerDict[@"login_type"] = @"other_login";
    }
    if (self.isOtherLogin) {
        tracerDict[@"enter_from"] = @"quick_login";
        tracerDict[@"enter_type"] = @"other_login";
    }
    tracerDict[@"login_agreement"] = @"1" ; // : @"0";
    TRACK_EVENT(@"click_login", tracerDict);
}


- (void)traceLoginResult:(UIImage *)captchaImage phoneNum:(NSString *)phoneNumber smsCode:(NSString *)smsCode error:(NSError *)error isOneKeyLogin:(BOOL)isOneKeyLogin {
    BOOL isReport = NO;
    NSString *errorMessage = UT_BE_NULL;
    if (!error) {
        // 登录成功
        isReport = YES;
    } else if (captchaImage) {
        // 获取验证码
        isReport = NO;
    } else {
        // 登录失败
        isReport = YES;
        
        if (error.code == 1039) {
            errorMessage = [error.userInfo objectForKey:@"toutiao.account.errmsg_key"];
        }else {
            errorMessage = @"啊哦，服务器开小差了";
            if (!isOneKeyLogin) {
                errorMessage = [FHMineAPI errorMessageByErrorCode:error];
            }
        }
    }
    
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"origin_enter_from"] = tracerDict[@"enter_from"] ? : @"be_null";
    tracerDict[@"origin_enter_type"] = tracerDict[@"enter_type"] ? : @"be_null";
    if ([FHLoginSharedModel sharedModel].isOneKeyLogin) {
        tracerDict[@"click_position"] = @"quick_login";
    }else {
        tracerDict[@"login_type"] = @"other_login";
    }
    if (self.isOtherLogin) {
        tracerDict[@"enter_from"] = @"quick_login";
        tracerDict[@"enter_type"] = @"other_login";
    }
    tracerDict[@"login_agreement"] = @"1" ; // : @"0";
    
    tracerDict[@"result"] = (error ? @"fail" : @"success");
    tracerDict[@"error"] = error ? @(error.code) : UT_BE_NULL;
    tracerDict[@"error_message"] = errorMessage;

    TRACK_EVENT(@"login_result", tracerDict);
}


- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"origin_enter_from"] = tracerDict[@"enter_from"] ? : @"be_null";
    tracerDict[@"origin_enter_type"] = tracerDict[@"enter_type"] ? : @"be_null";
    if ([FHLoginSharedModel sharedModel].isOneKeyLogin) {
        tracerDict[@"login_type"] = @"quick_login";
    }else {
        tracerDict[@"login_type"] = @"other_login";
    }
    if (self.isOtherLogin) {
        tracerDict[@"enter_from"] = @"quick_login";
        tracerDict[@"enter_type"] = @"other_login";
    }
    TRACK_EVENT(@"login_page", tracerDict);
}

- (void)traceVerifyCode {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"origin_enter_from"] = tracerDict[@"enter_from"] ? : @"be_null";
    tracerDict[@"origin_enter_type"] = tracerDict[@"enter_type"] ? : @"be_null";
    tracerDict[@"is_resent"] = @(self.isVerifyCodeRetry);
    tracerDict[@"login_type"] = tracerDict[@"login_type"] ? : @"other_login";
    if (self.isOtherLogin) {
        tracerDict[@"enter_from"] = @"quick_login";
        tracerDict[@"enter_type"] = @"other_login";
    }
    TRACK_EVENT(@"click_verifycode", tracerDict);
}

- (BOOL)isPureInt:(NSString *)str {
    NSScanner *scanner = [[NSScanner alloc] initWithString:str];
    int val = 0;
    return [scanner scanInt:&val] && scanner.isAtEnd;
}

- (void)blockRequestSendMessage:(NSInteger)retryTime {
    self.verifyCodeRetryTime = retryTime;
    [self startTimer];
}

#pragma mark - Timer
- (void)setVerifyCodeButtonCountDown {
    if (self.verifyCodeRetryTime < 0) {
        self.verifyCodeRetryTime = 0;
    }

    if (self.verifyCodeRetryTime == 0) {
        [self stopTimer];
//        [self.view setButtonContent:@"重新发送" font:[UIFont themeFontRegular:14] color:[UIColor themeGray1] state:UIControlStateNormal btn:self.view.sendVerifyCodeBtn];
//        [self.view setButtonContent:@"重新发送" font:[UIFont themeFontRegular:14] color:[UIColor themeGray3] state:UIControlStateDisabled btn:self.view.sendVerifyCodeBtn];
//        self.view.sendVerifyCodeBtn.enabled = (self.view.phoneInput.text.length > 0);
        self.isRequestingSMS = NO;
    } else {
//        self.view.sendVerifyCodeBtn.enabled = NO;
//        [self.view setButtonContent:[NSString stringWithFormat:@"重新发送(%lis)", (long) self.verifyCodeRetryTime] font:[UIFont themeFontRegular:14] color:[UIColor themeGray3] state:UIControlStateDisabled btn:self.view.sendVerifyCodeBtn];
    }
    if (self.updateTimeCountDownValue) {
        self.updateTimeCountDownValue(self.verifyCodeRetryTime);
    }
    self.verifyCodeRetryTime--;
}

- (void)startTimer {
    if (_timer) {
        [self stopTimer];
    }
    [self.timer fire];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:[BTDWeakProxy proxyWithTarget:self] selector:@selector(setVerifyCodeButtonCountDown) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end

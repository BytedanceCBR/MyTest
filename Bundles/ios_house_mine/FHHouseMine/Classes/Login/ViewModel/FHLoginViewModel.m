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

extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHPLoginhoneNumberCacheKey;

@interface FHLoginViewModel()

@property(nonatomic , weak) FHLoginViewController *viewController;
@property(nonatomic , assign) BOOL isRequestingSMS;
@property(nonatomic , strong) NSTimer *timer;
@property(nonatomic , assign) NSInteger verifyCodeRetryTime;
//是否重新是重新发送验证码
@property(nonatomic , assign) BOOL isVerifyCodeRetry;
@property(nonatomic , copy) NSString *oneKeyPhone;

@end

@implementation FHLoginViewModel

+ (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]) {
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

- (instancetype)initWithController:(FHLoginViewController *)viewController;
{
    self = [super init];
    if (self) {
        _needPopVC = YES;
        _isNeedCheckUGCAdUser = NO;
        _processType = FHLoginProcessTestB;
        _viewController = viewController;
    }
    return self;
}

#pragma mark - UI
- (void)viewWillAppear {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.noDismissVC) {
        self.noDismissVC = NO;
    } else {
        [self stopTimer];
    }
}

- (void)startLoadData
{
    if (![TTReachability isNetworkConnected]) {
        [self showOneKeyLoginView:NO phoneNum:nil];
        return;
    }
    
    BOOL isSwitchOff = [self getOneKeyLoginSwitchOff];
    if (isSwitchOff) {
        [self showOneKeyLoginView:NO phoneNum:nil];
        return;
    }

    [self.viewController startLoading];
    [self getOneKeyLoginPhoneNum];
}


/// 是否显示运营商一键登录
/// @param isOneKeyLogin YES：显示运营商一键登录 NO：显示手机号快捷登录
/// @param phoneNum 手机号
- (void)showOneKeyLoginView:(BOOL)isOneKeyLogin phoneNum:(NSString *)phoneNum {
    [self.viewController endLoading];
    self.isOneKeyLogin = isOneKeyLogin;
//    [self.view showOneKeyLoginView:isOneKeyLogin];
//    [self.view setAgreementContent:[self protocolAttrTextByIsOneKeyLogin:isOneKeyLogin] showAcceptBox:YES];
//    [self.view updateOneKeyLoginWithPhone:phoneNum service:isOneKeyLogin ? [self serviceNameStr] : nil];
//    [self.view.acceptCheckBox setSelected:NO];
//    [self checkToEnableConfirmBtn];
//    if (isOneKeyLogin) {
//        [self.view enableSendVerifyCodeBtn:NO];
//    }
    [self addEnterCategoryLog];
    
    //判断 self.processType
    
    FHLoginViewType viewType = FHLoginViewTypeOneKey;
    
    switch (self.processType) {
        case FHLoginProcessOrigin:
            if (self.isOneKeyLogin) {
                viewType = FHLoginViewTypeOneKey;
            } else {
                viewType = FHLoginViewTypeMobile;
            }
            break;
        case FHLoginProcessTestA:
            if (self.isOneKeyLogin) {
                viewType = FHLoginViewTypeOneKey;
            } else {
                viewType = FHLoginViewTypeDouYin;
            }
            break;
        case FHLoginProcessTestB:
            viewType = FHLoginViewTypeDouYin;
            break;
        default:
            break;
    }
    
    if (self.configureSubview) {
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
        if (isOneKeyLogin) {
            infoDict[@"phone"] = phoneNum?:@"";
            infoDict[@"service"] = [self serviceNameStr];
        }
        infoDict[@"protocol"] = [self protocolAttrTextByIsOneKeyLogin:isOneKeyLogin];
        self.configureSubview(viewType, infoDict.copy);
    }
}

- (void)checkToEnableConfirmBtn {
//    BOOL hasPhoneInput = self.view.phoneInput.text.length > 0;
//    BOOL hasVerifyCodeInput = self.view.varifyCodeInput.text.length > 0;
//    BOOL confirmEnable = hasPhoneInput && (self.view.isOneKeyLogin || hasVerifyCodeInput);
//    [self.view enableConfirmBtn:confirmEnable];
}

- (void)acceptCheckBoxChange:(BOOL)selected {
//    self.view.acceptCheckBox.selected = !selected;
    [self checkToEnableConfirmBtn];
}

#pragma mark - 运营商一键登录
/// 运营商一键登录开关
- (BOOL)getOneKeyLoginSwitchOff {
    BOOL disableOneKeyLogin = NO;
    BOOL disableTelecom = NO;
    BOOL disableUnicom = NO;
    BOOL disableMobile = NO;
    NSDictionary *fhSettings = [FHLoginViewModel fhSettings];
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
}

- (void)getOneKeyLoginPhoneNum
{
    __weak typeof(self)wself = self;
    NSString *serviceName = [TTAccount sharedAccount].service;
    if (serviceName.length < 1) {
        [self showOneKeyLoginView:NO phoneNum:nil];
        return;
    }
    
    // 注意获取完手机号之后长期不登录的异常结果
    [TTAccount getOneKeyLoginPhoneNumberCompleted:^(NSString * _Nullable phoneNumber, NSString * _Nullable serviceName, NSError * _Nullable error) {
        BOOL showOneKeyLogin = !error && phoneNumber.length > 0;
        [wself showOneKeyLoginView:showOneKeyLogin phoneNum:phoneNumber];
    }];
}

- (NSString *)serviceNameStr {
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

- (NSMutableAttributedString *)protocolAttrTextByIsOneKeyLogin:(BOOL)isOneKeyLogin {
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
    if (isOneKeyLogin) {
        if ([[TTAccount sharedAccount].service isEqualToString:TTAccountMobile]) {
            attrText = [[NSMutableAttributedString alloc] initWithString:@"登录即同意 《中国移动认证服务条款》以及《幸福里用户协议》和《隐私政策》"];
            serviceRange = NSMakeRange(7, 10);
            userProtocolRange = NSMakeRange(21, 7);
            privacyRange = NSMakeRange(31, 4);
            urlStr = [NSString stringWithFormat:@"https://wap.cmpassport.com/resources/html/contract.html"];
        } else if ([[TTAccount sharedAccount].service isEqualToString:TTAccountTelecom]) {
            attrText = [[NSMutableAttributedString alloc] initWithString:@"登录即同意 《中国电信认证服务协议》以及《幸福里用户协议》和《隐私政策》"];
            serviceRange = NSMakeRange(7, 10);
            userProtocolRange = NSMakeRange(21, 7);
            privacyRange = NSMakeRange(31, 4);
            urlStr = [NSString stringWithFormat:@"https://e.189.cn/sdk/agreement/detail.do?hidetop=true"];
        } else if ([[TTAccount sharedAccount].service isEqualToString:TTAccountUnion]) {
            attrText = [[NSMutableAttributedString alloc] initWithString:@"登录即同意 《中国联通服务与隐私协议》以及《幸福里用户协议》和《隐私政策》"];
            serviceRange = NSMakeRange(7, 11);
            userProtocolRange = NSMakeRange(22, 7);
            privacyRange = NSMakeRange(32, 4);
            urlStr = [NSString stringWithFormat:@"https://opencloud.wostore.cn/authz/resource/html/disclaimer.html?fromsdk=true"];
        }
        [attrText addAttributes:commonTextStyle range:NSMakeRange(0, attrText.length)];
        YYTextDecoration *decoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle];
        [attrText yy_setTextUnderline:decoration range:serviceRange];
        [attrText yy_setTextUnderline:decoration range:userProtocolRange];
        [attrText yy_setTextUnderline:decoration range:privacyRange];
        
        [attrText yy_setTextHighlightRange:serviceRange color:[UIColor themeGray3] backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
            [wself goToServiceProtocol:urlStr];
        }];
        [attrText yy_setTextHighlightRange:userProtocolRange color:[UIColor themeGray3] backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
            [wself goToUserProtocol];
        }];
        [attrText yy_setTextHighlightRange:privacyRange color:[UIColor themeGray3] backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
            [wself goToSecretProtocol];
        }];
    } else {
        attrText = [[NSMutableAttributedString alloc] initWithString:@"登录即同意 《幸福里用户协议》及《隐私政策》"];
        [attrText addAttributes:commonTextStyle range:NSMakeRange(0, attrText.length)];
        userProtocolRange = NSMakeRange(7, 7);
        privacyRange = NSMakeRange(17, 4);
        YYTextDecoration *decoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle];
        [attrText yy_setTextUnderline:decoration range:userProtocolRange];
        [attrText yy_setTextUnderline:decoration range:privacyRange];
        [attrText yy_setTextHighlightRange:userProtocolRange color:[UIColor themeGray3] backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
            [wself goToUserProtocol];
        }];
        [attrText yy_setTextHighlightRange:privacyRange color:[UIColor themeGray3] backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
            [wself goToSecretProtocol];
        }];
    }
    return attrText;
}

- (void)requestOneKeyLogin {
    __weak typeof(self) wself = self;
    [[ToastManager manager] showToast:@"正在登录中"];
    [TTAccount oneKeyLoginWithCompleted:^(NSError *_Nullable error) {
        [wself handleLoginResult:nil phoneNum:nil smsCode:nil error:error isOneKeyLogin:YES];
    }];
}

#pragma mark - FHLoginViewDelegate
- (void)confirm {
//    [self.view endEditing:YES];
//    [self quickLogin:self.view.phoneInput.text smsCode:self.view.varifyCodeInput.text captcha:nil];
}

- (void)sendVerifyCode {
    [self sendVerifyCodeWithCaptcha:nil];
}

- (void)goToUserProtocol
{
    self.noDismissVC = YES;
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@/f100/download/user_agreement.html&title=幸福里用户协议&hide_more=1",[FHMineAPI host]];
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

- (void)goToSecretProtocol
{
    self.noDismissVC = YES;
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@/f100/download/private_policy.html&title=隐私政策&hide_more=1",[FHMineAPI host]];
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

- (void)verifyCodeLoginAction
{
    self.isOtherLogin = YES;
//    [self showOneKeyLoginView:NO phoneNum:nil];
    FHLoginContainerViewController *vc = [[FHLoginContainerViewController alloc] init];
    vc.viewModel = self;
    vc.viewType = FHLoginViewTypeMobile;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (void)oneKeyLoginAction {
    [self traceLogin];
//    if (!self.view.acceptCheckBox.selected) {
//        [[ToastManager manager] showToast:@"请阅读并同意《隐私政策》和相关协议"];
//        return;
//    }
    [self requestOneKeyLogin];
}

- (void)appleLoginAction {
    __weak typeof(self) weakSelf = self;
    [TTAccount requestLoginForPlatform:TTAccountAuthTypeApple completion:^(BOOL success, NSError *error) {
        [weakSelf handleLoginResult:nil phoneNum:nil smsCode:nil error:error isOneKeyLogin:NO];
    }];
}

- (void)awesomeLoginAction {
    __weak typeof(self) weakSelf = self;
    [TTAccount requestLoginForPlatform:TTAccountAuthTypeDouyin willLogin:^(NSString * _Nonnull info) {
        NSLog(@"info:%@",info);
    } completion:^(BOOL success, NSError *error) {
        [weakSelf handleLoginResult:nil phoneNum:nil smsCode:nil error:error isOneKeyLogin:NO];
    }];
//    [TTAccount requestLoginForPlatform:TTAccountAuthTypeDouyin completion:^(BOOL success, NSError *error) {
//        [weakSelf handleLoginResult:nil phoneNum:nil smsCode:nil error:error isOneKeyLogin:NO];
//    }];
}


- (void)goToServiceProtocol:(NSString *)urlStr {
    self.noDismissVC = YES;
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

- (void)quickLogin:(NSString *)phoneNumber smsCode:(NSString *)smsCode captcha:(NSString *)captcha {

    __weak typeof(self) weakSelf = self;
    if (![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]) {
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
//    if (!self.view.acceptCheckBox.selected) {
//        [[ToastManager manager] showToast:@"请阅读并同意《用户协议》和《隐私政策》"];
//        return;
//    }
    
    [[ToastManager manager] showToast:@"正在登录中"];
    
    [FHMineAPI requestQuickLogin:phoneNumber smsCode:smsCode captcha:captcha completion:^(UIImage *_Nonnull captchaImage, NSNumber *_Nonnull newUser, NSError *_Nonnull error) {
        [weakSelf handleLoginResult:captchaImage phoneNum:phoneNumber smsCode:smsCode error:error isOneKeyLogin:NO];
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
                [self verifyCodeLoginAction];
            }];
            [alertController showFrom:self.viewController animated:YES];
        }else {
            NSString *errorMessage = @"啊哦，服务器开小差了";
            if (!isOneKeyLogin) {
                errorMessage = [FHMineAPI errorMessageByErrorCode:error];
            }
            [[ToastManager manager] showToast:errorMessage];
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
            [wself quickLogin:phoneNumber smsCode:smsCode captcha:alertView.captchaValue];
        }
#if DEBUG
        else {
            NSLog(@"%@-%@ > Error", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
#endif
        
    }];
}

#pragma mark - 键盘通知
- (void)keyboardWillShowNotifiction:(NSNotification *)notification {
    if (_isHideKeyBoard) {
        return;
    }
    
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions) [curve integerValue] animations:^{
        
        [UIView setAnimationBeginsFromCurrentState:YES];
//        self.view.scrollView.contentOffset = CGPointMake(0, 120);
//        self.viewController.customNavBarView.title.hidden = NO;
        
    }completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
//        self.view.scrollView.contentOffset = CGPointMake(0, 0);
//        self.viewController.customNavBarView.title.hidden = YES;
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - textFieldDidChange

- (void)textFieldDidChange:(NSNotification *)notification {
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
    [self checkToEnableConfirmBtn];
}

#pragma mark - 埋点
- (void)traceAnnounceAgreement {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict].mutableCopy;
    tracerDict[@"origin_enter_from"] = tracerDict[@"enter_from"] ? : @"be_null";
    tracerDict[@"origin_enter_type"] = tracerDict[@"enter_type"] ? : @"be_null";
    if (self.isOneKeyLogin) {
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
    if (self.isOneKeyLogin) {
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
    if (self.isOneKeyLogin) {
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
    if (self.isOneKeyLogin) {
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

- (void)popViewController {
    if(self.present){
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.viewController.navigationController popViewControllerAnimated:YES];
    }
}


- (void)sendVerifyCodeWithCaptcha:(NSString *)captcha {
//    [self.view endEditing:YES];
//
//    __weak typeof(self) weakSelf = self;
//    NSString *phoneNumber = self.view.phoneInput.text;
//
//    if (![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]) {
//        [[ToastManager manager] showToast:@"手机号错误"];
//        return;
//    }
//
//    if (![TTReachability isNetworkConnected]) {
//        [[ToastManager manager] showToast:@"网络错误"];
//        return;
//    }
//
//    if (self.isRequestingSMS) {
//        return;
//    }
//
//    self.isRequestingSMS = YES;
//    [[ToastManager manager] showToast:@"正在获取验证码"];
//    [self traceVerifyCode];
//
//    [FHMineAPI requestSendVerifyCode:phoneNumber captcha:captcha completion:^(NSNumber *_Nonnull retryTime, UIImage *_Nonnull captchaImage, NSError *_Nonnull error) {
//        if (!error) {
//            [weakSelf blockRequestSendMessage:[retryTime integerValue]];
//            [[ToastManager manager] showToast:@"短信验证码发送成功"];
//            weakSelf.isVerifyCodeRetry = YES;
//        } else if (captchaImage) {
//            weakSelf.isRequestingSMS = NO;
//            [weakSelf showCaptcha:captchaImage error:error];
//        } else {
//            NSString *errorMessage = [FHMineAPI errorMessageByErrorCode:error];
//            [[ToastManager manager] showToast:errorMessage];
//            weakSelf.isRequestingSMS = NO;
//        }
//    }];
}

- (void)showCaptcha:(UIImage *)captchaImage error:(NSError *)error {
    TTAccountMobileCaptchaAlertView *alertView = [[TTAccountMobileCaptchaAlertView alloc] initWithCaptchaImage:captchaImage];
    alertView.error = error;
    __weak typeof(self) wself = self;
    [alertView showWithDismissBlock:^(TTAccountMobileCaptchaAlertView *alertView, NSInteger buttonIndex) {
        if (alertView.captchaValue.length > 0) {
            [wself sendVerifyCodeWithCaptcha:alertView.captchaValue];
        }
#if DEBUG
        else {
            NSLog(@"%@-%@ > Error", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
#endif
        
    }];
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
//    if (self.verifyCodeRetryTime < 0) {
//        self.verifyCodeRetryTime = 0;
//    }
//
//    if (self.verifyCodeRetryTime == 0) {
//        [self stopTimer];
//        [self.view setButtonContent:@"重新发送" font:[UIFont themeFontRegular:14] color:[UIColor themeGray1] state:UIControlStateNormal btn:self.view.sendVerifyCodeBtn];
//        [self.view setButtonContent:@"重新发送" font:[UIFont themeFontRegular:14] color:[UIColor themeGray3] state:UIControlStateDisabled btn:self.view.sendVerifyCodeBtn];
//        self.view.sendVerifyCodeBtn.enabled = (self.view.phoneInput.text.length > 0);
//        self.isRequestingSMS = NO;
//    } else {
//        self.view.sendVerifyCodeBtn.enabled = NO;
//        [self.view setButtonContent:[NSString stringWithFormat:@"重新发送(%lis)", (long) self.verifyCodeRetryTime] font:[UIFont themeFontRegular:14] color:[UIColor themeGray3] state:UIControlStateDisabled btn:self.view.sendVerifyCodeBtn];
//    }
//    self.verifyCodeRetryTime--;
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
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(setVerifyCodeButtonCountDown) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end

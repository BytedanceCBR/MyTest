//
//  SpringLoginViewModel.m
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/12/16.
//

#import "SpringLoginViewModel.h"
#import "TTRoute.h"
#import "FHMineAPI.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "FHMineAPI.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "FHUserTracker.h"
#import <FHHouseBase/FHEnvContext.h>
#import <YYLabel.h>
#import <YYText/NSAttributedString+YYText.h>
#import "TTAccountMobileCaptchaAlertView.h"
#import "TTThemedAlertController.h"
#import <FHMinisdkManager.h>

extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHPLoginhoneNumberCacheKey;

@interface SpringLoginViewModel()<SpringLoginViewDelegate>

@property(nonatomic , weak) SpringLoginViewController *viewController;
@property(nonatomic , strong) SpringLoginView *view;
@property(nonatomic , assign) BOOL isRequestingSMS;
@property(nonatomic , strong) NSTimer *timer;
@property(nonatomic , assign) NSInteger verifyCodeRetryTime;
//是否重新是重新发送验证码
@property(nonatomic , assign) BOOL isVerifyCodeRetry;

@end

@implementation SpringLoginViewModel

- (instancetype)initWithView:(SpringLoginView *)view controller:(SpringLoginViewController *)viewController;
{
    self = [super init];
    if (self) {
        
        view.delegate = self;
        _needPopVC = YES;
        _isNeedCheckUGCAdUser = NO;
        _view = view;
        _viewController = viewController;
        [self showLoginView];
    }
    return self;
}

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

- (void)showLoginView {
    [self.view setAgreementContent:[self protocolAttrTextByIsOneKeyLogin] showAcceptBox:YES];
    [self.view.acceptCheckBox setSelected:NO];
    [self checkToEnableConfirmBtn];
    [self addEnterCategoryLog];
}

- (NSMutableAttributedString *)protocolAttrTextByIsOneKeyLogin {
    __weak typeof(self) wself = self;
    NSMutableAttributedString *attrText = [NSMutableAttributedString new];
    NSRange userProtocolRange;
    NSRange privacyRange;
    NSDictionary *commonTextStyle = @{
                                      NSFontAttributeName: [UIFont themeFontRegular:10],
                                      NSForegroundColorAttributeName: [UIColor colorWithHexString:@"a90c05"],
                                      };
    
    attrText = [[NSMutableAttributedString alloc] initWithString:@"我已阅读并同意 《幸福里用户协议》及《隐私政策》"];
    [attrText addAttributes:commonTextStyle range:NSMakeRange(0, attrText.length)];
    userProtocolRange = NSMakeRange(9, 7);
    privacyRange = NSMakeRange(19, 4);
    YYTextDecoration *decoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle];
    [attrText yy_setTextUnderline:decoration range:userProtocolRange];
    [attrText yy_setTextUnderline:decoration range:privacyRange];
    [attrText yy_setTextHighlightRange:userProtocolRange color:[UIColor colorWithHexString:@"a90c05"] backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
        [wself goToUserProtocol];
    }];
    [attrText yy_setTextHighlightRange:privacyRange color:[UIColor colorWithHexString:@"a90c05"] backgroundColor:nil tapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
        [wself goToSecretProtocol];
    }];
    
    return attrText;
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

#pragma mark - 键盘通知

- (void)keyboardWillShowNotifiction:(NSNotification *)notification {
    if (_isHideKeyBoard) {
        return;
    }
    
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions) [curve integerValue] animations:^{
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.scrollView.contentOffset = CGPointMake(0, 120);
        
    }completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.scrollView.contentOffset = CGPointMake(0, 0);
        self.viewController.customNavBarView.title.hidden = YES;
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -- textFieldDidChange

- (void)textFieldDidChange:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    if (textField != self.view.phoneInput && textField != self.view.varifyCodeInput) {
        return;
    }
    NSString *text = textField.text;
    NSInteger limit = 0;
    if(textField == self.view.phoneInput){
        limit = 11;
        if(!self.isRequestingSMS){
            [self.view enableSendVerifyCodeBtn:self.view.phoneInput.text.length > 0];
        }
    } else if (textField == self.view.varifyCodeInput) {
        limit = 6;
    }
    
    if(text.length > limit){
        textField.text = [text substringToIndex:limit];
    }
    //设置登录和获取验证码是否可点击
    [self checkToEnableConfirmBtn];
}

- (void)checkToEnableConfirmBtn {
    BOOL hasPhoneInput = self.view.phoneInput.text.length > 0;
    BOOL hasVerifyCodeInput = self.view.varifyCodeInput.text.length > 0;
    BOOL confirmEnable = hasPhoneInput && hasVerifyCodeInput && self.view.acceptCheckBox.isSelected;
    [self.view enableConfirmBtn:confirmEnable];
}

#pragma mark -- SpringLoginViewDelegate

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

- (void)acceptCheckBoxChange:(BOOL)selected {
    self.view.acceptCheckBox.selected = !selected;
    if(self.view.acceptCheckBox.selected){
        [self.view showTipView:NO];
    }
    [self checkToEnableConfirmBtn];
}

- (void)confirm {
    [self.view endEditing:YES];
    [self quickLogin:self.view.phoneInput.text smsCode:self.view.varifyCodeInput.text captcha:nil];
}

- (void)close {
    [self popViewController:NO];
    [FHMinisdkManager sharedInstance].isShowing = NO;
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
    if (!self.view.acceptCheckBox.selected) {
//        [[ToastManager manager] showToast:@"请阅读并同意《用户协议》和《隐私政策》"];
        [self.view showTipView:YES];
        return;
    }
    
    [[ToastManager manager] showToast:@"正在登录中"];
    
    [FHMineAPI requestQuickLogin:phoneNumber smsCode:smsCode captcha:captcha completion:^(UIImage *_Nonnull captchaImage, NSNumber *_Nonnull newUser, NSError *_Nonnull error) {
        [weakSelf handleLoginResult:captchaImage phoneNum:phoneNumber smsCode:smsCode error:error isOneKeyLogin:NO];
    }];
}

- (void)handleLoginResult:(UIImage *)captchaImage phoneNum:(NSString *)phoneNumber smsCode:(NSString *)smsCode error:(NSError *)error isOneKeyLogin:(BOOL)isOneKeyLogin {
    if (!error) {
        [[ToastManager manager] showToast:@"登录成功"];
        if (phoneNumber.length > 0) {
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
            [sendPhoneNumberCache setObject:phoneNumber forKey:kFHPLoginhoneNumberCacheKey];
        }
        if (self.needPopVC) {
            [self popViewController:YES];
        }
        [self loginSuccessedWithPhoneNum:phoneNumber];
        
        if (self.isNeedCheckUGCAdUser) {
            [[FHEnvContext sharedInstance] checkUGCADUserIsLaunch:YES];
        }
        
    } else if (captchaImage) {
        [self loginShowCaptcha:captchaImage error:error phoneNumber:phoneNumber smsCode:smsCode];
    } else {
        NSString *errorMessage = [FHMineAPI errorMessageByErrorCode:error];
        [[ToastManager manager] showToast:errorMessage];
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

- (void)traceAnnounceAgreement {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict].mutableCopy;
    tracerDict[@"click_position"] = @"login_agreement";
    TRACK_EVENT(@"click_login_agreement", tracerDict);
}

- (void)traceLogin {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"login_agreement"] = self.view.acceptCheckBox.isSelected ? @"1" : @"0";
    TRACK_EVENT(@"click_login", tracerDict);
}

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    TRACK_EVENT(@"login_page", tracerDict);
}

- (void)popViewController:(BOOL)animated {
    if(self.present){
        [self.viewController dismissViewControllerAnimated:animated completion:nil];
    }else{
        [self.viewController.navigationController popViewControllerAnimated:animated];
    }
}

- (void)sendVerifyCode {
    [self sendVerifyCodeWithCaptcha:nil];
}

- (void)sendVerifyCodeWithCaptcha:(NSString *)captcha {
    [self.view endEditing:YES];
    
    __weak typeof(self) weakSelf = self;
    NSString *phoneNumber = self.view.phoneInput.text;
    
    if (![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]) {
        [[ToastManager manager] showToast:@"手机号错误"];
        return;
    }
    
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络错误"];
        return;
    }
    
    if (self.isRequestingSMS) {
        return;
    }
    
    self.isRequestingSMS = YES;
    [[ToastManager manager] showToast:@"正在获取验证码"];
    [self traceVerifyCode];
    
    [FHMineAPI requestSendVerifyCode:phoneNumber captcha:captcha completion:^(NSNumber *_Nonnull retryTime, UIImage *_Nonnull captchaImage, NSError *_Nonnull error) {
        if (!error) {
            [weakSelf blockRequestSendMessage:[retryTime integerValue]];
            [[ToastManager manager] showToast:@"短信验证码发送成功"];
            weakSelf.isVerifyCodeRetry = YES;
        } else if (captchaImage) {
            weakSelf.isRequestingSMS = NO;
            [weakSelf showCaptcha:captchaImage error:error];
        } else {
            NSString *errorMessage = [FHMineAPI errorMessageByErrorCode:error];
            [[ToastManager manager] showToast:errorMessage];
            weakSelf.isRequestingSMS = NO;
        }
    }];
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
    tracerDict[@"is_resent"] = @(self.isVerifyCodeRetry);
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

- (void)setVerifyCodeButtonCountDown {
    if (self.verifyCodeRetryTime < 0) {
        self.verifyCodeRetryTime = 0;
    }
    
    if (self.verifyCodeRetryTime == 0) {
        [self stopTimer];
        [self.view setButtonContent:@"重新发送" font:[UIFont themeFontRegular:14] color:[UIColor colorWithHexString:@"a05700"] state:UIControlStateNormal btn:self.view.sendVerifyCodeBtn];
        [self.view setButtonContent:@"重新发送" font:[UIFont themeFontRegular:14] color:[UIColor colorWithHexString:@"e1b067"] state:UIControlStateDisabled btn:self.view.sendVerifyCodeBtn];
        self.view.sendVerifyCodeBtn.enabled = (self.view.phoneInput.text.length > 0);
        self.isRequestingSMS = NO;
    } else {
        self.view.sendVerifyCodeBtn.enabled = NO;
        [self.view setButtonContent:[NSString stringWithFormat:@"重新发送(%lis)", (long) self.verifyCodeRetryTime] font:[UIFont themeFontRegular:14] color:[UIColor colorWithHexString:@"e1b067"] state:UIControlStateDisabled btn:self.view.sendVerifyCodeBtn];
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
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(setVerifyCodeButtonCountDown) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

+ (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]) {
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

@end

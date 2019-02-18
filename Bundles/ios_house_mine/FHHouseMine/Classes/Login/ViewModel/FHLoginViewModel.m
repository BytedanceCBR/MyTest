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

@interface FHLoginViewModel()<FHLoginViewDelegate>

@property(nonatomic , weak) FHLoginViewController *viewController;
@property(nonatomic , strong) FHLoginView *view;
@property(nonatomic , assign) BOOL isRequestingSMS;
@property(nonatomic , strong) NSTimer *timer;
@property(nonatomic , assign) NSInteger verifyCodeRetryTime;

@end

@implementation FHLoginViewModel

- (instancetype)initWithView:(FHLoginView *)view controller:(FHLoginViewController *)viewController;
{
    self = [super init];
    if (self) {
        
        view.delegate = self;
        
        _view = view;
        _viewController = viewController;
    }
    return self;
}

- (void)viewWillAppear {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopTimer];
}

#pragma mark - 键盘通知

- (void)keyboardWillShowNotifiction:(NSNotification *)notification {
    if(_isHideKeyBoard){
        return;
    }
    
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{

        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.scrollView.contentOffset = CGPointMake(0, 120);
        self.viewController.customNavBarView.title.hidden = NO;

    } completion:^(BOOL finished) {

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
    NSString *text = textField.text;
    NSInteger limit = 0;
    if(textField == self.view.phoneInput){
        limit = 11;
        
        //设置登录和获取验证码是否可点击
        if(text.length > 0){
            [self setVerifyCodeButtonAndConfirmBtnEnabled:YES];
        }else{
            [self setVerifyCodeButtonAndConfirmBtnEnabled:NO];
        }
    }else if(textField == self.view.varifyCodeInput){
        limit = 6;
    }
    
    if(text.length > limit){
        textField.text = [text substringToIndex:limit];
    }
}

- (void)setVerifyCodeButtonAndConfirmBtnEnabled:(BOOL)enabled {
    [self.view enableSendVerifyCodeBtn:enabled];
    [self.view enableConfirmBtn:enabled];
}

#pragma mark -- FHLoginViewDelegate

- (void)goToUserProtocol {
    NSString *urlStr = [NSString stringWithFormat:@"fschema://webview?url=%@/f100/download/user_agreement.html&title=幸福里用户协议&hide_more=1",[FHMineAPI host]];
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

- (void)goToSecretProtocol {
    NSString *urlStr = [NSString stringWithFormat:@"fschema://webview?url=%@/f100/download/private_policy.html&title=隐私协议&hide_more=1",[FHMineAPI host]];
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

- (void)acceptCheckBoxChange:(BOOL)selected {
    self.view.acceptCheckBox.selected = !selected;
    if(!self.view.acceptCheckBox.selected){
        [[ToastManager manager] showToast:@"请阅读并同意幸福里用户协议"];
    }
}

- (void)confirm {
    [self.view endEditing:YES];
    if(!self.view.acceptCheckBox.selected){
        [[ToastManager manager] showToast:@"请阅读并同意幸福里用户协议"];
    }
    [self quickLogin:self.view.phoneInput.text smsCode:self.view.varifyCodeInput.text];
}

- (void)quickLogin:(NSString *)phoneNumber smsCode:(NSString *)smsCode {
     __weak typeof(self) weakSelf = self;
    
    if(![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]){
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
    
    [FHMineAPI requestQuickLogin:phoneNumber smsCode:smsCode completion:^(UIImage * _Nonnull captchaImage, NSNumber * _Nonnull newUser, NSError * _Nonnull error) {
        if(!error){
            [[ToastManager manager] showToast:@"登录成功"];
            [weakSelf popViewController];
        }else{
            NSString *errorMessage = [FHMineAPI errorMessageByErrorCode:error];
            [[ToastManager manager] showToast:errorMessage];
        }
    }];
}

- (void)popViewController {
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

//func quickLogin(mobile: String, smsCode: String) {
//
//    if !mobile.hasPrefix("1") || mobile.count > 11 {
//        EnvContext.shared.toast.showToast("手机号错误")
//        return
//    }
//
//    if EnvContext.shared.client.reachability.connection == .none
//    {
//        EnvContext.shared.toast.showToast("网络错误")
//        return
//    }
//
//    requestQuickLogin(mobile: mobile, smsCode: smsCode)
//    .subscribe(onNext: { [unowned self] void in
//        EnvContext.shared.toast.dismissToast()
//        EnvContext.shared.toast.showToast("登录成功")
//        self.onResponse.accept(.successed)
//        self.loginResponse.accept(.successed)
//        EnvContext.shared.client.accountConfig.setUserPhone(phoneNumber: mobile)
//        EnvContext.shared.client.sendPhoneNumberCache?.setObject(mobile as NSString, forKey: "phonenumber")
//        EnvContext.shared.client.accountConfig.userInfo.accept(TTAccount.shared().user())
//        // 去掉通讯录弹窗
//        //                    AddressBookSync.trySyncAddressBook()
//    }, onError: { [unowned self] error in
//        self.loginResponse.accept(.error(error))
//        if let theError = error as? NSError {
//
//            EnvContext.shared.toast.showToast(theError.errorMessageByErrorCode())
//        }else {
//            EnvContext.shared.toast.showToast("加载失败")
//
//        }                })
//    .disposed(by: disposeBag)
//}

- (void)sendVerifyCode {
    [self.view endEditing:YES];
    
    __weak typeof(self) weakSelf = self;
    NSString *phoneNumber = self.view.phoneInput.text;
    
    if(![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]){
        [[ToastManager manager] showToast:@"手机号错误"];
        return;
    }
    
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络错误"];
        return;
    }
    
    if(self.isRequestingSMS){
        return;
    }
    
    self.isRequestingSMS = YES;
    
    [FHMineAPI requestSendVerifyCode:phoneNumber completion:^(NSNumber * _Nonnull retryTime, UIImage * _Nonnull captchaImage, NSError * _Nonnull error) {
        if(!error){
            [weakSelf blockRequestSendMessage:[retryTime integerValue]];
            [[ToastManager manager] showToast:@"短信验证码发送成功"];
        }else{
            NSString *errorMessage = [FHMineAPI errorMessageByErrorCode:error];
            [[ToastManager manager] showToast:errorMessage];
            weakSelf.isRequestingSMS = NO;
        }
    }];
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
    if(self.verifyCodeRetryTime < 0){
        self.verifyCodeRetryTime = 0;
    }
    
    if(self.verifyCodeRetryTime == 0){
        [self stopTimer];
        [self.view setButtonContent:@"重新发送" font:[UIFont themeFontRegular:14] color:[UIColor themeBlack] state:UIControlStateNormal btn:self.view.sendVerifyCodeBtn];
        self.view.sendVerifyCodeBtn.enabled = YES;
        self.isRequestingSMS = NO;
    }else{
        self.view.sendVerifyCodeBtn.enabled = NO;
        [self.view setButtonContent:[NSString stringWithFormat:@"重新发送(%lis)",(long)self.verifyCodeRetryTime] font:[UIFont themeFontRegular:14] color:[UIColor themeGray3] state:UIControlStateDisabled btn:self.view.sendVerifyCodeBtn];
    }
    self.verifyCodeRetryTime--;
}

- (void)startTimer {
    if(_timer){
        [self stopTimer];
    }
    [self.timer fire];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (NSTimer *)timer {
    if(!_timer){
        _timer  =  [NSTimer timerWithTimeInterval:1 target:self selector:@selector(setVerifyCodeButtonCountDown) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end

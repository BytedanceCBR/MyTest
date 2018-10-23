//
//  TTAccountLoginBaseViewController.h
//  TTAccountLogin
//
//  Created by huic on 16/3/8.
//
//

#import "TTAccountLoginBaseViewController.h"
#import "TTAccountLoginQuickRetrieveViewController.h"
#import "TTAccountLoginEditProfileViewController.h"
#import "TTAccountAlertView.h"
#import "TTAccountLoginAlert.h"
#import "NSTimer+TTNoRetainRef.h"
#import "TTAccountLoginConfLogic.h"
#import "TTAccountLoginManager.h"



@interface TTAccountLoginBaseViewController ()
<
TTAccountMulticastProtocol
>
@property (nonatomic, strong) TTIndicatorView *waitingIndicatorView;
@end

@implementation TTAccountLoginBaseViewController

- (instancetype)initWithTitle:(NSString *)title source:(NSString *)source
{
    if (self = [super init]) {
        _source = !isEmptyString(source) ? source : @"other";
        _types = [TTAccountLoginConfLogic loginPlatforms];
        if ([TTNavigationController refactorNaviEnabled] && [TTDeviceHelper isPadDevice]) {
            self.ttNeedHideBottomLine = YES;
            self.ttNeedTopExpand = NO;
            self.ttNaviTranslucent = YES;
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
    
    if (self.subscribeCompletionHandler) {
        if (self.subscribeState == TTAccountLoginStateLogin) {
            // 不用做操作
        } else {
            self.subscribeCompletionHandler(TTAccountLoginStateCancelled);
        }
    }
    
    if (self.loginCompletionHandler) {
        if (self.loginState == TTAccountLoginStateLogin) {
            self.loginCompletionHandler(TTAccountLoginStateLogin);
        } else {
            self.loginCompletionHandler(TTAccountLoginStateCancelled);
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ttNavBarStyle = @"Image";
    self.ttHideNavigationBar = NO;
    
    self.loginState = TTAccountLoginStateNotLogin;
    self.subscribeState = TTAccountLoginStateNotLogin;
    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    
    //清空定时器
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.countdown = 0;
    self.resendButtonEnabled = YES;
    
    // 监听登录完成通知
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorityViewResponsedReceived:) name:kGetAccountStatesFinishedNotification object:nil];
    [TTAccount addMulticastDelegate:self];
    
    if (!self.hideLeftItem) {
        self.navigationItem.leftBarButtonItem = self.leftItem;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    self.navigationItem.rightBarButtonItem = self.closeItem;
    
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.upInfoContainerView];
    [self.view addSubview:self.platformLoginView];
    
    [self.view addSubview:self.mobileInput];
    [self.view addSubview:self.captchaInput];
    [self.view addSubview:self.registerButton];
    
    [self refreshSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.frame = self.navigationController.view.bounds;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutSubviews];
    [self tt_performSelector:@selector(addTapGesture) onlyOnceInSelector:_cmd];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 收起之前弹出的一切键盘
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    // 监听键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // TextField变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self.view findFirstResponder] resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark - timer

- (void)startTimer
{
    self.countdown = 60;  // 倒计时默认60s
    self.resendButtonEnabled = NO;  // 倒计时结束前，不可重发
    
    if (self.timer) {
        return;
    }
    
    [self fitResendView];
    
    NSTimer *timer = [TTNoRetainRefNSTimer timerWithTimeInterval:1
                                                          target:self
                                                        selector:@selector(countDownActionFired:)
                                                        userInfo:nil
                                                         repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)clearTimer
{
    // 清空定时器
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.countdown = 0;
    self.resendButtonEnabled = YES;
    
    if ([self isViewLoaded]) {
        [self fitResendView];
    }
}

/**
 *  倒计时每秒相应
 *
 *  @param timer 定时器
 */
- (void)countDownActionFired:(NSTimer *)timer
{
    if (self.countdown == 0) {
        //清空计时器
        [timer invalidate];
        self.timer = nil;
        self.resendButtonEnabled = YES;
    }
    if (self.countdown > 0) {
        self.countdown--;
    }
    [self fitResendView];
}


#pragma mark - refreshUI

- (void)layoutSubviews
{
    self.backgroundView.frame = self.view.bounds;
    
    // 为了适配小屏幕手机(4, 4s)
    CGFloat extraNegHeight = ([TTDeviceHelper is480Screen] ? - 10 : 0);
    
    // 上方信息区域高度占全局1:4.688
    _upInfoContainerView.frame = self.view.bounds;
    _upInfoContainerView.height = floor(self.view.height * kTTAccountLoginUpInfoHeightRatioInView) + extraNegHeight;
    
    // 中部布局
    _mobileInput.size = CGSizeMake(self.view.width - kTTAccountLoginInputFieldLeftMargin - kTTAccountLoginInputFieldRightMargin, kTTAccountLoginInputFieldHeight);
    _mobileInput.top = floor(_upInfoContainerView.bottom + _upInfoContainerView.height * kTTAccountLoginInputFieldHeightRatioWithUpInfo) + extraNegHeight;
    _mobileInput.left = kTTAccountLoginInputFieldLeftMargin;
    
    
    // 第三方登录布局
    self.platformLoginView.width = self.view.width;
    self.platformLoginView.left = 0;
    self.platformLoginView.bottom = self.view.height - kTTAccountLoginPlatformBottomMargin - self.view.tt_safeAreaInsets.bottom;
    
    [self fitResendView];
}

- (void)refreshRegisterButton
{
    if (self.registerButtonEnabled) {
        [self.registerButton setBackgroundColor:[UIColor colorWithHexString:@"FF0031"]];
    } else {
        [self.registerButton setBackgroundColor:[UIColor colorWithHexString:@"FF8098"]];
    }
}

- (void)fitResendView
{
    
}

- (void) refreshSubviews
{
    
}

#pragma mark - Actions

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 弹出键盘时，touch view关闭编辑状态，收起键盘
    [self.view endEditing:YES];
}

- (void)registerButtonClicked:(id)sender
{
    
}

- (void)leftItemClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightItemClicked
{
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - TTAccountLoginPlatformLoginViewDelegate

- (void)loginPlatform:(NSString *)keyName
{
    [self uMengPlatform:keyName];
    
    TTAccountAuthType authPlatformType = [TTAccount accountAuthTypeForPlatform:keyName];
    [TTAccountLoginManager requestLoginPlatformByType:authPlatformType completion:^(BOOL success, NSError *error) {
        
        [self respondsToAccountAuthLoginWithError:error forPlatform:keyName];
        
        if (success) {
            [TTAccountLoginManager setDefaultLoginUIStyleFor:TTAccountLoginStyleCaptcha];
        }
    }];
}

- (void)uMengPlatform:(NSString *)keyName
{
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(NSNotification *)notification
{
    [self refreshRegisterButton];
}

#pragma mark - Notification

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    // keyboard size属性准确
    CGRect keyboardScreenFrame =
    [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSLog(@"willshow height:%f", keyboardScreenFrame.size.height);
    CGRect btnRect = [self.view convertRect:self.registerButton.frame toView:nil];
    
    CGFloat offsetY =
    (self.view.height - (btnRect.origin.y + btnRect.size.height)) - keyboardScreenFrame.size.height;
    
    if (offsetY < 0) {
        CGRect frame = self.view.frame;
        frame.origin.y += offsetY;
        self.view.frame = frame;
        if (self.ttNavigationBar) {
            frame = self.ttNavigationBar.frame;
            frame.origin.y -= offsetY;
            self.ttNavigationBar.frame = frame;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
    if (self.ttNavigationBar) {
        frame = self.ttNavigationBar.frame;
        frame.origin.y = 0;
        self.ttNavigationBar.frame = frame;
    }
}

#pragma mark - TTAccountMulticastProtocol

//- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
//{
//    // 可能出现调用多次，因为此时可能才在多个实例（TTAccountLoginViewController和TTAccountEditProfileViewController）
//    if (TTAccountStatusChangedReasonTypeAuthPlatformLogin == reasonType) {
//        [self respondsToAccountAuthLoginWithError:nil forPlatform:platformName];
//    }
//}

- (void)respondsToAccountAuthLoginWithError:(NSError *)error forPlatform:(NSString *)platformName
{

}

//- (void)authorityViewResponsedReceived:(NSNotification *)notification
//{
//    NSError *error = [[notification userInfo] objectForKey:@"error"];
//    BOOL isNewUser = NO;
//
//    if (self.loginState == TTAccountLoginStateLogin) return;
//    if (self.subscribeState == TTAccountLoginStateLogin) return;
//
//    self.loginState = TTAccountLoginStateLogin;
//    self.subscribeState = TTAccountLoginStateLogin;
//
//    if (!error) {
//        NSDictionary *data = [notification.userInfo tt_dictionaryValueForKey:@"data"];
//        if (data) {
//            if ([data tt_longlongValueForKey:@"new_user"] == 1) {
//                isNewUser = YES;
//                TTAccountLoginEditProfileViewController *loginEditUserInfoVC = [[TTAccountLoginEditProfileViewController alloc] initWithSource:self.source];
//                // 设置新用户信息
//                [self.navigationController pushViewController:loginEditUserInfoVC animated:YES];
//                return;
//            }
//        }
//    }
//
//    [self didReceiveAccountLoginSuccess:!error ? YES : NO];
//}

#pragma mark - Helper

- (BOOL)validateMobileNumber:(NSString *)mobileNumber
{
    NSString *regex = @"^1\\d{10}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:mobileNumber]) {
        return YES;
    }
    return NO;
}

- (BOOL)isContentValid
{
    return NO;
}

- (void)addTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationBarTap:)];
    if (self.ttNavigationBar) {
        [self.ttNavigationBar addGestureRecognizer:tap];
    } else {
        [self.navigationController.navigationBar addGestureRecognizer:tap];
    }
}

#pragma mark - TTWaitingIndicator

- (void)showWaitingIndicator
{
    self.view.userInteractionEnabled = NO;
    _waitingIndicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:nil indicatorImage:nil dismissHandler:nil];
    _waitingIndicatorView.showDismissButton = NO;
    _waitingIndicatorView.autoDismiss = NO;
    [_waitingIndicatorView showFromParentView:self.view];
}

- (void)dismissWaitingIndicator
{
    [self _dismissWaitingIndicator];
}

- (void)dismissWaitingIndicatorWithError:(NSError *)error
{
    NSString *desc = [self _indicatorErrorTextFromError:error];
    
    if (!isEmptyString(desc)) {
        self.view.userInteractionEnabled = NO;
        [_waitingIndicatorView updateIndicatorWithImage:[UIImage themedImageNamed:@"close_popup_textpage"]];
        [self dismissWaitingIndicatorWithText:desc];
    } else {
        [self _dismissWaitingIndicator];
    }
}

- (void)dismissWaitingIndicatorWithText:(NSString *)message
{
    [_waitingIndicatorView updateIndicatorWithText:message
                           shouldRemoveWaitingView:YES];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf _dismissWaitingIndicator];
    });
}

- (void)_dismissWaitingIndicator
{
    self.view.userInteractionEnabled = YES;
    [_waitingIndicatorView dismissFromParentView];
    _waitingIndicatorView = nil;
}

#pragma mark - Indicator

- (void)showAutoDismissIndicatorWithError:(NSError *)error
{
    NSString *desc = [self _indicatorErrorTextFromError:error];
    
    if (!isEmptyString(desc)) {
        self.view.userInteractionEnabled = NO;
        [self showAutoDismissIndicatorWithText:desc];
    }
}

- (void)showAutoDismissIndicatorWithText:(NSString *)text
{
    self.view.userInteractionEnabled = NO;
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
}

- (NSString *)_indicatorErrorTextFromError:(NSError *)error
{
    if (!error) {
        return nil;
    }
    NSString *alertText = [error.userInfo valueForKey:@"alert_text"];
    
    if ([error.userInfo tt_intValueForKey:@"error_code"] == 1008) {
        return nil;
    }
    
    if (!isEmptyString(alertText)) {
        
        if ([alertText rangeOfString:@"是否找回密码"].location != NSNotFound) {
            __weak typeof(self) wself = self;
            TTAccountAlertView *alertView = [[TTAccountAlertView alloc] initWithTitle:alertText message:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES tapCompletion:^(TTAccountAlertCompletionEventType type) {
                if (type == TTAccountAlertCompletionEventTypeDone) {
                    TTAccountLoginQuickRetrieveViewController *viewController = [[TTAccountLoginQuickRetrieveViewController alloc] init];
                    viewController.mobileInput.field.text = self.mobileInput.field.text;
                    [wself.navigationController pushViewController:viewController animated:YES];
                }
            }];
            [alertView show];
            return nil;
        }
        
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:alertText message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert showFrom:self animated:YES];
        return nil;
    }
    NSString *desc = [error.userInfo valueForKey:@"message"];
    if (desc.length == 0) {
        desc = [error.userInfo valueForKey:@"description"];
    }
    if (desc.length == 0) {
        if (error.code == 1004) {
            desc = NSLocalizedString(@"该用户名已存在", nil);
        } else {
            desc = NSLocalizedString(@"发生了一些小意外，请稍后再试", nil);
        }
    }
    if (!TTNetworkConnected()) {
        desc = NSLocalizedString(@"网络不给力，请稍后重试", nil);
    } else if ([error.domain isEqualToString:@"NSURLErrorDomain"]) {
        if (desc.length == 0) {
            desc = NSLocalizedString(@"服务器不给力，请稍后重试", nil);
        }
    }
    if (desc.length == 0) {
        return nil;
    }
    return desc;
}

#pragma mark - Getter/Setter

- (UIBarButtonItem *)leftItem
{
    if (!_leftItem) {
        CGSize imageSize = CGSizeMake(16.f, 16.f);
        UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        customView.imageEdgeInsets = UIEdgeInsetsMake((40 - imageSize.height)/2, 0, (40 - imageSize.height)/2, (40 - imageSize.width));
        customView.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
        [customView setImage:[UIImage imageNamed:@"leftbackicon_sdk_login"]
                    forState:UIControlStateNormal];
        [customView addTarget:self
                       action:@selector(leftItemClicked)
             forControlEvents:UIControlEventTouchUpInside];
        _leftItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    }
    return _leftItem;
}

- (UIBarButtonItem *)closeItem
{
    if (!_closeItem) {
        CGSize imageSize = CGSizeMake(14.f, 14.f);
        UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        customView.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
        [customView setImage:[UIImage imageNamed:@"close_sdk_login"]
                    forState:UIControlStateNormal];
        [customView addTarget:self
                       action:@selector(rightItemClicked)
             forControlEvents:UIControlEventTouchUpInside];
        _closeItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    }
    return _closeItem;
}

- (SSThemedView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
        _backgroundView.backgroundColor = [UIColor whiteColor];
    }
    return _backgroundView;
}

- (SSThemedView *)upInfoContainerView
{
    if (!_upInfoContainerView) {
        _upInfoContainerView = [[SSThemedView alloc] initWithFrame:CGRectZero];
    }
    return _upInfoContainerView;
}

- (TTAccountLoginPlatformLoginView *)platformLoginView
{
    if (!_platformLoginView) {
        _platformLoginView = [[TTAccountLoginPlatformLoginView alloc] initWithFrame:self.view.bounds platformTypes:_types excludedPlatforms:_excludedPlatformNames];
        _platformLoginView.delegate = self;
        _platformLoginView.width = self.view.width;
        _platformLoginView.left = 0;
        _platformLoginView.bottom = self.view.height - kTTAccountLoginPlatformBottomMargin;
        
    }
    return _platformLoginView;
}

- (TTAccountLoginInputView *)mobileInput
{
    if (!_mobileInput) {
        _mobileInput = [[TTAccountLoginInputView alloc] initWithFrame:CGRectZero rightText:nil];
        _mobileInput.errorLabel.text = @"手机号错误";
    }
    return _mobileInput;
}

- (TTAccountLoginInputView *)captchaInput
{
    if (!_captchaInput) {
        _captchaInput = [[TTAccountLoginInputView alloc] initWithFrame:CGRectZero rightText:nil];
        _captchaInput.field.delegate = self;
        _captchaInput.errorLabel.text = @"验证码错误";
    }
    return _captchaInput;
}

- (SSThemedButton *)registerButton
{
    if (!_registerButton) {
        _registerButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [_registerButton setTitle:NSLocalizedString(@"快捷注册", nil)
                         forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton addTarget:self
                            action:@selector(registerButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
        _registerButton.titleLabel.font =
        [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:18]];
        _registerButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _registerButton.layer.cornerRadius = 21;
        _registerButton.layer.masksToBounds = YES;
        [_registerButton setBackgroundColor:[UIColor colorWithHexString:@"FF0031"]];
    }
    return _registerButton;
}

- (BOOL)registerButtonEnabled
{
    return [self isContentValid];
}

- (void)navigationBarTap:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}

@end

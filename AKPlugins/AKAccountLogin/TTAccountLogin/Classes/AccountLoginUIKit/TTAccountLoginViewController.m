//
//  TTAccountLoginViewController.m
//  TTAccountLogin
//
//  Created by huic on 16/3/9.
//
//

#import <TTLabelTextHelper.h>
#import <TTIndicatorView.h>
#import <TTUIResponderHelper.h>

#import "TTAccountLoginViewController.h"
#import "TTAccountNavigationController.h"
#import "TTAccountLoginEditProfileViewController.h"
#import "TTAccountLoginQuickRetrieveViewController.h"
#import "TTAccountAlertView.h"
#import "TTAccountLoginAlert.h"
#import "TTAccountLoginManager.h"
#import "TTUserPrivacyView.h"
#import "TTSandBoxHelper.h"
#import <BDAccountSDK.h>
#import <BDAccount+NetworkAPI.h>

#define DEVICE_SYS_FLOAT_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])

#define IS_IOS_8_LATER (DEVICE_SYS_FLOAT_VERSION >= 8.0)

NSString * const TTForceToDismissLoginViewControllerNotification = @"TTForceToDismissLoginViewControllerNotification";

// 记录上次选择的登录方式
static TTAccountLoginStyle s_preLoginStyle = 0;

@interface TTAccountLoginViewController ()
@property (nonatomic, strong) SSThemedLabel *upTipLabel; //上方注册提示文案
@property (nonatomic, strong) TTAlphaThemedButton *upInfoButton;
@property (nonatomic, strong) SSThemedLabel *upInfoLabel;
@property (nonatomic, strong) SSThemedLabel *loginTipLabel;
@property (nonatomic, strong) SSThemedLabel *emailFindPasswordTipLabel;
@property (nonatomic, strong) SSThemedButton *switchButton;
@property (nonatomic, strong) TTUserPrivacyView *privacyView;

@property (nonatomic,   copy) NSString *title;
@property (nonatomic,   copy) NSString *thirdPartySource;
@property (nonatomic,   copy) NSString *nonThirdPartySource; //验证码或者密码登录方式
@property (nonatomic, assign) TTAccountLoginStyle loginStyle;
@end

@implementation TTAccountLoginViewController

@synthesize title  = _title;
@synthesize source = _source;

- (instancetype)initWithTitle:(NSString *)title source:(NSString *)source
{
    return [self initWithTitle:title source:source isPasswordLogin:YES];
}

- (instancetype)initWithTitle:(NSString *)title source:(NSString *)source isPasswordLogin:(BOOL)passwordLoginStyle
{
    if (self = [super initWithTitle:title source:source]) {
        _title  = title;
        _source = !isEmptyString(source) ? source : @"other";
        _loginStyle = passwordLoginStyle ? TTAccountLoginStylePassword : TTAccountLoginStyleCaptcha;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnableReceiveDismissNotification" object:nil userInfo:@{@"enable": @(1)}];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)source
{
    if (isEmptyString(_source)) {
        _source = @"other";
    }
    return _source;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
    [self refreshSubviews];
    
    if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        [self mobilePageShowStatistics];
    } else if (self.loginStyle == TTAccountLoginStylePassword) {
        [self passwordPageShowStatistics];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissMyself:)
                                                 name:TTForceToDismissLoginViewControllerNotification
                                               object:nil];
}

- (BOOL)__isBeingPresentedModally__
{
    // Check if we have a parent navigation controller, it's being presented modally,
    // and if it is, that we are its root view controller
    if (self.navigationController && self.navigationController.presentingViewController)
        return ([self.navigationController.viewControllers indexOfObject:self] == 0);
    else // Check if we're being presented modally directly
        return ([self presentingViewController] != nil);
    return NO;
}

- (void)dismissMyself:(NSNotification *)note
{
    BOOL animated = YES;
    NSNumber *animatedNumber = note.userInfo[@"animated"];
    if (animatedNumber && [animatedNumber respondsToSelector:@selector(boolValue)]) {
        animated = [animatedNumber boolValue];
    }
    if ([self __isBeingPresentedModally__]) {
        [self dismissViewControllerAnimated:animated completion:^{
            
        }];
    } else {
        [self.navigationController popViewControllerAnimated:animated];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 内测版保持原有的statusBarStyle
    if (TTAccountLoginPlatformTypeInHouseOnly == [TTAccountLoginConfLogic loginPlatforms]) {
        self.ttStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnableReceiveDismissNotification" object:nil userInfo:@{@"enable": @(0)}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self doIfShowPlatformsTracker];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (isEmptyString(self.thirdPartySource) && isEmptyString(self.nonThirdPartySource)) {
        // 判断是[短信验证码登录页] 还是 [账号密码登录页] 的关闭
        if (self.loginStyle == TTAccountLoginStyleCaptcha) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_close" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [TTTrackerWrapper eventV3:@"login_mobile_close" params:extraDict isDoubleSending:YES];
        } else if (self.loginStyle == TTAccountLoginStylePassword) {
            // 如果是帐号密码登录页的关闭
            
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"password_login_close" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [TTTrackerWrapper eventV3:@"login_password_close" params:extraDict isDoubleSending:YES];
        } else if (self.loginStyle == TTAccountLoginStyleEmail) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [TTTrackerWrapper eventV3:@"login_email_close" params:extraDict isDoubleSending:YES];
        }
    }
}

#pragma mark - init

- (void)initSubviews
{
    //取消返回键
    self.navigationItem.leftBarButtonItem = self.closeItem;
    self.navigationItem.rightBarButtonItem = nil;
    
    //注册页顶部添加提示文案
    [self.view addSubview:self.upTipLabel];
    
    //登录页顶部增加提示Label
    [self.view addSubview:self.upInfoLabel];
    
    //中部新增登录提示Label
    [self.view addSubview:self.loginTipLabel];
    
    //中部新增切换登录方式
    [self.view addSubview:self.switchButton];
    
    //增加找回密码提示的Label
    [self.view addSubview:self.emailFindPasswordTipLabel];
    
    // 用户隐私条款
    [self.view addSubview:self.privacyView];
    
    self.mobileInput.field.placeholder = NSLocalizedString(@"手机号", nil);
    self.mobileInput.field.delegate = self;
    self.mobileInput.field.delegate = self;
    
    [self.mobileInput.resendButton addTarget:self action:@selector(resendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.captchaInput.resendButton addTarget:self action:@selector(resendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerButton setTitle:[TTAccountLoginConfLogic quickRegisterButtonText]
                         forState:UIControlStateNormal];
}

#pragma mark - layout

- (void)refreshSubviews
{
    [self refreshRegisterButton];
    
    if (!isEmptyString(self.captchaInput.field.text)) {
        self.captchaInput.field.text = nil;
    }
    
    if (s_preLoginStyle == TTAccountLoginStyleEmail || self.loginStyle == TTAccountLoginStyleEmail) {
        self.mobileInput.field.text = nil;
    }
    
    _switchButton.hidden = YES;
    _upTipLabel.hidden = YES;
    _upInfoLabel.hidden = YES;
    _loginTipLabel.hidden = YES;
    _emailFindPasswordTipLabel.hidden = YES;
    
    if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        //验证码登录
//        _switchButton.hidden = NO;
        _upTipLabel.hidden = NO;
        [_switchButton setTitle:NSLocalizedString(@"账号密码登录", nil) forState:UIControlStateNormal];
        self.mobileInput.field.placeholder = NSLocalizedString(@"手机号", nil);
        self.captchaInput.field.placeholder = NSLocalizedString(@"请输入验证码", nil);
        self.captchaInput.field.secureTextEntry = NO;
        // self.captchaInput.field.keyboardType = UIKeyboardTypeDefault;
        // 输入验证码时，键盘为数字键盘
        [self.captchaInput.field resignFirstResponder];
        self.captchaInput.field.keyboardType = UIKeyboardTypeNumberPad;
        if (!isEmptyString(self.mobileInput.field.text)) {
            [self.captchaInput.field becomeFirstResponder];
        }
        self.mobileInput.field.keyboardType = UIKeyboardTypePhonePad;
        self.mobileInput.field.rightViewMode = UITextFieldViewModeAlways;
        self.captchaInput.field.rightViewMode = UITextFieldViewModeNever;
        self.loginTipLabel.hidden = NO;
    }
    if (self.loginStyle == TTAccountLoginStylePassword) {
        //密码登录
//        _switchButton.hidden = NO;
        _upInfoLabel.hidden = NO;
        _upInfoLabel.text = NSLocalizedString(@"账号密码登录", nil);
        [_switchButton setTitle:NSLocalizedString(@"免密码登录", nil) forState:UIControlStateNormal];
        self.mobileInput.field.placeholder = NSLocalizedString(@"手机号", nil);
        self.captchaInput.field.placeholder = NSLocalizedString(@"密码", nil);
        self.captchaInput.field.secureTextEntry = YES;
        // 输入密码时，键盘为字母键盘
        [self.captchaInput.field resignFirstResponder];
        self.captchaInput.field.keyboardType = UIKeyboardTypeDefault;
        if (!isEmptyString(self.mobileInput.field.text)) {
            [self.captchaInput.field becomeFirstResponder];
        }
        self.mobileInput.field.keyboardType = UIKeyboardTypePhonePad;
        self.mobileInput.field.rightViewMode = UITextFieldViewModeNever;
        self.captchaInput.field.rightViewMode = UITextFieldViewModeAlways;
    }
    
    self.mobileInput.errorLabel.text = @"手机号错误";
    
    if (self.loginStyle == TTAccountLoginStyleEmail) {
        [self.mobileInput recover];
        [self.captchaInput recover];
        _upInfoLabel.hidden = NO;
        _emailFindPasswordTipLabel.hidden = NO;
        _upInfoLabel.text = NSLocalizedString(@"邮箱登录", nil);
        self.mobileInput.errorLabel.text = @"邮箱错误";
        self.mobileInput.field.keyboardType = UIKeyboardTypeEmailAddress;
        self.mobileInput.field.spellCheckingType = UITextSpellCheckingTypeNo;
        self.mobileInput.field.autocorrectionType = UITextAutocorrectionTypeNo;
        self.mobileInput.field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.mobileInput.field.returnKeyType = UIReturnKeyNext;
        self.mobileInput.field.enablesReturnKeyAutomatically = YES;
        self.mobileInput.field.placeholder  = NSLocalizedString(@"邮箱账号", nil);
        self.captchaInput.field.placeholder = NSLocalizedString(@"密码", nil);
        self.captchaInput.field.secureTextEntry = YES;
        [self.captchaInput.field resignFirstResponder];
        self.captchaInput.field.keyboardType  = UIKeyboardTypeDefault;
        self.mobileInput.field.rightViewMode  = UITextFieldViewModeNever;
        self.captchaInput.field.rightViewMode = UITextFieldViewModeNever;
    }
    
    [self.mobileInput.errorLabel sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //上方图片布局
    [_upTipLabel sizeToFit];
    _upTipLabel.bottom = self.upInfoContainerView.height;
    _upTipLabel.centerX = self.upInfoContainerView.centerX;
    
    [_upInfoLabel sizeToFit];
    _upInfoLabel.centerX = self.view.centerX;
    _upInfoLabel.bottom = self.upInfoContainerView.bottom;
    
    //验证码TextField布局
    self.captchaInput.size = CGSizeMake(self.view.width - kTTAccountLoginInputFieldLeftMargin - kTTAccountLoginInputFieldRightMargin, kTTAccountLoginInputFieldHeight);
    self.captchaInput.top = self.mobileInput.bottom + kTTAccountLoginInputFieldVerticalMargin;
    self.captchaInput.left = kTTAccountLoginInputFieldLeftMargin;
    
    //验证登录按钮布局
    self.registerButton.size = CGSizeMake(self.view.width - kTTAccountLoginInputFieldLeftMargin - kTTAccountLoginInputFieldRightMargin, 42);
    self.registerButton.top = self.captchaInput.bottom + 40;
    self.registerButton.left = kTTAccountLoginInputFieldLeftMargin;
    
    //未注册提示布局
    _loginTipLabel.top = self.registerButton.bottom + 15;
    _loginTipLabel.centerX = self.view.centerX;
    
    _privacyView.bottom = self.view.height - self.view.tt_safeAreaInsets.bottom - 20;
    _privacyView.centerX = self.view.centerX;
    self.platformLoginView.bottom = _privacyView.top;
    //切换登录方式布局
    _switchButton.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:@"ak_hidden_login_switch_button"];
    [_switchButton sizeToFit];
    _switchButton.centerX = self.view.centerX;
    _switchButton.top = self.registerButton.bottom + 60;
    
    //邮箱登录找回密码提示Label
    _emailFindPasswordTipLabel.centerX = self.view.centerX;
    _emailFindPasswordTipLabel.top = _switchButton.top;
    
    [self fitResendView];
}

- (void)fitResendView
{
    self.mobileInput.resendButton.enabled = NO;
    self.captchaInput.resendButton.enabled = self.resendButtonEnabled;
    
    NSString *resendTitle;
    if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        resendTitle = self.resendButtonEnabled ? @"获取验证码": [NSString stringWithFormat:@"重新发送(%ldS)",(long)self.countdown];
        [self.captchaInput updateRightText:NSLocalizedString(resendTitle, nil)];
    } else if (self.loginStyle == TTAccountLoginStylePassword) {
        resendTitle = @"找回密码";
        self.resendButtonEnabled = YES;
        [self.captchaInput updateRightText:NSLocalizedString(resendTitle, nil)];
    }
}

#pragma mark - Action

- (void)rightItemClicked
{
    [self.view endEditing:YES];
    
    //开始填写信息后点击关闭，弹出Alert提示
    if (!isEmptyString(self.captchaInput.field.text) || !isEmptyString(self.mobileInput.field.text)) {
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTracker category:@"umeng" event:@"register_new" label:@"cancel_register_dialog_show" dict:@{@"source":self.source}];
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [TTTrackerWrapper eventV3:@"login_cancel_register_show" params:extraDict isDoubleSending:YES];
        
        TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"确认放弃登录?", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
        WeakSelf;
        [alertController addActionWithTitle:NSLocalizedString(@"放弃", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            StrongSelf;
            //放弃注册
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"cancel_register_click_confirm" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"confirm" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_cancel_register_click" params:extraDict isDoubleSending:YES];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addActionWithTitle:NSLocalizedString(@"继续登录", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            //继续注册流程
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"cancel_register_click_continue" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"continue" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_cancel_register_click" params:extraDict isDoubleSending:YES];
        }];
        [alertController showFrom:self animated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)switchButtonClicked:(id)sender
{
    if (sender) {
        if (self.loginStyle == TTAccountLoginStyleEmail) {
            _loginStyle = s_preLoginStyle;
            s_preLoginStyle = TTAccountLoginStyleEmail;
        } else {
            self.loginStyle = !self.loginStyle;
            s_preLoginStyle = !self.loginStyle;
        }
    } else {
        s_preLoginStyle = self.loginStyle;
        _loginStyle = TTAccountLoginStyleEmail;
    }
    
    if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        // 在 [账号密码登录页] 点击switchButton后切换到 [账号短信验证码页], 记录该点击量
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTracker category:@"umeng" event:@"register_new" label:@"password_login_to_mobile" dict:@{@"source":self.source}];
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"to_mobile" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict isDoubleSending:YES];
        
        // unused
        // if (![SSCommonLogic quickLoginSwitch]) {
        //     [self tt_performSelector:@selector(mobilePageShowStatistics) onlyOnceInSelector:_cmd];
        // }
        
        //账号密码登录页切换到快捷注册页
    } else if (self.loginStyle == TTAccountLoginStylePassword) {
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_to_password" dict:@{@"source":self.source}];
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"to_password" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict isDoubleSending:YES];
        
        //快捷注册页面点击使用账号密码注册
        // unused
        // if ([SSCommonLogic quickLoginSwitch]) {
        //     [self tt_performSelector:@selector(passwordPageShowStatistics) onlyOnceInSelector:_cmd];
        // }
        
        // 清空计时器
        if (self.timer) {
            self.timer = nil;
            [self.timer invalidate];
        }
        self.countdown = 0;
    }
    
    // 上报是否显示平台埋点
    [self doIfShowPlatformsTracker];
    
    [self refreshSubviews];
    [self layoutSubviews];
}

- (void)mobilePageShowStatistics
{
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_show" dict:@{@"source":self.source}];
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:self.source forKey:@"source"];
    [TTTrackerWrapper eventV3:@"login_mobile_show" params:extraDict isDoubleSending:YES];
}

- (void)passwordPageShowStatistics
{
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTracker category:@"umeng" event:@"register_new" label:@"password_login_show" dict:@{@"source":self.source}];
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:self.source forKey:@"source"];
    [TTTrackerWrapper eventV3:@"login_password_show" params:extraDict isDoubleSending:YES];
}

- (void)resendButtonClicked:(id)sender
{
    __weak typeof(self) weakSelf = self;
    if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_send_auth" dict:@{@"source":self.source}];
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"send_auth" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict isDoubleSending:YES];
        
        //手机号格式错误
        if (isEmptyString(self.mobileInput.field.text) || ![self validateMobileNumber:self.mobileInput.field.text]) {
            [self.mobileInput showError];
            return;
        }
        //获取验证码
        //注册/绑定点重发验证码（倒计时阶段点击不算）
        [weakSelf sendCode:TTASMSCodeScenarioQuickLoginRetry];
        
    } else if (self.loginStyle == TTAccountLoginStylePassword) {
        //账号密码登录页点忘记密码
        //跳转至找回密码
        TTAccountLoginQuickRetrieveViewController *viewController = [[TTAccountLoginQuickRetrieveViewController alloc] init];
        viewController.mobileInput.field.text = self.mobileInput.field.text;
        [self.navigationController pushViewController:viewController animated:YES];
        
        // 进入 [账号密码登录页]后，点击"找回密码量"
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTracker category:@"umeng" event:@"register_new" label:@"click_find_password" dict:@{@"source":self.source}];
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"find_password" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict isDoubleSending:YES];
    }
}

- (void)emailButtonClick:(UIButton *)sender
{
    [self switchButtonClicked:nil];
}

- (void)sendCode:(TTASMSCodeScenarioType)scenarioType
{
    __weak typeof(self) wself = self;
    [wself showWaitingIndicator];
    [BDAccount requestSMSCodeWithMobile:self.mobileInput.field.text SMSCodeType:BDAccountSMSCodeTypeMobileSMSCodeLogin unbindExisted:NO completion:^(NSNumber * _Nullable retryTime, UIImage * _Nonnull captchaImage, NSError * _Nullable error) {

        if (!error) {
            [wself startTimer];
            [wself dismissWaitingIndicator];
            TTIndicatorView *indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"已发送验证码", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] dismissHandler:nil];
            indicatorView.autoDismiss = YES;
            [indicatorView showFromParentView:self.view];
        } else {
            if (captchaImage) {
                TTAccountCaptchaAlert *cAlert = [[TTAccountCaptchaAlert alloc] initWithTitle:@"请输入图片中的字符" captchaImage:captchaImage placeholder:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString *captchaStr) {
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        [wself showWaitingIndicator];
                        wself.captchaString = captchaStr;
                        [wself sendCode:scenarioType];
                    } else {
                        [wself dismissWaitingIndicator];
                    }
                }];
                [wself dismissWaitingIndicator];
                [cAlert show];
            } else {
                NSString *hintText = [error.userInfo tt_stringValueForKey:@"description"];
                if (isEmptyString(hintText)) {
                    hintText = NSLocalizedString(@"发送失败，请稍后重试", nil);
                }
                [wself dismissWaitingIndicatorWithText:hintText];
            }
        }
    }];
}

- (void)quickLogin
{
    [self showWaitingIndicator];
    
    __weak typeof(self) wself = self;

    [BDAccount requestQuickLoginWithMobile:self.mobileInput.field.text SMSCode:self.captchaInput.field.text completion:^(NSError * _Nullable error) {

        if (!error) {
            
            [TTAccountLoginManager setDefaultLoginUIStyleFor:TTAccountLoginStyleCaptcha];
            
            BOOL isNewUser = [[BDAccount sharedAccount] user].newUser;
            
            [[TTMonitor shareManager] trackService:@"account_mobile_quick_login" status:1 extra:nil];
            wself.nonThirdPartySource = @"mobile";
            
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_success" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"mobile" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_mobile_success" params:extraDict isDoubleSending:YES];
            
            if (wself.subscribeCompletionHandler) {
                wself.subscribeState = TTAccountLoginStateLogin;
            }
            if (wself.loginCompletionHandler) {
                wself.loginState = TTAccountLoginStateLogin;
            }
            
//            if (isNewUser) {
//                [wself dismissWaitingIndicator];
//                TTAccountLoginEditProfileViewController *userInfoVC = [[TTAccountLoginEditProfileViewController alloc] initWithSource:self.source];
//                // 设置新用户信息
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": @"phoneNumber"}];
//                [wself.navigationController pushViewController:userInfoVC animated:YES];
//                return;
//            }
            // 验证码正确注册成功
            [wself dismissWaitingIndicatorWithText:NSLocalizedString(@"登录成功", nil)];
            
            if (IS_IOS_8_LATER) {
                if (wself.subscribeCompletionHandler) {
                    wself.subscribeCompletionHandler(TTAccountLoginStateLogin);
                }
                
                [wself dismissViewControllerAnimated:YES completion:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": @"phoneNumber"}];
            } else {
                [wself dismissViewControllerAnimated:YES completion:^{
                    
                    if (wself.subscribeCompletionHandler) {
                        wself.subscribeCompletionHandler(TTAccountLoginStateLogin);
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": @"phoneNumber"}];
                    });
                }];
            }
        } else {
            // 验证码注册错误
            // 出现验证码错误时，隐藏“未注册。。。”
            _loginTipLabel.text = @"";
            
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:error.description forKey:@"error_description"];
            [extra setValue:@(error.code) forKey:@"error_code"];
            
//            if (captchaImage) {
//                [[TTMonitor shareManager] trackService:@"account_mobile_quick_login" status:2 extra:extra];
//
//                TTAccountCaptchaAlert *cAlert = [[TTAccountCaptchaAlert alloc] initWithTitle:@"请输入图片中的字符" captchaImage:captchaImage placeholder:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString *captchaStr) {
//
//                    if (type == TTAccountAlertCompletionEventTypeDone) {
//                        [wself showWaitingIndicator];
//                        wself.captchaString = captchaStr;
//                        [wself quickLogin];
//                    } else {
//                        [wself dismissWaitingIndicator];
//                    }
//                }];
//                [wself dismissWaitingIndicator];
//                [cAlert show];
//            } else {
                [[TTMonitor shareManager] trackService:@"account_mobile_quick_login" status:3 extra:extra];
                [wself monitorUserLoginFailureWithError:error status:1];
                
                [wself dismissWaitingIndicator];
                [wself.captchaInput showError];
                wself.loginTipLabel.hidden = YES;
//            }
        }
    }];
}

- (void)loginWithPassword
{
    __weak typeof(self) wself = self;
    [wself showWaitingIndicator];
    
    [TTAccount loginWithPhone:self.mobileInput.field.text password:self.captchaInput.field.text captcha:self.captchaString completion:^(UIImage *captchaImage, NSError *error) {
        
        if (!error) {
            
            [TTAccountLoginManager setDefaultLoginUIStyleFor:TTAccountLoginStylePassword];
            
            [[TTMonitor shareManager] trackService:@"account_mobile_login" status:1 extra:nil];
            self.nonThirdPartySource = @"password";
            // 在［账号密码登录页］，使用密码登录验证后，成功授权的账号量
            
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"password_login_success" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"password" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_password_success" params:extraDict isDoubleSending:YES];
            
            [self dismissWaitingIndicatorWithText:NSLocalizedString(@"登录成功", nil)];
            
            if (self.subscribeCompletionHandler) {
                self.subscribeState = TTAccountLoginStateLogin;
            }
            if (self.loginCompletionHandler) {
                self.loginState = TTAccountLoginStateLogin;
            }
            
            if (IS_IOS_8_LATER) {
                if (self.subscribeCompletionHandler) {
                    self.subscribeCompletionHandler(TTAccountLoginStateLogin);
                }
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": @"phoneNumber"}];
            } else {
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    if (self.subscribeCompletionHandler) {
                        self.subscribeCompletionHandler(TTAccountLoginStateLogin);
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": @"phoneNumber"}];
                    });
                }];
            }
        } else {
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:error.description forKey:@"error_description"];
            [extra setValue:@(error.code) forKey:@"error_code"];
            
            if (captchaImage) {
                [[TTMonitor shareManager] trackService:@"account_mobile_login" status:2 extra:extra];
                
                TTAccountCaptchaAlert *cAlert = [[TTAccountCaptchaAlert alloc] initWithTitle:@"请输入图片中的字符" captchaImage:captchaImage placeholder:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString *captchaStr) {
                    
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        [wself showWaitingIndicator];
                        wself.captchaString = captchaStr;
                        [wself loginWithPassword];
                    } else {
                        [wself dismissWaitingIndicator];
                    }
                }];
                [wself dismissWaitingIndicator];
                [cAlert show];
            } else {
                [[TTMonitor shareManager] trackService:@"account_mobile_login" status:3 extra:extra];
                [wself monitorUserLoginFailureWithError:error status:2];
                [wself dismissWaitingIndicatorWithError:error];
            }
        }
    }];
}

- (void)loginWithMail
{
    WeakSelf;
    [self showWaitingIndicator];
    
    [TTAccount loginWithEmail:self.mobileInput.field.text password:self.captchaInput.field.text captcha:self.captchaString completion:^(UIImage *captchaImage, NSError *error) {
        
        if (!error) {
            [[TTMonitor shareManager] trackService:@"account_email_login" status:1 extra:nil];
            self.nonThirdPartySource = @"password";
            // 在［账号密码登录页］，使用密码登录验证后，成功授权的账号量
            
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"email_login_success" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"email" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_email_success" params:extraDict isDoubleSending:YES];
            
            [self dismissWaitingIndicatorWithText:NSLocalizedString(@"登录成功", nil)];
            
            if (self.subscribeCompletionHandler) {
                self.subscribeState = TTAccountLoginStateLogin;
            }
            if (self.loginCompletionHandler) {
                self.loginState = TTAccountLoginStateLogin;
            }
            
            if (IS_IOS_8_LATER) {
                if (self.subscribeCompletionHandler) {
                    self.subscribeCompletionHandler(TTAccountLoginStateLogin);
                }
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": @"phoneNumber"}];
            } else {
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    if (self.subscribeCompletionHandler) {
                        self.subscribeCompletionHandler(TTAccountLoginStateLogin);
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": @"mail"}];
                    });
                }];
            }
            
        } else {
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:error.description forKey:@"error_description"];
            [extra setValue:@(error.code) forKey:@"error_code"];
            
            if (captchaImage) {
                [[TTMonitor shareManager] trackService:@"account_email_login" status:2 extra:extra];
                
                TTAccountCaptchaAlert *cAlert = [[TTAccountCaptchaAlert alloc] initWithTitle:@"请输入图片中的字符" captchaImage:captchaImage placeholder:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString *captchaStr) {
                    
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        [wself showWaitingIndicator];
                        wself.captchaString = captchaStr;
                        [wself loginWithMail];
                    } else {
                        [wself dismissWaitingIndicator];
                    }
                }];
                [wself dismissWaitingIndicator];
                [cAlert show];
            } else {
                [[TTMonitor shareManager] trackService:@"account_email_login" status:3 extra:extra];
                [wself monitorUserLoginFailureWithError:error status:3];
                [wself dismissWaitingIndicatorWithError:error];
            }
        }
    }];
}

/**
 监控用户登录失败方法
 
 @param error 失败的error
 @param status 1 代表验证码登录失败，2代表密码登录失败，3 代表邮件登录失败
 */
- (void)monitorUserLoginFailureWithError:(NSError *)error status:(NSInteger)status
{
    if (!error) return;
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    if (!isEmptyString(error.description)) {
        [extra setValue:error.description forKey:@"error_description"];
    }
    [extra setValue:@(error.code) forKey:@"error_code"];
    
    NSDictionary * (^appRequiredParamsHandler)(void) = [TTAccount accountConf].appRequiredParamsHandler;
    NSDictionary *requiredParams = appRequiredParamsHandler ? appRequiredParamsHandler() : nil;
    NSString *deviceID = [requiredParams valueForKey:TTAccountDeviceIdKey];
    if (!isEmptyString(deviceID)) {
        [extra setObject:deviceID forKey:@"device_id"];
    }
    
    [[TTMonitor shareManager] trackService:@"account_ihone_login" status:status extra:extra];
}

- (void)registerButtonClicked:(id)sender
{
    if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_click_confirm" dict:@{@"source":self.source}];
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"confirm" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict isDoubleSending:YES];
    } else if (self.loginStyle == TTAccountLoginStylePassword) {
        // 进入[账号密码登录页] 点击 “进入头条量”
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTracker category:@"umeng" event:@"register_new" label:@"password_login_click_confirm" dict:@{@"source":self.source}];
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"confirm" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict isDoubleSending:YES];
    } else if (self.loginStyle == TTAccountLoginStyleEmail) {
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"confirm" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_email_click" params:extraDict isDoubleSending:YES];
    }
    
    //本地检测不合法
    if (![self isContentValid]) {
        //快捷登录
        if (self.loginStyle == TTAccountLoginStyleCaptcha) {
            //未填写手机号
            if (self.mobileInput.field.text.length == 0) {
                [self.mobileInput showError];
                return;
            }
            
            //手机号输入错误
            if (![self validateMobileNumber:self.mobileInput.field.text]) {
                [self.mobileInput showError];
                return;
            }
            //未输入验证码点注册
            if (![self isVerifyWordOrPassWordValid]) {
                self.captchaInput.errorLabel.text = (self.loginStyle == TTAccountLoginStyleCaptcha ? @"验证码错误" : @"密码错误");
                [self.captchaInput showError];
                self.loginTipLabel.hidden = YES;
                return;
            }
        } //账号密码登录
        else if (self.loginStyle == TTAccountLoginStylePassword) {
            //未填写手机号
            if (self.mobileInput.field.text.length == 0) {
                [self.mobileInput showError];
                return;
            }
            
            //手机号输入错误
            if (![self validateMobileNumber:self.mobileInput.field.text]) {
                [self.mobileInput showError];
                return;
            }
            //未输入验证码点注册
            if (![self isVerifyWordOrPassWordValid]) {
                self.captchaInput.errorLabel.text = (self.loginStyle == TTAccountLoginStyleCaptcha ? @"验证码错误" : @"密码错误");
                [self.captchaInput showError];
                self.loginTipLabel.hidden = YES;
                return;
            }
        } else if (self.loginStyle == TTAccountLoginStyleEmail) {
            
            //未填写邮箱
            if (self.mobileInput.field.text.length == 0) {
                [self.mobileInput showError];
                return;
            }
            
            //邮箱输入错误
            if (![self validateMobileNumber:self.mobileInput.field.text]) {
                [self.mobileInput showError];
                return;
            }
            
            //密码位数不够
            if (![self isVerifyWordOrPassWordValid]) {
                self.captchaInput.errorLabel.text =  @"密码错误";
                [self.captchaInput showError];
                self.loginTipLabel.hidden = YES;
                return;
            }
        }
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"信息填写不全", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
//    if (![_privacyView isChecked]) {
//        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"尚未同意“用户协议和隐私条款“", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
//        return;
//    }
    
    if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        [self quickLogin];
    } else if (self.loginStyle == TTAccountLoginStylePassword) {
        [self loginWithPassword];
    } else if (self.loginStyle == TTAccountLoginStyleEmail) {
        [self loginWithMail];
    }
}

- (void)loginPlatform:(NSString *)keyName
{
    if ([keyName isEqualToString:TT_LOGIN_PLATFORM_EMAIL]) {
        if (self.loginStyle != TTAccountLoginStyleEmail) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"email_login_click" dict:@{@"source":self.source}];
            }
            
            // LogV3
            if (self.loginStyle == TTAccountLoginStyleCaptcha) {
                NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
                [extraDict setValue:self.source forKey:@"source"];
                [extraDict setValue:@"email" forKey:@"action_type"];
                [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict isDoubleSending:YES];
            } else if (self.loginStyle == TTAccountLoginStylePassword) {
                NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
                [extraDict setValue:self.source forKey:@"source"];
                [extraDict setValue:@"email" forKey:@"action_type"];
                [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict isDoubleSending:YES];
            }
            
            [self switchButtonClicked:nil];
        }
    } else {
        [self uMengPlatform:keyName];
        
        [TTAccountLoginManager requestLoginPlatformByName:keyName completion:^(BOOL success, NSError *error) {
            
            [self respondsToAccountAuthLoginWithError:error forPlatform:keyName];
            
            if (success) {
                [TTAccountLoginManager setDefaultLoginUIStyleFor:TTAccountLoginStyleCaptcha];
            }
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(NSNotification *)notification
{
    // 当文本内容出现变化时，loginTipLabel会显示内容
    self.loginTipLabel.text = NSLocalizedString(@"未注册手机验证后自动登录",nil);
    if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        self.loginTipLabel.hidden = NO;
    }
    
    [self.mobileInput recover];
    [self.captchaInput recover];
    [self refreshRegisterButton];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.captchaInput.field) {
        if (![self validateMobileNumber:self.mobileInput.field.text]) {
            [self.mobileInput showError];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.captchaInput.field) {
        [self registerButtonClicked:nil];
    } else {
        if (self.loginStyle == TTAccountLoginStyleEmail) {
            [self.captchaInput.field becomeFirstResponder];
        }
    }
    return YES;
}

#pragma mark - overrides

- (BOOL)isContentValid
{
    return (self.mobileInput.field.text.length > 0 && [self validateMobileNumber:self.mobileInput.field.text] && [self isVerifyWordOrPassWordValid]);
}

- (void)respondsToAccountAuthLoginWithError:(NSError *)error forPlatform:(NSString *)platformName
{
    if (self.loginState == TTAccountLoginStateLogin) return;
    if (self.subscribeState == TTAccountLoginStateLogin) return;
    
    if (!error) {
        self.loginState = TTAccountLoginStateLogin;
        self.subscribeState = TTAccountLoginStateLogin;
        
        [self trackLoginSuccessByThirdPartyPlatform:platformName];
        
        BOOL isNewUser = [[BDAccount sharedAccount] user].newUser;
        if (isNewUser) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": platformName ? : @""}];
            });
            
            TTAccountLoginEditProfileViewController *loginEditUserInfoVC = [[TTAccountLoginEditProfileViewController alloc] initWithSource:self.source];
            // 设置新用户信息
            [self.navigationController pushViewController:loginEditUserInfoVC animated:YES];
            return;
        }
    }
    
    [self didReceiveAccountLoginSuccess:(!error ? YES : NO) withPlatform:platformName];
}

- (void)didReceiveAccountLoginSuccess:(BOOL)success withPlatform:(NSString *)platformName
{
    if (success) {
        [self dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": platformName ? : @""}];
            });
        }];
    }
}

#pragma mark - tracker

- (void)doIfShowPlatformsTracker
{
    NSString *showLoginStyleString = nil;
    if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        showLoginStyleString = @"login_mobile_show";
    } else if (self.loginStyle == TTAccountLoginStylePassword) {
        showLoginStyleString = @"login_password_show";
    } else if (self.loginStyle == TTAccountLoginStyleEmail) {
        showLoginStyleString = @"login_email_show";
    }
    if (!showLoginStyleString) return;
    
    // 是否显示火山和抖音埋点
    if ([self.platformLoginView isShowingForPlatform:TT_LOGIN_PLATFORM_HUOSHAN]) {
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"1" forKey:@"hotsoon_login_show"];
        [TTTrackerWrapper eventV3:showLoginStyleString params:extraDict];
    }
    if ([self.platformLoginView isShowingForPlatform:TT_LOGIN_PLATFORM_DOUYIN]) {
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"1" forKey:@"douyin_login_show"];
        [TTTrackerWrapper eventV3:showLoginStyleString params:extraDict];
    }
}

- (void)trackLoginSuccessByThirdPartyPlatform:(NSString *)platformName
{
    // LogV1
    [TTTracker category:@"umeng" event:@"register_new" label:self.thirdPartySource dict:@{@"source":self.source}];
    // LogV3
    NSString *loginStyleEventString = nil;
    if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        loginStyleEventString = @"login_mobile_success";
    } else if (self.loginStyle == TTAccountLoginStylePassword) {
        loginStyleEventString = @"login_password_success";
    } else if (self.loginStyle == TTAccountLoginStyleEmail) {
        loginStyleEventString = @"login_email_success";
    }
    
    BOOL isDoubleSending = YES;
    NSString *platformLogString = nil;
    switch ([TTAccount accountAuthTypeForPlatform:platformName]) {
        case TTAccountAuthTypeWeChat: {
            platformLogString = @"weixin";
        }
            break;
        case TTAccountAuthTypeTencentQQ: {
            platformLogString = @"qq";
        }
            break;
        case TTAccountAuthTypeSinaWeibo: {
            platformLogString = @"sinaweibo";
        }
            break;
        case TTAccountAuthTypeTianYi: {
            platformLogString = @"telecom";
        }
            break;
        case TTAccountAuthTypeTencentWB: {
            platformLogString = @"qqweibo";
        }
            break;
        case TTAccountAuthTypeRenRen: {
            platformLogString = @"renren";
        }
            break;
        case TTAccountAuthTypeHuoshan: {
            platformLogString = @"hotsoon";
            isDoubleSending = NO;
        }
            break;
        case TTAccountAuthTypeDouyin: {
            platformLogString = @"douyin";
            isDoubleSending = NO;
        }
            break;
        default:
            break;
    }
    if (loginStyleEventString) {
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:platformLogString forKey:@"type"];
        if (isDoubleSending) {
            [TTTrackerWrapper eventV3:loginStyleEventString params:extraDict isDoubleSending:isDoubleSending];
        } else {
            [TTTrackerWrapper eventV3:loginStyleEventString params:extraDict];
        }
    }
}

- (NSString *)_indicatorErrorTextFromError:(NSError *)error
{
    if (!error) {
        return nil;
    }
    
    NSInteger errorCode = [error.userInfo tt_intValueForKey:@"error_code"];
    
    if (self.loginStyle == TTAccountLoginStyleEmail && errorCode == TTAccountLoginErrorCodePasswordWrong) {
        //发一个埋点
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTracker category:@"umeng" event:@"register_new" label:@"email_password_error" dict:@{@"source":self.source}];
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [TTTrackerWrapper eventV3:@"login_email_fail" params:extraDict isDoubleSending:YES];
    }
    
    if (errorCode == TTAccountLoginErrorCodeNotExist) {
        __weak typeof(self) wself = self;
        TTAccountAlertView *alertView = [[TTAccountAlertView alloc] initWithTitle:@"账号不存在，立即注册" message:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES tapCompletion:^(TTAccountAlertCompletionEventType type) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                [wself switchButtonClicked:wself];
                [wself resendButtonClicked:wself.mobileInput.resendButton];
            }
        }];
        [alertView show];
        return nil;
    }
    
    NSString *alertText = [error.userInfo valueForKey:@"alert_text"];
    
    if (!isEmptyString(alertText)) {
        if ([alertText rangeOfString:@"是否找回密码"].location != NSNotFound || errorCode == TTAccountLoginErrorCodeAlertFindPassword) {
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

- (TTUserPrivacyView *)privacyView
{
    if (!_privacyView) {
        _privacyView = [TTUserPrivacyView new];
        __weak typeof(self) weakSelf __unused = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        _privacyView.viewPrivacyHandler = ^() {
            if ([(id)UIApplication.class respondsToSelector:@selector(openPrivacyProtection)]) {
                [(id)UIApplication.class performSelector:@selector(openPrivacyProtection)];
            }
        };
        
        _privacyView.viewUserAgreementHandler = ^() {
            if ([(id)UIApplication.class respondsToSelector:@selector(openUserAgreement)]) {
                [(id)UIApplication.class performSelector:@selector(openUserAgreement)];
            }
        };
#pragma clang diagnostic pop
        
        [_privacyView layoutIfNeeded];
    }
    return _privacyView;
}

- (SSThemedLabel *)upTipLabel
{
    if (!_upTipLabel) {
        _upTipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _upTipLabel.backgroundColor = [UIColor clearColor];
        _upTipLabel.numberOfLines = 0;
        _upTipLabel.textColor = [UIColor blackColor];
        CGFloat fontSize = [TTDeviceUIUtils tt_fontSize:24];
        NSMutableAttributedString *attributedString = [TTLabelTextHelper attributedStringWithString:!isEmptyString(self.title) ? self.title : [TTAccountLoginConfLogic quickRegisterPageTitle] fontSize:fontSize lineHeight:fontSize * 1.4 lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:NO firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
        _upTipLabel.attributedText = attributedString;
        [_upTipLabel sizeToFit];
    }
    return _upTipLabel;
}

- (SSThemedLabel *)upInfoLabel
{
    if (!_upInfoLabel) {
        _upInfoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _upInfoLabel.textColorThemeKey = kColorText1;
        _upInfoLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:20]];
    }
    return _upInfoLabel;
}

- (SSThemedLabel *)loginTipLabel
{
    if (!_loginTipLabel) {
        _loginTipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _loginTipLabel.textColorThemeKey = kColorText3;
        _loginTipLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:11]];
        _loginTipLabel.text = NSLocalizedString(@"未注册手机验证后自动登录",nil);
        [_loginTipLabel sizeToFit];
        _loginTipLabel.centerX = self.view.centerX;
    }
    return _loginTipLabel;
}

- (SSThemedButton *)switchButton
{
    if (!_switchButton) {
        _switchButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _switchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _switchButton.titleLabel.font =
        [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _switchButton.titleColorThemeKey = kColorText5;
        _switchButton.highlightedTitleColorThemeKey = kColorText5Highlighted;
        [_switchButton addTarget:self
                          action:@selector(switchButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
        [_switchButton sizeToFit];
        
    }
    return _switchButton;
}

- (SSThemedLabel *)emailFindPasswordTipLabel
{
    if (!_emailFindPasswordTipLabel) {
        _emailFindPasswordTipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _emailFindPasswordTipLabel.textColorThemeKey = kColorText3;
        _emailFindPasswordTipLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _emailFindPasswordTipLabel.text = NSLocalizedString(@"找回密码请在PC端操作",nil);
        [_emailFindPasswordTipLabel sizeToFit];
    }
    return _emailFindPasswordTipLabel;
}

#pragma mark -- Helper

- (NSString *)prefixThirdPartySource
{
    if (self.loginStyle == TTAccountLoginStylePassword) {
        return @"password";
    } else if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        return @"mobile";
    } else if (self.loginStyle == TTAccountLoginStyleEmail) {
        return @"email";
    }
    return @"";
}

- (BOOL)validateMobileNumber:(NSString *)mobileNumber
{
    if (self.loginStyle != TTAccountLoginStyleEmail) {
        return [super validateMobileNumber:mobileNumber];
    } else {
        NSString *regex = @"^\\w+([-+._]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$";
        NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if ([predicate evaluateWithObject:mobileNumber]) {
            return YES;
        }
        return NO;
    }
}

- (BOOL)isVerifyWordOrPassWordValid
{
    if (self.loginStyle == TTAccountLoginStyleCaptcha) {
        return self.captchaInput.field.text.length == 4;
    } else {
        return self.captchaInput.field.text.length > 0;
    }
    return YES;
}

- (void)uMengPlatform:(NSString *)keyName
{
    if ([keyName isEqualToString:TT_LOGIN_PLATFORM_SINAWEIBO]) {
        self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_sinaweibo", [self prefixThirdPartySource]];
        // 判断是否在 [账号密码登录页面]，进入[账号密码登录页]后,点击第三方新浪微博登录的量
        if (self.loginStyle == TTAccountLoginStylePassword) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"password_login_click_sinaweibo" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"sinaweibo" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleCaptcha) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_click_sinaweibo" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"sinaweibo" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleEmail) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"email_login_click_sinaweibo" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"sinaweibo" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_email_click" params:extraDict isDoubleSending:YES];
        }
    } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_QZONE]) {
        self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_qq",[self prefixThirdPartySource]];
        // 判断是否在 [账号密码登录页面]，进入[账号密码登录页]后,点击第三方QQ登录的量
        if (self.loginStyle == TTAccountLoginStylePassword) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"password_login_click_qq" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"qq" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleCaptcha) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_click_qq" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"qq" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleEmail) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"email_login_click_qq" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"qq" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_email_click" params:extraDict isDoubleSending:YES];
        }
    } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_WECHAT]) {
        self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_weixin",[self prefixThirdPartySource]];
        // 判断是否在 [账号密码登录页面]，进入[账号密码登录页]后,点击第三方微信登录的量
        if (self.loginStyle == TTAccountLoginStylePassword) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"password_login_click_weixin" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"weixin" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleCaptcha) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_click_weixin" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"weixin" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleEmail) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"email_login_click_weixin" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"weixin" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_email_click" params:extraDict isDoubleSending:YES];
        }
    } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_QQWEIBO]) {
        self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_qqweibo",[self prefixThirdPartySource]];
        // 判断是否在 [账号密码登录页面]，进入[账号密码登录页]后,点击第三方腾讯微博登录的量
        if (self.loginStyle == TTAccountLoginStylePassword) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"password_login_click_qqweibo" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"qqweibo" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleCaptcha) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_click_qqweibo" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"qqweibo" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleEmail) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"email_login_click_qqweibo" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"qqweibo" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_email_click" params:extraDict isDoubleSending:YES];
        }
    } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_RENREN]) {
        self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_renren",[self prefixThirdPartySource]];
        // 判断是否在 [账号密码登录页面]，进入[账号密码登录页]后,点击第三方人人登录的量
        if (self.loginStyle == TTAccountLoginStylePassword) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"password_login_click_renren" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"renren" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleCaptcha) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_click_renren" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"renren" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleEmail) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"email_login_click_renren" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"renren" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_email_click" params:extraDict isDoubleSending:YES];
        }
    } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_TIANYI]) {
        self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_telecom",[self prefixThirdPartySource]];
        // 判断是否在 [账号密码登录页面]，进入[账号密码登录页]后,点击第三方人人登录的量
        if (self.loginStyle == TTAccountLoginStylePassword) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"password_login_click_telecom" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"telecom" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleCaptcha) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"mobile_login_click_telecom" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"telecom" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict isDoubleSending:YES];
        }
        else if (self.loginStyle == TTAccountLoginStyleEmail) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"email_login_click_telecom" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"telecom" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_email_click" params:extraDict isDoubleSending:YES];
        }
    } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_HUOSHAN]) {
        self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_hotsoon",[self prefixThirdPartySource]];
        // 判断是否在 [账号密码登录页面]，进入[账号密码登录页]后,点击第三方人人登录的量
        if (self.loginStyle == TTAccountLoginStylePassword) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"hotsoon" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict];
        }
        else if (self.loginStyle == TTAccountLoginStyleCaptcha) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"hotsoon" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict];
        }
        else if (self.loginStyle == TTAccountLoginStyleEmail) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"hotsoon" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_email_click" params:extraDict];
        }
    } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_DOUYIN]) {
        self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_douyin",[self prefixThirdPartySource]];
        // 判断是否在 [账号密码登录页面]，进入[账号密码登录页]后,点击第三方人人登录的量
        if (self.loginStyle == TTAccountLoginStylePassword) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"douyin" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_password_click" params:extraDict];
        }
        else if (self.loginStyle == TTAccountLoginStyleCaptcha) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"douyin" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_mobile_click" params:extraDict];
        }
        else if (self.loginStyle == TTAccountLoginStyleEmail) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"douyin" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_email_click" params:extraDict];
        }
    }
    
    /** New Imp
     NSString *oldLogLabelPrefixString = nil;
     NSString *newLogEventString = nil;
     if (self.loginStyle == TTAccountLoginStylePassword) {
     oldLogLabelPrefixString = @"password_login_click";
     newLogEventString = @"login_password_click";
     } else if (self.loginStyle == TTAccountLoginStyleCaptcha) {
     oldLogLabelPrefixString = @"mobile_login_click";
     newLogEventString = @"login_mobile_click";
     } else if (self.loginStyle == TTAccountLoginStyleCaptcha) {
     oldLogLabelPrefixString = @"email_login_click";
     newLogEventString = @"login_email_click";
     }
     
     NSString *platformLogString = nil;
     if ([keyName isEqualToString:TT_LOGIN_PLATFORM_SINAWEIBO]) {
     self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_sinaweibo", [self prefixThirdPartySource]];
     
     platformLogString = @"sinaweibo";
     } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_QZONE]) {
     self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_qq", [self prefixThirdPartySource]];
     
     platformLogString = @"qq";
     } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_WECHAT]) {
     self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_weixin", [self prefixThirdPartySource]];
     
     platformLogString = @"weixin";
     } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_QQWEIBO]) {
     self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_qqweibo", [self prefixThirdPartySource]];
     
     platformLogString = @"qqweibo";
     } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_RENREN]) {
     self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_renren", [self prefixThirdPartySource]];
     
     platformLogString = @"renren";
     } else if ([keyName isEqualToString:TT_LOGIN_PLATFORM_TIANYI]) {
     self.thirdPartySource = [NSString stringWithFormat:@"%@_login_success_telecom", [self prefixThirdPartySource]];
     
     platformLogString = @"telecom";
     }
     
     NSString *oldLogLabelString = oldLogLabelPrefixString;
     if (platformLogString) {
     oldLogLabelString = [oldLogLabelPrefixString stringByAppendingFormat:@"_%@", platformLogString];
     }
     
     // LogV1
     if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
     [TTTracker category:@"umeng" event:@"register_new" label:(oldLogLabelString ? : @"") dict:@{@"source":self.source}];
     }
     // LogV3
     NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
     [extraDict setValue:self.source forKey:@"source"];
     [extraDict setValue:platformLogString forKey:@"action_type"];
     [TTTrackerWrapper eventV3:newLogEventString params:extraDict isDoubleSending:YES];
     
     */
}

@end

//
//  ArticleMobileRegisterViewController.m
//  Article
//
//  Created by SunJiangting on 14-7-2.
//
//

#import "ArticleMobileRegisterViewController.h"
#import "TTThemedAlertController.h"
#import "TTDeviceHelper.h"
#import "TTAccountBusiness.h"

#import "ArticleMobileLoginViewController.h"
#import "ArticleMobileSettingViewController.h"
#import "TTTrackerWrapper.h"



@interface ArticleMobileRegisterViewController () <UITextFieldDelegate>

@property(nonatomic, strong) SSThemedButton     *loginButton;
@property(nonatomic, strong) SSThemedTextField  *captchaField;
@property(nonatomic, strong) SSThemedButton     *resendButton;
@property(nonatomic, strong) SSThemedTextField  *passwordField;

@property(nonatomic, strong) SSThemedLabel * captchaTipLabel;
@property(nonatomic, strong) SSThemedView *separatorView0;
@property(nonatomic, strong) SSThemedView *separatorView1;


//@property(nonatomic, strong) UIView  *containerView;
@property(nonatomic, weak)   NSTimer *timer;

@end

@implementation ArticleMobileRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.timeoutInterval = ArticleRetrieveTimeoutInterval;
        self.automaticallyAdjustKeyboardOffset = YES;
        self.maximumHeightOfContent = 310;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.state = ArticleLoginStateMobileRegister;
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle: NSLocalizedString(@"手机号注册", nil)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.captchaField = [[SSThemedTextField alloc] initWithFrame:CGRectMake(10, 0, 0, [ArticleMobileRegisterViewController heightOfInputField])];
    self.captchaField.keyboardType = UIKeyboardTypeNumberPad;
    self.captchaField.returnKeyType = UIReturnKeyNext;
    self.captchaField.placeholder = NSLocalizedString(@"请输入验证码", nil);
    
    self.captchaField.backgroundColor = [UIColor clearColor];
    self.captchaField.placeholderColorThemeKey = kColorText3;
    self.captchaField.textColorThemeKey = kColorText1;
    self.captchaField.delegate = self;
    self.captchaField.font = [UIFont systemFontOfSize:[ArticleMobileRegisterViewController fontSizeOfInputFiled]];
    [self.inputContainerView addSubview:self.captchaField];
    
    self.resendButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [self.resendButton addTarget:self action:@selector(resendButtonActionFired:) forControlEvents:UIControlEventTouchUpInside];
    self.resendButton.titleLabel.font = [UIFont systemFontOfSize:[ArticleMobileRegisterViewController fontSizeOfInputFiled]];
    self.resendButton.disabledTitleColorThemeKey = kColorText3;
    self.resendButton.titleColorThemeKey = kColorText4;
    self.resendButton.highlightedTitleColorThemeKey = kColorText4Highlighted;
    
    NSDictionary *previousCode = [[self class] previousMobileCodeInformation];
    if ([[previousCode valueForKey:@"mobile"] isEqualToString:self.mobileNumber] &&
        ([[previousCode valueForKey:@"type"] intValue] == TTASMSCodeScenarioPhoneRegister ||
         [[previousCode valueForKey:@"type"] intValue] == TTASMSCodeScenarioPhoneRegisterRetry)) {
            NSTimeInterval timeInterval = [[previousCode valueForKey:@"time"] doubleValue];
            NSInteger retryTime = [[previousCode valueForKey:@"retryTime"] intValue];
            NSInteger timeOffset = [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
            self.timeoutInterval = retryTime;
            self.countdown = MAX(0, (retryTime - timeOffset));
        } else {
            self.countdown = self.timeoutInterval;
        }
    
    [self setButtonEnabled:NO];
    [self fitResendButton];
    [self.resendButton sizeToFit];
    [self.inputContainerView addSubview:self.resendButton];
    
    self.separatorView0 = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceHelper ssOnePixel], 14)];
    self.separatorView0.backgroundColorThemeKey = kColorLine1;
    [self.inputContainerView addSubview:self.separatorView0];
    
    
    self.separatorView1 = [[SSThemedView alloc] init];
    self.separatorView1.backgroundColorThemeKey = kColorLine1;
    [self.inputContainerView addSubview:self.separatorView1];
    
    self.passwordField = [[SSThemedTextField alloc] init];
    self.passwordField.borderStyle = UITextBorderStyleNone;
    self.passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordField.returnKeyType = UIReturnKeyDone;
    self.passwordField.placeholder = NSLocalizedString(@"请输入新密码(6-20位英文或数字)", nil);
    self.passwordField.textColorThemeKey = kColorText1;
    self.passwordField.placeholderColorThemeKey = kColorText3;
    self.passwordField.secureTextEntry = YES;
    self.passwordField.delegate = self;
    self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordField.font = [UIFont systemFontOfSize:[ArticleMobileRegisterViewController fontSizeOfInputFiled]];
    [self.inputContainerView addSubview:self.passwordField];
    
    self.loginButton = [self mobileButtonWithTitle:NSLocalizedString(@"提 交", nil) target:self action:@selector(loginButtonActionFired:)];
    [self.containerView addSubview:self.loginButton];
    
    self.captchaTipLabel = [[SSThemedLabel alloc] init];
    self.captchaTipLabel.text = [NSString stringWithFormat:@"已向手机 %@ 发送验证码", self.mobileNumber];
    self.captchaTipLabel.font = [UIFont systemFontOfSize:[ArticleMobileRegisterViewController fontSizeOfCaptchaTipLabel]];
    self.captchaTipLabel.textColorThemeKey = kColorText3;
    [self.captchaTipLabel sizeToFit];
    [self.containerView addSubview:self.captchaTipLabel];
    
    [self startTimer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.inputContainerView.frame = CGRectMake(0, 30, (self.containerView.width), [ArticleMobileRegisterViewController heightOfInputField] * 2 + [TTDeviceHelper ssOnePixel]);
    self.resendButton.origin = CGPointMake((self.inputContainerView.width) - 10 - (self.resendButton.width), ([ArticleMobileRegisterViewController heightOfInputField] - (self.resendButton.height)) / 2);
    self.separatorView0.origin = CGPointMake((self.resendButton.left) - 10, ([ArticleMobileRegisterViewController heightOfInputField] - (self.separatorView0.height)) / 2);
    self.captchaField.width = (self.separatorView0.left) - 10;
    self.separatorView1.frame = CGRectMake(0, (self.captchaField.bottom), (self.inputContainerView.width), [TTDeviceHelper ssOnePixel]);
    self.passwordField.frame = CGRectMake(10, (self.separatorView1.bottom), (self.inputContainerView.width) - 10, [ArticleMobileRegisterViewController heightOfInputField]);
    self.loginButton.origin = CGPointMake(0, (self.inputContainerView.bottom) + 20);
    self.captchaTipLabel.origin = CGPointMake(((self.containerView.width) - (self.captchaTipLabel.width)) / 2, (self.loginButton.bottom) + 15);
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.captchaField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isContentValid
{
    return (self.captchaField.text.length > 0 && self.passwordField.text.length > 0);
}

#pragma mark - PrivateMethod
- (void)loginButtonActionFired:(id)sender {
    if (self.captchaField.text.length == 0) {
        wrapperTrackEvent(@"login_register", @"register_login_noauth");
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请输入验证码", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self.captchaField becomeFirstResponder];
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    if (self.passwordField.text.length == 0) {
        wrapperTrackEvent(@"login_register", @"register_login_nopsw");
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请输入密码", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self.passwordField becomeFirstResponder];
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    __weak ArticleMobileRegisterViewController *weakSelf = self;
    void (^registerBlock)(NSString *, NSString *, NSString *, NSString *) = ^(NSString *mobile, NSString *code, NSString *password,NSString *captcha) {
        [weakSelf showWaitingIndicator];
        
        [TTAccountManager startRegisterWithPhoneNumber:mobile code:code password:password captcha:captcha completion:^(UIImage *captchaImage, NSError *error) {
            
            weakSelf.captchaImage = captchaImage;
            weakSelf.captchaValue = nil;
            weakSelf.error = error;
            if (error) {
                if (captchaImage) {
                    [weakSelf dismissWaitingIndicator];
                    [weakSelf resendButtonActionFired:nil];
                } else {
                    [weakSelf dismissWaitingIndicatorWithError:error];
                }
                /////// 友盟统计
                wrapperTrackEvent(@"login_register", @"register_login_fail");
            } else {
                
                /////// 友盟统计
                wrapperTrackEvent(@"login_register", @"register_login_success");
                /// TODO:修改用户名
                ArticleMobileSettingViewController *viewController =
                [[ArticleMobileSettingViewController alloc] initWithNibName:nil bundle:nil];
                viewController.completion = weakSelf.completion;
                [weakSelf.navigationController pushViewController:viewController animated:YES];
            }
        }];
    };
    
    void (^alertCaptchaBlock)(UIImage *, NSError *, TTASMSCodeScenarioType) =
    ^(UIImage *captcha, NSError *error, TTASMSCodeScenarioType scenario) {
        ArticleMobileCaptchaAlertView *alertView = [[ArticleMobileCaptchaAlertView alloc] initWithCaptchaImage:captcha];
        alertView.error = error;
        [alertView showWithDismissBlock:^(ArticleMobileCaptchaAlertView *alertView, NSInteger buttonIndex) {
            self.captchaValue = alertView.captchaValue;
            self.captchaImage = alertView.captchaImage;
            if (alertView.captchaValue.length > 0) {
                registerBlock(self.mobileNumber, self.captchaField.text, self.passwordField.text, alertView.captchaValue);
            }
        }];
    };
    
    @ArticleTipAndReturnIFNetworkNotOK;
    if (self.captchaImage && !self.captchaValue) {
        alertCaptchaBlock(self.captchaImage, self.error, TTASMSCodeScenarioPhoneRegisterSubmit);
    } else {
        registerBlock(self.mobileNumber, self.captchaField.text, self.passwordField.text, self.captchaValue);
    }
}

- (void)resendButtonActionFired:(id)sender {
    /////// 友盟统计
    wrapperTrackEvent(@"login_register", @"register_retry");
    __weak ArticleMobileRegisterViewController *weakSelf = self;
    void (^registerBlock)(NSString *, NSString *) = ^(NSString *mobile, NSString *captcha) {
        
        [TTAccountManager startSendCodeWithPhoneNumber:mobile captcha:captcha type:TTASMSCodeScenarioPhoneRegisterRetry unbindExist:NO completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
            
            weakSelf.captchaImage = captchaImage;
            weakSelf.captchaValue = nil;
            weakSelf.error = error;
            weakSelf.timeoutInterval = retryTime.intValue;
            if (error) {
                if (captchaImage) {
                    [weakSelf resendButtonActionFired:nil];
                } else {
                    [weakSelf showAutoDismissIndicatorWithError:error];
                }
            } else {
                weakSelf.countdown = weakSelf.timeoutInterval;
                [weakSelf startTimer];
                NSMutableDictionary *information = [NSMutableDictionary dictionaryWithCapacity:2];
                [information setValue:@(TTASMSCodeScenarioPhoneRegisterRetry) forKey:@"type"];
                [information setValue:retryTime forKey:@"retryTime"];
                [information setValue:mobile forKey:@"mobile"];
                [information setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"time"];
                [[weakSelf class] setPreviousMobileCodeInformation:information];
            }
        }];
    };
    
    void (^alertCaptchaBlock)(UIImage *, NSError *, TTASMSCodeScenarioType) =
    ^(UIImage *captcha, NSError *error, TTASMSCodeScenarioType scenario) {
        ArticleMobileCaptchaAlertView *alertView = [[ArticleMobileCaptchaAlertView alloc] initWithCaptchaImage:captcha];
        alertView.error = error;
        [alertView showWithDismissBlock:^(ArticleMobileCaptchaAlertView *alertView, NSInteger buttonIndex) {
            self.captchaValue = alertView.captchaValue;
            self.captchaImage = alertView.captchaImage;
            if (alertView.captchaValue.length > 0) {
                registerBlock(self.mobileNumber, alertView.captchaValue);
            }
        }];
    };
    
    @ArticleTipAndReturnIFNetworkNotOK;
    if (self.captchaImage && !self.captchaValue) {
        alertCaptchaBlock(self.captchaImage, self.error, TTASMSCodeScenarioPhoneRegisterRetry);
    } else {
        registerBlock(self.mobileNumber, self.captchaValue);
    }
}

- (void)startTimer {
    if (self.timer) {
        return;
    }
    [self fitResendButton];
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(countDownActionFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)setButtonEnabled:(BOOL)enabled {
    self.resendButton.enabled = enabled;
}

- (void)fitResendButton {
    if (self.countdown == 0) {
        [self.resendButton setTitle:NSLocalizedString(@"重新发送", nil) forState:UIControlStateNormal];
        [self.resendButton setTitle:NSLocalizedString(@"重新发送", nil) forState:UIControlStateDisabled];
    } else {
        [self.resendButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"重新发送%d", nil), self.countdown] forState:UIControlStateNormal];
        [self.resendButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"重新发送%d", nil), self.countdown]
                           forState:UIControlStateDisabled];
    }
}

- (void)countDownActionFired:(NSTimer *)timer {
    if (self.countdown == 0) {
        [timer invalidate];
        self.timer = nil;
        [self setButtonEnabled:YES];
    }
    if (self.countdown > 0) {
        self.countdown--;
        [self setButtonEnabled:NO];
    }
    [self fitResendButton];
}

+ (CGFloat)fontSizeOfCaptchaTipLabel
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 14.f;
    } else {
        return 12.f;
    }
}
@end

//
//  ArticleMobileCaptchaViewController.m
//  Article
//
//  Created by Huaqing Luo on 30/7/15.
//
//

#import "ArticleMobileChangeCaptchaViewController.h"
#import <TTThemedAlertController.h>
#import <TTDeviceHelper.h>
#import <TTAccountBusiness.h>
#import "TTTrackerWrapper.h"


@interface ArticleMobileChangeCaptchaViewController ()

@property(nonatomic, strong) SSThemedTextField    *captchaField;
@property(nonatomic, strong) SSThemedButton       *loginButton;
@property(nonatomic, strong) SSThemedButton       *resendButton;

@property (nonatomic, weak)   NSTimer              *timer;
@property(nonatomic, strong) SSThemedLabel * captchaTipLabel;
@property(nonatomic, strong) SSThemedView *separatorView0;

@end

@implementation ArticleMobileChangeCaptchaViewController

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
    // Do any additional setup after loading the view.
    [self.navigationBar setTitleText:NSLocalizedString(@"绑定手机号", nil)];
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle: NSLocalizedString(@"更换手机号", nil)];
    
    
    self.captchaField = [[SSThemedTextField alloc] initWithFrame:CGRectMake(10, 0, 0, [ArticleMobileChangeCaptchaViewController heightOfInputField])];
    self.captchaField.keyboardType = UIKeyboardTypeNumberPad;
    self.captchaField.returnKeyType = UIReturnKeyNext;
    self.captchaField.placeholder = NSLocalizedString(@"请输入验证码", nil);
    self.captchaField.backgroundColor = [UIColor clearColor];
    self.captchaField.placeholderColorThemeKey = kColorText3;
    self.captchaField.textColorThemeKey = kColorText1;
    self.captchaField.delegate = self;
    self.captchaField.font = [UIFont systemFontOfSize:[ArticleMobileChangeCaptchaViewController fontSizeOfInputFiled]];
    [self.inputContainerView addSubview:self.captchaField];
    
    self.resendButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [self.resendButton addTarget:self action:@selector(resendButtonActionFired:) forControlEvents:UIControlEventTouchUpInside];
    self.resendButton.titleLabel.font = [UIFont systemFontOfSize:[ArticleMobileChangeCaptchaViewController fontSizeOfInputFiled]];
    self.resendButton.disabledTitleColorThemeKey = kColorText3;
    self.resendButton.titleColorThemeKey = kColorText4;
    self.resendButton.highlightedTitleColorThemeKey = kColorText4Highlighted;
    
    
    NSDictionary *previousCode = [[self class] previousMobileCodeInformation];
    if ([[previousCode valueForKey:@"mobile"] isEqualToString:self.mobileNumber] && ([[previousCode valueForKey:@"type"] intValue] == TTASMSCodeScenarioChangePhone || [[previousCode valueForKey:@"type"] intValue] == TTASMSCodeScenarioChangePhoneRetry)) {
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
    
    self.loginButton = [self mobileButtonWithTitle:NSLocalizedString(@"确认更换", nil) target:self action:@selector(loginButtonActionFired:)];
    self.loginButton.origin = CGPointMake(0, (self.inputContainerView.bottom) + 20);
    [self.containerView addSubview:self.loginButton];
    
    self.captchaTipLabel = [[SSThemedLabel alloc] init];
    self.captchaTipLabel.text = [NSString stringWithFormat:@"已向手机 %@ 发送验证码", self.mobileNumber];
    self.captchaTipLabel.font = [UIFont systemFontOfSize:[ArticleMobileChangeCaptchaViewController fontSizeOfCaptchaTipLabel]];
    self.captchaTipLabel.textColorThemeKey = kColorText3;
    [self.captchaTipLabel sizeToFit];
    [self.containerView addSubview:self.captchaTipLabel];
    
    [self startTimer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.inputContainerView.frame = CGRectMake(0, 30, (self.containerView.width), [ArticleMobileChangeCaptchaViewController heightOfInputField]);
    self.resendButton.origin = CGPointMake((self.inputContainerView.width) - 10 - (self.resendButton.width), ([ArticleMobileChangeCaptchaViewController heightOfInputField] - (self.resendButton.height)) / 2);
    self.separatorView0.origin = CGPointMake((self.resendButton.left) - 10, ([ArticleMobileChangeCaptchaViewController heightOfInputField] - (self.separatorView0.height)) / 2);
    self.captchaField.width = (self.separatorView0.left) - 10;
    self.captchaTipLabel.origin = CGPointMake(((self.containerView.width) - (self.captchaTipLabel.width)) / 2, (self.loginButton.bottom) + 15);
    self.captchaField.width = (self.separatorView0.left) - 10;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.captchaField becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void) goBack {
    [super goBack];
    if (self.completion) {
        self.completion(NO);
    }
}

- (void) resendButtonActionFired:(id) sender {
    wrapperTrackEvent(@"login_register", @"change_mobile_auth_retry");
    
    __weak ArticleMobileChangeCaptchaViewController * weakSelf = self;
    void (^ sendCodeBlock)(NSString *, NSString *) = ^(NSString * mobile, NSString * captcha) {
        
        [TTAccountManager startSendCodeWithPhoneNumber:mobile captcha:captcha type:TTASMSCodeScenarioChangePhoneRetry unbindExist:NO completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
            
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
                NSMutableDictionary * information = [NSMutableDictionary dictionaryWithCapacity:2];
                [information setValue:@(TTASMSCodeScenarioChangePhoneRetry) forKey:@"type"];
                [information setValue:retryTime forKey:@"retryTime"];
                [information setValue:mobile forKey:@"mobile"];
                [information setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"time"];
                [[weakSelf class] setPreviousMobileCodeInformation:information];
            }
        }];
    };
    
    void (^ alertCaptchaBlock) (UIImage *, NSError *, TTASMSCodeScenarioType) = ^(UIImage * captcha, NSError * error, TTASMSCodeScenarioType scenario) {
        ArticleMobileCaptchaAlertView * alertView = [[ArticleMobileCaptchaAlertView alloc] initWithCaptchaImage:captcha];
        alertView.error = error;
        [alertView showWithDismissBlock:^(ArticleMobileCaptchaAlertView * alertView, NSInteger buttonIndex) {
            self.captchaValue = alertView.captchaValue;
            self.captchaImage = alertView.captchaImage;
            if (alertView.captchaValue.length > 0) {
                sendCodeBlock(self.mobileNumber, alertView.captchaValue);
            }
        }];
    };
    @ArticleTipAndReturnIFNetworkNotOK;
    if (self.captchaImage && !self.captchaValue) {
        alertCaptchaBlock(self.captchaImage, self.error, TTASMSCodeScenarioChangePhoneRetry);
    } else {
        sendCodeBlock(self.mobileNumber, self.captchaValue);
    }
}

- (BOOL)isContentValid
{
    return self.captchaField.text.length > 0;
}

- (void)loginButtonActionFired:(id)sender
{
    if (self.captchaField.text.length == 0) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请输入验证码", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self.captchaField becomeFirstResponder];
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    
    __weak ArticleMobileChangeCaptchaViewController * weakSelf = self;
    void (^ changeMobileBlock)(NSString *, NSString *, NSString *) = ^(NSString *mobile, NSString *code, NSString *captcha) {
        [weakSelf showWaitingIndicator];
        
        [TTAccountManager startChangePhoneNumber:mobile code:code captcha:captcha completion:^(UIImage *captchaImage, NSError *error) {
            
            weakSelf.captchaImage = captchaImage;
            weakSelf.captchaValue = nil;
            if (!error) {
                wrapperTrackEvent(@"login_register", @"change_mobile_done");
                [weakSelf dismissWaitingIndicatorWithText:NSLocalizedString(@"手机号更换成功", nil)];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf backToMainViewControllerAnimated:YES completion:weakSelf.completion];
                });
            } else {
                wrapperTrackEvent(@"login_register", @"change_mobile_auth_error");
                
                if (captchaImage) {
                    [weakSelf dismissWaitingIndicator];
                    [weakSelf loginButtonActionFired:nil];
                } else {
                    [weakSelf dismissWaitingIndicatorWithError:error];
                }
            }
        }];
    };
    
    void (^ alertCaptchaBlock) (UIImage *, NSError *) = ^(UIImage * captcha, NSError * error) {
        ArticleMobileCaptchaAlertView * alertView = [[ArticleMobileCaptchaAlertView alloc] initWithCaptchaImage:captcha];
        alertView.error = error;
        [alertView showWithDismissBlock:^(ArticleMobileCaptchaAlertView * alertView, NSInteger buttonIndex) {
            self.captchaValue = alertView.captchaValue;
            self.captchaImage = alertView.captchaImage;
            if (alertView.captchaValue.length > 0) {
                changeMobileBlock(self.mobileNumber, self.captchaField.text, alertView.captchaValue);
            }
        }];
    };
    @ArticleTipAndReturnIFNetworkNotOK;
    if (self.captchaImage && !self.captchaValue) {
        alertCaptchaBlock(self.captchaImage, self.error);
    } else {
        changeMobileBlock(self.mobileNumber, self.captchaField.text, self.captchaValue);
    }
}

#pragma mark - PrivateMethod

- (void) startTimer {
    if (self.timer) {
        return;
    }
    [self fitResendButton];
    NSTimer * timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(countDownActionFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer fire];
    self.timer = timer;
}

- (void) setButtonEnabled:(BOOL) enabled {
    self.resendButton.enabled = enabled;
}

- (void) fitResendButton {
    if (self.countdown == 0) {
        [self.resendButton setTitle:NSLocalizedString(@"重新发送", nil) forState:UIControlStateNormal];
        [self.resendButton setTitle:NSLocalizedString(@"重新发送", nil) forState:UIControlStateDisabled];
    } else {
        [self.resendButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"重新发送%d", nil), self.countdown] forState:UIControlStateNormal];
        [self.resendButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"重新发送%d", nil), self.countdown] forState:UIControlStateDisabled];
    }
}

- (void) countDownActionFired:(NSTimer *) timer {
    if (self.countdown == 0) {
        [timer invalidate];
        [self setButtonEnabled:YES];
        self.timer = nil;
    }
    if (self.countdown > 0) {
        self.countdown --;
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

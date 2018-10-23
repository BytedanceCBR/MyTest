//
//  ArticleMobilePasswordViewController.m
//  Article
//
//  Created by SunJiangting on 14-7-15.
//
//

#import "ArticleMobilePasswordViewController.h"
#import <TTThemedAlertController.h>
#import <TTDeviceHelper.h>
#import <TTAccountBusiness.h>



@interface ArticleMobilePasswordViewController ()
/*
 @property(nonatomic, strong) UIImageView *animationView;
 
 @property(nonatomic, strong) UIImage *firstFrameImage;
 @property(nonatomic, strong) UIImage *lastFrameImage;*/

@property(nonatomic, strong) SSThemedTextField *captchaField;
@property(nonatomic, strong) SSThemedTextField *passwordField;

@property(nonatomic, strong) SSThemedButton *loginButton;
@property(nonatomic, strong) SSThemedButton *resendButton;

@property(nonatomic, strong) SSThemedLabel * captchaTipLabel;
@property(nonatomic, strong) SSThemedView   *separatorView0;
@property(nonatomic, strong) SSThemedView *separatorView1;



//@property(nonatomic, assign) NSInteger timeoutInterval;

@property(nonatomic, weak) NSTimer *timer;

@end

@implementation ArticleMobilePasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.timeoutInterval = ArticleRetrieveTimeoutInterval;
        self.automaticallyAdjustKeyboardOffset = YES;
        self.maximumHeightOfContent = 315;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationBar setTitleText:NSLocalizedString(@"修改密码", nil)];
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle: NSLocalizedString(@"修改密码", nil)];
    
    
    self.captchaField = [[SSThemedTextField alloc] initWithFrame:CGRectMake(10, 0, 0, [ArticleMobilePasswordViewController heightOfInputField])];
    self.captchaField.keyboardType = UIKeyboardTypeNumberPad;
    self.captchaField.returnKeyType = UIReturnKeyNext;
    self.captchaField.placeholder = NSLocalizedString(@"请输入验证码", nil);
    
    self.captchaField.backgroundColor = [UIColor clearColor];
    self.captchaField.placeholderColorThemeKey = kColorText3;
    self.captchaField.textColorThemeKey = kColorText1;
    self.captchaField.delegate = self;
    self.captchaField.font = [UIFont systemFontOfSize:[ArticleMobilePasswordViewController fontSizeOfInputFiled]];
    [self.inputContainerView addSubview:self.captchaField];
    
    self.resendButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [self.resendButton addTarget:self action:@selector(resendButtonActionFired:) forControlEvents:UIControlEventTouchUpInside];
    self.resendButton.titleLabel.font = [UIFont systemFontOfSize:[ArticleMobilePasswordViewController fontSizeOfInputFiled]];
    self.resendButton.disabledTitleColorThemeKey = kColorText3;
    self.resendButton.titleColorThemeKey = kColorText4;
    self.resendButton.highlightedTitleColorThemeKey = kColorText4Highlighted;
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
    self.passwordField.font = [UIFont systemFontOfSize:[ArticleMobilePasswordViewController fontSizeOfInputFiled]];
    [self.inputContainerView addSubview:self.passwordField];
    
    self.loginButton = [self mobileButtonWithTitle:NSLocalizedString(@"确认修改", nil) target:self action:@selector(loginButtonActionFired:)];
    [self.containerView addSubview:self.loginButton];
    
    self.captchaTipLabel = [[SSThemedLabel alloc] init];
    self.captchaTipLabel.text = [NSString stringWithFormat:@"已向手机 %@ 发送验证码", self.mobileNumber];
    self.captchaTipLabel.font = [UIFont systemFontOfSize:[ArticleMobilePasswordViewController fontSizeOfCaptchaTipLabel]];
    self.captchaTipLabel.textColorThemeKey = kColorText3;
    [self.captchaTipLabel sizeToFit];
    [self.containerView addSubview:self.captchaTipLabel];
    
    NSDictionary *previousCode = [[self class] previousMobileCodeInformation];
    if ([[previousCode valueForKey:@"mobile"] isEqualToString:self.mobileNumber] &&
        ([[previousCode valueForKey:@"type"] intValue] == TTASMSCodeScenarioChangePasswordRetry ||
         [[previousCode valueForKey:@"type"] intValue] == TTASMSCodeScenarioChangePassword)) {
            NSTimeInterval timeInterval = [[previousCode valueForKey:@"time"] doubleValue];
            NSInteger retryTime = [[previousCode valueForKey:@"retryTime"] intValue];
            NSInteger timeOffset = [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
            self.timeoutInterval = retryTime;
            self.countdown = MAX(0, (retryTime - timeOffset));
            
            [self startTimer];
        } else {
            self.countdown = 0; // self.timeoutInterval;
            __weak ArticleMobilePasswordViewController *weakSelf = self;
            
            [TTAccountManager startSendCodeWithPhoneNumber:self.mobileNumber captcha:nil type:TTASMSCodeScenarioChangePassword unbindExist:NO completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
                
                weakSelf.captchaImage = captchaImage;
                weakSelf.captchaValue = nil;
                weakSelf.error = error;
                weakSelf.timeoutInterval = retryTime.intValue;
                if (!error) {
                    weakSelf.countdown = weakSelf.timeoutInterval;
                    [weakSelf startTimer];
                    NSMutableDictionary *information = [NSMutableDictionary dictionaryWithCapacity:2];
                    [information setValue:@(TTASMSCodeScenarioChangePasswordRetry) forKey:@"type"];
                    [information setValue:retryTime forKey:@"retryTime"];
                    [information setValue:weakSelf.mobileNumber forKey:@"mobile"];
                    [information setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"time"];
                    [[weakSelf class] setPreviousMobileCodeInformation:information];
                } else {
                    weakSelf.countdown = 0;
                    if (captchaImage) {
                        [weakSelf resendButtonActionFired:nil];
                    } else {
                        [weakSelf showAutoDismissIndicatorWithError:error];
                        [weakSelf setButtonEnabled:YES];
                    }
                }
            }];
        }
    
    // Default Resend Button (grey and disable click)
    [self fitResendButton];
    [self setButtonEnabled:NO];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.inputContainerView.frame = CGRectMake(0, 30, (self.containerView.width), [ArticleMobilePasswordViewController heightOfInputField] * 2 + [TTDeviceHelper ssOnePixel]);
    CGFloat resendBtnWidth = MAX(95, self.resendButton.width);
    self.resendButton.size = CGSizeMake(resendBtnWidth, [ArticleMobilePasswordViewController heightOfInputField]);
    self.resendButton.origin = CGPointMake((self.inputContainerView.width) - 10 - resendBtnWidth, ([ArticleMobilePasswordViewController heightOfInputField] - (self.resendButton.height)) / 2);
    self.separatorView0.origin = CGPointMake((self.resendButton.left) - 10, ([ArticleMobilePasswordViewController heightOfInputField] - (self.separatorView0.height)) / 2);
    self.captchaField.width = (self.separatorView0.left) - 10;
    self.separatorView1.frame = CGRectMake(0, (self.captchaField.bottom), (self.inputContainerView.width), [TTDeviceHelper ssOnePixel]);
    self.passwordField.frame = CGRectMake(10, (self.separatorView1.bottom), (self.inputContainerView.width) - 10, [ArticleMobilePasswordViewController heightOfInputField]);
    self.loginButton.origin = CGPointMake(0, (self.inputContainerView.bottom) + 20);
    self.captchaTipLabel.origin = CGPointMake(((self.containerView.width) - (self.captchaTipLabel.width)) / 2, (self.loginButton.bottom) + 15);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /*
     [self.animationView startAnimating];
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     [self.animationView stopAnimating];
     self.animationView.image = self.lastFrameImage;
     });*/
}
/*
 - (void)themeChanged:(NSNotification *)notification {
 [super themeChanged:notification];
 UIImage *image = [UIImage gifImageNamed:@"sendcode_gif_change_password_night"];
 if ([TTThemeManager sharedInstance_tt].currentMode == TTThemeModeDay || !image) {
 image = [UIImage gifImageNamed:@"sendcode_gif_change_password"];
 }
 self.animationView.animationImages = image.images;
 if (image.images.count > 0) {
 self.firstFrameImage = [image.images firstObject];
 self.lastFrameImage = [image.images objectAtIndex:image.images.count - 2];
 }
 self.animationView.image = self.firstFrameImage;
 }*/

- (BOOL)isContentValid
{
    return (self.captchaField.text.length > 0 && self.passwordField.text.length > 0);
}

#pragma mark - PrivateMethod
- (void)loginButtonActionFired:(id)sender {
    if (self.captchaField.text.length == 0) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请输入验证码", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self.captchaField becomeFirstResponder];
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    if (self.passwordField.text.length == 0) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请输入新密码", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self.passwordField becomeFirstResponder];
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    __weak ArticleMobilePasswordViewController *weakSelf = self;
    void (^changePasswordBlock)(NSString *, NSString *, NSString *, NSString *) =
    ^(NSString *mobile, NSString *password, NSString *code, NSString *captcha) {
        [weakSelf showWaitingIndicator];
        
        [TTAccountManager startChangePasswordWithPassword:password code:code captcha:captcha completion:^(UIImage *captchaImage, NSError *error) {
            
            weakSelf.captchaImage = captchaImage;
            weakSelf.captchaValue = nil;
            if (!error) {
                [weakSelf dismissWaitingIndicatorWithText:NSLocalizedString(@"新密码设置成功", nil)];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(),
                               ^{ [weakSelf backToMainViewControllerAnimated:YES]; });
            } else {
                // 密码修改失败
                if (captchaImage) {
                    [weakSelf dismissWaitingIndicator];
                    [weakSelf loginButtonActionFired:nil];
                } else {
                    [weakSelf dismissWaitingIndicatorWithError:error];
                }
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
                changePasswordBlock(self.mobileNumber, self.passwordField.text, self.captchaField.text, alertView.captchaValue);
            }
        }];
    };
    
    @ArticleTipAndReturnIFNetworkNotOK;
    if (self.captchaImage && !self.captchaValue) {
        alertCaptchaBlock(self.captchaImage, self.error, TTASMSCodeScenarioChangePasswordSubmit);
    } else {
        changePasswordBlock(self.mobileNumber, self.passwordField.text, self.captchaField.text, self.captchaValue);
    }
}

- (void)resendButtonActionFired:(id)sender {
    __weak ArticleMobilePasswordViewController *weakSelf = self;
    void (^registerBlock)(NSString *, NSString *) = ^(NSString *mobile, NSString *captcha) {
        
        [TTAccountManager startSendCodeWithPhoneNumber:mobile captcha:captcha type:TTASMSCodeScenarioChangePasswordRetry unbindExist:NO completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
            
            weakSelf.captchaImage = captchaImage;
            weakSelf.captchaValue = nil;
            weakSelf.error = error;
            weakSelf.timeoutInterval = retryTime.intValue;
            if (error) {
                if (captchaImage) {
                    [weakSelf resendButtonActionFired:nil];
                } else {
                    [weakSelf showAutoDismissIndicatorWithError:error];
                    [weakSelf setButtonEnabled:YES];
                }
            } else {
                weakSelf.countdown = weakSelf.timeoutInterval;
                [weakSelf startTimer];
                NSMutableDictionary *information = [NSMutableDictionary dictionaryWithCapacity:2];
                [information setValue:@(TTASMSCodeScenarioChangePasswordRetry) forKey:@"type"];
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
            
            if (0 == buttonIndex || alertView.captchaValue.length <= 0) {
                [self fitResendButton];
                [self setButtonEnabled:YES];
            } else {
                [self setButtonEnabled:NO];
            }

            if (alertView.captchaValue.length > 0) {
                registerBlock(self.mobileNumber, alertView.captchaValue);
            }
        }];
    };
    
    @ArticleTipAndReturnIFNetworkNotOK;
    if (self.captchaImage && !self.captchaValue) {
        alertCaptchaBlock(self.captchaImage, self.error, TTASMSCodeScenarioChangePasswordRetry);
    } else {
        registerBlock(self.mobileNumber, self.captchaValue);
    }
}

#pragma mark - PrivateMethod

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
        [self setButtonEnabled:YES];
        self.timer = nil;
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

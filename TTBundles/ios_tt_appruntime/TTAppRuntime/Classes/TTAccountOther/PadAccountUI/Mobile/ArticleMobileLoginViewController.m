//
//  ArticleLoginViewController.m
//  Article
//
//  Created by SunJiangting on 14-7-4.
//
//

#import "ArticleMobileLoginViewController.h"
#import <TTThemedAlertController.h>
#import <TTDeviceHelper.h>

#import <TTAccountBusiness.h>
#import "ArticleMobileNumberViewController.h"
#import "TTTrackerWrapper.h"



@interface ArticleMobileLoginViewController ()

@property(nonatomic, strong) SSThemedTextField *mobileField;
@property(nonatomic, strong) SSThemedTextField *passwordField;

@property(nonatomic, strong) SSThemedButton     *registerButton;
@property(nonatomic, strong) SSThemedButton     *retrieveButton;

@property(nonatomic, strong) SSThemedButton     *loginButton;
@property(nonatomic, strong) SSThemedView       *separatorView0;
@property(nonatomic, strong) SSThemedView       *separatorView1;


@end

@implementation ArticleMobileLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.automaticallyAdjustKeyboardOffset = YES;
        self.maximumHeightOfContent = 250;
        self.hidesBottomBarWhenPushed = YES;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.state = ArticleLoginStateMobileLogin;
    
    // Do any additional setup after loading the view.
    self.navigationBar.title = NSLocalizedString(@"手机号登录", @"手机号登录");
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle: NSLocalizedString(@"手机号登录", @"手机号登录")];
    
    
    self.mobileField = [[SSThemedTextField alloc] init];
    self.mobileField.keyboardType = UIKeyboardTypeNumberPad;
    self.mobileField.returnKeyType = UIReturnKeyNext;
    self.mobileField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.mobileField.placeholder = NSLocalizedString(@"手机号", nil);
    self.mobileField.backgroundColor = [UIColor clearColor];
    self.mobileField.font = [UIFont systemFontOfSize:[ArticleMobileLoginViewController fontSizeOfInputFiled]];
    self.mobileField.text = self.mobileNumber;
    self.mobileField.delegate = self;
    self.mobileField.textColorThemeKey = kColorText1;
    self.mobileField.placeholderColorThemeKey = kColorText3;
    [self.inputContainerView addSubview:self.mobileField];
    
    self.separatorView0 = [[SSThemedView alloc] initWithFrame:[self _separatorView0Frame]];
    self.separatorView0.backgroundColorThemeKey = kColorLine1;
    [self.inputContainerView addSubview:self.separatorView0];
    
    self.passwordField = [[SSThemedTextField alloc] init];
    self.passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordField.font = [UIFont systemFontOfSize:[ArticleMobileLoginViewController fontSizeOfInputFiled]];
    self.passwordField.returnKeyType = UIReturnKeyDone;
    self.passwordField.backgroundColor = [UIColor clearColor];
    self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordField.placeholder = NSLocalizedString(@"密码", nil);
    self.passwordField.secureTextEntry = YES;
    self.passwordField.textColorThemeKey = kColorText1;
    self.passwordField.placeholderColorThemeKey = kColorText3;
    [self.inputContainerView addSubview:self.passwordField];
    
    self.separatorView1 = [[SSThemedView alloc] initWithFrame:[self _separatorView1Frame]];
    self.separatorView1.backgroundColorThemeKey = kColorLine1;
    [self.inputContainerView addSubview:self.separatorView1];
    
    self.retrieveButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    self.retrieveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.retrieveButton.titleLabel.font = [UIFont systemFontOfSize:[ArticleMobileLoginViewController fontSizeOfInputFiled]];
    [self.retrieveButton setTitle:NSLocalizedString(@"找回密码", nil) forState:UIControlStateNormal];
    [self.retrieveButton addTarget:self action:@selector(retrieveActionFired:) forControlEvents:UIControlEventTouchUpInside];
    self.retrieveButton.backgroundColor = [UIColor clearColor];
    self.retrieveButton.titleColorThemeKey = kColorText3;
    self.retrieveButton.highlightedTitleColorThemeKey = kColorText3Highlighted;
    [self.retrieveButton sizeToFit];
    [self.inputContainerView addSubview:self.retrieveButton];
    
    
    self.loginButton = [self mobileButtonWithTitle:NSLocalizedString(@"登 录", nil) target:self action:@selector(loginButtonActionFired:)];
    [self.containerView addSubview:self.loginButton];
    
    self.registerButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [self.registerButton setTitle:NSLocalizedString(@"注册账号", nil) forState:UIControlStateNormal];
    self.registerButton.titleLabel.font = [UIFont systemFontOfSize:[ArticleMobileLoginViewController fontSizeOfRegisterButtonTitle]];
    self.registerButton.titleColorThemeKey = kColorText6;
    self.registerButton.highlightedTitleColorThemeKey = kColorText6Highlighted;
    [self.registerButton addTarget:self action:@selector(registerActionFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerButton sizeToFit];
    [self.containerView addSubview:self.registerButton];
}

- (CGRect)_separatorView1Frame
{
    return CGRectMake(0, 0, [TTDeviceHelper ssOnePixel], 14);
}

- (CGRect)_separatorView0Frame
{
    return CGRectMake(0, (self.mobileField.bottom), (self.inputContainerView.width), [TTDeviceHelper ssOnePixel]);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.inputContainerView.frame = CGRectMake(0, 30, (self.containerView.width), [ArticleMobileLoginViewController heightOfInputField] * 2 + [TTDeviceHelper ssOnePixel]);
    self.mobileField.frame = CGRectMake(10, 0, (self.inputContainerView.width) - 10, [ArticleMobileLoginViewController heightOfInputField]);
    self.separatorView0.frame = [self _separatorView0Frame];
    self.passwordField.frame = CGRectMake(10, (self.separatorView0.bottom), 0, [ArticleMobileLoginViewController heightOfInputField]);
    self.retrieveButton.origin = CGPointMake((self.inputContainerView.width) - 10 - (self.retrieveButton.width), (self.separatorView0.bottom) + (([ArticleMobileLoginViewController heightOfInputField] - (self.retrieveButton.height)) / 2));
    self.separatorView1.origin = CGPointMake((self.retrieveButton.left) - 10, (self.separatorView0.bottom) + (([ArticleMobileLoginViewController heightOfInputField] - (self.separatorView1.height)) / 2));
    self.passwordField.width = (self.separatorView1.left) - 10;
    self.loginButton.origin = CGPointMake(0, (self.inputContainerView.bottom) + 20);
    self.registerButton.origin = CGPointMake(((self.containerView.width) - (self.registerButton.width)) / 2, (self.loginButton.bottom) + 20);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self validateMobileNumber:self.mobileField.text]) {
        [self.passwordField becomeFirstResponder];
    } else {
        [self.mobileField becomeFirstResponder];
    }
}

- (BOOL)isContentValid
{
    return (self.mobileField.text.length > 0 && self.passwordField.text.length > 0 && [self validateMobileNumber:self.mobileField.text]);
}

- (void)loginButtonActionFired:(id)sender {
    if (self.mobileField.text.length == 0) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请输入手机号", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self.mobileField becomeFirstResponder];
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    if (![self validateMobileNumber:self.mobileField.text]) {
        [self alertInvalidateMobileNumberWithCompletionHandler:^{
            [self.mobileField becomeFirstResponder];
        }];
        return;
    }
    if (self.passwordField.text.length == 0) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"密码不能为空", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self.passwordField becomeFirstResponder];
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    TTAccountManager.draftMobile = self.mobileField.text;
    
    @ArticleTipAndReturnIFNetworkNotOK;
    
    /////// 友盟统计
    wrapperTrackEvent(@"login_register", @"login_moblie");
    
    __weak ArticleMobileLoginViewController *weakSelf = self;
    void (^loginMobileBlock)(NSString *, NSString *, NSString *) = ^(NSString *mobile, NSString *password, NSString *captcha) {
        [weakSelf showWaitingIndicator];
        
        [TTAccountManager startLoginWithMail:mobile password:password captcha:self.captchaValue completion:^(UIImage *captchaImage, NSError *error) {
            weakSelf.error = error;
            weakSelf.captchaImage = captchaImage;
            weakSelf.captchaValue = nil;
            if (error) {
                if (captchaImage) {
                    [weakSelf loginButtonActionFired:nil];
                } else {
                    NSDictionary *userInfo = error.userInfo;
                    if ([userInfo valueForKey:@"alert_text"]) {
                        [weakSelf dismissWaitingIndicator];
                        // 优先弹出Alert框
                        [weakSelf _gotoRetrieveViewControllerWithAlertTitle:[userInfo valueForKey:@"alert_text"]];
                    } else {
                        [weakSelf dismissWaitingIndicatorWithError:error];
                    }
                }
                /////// 友盟统计
                wrapperTrackEvent(@"login_register", @"login_error");
            } else {
                /////// 友盟统计
                wrapperTrackEvent(@"login_register", @"login_success");
                
                [weakSelf backToMainViewControllerAnimated:YES completion:weakSelf.completion];
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
                loginMobileBlock(self.mobileField.text, self.passwordField.text, alertView.captchaValue);
            }
        }];
    };
    
    if (self.captchaImage && !self.captchaValue) {
        alertCaptchaBlock(self.captchaImage, self.error, TTASMSCodeScenarioPhoneRegister);
    } else {
        loginMobileBlock(self.mobileField.text, self.passwordField.text, self.captchaValue);
    }
}

- (void)_gotoRetrieveViewControllerWithAlertTitle:(NSString *)alertTitle {
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:alertTitle message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        wrapperTrackEvent(@"login_register", @"login_pop_cancel");
    }];
    [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        ArticleMobileNumberViewController *viewController =
        [[ArticleMobileNumberViewController alloc] initWithMobileNumberUsingType:ArticleMobileNumberUsingTypeRetrieve];
        viewController.mobileNumber = self.mobileField.text;
        [self.navigationController pushViewController:viewController animated:YES];
        wrapperTrackEvent(@"login_register", @"login_pop_confirm");
    }];
    [alert showFrom:self animated:YES];
}

- (void)registerActionFired:(id)sender {
    /////// 友盟统计
    wrapperTrackEvent(@"login_register", @"click_register");
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count >= 2) {
        ArticleMobileNumberViewController *viewController = viewControllers[[viewControllers indexOfObject:self] - 1];
        if ([viewController isKindOfClass:[ArticleMobileNumberViewController class]]) {
            if (viewController.usingType == ArticleMobileNumberUsingTypeRegister) {
                viewController.mobileField.text = self.mobileField.text;
                [self goBack];
            }
            return;
        }
    }
    ArticleMobileNumberViewController *viewController =
    [[ArticleMobileNumberViewController alloc] initWithMobileNumberUsingType:ArticleMobileNumberUsingTypeRegister];
    viewController.completion = self.completion;
    viewController.mobileNumber = self.mobileField.text;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)retrieveActionFired:(id)sender {
    /////// 友盟统计
    wrapperTrackEvent(@"login_register", @"forget_password");
    ArticleMobileNumberViewController *viewController =
    [[ArticleMobileNumberViewController alloc] initWithMobileNumberUsingType:ArticleMobileNumberUsingTypeRetrieve];
    viewController.mobileNumber = self.mobileField.text;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    NSString *temp = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (temp.length > 11) {
        textField.text = [temp substringToIndex:11];
        return NO;
    }
    return YES;
}

+ (CGFloat)fontSizeOfRegisterButtonTitle
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 17.f;
    } else {
        return 15.f;
    }
}
@end

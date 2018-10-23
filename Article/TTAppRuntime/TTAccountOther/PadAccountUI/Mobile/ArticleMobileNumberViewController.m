//
//  ArticleMobileNumberViewController.m
//  Article
//
//  Created by SunJiangting on 14-7-9.
//
//

#import "ArticleMobileNumberViewController.h"
#import <TTDeviceHelper.h>
#import <UIImage+TTThemeExtension.h>
#import <TTThemedAlertController.h>

#import <TTAccountBusiness.h>
#import "ArticleMobileLoginViewController.h"
#import "ArticleMobileRegisterViewController.h"
#import "ArticleMobileRetrieveViewController.h"
#import "ArticleMobileBindViewController.h"
#import "SSWebViewController.h"
#import "ArticleURLSetting.h"
#import "TTTrackerWrapper.h"
#import "TTUserPrivacyView.h"
#import "TTUIResponderHelper.h"
#import "UIApplication+UserPrivacyPolicy.h"

#define kNewContainerViewLeftPadding 30
#define kNewContainerViewRightPadding 30

@interface ArticleMobileNumberViewController ()

@property(nonatomic, strong) SSThemedTextField  *mobileField;

@property(nonatomic, strong) UIButton           *radioButton;
@property(nonatomic, strong) SSThemedButton     *termButton;

@property(nonatomic, strong) SSThemedButton     *nextButton;
@property(nonatomic, strong) SSThemedLabel      *areaLabel;
@property(nonatomic, strong) SSThemedView       *separatorView;
@property(nonatomic, strong) SSThemedLabel      *leftLabel;

@property(nonatomic, strong) SSThemedLabel      *remindLabel;
@property(nonatomic, strong) TTUserPrivacyView  *privacyView;

@property(nonatomic, assign) ArticleMobileNumberUsingType usingType;

@end

@implementation ArticleMobileNumberViewController

- (instancetype)initWithMobileNumberUsingType:(ArticleMobileNumberUsingType)usingType
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.usingType = usingType;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithMobileNumberUsingType:ArticleMobileNumberUsingTypeRegister];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *title = NSLocalizedString(@"手机号注册", nil);
    if (self.usingType == ArticleMobileNumberUsingTypeRetrieve) {
        title = NSLocalizedString(@"找回密码", nil);
    } else if (self.usingType == ArticleMobileNumberUsingTypeBind) {
        title = NSLocalizedString(@"绑定手机号", nil);
    }
    if (self.usingType == ArticleMobileNumberUsingTypeRegister) {
        self.navigationBar.rightBarView = [SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:@"登录" target:self action:@selector(loginActionFired:)];
    }
    self.navigationBar.title = title;
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle: title];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navigationBar.rightBarView];
    
    if (self.usingType == ArticleMobileNumberUsingTypeBind) {
        [self configureMobileBindView];
    } else {
        [self configureMobileRegisterOrRetrieveView];
    }
    
    [TTTracker eventV3:@"auth_mobile_show" params:@{@"source":@"settings"}];
}

- (void)configureMobileBindView
{
    if (self.inputContainerView.superview) {
        [self.inputContainerView removeFromSuperview];
    }
    
    //提示tile
    self.remindLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    self.remindLabel.backgroundColor = [UIColor clearColor];
    self.remindLabel.text = @"为了你的账号安全，请绑定手机号";
    self.remindLabel.numberOfLines = 0;
    self.remindLabel.textColorThemeKey = kColorText1;
    self.remindLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
    self.remindLabel.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:self.remindLabel];
    
    //手机号输入框
    self.mobileField = [[SSThemedTextField alloc] init];
    self.mobileField.keyboardType = UIKeyboardTypeNumberPad;
    self.mobileField.returnKeyType = UIReturnKeyDone;
    self.mobileField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.mobileField.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.mobileField.borderColorThemeKey = kColorLine9;
    self.mobileField.backgroundColorThemeKey = kColorBackground20;
    self.mobileField.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
    self.mobileField.textColorThemeKey = kColorText1;
    self.mobileField.placeholderColorThemeKey = kColorText9;
    self.mobileField.textAlignment = NSTextAlignmentLeft;
    self.mobileField.layer.masksToBounds = YES;
    self.mobileField.edgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);  //缩进40px
    self.mobileField.placeholder = NSLocalizedString(@"请输入手机号", nil);
    self.mobileField.text = self.mobileNumber;
    [self.containerView addSubview:self.mobileField];
    
    //下一步按钮
    self.nextButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [self.nextButton setTitle:NSLocalizedString(@"下一步", nil)
                     forState:UIControlStateNormal];
    self.nextButton.titleColorThemeKey = kColorText8;
    self.nextButton.highlightedTitleColorThemeKey = kColorText8Highlighted;
    [self.nextButton addTarget:self
                        action:@selector(nextButtonActionFired:)
              forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
    self.nextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.nextButton.layer.masksToBounds = YES;
    self.nextButton.backgroundColorThemeKey = kColorBackground7;
    self.nextButton.highlightedBackgroundColorThemeKey = kColorBackground7Highlighted;
    self.nextButton.highlightedBorderColorThemeKey = kColorText7Highlighted;
    [self.containerView addSubview:self.nextButton];
    
    self.isBindingVC = YES;
    self.nextButton = [self mobileButtonWithTitle:NSLocalizedString(@"下一步", nil) target:self action:@selector(nextButtonActionFired:)];
    [self.containerView addSubview:self.nextButton];
    
    //用户协议声明
    [self.containerView addSubview:self.privacyView];
}

- (void)configureMobileRegisterOrRetrieveView
{
    self.areaLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    self.areaLabel.backgroundColor = [UIColor clearColor];
    self.areaLabel.font = [UIFont systemFontOfSize:[ArticleMobileNumberViewController fontSizeOfInputFiled]];
    self.areaLabel.text = @"+86";
    self.areaLabel.textColorThemeKey = kColorText3;
    [self.areaLabel sizeToFit];
    self.areaLabel.origin = CGPointMake(10, ([ArticleMobileNumberViewController heightOfInputField] - (self.areaLabel.height)) / 2);
    [self.inputContainerView addSubview:self.areaLabel];
    
    self.separatorView = [[SSThemedView alloc] initWithFrame:CGRectMake((self.areaLabel.right) + 10, ([ArticleMobileNumberViewController heightOfInputField] - 14) / 2, [TTDeviceHelper ssOnePixel], 14)];
    self.separatorView.backgroundColorThemeKey = kColorLine1;
    [self.inputContainerView addSubview:self.separatorView];
    
    self.mobileField = [[SSThemedTextField alloc] initWithFrame:[self _mobileFieldFrame]];
    self.mobileField.keyboardType = UIKeyboardTypeNumberPad;
    self.mobileField.returnKeyType = UIReturnKeyNext;
    self.mobileField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.mobileField.placeholder = NSLocalizedString(@"请输入手机号", nil);
    self.mobileField.text = self.mobileNumber;
    //    self.mobileField.delegate = self;
    self.mobileField.font = [UIFont systemFontOfSize:[ArticleMobileNumberViewController fontSizeOfInputFiled]];
    self.mobileField.textColorThemeKey = kColorText1;
    self.mobileField.placeholderColorThemeKey = kColorText3;
    [self.inputContainerView addSubview:self.mobileField];
    
    self.nextButton = [self mobileButtonWithTitle:NSLocalizedString(@"下一步", nil) target:self action:@selector(nextButtonActionFired:)];
    self.isBindingVC = NO;
    [self.containerView addSubview:self.nextButton];
    
    if (self.usingType == ArticleMobileNumberUsingTypeRegister) {
        self.radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.radioButton addTarget:self action:@selector(radioButtonActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.radioButton setImage:[UIImage themedImageNamed:@"hookicon_sdk_login"] forState:UIControlStateNormal];
        [self.radioButton setImage:[UIImage themedImageNamed:@"hookicon_sdk_login_press"] forState:UIControlStateHighlighted];
        [self.radioButton setImage:[UIImage themedImageNamed:@"hookicon_sdk_login_press"] forState:UIControlStateSelected];
        self.radioButton.selected = YES;
        [self.radioButton sizeToFit];
        [self.containerView addSubview:self.radioButton];
        
        self.leftLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        self.leftLabel.textColorThemeKey = kColorText3;
        self.leftLabel.text = NSLocalizedString(@"同意", nil);
        self.leftLabel.backgroundColor = [UIColor clearColor];
        self.leftLabel.font = [UIFont systemFontOfSize:[ArticleMobileNumberViewController fontSizeOfTermButtonTitle]];
        [self.leftLabel sizeToFit];
        [self.containerView addSubview:self.leftLabel];
        
        self.termButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.termButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.termButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.termButton setTitle:NSLocalizedString(@"好多房用户协议", nil) forState:UIControlStateNormal];
        self.termButton.titleLabel.font = [UIFont systemFontOfSize:[ArticleMobileNumberViewController fontSizeOfTermButtonTitle]];
        self.termButton.titleColorThemeKey = kColorText4;
        self.termButton.highlightedTitleColorThemeKey = kColorText4Highlighted;
        [self.termButton addTarget:self action:@selector(termButtonActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.termButton sizeToFit];
        [self.containerView addSubview:self.termButton];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    wrapperTrackEvent(@"login_register", @"mobile_register_enter");
    [self.mobileField becomeFirstResponder];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.usingType == ArticleMobileNumberUsingTypeBind) {
        self.containerView.frame = [self _bindContainerViewFrame];
        self.remindLabel.frame = [self _bindRemindLabelFrame];
        self.mobileField.frame = [self _bindMobileFieldFrame];
        self.nextButton.frame = [self _bindNextButtonFrame];
        self.privacyView.frame = [self _bindPrivacyViewFrame];
        self.mobileField.layer.cornerRadius = self.mobileField.height / 2.f;
        self.nextButton.layer.cornerRadius = self.nextButton.height/ 2.f;
    } else {
        self.inputContainerView.frame = CGRectMake(0, 30, (self.containerView.width), [ArticleMobileNumberViewController heightOfInputField]);
        self.mobileField.frame = [self _mobileFieldFrame];
        self.nextButton.origin = CGPointMake(0, (self.inputContainerView.bottom) + 20);
        CGFloat totalWidth = (self.radioButton.width) + 5 + (self.leftLabel.width) + (self.termButton.width);
        
        if (self.radioButton) {
            self.radioButton.origin = CGPointMake(((self.containerView.width) - totalWidth) / 2, (self.nextButton.bottom) + 15);
            
            self.leftLabel.left = (self.radioButton.right) + 5;
            self.leftLabel.centerY = self.radioButton.centerY;
            
            self.termButton.left = (self.leftLabel.right);
            self.termButton.centerY = self.radioButton.centerY;
        }
    }
}

- (void)termButtonActionFired:(id)sender
{
    /////// 友盟统计
    wrapperTrackEvent(@"login_register", @"click_agreement");
    SSWebViewController *webViewController = [[SSWebViewController alloc] initWithSupportIPhoneRotate:NO];
    [webViewController setTitleText:NSLocalizedString(@"好多房用户协议", nil)];
    [webViewController requestWithURLString:[ArticleURLSetting userProtocolURLString]];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)loginActionFired:(id)sender
{
    [self _goLoginViewController];
}

- (void)_goLoginViewController
{
    wrapperTrackEvent(@"login_register", @"click_login");
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count >= 2) {
        ArticleMobileLoginViewController *viewController = viewControllers[[viewControllers indexOfObject:self] - 1];
        if ([viewController isKindOfClass:[ArticleMobileLoginViewController class]]) {
            viewController.mobileField.text = self.mobileField.text;
            [self goBack];
            return;
        }
    }
    ArticleMobileLoginViewController *loginViewController = [[ArticleMobileLoginViewController alloc] init];
    loginViewController.completion = self.completion;
    loginViewController.mobileNumber = self.mobileField.text;
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (void)goBack
{
    [super goBack];
    if (self.completion) {
        self.completion(NO);
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self.radioButton setImage:[UIImage themedImageNamed:@"hookicon_sdk_login"] forState:UIControlStateNormal];
    [self.radioButton setImage:[UIImage themedImageNamed:@"hookicon_sdk_login_press"] forState:UIControlStateHighlighted];
    [self.radioButton setImage:[UIImage themedImageNamed:@"hookicon_sdk_login_press"] forState:UIControlStateSelected];
}

- (void)backgroundTapActionFired:(id)sender
{
    if ([self.mobileField isFirstResponder]) {
        [self.mobileField resignFirstResponder];
    }
}

- (void)radioButtonActionFired:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self refreshMobileButtonIfNeeded];
}

- (BOOL)isContentValid
{
    if (self.usingType == ArticleMobileNumberUsingTypeBind) {
        return (!self.privacyView || [self.privacyView isChecked]) && (self.mobileField.text.length > 0 && [self validateMobileNumber:self.mobileField.text]);
    } else {
        return ((!self.radioButton || self.radioButton.selected) && self.mobileField.text.length > 0 && [self validateMobileNumber:self.mobileField.text]);
    }
}

- (void)nextButtonActionFired:(id)sender
{
    if (self.usingType == ArticleMobileNumberUsingTypeBind) {
        if (self.privacyView && ![self.privacyView isChecked]) {
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请同意《好多房用户协议》", nil) preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
            [alert showFrom:self animated:YES];
            return;
        }
    } else {
        if (self.radioButton && !self.radioButton.selected) {
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请同意《好多房用户协议》", nil) preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
            [alert showFrom:self animated:YES];
            return;
        }
    }
    
    if (self.mobileField.text.length == 0) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请输入手机号", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self.mobileField becomeFirstResponder];
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    if (![self validateMobileNumber:self.mobileField.text]) {
        // 手机号码不合法
        [self alertInvalidateMobileNumberWithCompletionHandler:^{
            [self.mobileField becomeFirstResponder];
        }];
        return;
    }
    
    TTAccountManager.draftMobile = self.mobileField.text;
    
    @ArticleTipAndReturnIFNetworkNotOK;
    switch (self.usingType) {
        case ArticleMobileNumberUsingTypeBind: {
            /// 绑定
            [self bindPhoneNumber];
        }
            break;
        case ArticleMobileNumberUsingTypeRegister: {
            [self registerPhoneNumber];
        }
            break;
        case ArticleMobileNumberUsingTypeRetrieve: {
            [self retrievePhoneNumber];
        }
            break;
        default:
            break;
    }
}

- (void)checkCaptchaImage
{
    
}

- (void)registerPhoneNumber
{
    __weak ArticleMobileNumberViewController *weakSelf = self;
    void (^registerBlock)(NSString *, NSString *) = ^(NSString *mobile, NSString *captcha) {
        NSDictionary *previousMobileInformation = [[self class] previousMobileCodeInformation];
        NSTimeInterval timeInterval = [[previousMobileInformation valueForKey:@"time"] doubleValue];
        NSInteger retryTime = [[previousMobileInformation valueForKey:@"retryTime"] intValue];
        NSInteger timeOffset = [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
        if (([[previousMobileInformation valueForKey:@"mobile"] isEqualToString:mobile] &&
             ([[previousMobileInformation valueForKey:@"type"] intValue] == TTASMSCodeScenarioPhoneRegister ||
              [[previousMobileInformation valueForKey:@"type"] intValue] == TTASMSCodeScenarioPhoneRegisterRetry)) &&
            (retryTime > timeOffset)) {
            /// 已经发送过验证码
            NSNumber *retryTime = [previousMobileInformation valueForKey:@"retryTime"];
            
            /////// 友盟统计
            wrapperTrackEvent(@"login_register", @"register_next");

            ArticleMobileRegisterViewController *viewController = [[ArticleMobileRegisterViewController alloc] init];
            viewController.mobileNumber = self.mobileField.text;
            viewController.completion = self.completion;
            viewController.timeoutInterval = retryTime.intValue;
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        } else {
            [self showWaitingIndicator];
            
            [TTTracker eventV3:@"auth_mobile_send_verification_code" params:@{@"source":@"settings"}];
            
            [TTAccountManager startSendCodeWithPhoneNumber:mobile captcha:captcha type:TTASMSCodeScenarioPhoneRegister unbindExist:NO completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
                weakSelf.captchaImage = captchaImage;
                weakSelf.captchaValue = nil;
                weakSelf.error = error;
                if (!error) {
                    ArticleMobileRegisterViewController *viewController = [[ArticleMobileRegisterViewController alloc] init];
                    viewController.completion = weakSelf.completion;
                    viewController.mobileNumber = self.mobileField.text;
                    viewController.timeoutInterval = retryTime.intValue;
                    [weakSelf.navigationController pushViewController:viewController animated:YES];
                    
                    /////// 友盟统计
                    wrapperTrackEvent(@"login_register", @"register_next");
                    
                    NSMutableDictionary *information = [NSMutableDictionary dictionaryWithCapacity:2];
                    [information setValue:@(TTASMSCodeScenarioPhoneRegister) forKey:@"type"];
                    [information setValue:retryTime forKey:@"retryTime"];
                    [information setValue:mobile forKey:@"mobile"];
                    [information setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"time"];
                    [[self class] setPreviousMobileCodeInformation:information];
                    [weakSelf dismissWaitingIndicator];
                } else {
                    /////// 友盟统计
                    wrapperTrackEvent(@"login_register", @"register_next_error");
                    
                    if (captchaImage) {
                        [weakSelf dismissWaitingIndicator];
                        [weakSelf registerPhoneNumber];
                    } else {
                        if (error.code == kPRHasRegisteredErrorCode) {
                            /// 该账号已经注册
                            NSString *tip = [NSString stringWithFormat:NSLocalizedString(@"手机号%@已注册，可以直接登录", nil),
                             weakSelf.mobileField.text];
                            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:tip message:nil preferredType:TTThemedAlertControllerTypeAlert];
                            [alert addActionWithTitle:NSLocalizedString(@"去登录", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                                if (weakSelf.navigationController.viewControllers.count >= 2) {
                                    ArticleMobileLoginViewController *viewController = weakSelf.navigationController.viewControllers[[weakSelf.navigationController.viewControllers indexOfObject:weakSelf] - 1];
                                    if ([viewController isKindOfClass:[ArticleMobileLoginViewController class]]) {
                                        viewController.mobileField.text = weakSelf.mobileField.text;
                                        [weakSelf goBack];
                                    } else {
                                        UINavigationController *navigationController = weakSelf.navigationController;
                                        [weakSelf.navigationController popViewControllerAnimated:NO];
                                        ArticleMobileLoginViewController *loginViewController = [[ArticleMobileLoginViewController alloc] init];
                                        loginViewController.completion = weakSelf.completion;
                                        loginViewController.mobileNumber = weakSelf.mobileField.text;
                                        [navigationController pushViewController:loginViewController animated:YES];
                                    }
                                } else {
                                    [weakSelf goBack];
                                }
                            }];
                            [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                                [weakSelf.mobileField becomeFirstResponder];
                            }];
                            [alert showFrom:self animated:YES];
                            [weakSelf dismissWaitingIndicator];
                        } else {
                            [weakSelf dismissWaitingIndicatorWithError:error];
                        }
                    }
                }
            }];
        }
    };
    
    void (^alertCaptchaBlock)(UIImage *, NSError *, TTASMSCodeScenarioType) =
    ^(UIImage *captcha, NSError *error, TTASMSCodeScenarioType scenario) {
        ArticleMobileCaptchaAlertView *alertView = [[ArticleMobileCaptchaAlertView alloc] initWithCaptchaImage:captcha];
        alertView.error = error;
        [alertView showWithDismissBlock:^(ArticleMobileCaptchaAlertView *alertView, NSInteger buttonIndex) {
            self.captchaValue = alertView.captchaValue;
            self.captchaImage = alertView.captchaImage;
            if (alertView.captchaValue.length > 0) {
                registerBlock(self.mobileField.text, alertView.captchaValue);
            }
        }];
    };
    
    if (self.captchaImage && !self.captchaValue) {
        alertCaptchaBlock(self.captchaImage, self.error, TTASMSCodeScenarioPhoneRegister);
    } else {
        registerBlock(self.mobileField.text, self.captchaValue);
    }
}

- (void)retrievePhoneNumber
{
    __weak ArticleMobileNumberViewController *weakSelf = self;
    void (^registerBlock)(NSString *, NSString *) = ^(NSString *mobile, NSString *captcha) {
        NSDictionary *previousMobileInformation = [[self class] previousMobileCodeInformation];
        NSTimeInterval timeInterval = [[previousMobileInformation valueForKey:@"time"] doubleValue];
        NSInteger retryTime = [[previousMobileInformation valueForKey:@"retryTime"] intValue];
        NSInteger timeOffset = [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
        
        if (([[previousMobileInformation valueForKey:@"mobile"] isEqualToString:mobile] &&
             ([[previousMobileInformation valueForKey:@"type"] intValue] == TTASMSCodeScenarioFindPassword ||
              [[previousMobileInformation valueForKey:@"type"] intValue] == TTASMSCodeScenarioFindPasswordRetry)) &&
            (retryTime > timeOffset)) {
            /// 已经发送过验证码
            NSNumber *retryTime = [previousMobileInformation valueForKey:@"retryTime"];
            /////// 友盟统计
            // TODO: AccountLog3.0
            wrapperTrackEvent(@"login_register", @"find_password_next");
            
            ArticleMobileRetrieveViewController *viewController = [[ArticleMobileRetrieveViewController alloc] init];
            viewController.mobileNumber = self.mobileField.text;
            viewController.timeoutInterval = retryTime.intValue;
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        } else {
            [self showWaitingIndicator];
            
            [TTAccountManager startSendCodeWithPhoneNumber:mobile captcha:captcha type:TTASMSCodeScenarioFindPassword unbindExist:NO completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
                
                weakSelf.captchaImage = captchaImage;
                weakSelf.captchaValue = nil;
                weakSelf.error = error;
                if (!error) {
                    /////// 友盟统计
                    // TODO: AccountLog3.0
                    wrapperTrackEvent(@"login_register", @"find_password_next");
                    
                    ArticleMobileRetrieveViewController *viewController = [[ArticleMobileRetrieveViewController alloc] init];
                    viewController.mobileNumber = self.mobileField.text;
                    viewController.timeoutInterval = retryTime.intValue;
                    [weakSelf.navigationController pushViewController:viewController animated:YES];
                    
                    NSMutableDictionary *information = [NSMutableDictionary dictionaryWithCapacity:2];
                    [information setValue:@(TTASMSCodeScenarioFindPassword) forKey:@"type"];
                    [information setValue:retryTime forKey:@"retryTime"];
                    [information setValue:mobile forKey:@"mobile"];
                    [information setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"time"];
                    [[self class] setPreviousMobileCodeInformation:information];
                    [weakSelf dismissWaitingIndicator];
                } else {
                    /////// 友盟统计
                    // TODO: AccountLog3.0
                    wrapperTrackEvent(@"login_register", @"find_password_next_error");
                    if (captchaImage) {
                        [weakSelf dismissWaitingIndicator];
                        [weakSelf retrievePhoneNumber];
                    } else {
                        [weakSelf dismissWaitingIndicatorWithError:error];
                    }
                }
            }];
        }
    };
    
    void (^alertCaptchaBlock)(UIImage *, NSError *, TTASMSCodeScenarioType) =
    ^(UIImage *captcha, NSError *error, TTASMSCodeScenarioType scenario) {
        ArticleMobileCaptchaAlertView *alertView = [[ArticleMobileCaptchaAlertView alloc] initWithCaptchaImage:captcha];
        alertView.error = error;
        [alertView showWithDismissBlock:^(ArticleMobileCaptchaAlertView *alertView, NSInteger buttonIndex) {
            self.captchaValue = alertView.captchaValue;
            self.captchaImage = alertView.captchaImage;
            if (alertView.captchaValue.length > 0) {
                registerBlock(self.mobileField.text, alertView.captchaValue);
            }
        }];
    };
    
    if (self.captchaImage && !self.captchaValue) {
        alertCaptchaBlock(self.captchaImage, self.error, TTASMSCodeScenarioFindPassword);
    } else {
        registerBlock(self.mobileField.text, self.captchaValue);
    }
}

- (void)bindPhoneNumber
{
    __weak ArticleMobileNumberViewController *weakSelf = self;
    void (^bindMobileBlock)(NSString *, NSString *) = ^(NSString *mobile, NSString *captcha) {
        NSDictionary *previousMobileInformation = [[self class] previousMobileCodeInformation];
        NSTimeInterval timeInterval = [[previousMobileInformation valueForKey:@"time"] doubleValue];
        NSInteger retryTime = [[previousMobileInformation valueForKey:@"retryTime"] intValue];
        NSInteger timeOffset = [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
        if (([[previousMobileInformation valueForKey:@"mobile"] isEqualToString:mobile] &&
             ([[previousMobileInformation valueForKey:@"type"] intValue] == TTASMSCodeScenarioBindPhone ||
              [[previousMobileInformation valueForKey:@"type"] intValue] == TTASMSCodeScenarioBindPhoneRetry)) &&
            (retryTime > timeOffset)) {
            /// 已经发送过验证码
            NSNumber *retryTime = [previousMobileInformation valueForKey:@"retryTime"];
            /////// 友盟统计
            wrapperTrackEvent(@"login_register", @"register_next");
            
            ArticleMobileBindViewController *viewController = [[ArticleMobileBindViewController alloc] init];
            viewController.mobileNumber = weakSelf.mobileField.text;
            viewController.timeoutInterval = retryTime.intValue;
            viewController.completion = weakSelf.completion;
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        } else {
            [self showWaitingIndicator];
            
            [TTAccountManager startSendCodeWithPhoneNumber:mobile captcha:captcha type:TTASMSCodeScenarioBindPhone unbindExist:NO completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
                
                weakSelf.captchaImage = captchaImage;
                weakSelf.captchaValue = nil;
                weakSelf.error = error;
                if (!error) {
                    /////// 友盟统计
                    wrapperTrackEvent(@"login_register", @"register_next");
                    
                    ArticleMobileBindViewController *viewController = [[ArticleMobileBindViewController alloc] initWithNibName:nil bundle:nil];
                    viewController.mobileNumber = self.mobileField.text;
                    viewController.timeoutInterval = retryTime.intValue;
                    viewController.completion = weakSelf.completion;
                    [weakSelf.navigationController pushViewController:viewController animated:YES];
                    
                    NSMutableDictionary *information =
                    [NSMutableDictionary dictionaryWithCapacity:2];
                    [information setValue:@(TTASMSCodeScenarioBindPhone) forKey:@"type"];
                    [information setValue:retryTime forKey:@"retryTime"];
                    [information setValue:mobile forKey:@"mobile"];
                    [information setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"time"];
                    [[self class] setPreviousMobileCodeInformation:information];
                    [weakSelf dismissWaitingIndicator];
                } else {
                    
                    if ([error.userInfo[@"error_code"] intValue] == 1001) {
                        [weakSelf dismissWaitingIndicator];
                        [weakSelf switchBind:error];
                    } else {
                        /////// 友盟统计
                        wrapperTrackEvent(@"login_register", @"register_next_error");
                        
                        if (captchaImage) {
                            [weakSelf dismissWaitingIndicator];
                            [weakSelf bindPhoneNumber];
                        } else {
                            [weakSelf dismissWaitingIndicatorWithError:error];
                        }
                    }
                }
            }];
        }
    };
    
    void (^alertCaptchaBlock)(UIImage *, NSError *, TTASMSCodeScenarioType) =
    ^(UIImage *captcha, NSError *error, TTASMSCodeScenarioType scenario) {
        ArticleMobileCaptchaAlertView *alertView = [[ArticleMobileCaptchaAlertView alloc] initWithCaptchaImage:captcha];
        alertView.error = error;
        [alertView showWithDismissBlock:^(ArticleMobileCaptchaAlertView *alertView, NSInteger buttonIndex) {
            self.captchaValue = alertView.captchaValue;
            self.captchaImage = alertView.captchaImage;
            if (alertView.captchaValue.length > 0) {
                bindMobileBlock(self.mobileField.text, alertView.captchaValue);
            }
        }];
    };
    
    if (self.captchaImage && !self.captchaValue) {
        alertCaptchaBlock(self.captchaImage, self.error, TTASMSCodeScenarioBindPhone);
    } else {
        bindMobileBlock(self.mobileField.text, self.captchaValue);
    }
}


- (void)switchBind:(NSError*)error
{
    //绑定手机号时提示已绑定其他账号
    wrapperTrackEvent(@"login", @"binding_mobile_error");
    __weak typeof(self) wself = self;
    TTAccountAlertView *alert = [[TTAccountAlertView alloc] initWithTitle:[error.userInfo objectForKey:@"description"] message:[error.userInfo objectForKey:@"dialog_tips"] cancelBtnTitle:@"取消" confirmBtnTitle:@"放弃原账号" animated:YES tapCompletion:^(TTAccountAlertCompletionEventType type) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            //绑定手机号时提示已绑定其他账号，点击放弃原账号
            [TTTracker eventV3:@"auth_mobile_bindaccount_tip_next" params:@{@"source":@"settings"}];
            
            TTAccountLoginAlert *loginAlert = [[TTAccountLoginAlert alloc] initPhoneNumberVerifyAlertWithActionType:TTAccountLoginAlertActionTypePhoneNumSwitch phoneNum:wself.mobileField.text title:@"输入验证码" placeholder:nil tip:[NSString stringWithFormat:@"已向手机号 %@ 发送验证码",wself.mobileField.text] cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type) {
                
                if (type == TTAccountAlertCompletionEventTypeDone) {
                    //绑定手机号时提示已绑定其他账号，成功放弃原账号
                    [TTTracker eventV3:@"auth_mobile_relieve_confirm" params:@{@"source":@"settings"}];
                    if (wself.completion) {
                        wself.completion(ArticleLoginStateMobileBind);
                    }
                    [wself.navigationController popViewControllerAnimated:YES];
                    
                } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                    [TTTracker eventV3:@"auth_mobile_relieve_cancel" params:@{@"source":@"settings"}];
                }
            }];
            [loginAlert show];
        } else if (type == TTAccountAlertCompletionEventTypeCancel) {
            //绑定手机号时提示已绑定其他账号,点击取消
            [TTTracker eventV3:@"auth_mobile_bindaccount_tip_cancel" params:@{@"source":@"settings"}];
        }
    }];
    
    [alert show];
}

#pragma mark - UITextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        if (textField.text.length == 11) {
            [self.nextButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        } else {
            [textField resignFirstResponder];
        }
        return NO;
    }
    NSString *temp = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (temp.length > 11) {
        textField.text = [temp substringToIndex:11];
        return NO;
    }
    return YES;
}

- (void)mobileFieldValueChanged:(UITextField *)textField
{
    self.nextButton.enabled = (textField.text.length > 0);
}

#pragma mark - frame helper

- (CGRect)_bindContainerViewFrame
{
    CGFloat containerWidth = [TTUIResponderHelper splitViewFrameForView:self.view].size.width - [TTDeviceUIUtils tt_newPadding:kNewContainerViewLeftPadding] - [TTDeviceUIUtils tt_newPadding:kNewContainerViewRightPadding];
    
    CGFloat containerHeight = self.view.frame.size.height - CGRectGetMaxY(self.navigationBar.frame);
    
    CGFloat leftPadding = [TTDeviceUIUtils tt_newPadding:kNewContainerViewLeftPadding];
    if ([TTDeviceHelper isPadDevice]) {
        leftPadding = leftPadding + [TTUIResponderHelper splitViewFrameForView:self.view].origin.x;
    }
    
    CGFloat topPadding = CGRectGetMaxY(self.navigationBar.frame);
    
    return CGRectMake(leftPadding, topPadding, containerWidth, containerHeight);
}

- (CGRect)_bindRemindLabelFrame
{
    return CGRectMake(0, [TTDeviceUIUtils tt_newPadding:20], (self.containerView.width), 18);
}

- (CGRect)_bindMobileFieldFrame
{
    CGFloat topPadding = CGRectGetMaxY(self.remindLabel.frame) + [TTDeviceUIUtils tt_newPadding:20];
    return CGRectMake(0,topPadding , (self.containerView.width), [self _bindInputContainViewAndNextButtonHeight:46]);
}

- (CGRect)_bindNextButtonFrame
{
    CGFloat topPadding = CGRectGetMaxY(self.mobileField.frame) + [TTDeviceUIUtils tt_newPadding:24];
    return CGRectMake(0, topPadding,(self.containerView.width), [self _bindInputContainViewAndNextButtonHeight:46]);
}

- (CGRect)_bindPrivacyViewFrame
{
    CGFloat topPadding = CGRectGetMaxY(self.nextButton.frame);
    CGFloat leftPadding = (self.containerView.width - self.privacyView.width)/2.f;
    
    return CGRectMake(leftPadding, topPadding, self.privacyView.width, self.privacyView.height);
}

- (CGRect)_mobileFieldFrame
{
    return CGRectMake((self.separatorView.right) + 10, 0, (self.inputContainerView.width) - (self.separatorView.right) - 10, [ArticleMobileNumberViewController heightOfInputField]);
}

- (CGFloat)_bindInputContainViewAndNextButtonHeight:(CGFloat)normalHeight
{
    CGFloat size = normalHeight;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return ceil(size * 1.3);
        case TTDeviceMode736: return ceil(size);
        case TTDeviceMode667:
        case TTDeviceMode812: return ceil(size);
        case TTDeviceMode568: return ceil(size * 0.9);
        case TTDeviceMode480: return ceil(size * 0.9);
    }
}

+ (CGFloat)fontSizeOfTermButtonTitle
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 14.f;
    } else {
        return 12.f;
    }
}

#pragma mark - Getter/Setter

- (TTUserPrivacyView *)privacyView
{
    if (!_privacyView) {
        _privacyView = [TTUserPrivacyView new];
        
        __weak typeof(self) weakSelf = self;
        _privacyView.viewPrivacyHandler = ^(void) {
            [weakSelf refreshMobileButtonIfNeeded];
            [UIApplication openPrivacyProtectionFromViewController:weakSelf.navigationController
                                                      useBarHeight:NO];
        };
        
        _privacyView.viewUserAgreementHandler = ^(void) {
            [weakSelf refreshMobileButtonIfNeeded];
            [UIApplication openUserAgreementFromViewController:weakSelf.navigationController
                                                  useBarHeight:NO];
        };
        
        _privacyView.viewCheckActionHandler = ^(void) {
            [weakSelf refreshMobileButtonIfNeeded];
        };
        
        [_privacyView layoutIfNeeded];
    }
    return _privacyView;
}

@end

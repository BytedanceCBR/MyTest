//
//  TTAccountLoginQuickRetrieveViewController.m
//  TTAccountLogin
//
//  Created by huic on 16/3/21.
//
//

#import "TTAccountLoginQuickRetrieveViewController.h"
#import <TTIndicatorView.h>
#import <UIViewAdditions.h>
#import "TTAccountLoginAlert.h"



@interface TTAccountLoginQuickRetrieveViewController ()
@property (nonatomic,   copy) NSString *phoneNumberString;

@property (nonatomic, strong) SSThemedLabel *upInfoLabel;
@property (nonatomic, strong) SSThemedLabel *bottomInfoLabel;
@property (nonatomic, strong) SSThemedView  *areaSeparatorView;
@property (nonatomic, strong) SSThemedLabel *areaLabel;
@property (nonatomic, strong) SSThemedView  *areaView;
@end

@implementation TTAccountLoginQuickRetrieveViewController

- (instancetype)init
{
    if (self = [super init]) {
        if ([TTNavigationController refactorNaviEnabled] && [TTDeviceHelper isPadDevice]) {
            self.ttNeedHideBottomLine = YES;
            self.ttNeedTopExpand = NO;
            self.ttNaviTranslucent = YES;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.state = TTAccountLoginQuickRetrieveStateNext;
    
    self.phoneNumberString = nil;
    
    [self initSubviews];
    [self refreshSubviews];
}

#pragma mark - init

- (void)initSubviews
{
    //隐藏第三方登录
    self.platformLoginView.hidden = YES;
    
    //顶部增加提示Label
    [self.view addSubview:self.upInfoLabel];
    
    self.captchaInput.field.secureTextEntry = YES;
    self.captchaInput.field.keyboardType = UIKeyboardTypeDefault;
    self.captchaInput.field.placeholder = NSLocalizedString(@"请输入新密码(6-20位英文或数字)", nil);
    [self.mobileInput.resendButton addTarget:self action:@selector(resendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - layout

- (void)refreshSubviews
{
    [self refreshRegisterButton];
    
    if (self.state == TTAccountLoginQuickRetrieveStateNext) {
        self.captchaInput.hidden = YES;
        self.bottomInfoLabel.hidden = YES;
        self.mobileInput.field.placeholder = NSLocalizedString(@"手机号", nil);
        self.mobileInput.field.rightViewMode = UITextFieldViewModeNever;
        self.mobileInput.field.leftView = self.areaView;
        self.mobileInput.field.leftViewMode = UITextFieldViewModeAlways;
        
        [self.registerButton setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    } else if (self.state == TTAccountLoginQuickRetrieveStateSubmit) {
        //提交
        self.captchaInput.hidden = NO;
        self.bottomInfoLabel.hidden = NO;
        self.mobileInput.field.text = @"";
        self.mobileInput.field.placeholder = NSLocalizedString(@"输入验证码", nil);
        self.mobileInput.field.rightViewMode = UITextFieldViewModeAlways;
        self.mobileInput.field.leftViewMode = UITextFieldViewModeNever;
        
        [self.registerButton setTitle:NSLocalizedString(@"提交", nil) forState:UIControlStateNormal];
        self.bottomInfoLabel.text = [NSString stringWithFormat:@"已向手机号 %@ 发送验证码", self.mobileInput.field.text];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 上方提示文字布局
    _upInfoLabel.centerX = self.view.width / 2;
    _upInfoLabel.bottom = self.upInfoContainerView.bottom;
    
    if (self.state == TTAccountLoginQuickRetrieveStateNext) {
        self.registerButton.size = CGSizeMake(self.view.width - kTTAccountLoginInputFieldLeftMargin - kTTAccountLoginInputFieldRightMargin, kTTAccountLoginInputFieldHeight);
        self.registerButton.top = self.mobileInput.bottom + kTTAccountLoginInputFieldVerticalMargin;
        self.registerButton.left = kTTAccountLoginInputFieldLeftMargin;
        
    } else if (self.state == TTAccountLoginQuickRetrieveStateSubmit) {
        self.captchaInput.size = CGSizeMake(self.view.width - kTTAccountLoginInputFieldLeftMargin - kTTAccountLoginInputFieldRightMargin, kTTAccountLoginInputFieldHeight);
        self.captchaInput.top = self.mobileInput.bottom + kTTAccountLoginInputFieldVerticalMargin;
        self.captchaInput.left = kTTAccountLoginInputFieldLeftMargin;
        
        self.registerButton.size = CGSizeMake(self.view.width - kTTAccountLoginInputFieldLeftMargin - kTTAccountLoginInputFieldRightMargin, kTTAccountLoginInputFieldHeight);
        self.registerButton.top = self.captchaInput.bottom + kTTAccountLoginInputFieldVerticalMargin;
        self.registerButton.left = kTTAccountLoginInputFieldLeftMargin;
        
        // 发送手机号提示布局
        [_bottomInfoLabel sizeToFit];
        _bottomInfoLabel.centerX = self.view.centerX;
        _bottomInfoLabel.top = self.registerButton.bottom + kTTAccountLoginLoginLabelVerticalMargin;
    }
    [self fitResendView];
}


- (void)fitResendView
{
    self.mobileInput.resendButton.enabled = self.resendButtonEnabled;
    NSString *resendTitleString;
    if (self.state == TTAccountLoginQuickRetrieveStateSubmit) {
        resendTitleString = self.resendButtonEnabled ? @"重新发送": [NSString stringWithFormat:@"重新发送(%ldS)", (long)self.countdown];
        [self.mobileInput updateRightText:NSLocalizedString(resendTitleString, nil)];
    }
}

#pragma mark - Actions

- (void)registerButtonClicked:(id)sender
{
    // 本地检测不合法
    if (![self isContentValid]) {
        // 统计：找回密码输手机号页点下一步报错
        TTASMSCodeScenarioType scenarioType = TTASMSCodeScenarioFindPassword;
        if (self.state == TTAccountLoginQuickRetrieveStateNext) {
            scenarioType = TTASMSCodeScenarioFindPassword;
        } else if (self.state == TTAccountLoginQuickRetrieveStateSubmit) {
            scenarioType = TTASMSCodeScenarioFindPasswordRetry;
        }
        
        if (scenarioType == TTASMSCodeScenarioFindPassword) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                ttTrackEvent(@"register_new", @"find_password_next_error");
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"error" forKey:@"return_value"];
            [TTTrackerWrapper eventV3:@"login_find_password" params:extraDict isDoubleSending:YES];
        } else if (scenarioType == TTASMSCodeScenarioFindPasswordRetry) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                ttTrackEvent(@"register_new", @"reset_password_next_error");
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"error" forKey:@"return_value"];
            [TTTrackerWrapper eventV3:@"login_reset_password" params:extraDict isDoubleSending:YES];
        }
        
        if (self.state == TTAccountLoginQuickRetrieveStateNext) {
            if (self.mobileInput.field.text.length == 0 || ![self validateMobileNumber:self.mobileInput.field.text]) {
                [self.mobileInput showError];
                return;
            }
        } else if (self.state == TTAccountLoginQuickRetrieveStateSubmit) {
            if (self.captchaInput.field.text.length == 0) {
                [self.captchaInput showError];
                return;
            }
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"信息填写不全", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    if (self.state == TTAccountLoginQuickRetrieveStateNext) {
        [self sendCode:TTASMSCodeScenarioFindPassword];
    } else if(self.state == TTAccountLoginQuickRetrieveStateSubmit) {
        [self changePassword];
    }
}

- (void)sendCode:(TTASMSCodeScenarioType)scenarioType
{
    if(self.state == TTAccountLoginQuickRetrieveStateNext) {
        self.phoneNumberString = self.mobileInput.field.text;
    }
    
    [self showWaitingIndicator];
    
    __weak typeof(self) wself = self;
    [TTAccount sendSMSCodeWithPhone:self.phoneNumberString captcha:self.captchaString SMSCodeType:scenarioType unbindExist:NO completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
        
        if (!error) {
            if (scenarioType != TTASMSCodeScenarioFindPasswordRetry) {
                //找回密码输手机号页顺利点下一步
                // LogV1
                if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                    ttTrackEvent(@"register_new", @"find_password_next");
                }
                // LogV3
                NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
                [extraDict setValue:@"confirm" forKey:@"action_type"];
                [TTTrackerWrapper eventV3:@"login_find_password" params:extraDict isDoubleSending:YES];
            }
            
            self.state = TTAccountLoginQuickRetrieveStateSubmit;
            [self refreshSubviews];
            [self layoutSubviews];
            [self startTimer];
            [wself dismissWaitingIndicatorWithText:NSLocalizedString(@"发送成功", nil)];
            
        } else {
            
            if (scenarioType != TTASMSCodeScenarioFindPasswordRetry) {
                //找回密码输手机号页点下一步报错
                // LogV1
                if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                    ttTrackEvent(@"register_new", @"find_password_next_error");
                }
                // LogV3
                NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
                [extraDict setValue:self.source forKey:@"source"];
                [extraDict setValue:@"error" forKey:@"return_value"];
                [TTTrackerWrapper eventV3:@"login_find_password" params:extraDict isDoubleSending:YES];
            }
            
            if (captchaImage) {
                [wself dismissWaitingIndicator];
                TTAccountCaptchaAlert *cAlert = [[TTAccountCaptchaAlert alloc] initWithTitle:@"请输入图片中的字符" captchaImage:captchaImage placeholder:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable captchaStr) {
                    
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        wself.captchaString = captchaStr;
                        [wself sendCode:scenarioType];
                    } else {
                        [wself dismissWaitingIndicator];
                    }
                }];
                [cAlert showInView:wself.view];
            } else {
                [wself dismissWaitingIndicatorWithError:error];
            }
        }
    }];
}

- (void)changePassword
{
    [self showWaitingIndicator];
    
    __weak typeof(self) wself = self;
    [TTAccount resetPasswordWithPhone:self.phoneNumberString SMSCode:self.mobileInput.field.text password:self.captchaInput.field.text captcha:self.captchaString completion:^(UIImage *captchaImage, NSError *error) {
        
        if (!error) {
            // 重设密码页顺利点下一步
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                ttTrackEvent(@"register_new", @"reset_password_next");
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"confirm" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_reset_password" params:extraDict isDoubleSending:YES];
            
            [self dismissWaitingIndicatorWithText:NSLocalizedString(@"修改成功", nil)];
            [self dismissViewControllerAnimated:true completion:nil];
            
        } else {
            // 重设密码页点下一步报错
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                ttTrackEvent(@"register_new", @"reset_password_next_error");
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"error" forKey:@"return_value"];
            [TTTrackerWrapper eventV3:@"login_reset_password" params:extraDict isDoubleSending:YES];
            
            if (captchaImage) {
                [wself dismissWaitingIndicator];
                TTAccountCaptchaAlert *cAlert = [[TTAccountCaptchaAlert alloc] initWithTitle:@"请输入图片中的字符" captchaImage:captchaImage placeholder:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable captchaStr) {
                    
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        wself.captchaString = captchaStr;
                        [wself changePassword];
                    } else {
                        [wself dismissWaitingIndicator];
                    }
                }];
                [cAlert showInView:wself.view];
            } else {
                [wself dismissWaitingIndicatorWithError:error];
            }
        }
    }];
}

- (void)leftItemClicked
{
    if (self.state == TTAccountLoginQuickRetrieveStateNext) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if(self.state == TTAccountLoginQuickRetrieveStateSubmit) {
        self.state = TTAccountLoginQuickRetrieveStateNext;
        [self refreshSubviews];
        [self layoutSubviews];
    }
}

- (void)rightItemClicked
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)resendButtonClicked:(id)sender
{
    // 重设密码页点重发验证码
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        ttTrackEvent(@"register_new", @"reset_password_retry");
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:self.source forKey:@"source"];
    [extraDict setValue:@"retry" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"login_reset_password" params:extraDict isDoubleSending:YES];
    
    [self sendCode:TTASMSCodeScenarioFindPasswordRetry];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(NSNotification *)notification
{
    [self.mobileInput recover];
    [self.captchaInput recover];
    [self refreshRegisterButton];
}

#pragma mark - Helper

// override from superclass
- (BOOL)isContentValid
{
    if (self.state == TTAccountLoginQuickRetrieveStateNext) {
        return (self.mobileInput.field.text.length > 0 && [self validateMobileNumber:self.mobileInput.field.text]);
    } else if(self.state == TTAccountLoginQuickRetrieveStateSubmit) {
        return (self.captchaInput.field.text.length > 0);
    }
    return NO;
}

#pragma mark - Getter/Setter

- (SSThemedLabel *)upInfoLabel
{
    if (!_upInfoLabel) {
        _upInfoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _upInfoLabel.textColorThemeKey = kColorText1;
        _upInfoLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:20]];
        _upInfoLabel.text = NSLocalizedString(@"找回密码", nil);
        [_upInfoLabel sizeToFit];
    }
    return _upInfoLabel;
}

- (SSThemedLabel *)bottomInfoLabel
{
    if (!_bottomInfoLabel) {
        _bottomInfoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _bottomInfoLabel.backgroundColor = [UIColor clearColor];
        _bottomInfoLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _bottomInfoLabel.textAlignment = NSTextAlignmentCenter;
        _bottomInfoLabel.textColorThemeKey = kColorText2;
    }
    return _bottomInfoLabel;
}

- (SSThemedView *)areaSeparatorView
{
    if (!_areaSeparatorView) {
        _areaSeparatorView = [[SSThemedView alloc]
                              initWithFrame:CGRectMake(0, 0, [TTDeviceHelper ssOnePixel], 16)];
        _areaSeparatorView.backgroundColorThemeKey = kColorLine9;
    }
    return _areaSeparatorView;
}

- (SSThemedLabel *)areaLabel
{
    if (!_areaLabel) {
        _areaLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _areaLabel.backgroundColor = [UIColor clearColor];
        _areaLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        _areaLabel.text = @"+86";
        _areaLabel.textColorThemeKey = kColorText3;
        [_areaLabel sizeToFit];
    }
    return _areaLabel;
}

- (SSThemedView *)areaView
{
    if (!_areaView) {
        _areaView = [[SSThemedView alloc] init];
        _areaView.backgroundColor = [UIColor clearColor];
        [_areaView addSubview:self.areaSeparatorView];
        [_areaView addSubview:self.areaLabel];
        
        CGFloat areaViewWidth = 15 + self.areaLabel.width + 15 + self.areaSeparatorView.width;
        CGFloat areaViewHeight = MAX(15, self.areaLabel.height);
        
        _areaView.size = CGSizeMake(areaViewWidth, areaViewHeight);
        
        self.areaLabel.centerY = _areaView.height / 2;
        self.areaLabel.left = 15;
        
        self.areaSeparatorView.centerY = _areaView.height / 2;
        self.areaSeparatorView.left = 15 + self.areaLabel.width + 15;
    }
    return _areaView;
}
@end

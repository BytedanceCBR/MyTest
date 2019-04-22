//
//  ArticleMobileChangeViewController.m
//  Article
//
//  Created by Huaqing Luo on 28/7/15.
//
//

#import "ArticleMobileChangeViewController.h"
#import <TTThemedAlertController.h>
#import <TTDeviceHelper.h>
#import <TTAccountBusiness.h>
#import "ArticleMobileChangeCaptchaViewController.h"
#import "TTTrackerWrapper.h"



@interface ArticleMobileChangeViewController ()

@property(nonatomic, strong)SSThemedLabel * tipLabel1;
@property(nonatomic, strong)SSThemedLabel * tipLabel2;

@property(nonatomic, strong)SSThemedTextField * fromMobileNumberField;
@property(nonatomic, strong)SSThemedTextField * toMobileNumberField;

@property(nonatomic, strong)SSThemedButton * nextButton;
@property(nonatomic, strong)SSThemedLabel *areaLabel0;
@property(nonatomic, strong)SSThemedLabel *areaLabel1;
@property(nonatomic, strong)SSThemedView  *separatorViewV0;
@property(nonatomic, strong)SSThemedView  *separatorViewV1;
@property(nonatomic, strong)SSThemedView  *separatorViewH;




@end

@implementation ArticleMobileChangeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.automaticallyAdjustKeyboardOffset = YES;
        self.maximumHeightOfContent = 310;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle: NSLocalizedString(@"更换手机号", nil)];
    
    self.tipLabel1 = [[SSThemedLabel alloc] init];
    self.tipLabel1.textColorThemeKey = kColorText3;
    self.tipLabel1.font = [UIFont systemFontOfSize:[ArticleMobileChangeViewController fontSizeOfTipLabel]];
    self.tipLabel1.text = @"更换绑定的手机号";
    [self.containerView addSubview:self.tipLabel1];
    [self.tipLabel1 sizeToFit];
    self.tipLabel2 = [[SSThemedLabel alloc] init];
    self.tipLabel2.textColorThemeKey = kColorText3;
    self.tipLabel2.font = [UIFont systemFontOfSize:[ArticleMobileChangeViewController fontSizeOfTipLabel]];
    self.tipLabel2.text = @"之后可以用新手机号及当前密码登录";
    [self.containerView addSubview:self.tipLabel2];
    [self.tipLabel2 sizeToFit];
    
    self.areaLabel0 = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    self.areaLabel0.backgroundColor = [UIColor clearColor];
    self.areaLabel0.font = [UIFont systemFontOfSize:[ArticleMobileChangeViewController fontSizeOfInputFiled]];
    self.areaLabel0.text = @"+86";
    self.areaLabel0.textColorThemeKey = kColorText3;
    [self.areaLabel0 sizeToFit];
    [self.inputContainerView addSubview:self.areaLabel0];
    
    self.separatorViewV0 = [[SSThemedView alloc] init];
    self.separatorViewV0.backgroundColorThemeKey = kColorLine1;
    [self.inputContainerView addSubview:self.separatorViewV0];
    
    self.fromMobileNumberField = [[SSThemedTextField alloc] initWithFrame:[self _fromMobileNumberFieldFrame]];
    self.fromMobileNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.fromMobileNumberField.returnKeyType = UIReturnKeyNext;
    self.fromMobileNumberField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.fromMobileNumberField.placeholder = NSLocalizedString(@"请输入当前绑定的手机号", nil);
    self.fromMobileNumberField.font = [UIFont systemFontOfSize:[ArticleMobileChangeViewController fontSizeOfInputFiled]];
    self.fromMobileNumberField.textColorThemeKey = kColorText1;
    self.fromMobileNumberField.placeholderColorThemeKey = kColorText3;
    self.fromMobileNumberField.backgroundColor = [UIColor clearColor];
    self.fromMobileNumberField.delegate = self;
    [self.inputContainerView addSubview:self.fromMobileNumberField];
    
    self.separatorViewH = [[SSThemedView alloc] initWithFrame:[self _separatorViewHFrame]];
    self.separatorViewH.backgroundColorThemeKey = kColorLine1;
    [self.inputContainerView addSubview:self.separatorViewH];
    
    self.areaLabel1 = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    self.areaLabel1.backgroundColor = [UIColor clearColor];
    self.areaLabel1.font = [UIFont systemFontOfSize:[ArticleMobileChangeViewController fontSizeOfInputFiled]];
    self.areaLabel1.text = @"+86";
    self.areaLabel1.textColorThemeKey = kColorText3;
    [self.areaLabel1 sizeToFit];
    [self.inputContainerView addSubview:self.areaLabel1];
    
    self.separatorViewV1 = [[SSThemedView alloc] initWithFrame:[self _separatorViewV1Frame]];
    self.separatorViewV1.backgroundColorThemeKey = kColorLine1;
    [self.inputContainerView addSubview:self.separatorViewV1];
    
    self.toMobileNumberField = [[SSThemedTextField alloc] initWithFrame:[self _toMobileNumberFieldFrame]];
    self.toMobileNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.toMobileNumberField.returnKeyType = UIReturnKeyNext;
    self.toMobileNumberField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.toMobileNumberField.placeholder = NSLocalizedString(@"请输入新手机号", nil);
    self.toMobileNumberField.font = [UIFont systemFontOfSize:[ArticleMobileChangeViewController fontSizeOfInputFiled]];
    self.toMobileNumberField.textColorThemeKey = kColorText1;
    self.toMobileNumberField.placeholderColorThemeKey = kColorText3;
    self.toMobileNumberField.backgroundColor = [UIColor clearColor];
    self.toMobileNumberField.delegate = self;
    [self.inputContainerView addSubview:self.toMobileNumberField];
    
    self.nextButton = [self mobileButtonWithTitle:NSLocalizedString(@"下一步", nil) target:self action:@selector(nextButtonActionFired:)];
    [self.containerView addSubview:self.nextButton];
    
    wrapperTrackEvent(@"login_register", @"change_mobile");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (CGRect)_separatorViewV1Frame
{
    return CGRectMake(self.areaLabel1.right + 10, [ArticleMobileChangeViewController heightOfInputField] + self.separatorViewV0.top, [TTDeviceHelper ssOnePixel], 14);
}

- (CGRect)_toMobileNumberFieldFrame
{
    return CGRectMake(self.separatorViewV1.right + 10, self.separatorViewH.bottom, self.inputContainerView.width - self.separatorViewV1.right - 10, [ArticleMobileChangeViewController heightOfInputField]);
}

- (CGRect)_fromMobileNumberFieldFrame
{
    return CGRectMake(self.separatorViewV0.right + 10, 0, self.inputContainerView.width - self.separatorViewV0.right - 10, [ArticleMobileChangeViewController heightOfInputField]);
}

- (CGRect)_separatorViewHFrame
{
    return CGRectMake(0, self.fromMobileNumberField.bottom, self.inputContainerView.width, [TTDeviceHelper ssOnePixel]);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tipLabel1.origin = CGPointMake((self.containerView.width - self.tipLabel1.width) / 2, 20.f);
    self.tipLabel2.origin = CGPointMake((self.containerView.width - self.tipLabel2.width) / 2, CGRectGetMaxY(self.tipLabel1.frame));
    self.inputContainerView.frame = CGRectMake(0, self.tipLabel2.bottom + 20, self.containerView.width, [ArticleMobileChangeViewController heightOfInputField] * 2 + [TTDeviceHelper ssOnePixel]);
    self.areaLabel0.origin = CGPointMake(10, ([ArticleMobileChangeViewController heightOfInputField] - self.areaLabel0.height) / 2);
    self.separatorViewV0.frame = CGRectMake(self.areaLabel0.right + 10, ([ArticleMobileChangeViewController heightOfInputField] - 14) / 2, [TTDeviceHelper ssOnePixel], 14);
    
    self.fromMobileNumberField.frame = [self _fromMobileNumberFieldFrame];
    self.separatorViewH.frame = [self _separatorViewHFrame];
    self.areaLabel1.origin = CGPointMake(10, [ArticleMobileChangeViewController heightOfInputField] + self.areaLabel0.top);
    self.separatorViewV1.frame = [self _separatorViewV1Frame];
    self.toMobileNumberField.frame = [self _toMobileNumberFieldFrame];
    self.nextButton.origin = CGPointMake(0, self.inputContainerView.bottom + 20);
}

- (BOOL)isContentValid
{
    return (self.fromMobileNumberField.text.length > 0 && [self validateMobileNumber:self.fromMobileNumberField.text] && self.toMobileNumberField.text.length > 0 && [self validateMobileNumber:self.toMobileNumberField.text] && ![self.fromMobileNumberField.text isEqualToString:self.toMobileNumberField.text]);
}

-(void)nextButtonActionFired:(id)sender
{
    if (self.fromMobileNumberField.text.length == 0 || self.toMobileNumberField.text.length == 0) {
        NSString * message = self.fromMobileNumberField.text.length == 0  ? NSLocalizedString(@"请输入旧手机号", nil) : NSLocalizedString(@"请输入新手机号", nil);
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:message preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            if (self.fromMobileNumberField.text.length == 0) {
                [self.fromMobileNumberField becomeFirstResponder];
            } else {
                [self.toMobileNumberField becomeFirstResponder];
            }
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    
    BOOL isFromNumberValid = [self validateMobileNumber:self.fromMobileNumberField.text];
    BOOL isToNumberValid = [self validateMobileNumber:self.toMobileNumberField.text];
    if (!isFromNumberValid || !isToNumberValid) {
        [self alertInvalidateMobileNumberWithCompletionHandler:^{
            if (!isFromNumberValid) {
                [self.fromMobileNumberField becomeFirstResponder];
            } else {
                [self.toMobileNumberField becomeFirstResponder];
            }
        }];
        return;
    }
    
    if ([self.fromMobileNumberField.text isEqualToString:self.toMobileNumberField.text]) {
        NSString *message = @"新旧手机号码相同，请重新输入";
        
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:message preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            if (![self.mobileNumber isEqualToString:self.fromMobileNumberField.text]) {
                [self.fromMobileNumberField becomeFirstResponder];
            } else {
                [self.toMobileNumberField becomeFirstResponder];
            }
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    
    // Change phone number
    [self changePhoneNumber];
}

- (void)changePhoneNumber
{
    __weak ArticleMobileChangeViewController *weakSelf = self;
    void (^changeMobileBlock)(NSString *, NSString *, NSString *) = ^(NSString *oldMobile, NSString *mobile, NSString *captcha) {
        NSDictionary *previousMobileInformation = [[self class] previousMobileCodeInformation];
        NSTimeInterval timeInterval = [[previousMobileInformation valueForKey:@"time"] doubleValue];
        NSInteger retryTime = [[previousMobileInformation valueForKey:@"retryTime"] intValue];
        NSInteger timeOffset = [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
        if (([[previousMobileInformation valueForKey:@"mobile"] isEqualToString:mobile] &&
             ([[previousMobileInformation valueForKey:@"type"] intValue] == TTASMSCodeScenarioChangePhone ||
              [[previousMobileInformation valueForKey:@"type"] intValue] == TTASMSCodeScenarioChangePhoneRetry)) &&
            (retryTime > timeOffset)) {
            /// 已经发送过验证码
            NSNumber *retryTime = [previousMobileInformation valueForKey:@"retryTime"];
            
            ArticleMobileChangeCaptchaViewController *viewController = [[ArticleMobileChangeCaptchaViewController alloc] init];
            viewController.mobileNumber = mobile;
            viewController.timeoutInterval = retryTime.intValue;
            viewController.completion = weakSelf.completion;
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        } else {
            [self showWaitingIndicator];
            
            [TTAccountManager startSendCodeWithPhoneNumber:mobile captcha:captcha type:TTASMSCodeScenarioChangePhone unbindExist:NO completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
                
                weakSelf.captchaImage = captchaImage;
                weakSelf.captchaValue = nil;
                weakSelf.error = error;
                if (!error) {
                    ArticleMobileChangeCaptchaViewController *viewController = [[ArticleMobileChangeCaptchaViewController alloc] init];
                    viewController.mobileNumber = mobile;
                    viewController.timeoutInterval = retryTime.intValue;
                    viewController.completion = weakSelf.completion;
                    [weakSelf.navigationController pushViewController:viewController animated:YES];
                    
                    NSMutableDictionary *information =
                    [NSMutableDictionary dictionaryWithCapacity:2];
                    [information setValue:@(TTASMSCodeScenarioChangePhone) forKey:@"type"];
                    [information setValue:retryTime forKey:@"retryTime"];
                    [information setValue:mobile forKey:@"mobile"];
                    [information setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"time"];
                    [[self class] setPreviousMobileCodeInformation:information];
                    
                    [weakSelf dismissWaitingIndicator];
                    
                    wrapperTrackEvent(@"login_register", @"change_mobile_next");
                } else {
                    wrapperTrackEvent(@"login_register", @"change_mobile_error");
                    
                    if (captchaImage) {
                        [weakSelf dismissWaitingIndicator];
                        [weakSelf changePhoneNumber];
                    } else {
                        [weakSelf dismissWaitingIndicatorWithError:error];
                    }
                }
            }];
        }
    };
    
    void (^alertCaptchaBlock)(UIImage *, NSError *) =
    ^(UIImage *captcha, NSError *error) {
        ArticleMobileCaptchaAlertView *alertView = [[ArticleMobileCaptchaAlertView alloc] initWithCaptchaImage:captcha];
        alertView.error = error;
        [alertView showWithDismissBlock:^(ArticleMobileCaptchaAlertView *alertView, NSInteger buttonIndex) {
            self.captchaValue = alertView.captchaValue;
            self.captchaImage = alertView.captchaImage;
            if (alertView.captchaValue.length > 0) {
                changeMobileBlock(self.fromMobileNumberField.text, self.toMobileNumberField.text, alertView.captchaValue);
            }
        }];
    };
    
    if (self.captchaImage && !self.captchaValue) {
        alertCaptchaBlock(self.captchaImage, self.error);
    } else {
        changeMobileBlock(self.fromMobileNumberField.text, self.toMobileNumberField.text, self.captchaValue);
    }
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

+ (CGFloat)fontSizeOfTipLabel
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 14.f;
    } else {
        return 12.f;
    }
}

@end

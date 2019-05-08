//
//  TTAccountBindingMobileViewController.m
//  Article
//
//  Created by zuopengliu on 13/9/2017.
//
//

#import "TTAccountBindingMobileViewController.h"
#import <TTUserPrivacyView.h>
#import <TTAccountBusiness.h>
#import "SSWebViewController.h"
#import "ArticleMobileCaptchaAlertView.h"
#import <NSTimer+TTNoRetainRef.h>
#import "NSString+TextValidation.h"
#import "UITextField+TTTouchAreaAddition.h"
#import "TTTracker.h"
#import "TTAccountAlertView.h"
#import "UIApplication+UserPrivacyPolicy.h"



#define kTTInsetLeftOrRightMargin [TTDeviceUIUtils tt_newPadding:30.f]
#define kTTSendSMSCodeButtonWidth (96.f)

static inline CGFloat navigationBarTop() {
    if ([TTDeviceHelper isIPhoneXDevice]) {
        return 44.f;
    }
    return 20.f;
}

@interface TTAccountBindingMobileViewController ()
<
UITextFieldDelegate,
UIGestureRecognizerDelegate
>
@property (nonatomic, strong) SSThemedView      *backgroundView;
@property (nonatomic, strong) SSThemedView      *containerView;
@property (nonatomic, strong) SSThemedLabel     *titleHintLabel; //提示

@property (nonatomic, strong) SSThemedTextField *mobileTextField;
@property (nonatomic, strong) SSThemedTextField *smsCodeTextField;
@property (nonatomic, strong) SSThemedButton    *sendSmsCodeButton;
@property (nonatomic, strong) SSThemedButton    *submitButton;

@property (nonatomic, strong) SSThemedView      *verSeparatorView;
@property (nonatomic, strong) TTUserPrivacyView *privacyView;

@property (nonatomic, strong) TTIndicatorView   *waitingIndicatorView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UITapGestureRecognizer *tapEndEditingGR;

@property(nonatomic, assign) UIStatusBarStyle originalStatusBarStyle;

@end

@implementation TTAccountBindingMobileViewController

+ (void)load {
    RegisterRouteObjWithEntryName(@"binding_mobile");
}

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.trackParams = [paramObj.allParams tt_dictionaryValueForKey:@"track_params"];
    }
    return self;
}

#pragma mark - TTModalWrapControllerProtocol

@synthesize hasNestedInModalContainer = _hasNestedInModalContainer;

- (UIScrollView *)tt_scrollView
{
    return nil;
}

#pragma mark - TTModalContainerDelegate

- (void)beginDismissModalContainerController:(TTModalContainerController *)container
{
    [self.view endEditing:YES];
}

- (void)willDismissModalContainerController:(TTModalContainerController *)container
{
    if (_bindingCompletionCallback) {
        _bindingCompletionCallback(NO,YES);
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kAccountBindingMobileNotification
                                                        object:self
                                                      userInfo:@{
                                                          @"finished" : @NO,
                                                          @"dismissed" : @YES,
                                                      }];
}

- (void)dealloc
{
    [self stopTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.tt_modalWrapperTitleViewHidden = YES;
        self.ttNaviTranslucent = YES;
        self.ttNeedHideBottomLine = YES;
        self.trackParams = [[NSDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray<UIColor *> *themedBackgroundColors = SSThemedColors(@"fafafa", @"252525");
    {
        // self.title = @"绑定手机号";
        self.view.backgroundColor = SSGetThemedColorInArray(themedBackgroundColors);
        self.view.clipsToBounds = YES;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _tapEndEditingGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(gestureRecognizerDidTouchBackgroundView:)];
        _tapEndEditingGR.delegate = self;
        _tapEndEditingGR.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:_tapEndEditingGR];
    }
    
    {
        self.navigationItem.leftBarButtonItem = nil;
        if (self.navigationController.viewControllers.count > 1) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationBackButtonWithTarget:self action:@selector(dismissSelf)]];
        }
        
        UIButton *closeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
        [closeButton setImage:[UIImage themedImageNamed:@"close_comment"] forState:UIControlStateNormal];
        closeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
        [closeButton sizeToFit];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            [closeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -2)];
        } else {
            [closeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -4)];
        }
        [closeButton addTarget:self action:@selector(acitonDidTapCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    }
    
    {
        SSThemedView *backgroundView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
        backgroundView.userInteractionEnabled = YES;
        backgroundView.backgroundColors = themedBackgroundColors;
        [self.view addSubview:backgroundView];
        
        self.backgroundView = backgroundView;
    }
    
    {
        [self.view addSubview:self.containerView];
        
        [self.containerView addSubview:self.titleHintLabel];
        [self.containerView addSubview:self.mobileTextField];
        [self.mobileTextField addSubview:self.verSeparatorView];
        [self.mobileTextField addSubview:self.sendSmsCodeButton];
        [self.containerView addSubview:self.smsCodeTextField];
        [self.containerView addSubview:self.submitButton];
        [self.containerView addSubview:self.privacyView];
    }
    
    {
        CGFloat topInset = navigationBarTop();
        TTNavigationBar *navBar = [[TTNavigationBar alloc] initWithFrame:CGRectMake(0, topInset, self.view.frame.size.width, 44)];
        navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        navBar.backgroundColor = [UIColor clearColor];
        [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        navBar.shadowImage = [UIImage new];
        [navBar setBarTintColor:[UIColor clearColor]];
        [navBar setTranslucent:YES];
        self.ttNaviTranslucent = YES;
        self.ttNeedHideBottomLine = YES;
        self.ttNavigationBar = navBar;
        
        [self.view addSubview:navBar];
    }
    
    [self layoutCustomSubviews];
    
    [self.class setShowBindingMobileTimes:(1+[self.class showBindingMobileTimes])];
    [self.class setShowBindingMobileEnabled:NO];
    
    {
        self.ttStatusBarStyle = UIStatusBarStyleDefault;
        // 记录状态栏
        self.originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (self.mobileString.length >= 11) {
        [self sendSMSCode:TTASMSCodeScenarioBindPhone captcha:nil];
        [self.smsCodeTextField becomeFirstResponder];
    } else {
        [self.mobileTextField becomeFirstResponder];
    }
    
    [TTTracker eventV3:@"auth_mobile_show" params:self.trackParams];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    { // 恢复状态栏
        [[UIApplication sharedApplication] setStatusBarStyle:self.originalStatusBarStyle];
    }
}

#pragma mark - keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note
{
    [self keyboardWillChange:note keyboardDistance:90.f keyboardHidden:NO];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [self keyboardWillChange:note keyboardDistance:90.f keyboardHidden:YES];
}

- (void)keyboardWillChange:(NSNotification *)notification   // 键盘改变通知
          keyboardDistance:(CGFloat)distance                // FirstResponder 与键盘之间的间距
            keyboardHidden:(BOOL)hiddenKeyboard             // 将隐藏还是显示键盘
{
    NSDictionary *userInfo = notification.userInfo;
    /// keyboard相对于屏幕的坐标
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }
    
    UITextField *firstResponderTextField = self.mobileTextField.isFirstResponder ? self.mobileTextField : (self.smsCodeTextField.isFirstResponder ? self.smsCodeTextField : nil);
    if (hiddenKeyboard || !firstResponderTextField) {
        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            self.containerView.frame = [self __containerViewTargetFrame__];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        UIView *firstResponderRelativeView = self.view;
        CGRect firstResponderRelativeFrame = [firstResponderTextField.superview convertRect:firstResponderTextField.frame toView:firstResponderRelativeView];
        
        CGFloat heightExceptKeyboard = firstResponderRelativeView.height - CGRectGetHeight(keyboardScreenFrame);
        // UITextField超过高度减去键盘上面的高度
        CGFloat topMovedOffset = MAX(0, CGRectGetMaxY(firstResponderRelativeFrame) + distance - heightExceptKeyboard);
        
        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            self.containerView.top -=  topMovedOffset;
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - layout

- (CGRect)__containerViewTargetFrame__
{
    CGFloat rectWidth = CGRectGetWidth(self.view.bounds);
    CGFloat containerWidth = [TTDeviceHelper isPadDevice] ? 520 : (CGRectGetWidth(self.view.bounds) - 2 * kTTInsetLeftOrRightMargin);
    
    return CGRectMake((rectWidth - containerWidth) / 2,
                      0,
                      containerWidth,
                      CGRectGetHeight(self.view.frame));
}

- (void)layoutCustomSubviews
{
    self.containerView.frame = [self __containerViewTargetFrame__];
    
    CGFloat verticalSpacing = [TTDeviceUIUtils tt_newPadding:60];
    self.titleHintLabel.frame = CGRectMake(0, verticalSpacing, self.containerView.width, 20);
    
    verticalSpacing = self.titleHintLabel.bottom + [TTDeviceUIUtils tt_newPadding:40.f];
    self.mobileTextField.frame = CGRectMake(0, verticalSpacing, self.containerView.width, [TTDeviceUIUtils tt_newPadding:46.f]);
    
    {
        self.verSeparatorView.frame =
        CGRectMake(self.mobileTextField.width - (kTTSendSMSCodeButtonWidth + self.verSeparatorView.width),
                   (self.mobileTextField.height - self.verSeparatorView.height)/2,
                   self.verSeparatorView.width,
                   self.verSeparatorView.height);
        
        self.sendSmsCodeButton.frame = CGRectMake(self.verSeparatorView.right, 0, kTTSendSMSCodeButtonWidth, self.mobileTextField.height);
    }
    
    verticalSpacing = self.mobileTextField.bottom + [TTDeviceUIUtils tt_newPadding:24.f];
    self.smsCodeTextField.frame = CGRectMake(0, verticalSpacing, self.containerView.width, [TTDeviceUIUtils tt_newPadding:46.f]);
    
    verticalSpacing = self.smsCodeTextField.bottom + [TTDeviceUIUtils tt_newPadding:24.f];
    self.submitButton.frame = CGRectMake(0, verticalSpacing, self.containerView.width, [TTDeviceUIUtils tt_newPadding:46.f]);
    
    verticalSpacing = self.submitButton.bottom + [TTDeviceUIUtils tt_newPadding:0.f];
    self.privacyView.frame = CGRectMake((self.containerView.width - self.privacyView.width) / 2.f, verticalSpacing, self.privacyView.width, self.privacyView.height);
    
    self.mobileTextField.layer.cornerRadius = self.mobileTextField.height / 2.f;
    self.smsCodeTextField.layer.cornerRadius = self.smsCodeTextField.height / 2.f;
    self.submitButton.layer.cornerRadius = self.submitButton.height / 2.f;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(6.f, 6.f)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.view.bounds;
    maskLayer.path = maskPath.CGPath;
    self.view.layer.mask = maskLayer;
    
    [self.view bringSubviewToFront:self.ttNavigationBar];
    
    self.backgroundView.frame = self.view.bounds;
    [self layoutCustomSubviews];
}

#pragma mark - timer

- (void)startTimerWithDuration:(NSTimeInterval)duration
{
    WeakSelf;
    self.timer = [NSTimer ttNRF_timerWithTimeInterval:1.f repeats:YES block:^(NSTimer * _Nonnull timer) {
        StrongSelf;
        
        void (^mainThreadActionBlock)() = ^{
            if (timer.tt_countdownTime <= 0) {
                [self stopTimer];
                [self.sendSmsCodeButton setTitle:NSLocalizedString(@"发送验证码", nil)
                                        forState:UIControlStateNormal];
                [self.sendSmsCodeButton setTitle:NSLocalizedString(@"发送验证码", nil)
                                        forState:UIControlStateDisabled];
                self.sendSmsCodeButton.enabled = YES;
            } else {
                NSInteger ti = (NSInteger)timer.tt_countdownTime--;
                NSString *newTitleString = [NSString stringWithFormat:@"重新发送%ld", (long)ti];
                [self.sendSmsCodeButton setTitle:newTitleString
                                        forState:UIControlStateNormal];
                [self.sendSmsCodeButton setTitle:newTitleString
                                        forState:UIControlStateDisabled];
                self.sendSmsCodeButton.enabled = NO;
            }
        };
        
        if ([NSThread isMainThread]) {
            if (mainThreadActionBlock) mainThreadActionBlock();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (mainThreadActionBlock) mainThreadActionBlock();
            });
        }
    }];
    self.timer.tt_countdownTime = duration;
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - handle

- (void)refreshSMSCodeButtonStatusWithRetryDuration:(NSTimeInterval)dur
{
    [self startTimerWithDuration:dur];
}

- (void)refreshSubmitBindingMobileButtonStatus
{
    if ([self.privacyView isChecked] &&
        [[self.mobileTextField.text trimmed] tt_isValidLengthCNTelNumber] &&
        [[self.smsCodeTextField.text trimmed] tt_isValidSMSCode]) {
        self.submitButton.enabled = YES;
    } else {
        self.submitButton.enabled = NO;
    }
    
    if (_submitButton.enabled) {
        _submitButton.alpha = 1;
    } else {
        _submitButton.alpha = 0.5;
    }
}

- (BOOL)validateMobilePhone:(NSString *)mobileString invalidAlertCompletion:(void (^)())completion
{
    if (mobileString.length == 0) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请输入手机号", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            if (completion) completion();
        }];
        [alert showFrom:self animated:YES];
        return NO;
    }
    
    if (![mobileString tt_isValidLengthCNTelNumber]) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请输入正确的手机号", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            if (completion) completion();
        }];
        [alert showFrom:self animated:YES];
        return NO;
    }
    
    return YES;
}

- (void)sendSMSCode:(TTASMSCodeScenarioType)codeType captcha:(NSString *)captchaString
{
    NSString *mobileString = [self.mobileTextField.text trimmed];
    if (![self validateMobilePhone:mobileString invalidAlertCompletion:^{
        [self.mobileTextField becomeFirstResponder];
    }]) {
        return;
    }
    
    [self showWaitingIndicator];
    
    //统计埋点
    [TTTracker eventV3:@"auth_mobile_send_verification_code" params:self.trackParams];
    
    WeakSelf;
    [TTAccountManager startSendCodeWithPhoneNumber:mobileString captcha:captchaString type:TTASMSCodeScenarioBindPhone unbindExist:NO completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
        StrongSelf;
        if (!error) {
            [self dismissWaitingIndicator];
            [self refreshSMSCodeButtonStatusWithRetryDuration:[retryTime doubleValue]];
        } else {
            if ([error.userInfo[@"error_code"] intValue] == TTAccountErrCodeHasRegistered) {
                [self dismissWaitingIndicator];
                [self switchBindMobile:error]; /* 解绑并绑定手机号 */
            } else if (captchaImage) {
                [self dismissWaitingIndicator];
                [self showCaptchaViewWithImage:captchaImage error:error forSMSCodeOp:YES];
            } else {
                [self dismissWaitingIndicatorWithError:error];
            }
        }
    }];
}

- (void)bindingMobileWithCaptcha:(NSString *)captchaString
{
    if (self.privacyView && ![self.privacyView isChecked]) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请同意《幸福里用户协议》", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert showFrom:self animated:YES];
        return;
    }
    
    NSString *mobileString  = [self.mobileTextField.text trimmed];
    NSString *smsCodeString = [self.smsCodeTextField.text trimmed];
    
    if (![self validateMobilePhone:mobileString invalidAlertCompletion:^{
        [self.mobileTextField becomeFirstResponder];
    }]) {
        return;
    }
    
    if (smsCodeString.length == 0) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请输入验证码", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self.smsCodeTextField becomeFirstResponder];
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    
    if (![smsCodeString tt_isValidSMSCode]) {
        wrapperTrackEvent(@"login_register", @"binding_login_noauth");
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"请输入正确的验证码", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self.smsCodeTextField becomeFirstResponder];
        }];
        [alert showFrom:self animated:YES];
        return;
    }
    
    [self showWaitingIndicator];
    
    //埋点
    [TTTracker eventV3:@"auth_mobile_verify_confirm" params:self.trackParams];
    
    WeakSelf;
    [TTAccountManager startBindPhoneNumber:mobileString code:smsCodeString password:nil captcha:captchaString unbindExist:NO completion:^(UIImage *captchaImage, NSError *error) {
        StrongSelf;
        if (!error) {
            // 绑定成功
            [self dismissWaitingIndicatorWithText:NSLocalizedString(@"手机号绑定成功", nil)];
            
            wrapperTrackEvent(@"login_register", @"binding_success");
            
            // TODO:
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_bindingCompletionCallback) {
                    _bindingCompletionCallback(YES, NO);
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:kAccountBindingMobileNotification
                                                                    object:self
                                                                  userInfo:@{
                                                                      @"finished" : @YES,
                                                                      @"dismissed" : @NO,
                                                                  }];

                [self dismissSelf];
            });
        } else {
            // 绑定失败
            [self dismissWaitingIndicatorWithText:NSLocalizedString(@"手机号绑定失败", nil)];
            
            wrapperTrackEvent(@"login_register", @"binding_login_error");
            
            if (captchaImage) {
                [self dismissWaitingIndicator];
                [self showCaptchaViewWithImage:captchaImage error:error forSMSCodeOp:YES];
            } else {
                [self dismissWaitingIndicatorWithError:error];
            }
        }
    }];
}

// 解绑老的绑定
- (void)switchBindMobile:(NSError *)error
{
    //绑定手机号时提示已绑定其他账号
    wrapperTrackEvent(@"login", @"binding_mobile_error");
    
    WeakSelf;
    TTAccountAlertView *alert = [[TTAccountAlertView alloc] initWithTitle:[error.userInfo objectForKey:@"description"] message:[error.userInfo objectForKey:@"dialog_tips"] cancelBtnTitle:@"取消" confirmBtnTitle:@"放弃原账号" animated:YES tapCompletion:^(TTAccountAlertCompletionEventType type) {
        StrongSelf;
        if (type == TTAccountAlertCompletionEventTypeDone) {
            //绑定手机号时提示已绑定其他账号，点击放弃原账号
            
            [TTTracker eventV3:@"auth_mobile_bindaccount_tip_next" params:self.trackParams];
            
            TTAccountLoginAlert *loginAlert = [[TTAccountLoginAlert alloc] initPhoneNumberVerifyAlertWithActionType:TTAccountLoginAlertActionTypePhoneNumSwitch phoneNum:self.mobileTextField.text title:@"输入验证码" placeholder:nil tip:[NSString stringWithFormat:@"已向手机号 %@ 发送验证码", self.mobileTextField.text] cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type) {
                
                if (type == TTAccountAlertCompletionEventTypeDone) {
                    //绑定手机号时提示已绑定其他账号，成功放弃原账号
                    
                    [TTTracker eventV3:@"auth_mobile_relieve_confirm" params:self.trackParams];
                    
                    if (self.bindingCompletionCallback) {
                        self.bindingCompletionCallback(YES, NO);
                    }
                    [self dismissSelf];
                } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                    
                    [TTTracker eventV3:@"auth_mobile_relieve_cancel" params:self.trackParams];
                }
            }];
            [loginAlert show];
        } else if (type == TTAccountAlertCompletionEventTypeCancel) {
            //绑定手机号时提示已绑定其他账号,点击取消
            
            [TTTracker eventV3:@"auth_mobile_bindaccount_tip_cancel" params:self.trackParams];
        }
    }];
    [alert show];
}

- (void)showCaptchaViewWithImage:(UIImage *)captchaImage
                           error:(NSError *)error
                    forSMSCodeOp:(BOOL)smsCodeOp
{
    ArticleMobileCaptchaAlertView *alertView = [[ArticleMobileCaptchaAlertView alloc] initWithCaptchaImage:captchaImage];
    alertView.error = error;
    [alertView showWithDismissBlock:^(ArticleMobileCaptchaAlertView *alertView, NSInteger buttonIndex) {
        
        if (alertView.captchaValue.length > 0) {
            if (smsCodeOp) {
                [self sendSMSCode:TTASMSCodeScenarioBindPhoneRetry captcha:alertView.captchaValue];
            } else {
                [self bindingMobileWithCaptcha:alertView.captchaValue];
            }
        } else {
            NSLog(@"%@-%@ > Error", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }];
}

#pragma mark - indicator

- (void)showWaitingIndicator
{
    self.containerView.userInteractionEnabled = NO;
    _waitingIndicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:nil indicatorImage:nil dismissHandler:nil];
    _waitingIndicatorView.showDismissButton = NO;
    _waitingIndicatorView.autoDismiss = NO;
    [_waitingIndicatorView showFromParentView:self.view];
}

- (void)dismissWaitingIndicatorWithError:(NSError *)error
{
    NSString *desc = [self __indicatorErrorTextFromError:error];
    if (!isEmptyString(desc)) {
        [_waitingIndicatorView updateIndicatorWithImage:[UIImage themedImageNamed:@"close_popup_textpage"]];
    }
    [self dismissWaitingIndicatorWithText:desc];
}

- (void)dismissWaitingIndicatorWithText:(NSString *)msgString
{
    if ([msgString length] > 0) {
        [_waitingIndicatorView updateIndicatorWithText:msgString
                               shouldRemoveWaitingView:YES];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf dismissWaitingIndicator];
        });
    } else {
        [self dismissWaitingIndicator];
    }
}

- (void)dismissWaitingIndicator
{
    self.containerView.userInteractionEnabled = YES;
    [_waitingIndicatorView dismissFromParentView];
    _waitingIndicatorView = nil;
}

- (NSString *)__indicatorErrorTextFromError:(NSError *)error
{
    if (!error) {
        return nil;
    }
    NSString *alertText = [error.userInfo valueForKey:@"alert_text"];
    if (!isEmptyString(alertText)) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:alertText message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert showFrom:self animated:YES];
        return nil;
    }
    NSString *desc = [error.userInfo valueForKey:@"message"];
    if (desc.length == 0) {
        desc = [error.userInfo valueForKey:@"description"];
    }
    if ([desc length] == 0) {
        desc = [error.userInfo valueForKey:TTAccountErrMsgKey];
    }
    if (desc.length == 0) {
        if (error.code == 1004 || error.code == TTAccountErrCodeNameExisted) {
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (_tapEndEditingGR == gestureRecognizer) {
        if ([gestureRecognizer.view isKindOfClass:[UITextField class]] ||
            [gestureRecognizer.view isKindOfClass:[UITextView class]] ||
            [gestureRecognizer.view isKindOfClass:[UIControl class]]) {
            return NO;
        } else {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - actions

- (void)gestureRecognizerDidTouchBackgroundView:(UITapGestureRecognizer *)tapGR
{
    [self.view endEditing:YES];
}

- (void)acitonDidTapCloseButton:(id)sender
{
    NSString *tip = !isEmptyString([[self class] tipBindCancel]) ? [[self class] tipBindCancel] : @"根据《互联网跟帖评论服务管理规定》要求，发布评论需要进行身份验证，为保证你能正常评论，建议尽快完成手机号绑定验证。";
    
    WeakSelf;
    TTAccountAlertView *alert = [[TTAccountAlertView alloc] initWithTitle:@"" message:tip cancelBtnTitle:@"放弃" confirmBtnTitle:@"继续绑定" animated:YES tapCompletion:^(TTAccountAlertCompletionEventType type) {
        
        if (type == TTAccountAlertCompletionEventTypeCancel) {
            StrongSelf;
            [self dismissSelf];
            if (_bindingCompletionCallback) {
                _bindingCompletionCallback(NO, YES);
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:kAccountBindingMobileNotification
                                                                object:self
                                                              userInfo:@{
                                                                  @"finished" : @NO,
                                                                  @"dismissed" : @YES,
                                                              }];

            //埋点
            [TTTracker eventV3:@"auth_mobile_verify_cancel" params:self.trackParams];
        }
    }];
    
    [alert show];
}

- (void)actionDidTapSendSMSCodeButton:(id)sender
{
    [self sendSMSCode:TTASMSCodeScenarioBindPhone captcha:nil];
}

- (void)actionDidTapSubmitBindingOpButton:(id)sender
{
    [self bindingMobileWithCaptcha:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChangeCharacters:(UITextField *)textField
{
    [self refreshSubmitBindingMobileButtonStatus];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        NSString *mobileString = [self.mobileTextField.text trimmed];
        NSString *smsCodeString= [self.smsCodeTextField.text trimmed];
        if ([mobileString tt_isValidTelNumber] && [smsCodeString tt_isValidSMSCode]) {
            [self.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        } else if (self.mobileTextField == textField && [mobileString tt_isValidTelNumber]) {
            [self.smsCodeTextField becomeFirstResponder];
        }
        return NO;
    }
    
    if (textField == self.mobileTextField) {
        NSString *temp = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (temp.length > 11) {
            textField.text = [temp substringToIndex:11];
            return NO;
        }
    } else if (textField == self.smsCodeTextField) {
        NSString *temp = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (temp.length > 4) {
            textField.text = [temp substringToIndex:4];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - setter/getter

- (SSThemedView *)containerView
{
    if (!_containerView) {
        _containerView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.userInteractionEnabled = YES;
    }
    return _containerView;
}

- (SSThemedLabel *)titleHintLabel
{
    if (!_titleHintLabel) {
        _titleHintLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleHintLabel.backgroundColor = [UIColor clearColor];
        _titleHintLabel.adjustsFontSizeToFitWidth = YES;
        _titleHintLabel.text = [self.titleHintString length] > 0 ? self.titleHintString : @"为了你的账号安全，请绑定手机号";
        _titleHintLabel.numberOfLines = 1;
        _titleHintLabel.textColorThemeKey = kColorText1;
        _titleHintLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:20]];
        _titleHintLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleHintLabel;
}

- (SSThemedTextField *)mobileTextField
{
    if (!_mobileTextField) {
        _mobileTextField = [[SSThemedTextField alloc] init];
        _mobileTextField.keyboardType = UIKeyboardTypeNumberPad;
        _mobileTextField.returnKeyType = UIReturnKeyDone;
        _mobileTextField.clearButtonMode = UITextFieldViewModeNever;
        _mobileTextField.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _mobileTextField.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        _mobileTextField.borderColorThemeKey = kColorLine9;
        _mobileTextField.textColorThemeKey = kColorText1;
        _mobileTextField.placeholderColorThemeKey = kColorText9;
        _mobileTextField.backgroundColorThemeKey = kColorBackground20;
        _mobileTextField.textAlignment = NSTextAlignmentLeft;
        _mobileTextField.layer.masksToBounds = YES;
        _mobileTextField.excludedHitTestEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kTTSendSMSCodeButtonWidth);
        _mobileTextField.edgeInsets = UIEdgeInsetsMake(0, 20, 0, kTTSendSMSCodeButtonWidth);  //缩进40px
        
        _mobileTextField.placeholder = NSLocalizedString(@"手机号", nil);
        _mobileTextField.delegate = self;
        [_mobileTextField addTarget:self action:@selector(textFieldDidChangeCharacters:) forControlEvents:UIControlEventEditingChanged];
    }
    return _mobileTextField;
}

- (SSThemedTextField *)smsCodeTextField
{
    if (!_smsCodeTextField) {
        _smsCodeTextField = [[SSThemedTextField alloc] init];
        _smsCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _smsCodeTextField.returnKeyType = UIReturnKeyDone;
        _smsCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _smsCodeTextField.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _smsCodeTextField.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        _smsCodeTextField.borderColorThemeKey = kColorLine9;
        _smsCodeTextField.textColorThemeKey = kColorText1;
        _smsCodeTextField.placeholderColorThemeKey = kColorText9;
        _smsCodeTextField.backgroundColorThemeKey = kColorBackground20;
        _smsCodeTextField.textAlignment = NSTextAlignmentLeft;
        _smsCodeTextField.layer.masksToBounds = YES;
        _smsCodeTextField.edgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);  //缩进40px
        _smsCodeTextField.placeholder = NSLocalizedString(@"请输入验证码", nil);
        _smsCodeTextField.delegate = self;
        [_smsCodeTextField addTarget:self action:@selector(textFieldDidChangeCharacters:) forControlEvents:UIControlEventEditingChanged];
    }
    return _smsCodeTextField;
}

- (SSThemedButton *)sendSmsCodeButton
{
    if (!_sendSmsCodeButton) {
        _sendSmsCodeButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _sendSmsCodeButton.titleColorThemeKey = kColorText1;
        _sendSmsCodeButton.disabledTitleColorThemeKey = kColorText3;
        _sendSmsCodeButton.highlightedTitleColorThemeKey = kColorText1Highlighted;
        _sendSmsCodeButton.layer.masksToBounds = YES;
        _sendSmsCodeButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _sendSmsCodeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _sendSmsCodeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_sendSmsCodeButton setTitle:NSLocalizedString(@"发送验证码", nil)
                            forState:UIControlStateNormal];
        [_sendSmsCodeButton addTarget:self
                               action:@selector(actionDidTapSendSMSCodeButton:)
                     forControlEvents:UIControlEventTouchUpInside];
        [_sendSmsCodeButton sizeToFit];
    }
    return _sendSmsCodeButton;
}

- (SSThemedButton *)submitButton
{
    if (!_submitButton) {
        _submitButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _submitButton.layer.masksToBounds = YES;
        _submitButton.backgroundColorThemeKey = kColorBackground7;
        _submitButton.titleColorThemeKey = kColorText12;
        _submitButton.highlightedTitleColorThemeKey = kColorText8Highlighted;
        _submitButton.highlightedBackgroundColorThemeKey = kColorBackground7Highlighted;
        _submitButton.highlightedBorderColorThemeKey = kColorText7Highlighted;
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        _submitButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _submitButton.enabled = NO;
        _submitButton.alpha = 0.5;
        [_submitButton setTitle:NSLocalizedString(@"确定", nil)
                       forState:UIControlStateNormal];
        [_submitButton addTarget:self
                          action:@selector(actionDidTapSubmitBindingOpButton:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

- (SSThemedView *)verSeparatorView
{
    if (!_verSeparatorView) {
        _verSeparatorView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceHelper ssOnePixel], [TTDeviceUIUtils tt_newPadding:12])];
        _verSeparatorView.backgroundColorThemeKey = kColorLine9;
    }
    return _verSeparatorView;
}

- (TTUserPrivacyView *)privacyView
{
    if (!_privacyView) {
        _privacyView = [TTUserPrivacyView new];
        
        __weak typeof(self) weakSelf = self;
        
        _privacyView.viewPrivacyHandler = ^() {
            wrapperTrackEvent(@"login_register", @"click_privacy");
            
            [UIApplication openPrivacyProtectionFromViewController:weakSelf.navigationController
                                                      useBarHeight:NO];
        };
        
        _privacyView.viewUserAgreementHandler = ^() {
            wrapperTrackEvent(@"login_register", @"click_agreement");
            
            [UIApplication openUserAgreementFromViewController:weakSelf.navigationController
                                                  useBarHeight:NO];
        };
        
        _privacyView.viewCheckActionHandler = ^() {
            [weakSelf refreshSubmitBindingMobileButtonStatus];
        };
        
        [_privacyView layoutIfNeeded];
    }
    return _privacyView;
}

- (NSString*)titleHintString
{
    if (isEmptyString(_titleHintString)) {
        _titleHintString  = [[self class] tipBindTitle];
    }
    return _titleHintString;
}

#pragma mark - NSUserDefault

static NSString * const kTTShowBindingMobielTimes = @"kTTShowBindingMobielTimes";

+ (NSInteger)showBindingMobileTimes
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kTTShowBindingMobielTimes] integerValue];
}

// 更新已展示次数
+ (void)setShowBindingMobileTimes:(NSInteger)times
{
    [[NSUserDefaults standardUserDefaults] setObject:@(times) forKey:kTTShowBindingMobielTimes];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static BOOL s_showBindingMobileEnabled = NO;

+ (void)setShowBindingMobileEnabled:(BOOL)enabled
{
    s_showBindingMobileEnabled = enabled;
}


// 判断当前是否可显示绑定手机号弹窗
+ (BOOL)showBindingMobileEnabled
{
    return s_showBindingMobileEnabled;
}

//title提示文案
+ (NSString *)tipBindTitle
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"ttAccountTipBindTitle"];
}

+ (void)setTipBindTitle:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"ttAccountTipBindTitle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


//退出提示文案
+ (NSString *)tipBindCancel
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"ttAccountTipBindCancel"];
}

+ (void)setTipBindCancel:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"ttAccountTipBindCancel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

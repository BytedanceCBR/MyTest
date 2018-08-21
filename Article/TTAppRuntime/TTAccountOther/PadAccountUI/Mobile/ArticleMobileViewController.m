//
//  ArticleMobileViewController.m
//  Article
//
//  Created by SunJiangting on 14-7-9.
//
//

#import "ArticleMobileViewController.h"
#import <ImageIO/ImageIO.h>
#import <TTIndicatorView.h>
#import <TTThemedAlertController.h>
#import <UIViewController+NavigationBarStyle.h>
#import <TTDeviceHelper.h>
#import <TTUIResponderHelper.h>
#import <UIImage+TTThemeExtension.h>

#import <TTAccountBusiness.h>

#import "ArticleMobileLoginViewController.h"
#import "ArticleListNotifyBarView.h"


#define kContainerViewLeftPadding 20
#define kContainerViewRightPadding 20

const NSInteger ArticleRetrieveTimeoutInterval = 60;

@interface ArticleMobileViewController () {
    BOOL _keyboardVisible;
    SSThemedButton * _mobileButton;
}

@property(nonatomic, strong) SSThemedView *backgroundView;

@property(nonatomic, retain) ArticleListNotifyBarView *notifyBarView;
@property(nonatomic, strong) TTIndicatorView *waitingIndicatorView;

@property(nonatomic, assign) BOOL mobileButtonEnabled;


@end

@implementation ArticleMobileViewController

- (void)dealloc {
    [self _dismissWaitingIndicator];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.automaticallyAdjustKeyboardOffset = NO;
        self.mobileNumber = [TTAccountManager draftMobile];
        self.modeChangeActionType = ModeChangeActionTypeCustom;
        self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
        self.isBindingVC = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    /*
     if ([UIViewController instanceMethodForSelector:@selector(setWantsFullScreenLayout:)]) {
     self.wantsFullScreenLayout = NO;
     }*/
    self.backgroundView = [[SSThemedView alloc] initWithFrame:[self _backgroundViewFrame]];
    self.backgroundView.backgroundColors = SSThemedColors(@"fafafa", @"252525");
    [self.view addSubview:self.backgroundView];
    
    self.navigationBar = [[SSNavigationBar alloc] initWithFrame:[self _navigationBarFrame]];
    
    self.containerView =
    [[SSThemedView alloc] initWithFrame:[self _containerViewFrame]];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.containerView];
    self.containerView.userInteractionEnabled = YES;
    [self.view bringSubviewToFront:self.navigationBar];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapActionFired:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.containerView addGestureRecognizer:tapGestureRecognizer];
    
    self.notifyBarView = [[ArticleListNotifyBarView alloc]
                          initWithFrame:[self _notifyBarViewFrame]];
    [self.view addSubview:_notifyBarView];
    
    self.inputContainerView = [[SSThemedView alloc] initWithFrame:[self _inputContainerViewFrame]];
    self.inputContainerView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.inputContainerView.borderColorThemeKey = kColorLine1;
    self.inputContainerView.backgroundColorThemeKey = kColorBackground4;
    //    self.inputContainerView.layer.cornerRadius = [ArticleMobileLoginViewController heightOfInputField] / 2;
    [self.containerView addSubview:self.inputContainerView];
    
    [self reloadThemeUI];
}

- (CGRect)_backgroundViewFrame
{
    return self.view.bounds;
}

- (CGRect)_inputContainerViewFrame
{
    return CGRectMake(0, 30, (self.containerView.width), [ArticleMobileLoginViewController heightOfInputField]);
}

- (CGRect)_notifyBarViewFrame
{
    return CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), self.view.width, [SSCommonLogic articleNotifyBarHeight]);
}

- (CGRect)_navigationBarFrame
{
    return CGRectMake(0, 0, self.view.frame.size.width, [SSNavigationBar navigationBarHeight]);
}

- (CGRect)_containerViewFrame
{
    CGFloat containerWidth = [TTUIResponderHelper splitViewFrameForView:self.view].size.width - kContainerViewLeftPadding - kContainerViewRightPadding;
    
    if ([TTDeviceHelper isPadDevice]) {
        return CGRectMake(kContainerViewLeftPadding + [TTUIResponderHelper splitViewFrameForView:self.view].origin.x, CGRectGetMaxY(self.navigationBar.frame),
                          containerWidth, self.view.frame.size.height - CGRectGetMaxY(self.navigationBar.frame));
    }else {
        return CGRectMake(kContainerViewLeftPadding, CGRectGetMaxY(self.navigationBar.frame),
                          containerWidth, self.view.frame.size.height - CGRectGetMaxY(self.navigationBar.frame));
    }
}

- (void)viewDidLayoutSubviews
{
    
    [super viewDidLayoutSubviews];
    self.backgroundView.frame = [self _backgroundViewFrame];
    self.navigationBar.frame = [self _navigationBarFrame];
    self.containerView.frame = [self _containerViewFrame];
    self.notifyBarView.frame = [self _notifyBarViewFrame];
    self.inputContainerView.frame = [self _inputContainerViewFrame];
    _mobileButton.size = CGSizeMake((self.containerView.width), [ArticleMobileViewController heightOfMobileButton]);
    
}

- (void)themeChanged:(NSNotification *)notification {
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self.view findFirstResponder] resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self _dismissWaitingIndicator];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backgroundTapActionFired:(UITapGestureRecognizer *)tapGestureRecognizer {
    UIResponder *responder = [self.view findFirstResponder];
    if ([responder isKindOfClass:[UITextField class]] || [responder isKindOfClass:[UITextView class]]) {
        [responder resignFirstResponder];
    }
}

- (SSThemedButton *)mobileButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    
    if (self.isBindingVC) {
        
        SSThemedButton *button = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleColorThemeKey = kColorText8;
        button.highlightedTitleColorThemeKey = kColorText8Highlighted;
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.layer.cornerRadius = kTTAccountLoginInputFieldHeight / 2;
        button.layer.masksToBounds = YES;
        button.backgroundColorThemeKey = kColorBackground7;
        button.highlightedBackgroundColorThemeKey = kColorBackground7Highlighted;
        button.highlightedBorderColorThemeKey = kColorText7Highlighted;
        self.mobileButtonEnabled = [self isContentValid];
        _mobileButton = button;
        [self refreshMobileButton];
        return button;
    }
    else {
        SSThemedButton *button = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        //button.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        button.layer.cornerRadius = 3.f;
        button.layer.masksToBounds = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:[ArticleMobileViewController fontSizeOfMobileButtonTitle]];
        button.size = CGSizeMake((self.containerView.width), [ArticleMobileViewController heightOfMobileButton]);
        self.mobileButtonEnabled = [self isContentValid];
        _mobileButton = button;
        [self refreshMobileButton];
        return button;
    }
}

// Subclass should override this method
- (BOOL)isContentValid
{
    return NO;
}

- (void)refreshMobileButton
{
    if (self.isBindingVC) {
        
        _mobileButton.backgroundColorThemeKey = kColorBackground7;
        _mobileButton.highlightedBackgroundColorThemeKey = kColorBackground7Highlighted;
        _mobileButton.titleColorThemeKey = kColorText8;
        _mobileButton.highlightedTitleColorThemeKey = kColorText8Highlighted;
        if (self.mobileButtonEnabled) {
            _mobileButton.alpha = 1.f;
        } else {
            _mobileButton.alpha = 0.5f;
        }
    }
    else {
        if (self.mobileButtonEnabled) {
            _mobileButton.backgroundColorThemeKey = kColorBackground7;
            _mobileButton.titleColorThemeKey = kColorText7;
            _mobileButton.highlightedBackgroundColorThemeKey = kColorBackground7Highlighted;
            _mobileButton.highlightedTitleColorThemeKey = kColorText7Highlighted;
        } else {
            _mobileButton.backgroundColorThemeKey = kColorBackground1Disabled;
            _mobileButton.titleColorThemeKey = kColorText7;
            _mobileButton.highlightedBackgroundColorThemeKey = kColorBackground1Disabled;
            _mobileButton.highlightedTitleColorThemeKey = kColorText7Highlighted;
        }
    }
}

- (void)refreshMobileButtonIfNeeded
{
    if (self.mobileButtonEnabled != [self isContentValid]) {
        self.mobileButtonEnabled = !self.mobileButtonEnabled;
        [self refreshMobileButton];
    }
}

- (void)textFieldDidChange:(NSNotification *)notification
{
    [self refreshMobileButtonIfNeeded];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self keyboardWillChangeFrame:notification keyboardHidden:NO];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self keyboardWillChangeFrame:notification keyboardHidden:YES];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification keyboardHidden:(BOOL)hidden {
    if (!self.automaticallyAdjustKeyboardOffset || self.maximumHeightOfContent == 0) {
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    /// keyboard相对于屏幕的坐标
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
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
    
    CGFloat duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = self.containerView.frame;
    if (hidden) {
        frame.origin.y = CGRectGetMaxY(self.navigationBar.frame);
    } else {
        CGFloat offset = (self.maximumHeightOfContent + 44) - CGRectGetMinY(keyboardScreenFrame);
        if (offset > 0 && offset < CGRectGetHeight(self.containerView.frame)) {
            frame.origin.y = CGRectGetMaxY(self.navigationBar.frame) - offset;
        }
        
        // fix iPhone4上展示样式BUG
        const CGFloat minTopInset = (64 - 20);
        frame.origin.y = MAX(frame.origin.y, minTopInset);
    }
    if (duration == 0) {
        duration = 0.25;
    }
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:options
                     animations:^{ self.containerView.frame = frame; }
                     completion:^(BOOL finished) { self.containerView.frame = frame; }];
}

- (void)showNotifyBarMsg:(NSString *)msg {
    if (!isEmptyString(msg)) {
        [_notifyBarView showMessage:msg
                  actionButtonTitle:nil
                          delayHide:YES
                           duration:3
                bgButtonClickAction:NULL
             actionButtonClickBlock:NULL
                       didHideBlock:NULL];
    }
}

#pragma mark - WaitingIndicator

- (void)showWaitingIndicator {
    self.containerView.userInteractionEnabled = NO;
    _waitingIndicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:nil indicatorImage:nil dismissHandler:nil];
    _waitingIndicatorView.showDismissButton = NO;
    _waitingIndicatorView.autoDismiss = NO;
    [_waitingIndicatorView showFromParentView:self.view];
}

- (void)dismissWaitingIndicator
{
    [self _dismissWaitingIndicator];
}

- (void)dismissWaitingIndicatorWithError:(NSError *)error {
    NSString *desc = [self _indicatorErrorTextFromError:error];
    if (!isEmptyString(desc)) {
        self.containerView.userInteractionEnabled = NO;
        [_waitingIndicatorView updateIndicatorWithImage:[UIImage themedImageNamed:@"close_popup_textpage"]];
        [self dismissWaitingIndicatorWithText:desc];
    }
}

- (void)dismissWaitingIndicatorWithText:(NSString *)message {
    [_waitingIndicatorView updateIndicatorWithText:message
                           shouldRemoveWaitingView:YES];
    __weak ArticleMobileViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf _dismissWaitingIndicator];
    });
}

- (void)_dismissWaitingIndicator {
    self.containerView.userInteractionEnabled = YES;
    [_waitingIndicatorView dismissFromParentView];
    _waitingIndicatorView = nil;
}

#pragma mark - Indicator
- (void)showAutoDismissIndicatorWithError:(NSError *)error
{
    NSString *desc = [self _indicatorErrorTextFromError:error];
    if (!isEmptyString(desc)) {
        [self showAutoDismissIndicatorWithText:desc];
    }
}

- (void)showAutoDismissIndicatorWithText:(NSString *)text
{
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
}

- (NSString *)_indicatorErrorTextFromError:(NSError *)error
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
    }
    else if ([error.domain isEqualToString:@"NSURLErrorDomain"]) {
        if (desc.length == 0) {
            desc = NSLocalizedString(@"服务器不给力，请稍后重试", nil);
        }
    }
    if (desc.length == 0) {
        return nil;
    }
    return desc;
}

- (void)backToMainViewControllerAnimated:(BOOL)animated {
    [self backToMainViewControllerAnimated:animated completion:NULL];
}

- (void)backToMainViewControllerAnimated:(BOOL)animated completion:(ArticleMobilePiplineCompletion)completion {
    [self _dismissWaitingIndicator];
    NSArray *viewControllers = self.navigationController.viewControllers;
    /// find LoginViewController
    __block BOOL hasIntroduction = NO;
    [[self class] setPreviousMobileCodeInformation:nil];
    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:NSClassFromString(@"SSIntroduceViewController")]) {
            hasIntroduction = YES;
            *stop = YES;
        }
    }];
    if (hasIntroduction && self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          if (completion) {
                                                              completion(ArticleLoginStateMobileLogin);
                                                          }
                                                      }];
    } else {
        __block NSInteger firstLoginIdx = -1;
        [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[ArticleMobileViewController class]]) {
                firstLoginIdx = idx;
                *stop = YES;
            }
        }];
        if (firstLoginIdx > 0) {
            UIViewController *viewController = viewControllers[firstLoginIdx - 1];
            [self.navigationController popToViewController:viewController animated:NO];//这里把pop 动画改NO 防止iOS7下的 nav崩溃
        } else {
            //            [self.navigationController popViewControllerAnimated:animated];
            if (self.navigationController.presentingViewController) {
                [self.navigationController dismissViewControllerAnimated:animated completion:NULL];
            }
        }
        if (completion) {
            completion(self.state);
        }
    }
}

- (BOOL)validateMobileNumber:(NSString *)mobileNumber {
    NSString *regex = @"^1\\d{10}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:mobileNumber]) {
        return YES;
    }
    return NO;
}

- (void)alertInvalidateMobileNumberWithCompletionHandler:(void (^)(void))completionHandler {
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请输入正确的手机号", nil) preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        if (completionHandler) {
            completionHandler();
        }
    }];
    [alert showFrom:self animated:YES];
}

static NSDictionary *_previousMobileCodeInformation;

+ (void)setPreviousMobileCodeInformation:(NSDictionary *)dictionary {
    _previousMobileCodeInformation = [dictionary copy];
}
+ (NSDictionary *)previousMobileCodeInformation {
    return _previousMobileCodeInformation;
}

+ (CGFloat)fontSizeOfMobileButtonTitle
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice] || [TTDeviceHelper isIPhoneXDevice]) {
        return 17.f;
    } else {
        return 15.f;
    }
}

+ (CGFloat)heightOfMobileButton
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 50.f;
    } else {
        return 44.f;
    }
}

+ (CGFloat)heightOfInputField
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 50.f;
    } else {
        return 44.f;
    }
}

+ (CGFloat)fontSizeOfInputFiled
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 17.f;
    } else {
        return 15.f;
    }
}

@end

@implementation UIImage (ArticleGIFImage)

+ (UIImage *)gifImageNamed:(NSString *)gifName {
    return [self gifImageNamed:gifName duration:NULL];
}

+ (UIImage *)gifImageNamed:(NSString *)gifName duration:(NSTimeInterval *)_duration {
    NSString *singleScale = [[NSBundle mainBundle] pathForResource:gifName ofType:@".gif"];
    NSString *doubleScale = [[NSBundle mainBundle] pathForResource:[gifName stringByAppendingString:@"@2x"] ofType:@".gif"];
    NSData *singleData = [NSData dataWithContentsOfFile:singleScale];
    NSData *doubleData = [NSData dataWithContentsOfFile:doubleScale];
    NSData *data = singleData;
    if ([UIScreen mainScreen].scale > 1) {
        data = doubleData.length > 0 ? doubleData : singleData;
    }
    if (!data) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    } else {
        NSMutableArray *images = [NSMutableArray array];
        NSTimeInterval duration = 0.0f;
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            NSDictionary *frameProperties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, i, NULL));
            duration += [[[frameProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary]
                          objectForKey:(NSString *)kCGImagePropertyGIFDelayTime] doubleValue];
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        if (_duration) {
            *_duration = duration;
        }
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    CFRelease(source);
    return animatedImage;
}

@end

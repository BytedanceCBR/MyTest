//
//  TTUserProfileInputView.m
//  Article
//
//  Created by 王双华 on 15/10/10.
//
//

#import "TTUserProfileInputView.h"
#import "TTNavigationController.h"
#import "TTDeviceHelper.h"
#import "UITextView+TTAdditions.h"
#import "NSString+TTLength.h"


#define kButtonWidth        [TTDeviceUIUtils tt_newPadding:57.f]
#define kButtonHeight       [TTDeviceUIUtils tt_newPadding:28.f]
#define kButtonGap          15
#define kButtonRightMargin  10


@interface TTUserProfileInputView()<UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView * inputBackgroundView;
@property (nonatomic, strong) SSThemedLabel * countLabel;
@property (nonatomic, strong) SSThemedButton * publishButton;
@property (nonatomic, assign) BOOL      hasRemovedFromWindow;

@end

//const NSInteger TTUserProfileInputViewDefaultHeight = 174;
const NSInteger TTUserProfileInputViewDefaultHeight = 160;


@implementation TTUserProfileInputView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (CGRect)frameForBackgroundView
{
    CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
    
    if ([TTDeviceHelper OSVersionNumber] < 8.0 &&
        !UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        frame.size = CGSizeMake(frame.size.height, frame.size.width);
    }

    return frame;
}

- (instancetype) initWithFrame:(CGRect)frame{
    frame = [TTUserProfileInputView frameForBackgroundView];
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.backgroundView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.backgroundView];
        
        UIGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTapActionFired:)];
        tapGesture.delegate  = self;
        [self.backgroundView addGestureRecognizer:tapGesture];
        
        self.editView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - [TTDeviceUIUtils tt_newPadding:TTUserProfileInputViewDefaultHeight], CGRectGetWidth(frame), [TTDeviceUIUtils tt_newPadding:TTUserProfileInputViewDefaultHeight])];
        self.editView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.editView];
        
        
//        self.inputBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 40, CGRectGetWidth(self.editView.bounds) - 20, 90)];
        CGFloat inputViewPadding = [TTDeviceUIUtils tt_newPadding:14.f];
        CGFloat inputViewBottomPadding = [TTDeviceUIUtils tt_newPadding:44.f];
        
        self.inputBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(inputViewPadding, inputViewPadding, CGRectGetWidth(self.editView.bounds) - (2 * inputViewPadding), self.editView.height - (inputViewPadding + inputViewBottomPadding))];
        self.inputBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.inputBackgroundView.layer.cornerRadius = 4;
        self.inputBackgroundView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        [self.editView addSubview:self.inputBackgroundView];
        
//        CGRect textRect = CGRectMake(10, 12, CGRectGetWidth(self.inputBackgroundView.bounds) - 20 , CGRectGetHeight(self.inputBackgroundView.bounds) - 35);
        CGRect textRect = CGRectMake(4, 0, CGRectGetWidth(self.inputBackgroundView.bounds) - 4, CGRectGetHeight(self.inputBackgroundView.bounds) - 1);
        
        self.textView = [[SSThemedTextView alloc] initWithFrame:textRect];
        self.textView.contentInset = UIEdgeInsetsZero;
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.delegate = self;
        self.textView.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.f]];
        self.textView.placeHolderFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.f]];
        self.textView.scrollsToTop = NO;
        [self.inputBackgroundView addSubview:self.textView];
        
        self.countLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.inputBackgroundView.bounds) - 50, CGRectGetMaxY(self.inputBackgroundView.bounds) - 18, 40, 11)];
        self.countLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:11.f]];
        self.countLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        self.countLabel.backgroundColor = [UIColor clearColor];
        self.countLabel.textAlignment = NSTextAlignmentRight;
        [self.inputBackgroundView addSubview:self.countLabel];
        
        self.tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(self.inputBackgroundView.left, CGRectGetMaxY(self.inputBackgroundView.bounds)+self.inputBackgroundView.frame.origin.y+16 ,230, [TTDeviceUIUtils tt_fontSize:12.f])];
        self.tipLabel.centerY = (self.editView.height - self.inputBackgroundView.bottom) / 2 + self.inputBackgroundView.bottom;
        self.tipLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
        self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        self.tipLabel.backgroundColor = [UIColor clearColor];
        self.tipLabel.textAlignment = NSTextAlignmentLeft;
        [self.editView addSubview:self.tipLabel];

        self.publishButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.publishButton.frame = CGRectMake(0, 0, kButtonWidth, kButtonHeight);
        self.publishButton.right = self.inputBackgroundView.right;
        self.publishButton.centerY = self.tipLabel.centerY;
        [self.publishButton setTitle:@"确定" forState:UIControlStateNormal];
        self.publishButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14.f]];
        self.publishButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.publishButton.layer.cornerRadius = 6;
        self.publishButton.backgroundColorThemeKey = kColorBackground8;
        self.publishButton.titleColorThemeKey = kColorText12;
        self.publishButton.disabledTitleColorThemeKey = kColorText10;
        self.publishButton.disabledBackgroundColors = SSThemedColors(@"cacaca", @"505050");
        [self.publishButton addTarget:self action:@selector(publishActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.editView addSubview:self.publishButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleUITextViewTextDidChangeNotification:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:_textView];
        [self reloadThemeUI];
    }
    return  self;
}

- (void)setType:(TTUserProfileInputViewType)type{
    _type = type;
    if (type == TTUserProfileInputViewTypeName) {
        self.textView.placeHolder = @"请输入用户名";
        [self.tipLabel setText:NSLocalizedString(@"支持中英文、数字", nil)];
        self.count = 20;
    }
    else if(type == TTUserProfileInputViewTypeSign){
        self.textView.placeHolder = @"请输入个性签名";
        [self.tipLabel setText:NSLocalizedString(@"", nil)];
        self.count = 60;
    }
    else if (type == TTUserProfileInputViewTypePGCSign) {
        self.textView.placeHolder = @"请输入个性签名";
        [self.tipLabel setText:NSLocalizedString(@"10-30个字", nil)];
        self.count = 60;
    }
}

- (void)refreshCountLabel{
    if (self.count > 0) {
        NSInteger wordLength = [_textView.text tt_lengthOfBytes];
        _countLabel.text = [NSString stringWithFormat:@"%lu", MAX(0, self.count - wordLength)];
        if (self.count - wordLength <= 0) {
            _countLabel.text = [NSString stringWithFormat:@"-%lu", MAX(0, self.count - wordLength)];
        }
        if ([_textView.text tt_lengthOfBytes] == 0) {
            self.publishButton.enabled = NO;
        }
        else{
            self.publishButton.enabled = YES;
        }
    }
}

- (void)willAppear{
    [super willAppear];
}

- (void)didAppear{
    [super didAppear];
}

- (void)willDisappear{
    [super willDisappear];
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    [super willMoveToWindow:newWindow];
    
    UIViewController * viewController = (UIViewController *)[TTUIResponderHelper topViewControllerFor: self];
    TTNavigationController * navigationController = (TTNavigationController *)viewController;
    
    if (!newWindow) {
        self.hasRemovedFromWindow = YES;
        if ([navigationController isKindOfClass:[TTNavigationController class]]) {
        navigationController.topViewController.ttDisableDragBack = NO;
        }
    }
    if (newWindow && self.hasRemovedFromWindow) {
        if (!self.textView.isFirstResponder) {
            [self.textView becomeFirstResponder];
        }
        if ([navigationController isKindOfClass:[TTNavigationController class]]) {
        navigationController.topViewController.ttDisableDragBack = YES;
        }
    }
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
    self.inputBackgroundView.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.inputBackgroundView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine7) CGColor];
    self.editView.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);
    self.textView.placeHolderColor = SSGetThemedColorWithKey(kColorText9);
    self.textView.textColor = SSGetThemedColorWithKey(kColorText1);
    
    self.tipLabel.textColor = SSGetThemedColorWithKey(kColorText3);
    self.countLabel.textColor = SSGetThemedColorWithKey(kColorText3);
}

- (void)showInView:(UIView *)view animated:(BOOL)animated{
    if (!view) {
        view = SSGetMainWindow();
    }
    [self refreshCountLabel];
    UIViewController *viewController = (UIViewController *)[TTUIResponderHelper topViewControllerFor: view];
    viewController = (TTNavigationController *)viewController.navigationController;
    if ([viewController isKindOfClass:[TTNavigationController class]]) {
    TTNavigationController *navigationController = (TTNavigationController *)viewController;
    navigationController.topViewController.ttDisableDragBack = YES;
    }
    [viewController.view addSubview:self];
    self.editView.top = CGRectGetHeight(self.bounds);
    self.backgroundView.alpha = 0.0;
    [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundView.alpha = 0.5;
    } completion:^(BOOL finished) {
        [self.textView becomeFirstResponder];
        
    }];
}

- (void)dismissAnimated:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self.textView resignFirstResponder];
    self.backgroundView.alpha = 0.5;
    [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundView.alpha = 0.1;
    } completion:^(BOOL finished) {
        UIViewController * viewController = (UIViewController *)[TTUIResponderHelper topViewControllerFor: self.superview];
        
        if ([viewController isKindOfClass:[TTNavigationController class]]) {
            TTNavigationController * navigationController = (TTNavigationController *)viewController;
             navigationController.topViewController.ttDisableDragBack = NO;
        }
       
        [self removeFromSuperview];
        
    }];
}

- (void)cancelActionFired:(id)sender{
    if([self.delegate respondsToSelector:@selector(cancelButtonClicked:)]) {
        [self.delegate performSelector:@selector(cancelButtonClicked:) withObject:self];
    }
    [self dismissAnimated:YES];
}

- (void)publishActionFired:(id)sender{
    if([self.delegate respondsToSelector:@selector(confirmButtonClicked:)]) {
        [self.delegate performSelector:@selector(confirmButtonClicked:) withObject:self];
    }
    [self dismissAnimated:YES];
}

- (void)handleUITextViewTextDidChangeNotification:(NSNotification *)notification
{
    if ([self.textView.text tt_lengthOfBytes] > self.count && self.textView.markedTextRange == nil) {
        NSUInteger limitedLength = [self.textView.text limitedLengthOfMaxCount:self.count];
        self.textView.text = [self.textView.text substringToIndex:MIN(limitedLength, self.textView.text.length - 1)];
        [self.textView showOrHidePlaceHolderTextView];
    }
    [self refreshCountLabel];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // add [text lenght] == 0 to enable old string over limited
    NSInteger changedLength = [textView.text tt_lengthOfBytes] - range.length + [text tt_lengthOfBytes];
    return changedLength <= self.count || [text length] == 0;
}

#pragma mark - UITapGesture
- (void) backgroundTapActionFired:(id) sender {
    if([self.delegate respondsToSelector:@selector(cancelButtonClicked:)]) {
        [self.delegate performSelector:@selector(cancelButtonClicked:) withObject:self];
    }
    [self dismissAnimated:YES];
}

#pragma mark - UIKeyboardNotification
- (void) keyboardWillChangeFrame:(NSNotification *) notification {
    
    NSDictionary * userInfo = notification.userInfo;
    /// keyboard相对于屏幕的坐标
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ([TTDeviceHelper isPadDevice] && [TTDeviceHelper OSVersionNumber] < 8.0) {
        keyboardScreenFrame = [self convertRect:keyboardScreenFrame fromView:nil];
    }
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
    
    CGRect frame = self.editView.frame;
    if (keyboardScreenFrame.origin.y == self.frame.size.height) {
        frame.origin.y = self.frame.size.height;
    }
    else{
        frame.origin.y = CGRectGetMinY(keyboardScreenFrame) - CGRectGetHeight(frame);
    }
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.editView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    [self dismissAnimated:YES];
}
@end


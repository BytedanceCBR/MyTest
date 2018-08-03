//
//  TTStrongPushAlertView.m
//  Article
//
//  Created by liuzuopeng on 02/07/2017.
//
//

#import "TTStrongPushAlertView.h"
#import "TTStrongPushImagesView.h"
#import "UILabel+SizeToTextParagraphStyle.h"
#import <TTKeyboardListener.h>
#import <TTUIResponderHelper.h>
#import "TTPushAlertModel.h"


#define IS_PHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define UIScreenWidth   (IS_PHONE ? [[UIScreen mainScreen] bounds].size.width : [UIApplication sharedApplication].keyWindow.bounds.size.width)
#define UIScreenHeight  (IS_PHONE ? [[UIScreen mainScreen] bounds].size.height : [UIApplication sharedApplication].keyWindow.bounds.size.height)

#define UIPortraitScreenWidth  (MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height))
#define UIPortraitScreenHeight (MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height))
#define UIPortraitScreenBounds (CGRectMake(0, 0, UIPortraitScreenWidth, UIPortraitScreenHeight))


#define TTAlertMaxContainerWidth   (636/2)
#define TTInsetTop                 ([TTDeviceUIUtils tt_newPadding:24.f/2])
#define TTButtonHeight             ([TTDeviceUIUtils tt_newPadding:88.f/2])
#define TTButtonInsetTopSpacing    ([TTDeviceUIUtils tt_newPadding:32.f/2])
#define TTVolumeWidthOrHeight      (MAX(14, [TTDeviceUIUtils tt_newPadding:28.f/2]))
#define TTInsetLeftOrRight         ([TTDeviceUIUtils tt_newPadding:30.f/2])
#define TTVolumeToTitleLabelInHor  ([TTDeviceUIUtils tt_newPadding:14.f/2])
#define TTVolumeToDetailLabelInVer ([TTDeviceUIUtils tt_newPadding:(20.f/2 - 3)])
#define TTTextLabelToImageHeight   ([TTDeviceUIUtils tt_newPadding:(16.f/2 - 1)])
#define TTContainerViewWidth       (MIN(TTAlertMaxContainerWidth, UIPortraitScreenWidth - 57.f))



@interface TTStrongPushButtonsView : SSThemedView
@property (nonatomic, strong) SSThemedView   *horSeperatorView;
@property (nonatomic, strong) SSThemedView   *verSeperatorView;
@property (nonatomic, strong) SSThemedButton *leftActionButton;
@property (nonatomic, strong) SSThemedButton *rightActionButton;
@end
@implementation TTStrongPushButtonsView
- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupCustomViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupCustomViews];
    }
    return self;
}

- (void)setupCustomViews
{
    [self addSubview:self.horSeperatorView];
    [self addSubview:self.verSeperatorView];
    [self addSubview:self.leftActionButton];
    [self addSubview:self.rightActionButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat buttonWidth  = (width - [TTDeviceHelper ssOnePixel]) / 2;
    CGFloat buttonHeight = height - [TTDeviceHelper ssOnePixel];
    
    self.horSeperatorView.frame = CGRectMake(0,
                                             0,
                                             width,
                                             [TTDeviceHelper ssOnePixel]);
    
    self.verSeperatorView.frame = CGRectMake(buttonWidth,
                                             [TTDeviceHelper ssOnePixel],
                                             [TTDeviceHelper ssOnePixel],
                                             height - [TTDeviceHelper ssOnePixel]);
    
    self.leftActionButton.frame = CGRectMake(0,
                                             [TTDeviceHelper ssOnePixel],
                                             buttonWidth,
                                             buttonHeight);
    
    self.rightActionButton.frame = CGRectMake(width - buttonWidth,
                                              [TTDeviceHelper ssOnePixel],
                                              buttonWidth,
                                              buttonHeight);
}

#pragma mark - helper

+ (SSThemedButton *)__createCenterAlignmentButton__
{
    SSThemedButton *aButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    aButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:34.f/2]];
    aButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    aButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    aButton.titleColorThemeKey = kColorText6;
    return aButton;
}

+ (SSThemedView *)__createVerticalSeparator__
{
    CGFloat lineHeight = [TTDeviceUIUtils tt_newPadding:50.f];
    SSThemedView *lineView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceHelper ssOnePixel], lineHeight)];
    lineView.backgroundColorThemeKey = kColorLine1;
    return lineView;
}

+ (SSThemedView *)__createHorizentalSeparator__
{
    CGFloat lineWidth = [TTDeviceUIUtils tt_newPadding:100.f];
    SSThemedView *lineView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, lineWidth, [TTDeviceHelper ssOnePixel])];
    lineView.backgroundColorThemeKey = kColorLine1;
    return lineView;
}

#pragma mark - getter/setter

- (SSThemedView *)horSeperatorView
{
    if (!_horSeperatorView) {
        _horSeperatorView = [self.class __createHorizentalSeparator__];
    }
    return _horSeperatorView;
}

- (SSThemedView *)verSeperatorView
{
    if(!_verSeperatorView) {
        _verSeperatorView = [self.class __createVerticalSeparator__];
    }
    return _verSeperatorView;
}

- (SSThemedButton *)leftActionButton
{
    if (!_leftActionButton) {
        _leftActionButton = [self.class __createCenterAlignmentButton__];
        [_leftActionButton setTitle:@"忽略" forState:UIControlStateNormal];
    }
    return _leftActionButton;
}

- (SSThemedButton *)rightActionButton
{
    if (!_rightActionButton) {
        _rightActionButton = [self.class __createCenterAlignmentButton__];
        [_rightActionButton setTitle:@"立即查看" forState:UIControlStateNormal];
    }
    return _rightActionButton;
}

@end



@interface TTStrongPushAlertView () {
    UIDeviceOrientation _deviceOrientation;
}
@property (nonatomic, strong, readwrite) SSThemedView *containerView;
@property (nonatomic, strong, readwrite) SSThemedImageView *volumeImageView;
@property (nonatomic, strong, readwrite) SSThemedLabel *titleLabel;
@property (nonatomic, strong, readwrite) SSThemedLabel *detailLabel;
@property (nonatomic, strong, readwrite) TTStrongPushImagesView *imagesView;
@property (nonatomic, strong, readwrite) TTStrongPushButtonsView *buttonContainerView;;

@property (nonatomic, strong) SSThemedButton *tappedEventButton;
@end

@implementation TTStrongPushAlertView
@synthesize shouldAutorotate= _shouldAutorotate;
@synthesize alertModel      = _alertModel;
@synthesize didTapHandler   = _didTapHandler;
@synthesize willHideHandler = _willHideHandler;
@synthesize didHideHandler  = _didHideHandler;

+ (instancetype)showWithAlertModel:(TTPushAlertModel *)aModel
                     willHideBlock:(TTPushAlertDismissBlock)willHideClk
                      didHideBlock:(TTPushAlertDismissBlock)didHideClk
{
    TTStrongPushAlertView *alertView = [[self alloc] initWithAlertModel:aModel willHideBlock:willHideClk didHideBlock:didHideClk];
    [alertView show];
    return alertView;
}

- (instancetype)initWithAlertModel:(TTPushAlertModel *)aModel
                     willHideBlock:(TTPushAlertDismissBlock)willHideClk
                      didHideBlock:(TTPushAlertDismissBlock)didHideClk
{
    if ((self = [self initWithFrame:CGRectZero])) {
        _willHideHandler = willHideClk;
        _didHideHandler  = didHideClk;
        
        if ([TTDeviceHelper isPadDevice]) {
            self.shouldAutorotate = YES;
        } else {
            self.shouldAutorotate = NO;
        }
        
        self.alertModel = aModel;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupControls];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupControls];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupControls
{
    _deviceOrientation = UIDeviceOrientationPortrait;
    
    [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3f]];
    [self setTintColor:[UIColor clearColor]];
    
    [self setupCustomViews];
    
    [self addKeyboardObservers];
}

- (void)addKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)addRotateObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationDidReceiveDeviceRotateNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeRotateObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)setupCustomViews
{
    [self addSubview:self.containerView];
    
    [self.containerView addSubview:self.volumeImageView];
    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.detailLabel];
    [self.containerView addSubview:self.imagesView];
    [self.containerView addSubview:self.buttonContainerView];
    [self.containerView addSubview:self.tappedEventButton];
    
    [self.buttonContainerView.leftActionButton addTarget:self
                                                  action:@selector(handleActionDidTapIgnoreButton:)
                                        forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainerView.rightActionButton addTarget:self
                                                   action:@selector(handleActionDidTapViewInstantlyButton:)
                                         forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - layouts

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self doCustomLayout];
}

- (void)doCustomLayout
{
    CGFloat insetLeftOrRight        = TTInsetLeftOrRight;
    CGFloat volumeWidthOrHeight     = TTVolumeWidthOrHeight;
    CGFloat volumeToTitleLabelInHor = TTVolumeToTitleLabelInHor;
    CGFloat volumeToDetailLabelInVer= TTVolumeToDetailLabelInVer;
    CGFloat maxContentWidth         = TTContainerViewWidth - 2 * insetLeftOrRight;
    
    BOOL bContainsImage = [self.imagesView numberOfImages] > 0;
    
    // layout volumeImageView
    self.volumeImageView.frame = CGRectMake(insetLeftOrRight,
                                            TTInsetTop,
                                            volumeWidthOrHeight,
                                            volumeWidthOrHeight);
    
    // layout titleLabel
    self.titleLabel.left = self.volumeImageView.right + volumeToTitleLabelInHor;
    self.titleLabel.centerY = self.volumeImageView.centerY;
    self.titleLabel.width = maxContentWidth - (volumeToTitleLabelInHor + volumeWidthOrHeight);
    
    // layout detailLabel
    self.detailLabel.left = insetLeftOrRight;
    // 没图时，间距会大点
    [self.detailLabel tt_sizeToFitMaxWidth:maxContentWidth lineSpacing:(12.f/2 - 1)];
    
//    // 详情页是否大于两行，当无图并且小于两行时，间距放大点
//    BOOL bDetailLabelGreater2LN = (CGRectGetHeight(self.detailLabel.bounds) > self.detailLabel.font.lineHeight * 2);
    
    self.detailLabel.top = self.volumeImageView.bottom + (volumeToDetailLabelInVer + (bContainsImage ? 0 : 4)) /* + (!bContainsImage && !bDetailLabelGreater2LN ? 10 : 0) */;
    
    // layout imagesView
    CGFloat imagesHeight = [self __imagesContainerHeight__];
    self.imagesView.hidden = bContainsImage ? NO : YES;
    self.imagesView.frame  = CGRectMake(insetLeftOrRight,
                                        CGRectGetHeight(self.containerView.bounds) - imagesHeight - TTButtonHeight - TTButtonInsetTopSpacing,
                                        maxContentWidth,
                                        imagesHeight);
    
    // layout button
    self.buttonContainerView.bottom = CGRectGetHeight(self.containerView.bounds);
    
    // layout tap event button
    self.tappedEventButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.containerView.bounds) - CGRectGetHeight(self.buttonContainerView.bounds));
}

#pragma mark - events

- (void)handleActionDidTapIgnoreButton:(id)sender
{
    if (_didTapHandler) {
        _didTapHandler(TTStrongAlertHideTypeTapCancel);
    }
    [self hideWithAnimated:YES dismissReason:TTStrongAlertHideTypeTapCancel];
}

- (void)handleActionDidTapViewInstantlyButton:(id)sender
{
    if (_didTapHandler) {
        _didTapHandler(TTStrongAlertHideTypeTapOk);
    }
    [self hideWithAnimated:YES dismissReason:TTStrongAlertHideTypeTapOk];
}

- (void)strongPushAlertActionDidTapContentButton:(id)sender
{
    if (_didTapHandler) {
        _didTapHandler(TTStrongAlertHideTypeTapContent);
    }
    [self hideWithAnimated:YES dismissReason:TTStrongAlertHideTypeTapContent];
}

#pragma mark - show/hide

- (void)show
{
    [self showWithAnimated:YES completion:nil];
}

- (void)showWithAnimated:(BOOL)animated
              completion:(TTPushAlertVoidParamBlock)didCompletedHandler
{
    if (self.superview) return;
    
    [self.class showMe];
    
    UIView *selfSuperView = [self __findSuperViewInVisibleWindow__];
    
    [selfSuperView addSubview:self];
    [self __adjustFrameBeforeShowAnimation__];
    
    _deviceOrientation = UIDeviceOrientationPortrait;
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.containerView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                if ([TTDeviceHelper OSVersionNumber] >= 8.f) {
                    self.containerView.transform = CGAffineTransformIdentity;
                } else {
                    [self layoutOniOS7WithOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
                }
            } completion:^(BOOL finished) {
                if (didCompletedHandler) {
                    didCompletedHandler();
                }
            }];
        }];
    } else {
        if (didCompletedHandler) {
            didCompletedHandler();
        }
    }
}

- (void)hide
{
    [self hideWithAnimated:YES];
}

- (void)hideWithAnimated:(BOOL)animated
{
    [self hideWithAnimated:animated dismissReason:TTStrongAlertHideTypeExternalCall];
}

- (void)hideWithAnimated:(BOOL)animated dismissReason:(NSInteger)idx
{
    [self.class hideMe];
    
    [self removeRotateObserver];
    
    if (_willHideHandler) {
        _willHideHandler(idx);
    }
    
    [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containerView.transform = CGAffineTransformMakeScale(0.f, 0.f);
    } completion:^(BOOL finished){
        [self removeFromSuperview];
        if (_didHideHandler) {
            _didHideHandler(idx);
        }
    }];
}

#pragma mark - notifications

- (void)handleOrientationDidReceiveDeviceRotateNotification:(NSNotification *)notification
{
    if (_shouldAutorotate) {
        
        CGFloat curSuperViewWidth = CGRectGetWidth(self.superview.bounds);
        BOOL superViewRotated = fabs(curSuperViewWidth - CGRectGetWidth(self.bounds)) > FLT_EPSILON;
        
        if ([TTDeviceHelper isPadDevice]) {
            self.frame = self.superview ? self.superview.bounds : [UIScreen mainScreen].bounds;
            [self layoutIfNeeded];
            [UIView animateWithDuration:0.25 animations:^{
                self.frame = self.superview ? self.superview.bounds : [UIScreen mainScreen].bounds;
                self.containerView.frame = [self __targetRectForContainerViewWithKeyboardHeight:[TTKeyboardListener sharedInstance].keyboardHeight];
            }];
        } else {
            if (superViewRotated) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.frame = self.superview ? self.superview.bounds : [UIScreen mainScreen].bounds;
                    self.containerView.frame = [self __targetRectForContainerViewWithKeyboardHeight:[TTKeyboardListener sharedInstance].keyboardHeight];
                }];
            } else {
                // [self didDeviceOrientationChangeWhenSuperViewDoesNotRotate];
            }
        }
    }
}

- (void)didDeviceOrientationChangeWhenSuperViewDoesNotRotate
{
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    CGAffineTransform transform = CGAffineTransformIdentity;
    BOOL shouldRotate = NO;
    
    switch (_deviceOrientation) {
        case UIDeviceOrientationPortrait: {
            switch (curDeviceOrientation) {
                case UIDeviceOrientationLandscapeLeft: {
                    transform = CGAffineTransformRotate(self.containerView.transform, M_PI/2);
                    shouldRotate = YES;
                }
                    break;
                case UIDeviceOrientationLandscapeRight: {
                    transform = CGAffineTransformRotate(self.containerView.transform, -M_PI/2);
                    shouldRotate = YES;
                }
                    break;
                case UIDeviceOrientationPortrait:
                case UIDeviceOrientationPortraitUpsideDown:
                default: {
                    
                }
                    break;
            }
        }
            break;
            
        case UIDeviceOrientationLandscapeLeft: {
            switch (curDeviceOrientation) {
                case UIDeviceOrientationPortrait: {
                    transform = CGAffineTransformRotate(self.containerView.transform, -M_PI/2);
                    shouldRotate = YES;
                }
                    break;
                case UIDeviceOrientationLandscapeRight: {
                    transform = CGAffineTransformRotate(self.containerView.transform, M_PI);
                    shouldRotate = YES;
                }
                    break;
                case UIDeviceOrientationLandscapeLeft:
                case UIDeviceOrientationPortraitUpsideDown:
                default: {
                    
                }
                    break;
            }
        }
            break;
            
        case UIDeviceOrientationLandscapeRight: {
            switch (curDeviceOrientation) {
                case UIDeviceOrientationPortrait: {
                    transform = CGAffineTransformRotate(self.containerView.transform, M_PI/2);
                    shouldRotate = YES;
                }
                    break;
                case UIDeviceOrientationLandscapeLeft: {
                    transform = CGAffineTransformRotate(self.containerView.transform, M_PI);
                    shouldRotate = YES;
                }
                    break;
                case UIDeviceOrientationLandscapeRight:
                case UIDeviceOrientationPortraitUpsideDown:
                default: {
                    
                }
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    if (shouldRotate) {
        _deviceOrientation = curDeviceOrientation;
        [UIView animateWithDuration:0.25 animations:^{
            self.containerView.transform = transform;
        } completion:^(BOOL finished) {
            _deviceOrientation = curDeviceOrientation;
        }];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    if (!self.superview) return;
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect rect = [self __targetRectForContainerViewWithKeyboardHeight:keyboardSize.height];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    [UIView setAnimationCurve:animationCurve];
    self.containerView.frame = rect;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (!self.superview) return;
    if (!CGPointEqualToPoint(self.containerView.center, self.center)) {
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationCurve:animationCurve];
        self.containerView.center = self.center;
        [UIView commitAnimations];
    }
}

#pragma mark - helper

- (UIView *)__findSuperViewInVisibleWindow__
{
    return [UIApplication sharedApplication].delegate.window ? : [TTUIResponderHelper topmostView];
}

- (void)__adjustFrameBeforeShowAnimation__
{
    self.frame = self.superview ? self.superview.bounds : [UIScreen mainScreen].bounds;
    self.containerView.frame = [self __targetRectForContainerViewWithKeyboardHeight:[TTKeyboardListener sharedInstance].keyboardHeight];
    [self layoutIfNeeded];
}

- (CGRect)__targetRectForContainerViewWithKeyboardHeight:(CGFloat)keyboardHeight
{
    CGFloat containerHeight = [self __containerViewHeight__];
    CGRect targetContainerRect = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - TTContainerViewWidth) / 2,
                                                           (CGRectGetHeight(self.bounds) - containerHeight)/2,
                                                           TTContainerViewWidth,
                                                           containerHeight));
    
    CGFloat minSpacingToMarginBottom = 10.f;
    CGFloat heightExceptKeyboardAndContainer = CGRectGetHeight(self.bounds) - targetContainerRect.size.height - keyboardHeight - minSpacingToMarginBottom;
    
    if (heightExceptKeyboardAndContainer > 0)  {
        targetContainerRect.origin.y = (CGRectGetHeight(self.bounds) - keyboardHeight - targetContainerRect.size.height)/2;
    } else {
        targetContainerRect.origin.y = (CGRectGetHeight(self.bounds) - keyboardHeight - targetContainerRect.size.height - minSpacingToMarginBottom);
    }
    
    return targetContainerRect;
}

- (void)layoutOniOS7WithOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        
        CGPoint alertCenter = CGPointMake(UIScreenWidth / 2.0, UIScreenHeight / 2.0);
        CGAffineTransform transform = CGAffineTransformIdentity;
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                alertCenter.y += [TTKeyboardListener sharedInstance].keyboardHeight / 2.0;
                transform = CGAffineTransformMakeRotation(M_PI);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                alertCenter.x -= [TTKeyboardListener sharedInstance].keyboardHeight / 2.0;
                transform = CGAffineTransformMakeRotation(-M_PI/2);
                break;
            case UIInterfaceOrientationLandscapeRight:
                alertCenter.x += [TTKeyboardListener sharedInstance].keyboardHeight / 2.0;
                transform = CGAffineTransformMakeRotation(M_PI/2);
                break;
            default:
                alertCenter.y -= [TTKeyboardListener sharedInstance].keyboardHeight / 2.0;
                break;
        }
        self.containerView.transform = transform;
        CGPoint center = [[UIApplication sharedApplication].keyWindow convertPoint:alertCenter toView:self.containerView.superview];
        self.containerView.center = center;
    }
}

- (CGFloat)__containerViewHeight__
{
    CGFloat containerViewHeight = TTInsetTop + TTVolumeWidthOrHeight;
    CGFloat maxTextWidth = TTContainerViewWidth - 2 * TTInsetLeftOrRight;
    
    BOOL bContainsImage = [self.imagesView numberOfImages] > 0;
    if ([_alertModel.detailString length] > 0) {
        CGSize detailSize = [_alertModel.detailString tt_sizeForLabel:self.detailLabel withMaxWidth:maxTextWidth lineSpacing:(12.f/2 - 1)];
        // 没图时，间距会大点
        containerViewHeight += ((detailSize.height - 1) + (TTVolumeToDetailLabelInVer + (bContainsImage ? 0 : 4)));
        
        // 详情页是否大于两行，当无图并且小于两行时，间距放大点
//        BOOL bDetailLabelGreater2LN = (CGRectGetHeight(self.detailLabel.bounds) > self.detailLabel.font.lineHeight * 2);
//        containerViewHeight += ((!bContainsImage && !bDetailLabelGreater2LN) ? 2 * 10 : 0);
    }
    if (bContainsImage) {
        containerViewHeight += ([self __imagesContainerHeight__] + TTTextLabelToImageHeight);
    }
    
    containerViewHeight += (TTButtonInsetTopSpacing + TTButtonHeight);
    
    return containerViewHeight;
}

- (CGFloat)__imagesContainerHeight__
{
    switch ([self.imagesView numberOfImages]) {
        case 0: {
            return 0;
        }
            break;
        case 1: {
            return [TTDeviceUIUtils tt_newPadding:324.f/2];
        }
            break;
        default: {
            return [TTDeviceUIUtils tt_newPadding:124.f/2];
        }
            break;
    }
    return 0;
}

#pragma mark - showing helper

static BOOL s_strongPushAlertShowing = NO;

+ (void)showMe
{
    s_strongPushAlertShowing = YES;
}

+ (void)hideMe
{
    s_strongPushAlertShowing = NO;
}

+ (BOOL)isShowing
{
    return s_strongPushAlertShowing;
}

#pragma mark - setter/getter

- (void)setShouldAutorotate:(BOOL)shouldAutorotate
{
    _shouldAutorotate = shouldAutorotate;
    if (shouldAutorotate) {
        [self addRotateObserver];
    } else {
        [self removeRotateObserver];
    }
}

- (SSThemedView *)containerView
{
    if (!_containerView) {
        _containerView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _containerView.userInteractionEnabled = YES;
        _containerView.layer.cornerRadius = [TTDeviceUIUtils tt_padding:8.f/2];
        _containerView.backgroundColorThemeKey = kColorBackground4;
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}

- (TTStrongPushButtonsView *)buttonContainerView
{
    if (!_buttonContainerView) {
        _buttonContainerView = [TTStrongPushButtonsView new];
        _buttonContainerView.frame = CGRectMake(0, 0, TTContainerViewWidth, TTButtonHeight);
    }
    return _buttonContainerView;
}

- (TTStrongPushImagesView *)imagesView
{
    if (!_imagesView) {
        _imagesView = [[TTStrongPushImagesView alloc] initWithFrame:CGRectZero];
    }
    return _imagesView;
}

- (SSThemedImageView *)volumeImageView
{
    if (!_volumeImageView) {
        _volumeImageView = [[SSThemedImageView alloc] init];
        _volumeImageView.imageName = @"push_notice_popups";
        _volumeImageView.size = CGSizeMake(28.f, 28.f);
    }
    return _volumeImageView;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [SSThemedLabel new];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont systemFontOfSize:MAX(12, [TTDeviceUIUtils tt_fontSize:24.f/2])];
        _titleLabel.textColorThemeKey = kColorText3;
        _titleLabel.text = @"即时推送";
    }
    return _titleLabel;
}

- (SSThemedLabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [SSThemedLabel new];
        _detailLabel.numberOfLines = 2;
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailLabel.font = [UIFont systemFontOfSize:([TTDeviceUIUtils tt_newFontSize:34.f/2] < 16.f) ? 15 : [TTDeviceUIUtils tt_newFontSize:34.f/2]];
        _detailLabel.textColorThemeKey = kColorText1;
        _detailLabel.text = nil;
    }
    _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    return _detailLabel;
}

- (SSThemedButton *)tappedEventButton
{
    if (!_tappedEventButton) {
        _tappedEventButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_tappedEventButton addTarget:self
                               action:@selector(strongPushAlertActionDidTapContentButton:)
                     forControlEvents:UIControlEventTouchUpInside];
    }
    return _tappedEventButton;
}

- (void)setAlertModel:(TTPushAlertModel *)alertModel
{
    if (_alertModel != alertModel) {
        _alertModel = alertModel;
        
        self.titleLabel.text = alertModel.titleString;
        [self.titleLabel sizeToFit];
        self.detailLabel.text = alertModel.detailString;
        [self.detailLabel sizeToFit];
        self.imagesView.images = alertModel.images;
        
        [self layoutIfNeeded];
    }
}

@end

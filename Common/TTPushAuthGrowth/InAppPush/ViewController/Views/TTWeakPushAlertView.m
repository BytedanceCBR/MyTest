
//
//  TTWeakPushAlertView.m
//  Article
//
//  Created by liuzuopeng on 02/07/2017.
//
//

#import "TTWeakPushAlertView.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import <UIView+CustomTimingFunction.h>
#import <TTUIResponderHelper.h>
#import "NSTimer+NoRetain.h"
#import "TTInAppPushSettings.h"
#import "TTPushAlertModel.h"
#import "UILabel+SizeToTextParagraphStyle.h"



#define kTTWeakPushAlertViewToMarginBottom      (44 + [TTDeviceUIUtils tt_padding:8])
#define kTTWeakPushAlertViewHorZoomBoundary     (10.f)
#define kTTWeakPushAlertViewHorDismissBoundary  (60.f)
#define kTTWeakPushAlertViewVerZoomBoundary     (10.f)
#define kTTWeakPushAlertViewVerDismissBoundary  (20.f)

#define kTTWeakPushAlertViewScaleSize           (0.96)

#define kTTAutoDismissDuration ([TTInAppPushSettings weakAlertAutoDismissDuration])


typedef NS_ENUM(NSInteger, TTPanGestureMoveDirection) {
    TTPanGestureMoveDirectionNone,
    TTPanGestureMoveDirectionUp,
    TTPanGestureMoveDirectionDown,
    TTPanGestureMoveDirectionLeft,
    TTPanGestureMoveDirectionRight,
};

@interface TTWeakPushAlertView () {
    UIDeviceOrientation _deviceOrientation;
}

@property (nonatomic, strong) SSThemedImageView *attractedImageView;
@property (nonatomic, strong) SSThemedButton *closeButton;
@property (nonatomic, strong) SSThemedLabel  *titleLabel;
@property (nonatomic, strong) SSThemedLabel  *detailLabel;
@property (nonatomic, strong) SSThemedButton *tappedEventButton;

@property (nonatomic, strong) UIPanGestureRecognizer *dragViewPanGR;
// 记录拖动前self的位置
@property (nonatomic, assign) CGRect selfFrameBeforeDragging;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval countdownTiming;
@property (nonatomic, assign) TTPanGestureMoveDirection panBeginDirection;
@end

@implementation TTWeakPushAlertView
@synthesize shouldAutorotate= _shouldAutorotate;
@synthesize alertModel      = _alertModel;
@synthesize didTapHandler   = _didTapHandler;
@synthesize willHideHandler = _willHideHandler;
@synthesize didHideHandler  = _didHideHandler;

- (instancetype)initWithAlertModel:(TTPushAlertModel *)aModel
                     willHideBlock:(TTPushAlertDismissBlock)willHideClk
                      didHideBlock:(TTPushAlertDismissBlock)didHideClk
{
    if ((self = [super init])) {
        _alertModel = aModel;
        _willHideHandler = willHideClk;
        _didHideHandler  = didHideClk;
        
        _countdownTiming   = 0;
        _panBeginDirection = TTPanGestureMoveDirectionNone;
        _slipIntoDirection = TTWeakPushSlideDirectionFromBottom;
        _deviceOrientation = UIDeviceOrientationPortrait;
        
        _containsIndicatorHome = YES;
        
        if ([TTDeviceHelper isPadDevice]) {
            self.shouldAutorotate = YES;
        } else {
            self.shouldAutorotate = NO;
        }
        
        // setup views
        [self setupCustomViews];
        
        self.titleLabel.text = aModel.titleString;
        [self.titleLabel sizeToFit];
        self.detailLabel.text = aModel.detailString;
        [self.detailLabel sizeToFit];
        
        id imageObject = aModel.firstImageObject;
        if ([imageObject isKindOfClass:[UIImage class]]) {
            self.attractedImageView.image = (UIImage *)imageObject;
        } else if ([imageObject isKindOfClass:[NSURL class]]) {
            [self.attractedImageView sda_setImageWithURL:(NSURL *)imageObject completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
            }];
        } else if ([imageObject isKindOfClass:[NSString class]]) {
            NSURL *imageURL = [NSURL URLWithString:(NSString *)imageObject];
            if ([imageURL isFileURL]) {
                UIImage *image = [UIImage imageWithContentsOfFile:imageURL.absoluteString];
                self.attractedImageView.image = image;
            } else if ([imageURL.absoluteString hasPrefix:@"http"]) {
                [self.attractedImageView sda_setImageWithURL:(NSURL *)imageObject completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                }];
            } else {
                UIImage *image = [UIImage imageNamed:(NSString *)imageObject];
                self.attractedImageView.image = image;
            }
        }
        
        self.backgroundColorThemeKey = kColorBackground4;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 4;
    }
    return self;
}

+ (instancetype)showWithAlertModel:(TTPushAlertModel *)aModel
                     willHideBlock:(TTPushAlertDismissBlock)willHideClk
                      didHideBlock:(TTPushAlertDismissBlock)didHideClk
{
    return [[self alloc] initWithAlertModel:aModel
                              willHideBlock:willHideClk
                               didHideBlock:didHideClk];
}

+ (instancetype)showWithTitle:(NSString *)titleString
                      content:(NSString *)contentString
                  imageObject:(id)imageObject /* UIImage, NSString, NSURL */
{
    TTWeakPushAlertView *weakAlertView = [[TTWeakPushAlertView alloc] initWithTitle:titleString
                                                                            content:contentString
                                                                        imageObject:imageObject];
    [weakAlertView show];
    return weakAlertView;
}

- (instancetype)initWithTitle:(NSString *)titleString
                      content:(NSString *)contentString
                  imageObject:(id)imageObject /* UIImage, NSString, NSURL */
{
    TTPushAlertModel *aModel = [TTPushAlertModel modelWithTitle:titleString
                                                         detail:contentString
                                                         images:imageObject ? @[imageObject] : nil];
    
    return [self initWithAlertModel:aModel willHideBlock:nil didHideBlock:nil];
}

- (void)setupCustomViews
{
    [self addSubview:self.tappedEventButton];
    [self addSubview:self.attractedImageView];
    [self addSubview:self.closeButton];
    [self addSubview:self.titleLabel];
    [self addSubview:self.detailLabel];
    
    [self addGestureRecognizer:self.dragViewPanGR];
}

- (void)addRotateObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationDidReceiveDeviceRotateNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeRotateObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc
{
    [self stopTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notification

- (void)handleOrientationDidReceiveDeviceRotateNotification:(NSNotification *)note
{
    if (_shouldAutorotate) {
        CGFloat curSuperViewWidth = CGRectGetWidth(self.superview.bounds) - 2 * [self.class leftOrRightScreenMarign];
        BOOL superViewRotated = fabs(curSuperViewWidth - CGRectGetWidth(self.bounds)) > FLT_EPSILON;
        
        if ([TTDeviceHelper isPadDevice]) {
            [UIView animateWithDuration:0.25 animations:^{
                self.frame = [self endFrameDidShowAnimation];
            }];
        } else {
            if (superViewRotated) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.frame = [self endFrameDidShowAnimation];
                }];
            } else {
                [self didDeviceOrientationChangeWhenSuperViewDoesNotRotate];
            }
        }
    }
}

- (void)didDeviceOrientationChangeWhenSuperViewDoesNotRotate
{
    
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds) > 0 ? CGRectGetWidth(self.bounds) : [self.class defaultViewWidth];
    CGFloat insetLeftOrRight = [TTDeviceUIUtils tt_padding:20.f/2];
    CGFloat insetTopOrBottom = [TTDeviceUIUtils tt_padding:20.f/2];
    CGFloat titleToDetailLabelInVer = [TTDeviceUIUtils tt_padding:10.f/2];
    CGFloat imageWidthOrHeight = MAX(54.f, [TTDeviceUIUtils tt_padding:108.f/2]);
    CGFloat closeButtonSize = MAX(28.f/2, [TTDeviceUIUtils tt_padding:28.f/2]);
    CGFloat maxTextWidth = viewWidth - insetLeftOrRight * 2 - closeButtonSize - [TTDeviceUIUtils tt_padding:12.f/2];
    CGFloat offsetX = insetLeftOrRight;
    
    if (self.attractedImageView.image) {
        CGFloat imageToText = [TTDeviceUIUtils tt_padding:20.f/2];
        
        self.attractedImageView.frame = CGRectMake(offsetX,
                                                   insetTopOrBottom,
                                                   imageWidthOrHeight,
                                                   imageWidthOrHeight);
        
        offsetX = self.attractedImageView.right + imageToText;
        maxTextWidth -= (imageWidthOrHeight + imageToText);
    }
    
    // layout titleLabel
    self.titleLabel.frame = CGRectMake(offsetX,
                                       insetTopOrBottom - 1,
                                       maxTextWidth,
                                       CGRectGetHeight(self.titleLabel.frame));
    
    // layout detailLabel
    if ([self.detailLabel.text length] > 0) {
        
        [self.detailLabel tt_sizeToFitMaxWidth:maxTextWidth lineSpacing:4/*[TTDeviceUIUtils tt_padding:4.f]*/];
        self.detailLabel.left = offsetX;
        self.detailLabel.top =  [self.titleLabel.text length] > 0 ? (self.titleLabel.bottom + titleToDetailLabelInVer) : (insetTopOrBottom - 1);
    }
    
    self.closeButton.frame = CGRectMake([self.class defaultViewWidth] - insetLeftOrRight - closeButtonSize,
                                        insetTopOrBottom,
                                        closeButtonSize,
                                        closeButtonSize);
    
    self.tappedEventButton.frame = self.bounds;
}

- (void)actionForDidTapContentButton:(id)sender
{
    if (_didTapHandler) {
        _didTapHandler(TTWeakPushAlertHideTypeOpenContent);
    }
    [self hideWithAnimated:YES reason:TTWeakPushAlertHideTypeOpenContent];
}

- (void)actionForDidTapCloseButton:(id)sender
{
    if (_didTapHandler) {
        _didTapHandler(TTWeakPushAlertHideTypeTapClose);
    }
    [self hideWithAnimated:YES reason:TTWeakPushAlertHideTypeTapClose];
}

#pragma mark - pan gesture

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)panGR
{
    if (panGR.view != self)  {
        _panBeginDirection = TTPanGestureMoveDirectionNone;
        return;
    }
    
    CGPoint translation = [panGR translationInView:panGR.view.superview];
    
    [self changePanDirectionWithTranslation:translation];
    
    switch (panGR.state) {
        case UIGestureRecognizerStateBegan: {
            self.selfFrameBeforeDragging = self.frame;
            
            [self updateSelfFrameWithPanGesture:panGR];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            // 根据初始移动方向来决定当前继续移动方向
            [self updateSelfFrameWithPanGesture:panGR];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self updateSelfWhenReleasePanGR:panGR];
            
            _panBeginDirection = TTPanGestureMoveDirectionNone;
        }
            break;
        default: {
        }
            break;
    }
}

/** 记录初始移动的方向 */
- (void)changePanDirectionWithTranslation:(CGPoint)translation
{
    if (_panBeginDirection != TTPanGestureMoveDirectionNone) {
        return;
    }
    
    if (translation.x < 0) {
        _panBeginDirection = TTPanGestureMoveDirectionLeft;
    } else if (translation.x > 0) {
        _panBeginDirection = TTPanGestureMoveDirectionRight;
    } else if (translation.y > 0) {
        if (self.slipIntoDirection == TTWeakPushSlideDirectionFromBottom ||
            self.slipIntoDirection == TTWeakPushSlideDirectionFromLeftBottom ||
            self.slipIntoDirection == TTWeakPushSlideDirectionFromRightBottom) {
            _panBeginDirection = TTPanGestureMoveDirectionDown;
        }
    } else {
        if (self.slipIntoDirection == TTWeakPushSlideDirectionFromTop ||
            self.slipIntoDirection == TTWeakPushSlideDirectionFromLeftTop ||
            self.slipIntoDirection == TTWeakPushSlideDirectionFromRightTop) {
            _panBeginDirection = TTPanGestureMoveDirectionUp;
        }
    }
}

- (void)panOutAnimateWithDirection:(TTPanGestureMoveDirection)panDirection
{
    // correct
    if ((self.slipIntoDirection == TTWeakPushSlideDirectionFromBottom ||
         self.slipIntoDirection == TTWeakPushSlideDirectionFromLeftBottom ||
         self.slipIntoDirection == TTWeakPushSlideDirectionFromRightBottom) &&
        panDirection == TTPanGestureMoveDirectionUp) {
        panDirection = TTPanGestureMoveDirectionDown;
    } else if ((self.slipIntoDirection == TTWeakPushSlideDirectionFromTop ||
                self.slipIntoDirection == TTWeakPushSlideDirectionFromLeftTop ||
                self.slipIntoDirection == TTWeakPushSlideDirectionFromRightTop) &&
               panDirection == TTPanGestureMoveDirectionDown) {
        panDirection = TTPanGestureMoveDirectionUp;
    }
    
    if (panDirection == TTPanGestureMoveDirectionLeft) {
        CGRect targetRect = self.frame;
        targetRect.origin.x = -(CGRectGetWidth(self.superview.bounds));
        
        [self hideWithAnimated:YES reason:TTWeakPushAlertHideTypePanClose toFrame:targetRect];
    } else if (panDirection == TTPanGestureMoveDirectionRight) {
        CGRect targetRect = self.frame;
        targetRect.origin.x = CGRectGetWidth(self.superview.bounds);
        
        [self hideWithAnimated:YES reason:TTWeakPushAlertHideTypePanClose toFrame:targetRect];
    } else if (panDirection == TTPanGestureMoveDirectionDown) {
        CGRect targetRect = self.frame;
        targetRect.origin.y = CGRectGetHeight(self.superview.bounds);
        
        [self hideWithAnimated:YES reason:TTWeakPushAlertHideTypePanClose toFrame:targetRect];
    } else if (panDirection == TTPanGestureMoveDirectionUp) {
        CGRect targetRect = self.frame;
        targetRect.origin.y = -(CGRectGetHeight(self.bounds));
        
        [self hideWithAnimated:YES reason:TTWeakPushAlertHideTypePanClose toFrame:targetRect];
    }
}

- (void)restoreFrameAnimationWhenPanFailed
{
    [UIView animateWithDuration:0.2 customTimingFunction:CustomTimingFunctionQuadraticEasyOut animation:^{
        [self setTransform:CGAffineTransformIdentity];
        self.center = CGPointMake(CGRectGetMidX(self.selfFrameBeforeDragging), CGRectGetMidY(self.selfFrameBeforeDragging));
    } completion:^(BOOL finished) {
        if (self.countdownTiming >= kTTAutoDismissDuration) {
            [self hideWithAnimated:YES reason:TTWeakPushAlertHideTypeAutoDismiss];
        }
    }];
}

- (void)updateSelfFrameWithPanGesture:(UIPanGestureRecognizer *)panGR
{
    CGPoint translation = [panGR translationInView:panGR.view.superview];
    
    if (_panBeginDirection == TTPanGestureMoveDirectionLeft ||
        _panBeginDirection == TTPanGestureMoveDirectionRight)  {
        if (fabs(translation.x) <= kTTWeakPushAlertViewHorZoomBoundary) {
            CGFloat offset = fabs(translation.x);
            CGFloat zoomRatio = (kTTWeakPushAlertViewScaleSize - 1) / kTTWeakPushAlertViewHorZoomBoundary * offset + 1;
            [self setTransform:CGAffineTransformMakeScale(zoomRatio, zoomRatio)];
        } else {
            [self setTransform:CGAffineTransformMakeScale(kTTWeakPushAlertViewScaleSize, kTTWeakPushAlertViewScaleSize)];
        }
        
        self.centerX = CGRectGetMidX(self.selfFrameBeforeDragging) + translation.x;
        
    } else if (_panBeginDirection == TTPanGestureMoveDirectionUp ||
               _panBeginDirection == TTPanGestureMoveDirectionDown) {
        if (_panBeginDirection == TTPanGestureMoveDirectionDown) {
            if (translation.y >= 0) {
                if (fabs(translation.y) <= kTTWeakPushAlertViewVerZoomBoundary) {
                    CGFloat offset = translation.y;
                    CGFloat zoomRatio = (kTTWeakPushAlertViewScaleSize - 1) / kTTWeakPushAlertViewVerZoomBoundary * offset + 1;
                    [self setTransform:CGAffineTransformMakeScale(zoomRatio, zoomRatio)];
                } else {
                    [self setTransform:CGAffineTransformMakeScale(kTTWeakPushAlertViewScaleSize, kTTWeakPushAlertViewScaleSize)];
                }
                
                self.centerY = CGRectGetMidY(self.selfFrameBeforeDragging) + translation.y;
            } else {
                self.center = CGPointMake(CGRectGetMidX(self.selfFrameBeforeDragging), CGRectGetMidY(self.selfFrameBeforeDragging));
                [self setTransform:CGAffineTransformIdentity];
            }
            
        } else if (_panBeginDirection == TTPanGestureMoveDirectionUp) {
            if (translation.y <= 0) {
                if (fabs(translation.y) <= kTTWeakPushAlertViewVerZoomBoundary) {
                    CGFloat offset = translation.y;
                    CGFloat zoomRatio = (kTTWeakPushAlertViewScaleSize - 1) / kTTWeakPushAlertViewVerZoomBoundary * offset + 1;
                    [self setTransform:CGAffineTransformMakeScale(zoomRatio, zoomRatio)];
                } else {
                    [self setTransform:CGAffineTransformMakeScale(kTTWeakPushAlertViewScaleSize, kTTWeakPushAlertViewScaleSize)];
                }
                
                self.centerY = CGRectGetMidY(self.selfFrameBeforeDragging) + translation.y;
            } else {
                self.center = CGPointMake(CGRectGetMidX(self.selfFrameBeforeDragging), CGRectGetMidY(self.selfFrameBeforeDragging));
                [self setTransform:CGAffineTransformIdentity];
            }
            
        } else {
            self.center = CGPointMake(CGRectGetMidX(self.selfFrameBeforeDragging), CGRectGetMidY(self.selfFrameBeforeDragging));
            [self setTransform:CGAffineTransformIdentity];
        }
        
    } else {
        self.center = CGPointMake(CGRectGetMidX(self.selfFrameBeforeDragging), CGRectGetMidY(self.selfFrameBeforeDragging));
        [self setTransform:CGAffineTransformIdentity];
    }
}

- (void)updateSelfWhenReleasePanGR:(UIPanGestureRecognizer *)panGR
{
    CGPoint translation = [panGR translationInView:panGR.view.superview];
    
    if (_panBeginDirection == TTPanGestureMoveDirectionLeft ||
        _panBeginDirection == TTPanGestureMoveDirectionRight) {
        // 根据手势松开时的方向决定消失气泡时的方向
        if (fabs(translation.x) > kTTWeakPushAlertViewHorDismissBoundary) {
            if (translation.x > 0) {
                [self panOutAnimateWithDirection:TTPanGestureMoveDirectionRight];
            } else {
                [self panOutAnimateWithDirection:TTPanGestureMoveDirectionLeft];
            }
        } else {
            [self restoreFrameAnimationWhenPanFailed];
        }
    } else if (_panBeginDirection == TTPanGestureMoveDirectionUp ||
               _panBeginDirection == TTPanGestureMoveDirectionDown) {
        
        if (fabs(translation.y) > kTTWeakPushAlertViewVerDismissBoundary) {
            if (translation.y > 0) {
                [self panOutAnimateWithDirection:TTPanGestureMoveDirectionDown];
            } else {
                [self panOutAnimateWithDirection:TTPanGestureMoveDirectionUp];
            }
        } else {
            [self restoreFrameAnimationWhenPanFailed];
        }
    }
}


#pragma mark - compute frame

// 计算是否包含indicatorHome高度
- (CGFloat)iphoneXBottomOffset
{
    if (!_containsIndicatorHome) return 0;
    return [TTDeviceHelper isIPhoneXDevice] ? 34 : 0;
}

- (CGRect)initialFrameWillShowAnimationInSuperView:(UIView *)view
{
    CGRect initialFrame =
    CGRectMake(0,
               0,
               view ? view.width - 2 * [self.class leftOrRightScreenMarign] : [self.class defaultViewWidth],
               [self.class defaultViewHeight]);
    
    switch (self.slipIntoDirection) {
        case TTWeakPushSlideDirectionFromTop: {
            initialFrame.origin.x = [self.class leftOrRightScreenMarign];
            initialFrame.origin.y = -([self.class topStatusBarHeight] + [self.class defaultViewHeight]);
        }
            break;
        case TTWeakPushSlideDirectionFromLeftTop: {
            initialFrame.origin.x = view ? -(CGRectGetWidth(view.frame)) : (-CGRectGetWidth([UIScreen mainScreen].bounds));
            initialFrame.origin.y = [self.class topStatusBarHeight];
        }
            break;
        case TTWeakPushSlideDirectionFromRightTop: {
            initialFrame.origin.x = view ? (CGRectGetWidth(view.frame)) : (CGRectGetWidth([UIScreen mainScreen].bounds));
            initialFrame.origin.y = [self.class topStatusBarHeight];
        }
            break;
        case TTWeakPushSlideDirectionFromBottom: {
            initialFrame.origin.x = [self.class leftOrRightScreenMarign];
            initialFrame.origin.y = view ? view.bottom : CGRectGetHeight([UIScreen mainScreen].bounds);
        }
            break;
        case TTWeakPushSlideDirectionFromLeftBottom: {
            initialFrame.origin.x = view ? -(CGRectGetWidth(view.frame)) : -(CGRectGetWidth([UIScreen mainScreen].bounds));
            initialFrame.origin.y = (view ? CGRectGetHeight(view.frame) : CGRectGetHeight([UIScreen mainScreen].bounds)) - ([self.class defaultViewHeight] + kTTWeakPushAlertViewToMarginBottom + [self iphoneXBottomOffset]);
        }
            break;
        case TTWeakPushSlideDirectionFromRightBottom: {
            initialFrame.origin.x = view ? (CGRectGetWidth(view.frame)) : (CGRectGetWidth([UIScreen mainScreen].bounds));
            initialFrame.origin.y = (view ? CGRectGetHeight(view.frame) : CGRectGetHeight([UIScreen mainScreen].bounds)) - ([self.class defaultViewHeight] + kTTWeakPushAlertViewToMarginBottom + [self iphoneXBottomOffset]);
        }
            break;
    }
    return initialFrame;
}

- (CGRect)endFrameDidShowAnimation
{
    CGRect endFrame = (self.superview ?
                       CGRectMake(0, 0, self.superview.width - 2 * [self.class leftOrRightScreenMarign], CGRectGetHeight(self.bounds)) :
                       CGRectMake(0, 0, MIN([self.class defaultViewWidth], CGRectGetWidth(self.bounds)), CGRectGetHeight(self.bounds)));
    
    switch (self.slipIntoDirection) {
        case TTWeakPushSlideDirectionFromTop:
        case TTWeakPushSlideDirectionFromLeftTop:
        case TTWeakPushSlideDirectionFromRightTop: {
            endFrame.origin.x = [self.class leftOrRightScreenMarign];
            endFrame.origin.y = [self.class topStatusBarHeight];
        }
            break;
        case TTWeakPushSlideDirectionFromBottom:
        case TTWeakPushSlideDirectionFromLeftBottom:
        case TTWeakPushSlideDirectionFromRightBottom: {
            endFrame.origin.x = [self.class leftOrRightScreenMarign];
            endFrame.origin.y = (self.superview ? CGRectGetHeight(self.superview.bounds) : CGRectGetHeight([[UIScreen mainScreen] bounds])) - ([self.class defaultViewHeight] + kTTWeakPushAlertViewToMarginBottom + [self iphoneXBottomOffset]);
            
        
        }
            break;
    }
    return endFrame;
}

- (CGRect)endFrameDidHideAnimation
{
    CGRect endFrame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    switch (self.slipIntoDirection) {
        case TTWeakPushSlideDirectionFromTop:
        case TTWeakPushSlideDirectionFromLeftTop:
        case TTWeakPushSlideDirectionFromRightTop: {
            endFrame.origin.x = [self.class leftOrRightScreenMarign];
            endFrame.origin.y = -(CGRectGetHeight(self.bounds));
        }
            break;
        case TTWeakPushSlideDirectionFromBottom:
        case TTWeakPushSlideDirectionFromLeftBottom:
        case TTWeakPushSlideDirectionFromRightBottom: {
            endFrame.origin.x = [self.class leftOrRightScreenMarign];
            endFrame.origin.y = self.superview ? CGRectGetHeight(self.superview.bounds) : CGRectGetHeight([UIScreen mainScreen].bounds);
        }
            break;
    }
    return endFrame;
}

+ (UIView *)findSuperViewInVisibleWindow
{
    return [UIApplication sharedApplication].delegate.window ? : [TTUIResponderHelper topmostView];
}


#pragma mark - show/hide

- (void)show
{
    [self showWithAnimated:YES completion:nil];
}

- (void)showWithAnimated:(BOOL)animated
              completion:(TTPushAlertVoidParamBlock)didCompletedHandler
{
    [self showInView:nil withAnimated:animated completion:didCompletedHandler];
}

- (void)showInView:(UIView *)superView
      withAnimated:(BOOL)animated
        completion:(TTPushAlertVoidParamBlock)didCompletedHandler
{
    if (self.superview) return;
    
    [self.class showMe];
    
    if (!superView) {
        superView = [self.class findSuperViewInVisibleWindow];
    }
    
    [superView addSubview:self];
    self.frame = [self initialFrameWillShowAnimationInSuperView:superView];
    
    if (animated) {
        NSTimeInterval duration = [TTInAppPushSettings weakAlertAnimationDuration];
        [UIView animateWithDuration:duration delay:0.5 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
            self.frame = [self endFrameDidShowAnimation];
        } completion:^(BOOL finished) {
            
            [self startTimer];
            
            if (didCompletedHandler) {
                didCompletedHandler();
            }
        }];
    } else {
        [self startTimer];
        
        self.frame = [self endFrameDidShowAnimation];
        
        if (didCompletedHandler) {
            didCompletedHandler();
        }
    }
}

- (void)hide
{
    [self hideWithAnimated:YES reason:TTWeakPushAlertHideTypeExternalCall];
}

- (void)hideWithAnimated:(BOOL)animated
{
    [self hideWithAnimated:animated reason:TTWeakPushAlertHideTypeExternalCall];
}

- (void)hideWithAnimated:(BOOL)animated
                  reason:(TTWeakPushAlertHideType)hideReason
{
    [self hideWithAnimated:animated reason:hideReason toFrame:[self endFrameDidHideAnimation]];
}

- (void)hideWithAnimated:(BOOL)animated
                  reason:(TTWeakPushAlertHideType)hideReason
                 toFrame:(CGRect)targetFrame
{
    [self.class hideMe];
    
    [self removeRotateObserver];
    
    if (_willHideHandler) {
        _willHideHandler(hideReason);
    }
    
    if (animated) {
        NSTimeInterval duration = 0.2;
        [UIView animateWithDuration:duration customTimingFunction:CustomTimingFunctionQuadraticEasyOut animation:^{
            self.frame = targetFrame;
        } completion:^(BOOL finished) {
            self.alpha = 0.f;
            [self removeFromSuperview];
            
            if (_didHideHandler) {
                _didHideHandler(hideReason);
            }
        }];
    } else {
        self.alpha = 0.f;
        [self removeFromSuperview];
        
        if (_didHideHandler) {
            _didHideHandler(hideReason);
        }
    }
}

#pragma mark - timer

- (void)startTimer
{
    [self stopTimer];
    
    _countdownTiming = 0;
    
    __weak typeof(self) weakSelf = self;
    _timer = [NSTimer tt_timerWithTimeInterval:1 repeats:YES block:^(NSTimer *timer) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.countdownTiming++;
        
        if (strongSelf.countdownTiming >= kTTAutoDismissDuration) {
            [strongSelf stopTimer];
            
            // 计时器完成时，仅仅没有移动时自动hide，当正在移动时等移动结束后hide
            if (TTPanGestureMoveDirectionNone == strongSelf.panBeginDirection) {
                [strongSelf hideWithAnimated:YES reason:TTWeakPushAlertHideTypeAutoDismiss];
            }
        }
    }];
    if (_timer) {
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - showing helper

static BOOL s_weakPushAlertShowing = NO;

+ (void)showMe
{
    s_weakPushAlertShowing = YES;
}

+ (void)hideMe
{
    s_weakPushAlertShowing = NO;
}

+ (BOOL)isShowing
{
    return s_weakPushAlertShowing;
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

- (SSThemedImageView *)attractedImageView
{
    if (!_attractedImageView) {
        _attractedImageView = [[SSThemedImageView alloc] init];
        _attractedImageView.contentMode = UIViewContentModeScaleAspectFill;
        _attractedImageView.enableNightCover = YES;
        _attractedImageView.clipsToBounds = YES;
    }
    return _attractedImageView;
}

- (SSThemedButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _closeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        _closeButton.clipsToBounds = YES;
        _closeButton.imageName = @"push_close_popups";
        [_closeButton addTarget:self
                         action:@selector(actionForDidTapCloseButton:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (SSThemedButton *)tappedEventButton
{
    if (!_tappedEventButton) {
        _tappedEventButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _tappedEventButton.frame = CGRectMake(0, 0, [self.class defaultViewWidth], [self.class defaultViewHeight]);
        [_tappedEventButton addTarget:self
                               action:@selector(actionForDidTapContentButton:)
                     forControlEvents:UIControlEventTouchUpInside];
    }
    return _tappedEventButton;
}


- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [SSThemedLabel new];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
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
        _detailLabel.adjustsFontSizeToFitWidth = [TTInAppPushSettings weakAlertAdjustsFontSizeToFitWidth];
        _detailLabel.minimumScaleFactor = 0.8;
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:15.f]];
        _detailLabel.textColorThemeKey = kColorText1;
    }
    return _detailLabel;
}

- (UIPanGestureRecognizer *)dragViewPanGR
{
    if (!_dragViewPanGR) {
        _dragViewPanGR = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(handlePanGestureRecognizer:)];
    }
    return _dragViewPanGR;
}

#pragma mark - class methods

+ (CGFloat)defaultViewHeight
{
    return MAX(148.f/2, [TTDeviceUIUtils tt_padding:148.f/2]);
}

+ (CGFloat)defaultViewWidth
{
    return (CGRectGetWidth([UIScreen mainScreen].bounds) - 2 * [self.class leftOrRightScreenMarign]);
}

+ (CGFloat)topStatusBarHeight
{
    return MAX(20, [UIApplication sharedApplication].statusBarFrame.size.height);
}

+ (CGFloat)leftOrRightScreenMarign
{
    return 16.f/2;
}

@end

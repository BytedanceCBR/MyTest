//
//  TTAccountIndicatorView.m
//  TTAccountSDK
//
//  Created by 冯靖君 on 16/1/26.
//
//

#import "TTAccountIndicatorView.h"
#import "TTAccountMacros.h"



static NSInteger const kTTAIndicatorTextLabelMaxLineNumber = 2;
static CGFloat   const kTTATopPadding = 20.f;
static CGFloat   const kTTABottomPadding = 20.f;
static CGFloat   const kTTAItemSpacing = 10.f;
static CGFloat   const kTTAHoriSpacing = 20.f;
static CGFloat   const kTTADismissButtonPadding = 10.f;

static CGFloat   const kTTAIndicatorMaxWidth = 160.f;

static CGFloat   const kTTADisplayDuration = 1.f;
static CGFloat   const kTTAShowAnimationDuration = 0.5f;
static CGFloat   const kTTAHideAnimationDuration = 0.5f;

static CGFloat   const kTTAIndicatorTextFontSize = 17.f;



/**
 *  动画显示转菊花，用在loadMore和TTIndicator的waitingStyle场景
 */
@interface __TTAccountWaitingView__ : UIView
@property(nonatomic, assign) BOOL animating;
@property(nonatomic, strong) UIImageView *imageView;

/** start animating */
- (void)startAnimating;

/** end animating */
- (void)stopAnimating;
@end

static CGFloat const kTTAWaitingItemSize = 24.f;

@implementation __TTAccountWaitingView__

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self buildImageView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self buildImageView];
    }
    return self;
}

- (void)buildImageView
{
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.tta_imageName = @"tta_refreshicon_loading";
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
    [self sizeToFit];
}

- (void)startAnimating
{
    [self.imageView.layer removeAllAnimations];
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.duration    = 1.0f;
    rotateAnimation.repeatCount = HUGE_VAL;
    rotateAnimation.toValue     = @(M_PI * 2);
    [self.imageView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    
    self.animating = YES;
    self.hidden    = NO;
}

- (void)stopAnimating
{
    [self.imageView.layer removeAllAnimations];
    
    self.animating = NO;
    self.hidden    = YES;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow) {
        if (self.animating) {
            [self startAnimating];
        }
    } else {
        [self stopAnimating];
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(kTTAWaitingItemSize, kTTAWaitingItemSize);
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(kTTAWaitingItemSize, kTTAWaitingItemSize);
}

@end



@interface __TTAIndicatorContentView__ : UIView

@end

@implementation __TTAIndicatorContentView__

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor     = [UIColor colorWithWhite:0 alpha:0.8];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius  = 5.f;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    __block CGFloat contentWidth  = 0;
    __block CGFloat contentHeight = kTTATopPadding + kTTABottomPadding;
    __block NSInteger unHiddenSubViewCount = 0;
    for (UIView *subView in self.subviews) {
        if (!subView.hidden && ![subView isKindOfClass:[UIButton class]]) {
            contentWidth   = MAX(CGRectGetWidth(subView.frame), contentWidth);
            contentHeight += CGRectGetHeight(subView.frame);
            unHiddenSubViewCount++;
        }
    }
    
    contentWidth += kTTAHoriSpacing * 2;
    if (unHiddenSubViewCount > 1) {
        contentHeight += (unHiddenSubViewCount - 1) * kTTAItemSpacing;
    }
    return CGSizeMake(contentWidth, contentHeight);
}

@end



@interface TTAccountIndicatorView ()
@property(nonatomic, assign) TTAccountIndicatorViewStyle indicatorStyle;
@property(nonatomic, assign) BOOL isUserDismiss;

// UI
@property(nonatomic, strong) UIView *parentView;
@property(nonatomic, strong) UILabel *indicatorTextLabel;
@property(nonatomic, strong) UIImageView *indicatorImageView;
@property(nonatomic, strong) UIButton *dismissButton;
@property(nonatomic, strong) __TTAccountWaitingView__ *indicatorWaitingView;
@property(nonatomic, strong) __TTAIndicatorContentView__ *contentView;

@property(nonatomic,   copy) NSString *indicatorText;
@property(nonatomic, strong) UIImage  *indicatorImage;

@property(nonatomic,   copy) TTAccountIndicatorViewDidDismissBlock dismissHandler;
@end

@implementation TTAccountIndicatorView

#pragma mark - Init

- (instancetype)initWithIndicatorStyle:(TTAccountIndicatorViewStyle)style
                         indicatorText:(NSString *)indicatorText
                        indicatorImage:(UIImage *)indicatorImage
                        dismissHandler:(TTAccountIndicatorViewDidDismissBlock)handler
{
    if ((self = [super initWithFrame:CGRectZero])) {
        _indicatorStyle     = style;
        _indicatorText      = indicatorText;
        _indicatorImage     = indicatorImage;
        _showDismissButton  = NO;
        _autoDismiss        = YES;
        _dismissHandler     = handler;
        
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithIndicatorStyle:kTTAccountIndicatorViewStyleImage
                          indicatorText:nil
                         indicatorImage:nil
                         dismissHandler:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithIndicatorStyle:kTTAccountIndicatorViewStyleImage
                          indicatorText:nil
                         indicatorImage:nil
                         dismissHandler:nil];
}

- (void)initSubViews
{
    _contentView = [[__TTAIndicatorContentView__ alloc] init];
    [self addSubview:_contentView];
    
    _indicatorImageView = [UIImageView new];
    _indicatorImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_contentView addSubview:_indicatorImageView];
    if (_indicatorImage) {
        [self _layoutIndicatorImageViewWithImage:_indicatorImage];
    }
    
    _indicatorTextLabel = [UILabel new];
    _indicatorTextLabel.backgroundColor = [UIColor clearColor];
    _indicatorTextLabel.textColor = TTAccountUIColorFromHexRGB(0xffffff);
    _indicatorTextLabel.font = [UIFont systemFontOfSize:kTTAIndicatorTextFontSize];
    _indicatorTextLabel.textAlignment = NSTextAlignmentCenter;
    _indicatorTextLabel.numberOfLines = kTTAIndicatorTextLabelMaxLineNumber;
    _indicatorTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_contentView addSubview:_indicatorTextLabel];
    if (!TTAccountIsEmptyString(_indicatorText)) {
        [self _layoutIndicatorLabelWithText:_indicatorText];
    }
    
    _indicatorWaitingView = [__TTAccountWaitingView__ new];
    _indicatorWaitingView.imageView.tta_imageName = @"tta_loading";
    if ([self _needShowWaitingView]) {
        [_contentView addSubview:_indicatorWaitingView];
    }
    
    _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _dismissButton.frame = CGRectMake(0, 0, 8, 8);
    _dismissButton.tta_imageName   = @"tta_close_move_details";
    _dismissButton.tta_hlImageName = @"tta_close_move_details_press";
    _dismissButton.hidden = YES; /** 默认隐藏 */
    [_dismissButton addTarget:self
                       action:@selector(dismissByUser)
             forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:self.dismissButton];
    
    if (TTACCOUNT_IS_IPAD) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarOrientationDidChange)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)statusBarOrientationDidChange
{
    [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    _indicatorImageView.hidden      = !_indicatorImage || [self _needShowWaitingView];
    _indicatorTextLabel.hidden      = TTAccountIsEmptyString(_indicatorText);
    _indicatorWaitingView.hidden    = ![self _needShowWaitingView];
    _dismissButton.hidden = !_showDismissButton;
    
    [_contentView sizeToFit];
    _contentView.center = CGPointMake(CGRectGetWidth(_parentView.frame) / 2,
                                      CGRectGetHeight(_parentView.frame) / 2);
    
    if (!_indicatorImageView.hidden) {
        _indicatorImageView.frame = CGRectMake((CGRectGetWidth(_contentView.frame) -CGRectGetWidth(_indicatorImageView.frame))/2,
                                               kTTATopPadding,
                                               CGRectGetWidth(_indicatorImageView.frame),
                                               CGRectGetHeight(_indicatorImageView.frame));
        
        if (!_indicatorTextLabel.hidden) {
            _indicatorTextLabel.frame = CGRectMake((CGRectGetWidth(_contentView.frame) -CGRectGetWidth(_indicatorTextLabel.frame))/2,
                                                   CGRectGetMaxY(_indicatorImageView.frame) + kTTAItemSpacing,
                                                   CGRectGetWidth(_indicatorTextLabel.frame),
                                                   CGRectGetHeight(_indicatorTextLabel.frame));
        }
    }
    else {
        CGFloat contentBaseLine = kTTATopPadding;
        if (!_indicatorWaitingView.hidden) {
            _indicatorWaitingView.frame = CGRectMake((CGRectGetWidth(_contentView.frame) -CGRectGetWidth(_indicatorWaitingView.frame))/2,
                                                     kTTATopPadding,
                                                     CGRectGetWidth(_indicatorWaitingView.frame),
                                                     CGRectGetHeight(_indicatorWaitingView.frame));
            
            contentBaseLine = CGRectGetMaxY(_indicatorWaitingView.frame) + kTTAItemSpacing;
        }
        
        if (!_indicatorTextLabel.hidden) {
            _indicatorTextLabel.frame = CGRectMake((CGRectGetWidth(_contentView.frame) -CGRectGetWidth(_indicatorTextLabel.frame))/2,
                                                   contentBaseLine,
                                                   CGRectGetWidth(_indicatorTextLabel.frame),
                                                   CGRectGetHeight(_indicatorTextLabel.frame));
            
            contentBaseLine = CGRectGetMaxY(_indicatorTextLabel.frame) + kTTAItemSpacing;
        }
    }
    
    if (!_dismissButton.hidden) {
        _dismissButton.frame = CGRectMake(CGRectGetWidth(_contentView.frame) - kTTADismissButtonPadding - CGRectGetWidth(_dismissButton.frame),
                                          kTTADismissButtonPadding,
                                          CGRectGetWidth(_dismissButton.frame),
                                          CGRectGetHeight(_dismissButton.frame));
    }
    
    [self makeRotationTransformOnIOS7];
    [self layoutContentSubViewsOnIOS7];
}

- (void)makeRotationTransformOnIOS7
{
    if (TTACCOUNT_DEVICE_SYS_VERSION < 8.f) {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                _contentView.transform = CGAffineTransformIdentity;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                _contentView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                break;
            case UIInterfaceOrientationLandscapeRight:
                _contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
                break;
            default:
                break;
        }
    }
}

- (void)layoutContentSubViewsOnIOS7
{
    if (TTACCOUNT_DEVICE_SYS_VERSION < 8.f &&
        UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        _indicatorImageView.center   = (CGPoint){CGRectGetHeight(_contentView.frame) / 2, _indicatorImageView.center.y};
        _indicatorTextLabel.center   = (CGPoint){CGRectGetHeight(_contentView.frame) / 2, _indicatorTextLabel.center.y};
        _indicatorWaitingView.center = (CGPoint){CGRectGetHeight(_contentView.frame) / 2, _indicatorWaitingView.center.y};
    }
}


#pragma mark - Show

- (void)showFromParentView:(UIView *)parentView
{
    if (!parentView) {
        parentView = [self.class indicatorWindow];
    }
    
    _parentView = parentView;
    [self _dismissAllCurrentIndicators];
    
    _parentView.hidden = NO;
    [_parentView addSubview:self];
    self.frame = (CGRect){(CGPoint)self.frame.origin, (CGSize)parentView.frame.size};
    self.userInteractionEnabled = _showDismissButton;
    
    self.alpha = 0.f;
    _indicatorImageView.alpha = 0.f;
    _indicatorTextLabel.alpha = 0.f;
    _indicatorImageView.transform = CGAffineTransformMakeScale(0.f, 0.f);
    if ([self _needShowWaitingView]) {
        [_indicatorWaitingView startAnimating];
    }
    [UIView animateWithDuration:kTTAShowAnimationDuration delay:0.f usingSpringWithDamping:0.8f initialSpringVelocity:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        if (_autoDismiss) {
            [self performSelector:@selector(dismissFromParentView) withObject:nil afterDelay:kTTADisplayDuration];
        }
    }];
    [UIView animateWithDuration:kTTAShowAnimationDuration-0.1 delay:0.1f usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _indicatorImageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        _indicatorImageView.alpha = 1.f;
        _indicatorTextLabel.alpha = 1.f;
    } completion:^(BOOL finished) {
    }];
}

+ (UIWindow *)indicatorWindow
{
    static UIWindow *mainWindow = nil;
    if (!mainWindow) {
        mainWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                [UIScreen mainScreen].bounds.size.width,
                                                                [UIScreen mainScreen].bounds.size.height)];
        mainWindow.windowLevel = UIWindowLevelStatusBar + 5;
        mainWindow.userInteractionEnabled = NO;
    }
    return mainWindow;
}

+ (void)showWithIndicatorStyle:(TTAccountIndicatorViewStyle)style
                 indicatorText:(NSString *)indicatorText
                indicatorImage:(UIImage *)indicatorImage
                   autoDismiss:(BOOL)autoDismiss
                dismissHandler:(TTAccountIndicatorViewDidDismissBlock)handler
{
    TTAccountIndicatorView *indicatorView = [[TTAccountIndicatorView alloc] initWithIndicatorStyle:style
                                                                                     indicatorText:indicatorText
                                                                                    indicatorImage:indicatorImage
                                                                                    dismissHandler:handler];
    indicatorView.autoDismiss = autoDismiss;
    [indicatorView showFromParentView:[self indicatorWindow]];
}


#pragma mark - Dismiss

- (void)dismissByUser
{
    _isUserDismiss = YES;
    
    [self dismissFromParentView];
}

- (void)dismissFromParentView
{
    [self _dismissFromParentViewAnimated:YES];
}

- (void)_dismissFromParentViewAnimated:(BOOL)animated
{
    void (^completion)(BOOL finished) = ^(BOOL finished) {
        self.alpha = 0.f;
        self.indicatorText = nil;
        self.indicatorImage = nil;
        if ([self _needShowWaitingView]) {
            [_indicatorWaitingView stopAnimating];
        }
        [self removeFromSuperview];
        
        UIWindow *indicatorWindow = [TTAccountIndicatorView indicatorWindow];
        if (!indicatorWindow.subviews.count){
            indicatorWindow.hidden = YES;
        }
        _parentView = nil;
        
        if (_dismissHandler) {
            _dismissHandler(self, _isUserDismiss);
            self.isUserDismiss = NO;
        }
    };
    
    if (animated) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:kTTAHideAnimationDuration animations:^{
                self.alpha = 0.f;
            } completion:^(BOOL finished){
                completion(finished);
            }];
        });
    } else {
        completion(YES);
    }
}

- (void)_dismissAllCurrentIndicators
{
    [self _dismissAllCurrentIndicatorsOnParentView:_parentView animated:NO];
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        [self _dismissAllCurrentIndicatorsOnParentView:window animated:NO];
    }
}

- (void)_dismissAllCurrentIndicatorsOnParentView:(UIView *)parentView animated:(BOOL)animated
{
    for (UIView *subView in parentView.subviews) {
        if ([subView isKindOfClass:[TTAccountIndicatorView class]]) {
            [((TTAccountIndicatorView *)subView) _dismissFromParentViewAnimated:animated];
        }
    }
}

+ (void)dismissIndicators
{
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        for (UIView *subView in window.subviews) {
            if ([subView isKindOfClass:[TTAccountIndicatorView class]]) {
                [((TTAccountIndicatorView *)subView) _dismissFromParentViewAnimated:YES];
            }
        }
    }
}


#pragma mark - Setter

- (void)setShowDismissButton:(BOOL)showDismissButton
{
    _showDismissButton = showDismissButton;
    
    self.userInteractionEnabled = _showDismissButton;
    [self setNeedsLayout];
}


#pragma mark - Update

- (void)updateIndicatorWithText:(nullable NSString *)newIndicatorText
        shouldRemoveWaitingView:(BOOL)removed
{
    if (removed) {
        /** 只是改变style，让waitingView隐藏 */
        _indicatorStyle = kTTAccountIndicatorViewStyleImage;
    }
    
    [self _layoutIndicatorLabelWithText:newIndicatorText];
    [self setNeedsLayout];
}

- (void)updateIndicatorWithImage:(UIImage *)updateIndicatorImage
{
    _indicatorStyle = kTTAccountIndicatorViewStyleImage;
    
    [self _layoutIndicatorImageViewWithImage:updateIndicatorImage];
    [self setNeedsLayout];
}


#pragma mark - Private

- (BOOL)_needShowWaitingView
{
    return _indicatorStyle == kTTAccountIndicatorViewStyleWaitingView;
}

- (void)_layoutIndicatorLabelWithText:(NSString *)text
{
    _indicatorText = text;
    
    _indicatorTextLabel.text = _indicatorText;
    //singleLine size
    CGSize labelSize = [_indicatorText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kTTAIndicatorTextFontSize]}];
    if (labelSize.width > kTTAIndicatorMaxWidth) {
        labelSize.width = kTTAIndicatorMaxWidth;
        labelSize.height = [self.class tta_sizeOfText:text
                                             fontSize:kTTAIndicatorTextFontSize
                                             forWidth:kTTAIndicatorMaxWidth
                                        forLineHeight:_indicatorTextLabel.font.lineHeight
                         constraintToMaxNumberOfLines:kTTAIndicatorTextLabelMaxLineNumber firstLineIndent:0 textAlignment:NSTextAlignmentCenter].height;
    }
    _indicatorTextLabel.frame = (CGRect){0, 0, (CGSize)labelSize};
}

- (void)_layoutIndicatorImageViewWithImage:(UIImage *)image
{
    _indicatorImage = image;
    
    [_indicatorImageView setImage:image];
    _indicatorImageView.frame = (CGRect){0, 0, (CGSize)image.size};
}


#pragma mark - helper

+ (CGSize)tta_sizeOfText:(NSString *)text
                fontSize:(CGFloat)fontSize
                forWidth:(CGFloat)width
           forLineHeight:(CGFloat)lineHeight
constraintToMaxNumberOfLines:(NSInteger)numberOfLines
         firstLineIndent:(CGFloat)indent
           textAlignment:(NSTextAlignment)alignment
{
    CGSize size = CGSizeZero;
    if ([text length] > 0) {
        UIFont *font = [UIFont systemFontOfSize:fontSize];
        CGFloat constraintHeight   = numberOfLines ? numberOfLines * (lineHeight + 1) : 9999.f;
        CGFloat lineHeightMultiple = lineHeight / font.lineHeight;
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment     = alignment;
        style.lineHeightMultiple  = lineHeightMultiple;
        style.minimumLineHeight   = font.lineHeight * lineHeightMultiple;
        style.maximumLineHeight   = font.lineHeight * lineHeightMultiple;
        style.firstLineHeadIndent = indent;
        
        size = [text boundingRectWithSize:CGSizeMake(width, constraintHeight)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:font,
                                            NSParagraphStyleAttributeName:style
                                            }
                                  context:nil].size;
    }
    return size;
}

@end

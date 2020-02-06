//
//  TTIndicatorView.m
//  Article
//
//  Created by 冯靖君 on 16/1/26.
//
//

#import "TTIndicatorView.h"
#import "TTWaitingView.h"
#import <TTThemed/SSThemed.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTLabelTextHelper.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/UIButton+TTAdditions.h>


static NSInteger const indicatorTextLabelMaxLineNumber = 2;
static CGFloat const topPadding = 20.f;
static CGFloat const bottomPadding = 20.f;
static CGFloat const itemSpacing = 10.f;
static CGFloat const horiSpacing = 20.f;
static CGFloat const dismissButtonPadding = 10.f;

static CGFloat const indicatorMaxWidth = 160.f;

static CGFloat const defaultDisplayDuration = 1.f;
static CGFloat const showAnimationDuration = 0.5f;
static CGFloat const hideAnimationDuration = 0.5f;
static CGFloat const defaultDismissDelay = 0.5f;

static CGFloat const indicatorTextFontSize = 17.f;

@interface TTIndicatorContentView : UIView
@end

@implementation TTIndicatorContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5.f;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    __block CGFloat contentWidth = 0;
    __block CGFloat contentHeight = topPadding + bottomPadding;
    __block NSInteger unHiddenSubViewCount = 0;
    for (UIView * subView in self.subviews) {
        if (Shown(subView) && ![subView isKindOfClass:[SSThemedButton class]]) {
            contentWidth = MAX(subView.width, contentWidth);
            contentHeight += subView.height;
            unHiddenSubViewCount++;
        }
    }
    contentWidth += horiSpacing*2;
    if (unHiddenSubViewCount > 1) {
        contentHeight += (unHiddenSubViewCount - 1) * itemSpacing;
    }
    return CGSizeMake(contentWidth, contentHeight);
}

@end

@interface TTIndicatorView ()

@property(nonatomic, assign) TTIndicatorViewStyle indicatorStyle;

@property(nonatomic, strong) SSThemedLabel *indicatorTextLabel;
@property(nonatomic, strong) SSThemedImageView *indicatorImageView;
@property(nonatomic, strong) TTWaitingView *indicatorWaitingView;
@property(nonatomic, strong) SSThemedButton *dismissButton;
@property(nonatomic, strong) TTIndicatorContentView *contentView;
@property(nonatomic, weak) UIView *parentView;

@property(nonatomic, copy) NSString *indicatorText;
@property(nonatomic, copy) UIImage *indicatorImage;

@property(nonatomic, copy) DismissHandler dismissHandler;
@property(nonatomic, assign) BOOL isUserDismiss;
@property(nonatomic, assign) NSInteger supportMaxLine;
@property (nonatomic) CGFloat expectedWidth;


@end

@implementation TTIndicatorView

#pragma mark - Initialization

- (instancetype)initWithIndicatorStyle:(TTIndicatorViewStyle)style
                         indicatorText:(NSString *)indicatorText
                        indicatorImage:(UIImage *)indicatorImage
                        dismissHandler:(DismissHandler)handler
{
    return [self initWithIndicatorStyle:style
                          indicatorText:indicatorText
                         indicatorImage:indicatorImage
                                maxLine:indicatorTextLabelMaxLineNumber
                         dismissHandler:handler];
}

- (nonnull instancetype)initWithIndicatorStyle:(TTIndicatorViewStyle)style
                                 indicatorText:(NSString *)indicatorText
                                indicatorImage:(UIImage *)indicatorImage
                                       maxLine:(NSInteger)maxLine
                                dismissHandler:(DismissHandler)handler {
    return [self initWithIndicatorStyle:style
                          indicatorText:indicatorText
                         indicatorImage:indicatorImage
                                maxLine:maxLine
                          expectedWidth:-1
                         dismissHandler:handler];
}

- (instancetype)initWithIndicatorStyle:(TTIndicatorViewStyle)style
                         indicatorText:(NSString *)indicatorText
                        indicatorImage:(UIImage *)indicatorImage
                               maxLine:(NSInteger)maxLine
                         expectedWidth:(CGFloat)expectedWidth
                        dismissHandler:(DismissHandler)handler
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _indicatorStyle = style;
        _indicatorText = indicatorText;
        _indicatorImage = indicatorImage;
        _showDismissButton = NO;
        _autoDismiss = YES;
        _dismissHandler = handler;
        _supportMaxLine = maxLine;
        _dismissDelay = defaultDismissDelay;
        _expectedWidth = expectedWidth;
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:nil indicatorImage:nil dismissHandler:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:nil indicatorImage:nil dismissHandler:nil];
}

- (void)initSubViews
{
    _contentView = [[TTIndicatorContentView alloc] init];
    [self addSubview:_contentView];
    
    _indicatorImageView = [SSThemedImageView new];
    _indicatorImageView.contentMode = UIViewContentModeScaleAspectFill;
    if (_indicatorImage) {
        [self _layoutIndicatorImageViewWithImage:_indicatorImage];
    }
    [_contentView addSubview:_indicatorImageView];
    
    _indicatorTextLabel = [SSThemedLabel new];
    _indicatorTextLabel.backgroundColor = [UIColor clearColor];
    _indicatorTextLabel.textColorThemeKey = kColorText8;
    _indicatorTextLabel.font = [UIFont systemFontOfSize:indicatorTextFontSize];
    _indicatorTextLabel.textAlignment = NSTextAlignmentCenter;
    _indicatorTextLabel.numberOfLines = _supportMaxLine;
    _indicatorTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    if (!isEmptyString(_indicatorText)) {
        [self _layoutIndicatorLabelWithText:_indicatorText];
    }
    [_contentView addSubview:_indicatorTextLabel];
    
    _indicatorWaitingView = [TTWaitingView new];
    _indicatorWaitingView.imageView.imageName = @"loading";
    if ([self _needShowWaitingView]) {
        [_contentView addSubview:_indicatorWaitingView];
    }
    
    _dismissButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    _dismissButton.size = CGSizeMake(8, 8);
    _dismissButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    _dismissButton.imageName = @"close_move_details";
    /**
     *  默认隐藏
     */
    _dismissButton.hidden = YES;
    [_dismissButton addTarget:self
                       action:@selector(dismissByUser)
             forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:self.dismissButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeStatusBarOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)p_needTransform {
    UIInterfaceOrientation ori = [UIApplication sharedApplication].statusBarOrientation;
    if ((_parentView.width > _parentView.height && UIInterfaceOrientationIsPortrait(ori)) || (_parentView.width < _parentView.height && UIInterfaceOrientationIsLandscape(ori))) {
        return YES;
    } else {
        return NO;
    }
}

- (void)observeStatusBarOrientationChanged:(NSNotification *)aNotification
{
    [self setNeedsLayout];
    
    NSNumber *orientationNumber = aNotification.userInfo[UIApplicationStatusBarOrientationUserInfoKey];
    UIInterfaceOrientation orientation = orientationNumber.integerValue;
    [self rotateContentForInterfaceOrientation:orientation];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    _indicatorImageView.hidden = !_indicatorImage || [self _needShowWaitingView];
    _indicatorTextLabel.hidden = isEmptyString(_indicatorText);
    _indicatorWaitingView.hidden = ![self _needShowWaitingView];
    _dismissButton.hidden = !_showDismissButton;
    [_contentView sizeToFit];
    _contentView.center = CGPointMake(_parentView.width/2, _parentView.height/2);
    if (Shown(_indicatorImageView)) {
        _indicatorImageView.centerX = _contentView.bounds.size.width/2;
        _indicatorImageView.top = topPadding;
        if (Shown(_indicatorTextLabel)) {
            _indicatorTextLabel.centerX = _contentView.bounds.size.width/2;
            _indicatorTextLabel.top = _indicatorImageView.bottom + itemSpacing;
        }
    }
    else {
        CGFloat contentBaseLine = topPadding;
        if (Shown(_indicatorWaitingView)) {
            _indicatorWaitingView.centerX = _contentView.bounds.size.width/2;
            _indicatorWaitingView.top = topPadding;
            contentBaseLine = _indicatorWaitingView.bottom + itemSpacing;
        }
        if (Shown(_indicatorTextLabel)) {
            _indicatorTextLabel.centerX = _contentView.bounds.size.width/2;
            _indicatorTextLabel.top = contentBaseLine;
            contentBaseLine = _indicatorTextLabel.bottom + itemSpacing;
        }
    }
    
    if (Shown(_dismissButton)) {
        _dismissButton.origin = CGPointMake(_contentView.width - dismissButtonPadding - _dismissButton.width, dismissButtonPadding);
    }
    
    [self makeRotationTransformOnIOS7];
    [self layoutContentSubViewsOnIOS7];
}

- (void)makeRotationTransformOnIOS7
{
    if ([TTDeviceHelper OSVersionNumber] < 8.f && [self p_needTransform]) {
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
    if ([TTDeviceHelper OSVersionNumber] < 8.f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        _indicatorImageView.centerX = _contentView.height/2;
        _indicatorTextLabel.centerX = _contentView.height/2;
        _indicatorWaitingView.centerX = _contentView.height/2;
    }
}

- (void)rotateContentForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _contentView.transform = CGAffineTransformIdentity;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            _contentView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIInterfaceOrientationLandscapeRight:
            _contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
    }
}

#pragma mark - Show

- (void)showFromParentView:(UIView *)parentView
{
    [self showFromParentView:parentView offset:UIOffsetMake(0, 0)];
}

- (void)showFromParentView:(UIView *)parentView offset:(UIOffset)offset
{
    if (!parentView) {
        parentView = [self.class _defaultParentView];
    }
    
    _parentView = parentView;
    [self _dismissAllCurrentIndicators];
    [_parentView addSubview:self];
    self.size = CGSizeMake(parentView.width, parentView.height);
    self.center = CGPointMake(parentView.centerX + offset.horizontal, parentView.centerY + offset.vertical);
    self.userInteractionEnabled = _showDismissButton;
    
    self.alpha = 0.f;
    if ([self p_needTransform]) {
        [self rotateContentForInterfaceOrientation:UIApplication.sharedApplication.statusBarOrientation];
    }
    _indicatorImageView.alpha = 0.f;
    _indicatorTextLabel.alpha = 0.f;
    _indicatorImageView.transform = CGAffineTransformMakeScale(0.f, 0.f);
    if ([self _needShowWaitingView]) {
        [_indicatorWaitingView startAnimating];
    }
    [UIView animateWithDuration:showAnimationDuration delay:0.f usingSpringWithDamping:0.8f initialSpringVelocity:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        if (_autoDismiss) {
            [self performSelector:@selector(dismissFromParentView) withObject:nil afterDelay:self.duration > 0? self.duration: defaultDisplayDuration];
        }
    }];
    [UIView animateWithDuration:showAnimationDuration-0.1 delay:0.1f usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _indicatorImageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        _indicatorImageView.alpha = 1.f;
        _indicatorTextLabel.alpha = 1.f;
    } completion:^(BOOL finished) {
    }];
}

+ (void)showWithIndicatorStyle:(TTIndicatorViewStyle)style
                 indicatorText:(NSString *)indicatorText
                indicatorImage:(UIImage *)indicatorImage
                   autoDismiss:(BOOL)autoDismiss
                dismissHandler:(DismissHandler)handler
{
    return [self showWithIndicatorStyle:style
                          indicatorText:indicatorText
                         indicatorImage:indicatorImage
                                maxLine:indicatorTextLabelMaxLineNumber
                          expectedWidth:-1
                            autoDismiss:autoDismiss
                         dismissHandler:handler];
}

+ (void)showWithIndicatorStyle:(TTIndicatorViewStyle)style
                 indicatorText:(nullable NSString *)indicatorText
                indicatorImage:(nullable UIImage *)indicatorImage
                       maxLine:(NSInteger)maxLine
                   autoDismiss:(BOOL)autoDismiss
                dismissHandler:(nullable DismissHandler)handler
{
    TTIndicatorView *indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:style indicatorText:indicatorText indicatorImage:indicatorImage maxLine:maxLine expectedWidth:-1 dismissHandler:handler];
    indicatorView.autoDismiss = autoDismiss;
    [indicatorView showFromParentView:[self.class _defaultParentView]];
}

+ (void)showWithIndicatorStyle:(TTIndicatorViewStyle)style
                 indicatorText:(nullable NSString *)indicatorText
                indicatorImage:(nullable UIImage *)indicatorImage
                       maxLine:(NSInteger)maxLine
                 expectedWidth:(CGFloat)expectedWidth
                   autoDismiss:(BOOL)autoDismiss
                dismissHandler:(nullable DismissHandler)handler {
    TTIndicatorView *indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:style indicatorText:indicatorText indicatorImage:indicatorImage maxLine:maxLine expectedWidth:expectedWidth dismissHandler:handler];
    indicatorView.autoDismiss = autoDismiss;
    [indicatorView showFromParentView:[self.class _defaultParentView]];
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
        _parentView = nil;
        if (_dismissHandler) {
            _dismissHandler(_isUserDismiss);
            self.isUserDismiss = NO;
        }
    };
    if (animated) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.dismissDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:hideAnimationDuration
                             animations:^{
                                 self.alpha = 0.f;
                             }
                             completion:^(BOOL finished){
                                 completion(finished);
                             }];
        });
    }
    else {
        completion(YES);
    }
}

- (void)_dismissAllCurrentIndicators
{
    [self _dismissAllCurrentIndicatorsOnParentView:_parentView animated:NO];
    for (UIWindow * window in [UIApplication sharedApplication].windows) {
        [self _dismissAllCurrentIndicatorsOnParentView:window animated:NO];
    }
}

- (void)_dismissAllCurrentIndicatorsOnParentView:(UIView *)parentView animated:(BOOL)animated
{
    for (UIView * subView in parentView.subviews) {
        if ([subView isKindOfClass:[TTIndicatorView class]]) {
            [((TTIndicatorView *)subView) _dismissFromParentViewAnimated:animated];
        }
    }
}

+ (void)dismissIndicators
{
    for (UIWindow * window in [UIApplication sharedApplication].windows) {
        for (UIView * subView in window.subviews) {
            if ([subView isKindOfClass:[TTIndicatorView class]]) {
                [((TTIndicatorView *)subView) _dismissFromParentViewAnimated:YES];
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

- (void)setDismissDelay:(NSTimeInterval)dissmissDelay
{
    dissmissDelay = MAX(0, dissmissDelay);
    
    _dismissDelay = dissmissDelay;
}

#pragma mark - Update
- (void)updateIndicatorWithText:(NSString *)updateIndicatorText
        shouldRemoveWaitingView:(BOOL)shouldRemoveWaitingView
{
    if (shouldRemoveWaitingView) {
        /**
         *  只是改变style，让waitingView隐藏
         */
        _indicatorStyle = TTIndicatorViewStyleImage;
    }
    [self _layoutIndicatorLabelWithText:updateIndicatorText];
    [self setNeedsLayout];
}

- (void)updateIndicatorWithImage:(UIImage *)updateIndicatorImage
{
    _indicatorStyle = TTIndicatorViewStyleImage;
    [self _layoutIndicatorImageViewWithImage:updateIndicatorImage];
    [self setNeedsLayout];
}

#pragma mark - Private

+ (UIView *)_defaultParentView
{
    if ([[UIApplication sharedApplication] keyWindow]) {
        return [[UIApplication sharedApplication] keyWindow];
    }
    
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
        return [[[UIApplication sharedApplication] delegate] window];
    }    
    return nil;
}

- (BOOL)_needShowWaitingView
{
    return _indicatorStyle == TTIndicatorViewStyleWaitingView;
}

- (void)_layoutIndicatorLabelWithText:(NSString *)text
{
    _indicatorText = text;
    _indicatorTextLabel.text = _indicatorText;
    //singleLine size
    CGSize labelSize = [_indicatorText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:indicatorTextFontSize]}];
    if (labelSize.width > self.indicatorMaxWidth) {
        labelSize.width = self.indicatorMaxWidth;
        labelSize.height = [TTLabelTextHelper heightOfText:text fontSize:indicatorTextFontSize forWidth:self.indicatorMaxWidth forLineHeight:[UIFont systemFontOfSize:indicatorTextFontSize].lineHeight constraintToMaxNumberOfLines:_supportMaxLine firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
    }
    _indicatorTextLabel.size = labelSize;
}

- (void)_layoutIndicatorImageViewWithImage:(UIImage *)image
{
    _indicatorImage = image;
    [_indicatorImageView setImage:image];
    _indicatorImageView.size = image.size;
}

+ (void)showIndicatorForFollowMessage:(NSString *)msg {
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:[UIImage imageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
}

- (CGFloat)indicatorMaxWidth {
    if (self.expectedWidth <= 0 || self.expectedWidth >= UIScreen.mainScreen.bounds.size.width) {
        return indicatorMaxWidth;
    } else {
        return self.expectedWidth;
    }
}

@end

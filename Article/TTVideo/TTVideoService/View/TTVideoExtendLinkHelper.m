//
//  TTVideoExtendLinkView.m
//  Article
//
//  Created by panxiang on 16/9/19.
//
//

#import "TTVideoExtendLinkHelper.h"
#import "SSWebViewController.h"
#import "TTRoute.h"
#import "TTUIResponderHelper.h"
#import "TTNavigationController.h"
#import "NSObject+FBKVOController.h"
#import "TTSettingsManager.h"
#import "UIViewAdditions.h"

@interface TTVideoLinkViewTopBar : SSThemedView
{
    SSThemedLabel *_titleLabel;
    SSThemedView *_bottomLine;
    
}
@property (nonatomic, copy, readwrite)NSString *title;
@property (nonatomic, copy, readwrite)TTAlphaThemedButton *backButton;
@property (nonatomic, copy, readwrite)TTAlphaThemedButton *moreButton;
@property (nonatomic, assign)CGRect originFrame;

@end

@implementation TTVideoLinkViewTopBar

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        self.originFrame = frame;
        [self addBackButton];
        [self addMoreButton];
        [self addTitleLable];
        [self addBottomLine];
    }
    return self;
}

- (void)addBackButton
{
    _backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    _backButton.imageName = @"lefterbackicon_titlebar";
    _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_backButton sizeToFit];
    [self addSubview:_backButton];
}

- (void)addMoreButton
{
    _moreButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    _moreButton.imageName = @"new_more_titlebar";
    _moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_moreButton sizeToFit];
    [self addSubview:_moreButton];
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSInteger safeArea = ![TTDeviceHelper isIPhoneXDevice] ? 0 : self.tt_safeAreaInsets.top - 10;
    _backButton.frame = CGRectMake(10, safeArea, _backButton.width, self.height - safeArea);
    _moreButton.frame = CGRectMake(self.width - _moreButton.width - 10, safeArea, _backButton.width, self.height - safeArea);
    _titleLabel.frame = CGRectMake(_backButton.right + 10, safeArea, self.width - 2 * (_backButton.right + 10), self.height - safeArea);
}

- (void)addTitleLable
{
    //title的文字颜色
    _titleLabel = [[SSThemedLabel alloc] init];
    _titleLabel.textColorThemeKey = @"navigationTextColorWhite";
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
}

- (void)addBottomLine {
    _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bounds) - [TTDeviceHelper ssOnePixel], CGRectGetWidth(self.bounds), [TTDeviceHelper ssOnePixel])];
    _bottomLine.backgroundColorThemeKey = kColorLine1;
    _bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_bottomLine];
}
@end



@interface TTVideoExtendLinkHelper ()
+ (SSWebViewController *)webControllerWithParameters:(NSDictionary *)parameters isHiddenBar:(BOOL)hiddenBar;
@end

@interface TTVideoLinkView ()<UIGestureRecognizerDelegate>
@property (nonatomic)SSWebViewController *webViewController;
@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGFloat lastY;
@property (nonatomic, assign) BOOL isScrolledToTop;
@property (nonatomic, assign) BOOL isDown;
@property (nonatomic, assign) BOOL isInAnimation;
@property (nonatomic, assign) CGRect beginFrame;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, assign) BOOL isDraggingView;
@property (nonatomic, assign) NSInteger safeArea;
@property (nonatomic, assign) BOOL isFull;
@property (nonatomic, assign) BOOL isDisablePan;
@property (nonatomic, strong) TTVideoLinkViewTopBar *topBar;
@end

@implementation TTVideoLinkView

- (void)addOldUIWithParameters:(NSDictionary *)parameters frame:(CGRect)frame parentViewController:(UIViewController *)parentViewController
{
    SSThemedButton *backgroundButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    backgroundButton.backgroundColor = [UIColor clearColor];
    backgroundButton.imageName = @"titlebar_close";
    [backgroundButton sizeToFit];
    CGFloat space = [TTDeviceUIUtils tt_newFontSize:44];
    backgroundButton.frame = CGRectMake(self.width - [TTDeviceUIUtils tt_newFontSize:12] - backgroundButton.width, 0, backgroundButton.frame.size.width, space);
    [backgroundButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backgroundButton];
    
    CGFloat left = [TTDeviceUIUtils tt_newFontSize:12];
    SSThemedLabel *title = [[SSThemedLabel alloc] initWithFrame:CGRectMake(left, 0, frame.size.width - backgroundButton.frame.size.width - left * 2 - 5, space)];
    title.text = [parameters valueForKey:@"wap_title"];
    title.textColorThemeKey = kColorText1;
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:15]];
    [self addSubview:title];
    
    CGFloat lineHeight = 1.0/[UIScreen mainScreen].scale;
    SSThemedView *line = [[SSThemedView alloc] initWithFrame:CGRectMake(0, space - lineHeight, self.width, lineHeight)];
    line.backgroundColorThemeKey = kColorLine1;
    [self addSubview: line];
    
    _webViewController = [TTVideoExtendLinkHelper webControllerWithParameters:parameters isHiddenBar:YES];
    [_webViewController willMoveToParentViewController:parentViewController];
    [self addSubview:_webViewController.view];
    _webViewController.view.frame = CGRectMake(0, backgroundButton.bottom, self.width, self.height - backgroundButton.bottom);
    [_webViewController didMoveToParentViewController:parentViewController];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.topBar) {
        [self.superview addSubview:self.topBar];
    }
}

- (void)addNewUIWithParameters:(NSDictionary *)aparameters frame:(CGRect)frame parentViewController:(UIViewController *)parentViewController
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:aparameters];
    [parameters setValue:@(YES) forKey:@"disable_web_progressView"];
    TTVideoLinkViewTopBar *topBar = [[TTVideoLinkViewTopBar alloc] initWithFrame:CGRectMake(0,-44 - self.safeArea, self.width, 44 + self.safeArea)];
    topBar.alpha = 0;
    topBar.title = [parameters valueForKey:@"wap_title"];
    [topBar.backButton addTarget:self
                          action:@selector(newClickBackButton)
                forControlEvents:UIControlEventTouchUpInside];
    [topBar.moreButton addTarget:self
                          action:@selector(newClickMoreButton)
                forControlEvents:UIControlEventTouchUpInside];
    self.topBar = topBar;
    self.fullFrame = CGRectMake(self.fullFrame.origin.x, self.fullFrame.origin.y + topBar.height, self.fullFrame.size.width, self.fullFrame.size.height - topBar.height);
    _webViewController = [TTVideoExtendLinkHelper webControllerWithParameters:parameters isHiddenBar:YES];
    [_webViewController willMoveToParentViewController:parentViewController];
    [self addSubview:_webViewController.view];
    _webViewController.view.frame = self.bounds;
    [_webViewController didMoveToParentViewController:parentViewController];
    
    @weakify(self);
    [self.KVOController observe:_webViewController.ssWebView.ssWebContainer.ssWebView.scrollView keyPath:@keypath(_webViewController.ssWebView.ssWebContainer.ssWebView.scrollView,contentOffset) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.isScrolledToTop = _webViewController.ssWebView.ssWebContainer.ssWebView.scrollView.contentOffset.y <= 0;
    }];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
    self.panGestureRecognizer = pan;
}

- (instancetype)initWithHalfFrame:(CGRect)halfFrame fullFrame:(CGRect)fullFrame parentViewController:(UIViewController *)parentViewController parameters:(NSDictionary *)parameters
{
    CGRect frame = halfFrame;
    self = [super initWithFrame:frame];
    if (self) {
        self.safeArea = ![TTDeviceHelper isIPhoneXDevice] ? 0 : self.tt_safeAreaInsets.top;
        self.halfFrame = halfFrame;
        self.fullFrame = fullFrame;
        self.isScrolledToTop = YES;
        self.backgroundColorThemeKey = kColorBackground4;
        if ([self isNewInteractive]) {
            [self addNewUIWithParameters:parameters frame:frame parentViewController:parentViewController];
        }else{
            [self addOldUIWithParameters:parameters frame:frame parentViewController:parentViewController];
        };
        if ([self.delegate respondsToSelector:@selector(videoLinkViewWillAppear)]) {
            [self.delegate videoLinkViewWillAppear];
        }
    }
    return self;
}

- (BOOL)isNewInteractive
{
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_extend_link_new_interactive" defaultValue:@(NO) freeze:YES] boolValue];
}

- (void)newClickMoreButton
{
    if ([self.delegate respondsToSelector:@selector(videoLinkViewClickMorebutton)]) {
        [self.delegate videoLinkViewClickMorebutton];
    }
}

- (void)newClickBackButton
{
    if ([self.delegate respondsToSelector:@selector(videoLinkViewClickBackbutton)]) {
        [self.delegate videoLinkViewClickBackbutton];
    }
}

- (void)pan:(UIPanGestureRecognizer *)ges {
    CGPoint locationPoint = [ges locationInView:self.superview];
    CGPoint translation = [ges translationInView:self.superview];
    BOOL isUp = YES;
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (self.frame.size.height >= self.fullFrame.size.height && translation.y < 0) {
                self.isDisablePan = YES;
                return;
            }
            if (self.frame.size.height <= self.halfFrame.size.height && translation.y > 0) {
                self.isDisablePan = YES;
                return;
            }
            self.beginFrame = self.frame;
            self.originFrame = CGRectEqualToRect(self.beginFrame, self.halfFrame) ? self.halfFrame : self.fullFrame;
            self.lastY = locationPoint.y;
            CGPoint velocity = [ges velocityInView:self.superview];
            if (fabs(velocity.y) > 450) {
                if (isUp) {
                    [self fullAnimationIsAuto:NO sendTrack:YES];
                }else{
                    [self halfAnimation];
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (self.isDisablePan) {
                return;
            }
            CGFloat step = locationPoint.y - self.lastY;
            CGRect frame = self.frame;
            frame.origin.y += step;
            frame.size.height -= step;
            isUp = step > 0 ? NO : YES;
            if (frame.origin.y <= self.fullFrame.origin.y) {
                frame.origin.y = self.fullFrame.origin.y;
            }else if (frame.origin.y > self.halfFrame.origin.y){
                frame.origin.y = self.halfFrame.origin.y;
            }
            if (frame.size.height <= self.halfFrame.size.height) {
                frame.size.height = self.halfFrame.size.height;
            }else if (frame.size.height > self.fullFrame.size.height){
                frame.size.height = self.fullFrame.size.height;
            }
            self.frame = frame;
            self.lastY = locationPoint.y;
            if (CGRectEqualToRect(self.frame, self.fullFrame)) {
                self.hasEnterFull = YES;
            }
            if (step != 0) {
                if (!self.isInAnimation) {
                    [self checkScrollIsUp:isUp animated:NO sendTrack:YES];
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (self.isDisablePan) {
                self.isDisablePan = NO;
                return;
            }
            if (!self.isInAnimation) {
                if (self.frame.origin.y > self.beginFrame.origin.y) {
                    [self checkScrollIsUp:NO animated:YES sendTrack:YES];
                }else if (self.frame.origin.y < self.beginFrame.origin.y){
                    [self checkScrollIsUp:YES animated:YES sendTrack:YES];
                }else if(self.frame.origin.y == self.beginFrame.origin.y){
                    [self showPercent:0 isUp:NO];
                }
            }
        }
            break;
        default:
            break;
    }
    
}

- (void)autoFull
{
    if ([self isNewInteractive]) {
        [self fullAnimationIsAuto:YES sendTrack:YES];
        self.hasEnterFull = YES;
        CGFloat distancePercent = [self getDistancePercentWithStartFrame:self.fullFrame];
        [self.delegate videoLinkViewScrollIsUp:YES percent:distancePercent];
        [self showTopBarWithPercent:distancePercent];
    }
}

- (CGFloat)getDistancePercentWithStartFrame:(CGRect)startFrame
{
    CGFloat distancePercent = fabs((startFrame.origin.y - self.halfFrame.origin.y) / (self.halfFrame.origin.y - self.fullFrame.origin.y));
    return distancePercent;
}

- (void)showTopBarWithPercent:(CGFloat)distancePercent
{
    if (distancePercent <= 1 && distancePercent >= 0) {
        self.topBar.alpha = distancePercent;
        CGFloat distance = fabs(distancePercent * (self.topBar.originFrame.size.height));
        self.topBar.frame = CGRectMake(0, self.topBar.originFrame.origin.y + distance, self.width, self.topBar.height);
    }
}

- (void)showPercent:(CGFloat)percent isUp:(BOOL)isUp
{
    if ([self.delegate respondsToSelector:@selector(videoLinkViewScrollIsUp:percent:)]) {
        CGFloat distancePercent = [self getDistancePercentWithStartFrame:self.frame];
        [self.delegate videoLinkViewScrollIsUp:isUp percent:distancePercent];
        [self showTopBarWithPercent:distancePercent];
    }
}

- (void)checkScrollIsUp:(BOOL)isUp animated:(BOOL)animated sendTrack:(BOOL)sendTrack
{
    CGFloat percent = fabs((self.frame.origin.y - self.beginFrame.origin.y) / (self.halfFrame.origin.y - self.fullFrame.origin.y));
    [self showPercent:percent isUp:isUp];
    if (isUp) {//向上移动
        if (percent > 0.5) {//超过一半距离
            if (animated) {
                [self fullAnimationIsAuto:sendTrack sendTrack:sendTrack];
            }
        }else{
            if (animated) {
                [self halfAnimation];
            }
        }
    }else {//向下移动
        if (percent > 0.5) {//超过一半距离
            if (animated) {
                [self halfAnimation];
            }
        }else{
            if (animated) {
                [self fullAnimationIsAuto:NO sendTrack:NO];
            }
        }
    }
}

- (void)fullAnimationIsAuto:(BOOL)isAuto sendTrack:(BOOL)sendTrack
{
    self.isInAnimation = YES;
    self.hasEnterFull = YES;
    if (!self.isFull && sendTrack) {
        if ([self.delegate respondsToSelector:@selector(videoLinkViewFullScreenTrackIsAuto:)]) {
            [self.delegate videoLinkViewFullScreenTrackIsAuto:NO];
        }
    }
    self.isFull = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = self.fullFrame;
        self.topBar.alpha = 1;
        self.topBar.frame = CGRectOffset(self.topBar.originFrame, 0, self.topBar.height);
        self.isInAnimation = NO;
    }];
}

- (void)halfAnimation
{
    self.isFull = NO;
    self.isInAnimation = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = self.halfFrame;
        self.topBar.alpha = 0;
        self.topBar.frame = self.topBar.originFrame;
        [self showPercent:0 isUp:NO];
        self.isInAnimation = NO;
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self.panGestureRecognizer.view];
        self.isDown = velocity.y > 0;
        CGPoint translation = [((UIPanGestureRecognizer *)gestureRecognizer) translationInView:gestureRecognizer.view];
        if (fabs(velocity.x) < fabs(velocity.y))
        {
            if (CGRectEqualToRect(self.frame, self.fullFrame) &&
                self.isScrolledToTop && self.isDown) {
                return YES;//跟手
            }
            if (self.frame.size.height < self.fullFrame.size.height &&
                self.frame.size.height >= self.halfFrame.size.height) {
                return YES;
            }
        }
        return NO;//不跟手
    }
    return YES;
}

- (void)backButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(videoLinkViewWillDisappear)]) {
        [self.delegate videoLinkViewWillDisappear];
    }
    [self removeFromSuperview];
}
@end


@implementation TTVideoExtendLinkHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (SSWebViewController *)webControllerWithParameters:(NSDictionary *)parameters
{
    return [self webControllerWithParameters:parameters isHiddenBar:NO];
}

+ (SSWebViewController *)webControllerWithParameters:(NSDictionary *)parameters isHiddenBar:(BOOL)hiddenBar
{
    NSMutableDictionary *conditions = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [conditions setValue:@(YES) forKey:@"supportRotate"];
    [conditions setValue:[parameters valueForKey:@"url"] forKey:@"url"];
    [conditions setValue:[parameters valueForKey:@"wap_title"] forKey:@"title"];
    [conditions setValue:[parameters valueForKey:@"status_bar_color"] forKey:@"status_bar_color"];
    if (hiddenBar) {
        [conditions setValue:@(YES) forKey:@"hide_status_bar"];
        [conditions setValue:@(YES) forKey:@"hide_nav_bar"];
        [conditions setValue:@"close" forKey:@"back_button_icon"];
        [conditions setValue:@"bottom_right" forKey:@"back_button_position"];
    }
    else
    {
        [conditions setValue:@(NO) forKey:@"hide_status_bar"];
        [conditions setValue:@(NO) forKey:@"hide_nav_bar"];
        [conditions setValue:@"down_arrow" forKey:@"back_button_icon"];
    }
    
    SSWebViewController * web = [[SSWebViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(conditions)];
    web.adID = [parameters valueForKey:@"id"];
    web.logExtra = [parameters valueForKey:@"log_extra"];
    if (hiddenBar) {
        [web setDismissType:SSWebViewDismissTypePresent];
    }
    return web;
}

+ (TTVideoLinkView *)linkViewWithHalfFrame:(CGRect)halfFrame fullFrame:(CGRect)fullFrame parentViewController:(UIViewController *)parentViewController parameters:(NSDictionary *)parameters
{
    return [[TTVideoLinkView alloc] initWithHalfFrame:halfFrame fullFrame:fullFrame parentViewController:parentViewController parameters:parameters];
}

@end

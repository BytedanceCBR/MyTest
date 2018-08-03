//
//  TTAWapNavigationBar.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 3/21/17.
//
//

#import "TTAWapNavigationBar.h"
#import "TTAccount.h"
#import "NSBundle+TTAResources.h"
#import <objc/runtime.h>



#define kTTAccountOnePixel (1.0f / [[UIScreen mainScreen] scale])


typedef NS_ENUM(NSInteger, TTAccountSDKNavBarLayoutInsetType) {
    TTAccountSDKNavBarLayoutInsetTypeNone = 0,
    TTAccountSDKNavBarLayoutInsetTypeLeft,          // 最左边
    TTAccountSDKNavBarLayoutInsetTypeRight,         // 最右边
    TTAccountSDKNavBarLayoutInsetTypeLeftAndRight,  // 最左边 和 最右边 
};

@interface UIView (TTAccountSDKBarButtonPositionLayout)

@property (nonatomic, assign) TTAccountSDKNavBarLayoutInsetType navBarLayoutInsetType;

@end

@implementation UIView (TTAccountSDKBarButtonPositionLayout)

- (void)setNavBarLayoutInsetType:(TTAccountSDKNavBarLayoutInsetType)barButtonLayoutType
{
    objc_setAssociatedObject(self, @selector(navBarLayoutInsetType), @(barButtonLayoutType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTAccountSDKNavBarLayoutInsetType)navBarLayoutInsetType
{
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (value && [value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return TTAccountSDKNavBarLayoutInsetTypeNone;
}

@end



@interface TTAWapBarButtonContainerView : UIView

@property (nonatomic, weak) UIButton *barButton;

@end



@interface TTAWapNavigationBar ()

@property (nonatomic, strong) UIView *barBottomLineView;

@property (nonatomic, strong) UIView *barBackgroundShadowView;

@end

@implementation TTAWapNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonInit
{
    NSString *hideShadowKey = [NSString stringWithFormat:@"hides%@", @"Shadow"];
    [self setValue:@(YES) forKey:hideShadowKey];
    
    {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.shadowImage = [UIImage new];
        self.translucent = NO;
    }
    
    {
        [self addSubview:self.barBottomLineView];
        [self insertSubview:self.barBackgroundShadowView atIndex:0];
    }
    
    {
        UIColor *lineColor  =
        [TTAccount accountConf].wapLoginConf.navBarBottomLineColor;
        UIColor *barBgColor =
        [TTAccount accountConf].wapLoginConf.navBarBackgroundColor;
        UIColor *tintColor =
        [TTAccount accountConf].wapLoginConf.navBarTintColor;
        
        self.hairlineColor = lineColor ? : [UIColor whiteColor];
        self.barBackgroundColor = barBgColor ? : [UIColor whiteColor];
        tintColor ? self.tintColor = tintColor : nil;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustCustomViewsLayout)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustCustomViewsLayout)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification
                                               object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self adjustCustomViewsLayout];
    
    [self adaptIOS11NavBarLayout];
}

- (void)adaptIOS11NavBarLayout
{
    if (TTACCOUNT_DEVICE_SYS_VERSION >= 11.0) {
        NSString *iOS11ButtonBarClsName  = [NSString stringWithFormat:@"_%@%@", @"UIButtonBar", @"StackView"];
        UIView *customLeftBarButtonView  = self.topItem.leftBarButtonItem.customView;
        UIView *customRightBarButtonView = self.topItem.rightBarButtonItem.customView;
        
        if ([customLeftBarButtonView isKindOfClass:[TTAWapBarButtonContainerView class]] && [customLeftBarButtonView.superview.superview isKindOfClass:NSClassFromString(iOS11ButtonBarClsName)]) {
            if ([customLeftBarButtonView respondsToSelector:@selector(navBarLayoutInsetType)]) {
                NSInteger layoutType = customLeftBarButtonView.navBarLayoutInsetType;
                /** _UINavigationBarContentView */
                UIView *stackViewSuperView = customLeftBarButtonView.superview.superview.superview;
                [self.class adaptAutoLayoutByChangeInsetForView:stackViewSuperView
                                                layoutInsetType:layoutType];
            }
        }
        
        if ([customRightBarButtonView isKindOfClass:[TTAWapBarButtonContainerView class]] && [customRightBarButtonView.superview.superview isKindOfClass:NSClassFromString(iOS11ButtonBarClsName)]) {
            if ([customRightBarButtonView respondsToSelector:@selector(navBarLayoutInsetType)]) {
                NSInteger layoutType = customRightBarButtonView.navBarLayoutInsetType;
                /** _UINavigationBarContentView */
                UIView *stackViewSuperView = customRightBarButtonView.superview.superview.superview;
                [self.class adaptAutoLayoutByChangeInsetForView:stackViewSuperView
                                                layoutInsetType:layoutType];
                
            }
        }
    }
}

+ (void)adaptAutoLayoutByChangeInsetForView:(UIView *)stackViewSuperView
                            layoutInsetType:(TTAccountSDKNavBarLayoutInsetType)type
{
    if (!stackViewSuperView) return;
    
    NSInteger leftEdgeInset  = ((type == TTAccountSDKNavBarLayoutInsetTypeLeft || type == TTAccountSDKNavBarLayoutInsetTypeLeftAndRight) ? 0 : -1);
    NSInteger rightEdgeInset = ((type == TTAccountSDKNavBarLayoutInsetTypeRight || type == TTAccountSDKNavBarLayoutInsetTypeLeftAndRight) ? 0 : -1);
    
    @try {
        if ([stackViewSuperView respondsToSelector:@selector(setLayoutMargins:)]) {
            id edgeInsetsValue = [stackViewSuperView valueForKey:@"layoutMargins"];
            UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
            if ([edgeInsetsValue isKindOfClass:[NSValue class]]) {
                edgeInsets = [edgeInsetsValue UIEdgeInsetsValue];
                if (leftEdgeInset >= 0)  edgeInsets.left = leftEdgeInset;
                if (rightEdgeInset >= 0) edgeInsets.right = rightEdgeInset;
            }
            [stackViewSuperView performSelector:@selector(setLayoutMargins:)
                                     withObject:[NSValue valueWithUIEdgeInsets:edgeInsets]];
        }
        
        if ([stackViewSuperView respondsToSelector:@selector(setDirectionalLayoutMargins:)]) {
            id edgeInsetsValue = [stackViewSuperView valueForKey:@"directionalLayoutMargins"];
            UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
            if (leftEdgeInset >= 0)  edgeInsets.left = leftEdgeInset;
            if (rightEdgeInset >= 0) edgeInsets.right = rightEdgeInset;
            
            if ([edgeInsetsValue isKindOfClass:[NSValue class]]) {
                if ([edgeInsetsValue respondsToSelector:@selector(directionalEdgeInsetsValue)]) {
                    // 将 NSDirectionalEdgeInsets 转换为 UIEdgeInsets
                    edgeInsets = [[edgeInsetsValue valueForKey:@"directionalEdgeInsetsValue"] UIEdgeInsetsValue];
                    if (leftEdgeInset >= 0)  edgeInsets.left = leftEdgeInset;
                    if (rightEdgeInset >= 0) edgeInsets.right = rightEdgeInset;
                } else {
                    edgeInsets = [edgeInsetsValue UIEdgeInsetsValue];
                }
            }
            
            [stackViewSuperView performSelector:@selector(setDirectionalLayoutMargins:)
                                     withObject:[NSValue valueWithUIEdgeInsets:edgeInsets]];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}


#pragma mark - adjust layout

- (void)adjustCustomViewsLayout
{
    if (_barBottomLineView && (CGRectGetWidth(_barBottomLineView.bounds) != CGRectGetWidth(self.bounds))) {
        self.barBottomLineView.frame = CGRectMake(0,
                                                  CGRectGetMaxY(self.bounds) - kTTAccountOnePixel,
                                                  CGRectGetWidth(self.bounds),
                                                  kTTAccountOnePixel);
    }
    if (_barBottomLineView) [self bringSubviewToFront:self.barBottomLineView];
    
    
    if (_barBackgroundShadowView && ((CGRectGetWidth(_barBackgroundShadowView.bounds)  != CGRectGetWidth(self.bounds)) ||
                                     (CGRectGetHeight(_barBackgroundShadowView.bounds) != (CGRectGetHeight(self.bounds) + [self.class statusBarHeight])))) {
        self.barBackgroundShadowView.frame = CGRectMake(0,
                                                        -[self.class statusBarHeight],
                                                        CGRectGetWidth(self.bounds),
                                                        CGRectGetHeight(self.bounds) + [self.class statusBarHeight]);
    }
    if (_barBackgroundShadowView) [self sendSubviewToBack:self.barBackgroundShadowView];
}

#pragma mark - getter/setter

- (void)setHairlineColor:(UIColor *)hairlineColor
{
    _hairlineColor = hairlineColor;
    self.barBottomLineView.backgroundColor = _hairlineColor;
}

- (void)setBarBackgroundColor:(UIColor *)barBackgroundColor
{
    _barBackgroundColor = barBackgroundColor;
    if (_barBackgroundColor) {
        self.translucent = YES;
    } else {
        self.translucent = NO;
    }
    self.barBackgroundShadowView.backgroundColor = _barBackgroundColor;
}

- (UIView *)barBottomLineView
{
    if (!_barBottomLineView) {
        _barBottomLineView =
        [[UIView alloc] initWithFrame:CGRectMake(0,
                                                 CGRectGetMaxY(self.bounds) - kTTAccountOnePixel,
                                                 CGRectGetWidth(self.bounds),
                                                 kTTAccountOnePixel)];
        _barBottomLineView.backgroundColor = [UIColor whiteColor];
    }
    return _barBottomLineView;
}

- (UIView *)barBackgroundShadowView
{
    if (!_barBackgroundShadowView) {
        _barBackgroundShadowView =
        [[UIView alloc] initWithFrame:CGRectMake(0,
                                                 -[self.class statusBarHeight],
                                                 CGRectGetWidth(self.bounds),
                                                 CGRectGetHeight(self.bounds) + [self.class statusBarHeight])];
        _barBackgroundShadowView.backgroundColor = [UIColor whiteColor];
    }
    return _barBackgroundShadowView;
}

#pragma mark - helper

+ (CGFloat)statusBarHeight
{
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

@end



#pragma mark - TTAWapBarButtonContainerView

@implementation TTAWapBarButtonContainerView

- (instancetype)initWithBarButton:(UIButton *)barButton
{
    if ((self = [super init])) {
        _barButton = barButton;
        
        // force to call `alignmentRectInsets`
        //        if ([self respondsToSelector:@selector(safeAreaLayoutGuide)]) {
        //            [self performSelector:@selector(safeAreaLayoutGuide)];
        //        }
    }
    return self;
}

- (void)dealloc
{
    _barButton = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.barButton && CGRectGetHeight(self.barButton.frame) != 44.f) {
        CGRect barButtonFrame = self.barButton.frame;
        self.barButton.frame  = CGRectMake(CGRectGetMinX(barButtonFrame),
                                           0,
                                           CGRectGetWidth(barButtonFrame),
                                           44.f);
    }
    
    if (self.barButton && !CGSizeEqualToSize(self.bounds.size, self.barButton.bounds.size)) {
        CGRect selfFrame = self.frame;
        self.frame = CGRectMake(CGRectGetMinX(selfFrame),
                                0,
                                CGRectGetWidth(self.barButton ? self.barButton.bounds : selfFrame),
                                44.f);
    }
}

- (CGSize)intrinsicContentSize
{
    return self.barButton ? self.barButton.bounds.size : [super intrinsicContentSize];
}

- (UIEdgeInsets)alignmentRectInsets
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 16.f, 0, 0);
    //    if (TTACCOUNT_DEVICE_SYS_VERSION >= 11.0) { // 在Xcode8上编译的包在iOS11上将导致递归调用
    //        insets = [super alignmentRectInsets]; // UIEdgeInsetsMake(0, 0.000001, 0, 0);
    //    }
    return insets;
}

@end



@implementation UIBarButtonItem (TTABarButtonItemControl)

+ (UIView *)tta_barTitleViewWithTitle:(NSString *)titleString
{
    UIColor *titleTextColor = [TTAccount accountConf].wapLoginConf.navBarTitleTextColor;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor= titleTextColor ? : TTAccountUIColorFromHexRGB(0x464646);
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.text = titleString;
    [titleLabel sizeToFit];
    
    return titleLabel;
}

+ (UIBarButtonItem *)tta_backBarButtonItemWithTarget:(id)target
                                              action:(SEL)action
{
    return [self tta_backBarButtonItemWithText:nil
                                    arrowImage:YES
                                        target:target
                                        action:action];
}

+ (UIBarButtonItem *)tta_backBarButtonItemWithText:(NSString *)textString
                                        arrowImage:(BOOL)arrowImageEnabled
                                            target:(id)target
                                            action:(SEL)action
{
    return [self.class tta_barButtonItemWithText:textString
                                           image:(arrowImageEnabled ? [UIImage tta_imageNamed:@"tta_backbutton_titlebar"] : nil)
                                          target:target
                                          action:action
                              barLayoutInsetType:TTAccountSDKNavBarLayoutInsetTypeLeft];
}

+ (UIBarButtonItem *)tta_barButtonItemWithText:(NSString *)textString
                                         image:(UIImage *)image
                                        target:(id)target
                                        action:(SEL)action
                            barLayoutInsetType:(TTAccountSDKNavBarLayoutInsetType)type
{
    if (!target || !action) return nil;
    
    UIColor *tintColor = [TTAccount accountConf].wapLoginConf.navBarTintColor;
    UIColor *textNormalColor  = tintColor ? : TTAccountUIColorFromHexRGB(0xFF7350);
    UIColor *highlightedColor = [textNormalColor colorWithAlphaComponent:0.8];
    UIColor *disabledColor    = [textNormalColor colorWithAlphaComponent:0.5];
    
    // 不加一个containerView直接把button传给navigationItem会造成button的响应区域变得很大
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (image) {
        [aButton setImage:image forState:UIControlStateNormal];
    }
    [aButton setTitle:textString
             forState:UIControlStateNormal];
    [aButton setTitleColor:textNormalColor
                  forState:UIControlStateNormal];
    [aButton setTitleColor:highlightedColor
                  forState:UIControlStateHighlighted];
    [aButton setTitleColor:disabledColor
                  forState:UIControlStateDisabled];
    [aButton addTarget:target action:action
      forControlEvents:UIControlEventTouchUpInside];
    [aButton sizeToFit];
    
    TTAWapBarButtonContainerView *containerView = [[TTAWapBarButtonContainerView alloc] initWithBarButton:aButton];
    containerView.navBarLayoutInsetType = type;
    containerView.frame = CGRectMake(0, 0, MAX(44.f, CGRectGetWidth(aButton.frame) + 2), 44.f);
    aButton.frame = containerView.bounds;
    [containerView addSubview:aButton];
    
    return [[UIBarButtonItem alloc] initWithCustomView:containerView];
}

+ (UIBarButtonItem *)tta_refreshBarButtonItemWithTarget:(id)target
                                                 action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                         target:target
                                                         action:action];
}

@end



@implementation UIViewController (TTAWapNavgiationBar)

- (void)setTta_wapNavigationBar:(TTAWapNavigationBar *)tta_wapNavigationBar
{
    objc_setAssociatedObject(self,
                             @selector(tta_wapNavigationBar),
                             tta_wapNavigationBar,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTAWapNavigationBar *)tta_wapNavigationBar
{
    TTAWapNavigationBar *wapNavBar = objc_getAssociatedObject(self, _cmd);
    if ([wapNavBar isKindOfClass:[TTAWapNavigationBar class]]) {
        return wapNavBar;
    }
    return [self __tta_wapNavigationBar__];
}

- (TTAWapNavigationBar *)__tta_wapNavigationBar__
{
    if ([self.navigationController.navigationBar isKindOfClass:[TTAWapNavigationBar class]]) {
        return (TTAWapNavigationBar *)self.navigationController.navigationBar;
    }
    return nil;
}

@end


//
//  SSNavigationBar.m
//  Article
//
//  Created by SunJiangting on 14-9-17.
//
//

#import "SSNavigationBar.h"
#import "TTAlphaThemedButton.h"
#import "SSThemed.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeManager.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"
#import "NSObject+FBKVOController.h"

@interface TTNavigationBarItemContainerView ()

@property (nonatomic, strong) SSThemedButton *button;
@property (nonatomic, assign) SSNavigationButtonOrientation orientation;

@end

@implementation TTNavigationBarItemContainerView

- (instancetype)initWithOrientation:(SSNavigationButtonOrientation)orientation {
    if (self = [super init]) {
        self.orientation = orientation;
        [self addKVO];
    }
    return self;
}

- (void)setButton:(SSThemedButton *)button {
    _button = button;
    [self addKVO];
}

- (void)addKVO {
    if(!isEmptyString(_button.titleLabel.text) && _button) {
        WeakSelf;
        [self.KVOController observe:_button keyPath:@"titleLabel.text" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            NSString *newTitle = [change valueForKey:NSKeyValueChangeNewKey];
            if (newTitle.length > 3) {
                self.button.titleLabel.font = [UIFont systemFontOfSize:15.f];
            }else {
                self.button.titleLabel.font = [UIFont systemFontOfSize:16.f];
            }
            [self.button setTitle:newTitle forState:UIControlStateNormal];
            [self.button sizeToFit];
            CGFloat width = self.button.width;
            self.button.frame = CGRectMake(0, 0, width, 44.f);
            self.width = width;
            if (self.orientation == SSNavigationButtonOrientationOfLeft) {
                self.left = CGRectGetMinX(self.superview.bounds) + 12.f;
            } else if (self.orientation == SSNavigationButtonOrientationOfRight) {
                self.right = CGRectGetMaxX(self.superview.bounds) - 12.f;
            }
            [self layoutIfNeeded];
        }];
    }
}

- (UIEdgeInsets)alignmentRectInsets {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (self.orientation == SSNavigationButtonOrientationOfLeft) {
        insets = UIEdgeInsetsMake(0.f, isEmptyString(_button.titleLabel.text) ? 8.f : 2.f, 0.f, 0.f);
    } else if (self.orientation == SSNavigationButtonOrientationOfRight) {
        insets = UIEdgeInsetsMake(0.f, 0.f, 0.f, isEmptyString(_button.titleLabel.text) ? 14.f : 2.f);
    }
    return insets;
}

@end

@interface SSNavigationBar ()

@property(nonatomic, strong) UIView *transitionView;
@property(nonatomic, strong) UIColor *navigationBarTintColor;

@end

@implementation SSNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    CGFloat height = 64;
    if (frame.size.height < height) {
        frame.size.height = height;
    }
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _shouldTitleViewSizeToFit = NO;
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.translucent = NO;
        self.navigationBarTintColor = toolbar.barTintColor;
        self.backgroundView = toolbar;
        [self reloadThemeUI];
        self.backgroundView.frame = self.bounds;
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.backgroundView];

        CGFloat topMargin = CGRectGetHeight(frame) - 44;
        CGFloat height = 44;
        self.transitionView = [[UIView alloc] initWithFrame:CGRectMake(0, topMargin, CGRectGetWidth(self.bounds), height)];
        self.transitionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.transitionView.backgroundColor = [UIColor clearColor];
        self.transitionView.clipsToBounds = YES;
        [self addSubview:self.transitionView];

        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColorThemeKey = kColorText2;
        self.titleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.titleLabel.font = [UIFont systemFontOfSize:20.];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        // self.titleView = self.titleLabel;

        self.separatorView = [[SSThemedView alloc] init];
        self.separatorView.backgroundColors = SSThemedColors(@"afafaf", @"464646");
        [self addSubview:self.separatorView];
        self.preferredItemWidth = 60;
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    if ([self.backgroundView isKindOfClass:[UIToolbar class]]) {
        UIToolbar *toolbar = (UIToolbar *)self.backgroundView;
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            toolbar.barTintColor = [UIColor colorWithHexString:@"2b2b2b"];
        } else {
            toolbar.barTintColor = self.navigationBarTintColor;
        }
    }
}

- (void)setTitleText:(NSString *)title {
    self.title = title;
}

- (void)setTitle:(NSString *)title {
    NSString *fixtitle = title;
    NSInteger threshold = 10;
    if ([TTDeviceHelper is667Screen]) {
        threshold = 13;
    } else if ([TTDeviceHelper is736Screen]) {
        threshold = 18;
    }
    if ([fixtitle length] > threshold && ![TTDeviceHelper isPadDevice]) {
        fixtitle = [NSString stringWithFormat:@"%@...", [title substringToIndex:threshold]];
    }
    _title = [fixtitle copy];
    self.titleLabel.text = fixtitle;
    self.titleView = self.titleLabel;
}

- (void)setTitleView:(UIView *)titleView {
    if (titleView) {
        [_titleView removeFromSuperview];
    }
    _titleView = titleView;
    _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (titleView) {
        [self.transitionView addSubview:titleView];
        [self relayoutNavigationSubviews];
    }
}

- (void)setLeftBarView:(UIView *)leftBarView {
    if (_leftBarView) {
        [_leftBarView removeFromSuperview];
    }
    _leftBarView = leftBarView;
    if (leftBarView) {
        [self.transitionView addSubview:leftBarView];
        [self relayoutNavigationSubviews];
    }
}

- (void)setRightBarView:(UIView *)rightBarView {
    if (_rightBarView) {
        [_rightBarView removeFromSuperview];
    }
    _rightBarView = rightBarView;
    if (rightBarView) {
        [self.transitionView addSubview:rightBarView];
        [self relayoutNavigationSubviews];
    }
}

- (void)fitLocationWithView:(UIView *)view {
    CGFloat viewHeight = view.frame.size.height;
    if (viewHeight == 0) {
        viewHeight = 44;
    }
    CGFloat height = MIN(CGRectGetHeight(self.transitionView.bounds), viewHeight);
    CGFloat margin = (CGRectGetHeight(self.transitionView.bounds) - height) / 2;

    CGRect frame = view.frame;
    frame.origin.y = margin;
    frame.size.height = height;
    view.frame = frame;
    
//    //在新版里 不需要在使用自己计算的frame 用sizetofit就行
//    [view sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.separatorView.frame = CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
    [self relayoutNavigationSubviews];
}

- (void)relayoutNavigationSubviews {
    CGFloat sideItemWidth = 0;
    if (self.leftBarView || self.rightBarView) {
        sideItemWidth = MAX(CGRectGetWidth(self.leftBarView.frame), CGRectGetWidth(self.rightBarView.frame));
        if (sideItemWidth == 0) {
            sideItemWidth = self.preferredItemWidth;
        }
    }
    sideItemWidth = MIN(sideItemWidth, self.preferredItemWidth);
    CGFloat itemMargin = 10;
    CGFloat maxTitleViewLength = CGRectGetWidth(self.bounds) - 2 * (sideItemWidth + itemMargin);

    self.leftBarView.frame = CGRectMake(0, 0, sideItemWidth, CGRectGetHeight(self.leftBarView.frame));
    self.titleView.frame = CGRectMake(sideItemWidth, 0, CGRectGetWidth(self.bounds) - 2 * sideItemWidth, CGRectGetHeight(self.titleView.frame));
    
    if (self.shouldTitleViewSizeToFit) {
        [self.titleView sizeToFit];
        if (self.titleView.frame.size.width > maxTitleViewLength) {
            CGRect rect = self.titleView.frame;
            rect.size.width = maxTitleViewLength;
            self.titleView.frame = rect;
        }
        self.titleView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.bounds) / 2);
    }
    
    self.rightBarView.frame = CGRectMake(CGRectGetWidth(self.bounds) - sideItemWidth, 0, sideItemWidth, CGRectGetHeight(self.rightBarView.frame));

    [self fitLocationWithView:self.leftBarView];
    [self fitLocationWithView:self.titleView];
    [self fitLocationWithView:self.rightBarView];
}

+ (CGFloat)navigationBarHeight {
    return 44.f + [UIApplication sharedApplication].statusBarFrame.size.height;
}

+ (TTNavigationBarItemContainerView *)navigationBackButtonWithTarget:(id)target action:(SEL)action {
    //不加一个containerView直接把button传给navigationItem会造成button的响应范围变得很大
    TTNavigationBarItemContainerView *containerView = [[TTNavigationBarItemContainerView alloc] initWithOrientation:SSNavigationButtonOrientationOfLeft];
    containerView.frame = CGRectMake(0, 0, 44.f, 44.f);
    
    TTAlphaThemedButton *button = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    containerView.button = button;
    button.enableHighlightAnim = YES;
    button.frame = containerView.bounds;
    [containerView addSubview:button];
    button.imageName = @"lefterbackicon_titlebar";
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return containerView;
}

+ (TTNavigationBarItemContainerView *)navigationButtonOfOrientation:(SSNavigationButtonOrientation)orientation withTitle:(NSString *)title target:(id)target action:(SEL)action {
    //不加一个containerView直接把button传给navigationItem会造成button的响应范围变得很大
    TTNavigationBarItemContainerView *containerView = [[TTNavigationBarItemContainerView alloc] initWithOrientation:orientation];
    
    SSThemedButton *button = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    containerView.button = button;
    [containerView addSubview:button];
    if (title.length > 3) {
        button.titleLabel.font = [UIFont systemFontOfSize:15.f];
    }else {
        button.titleLabel.font = [UIFont systemFontOfSize:16.f];
    }
    [button setTitle:title forState:UIControlStateNormal];
    [button sizeToFit];
    CGFloat width = button.width;
    button.frame = CGRectMake(0, 0, width, 44);
    containerView.bounds = button.bounds;
    button.titleColorThemeKey = kColorText2;
    button.highlightedTitleColorThemeKey = kColorText2Highlighted;
    button.disabledTitleColorThemeKey = kColorText3;
    [button setTitle:title forState:UIControlStateDisabled];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return containerView;
}

+ (UIView *)navigationTitleViewWithTitle:(NSString *)title {

    SSThemedLabel * titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColorThemeKey = kColorText1;
    titleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    titleLabel.font = [UIFont systemFontOfSize:17.];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    
    return titleLabel;

}
@end

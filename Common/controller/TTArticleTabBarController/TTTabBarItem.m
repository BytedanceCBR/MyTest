//
//  TTTabBarItem.m
//  Pods
//
//  Created by fengyadong on 16/7/12.
//
//

#import "TTTabBarItem.h"
#import "UIViewAdditions.h"
#import "TTBadgeNumberView.h"
#import <TTPersistence/TTPersistence.h>
#import "TTSettingsManager.h"

static const CGFloat kTTTabBarItemTitleBottomOffset = 4.f;
static const CGFloat offsetRedDotV = 10.f;
static NSString *const kTTTabBarItemBoundsFileName = @"kTTTabBarItemBounds.plist";
static TTPersistence *tabBarItemPersistence;

@interface TTTabBarItem ()

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, strong) SSThemedButton *tabBarButton;
@property (nonatomic, strong) SSThemedImageView *imageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) UIImage *noralImage;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic, strong) UIImage *loadingImage;
@property (nonatomic, assign) TTTabBarItemState state;
@property (nonatomic, strong) TTBadgeNumberView *ttBadgeView;
@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) UIViewController *viewController;
@property (nonatomic, assign, readwrite) BOOL isRegular;

@end

@implementation TTTabBarItem

+ (void)initialize {
    if (self == [TTTabBarItem class] && [[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue]) {
        tabBarItemPersistence = [TTPersistence persistenceWithName:kTTTabBarItemBoundsFileName];
    }
}

#pragma mark - Setup Components

- (instancetype)init {
    return [self initWithIdentifier:@"default" viewController:[UIViewController new] index:0 isRegular:YES];
}

- (instancetype)initWithIdentifier:(NSString *)identifier viewController:(UIViewController *)viewController index:(NSUInteger)index isRegular:(BOOL)isRegular {
    if (self = [super init]) {
        _identifier = identifier;
        _viewController = viewController;
        _index = index;
        _isRegular = isRegular;
        
        [self setupTabBarButton];
        [self setupImageAndTitleView];
        [self setupDefualtProperties];
        if ([TTDeviceHelper OSVersionNumber] < 8.0) {
            self.backgroundColorThemeKey = @"TabBarBackgroundWhite";
        }
    }
    
    return self;
}

- (void)setupTabBarButton {
    if (!_tabBarButton) {
        _tabBarButton = [[SSThemedButton alloc] initWithFrame:CGRectZero];
        [self addSubview:_tabBarButton];
    }
}

- (void)setupImageAndTitleView {
    if (!_imageView) {
        _imageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imageView];
    }
    
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_titleLabel];
    }
}

- (void)setupDefualtProperties {
    _state = TTTabBarItemStateNone;
    _ttBadgeOffsetV = MAXFLOAT;
}

- (void)setAnimationView:(LOTAnimationView *)animationView {
    if (animationView != _animationView) {
        if (_animationView) {
            [_animationView removeFromSuperview];
        }
        _animationView = animationView;
        if (_animationView) {
            [self addSubview:_animationView];
        }
    }
}

#pragma mark -- Layout

- (void)layoutTabBarButton {
    [self.tabBarButton setFrame:self.bounds];
    [self.tabBarButton addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutImageAndTitleView {
    
    if (self.animationView) {
        self.animationView.centerX = CGRectGetWidth(self.bounds) / 2;
        self.animationView.centerY = CGRectGetHeight(self.bounds) / 2;
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            self.animationView.alpha = 1.f;
        } else {
            self.animationView.alpha = 0.5f;
        }
        
        self.imageView.hidden = YES;
        self.titleLabel.hidden = YES;
        return;
    } else {
        self.imageView.hidden = NO;
        self.titleLabel.hidden = NO;
    }
    
    [self.imageView sizeToFit];
    self.imageView.top = 0;
    self.imageView.centerX = CGRectGetWidth(self.bounds) / 2;
    if (isEmptyString(self.title)) {
        self.imageView.centerY = CGRectGetHeight(self.bounds) / 2;
    }
    
    self.titleLabel.font = self.titleFont;
    self.titleLabel.text = self.title;
    self.titleLabel.bottom = self.bottom - kTTTabBarItemTitleBottomOffset;
    
    if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue]) {
        NSString *bounds = [tabBarItemPersistence objectForKey:self.title];
        if (!isEmptyString(bounds)) {
            self.titleLabel.bounds = CGRectFromString(bounds);
        } else {
            [self.titleLabel sizeToFit];
            [tabBarItemPersistence setObject:NSStringFromCGRect(self.titleLabel.bounds) forKey:self.title];
        }
    }else{
        [self.titleLabel sizeToFit];
    }
    
    self.titleLabel.centerX = CGRectGetWidth(self.bounds) / 2;
}

- (void)layoutBadgeView {
    CGFloat paddingX = self.ttBadgeView.badgeNumber == -1 ? 10.f : 0;
    self.ttBadgeView.centerX = ceilf(self.imageView.right) + paddingX;
    CGFloat offsetV = self.ttBadgeOffsetV != MAXFLOAT ? self.ttBadgeOffsetV : offsetRedDotV;
    self.ttBadgeView.centerY = ceilf(self.imageView.top + offsetV);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutTabBarButton];
    [self layoutImageAndTitleView];
    [self layoutBadgeView];
}

#pragma mark - Public Method

+ (void)syncAllCachedBounds {
    [tabBarItemPersistence save];
}

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        _title = title;
        [self setNeedsLayout];
    }
}

- (void)setNormalImage:(UIImage *)normalImage
      highlightedImage:(UIImage *)highlightedImage
          loadingImage:(UIImage *)loadingImage {
    if (highlightedImage && highlightedImage != self.highlightedImage) {
        self.highlightedImage = highlightedImage;
    }
    
    if (normalImage && normalImage != self.noralImage) {
        self.noralImage = normalImage;
    }
    
    if (loadingImage && loadingImage != self.loadingImage) {
        self.loadingImage = loadingImage;
    }
    
    if(self.state == TTTabBarItemStateNone) {
        self.state = TTTabBarItemStateNormal;
    }
    else {
        [self changeImageViewIfNeed];
        [self layoutImageAndTitleView];
    }
}

- (void)setState:(TTTabBarItemState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    [self changeImageViewIfNeed];
}

- (void)changeImageViewIfNeed {
    if (_state == TTTabBarItemStateLoading) {
        self.imageView.image = self.loadingImage;
        self.titleLabel.textColor = self.highlightedTitleColor;
        //正在做动画直接返回，否则动画会被打断并重新开始
        if ([self.imageView.layer animationForKey:@"rotateAnimation"]) {
            return;
        }
        //rotating animation
        CABasicAnimation * rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
        rotateAnimation.duration = 1.f;
        rotateAnimation.repeatCount = HUGE_VALF;
        
        [self.imageView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    } else {
        [self.imageView.layer removeAllAnimations];
        if (_state == TTTabBarItemStateHighlighted) {
            self.imageView.image = self.highlightedImage;
            self.titleLabel.textColor = self.highlightedTitleColor;
        } else {
            self.imageView.image = self.noralImage;
            self.titleLabel.textColor = self.normalTitleColor;
        }
    }
}

- (TTBadgeNumberView*)ttBadgeView {
    if (!_ttBadgeView) {
        _ttBadgeView = [[TTBadgeNumberView alloc] init];
        _ttBadgeView.badgeViewStyle = TTBadgeNumberViewStyleDefault;
        [self addSubview:_ttBadgeView];
    }
    
    return _ttBadgeView;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    if (self.animationView) {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            self.animationView.alpha = 1.f;
        } else {
            self.animationView.alpha = 0.5f;
        }
    }
}

#pragma mark -- Action

- (void)didSelect:(id)sender {
    if (sender && self.selectedBlock) {
        self.selectedBlock();
    }
}

@end

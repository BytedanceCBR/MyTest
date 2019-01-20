//
//  TTCategorySelectorView.m
//  Article
//
//  Created by Dianwei on 13-6-25.
//
//

#import <QuartzCore/QuartzCore.h>
#import "TTCategorySelectorView.h"
#import "TTArticleCategoryManager.h"
#import "TTVideoCategoryManager.h"
#import "TTBadgeNumberView.h"
#import "TTCategoryDefine.h"

#import "UIViewAdditions.h"
#import "TTNavigationController.h"

#import "UIButton+TTAdditions.h"
#import "TTGlowLabel.h"
#import "TTDeviceHelper.h"

#import "UIImage+TTThemeExtension.h"
#import <Crashlytics/Crashlytics.h>

#import "TTCategoryBadgeNumberManager.h"
#import "TTInfiniteLoopFetchNewsListRefreshTipManager.h"
#import "ArticleBadgeManager.h"

#import "TTSettingsManager.h"
#import "TTPushAlertManager.h"
//#import <TTDialogDirector/CLLocationManager+MutexDialogAdapter.h>
#import "TTCategory+ConfigDisplayName.h"

#import "Bubble-Swift.h"


#define kFirstLeftMargin    15
#define kLastRightMargin    68

#define kFirstTopMargin     12
#define kLastBottomMargin   13

#define kCategroyDefaulHouse @"f_house_news"

@class CategorySelectorButton;

@protocol CategorySelectorButtonDelegate <NSObject>

- (void)buttonTapped:(CategorySelectorButton*)button;
- (CGFloat)marginBetweenVisibleLabelAndButton;
- (void)categoryTipNewChangedOfCategoryID:(NSString *)categoryID withTipNew:(BOOL)tipNew;

@end

@interface CategorySelectorButton : UIView {
    float _maskWidth;
    TTCategory *_categoryModel;
}

@property (nonatomic, strong) TTCategory *categoryModel;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, weak)   NSObject<CategorySelectorButtonDelegate> *delegate;
@property (nonatomic, strong) TTGlowLabel *titleLabel;
@property (nonatomic, strong) TTGlowLabel *maskTitleLabel;
@property (nonatomic, strong) SSThemedView *bottomSelectView;
@property (nonatomic, strong) TTBadgeNumberView *badgeView;
@property (nonatomic, assign) TTCategorySelectorViewStyle style;
@property (nonatomic, assign) TTCategorySelectorViewTabType tabType;
@property (nonatomic, copy)   NSArray<NSString *> *textColors;
@property (nonatomic, copy)   NSArray<NSString *> *textGlowColors;
@property (nonatomic, assign) CGFloat textGlowSize;
@property (nonatomic, assign) BOOL isTrackForShow;
@end

@implementation CategorySelectorButton

- (void)dealloc
{
    self.categoryModel = nil;
    self.delegate = nil;
    self.titleLabel = nil;
    self.maskTitleLabel = nil;
    self.badgeView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame style:(TTCategorySelectorViewStyle)aStyle tabType:(TTCategorySelectorViewTabType)tabType textColors:(NSArray<NSString *> *)textColors textGlowColors:(NSArray<NSString *> *)textGlowColors textGlowSize:(CGFloat)glowSize
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.style = aStyle;
        self.tabType = tabType;
        self.isTrackForShow = YES;
        
        self.titleLabel = [[TTGlowLabel alloc] initWithFrame:self.bounds];
        [self addSubview:_titleLabel];
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:_tapRecognizer];
        
        self.maskTitleLabel = [[TTGlowLabel alloc] initWithFrame:_titleLabel.frame];
        self.maskTitleLabel.backgroundColor = [UIColor clearColor];
        
        self.bottomSelectView = [[SSThemedView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 3, 20, 3)];
        self.bottomSelectView.backgroundColor = [UIColor clearColor];
        self.bottomSelectView.alpha = 0;
        self.bottomSelectView.layer.cornerRadius = 1.5;
        
        _maskTitleLabel.alpha = 0;
        
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.maskTitleLabel.textAlignment = self.titleLabel.textAlignment;
        
        if (self.style == TTCategorySelectorViewWhiteStyle) {
            _titleLabel.textColorThemeKey = kColorText12;
            _maskTitleLabel.textColorThemeKey = kColorText12;
        }else if (self.style == TTCategorySelectorViewLightStyle || self.style == TTCategorySelectorViewNewVideoStyle) {
            _titleLabel.textColorThemeKey = kColorText3;
            _maskTitleLabel.textColorThemeKey = kFHColorDarkBlue;
            self.bottomSelectView.backgroundColorThemeKey = kFHColorCoralPink;
        }else if (self.style == TTCategorySelectorViewVideoStyle) {
            _titleLabel.textColorThemeKey = kColorText1;
            _maskTitleLabel.textColorThemeKey = kColorText4;
        }
        else {
            _titleLabel.textColorThemeKey = kColorText2;
            _maskTitleLabel.textColorThemeKey = kColorText4;
        }
        
        //自定义颜色服务端配置
        if (!SSIsEmptyArray(textColors) && textColors.count == 4) {
            self.textColors = textColors;
            UIColor *normalColor = [UIColor colorWithDayColorName:textColors[0] nightColorName:textColors[1]];
            UIColor *hightlightedColor = [UIColor colorWithDayColorName:textColors[2] nightColorName:textColors[3]];
            _titleLabel.textColor = normalColor;
            _maskTitleLabel.textColor = hightlightedColor;
        }
        
        if (!SSIsEmptyArray(textGlowColors) && textGlowColors.count == 4 && glowSize > 0) {
            self.textGlowColors = textGlowColors;
            UIColor *normalColor = [UIColor colorWithDayColorName:textGlowColors[0] nightColorName:textGlowColors[1]];
            UIColor *hightlightedColor = [UIColor colorWithDayColorName:textGlowColors[2] nightColorName:textGlowColors[3]];
            _titleLabel.glowColor = normalColor;
            _maskTitleLabel.glowColor = hightlightedColor;
            _titleLabel.glowSize = glowSize;
            _maskTitleLabel.glowSize = glowSize;
        }
        
        _titleLabel.font = [UIFont themeFontRegular:[TTCategorySelectorView channelFontSizeWithStyle:aStyle tabType:tabType]];
        
        _maskTitleLabel.font = [UIFont themeFontSemibold:[TTCategorySelectorView channelFontSizeWithStyle:aStyle tabType:tabType]];
        
        [self addSubview:_maskTitleLabel];
        [self addSubview:_bottomSelectView];
        
        if (![SSCommonLogic isNewLaunchOptimizeEnabled]) {
            [_maskTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(themeChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)setCategoryModel:(TTCategory *)categoryModel
{
    if(_categoryModel != categoryModel)
    {
        [_categoryModel removeObserver:self forKeyPath:@"tipNew"];
        _categoryModel = categoryModel;
        if(_categoryModel)
        {
            [_categoryModel addObserver:self forKeyPath:@"tipNew" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (TTCategory*)categoryModel
{
    return _categoryModel;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"tipNew"])
    {
        BOOL show = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        BOOL hasNotifyPoint = [[TTCategoryBadgeNumberManager sharedManager] hasNotifyPointOfCategoryID:_categoryModel.categoryID];
        NSUInteger badgeNumber = [[TTCategoryBadgeNumberManager sharedManager] badgeNumberOfCategoryID:_categoryModel.categoryID];
        [self showPoint:show||hasNotifyPoint badgeNumber:badgeNumber style:_style];
        if (_delegate) {
            [_delegate categoryTipNewChangedOfCategoryID:_categoryModel.categoryID withTipNew:show];
        }
    }
}


- (void)setText:(NSString*)text
{
    
    BOOL categoryNameChanged = ![text isEqualToString:_titleLabel.text];
    
    _titleLabel.text = text;
    _maskTitleLabel.text = text;
    
    if (self.categoryModel.cachedSize && categoryNameChanged) {
        CGSize size = [_titleLabel sizeThatFits:CGSizeMake(200, 30)];
        self.categoryModel.cachedSize = [NSValue valueWithCGSize:size];
        [self.categoryModel save];
    }
}

- (NSString*)text
{
    return _titleLabel.text;
}

- (void)tapped:(UIGestureRecognizer*)recognizer
{
    if(_delegate)
    {
        [_delegate buttonTapped:self];
    }
}

- (void)sizeToFit
{
    CGSize size = CGSizeZero;
    if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue]) {
        BOOL categoryNameRemained = [_titleLabel.text isEqualToString:[self.categoryModel adjustDisplayName]];
        if (self.categoryModel.cachedSize && categoryNameRemained ) {
            size = self.categoryModel.cachedSize.CGSizeValue;
        }
        else {
            NSString *newCategoryName = [self.categoryModel adjustDisplayName];
            [self setText:newCategoryName];
            size = [_titleLabel sizeThatFits:CGSizeMake(200, 30)];
            self.categoryModel.cachedSize = [NSValue valueWithCGSize:size];
            [self.categoryModel save];
        }
    }else{
        size = [_titleLabel sizeThatFits:CGSizeMake(200, 30)];
    }
    CGRect rect = self.frame;
    rect.size.width = size.width;
    self.frame = rect;
}

- (void)updateBottomSelectFrame
{
    CGRect rect = self.frame;
    CGFloat bottomLeft = 0;
    CGFloat bottomWidth = 20;
    if (rect.size.width - 20 > 0) {
        bottomLeft = (rect.size.width - 20)/2.0f;
    }else
    {
        bottomLeft = 0;
        bottomWidth = rect.size.width;
    }
    self.bottomSelectView.frame = CGRectMake(bottomLeft, rect.size.height - 3, bottomWidth, 3);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([SSCommonLogic isNewLaunchOptimizeEnabled]) {
        _titleLabel.bounds = self.bounds;
        _titleLabel.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
        _maskTitleLabel.bounds = self.bounds;
        _maskTitleLabel.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
        _bottomSelectView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);

    }
    [self updateBadgeViewFrame];
}

- (void)updateBadgeViewFrame
{
    CGFloat left = 0;
    CGFloat top = 0;
    if (TTBadgeNumberPoint == self.badgeView.badgeNumber) {
        left = self.width - 11.f;
        top = 9.f;
    }else {
        left = self.width - 13.f;
        top = 8.f;
    }
    self.badgeView.left = left;
    self.badgeView.top = top;
}

static BOOL bNeedTrackFollowCategoryPointLog = YES;
static BOOL bNeedTrackFollowCategoryBadgeLog = YES;

- (void)showPoint:(BOOL)showPoint badgeNumber:(NSUInteger)badgeNumber style:(TTCategorySelectorViewStyle)style
{
    if (showPoint || badgeNumber > 0) {
        if (!self.badgeView) {
            self.badgeView = [[TTBadgeNumberView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
            if (self.style == TTCategorySelectorViewWhiteStyle) {
                self.badgeView.badgeViewStyle = TTBadgeNumberViewStyleWhite;
            }else{
                self.badgeView.badgeViewStyle = TTBadgeNumberViewStyleDefaultWithBorder;
            }
            [self addSubview:self.badgeView];
        }
        if (badgeNumber > 0) {
            if (badgeNumber > 99) {
                self.badgeView.badgeNumber = TTBadgeNumberMore;
            }else {
                self.badgeView.badgeNumber = badgeNumber;
            }
            
        }else {
            self.badgeView.badgeNumber = TTBadgeNumberPoint;
        }
        [self updateBadgeViewFrame];
    } else {
        [self.badgeView removeFromSuperview];
        self.badgeView = nil;
    }
    
    
    if ([_categoryModel.categoryID isEqualToString:kTTFollowCategoryID] && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (badgeNumber > 0) { //优先显示数字
            if (bNeedTrackFollowCategoryBadgeLog) {
                [TTTrackerWrapper eventV3:@"show_red_number" params:@{@"categroy_name" : kTTFollowCategoryID}];
                bNeedTrackFollowCategoryBadgeLog = NO;
            }
        } else if (showPoint){ //其次显示红点
            if (bNeedTrackFollowCategoryPointLog) {
                [TTTrackerWrapper eventV3:@"show_red_dot" params:@{@"categroy_name" : kTTFollowCategoryID}];
                bNeedTrackFollowCategoryPointLog = NO;
            }
        }
        if (badgeNumber <= 0) { //某一次开始数字被清零，那下一次再显示数字要上报埋点
            bNeedTrackFollowCategoryBadgeLog = YES;
        }
        if (!showPoint) { //某一次红点被清掉，下一次出现红点需要上报埋点
            bNeedTrackFollowCategoryPointLog = YES;
        }
        
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kCategoryBadgeChangeNotification object:self];
}

#pragma mark -- Notification

- (void)themeChanged:(NSNotification *)notification {
    if (self.textColors.count == 4) {
        UIColor *normalColor = [UIColor colorWithDayColorName:self.textColors[0] nightColorName:self.textColors[1]];
        UIColor *hightlightedColor = [UIColor colorWithDayColorName:self.textColors[2] nightColorName:self.textColors[3]];
        _titleLabel.textColor = normalColor;
        _maskTitleLabel.textColor = hightlightedColor;
    }
    
    if (self.textGlowColors.count == 4 && self.textGlowSize > 0) {
        UIColor *normalColor = [UIColor colorWithDayColorName:self.textGlowColors[0] nightColorName:self.textGlowColors[1]];
        UIColor *hightlightedColor = [UIColor colorWithDayColorName:self.textGlowColors[2] nightColorName:self.textGlowColors[3]];
        _titleLabel.glowColor = normalColor;
        _maskTitleLabel.glowColor = hightlightedColor;
    }
}

@end

@interface TTCategorySelectorView()<UIScrollViewDelegate, CategorySelectorButtonDelegate, TTCategoryBadgeNumberManagerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) CategorySelectorButton *lastSelectedButton;
@property (nonatomic, strong) NSMutableArray *categoryViews;
@property (nonatomic, strong) TTAlphaThemedButton *expandButton;
@property (nonatomic, strong) TTAlphaThemedButton *searchButton;
//@property (nonatomic, strong) UIButton *manageButton;
@property (nonatomic, assign) TTCategorySelectorViewStyle style;
@property (nonatomic, assign) TTCategorySelectorViewTabType tabType;
@property (nonatomic, strong) SSThemedImageView *rightBorderIndicatorView;
@property (nonatomic, strong) TTBadgeNumberView *hasNewCategoryBadgeView;
@property (nonatomic, strong) NSString *cacheNewCategoryID;
@property (nonatomic, strong) SSThemedView *bottomLineView;
@property (nonatomic, assign) CGFloat lastContentOffset;
//@property (nonatomic, strong) SSThemedView * padMaskView;
// 保存所有带红点并且点击后自动消失的category的Id
@property (nonatomic, strong) NSMutableOrderedSet *categoryClickAutoDismissBadgeSet;
// videotab
@property (nonatomic, strong) CALayer *rightBackLayer;
@property (nonatomic, strong) CAGradientLayer *rightGradientLayer;

@end

@implementation TTCategorySelectorView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.hasNewCategoryBadgeView = nil;
    self.rightBorderIndicatorView = nil;
    self.scrollView = nil;
    self.lastSelectedButton = nil;
    self.categories = nil;
    self.delegate = nil;
    self.expandButton = nil;
    self.categoryViews = nil;
//    self.manageButton = nil;
    self.bottomLineView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
                        style:(TTCategorySelectorViewStyle)style
                      tabType:(TTCategorySelectorViewTabType)tabType
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.style = style;
        self.tabType = tabType;
        
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.scrollsToTop = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.delegate = self;
        if (@available(ios 11.0, *)){
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:self.scrollView];
        self.categoryViews = [NSMutableArray arrayWithCapacity:10];
        
        self.expandButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        self.expandButton.enableHighlightAnim = YES;
        [self.expandButton addTarget:self action:@selector(expandButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.expandButton.backgroundColor = [UIColor clearColor];
        [self refreshExpandButton:nil];
        
        self.searchButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        self.searchButton.enableHighlightAnim = YES;
        [self.searchButton addTarget:self action:@selector(searchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.searchButton.backgroundColor = [UIColor clearColor];
        [self refreshExpandButton:nil];

        self.rightBorderIndicatorView = [[SSThemedImageView alloc] init];
        
        if (style == TTCategorySelectorViewWhiteStyle) {
            self.rightBorderIndicatorView.imageName = @"shadow_add_titlebar.png";
        } else if (style == TTCategorySelectorViewVideoStyle) {
            UIColor *color = [UIColor tt_themedColorForKey:kColorBackground4];
            if ([TTDeviceHelper isPadDevice]) {
                color = [UIColor tt_themedColorForKey:kColorBackground3];
            }
            self.rightBackLayer = [CALayer layer];
            self.rightBackLayer.backgroundColor = color.CGColor;
            [self.rightBorderIndicatorView.layer addSublayer:self.rightBackLayer];
            self.rightGradientLayer = [CAGradientLayer layer];
            if (color) {
                self.rightGradientLayer.colors = @[(__bridge id)[color colorWithAlphaComponent:0].CGColor, (__bridge id)[color colorWithAlphaComponent:1].CGColor];
            }
            self.rightGradientLayer.startPoint = CGPointMake(0, 0.5);
            self.rightGradientLayer.endPoint = CGPointMake(1, 0.5);
            [self.rightBorderIndicatorView.layer addSublayer:self.rightGradientLayer];
        } else if (style == TTCategorySelectorViewLightStyle || style == TTCategorySelectorViewNewVideoStyle) {
            self.rightBorderIndicatorView.imageName = @"shadow_add_titlebar_new3.png";
        }
        else {
            self.rightBorderIndicatorView.imageName = @"shadow_addolder_titlebar.png";
        }
        
        self.rightBorderIndicatorView.backgroundColor = [UIColor clearColor];
        
        if (style == TTCategorySelectorViewBlackStyle) {
            
            self.bottomLineView = [[SSThemedView alloc] init];
            self.bottomLineView.backgroundColors = @[@"dddddd", @"464646"];
            
            [self addSubview:self.bottomLineView];
            
            [self setBottomLineFrame];
            
            self.backgroundColorThemeKey = kColorBackground3;
        } else if (style == TTCategorySelectorViewVideoStyle) {
            if ([TTDeviceHelper isPadDevice]) {
                self.bottomLineView = [[SSThemedView alloc] init];
                self.bottomLineView.backgroundColors = @[@"dddddd", @"464646"];
                
                [self addSubview:self.bottomLineView];
                
                [self setBottomLineFrame];

                self.backgroundColorThemeKey = kColorBackground3;
            } else {
                self.backgroundColorThemeKey = kColorBackground4;
            }
        } else if (style == TTCategorySelectorViewLightStyle || style == TTCategorySelectorViewNewVideoStyle) {
            self.bottomLineView = [[SSThemedView alloc] init];
            self.bottomLineView.backgroundColorThemeKey = kColorLine1;
            
            [self addSubview:self.bottomLineView];
            
            [self setBottomLineFrame];

            self.backgroundColorThemeKey = kColorBackground4;
        }
        
        [self addSubview:self.rightBorderIndicatorView];
        [self addSubview:self.searchButton]; //search图片四周用很多空白，所以用expandButton覆盖
        [self addSubview:self.expandButton];

        
        [self reloadThemeUI];
        
        [self changeHasNewCategoryBadge:nil];
        
        [self bringSubviewToFront:self.bottomLineView];
        
        if (self.tabType == TTCategorySelectorViewNewsTab) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeHasNewCategoryBadge:) name:kArticleCategoryTipNewChangedNotification object:nil];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeHasNewCategoryBadge:) name:kCategoryBadgeChangeNotification object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCategory:) name:kCategoryManagementViewCategorySelectedNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryViewWillHidden:) name:kCategoryManagerViewWillHideNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInsertCategoryIntoLastVisiblePosition:) name:kTTInsertCategoryToLastPositionNotification object:nil];
            
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBadgeRefreshedNotification:) name:kArticleBadgeManagerRefreshedNotification object:nil];
            
            
            ///...
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFeedRefreshADImages:) name:kArticleCategoryHasChangeNotification object:nil];
        }
        
        self.categoryClickAutoDismissBadgeSet = [[NSMutableOrderedSet alloc] init];
        
        if (TTCategorySelectorViewNewsTab == self.tabType) {
            [[TTCategoryBadgeNumberManager sharedManager] setDelegate:self];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryRefresh:) name:@"kCategoryRefresh" object:nil];
    }
    
    return self;
}

- (void)setBottomLineFrame
{
    if (![SSCommonLogic isNewLaunchOptimizeEnabled]) {
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
}

- (void)layoutSubviews
{
    if ([NSThread isMainThread]) {
        [self didDoLayoutSubViews];
    } else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didDoLayoutSubViews];
        });
    }
}

- (void)didDoLayoutSubViews
{
    if ([SSCommonLogic isNewLaunchOptimizeEnabled]) {
        self.bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - [TTDeviceHelper ssOnePixel], CGRectGetWidth(self.bounds), [TTDeviceHelper ssOnePixel]);
    }
    if ([TTDeviceHelper isPadDevice]) {
        self.scrollView.frame = CGRectInset(self.bounds, [TTUIResponderHelper paddingForViewWidth:0], 0);
        self.scrollView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, self.scrollView.center.y);
//        if (self.padMaskView == nil) {
//            self.padMaskView = [[SSThemedView alloc] initWithFrame:CGRectMake([TTUIResponderHelper paddingForViewWidth:0] - 15, 0, 30, self.bounds.size.height-1)];
//            self.padMaskView.backgroundColorThemeKey = kColorBackground3;
//            self.padMaskView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//            [self addSubview:self.padMaskView];
//        }
//        self.padMaskView.frame = CGRectMake([TTUIResponderHelper paddingForViewWidth:0] - 15, 0, 30, self.bounds.size.height-1);
    }
    else {
        CGRect rect = self.bounds;
        //fix:iOS7下进入图集横屏后pop导致频道栏消失的问题
        if ([TTDeviceHelper OSVersionNumber] < 8.f) {
            rect.size.width = [TTUIResponderHelper screenSize].width;
        }
        self.scrollView.frame = rect;
    }
    CGRect viewFrame = self.rightBorderIndicatorView.frame;
    viewFrame.size.width = (self.tabType == TTCategoryModelTopTypeVideo ? 44 : 52);
    viewFrame.size.height = self.height;
    viewFrame.origin.x = self.scrollView.right - viewFrame.size.width;
    viewFrame.origin.y = 0;
    
    [self refreshExpandButton:nil];
    [self refreshSelectorView];
    [self scrollToCategory:self.currentSelectedCategory];
    
    self.rightBorderIndicatorView.frame = viewFrame;
    self.rightBackLayer.frame = self.rightBorderIndicatorView.bounds;
    self.rightGradientLayer.frame = CGRectMake(-24, 0, 24, self.rightBorderIndicatorView.height);
    
    [super layoutSubviews];
}

- (void)hideExpandButton
{
    self.expandButton.hidden = YES;
    self.rightBorderIndicatorView.hidden = YES;
}


- (NSString *)categoryId
{
    return self.currentSelectedCategory.categoryID;
}

+ (CGFloat)channelFontSizeWithStyle:(TTCategorySelectorViewStyle)style tabType:(TTCategorySelectorViewTabType)tabType{
    if ([TTDeviceHelper isPadDevice]) {
        return 16.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 16.f;
    } else if ([TTDeviceHelper is667Screen]) {
        return 16.f;
    }else if ([TTDeviceHelper isIPhoneXDevice]) {
        return 16.f;
    } else {
        return 13.f;
    }
}

+ (CGFloat)channelSelectedFontSizeWithStyle:(TTCategorySelectorViewStyle)style tabType:(TTCategorySelectorViewTabType)tabType{
    if ([TTDeviceHelper isPadDevice]) {
        return 15.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 16.f;
    }else if ([TTDeviceHelper isIPhoneXDevice]) {
        return 16.f;
    }else if ([TTDeviceHelper is667Screen]) {
        return 16.f;
    } else {
        return 13.f;
    }
}

- (void)refreshExpandButton:(NSNotification *)notification
{
    UIImage * tmpImage = nil;
    
    switch (self.style) {
        case TTCategorySelectorViewBlackStyle:
        {
            if ([TTDeviceHelper isPadDevice]) {
                _expandButton.imageName = @"add_channel_titlbar";
            }else{
                _expandButton.imageName = @"add_channel_titlbar_thin";
            }
            _searchButton.imageName = @"white_search_titlebar";
            
        }
            break;
        case TTCategorySelectorViewWhiteStyle:
        {
            _expandButton.imageName = @"add_channel_titlbar_thin";
            _searchButton.imageName = @"white_search_titlebar";
            
        }
            break;
        case TTCategorySelectorViewVideoStyle:
        {
            _expandButton.imageName = @"Search";
        }
            break;
        case TTCategorySelectorViewLightStyle:
        {
            _expandButton.imageName = @"add_channel_titlbar_thin_new";
        }
            break;
        default:
            break;
    }
    
    if ([TTDeviceHelper isPadDevice]) {
        tmpImage = [UIImage themedImageNamed:@"add_channel_titlbar"];
    }else{
        tmpImage = [UIImage themedImageNamed:@"add_channel_titlbar_thin"];
    }
    
    
    //熊孜要求搜索按钮与频道展开按钮都是正方形，宽高均定于CategorySelector的高度
    if (self.style == TTCategorySelectorViewVideoStyle || [TTDeviceHelper isPadDevice]) {
        //视频样式单独处理
        self.expandButton.right = self.scrollView.right;
        self.expandButton.top = 0;
        self.expandButton.width = tmpImage.size.width + 10 * 2 + ([TTDeviceHelper isPadDevice]? 0 : [TTDeviceHelper is736Screen]? 4 : 4);
        self.expandButton.height = self.height;
        self.rightBorderIndicatorView.width = self.expandButton.width + ([TTDeviceHelper isPadDevice]? 4 : 8);
        self.rightBorderIndicatorView.right = self.scrollView.right + 1;
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, self.expandButton.hidden ? 0 : self.expandButton.width + 10);
    } else {
        if (self.style == TTCategorySelectorViewNewVideoStyle || [SSCommonLogic feedCaregoryAddHiddenEnable]){
            self.searchButton.hidden = YES;
            self.expandButton.hidden = YES;
            self.rightBorderIndicatorView.hidden = YES;
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            return;
        }
        
        self.searchButton.hidden = YES;
        
        self.expandButton.right = self.searchButton.hidden == NO ? self.searchButton.left : self.scrollView.right;
        self.expandButton.top = 0;
        self.expandButton.width = tmpImage.size.width + 16;
        self.expandButton.height = self.height;
        
        self.rightBorderIndicatorView.width = self.scrollView.right - self.expandButton.left + (self.searchButton.hidden == NO ? 18 : 10);
        if (self.style == TTCategorySelectorViewLightStyle) {
            self.rightBorderIndicatorView.width = 52;
            self.expandButton.right = self.scrollView.right - 6;
        }
        self.rightBorderIndicatorView.right = self.scrollView.right;
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, self.expandButton.hidden ? 5 : self.rightBorderIndicatorView.width);
    }
}

//- (CategorySelectorButton *)getSubscribeButton
//{
//    for (CategorySelectorButton * button in _categoryViews)
//    {
//        if ([button.categoryModel.categoryID isEqualToString:kTTSubscribeCategoryID])
//        {
//            return button;
//        }
//    }
//    
//    return nil;
//}

//- (void)receiveBadgeRefreshedNotification:(NSNotification*)notification
//{
//    // luohuaqing: 当前只处理“订阅频道”
//    CategorySelectorButton * subscribeButton = [self getSubscribeButton];
//    if (subscribeButton)
//    {
//        if ([[ArticleBadgeManager shareManger].subscribeHasNewUpdatesIndicator boolValue])
//        {
//            if (![subscribeButton hasShownBadge])
//            {
//                [subscribeButton showBadge:YES style:_style];
//                [_categoryBadgeSet addObject:kTTSubscribeCategoryID];
//            }
//        }
//        else
//        {
//            if ([subscribeButton hasShownBadge])
//            {
//                [subscribeButton showBadge:NO style:_style];
//                [_categoryBadgeSet removeObject:kTTSubscribeCategoryID];
//            }
//        }
//    }
//}

- (void)changeCategory:(NSNotification*)notification
{
    TTCategory *category = [[notification userInfo] objectForKey:@"model"];
    if(category)
    {
        NSUInteger idx = [_categories indexOfObject:category];
        if(idx != NSNotFound && idx < _categories.count)
        {
            TTCategory *category = [_categories objectAtIndex:idx];
            if(_delegate)
            {
                [_delegate categorySelectorView:self selectCategory:category];
            }
            
            [self selectCategory:category];
        }
    }
}

-(void)categoryViewWillHidden:(NSNotification *)notification{
    if (_delegate && [_delegate respondsToSelector:@selector(categorySelectorView:closeCategoryView:)]) {
        [_delegate categorySelectorView:self closeCategoryView:YES];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [self refreshChannelButtonUI];
    UIColor *color = [UIColor tt_themedColorForKey:kColorBackground4];
    if ([TTDeviceHelper isPadDevice]) {
        color = [UIColor tt_themedColorForKey:kColorBackground3];
    }
    if (color) {
        self.rightBackLayer.backgroundColor = color.CGColor;
        self.rightGradientLayer.colors = @[(__bridge id)[color colorWithAlphaComponent:0].CGColor, (__bridge id)[color colorWithAlphaComponent:1].CGColor];
    }
}

#pragma mark -- CategorySelectorButtonDelegate

- (void)buttonTapped:(CategorySelectorButton *)button
{
    [self categoryClicked:button];
}

- (CGFloat)marginBetweenVisibleLabelAndButton {
    CGFloat margin = 19;
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        margin = 28;
    } else if ([TTDeviceHelper is736Screen]) {
        margin = 28;
    } else if ([TTDeviceHelper isPadDevice]) {
        margin = 25;
    }
    
//    if (self.tabType == TTCategorySelectorViewNewsTab && self.style == TTCategorySelectorViewWhiteStyle)
//    {
//        if ([TTUISettingHelper categoryViewMarginControllable]) {
//            margin = [[TTUISettingHelper sharedInstance_tt] categoryViewMargin];
//        }
//    }
    
    if ((self.tabType == TTCategorySelectorViewNewVideoTab || self.tabType == TTCategorySelectorViewNewsTab) && (self.style == TTCategorySelectorViewLightStyle || self.style == TTCategorySelectorViewNewVideoStyle) && ![TTDeviceHelper isPadDevice])
    {
        margin = 16;
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
            margin = 20;
        } else {
            margin = 16;
        }
    }
    
    if (self.tabType == TTCategoryModelTopTypeVideo) {
        if ([TTDeviceHelper isPadDevice]) {
            margin = 25;
        } else if ([TTDeviceHelper is736Screen]) {
            margin = 19;
        } else if ([TTDeviceHelper isScreenWidthLarge320]) {
            margin = 16;
        } else {
            margin = 15;
        }
    }
    
    return margin;
}

- (void)categoryTipNewChangedOfCategoryID:(NSString *)categoryID withTipNew:(BOOL)tipNew {
    if (!isEmptyString(categoryID)) {
        if (tipNew) {
            [self.categoryClickAutoDismissBadgeSet addObject:categoryID];
        }else {
            [self.categoryClickAutoDismissBadgeSet removeObject:categoryID];
        }
    }
}

- (void)categoryClicked:(CategorySelectorButton*)sender
{
    if (!isEmptyString(sender.categoryModel.categoryID) && [self.categoryClickAutoDismissBadgeSet containsObject:sender.categoryModel.categoryID]) {
        [[self class] trackTipsWithLabel:@"click" position:@"category" style:@"red_tips" categoryID:sender.categoryModel.categoryID];
    }
    [self updateSelectButton:sender];
    NSUInteger idx = [_categoryViews indexOfObject:sender];
    if(idx != NSNotFound && idx < _categories.count)
    {
        TTCategory *category = [_categories objectAtIndex:idx];
        category.tipNew = NO;
        [category save];
        
        if (category.categoryID) {
            TLS_LOG(@"categoryClicked=%@",category.categoryID);
        }
        
        if(_delegate)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixedListRefreshTypeNotification object:self userInfo:@{@"refresh_reason" : @(ExploreMixedListRefreshTypeClickChannel)}];
            [_delegate categorySelectorView:self selectCategory:category];
        }
        [self selectCategory:category];
    }
}

- (void)selectCategory:(TTCategory *)category
{
    self.currentSelectedCategory = category;
    if (category.topCategoryType == TTCategoryModelTopTypeNews) {
        [TTArticleCategoryManager setCurrentSelectedCategoryID:category.categoryID];
        [[NSUserDefaults standardUserDefaults] setValue:category.categoryID forKey:@"kLastSelectCategory"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (category.topCategoryType == TTCategoryModelTopTypeVideo) {
        
        [TTVideoCategoryManager setCurrentSelectedCategoryID:category.categoryID];
    }
    NSInteger idx = [_categories indexOfObject:category];
    if(idx < _categoryViews.count)
    {
        [self.categoryClickAutoDismissBadgeSet removeObject:category.categoryID];
        
        CategorySelectorButton *button = _categoryViews[idx];
        if (button.categoryModel.tipNew) {
            button.categoryModel.tipNew = NO;
            [button.categoryModel save];
        }
        
        [self updateSelectButton:button];
        
        [self scrollToCategory:category];
    }
    
    [self showDialogWhenChangeFeedTabCategory];
}

- (void)showDialogWhenChangeFeedTabCategory
{
    if ([self.currentSelectedCategory.categoryID isEqualToString:kTTNewsLocalCategoryID]) {
//        [CLLocationManager ttdd_showLocationAtLocalChannel];
    }
    
    switch (self.tabType) {
        case TTCategorySelectorViewNewsTab: {
            [TTPushAlertManager enterFeedPage:TTPushWeakAlertPageTypeMainFeed];
        }
            break;
        case TTCategorySelectorViewVideoTab:
        case TTCategorySelectorViewNewVideoTab: {
            [TTPushAlertManager enterFeedPage:TTPushWeakAlertPageTypeWatermelonVideoFeed];
        }
            break;
        case TTCategorySelectorViewPhotoTab: {
            
        }
            break;
        default:
            break;
    }
}

- (void)scrollToCategory:(TTCategory *)category
{
    NSInteger idx = [_categories indexOfObject:category];
    if (idx < _categoryViews.count) {
        
        CategorySelectorButton *button = _categoryViews[idx];
        
        CGFloat offsetX = 0;
        CGFloat distanceFromButtonToCenter = button.centerX - _scrollView.width / 2;
        CGFloat maxOffsetX = MAX(_scrollView.contentSize.width + _scrollView.contentInset.right - _scrollView.width, 0);
        
        if (distanceFromButtonToCenter > 0) {
            offsetX = distanceFromButtonToCenter;
        }
        
        if (offsetX > maxOffsetX) {
            offsetX = maxOffsetX;
        }
        
        [UIView animateWithDuration:0.4 animations:^{
            [_scrollView setContentOffset:CGPointMake(offsetX, 0)];
        }];
    }
}

- (void)updateSelectButton:(CategorySelectorButton*)button
{
    if ([button isEqual:_lastSelectedButton]) {
        return;
    }
    
    for (CategorySelectorButton * btn in _categoryViews) {
        if (btn != button) {
            [self setButtonNormalColor:btn];
        }
    }
    MessageEventManager * messageMgr = [[[EnvContext shared] client] messageManager];

    //判断离开首页推荐频道
    if ([_lastSelectedButton.categoryModel.categoryID isEqualToString:kCategroyDefaulHouse] && ![button.categoryModel.categoryID isEqualToString:kCategroyDefaulHouse]) {
        [messageMgr startSyncCategoryBadge];
    }
    
    if ([button.categoryModel.categoryID isEqualToString:kCategroyDefaulHouse]) {
        [messageMgr stopSyncCategoryBadge];
    }
    
    self.lastSelectedButton = button;
    
    [self setButtonHighlightColor:_lastSelectedButton];
    
    //红点/数字受TTCategoryBadgeNumberManager影响
    BOOL showPoint = [[TTCategoryBadgeNumberManager sharedManager] hasNotifyPointOfCategoryID:_lastSelectedButton.categoryModel.categoryID];
    //判断当前频道是否是首页推荐

    
    
    
    NSUInteger badgeNumber = [[TTCategoryBadgeNumberManager sharedManager] badgeNumberOfCategoryID:_lastSelectedButton.categoryModel.categoryID];
    [_lastSelectedButton showPoint:showPoint badgeNumber:badgeNumber style:_style];
    [_categoryClickAutoDismissBadgeSet removeObject:_lastSelectedButton.categoryModel.categoryID];
}

//- (void)expandButtonClicked:(id)sender
//{
//    if(sender) {
//        if ([self.delegate respondsToSelector:@selector(categorySelectorView:didClickExpandButton:)]) {
//            [self.delegate categorySelectorView:self didClickExpandButton:sender];
//        }
//    }
//    if (!isEmptyString(self.cacheNewCategoryID) && self.hasNewCategoryBadgeView) {
//        [[self class] trackTipsWithLabel:@"click" position:@"channel_management" style:@"red_tips" categoryID:self.cacheNewCategoryID];
//    }
//    [self removeClickAutoDismissBadges];
//}

- (void)searchButtonClicked:(id)sender
{
    if(sender) {
        if ([self.delegate respondsToSelector:@selector(categorySelectorView:didClickSearchButton:)]) {
            [self.delegate categorySelectorView:self didClickSearchButton:sender];
        }
    }
}

- (void)categoryRefresh:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshSelectorView];
    });
}

- (void)refreshWithCategories:(NSArray*)categories_
{
    self.categories = categories_;
    [self refreshSelectorView];
    [self refreshBorderIndicator];
}

- (void)refreshSelectorView
{
    if ([SSCommonLogic isNewLaunchOptimizeEnabled]) {
        //启动首次调用时，width和height为0，此时不计算SelectorView，节约启动时间
        if (self.width == 0 || self.height == 0) {
            return;
        }
    }
    
    NSInteger idx = 0;
    CGFloat offsetX = 10;
    
    BOOL isContainFollowCategory = NO;
    
    self.scrollView.height = self.height;
    for(; idx < _categories.count; idx ++)
    {
        TTCategory *category = _categories[idx];
        if ([category.categoryID isEqualToString:kTTFollowCategoryID]) {
            isContainFollowCategory = YES;
        }
        
        if(idx >= _categoryViews.count)
        {
            //TODO:Jason 颜色动态配
            NSArray<NSString *> *textColors = nil;
            NSArray<NSString *> *textGlowColors = nil;
            CGFloat glowSize = 0;
            if ([self.delegate respondsToSelector:@selector(categorySelectorTextColors)]) {
                textColors = [self.delegate categorySelectorTextColors];
            }

            if ([self.delegate respondsToSelector:@selector(categorySelectorTextGlowColors)]) {
                textGlowColors = [self.delegate categorySelectorTextGlowColors];
            }

            if ([self.delegate respondsToSelector:@selector(categorySelectorTextGlowSize)]) {
                glowSize = [self.delegate categorySelectorTextGlowSize];
            }
            
            CategorySelectorButton *categoryButton = [[CategorySelectorButton alloc] initWithFrame:CGRectZero style:self.style tabType:self.tabType textColors:textColors textGlowColors:textGlowColors textGlowSize:glowSize];
            categoryButton.delegate = self;
            
            [_categoryViews addObject:categoryButton];
        }
        
        CategorySelectorButton *categoryButton = [_categoryViews objectAtIndex:idx];
        categoryButton.categoryModel = category;
        [categoryButton setText:[category adjustDisplayName]];
        categoryButton.frame = CGRectMake(0, 0, 0, self.height);
        [categoryButton sizeToFit];
        
        CGRect buttonFrame = categoryButton.frame;
        buttonFrame.size.width += [self marginBetweenVisibleLabelAndButton];
        categoryButton.frame = buttonFrame;
        
        categoryButton.left = offsetX;
        [categoryButton updateBottomSelectFrame];
        [self.scrollView addSubview:categoryButton];
        
        offsetX = categoryButton.right + 10;
        
        NSString *startCategoryID = kTTMainCategoryID;
        if (!_lastSelectedButton && [SSCommonLogic firstCategoryStyle] > 0) {
            NSInteger type = [SSCommonLogic firstCategoryStyle];
            if (type == 1) {
                startCategoryID = [[NSUserDefaults standardUserDefaults] valueForKey:@"kLastSelectCategory"];
                if (!startCategoryID) {
                    startCategoryID = kTTMainCategoryID;
                }
            }
            if (type == 2) {
                startCategoryID = [SSCommonLogic feedStartCategory];
                if (!startCategoryID) {
                    startCategoryID = kTTMainCategoryID;
                }
            }
            
            if (![startCategoryID isEqualToString:kTTMainCategoryID]) {
                startCategoryID = self.currentSelectedCategory.categoryID;
            }
        }
        
        if(!_lastSelectedButton && [category.categoryID isEqualToString:startCategoryID])
        {
            [self setButtonHighlightColor:categoryButton];
            self.lastSelectedButton = categoryButton;
        } else if (_lastSelectedButton != categoryButton) {
            [self setButtonNormalColor:categoryButton];
        }
        
        //红点/数字受categoryClickAutoDismissBadgeSet和TTCategoryBadgeNumberManager影响
        BOOL autoDismissBadge = [self.categoryClickAutoDismissBadgeSet containsObject:categoryButton.categoryModel.categoryID];
        BOOL hasNotifyPoint = [[TTCategoryBadgeNumberManager sharedManager] hasNotifyPointOfCategoryID:category.categoryID];
        NSUInteger badgeNumber = [[TTCategoryBadgeNumberManager sharedManager] badgeNumberOfCategoryID:category.categoryID];
        [categoryButton showPoint:autoDismissBadge||hasNotifyPoint badgeNumber:badgeNumber style:_style];
    }
    
    self.scrollView.contentSize = CGSizeMake(offsetX, self.height);
    self.scrollView.alwaysBounceHorizontal = YES;
    NSInteger originalCnt = _categoryViews.count;
    NSMutableArray *toBeRemoved = [NSMutableArray arrayWithCapacity:originalCnt];
    
    for(; idx < originalCnt; idx ++)
    {
        UIView *categoryView = [_categoryViews objectAtIndex:idx];
        [categoryView removeFromSuperview];
        [toBeRemoved addObject:categoryView];
    }
    
    [_categoryViews removeObjectsInArray:toBeRemoved];
    [self changeHasNewCategoryBadge:nil];
    
    if (self.tabType == TTCategorySelectorViewNewsTab || self.tabType == TTCategorySelectorViewVideoTab || self.tabType == TTCategorySelectorViewNewVideoTab) {
        if (isContainFollowCategory) {
            [[TTInfiniteLoopFetchNewsListRefreshTipManager sharedManager] startInfiniteLoopFetchFollowChannelRefreshTip];
        }
        
        // 策略首页没有关注频道，则视频小视频也不会有，可以直接stop
        if (self.tabType == TTCategorySelectorViewNewsTab && !isContainFollowCategory) {
            [[TTInfiniteLoopFetchNewsListRefreshTipManager sharedManager] stopInfiniteLoopFetchFollowChannelRefreshTip];
        }
        
        //Category selector view 布局刷新，关注频道的位置可能发生变化，发送该通知使得消息提醒的badge number出现在正确的位置
        //消息提醒的badge number可能出现在关注频道也可能出现在top bar的头像上（或者第四个tab）
        [[NSNotificationCenter defaultCenter] postNotificationName:kArticleBadgeManagerRefreshedNotification
                                                            object:self
                                                          userInfo:nil];
    }
    if (self.lastSelectedButton == nil && self.currentSelectedCategory) {
        [self selectCategory:self.currentSelectedCategory];
    }
}

- (void)setButtonNormalColor:(CategorySelectorButton *)button
{
    [UIView animateWithDuration:.3 animations:^{
        button.titleLabel.alpha = ((self.style == TTCategorySelectorViewWhiteStyle) ? 0.76 : 1);
        button.maskTitleLabel.alpha = 0;
        button.titleLabel.transform = CGAffineTransformIdentity;
        button.maskTitleLabel.transform = CGAffineTransformIdentity;
        button.bottomSelectView.alpha = 0;
    }];
}

- (void)setButtonHighlightColor:(CategorySelectorButton *)button
{
    [UIView animateWithDuration:.3 animations:^{
        button.titleLabel.alpha = 0;
        button.maskTitleLabel.alpha = 1;
        CGFloat scale = [[self class] channelSelectedFontSizeWithStyle:self.style tabType:self.tabType] / [[self class] channelFontSizeWithStyle:self.style tabType:self.tabType];
        button.titleLabel.transform = CGAffineTransformMakeScale(scale, scale);
        button.maskTitleLabel.transform = CGAffineTransformMakeScale(scale, scale);
        button.bottomSelectView.alpha = 1;
    }];
}

- (void)refreshBorderIndicator
{
    if (self.scrollView.contentOffset.x >= (self.scrollView.contentSize.width - self.scrollView.frame.size.width - 10)) {
//                if (!_rightBorderIndicatorView.hidden) {
//                    _rightBorderIndicatorView.hidden = YES;
//                }
    }
    else {
//                if (_rightBorderIndicatorView.hidden) {
//                    _rightBorderIndicatorView.hidden = NO;
//                }
    }
}

- (float)categoryButtonOffsetY
{
    return 3;
}

- (void)refreshChannelButtonUI
{
    for (CategorySelectorButton * button in _categoryViews) {
        if (button == _lastSelectedButton) {
            [self setButtonHighlightColor:button];
        }
        else {
            [self setButtonNormalColor:button];
        }
    }
}

- (void)moveSelectFrameFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex percentage:(CGFloat)percentage
{
    if(fromIndex < _categoryViews.count && toIndex < _categoryViews.count && fromIndex >= 0 && toIndex >= 0 && fromIndex != toIndex)
    {

        CategorySelectorButton *fromButton = _categoryViews[fromIndex];
        CategorySelectorButton *toButton = _categoryViews[toIndex];

        CGFloat transformScaleDelta = ([[self class] channelSelectedFontSizeWithStyle:self.style tabType:self.tabType] / [[self class] channelFontSizeWithStyle:self.style tabType:self.tabType] - 1);
        CGFloat percent = fabs(percentage);

        percent = MIN(1, MAX(0, percent));

        CGFloat fromScale = 1 + transformScaleDelta * (1 - percent);
        CGFloat toScale = 1 + transformScaleDelta * percent;
    
        fromButton.titleLabel.transform = CGAffineTransformMakeScale(fromScale, fromScale);
        toButton.titleLabel.transform = CGAffineTransformMakeScale(toScale, toScale);

        fromButton.maskTitleLabel.transform = fromButton.titleLabel.transform;
        toButton.maskTitleLabel.transform = toButton.titleLabel.transform;
        
        fromButton.titleLabel.alpha = percent * ((self.style == TTCategorySelectorViewWhiteStyle) ? 0.76 : 1);
        toButton.titleLabel.alpha = (1 - percent) * ((self.style == TTCategorySelectorViewWhiteStyle) ? 0.76 : 1);

        fromButton.maskTitleLabel.alpha = 1 - percent;
        toButton.maskTitleLabel.alpha = percent;
        fromButton.bottomSelectView.alpha = 1 - percent;
        toButton.bottomSelectView.alpha = percent;
    }
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self refreshBorderIndicator];
        [self trackFlipEvent:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self refreshBorderIndicator];
    [self trackFlipEvent:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self refreshBorderIndicator];
    [self trackFlipEvent:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self refreshBorderIndicator];
    
    [_categoryViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[CategorySelectorButton class]]) {
            CategorySelectorButton *button = (CategorySelectorButton *)obj;
            if (!isEmptyString(button.categoryModel.categoryID) && [self.categoryClickAutoDismissBadgeSet containsObject:button.categoryModel.categoryID] && button.isTrackForShow) {
                if(button.right - _scrollView.contentOffset.x - 6 < _scrollView.width)
                {
                    [[self class] trackTipsWithLabel:@"show" position:@"category" style:@"red_tips" categoryID:button.categoryModel.categoryID];
                    button.isTrackForShow = NO;
                }
            }
        }
    }];
    // 根据产品需求，滑动不需要考虑
    //    [self changeHasNewCategoryBadge:nil];
}


- (void)trackFlipEvent:(UIScrollView *)scrollView
{
    if (_lastContentOffset < scrollView.contentOffset.x) {
        // 导航栏向左拖动
        wrapperTrackEvent(@"channel_manage", @"flip_left");
    } else if (_lastContentOffset > scrollView.contentOffset.x) {
        // 导航栏向右拖动
        wrapperTrackEvent(@"channel_manage", @"flip_right");
    }
}

#pragma mark -- kArticleCategoryTipNewChangedNotification
- (void)changeHasNewCategoryBadge:(NSNotification*)notification
{
    __block BOOL showBadge = NO;
    __block NSString *categoryID = nil;
    [_scrollView.subviews enumerateObjectsUsingBlock:^(id subview, NSUInteger idx, BOOL *stop) {
        if([subview isKindOfClass:[CategorySelectorButton class]])
        {
            CategorySelectorButton *button = (CategorySelectorButton*)subview;
            if(_scrollView.width > 0 && button.right - _scrollView.contentOffset.x - 6 > _scrollView.width)
            {
                if(!isEmptyString(button.categoryModel.categoryID) && [self.categoryClickAutoDismissBadgeSet containsObject:button.categoryModel.categoryID])
                {
                    showBadge = YES;
                    categoryID = button.categoryModel.categoryID;
                    *stop = YES;
                }
            }
        }
    }];
    
    [self showTipNewBadge:showBadge categoryID:categoryID];
}

- (void)showTipNewBadge:(BOOL)showBadge categoryID:(NSString *)categoryID
{
    if(showBadge)
    {
        if(!_hasNewCategoryBadgeView)
        {
            self.hasNewCategoryBadgeView = [[TTBadgeNumberView alloc] initWithFrame:CGRectMake(20, 9, 4, 4)];
            
        }
        if (self.style == TTBadgeNumberViewStyleWhite) {
            _hasNewCategoryBadgeView.badgeViewStyle = TTBadgeNumberViewStyleWhite;
            _hasNewCategoryBadgeView.badgeNumber = TTBadgeNumberPoint;
        }
        else {
            _hasNewCategoryBadgeView.badgeViewStyle = TTBadgeNumberViewStyleDefault;
            _hasNewCategoryBadgeView.badgeNumber = TTBadgeNumberPoint;
        }
        
        if (self.style != TTCategorySelectorViewVideoStyle && self.style != TTCategorySelectorViewNewVideoStyle) {
            if (!_hasNewCategoryBadgeView.superview) {
                [[self class] trackTipsWithLabel:@"show" position:@"channel_management" style:@"red_tips" categoryID:categoryID];
            }
            [_expandButton addSubview:_hasNewCategoryBadgeView];
            self.cacheNewCategoryID = categoryID;
        }
    }
    else
    {
        [_hasNewCategoryBadgeView removeFromSuperview];
        self.hasNewCategoryBadgeView = nil;
        self.cacheNewCategoryID = nil;
    }
}

- (void)handleInsertCategoryIntoLastVisiblePosition:(NSNotification*)notification
{
    TTCategory *categoryModel = [[notification userInfo] objectForKey:kTTInsertCategoryNotificationCategoryKey];
    if (categoryModel.topCategoryType != TTCategoryModelTopTypeNews) {
        return;
    }
    
    NSUInteger lastOrderIndex = 1;
    if([[notification userInfo] objectForKey:kTTInsertCategoryNotificationPositionKey])
    {
        lastOrderIndex = [[[notification userInfo] objectForKey:kTTInsertCategoryNotificationPositionKey] intValue];
    }
    else
    {
        for(UIView *subview in _scrollView.subviews)
        {
            if([subview isKindOfClass:[CategorySelectorButton class]])
            {
                if(subview.right <= _scrollView.width)
                {
                    CategorySelectorButton *button = (CategorySelectorButton*)subview;
                    lastOrderIndex = MAX(button.categoryModel.orderIndex, lastOrderIndex);
                }
            }
        }
        
        // Fixed bug XWTT-3707.
        lastOrderIndex = (lastOrderIndex >= 2) ? (lastOrderIndex - 1) : lastOrderIndex;
    }
    
    
    if (![_lastSelectedButton.categoryModel.categoryID isEqualToString:categoryModel.categoryID]) {
        // 新添加的频道显示红点
        [self.categoryClickAutoDismissBadgeSet addObject:categoryModel.categoryID];
        categoryModel.tipNew = YES;
        [TTArticleCategoryManager setHasNewTip:YES];
    } else {
        // 当前频道不显示红点
        [self.categoryClickAutoDismissBadgeSet removeObject:categoryModel.categoryID];
        categoryModel.tipNew = NO;
    }
    [categoryModel save];
    
    NSMutableArray *categories =  [NSMutableArray arrayWithArray:[[TTArticleCategoryManager sharedManager] preFixedAndSubscribeCategories]];
    if([categories containsObject:categoryModel])
    {
        [categories removeObject:categoryModel];
    }
    
    if (lastOrderIndex <= categories.count) {
        [categories insertObject:categoryModel atIndex:lastOrderIndex];
    } else {
        [categories insertObject:categoryModel atIndex:categories.count];
    }
    
    [categories enumerateObjectsUsingBlock:^(TTCategory *category, NSUInteger idx, BOOL *stop) {
        category.orderIndex = idx;
        [category save];
    }];
    
    [[TTArticleCategoryManager sharedManager] subscribe:categoryModel];
    [[TTArticleCategoryManager sharedManager] save];
    [[TTArticleCategoryManager sharedManager] startGetCategory:YES];
    
    //首页跳转到新添加频道
//    if (self.tabType == TTCategorySelectorViewNewsTab) {
//        [self selectCategory:categoryModel];
//        [self.delegate categorySelectorView:self selectCategory:categoryModel];
//    }
    
    ///...
//    [[TTRefreshADManager sharedInstance] fetchRefreshADResourceAndCareExpirationTime:NO];
}

///...
- (void)fetchFeedRefreshADImages:(NSNotification *)notification
{
//    [[TTRefreshADManager sharedInstance] fetchRefreshADResourceAndCareExpirationTime:NO];
}

- (BOOL)isCategoryVisible:(NSString*)categoryID
{
    if (isEmptyString(categoryID)) {
        return NO;
    }
    
    BOOL result = NO;
    
    for (UIView *subview in _scrollView.subviews)
    {
        if([subview isKindOfClass:[CategorySelectorButton class]])
        {
            CategorySelectorButton *button = (CategorySelectorButton*)subview;
            if([button.categoryModel.categoryID isEqualToString:categoryID])
            {
                if(button.right - _scrollView.contentOffset.x < _scrollView.width)
                {
                    result = YES;
                }
                
                break;
            }
        }
    }
    
    return result;
}

- (BOOL)isCategoryInFirstScreen:(NSString*)categoryID
{
    if (isEmptyString(categoryID)) {
        return NO;
    }
    
    BOOL result = NO;
    
    for(UIView *subview in _scrollView.subviews)
    {
        if([subview isKindOfClass:[CategorySelectorButton class]])
        {
            CategorySelectorButton *button = (CategorySelectorButton*)subview;
            if([button.categoryModel.categoryID isEqualToString:categoryID])
            {
                if(button.right <= _scrollView.width)
                {
                    result = YES;
                }
                
                break;
            }
        }
    }
    
    return result;
}

// 频道标签上是否有红点（此处红点指的是点击自动消失的红点）
- (BOOL)isCategoryShowBadge:(NSString *)categoryId {
    if (!isEmptyString(categoryId)) {
        return [self.categoryClickAutoDismissBadgeSet containsObject:categoryId];
    }
    return NO;
}

- (UIView *)categorySelectorButtonByCategoryId:(NSString *)categoryId {
    __block UIView *result = nil;
    
    [_scrollView.subviews enumerateObjectsUsingBlock:^(id subview, NSUInteger idx, BOOL *stop) {
        if([subview isKindOfClass:[CategorySelectorButton class]])
        {
            CategorySelectorButton *button = (CategorySelectorButton*)subview;
            if ([button.categoryModel.categoryID isEqualToString:categoryId])
            {
                result = button.titleLabel;
                *stop = YES;
            }
        }
    }];
    return result;
}

- (void)removeClickAutoDismissBadges {
    [_scrollView.subviews enumerateObjectsUsingBlock:^(id subview, NSUInteger idx, BOOL *stop) {
        if([subview isKindOfClass:[CategorySelectorButton class]])
        {
            CategorySelectorButton *button = (CategorySelectorButton*)subview;
            if (![button.categoryModel.categoryID isEqualToString:kTTSubscribeCategoryID] && [self.categoryClickAutoDismissBadgeSet containsObject:button.categoryModel.categoryID])
            {
                //红点/数字受TTCategoryBadgeNumberManager控制
                BOOL hasNotifyPoint = [[TTCategoryBadgeNumberManager sharedManager] hasNotifyPointOfCategoryID:button.categoryModel.categoryID];
                NSUInteger badgeNumber = [[TTCategoryBadgeNumberManager sharedManager] badgeNumberOfCategoryID:button.categoryModel.categoryID];
                [button showPoint:hasNotifyPoint badgeNumber:badgeNumber style:_style];
                [self.categoryClickAutoDismissBadgeSet removeObject:button.categoryModel.categoryID];
            }
        }
    }];
    [self changeHasNewCategoryBadge:nil];
}

#pragma mark - TTCategoryBadgeNumberManagerDelegate

- (void)categoryBadgeNumberDidChange:(TTCategoryBadgeNumberManager *)manager
                          categoryID:(NSString *)categoryID
                      hasNotifyPoint:(BOOL)hasNotifyPoint
                         badgeNumber:(NSUInteger)badgeNumber {
    if (!isEmptyString(categoryID)) {
        __block CategorySelectorButton * targetButton = nil;
        [_scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[CategorySelectorButton class]] && [[(CategorySelectorButton *)obj categoryModel].categoryID isEqualToString:categoryID]) {
                targetButton = obj;
                *stop = YES;
            }
        }];
        if (targetButton) {
            BOOL show = [self.categoryClickAutoDismissBadgeSet containsObject:categoryID];
            BOOL hasNotifyPoint = [[TTCategoryBadgeNumberManager sharedManager] hasNotifyPointOfCategoryID:categoryID];
            NSUInteger badgeNumber = [[TTCategoryBadgeNumberManager sharedManager] badgeNumberOfCategoryID:categoryID];
            [targetButton showPoint:show||hasNotifyPoint badgeNumber:badgeNumber style:_style];
        }
    }
}

- (BOOL)isCategoryInFirstScreen:(TTCategoryBadgeNumberManager *)manager
                 withCategoryID:(NSString *)categoryID {
    if ([categoryID isEqualToString:kTTFollowCategoryID]) {
        //关注频道是否在首屏的判断逻辑和其他频道有区别
        //只有关注频道不被添加频道的按钮遮挡，才算在首屏
        BOOL result = NO;
        for(UIView *subview in _scrollView.subviews) {
            if([subview isKindOfClass:[CategorySelectorButton class]]) {
                CategorySelectorButton *button = (CategorySelectorButton*)subview;
                if([button.categoryModel.categoryID isEqualToString:categoryID]) {
                    if(button.right <= _scrollView.width - self.expandButton.width){
                        result = YES;
                    }
                    break;
                }
            }
        }
        return result;
    }else {
        return [self isCategoryInFirstScreen:categoryID];
    }
}

#pragma mark - track tips

+ (void)trackTipsWithLabel:(NSString *)label position:(NSString *)position style:(NSString *)style
{
    [self trackTipsWithLabel:label position:position style:style categoryID:nil];
}

+ (void)trackTipsWithLabel:(NSString *)label position:(NSString *)position style:(NSString *)style categoryID:(NSString *)categoryID
{
    if (!isEmptyString(label) && !isEmptyString(position) && !isEmptyString(style)) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
        [extra setValue:categoryID forKey:@"category_name"];
        [extra setValue:position forKey:@"position"];
        [extra setValue:style forKey:@"style"];
        wrapperTrackEventWithCustomKeys(@"tips", label, nil, nil, extra);
    }
}

@end



//
//  TTMoviePlayerControlTopView.m
//  Article
//
//  Created by xiangwu on 2016/12/27.
//
//

#import "TTMoviePlayerControlTopView.h"
#import "UIViewAdditions.h"
#import "TTLabelTextHelper.h"
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import "TTVPlayerSettingUtility.h"
#import "UIButton+TTAdditions.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "UIImage+TTThemeExtension.h"

typedef NS_ENUM(NSInteger, TTVTitleFontStyle)
{
    TTVTitleFontStyleNormal,
    TTVTitleFontStyleSmall,
    TTVTitleFontStyleUltraSmall
};

static const CGFloat kBackButtonWidth = 24;
extern BOOL ttvs_isVideoNewRotateEnabled(void);

@interface TTMoviePlayerControlTopView ()

@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UILabel *playTimesLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSNumber *barStyleNumber;
@property (nonatomic, strong) NSNumber *statusbarHiddenNumber;

@end

@implementation TTMoviePlayerControlTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        
        //顶部的渐变阴影
        _backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopShadow"]];
        _backImageView.userInteractionEnabled = YES;
        [self addSubview:_backImageView];
        
        //标题标
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:[[self class] settedTitleFontSize]];
        _titleLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        [self addSubview:_titleLabel];
        _titleLabel.numberOfLines = 2;
        
        _playTimesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _playTimesLabel.font = [UIFont systemFontOfSize:12.f];
        _playTimesLabel.textColor = [UIColor tt_defaultColorForKey:kColorText9];
        if (ttvs_isVideoFeedCellHeightAjust() > 1){
            _playTimesLabel.textColor = [UIColor tt_defaultColorForKey:kColorLine1];
        }
        [self addSubview:_playTimesLabel];
        [self addShareMore];

        //返回按钮
        _backButton = [[UIButton alloc] init];
        _backButton.frame = CGRectMake(0, 0, kBackButtonWidth, kBackButtonWidth);
        [_backButton setImage:[UIImage imageNamed:@"white_lefterbackicon_titlebar"] forState:UIControlStateNormal];
        [self addSubview:_backButton];
        
        [self updateBackBtnHitTest];

        _showFullscreenStatusBar = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged) name:kSettingFontSizeChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateBackBtnHitTest {
    if (_isFull) {
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -12, -26, -84);
        _backButton.hidden = NO;
    } else {
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -12, -15, -36);
        _backButton.hidden = YES;
        _moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        _shareButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    }
}

- (void)updateFrame {
    _backImageView.frame = UIEdgeInsetsInsetRect(self.bounds, self.dimAreaEdgeInsetsWhenFullScreen);
    if (_isFull) {
        if (self.barStyleNumber == nil) {
            self.barStyleNumber = @([UIApplication sharedApplication].statusBarStyle);
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
        if (self.statusbarHiddenNumber == nil) {
            self.statusbarHiddenNumber = @([UIApplication sharedApplication].isStatusBarHidden);
            [[UIApplication sharedApplication] setStatusBarHidden:(!_showFullscreenStatusBar || self.alpha == 0)];
        }
        _backButton.top = _showFullscreenStatusBar ? 30 : 10;
        _backButton.left = 12;
        _titleLabel.numberOfLines = 1;
        [_titleLabel sizeToFit];
        _titleLabel.left = _backButton.right + 4;
        _titleLabel.centerY = _backButton.centerY;
        _titleLabel.width = self.width - _titleLabel.left - 4;
        
        _backButton.hidden = NO;
        
        [self updateShareMore];
        if (_shouldShowShareMore > 0) {
            _titleLabel.width = self.width  - 76 - _titleLabel.left;
        }
        //如果系统是9以下或者是旧转屏，全屏不展示share／more
        if ([TTDeviceHelper OSVersionNumber] < 9.0 || !ttvs_isVideoNewRotateEnabled()) {
            _moreButton.hidden = YES;
            _shareButton.hidden = YES;
        }
        _playTimesLabel.hidden = YES;
        _titleLabel.hidden = NO;
    } else {
        if (self.barStyleNumber) {
            [[UIApplication sharedApplication] setStatusBarStyle:self.barStyleNumber.unsignedIntegerValue == UIStatusBarStyleDefault ? [[TTThemeManager sharedInstance_tt] statusBarStyle] : self.barStyleNumber.unsignedIntegerValue];
            self.barStyleNumber = nil;
        }
        if (self.statusbarHiddenNumber) {
            [[UIApplication sharedApplication] setStatusBarHidden:self.statusbarHiddenNumber.boolValue];
            self.statusbarHiddenNumber = nil;
        }
        _titleLabel.numberOfLines = 2;
        CGFloat fontSize = [[self class] settedTitleFontSize];
        if (_isSmallFontSizeForTitle) {
            fontSize = [[self class] settedTitleSmallFontSize];
        }
        CGFloat height = [TTLabelTextHelper heightOfText:_titleLabel.text fontSize:fontSize forWidth:self.width - 15 * 2 constraintToMaxNumberOfLines:2];
        CGSize size = CGSizeMake(self.width - 15 * 2, height);
        if(ttvs_isVideoFeedCellHeightAjust() > 0){
            _titleLabel.frame = CGRectMake(15, 8, size.width, size.height);
        }else{
            _titleLabel.frame = CGRectMake(15, 12, size.width, size.height);
        }
        _moreButton.centerY = 22;
        _moreButton.right = self.width - 12;
        _playTimesLabel.top = _titleLabel.bottom + 3;
        _playTimesLabel.left = _titleLabel.left;
        _backButton.hidden = YES;
        _moreButton.hidden = YES;
        _shareButton.hidden = YES;
        _playTimesLabel.hidden = NO;
    }
}

- (void)setWatchCount:(NSString *)count
{
    _playTimesLabel.text = count;
    [_playTimesLabel sizeToFit];
}

- (void)setTitle:(NSString *)title fontSizeStyle:(NSInteger)style {
    [_titleLabel setText:title];
    if (style == TTVTitleFontStyleSmall || style == TTVTitleFontStyleUltraSmall) {
        _isSmallFontSizeForTitle = YES;
    }
    else {
        _isSmallFontSizeForTitle = NO;
    }
    if (style == TTVTitleFontStyleUltraSmall) {
        _titleLabel.font = [UIFont boldSystemFontOfSize:[[self class] settedTitleUltraSmallFontSize]];
    }
    else if (style == TTVTitleFontStyleSmall) {
        _titleLabel.font = [UIFont boldSystemFontOfSize:[[self class] settedTitleSmallFontSize]];
    }
    else{
        _titleLabel.font = [UIFont boldSystemFontOfSize:[[self class] settedTitleFontSize]];
    }
}

- (void)fontSizeChanged
{
    if (_isSmallFontSizeForTitle) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:[[self class] settedTitleSmallFontSize]];
    }
    else{
        self.titleLabel.font = [UIFont boldSystemFontOfSize:[[self class] settedTitleFontSize]];
    }
}

+ (float)settedTitleUltraSmallFontSize {
    NSDictionary *fontSizes =  @{@"iPad" : @[@17, @20, @22, @27],
                                 @"iPhone667": @[@14,@16,@18,@21],
                                 @"iPhone736" : @[@14, @16, @18, @21],
                                 @"iPhone" : @[@12, @14, @16, @19]};
    NSString *key = nil;
    if ([TTDeviceHelper isPadDevice]) {
        key = @"iPad";
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        key = @"iPhone736";
    } else {
        key = @"iPhone";
    }
    NSArray *fonts = [fontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];;
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return [fonts[index] floatValue];
}

+ (float)settedTitleSmallFontSize {
    NSDictionary *fontSizes =  @{@"iPad" : @[@19, @22, @24, @29],
                                 @"iPhone667": @[@16,@18,@20,@23],
                                 @"iPhone736" : @[@16, @18, @20, @23],
                                 @"iPhone" : @[@14, @16, @18, @21]};
    NSString *key = nil;
    if ([TTDeviceHelper isPadDevice]) {
        key = @"iPad";
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        key = @"iPhone736";
    } else {
        key = @"iPhone";
    }
    NSArray *fonts = [fontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];;
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return [fonts[index] floatValue];
}

+ (float)settedTitleFontSize {
    NSDictionary *fontSizes = @{@"iPad" : @[@20, @23, @25, @30],
                                @"iPhone667": @[@17,@19,@21,@24],
                                @"iPhone736" : @[@17, @19, @21, @24],
                                @"iPhone" : @[@15, @17, @20, @24]};
    NSString *key = nil;
    if ([TTDeviceHelper isPadDevice]) {
        key = @"iPad";
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        key = @"iPhone736";
    } else {
        key = @"iPhone";
    }
    NSArray *fonts = [fontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];;
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return [fonts[index] floatValue];
}

- (void)setIsFull:(BOOL)isFull {
    _isFull = isFull;
//    self.userInteractionEnabled = isFull;
    [self updateFrame];
    [self updateBackBtnHitTest];
}

- (void)addShareMore
{
    if (!_moreButton) {
        _moreButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, 24.f, 24.f)];
        [self.moreButton setImage:[UIImage themedImageNamed:@"new_morewhite_titlebar"] forState:UIControlStateNormal];
        [self.moreButton setImage:[UIImage themedImageNamed:@"new_morewhite_titlebar"] forState:UIControlStateHighlighted];
    }
    
    if (!_shareButton) {
        _shareButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, 24.f, 24.f)];
        [self.shareButton setImage:[UIImage themedImageNamed:@"icon_details_share"] forState:UIControlStateNormal];
        [self.shareButton setImage:[UIImage themedImageNamed:@"icon_details_share"] forState:UIControlStateHighlighted];
    }
    [self addSubview:_moreButton];
    [self addSubview:_shareButton];
    [self updateBackBtnHitTest];
    [self updateFrame];
    self.moreButton.hidden = YES;
    self.shareButton.hidden = YES;
}

- (void)updateShareMore{
    
    if (_shouldShowShareMore == 1){
        _shareButton.hidden = NO;
        _moreButton.hidden = YES;
        _shareButton.right = self.width - 20;
        _shareButton.top = _backButton.top;
    }else if (_shouldShowShareMore == 2){
        _moreButton.hidden = NO;
        _shareButton.hidden = YES;
        _moreButton.top = _backButton.top;
        _moreButton.right = self.width - 12;
    }
}
@end

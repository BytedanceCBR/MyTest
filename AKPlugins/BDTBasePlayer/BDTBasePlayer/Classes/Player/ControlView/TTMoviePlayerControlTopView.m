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
#import "TTUGCAttributedLabel.h"
#import "TTRichSpanText+Link.h"
#import "TTUGCEmojiParser.h"
#import "TTLabelTextHelper.h"

extern BOOL ttvs_isEnhancePlayerTitleFont(void);
typedef NS_ENUM(NSInteger, TTVTitleFontStyle)
{
    TTVTitleFontStyleNormal,
    TTVTitleFontStyleSmall,
    TTVTitleFontStyleUltraSmall
};

static const CGFloat kBackButtonWidth = 24;

@interface TTMoviePlayerControlTopView ()

@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UILabel *playTimesLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSNumber *barStyleNumber;
@property (nonatomic, copy) NSString *title;
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
        _titleLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        [self addSubview:_titleLabel];
        _titleLabel.numberOfLines = 2;
        
        _playTimesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _playTimesLabel.font = [UIFont systemFontOfSize:12.f];
        _playTimesLabel.textColor = [UIColor tt_defaultColorForKey:kColorText9];
        if ([TTVPlayerSettingUtility ttvs_isVideoFeedCellHeightAjust] > 1){
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

- (CGSize)titleFrameSize
{
    return [self.title boundingRectWithSize:CGSizeMake(self.width - 15 * 2, 9999.f)
                             options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{NSFontAttributeName:[self titleFont],
                                       NSParagraphStyleAttributeName:[self titleParagraphStyle],
                                       }
                             context:nil].size;
}

- (void)updateFrame {
    _backImageView.frame = UIEdgeInsetsInsetRect(self.bounds, self.dimAreaEdgeInsetsWhenFullScreen);
    [self setTitle:_title];
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
        _titleLabel.left = _backButton.right + 4;
        _titleLabel.centerY = _backButton.centerY;
        _titleLabel.width = self.width - _titleLabel.left - 4;
        CGSize size = [self titleFrameSize];
        _titleLabel.height = size.height;
        _backButton.hidden = NO;
        
        [self updateShareMore];
        if (_shouldShowShareMore > 0) {
            _titleLabel.width = self.width  - 76 - _titleLabel.left;
        }
        //如果系统是9以下或者是旧转屏，全屏不展示share／more
        if ([TTDeviceHelper OSVersionNumber] < 9.0 || ![TTVPlayerSettingUtility ttvs_isVideoNewRotateEnabled]) {
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
        
        CGSize size = [self titleFrameSize];
        
        if([TTVPlayerSettingUtility ttvs_isVideoFeedCellHeightAjust] > 0){
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

- (UIFont *)titleFont
{
    return [UIFont boldSystemFontOfSize:[[self class] settedTitleFontSize]];
}

- (NSMutableParagraphStyle *)titleParagraphStyle
{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    CGFloat lineSize = [[self class] settedTitleFontSize] + 4;
    if ([TTDeviceHelper OSVersionNumber] < 9) {
        paragraphStyle.minimumLineHeight = lineSize;
        paragraphStyle.maximumLineHeight = lineSize;
        paragraphStyle.lineHeightMultiple = 4;
    }else {
        paragraphStyle.minimumLineHeight = lineSize;
        paragraphStyle.maximumLineHeight = lineSize;
        paragraphStyle.lineSpacing = 0;
    }
    if (self.isFull) {
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    }else{
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    }
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.firstLineHeadIndent = 0;
    return paragraphStyle;
}

- (NSDictionary *)titleLabelAttributedDictionary{
    NSMutableDictionary * attributeDictionary = [NSMutableDictionary dictionary];
    [attributeDictionary setValue:[self titleParagraphStyle] forKey:NSParagraphStyleAttributeName];
    [attributeDictionary setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [attributeDictionary setValue:[self titleFont] forKey:NSFontAttributeName];
    return attributeDictionary.copy;
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    if (!_title) {
        _title = @" ";
    }
    NSAttributedString *string = [TTUGCEmojiParser parseInTextKitContext:title fontSize:[[self class] settedTitleFontSize]];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    NSDictionary *attrDic = [self titleLabelAttributedDictionary];
    [mutableAttributedString addAttributes:attrDic range:NSMakeRange(0, mutableAttributedString.length)];
    _titleLabel.attributedText = mutableAttributedString;
}

- (void)fontSizeChanged
{
    [self updateFrame];
}

+ (float)settedTitleFontSize {
    NSDictionary *fontSizes = nil;
    if (ttvs_isEnhancePlayerTitleFont()){
        fontSizes = @{@"iPad" : @[@20, @22, @24, @28],
                      @"iPhone667": @[@18,@19,@20,@22],
                      @"iPhone736" : @[@19, @20, @21, @23],
                      @"iPhone" : @[@16, @17, @18, @20]};
    }else{
        fontSizes = @{@"iPad" : @[@19, @22, @24, @29],
                      @"iPhone667": @[@16,@18,@20,@23],
                      @"iPhone736" : @[@16, @18, @20, @23],
                      @"iPhone" : @[@14, @16, @18, @21]};
    }
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
        self.moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    }
    
    if (!_shareButton) {
        _shareButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, 24.f, 24.f)];
        [self.shareButton setImage:[UIImage themedImageNamed:@"icon_details_share"] forState:UIControlStateNormal];
        [self.shareButton setImage:[UIImage themedImageNamed:@"icon_details_share"] forState:UIControlStateHighlighted];
        self.shareButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
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

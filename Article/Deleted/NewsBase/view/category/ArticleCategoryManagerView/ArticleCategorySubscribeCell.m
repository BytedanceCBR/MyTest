//
//  ArticleCategorySubscribeCell.m
//  Article
//
//  Created by Dianwei on 14-9-14.
//
//

#import "ArticleCategorySubscribeCell.h"
#import "ArticleCategoryManagerViewConstant.h"
#import "TTArticleCategoryManager.h"
#import "TTBadgeNumberView.h"

#import "TTThemeConst.h"
#import "UIColor+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTProjectLogicManager.h"
#import "TTBadgeTrackerHelper.h"
#import "TTCategory+ConfigDisplayName.h"


#define kCellTitleBorderGap 5.0f

@interface ArticleCategorySubscribeCell(){
    BOOL _showBadge;
    BOOL _currentIsDragging;//start is NO
    BOOL _editing;
}

@property(nonatomic, strong)TTBadgeNumberView *badgeView;
@property(nonatomic, strong)SSThemedImageView *plusImageView;

@end

@implementation ArticleCategorySubscribeCell

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, [ArticleCategorySubscribeCell articleCategorySubscribeCellWidth], [ArticleCategorySubscribeCell articleCategorySubscribeCellHeight])];
    if (self) {
        _currentIsDragging = NO;
        
        // 默认不显示阴影, opacity=0
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.bgButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_bgButton addTarget:self action:@selector(bgButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bgButton];
        
//        _bgButton.backgroundColorThemeKey = kColorBackground3;
        _bgButton.backgroundColor = [[TTThemeManager sharedInstance_tt] themedColorForKey:kColorBackground3];
        _bgButton.layer.cornerRadius = 4;
        _bgButton.layer.masksToBounds = YES;
        
        [_bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textColorThemeKey = kColorText1;
        [self addSubview:_titleLabel];
        _titleLabel.centerY = self.height/2;
        
        self.plusImageView = [[SSThemedImageView alloc] init];
        _plusImageView.imageName = @"addicon_channel.png";
        [self addSubview:_plusImageView];
        _plusImageView.hidden = YES;
        _plusImageView.frame = CGRectMake(0, 0, 12, 12);
        _plusImageView.centerY = self.height/2;
        
//        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self);
//        }];
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
        
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(4);
            make.top.equalTo(self).offset(-4);
            make.height.width.mas_equalTo(18);
        }];
        
        _closeButton.hidden = YES;
        _closeButton.layer.zPosition = 1;
        _editing = NO;
        
        [self reloadThemeUI];
    }
    
    return self;
}

- (void)refreshDraggingStatus:(BOOL)isDragging
{
    if (isDragging == _currentIsDragging) {
        return;
    }
    
    _currentIsDragging = isDragging;
    CGPoint center = self.center;
    if (_currentIsDragging) {
        self.size = CGSizeMake([ArticleCategorySubscribeCell articleCategorySubscribeCellWidth] + 9.f, [ArticleCategorySubscribeCell articleCategorySubscribeCellHeight] + 9.f);
        //_bgButton.alpha = 0.8;
        self.badgeView.hidden = YES;
        self.tipNewView.hidden = YES;
        
    } else {
        self.size =CGSizeMake([ArticleCategorySubscribeCell articleCategorySubscribeCellWidth], [ArticleCategorySubscribeCell articleCategorySubscribeCellHeight]);
        //_bgButton.alpha = 1;
        
        if (![self isEditing]) {
            self.badgeView.hidden = NO;
            self.tipNewView.hidden = NO;
        }
    }
    
    self.center = center;
    
    [self refreshTitleLabel];
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    if (![self isCanNotChangeCell]) {
        _closeButton.hidden = !_editing;
    }
    [self refreshTitleLabel];
    
    if (_editing) {
        self.badgeView.hidden = YES;
        self.tipNewView.hidden = YES;
    } else {
        self.badgeView.hidden = NO;
        self.tipNewView.hidden = NO;
    }
}

- (BOOL)isEditing
{
    return _editing;
}

- (void)themeChanged:(NSNotification *)notification
{
    [_closeButton setImage:[UIImage themedImageNamed:@"deleteicon_channel.png"] forState:UIControlStateNormal];
    [self refrshButtonBackgroundColor];
}

- (void)bgButtonClicked:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(categoryCellDidClicked:)]) {
        if (!self.tipNewView.hidden) {
            [[TTBadgeTrackerHelper class] trackTipsWithLabel:@"click" position:@"channel_edit" style:@"red_tips" categoryID:self.model.categoryID];
        }
        [_delegate categoryCellDidClicked:self];
    }
}

- (void)closeButtonClicked:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(closeButtonClicked:)])
    {
        [_delegate closeButtonClicked:self];
    }
}

- (void)showTipNewIfNeed
{
    if (_model.tipNew) {
        if (!self.tipNewView) {
            self.tipNewView = [[SSThemedImageView alloc] init];
            _tipNewView.contentMode = UIViewContentModeScaleToFill;
            _tipNewView.imageName = @"add_channels_new.png";
            _tipNewView.backgroundColor = [UIColor clearColor];
        }
        if (!self.tipNewView.superview) {
            [[TTBadgeTrackerHelper class] trackTipsWithLabel:@"show" position:@"channel_edit" style:@"red_tips" categoryID:_model.categoryID];
        }
        [self addSubview:_tipNewView];
        [_tipNewView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(self);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(8);
        }];
    } else {
        if (self.tipNewView) {
            [_tipNewView removeFromSuperview];
            self.tipNewView = nil;
        }
    }
}

- (void)refreshTitleLabel
{
    CGFloat fontSize = [ArticleCategorySubscribeCell articleCategorySubscribeCellTitleFontSizeWithCategory:_model];
    
    if (_currentIsDragging) {
        fontSize += 3;
    }
    
    [_titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    
    _titleLabel.text = @"五个汉字字";
    [_titleLabel sizeToFit];
    CGFloat max5W = _titleLabel.width;
    
//    _titleLabel.text = @"四个汉字";
//    [_titleLabel sizeToFit];
//    CGFloat max4W = _titleLabel.width;
    
//    _titleLabel.text = @"三个字";
//    [_titleLabel sizeToFit];
//    CGFloat max3W = _titleLabel.width;
    
    if ([_model adjustDisplayName].length > 5) {
        _titleLabel.text = [NSString stringWithFormat:@"%@…", [[_model adjustDisplayName] substringToIndex:4]];
    }
    else {
        _titleLabel.text = [_model adjustDisplayName];
    }
    
    [_titleLabel sizeToFit];
  
    if (_titleLabel.width > max5W) {
        _titleLabel.width = max5W;
    }
    
    _plusImageView.centerY = self.height/2;
    _titleLabel.centerY = self.height/2;
    
    if (_model.subscribed == 0) {
        if ([_model adjustDisplayName].length < 4) {
            _plusImageView.size = CGSizeMake(12, 12);
        } else {
            _plusImageView.size = CGSizeMake(10, 10);
        }
        
        CGFloat left = (self.width - _plusImageView.width - [self plusTitleGap:[_model adjustDisplayName]] - _titleLabel.width) / 2;
        _plusImageView.left = left;
        _titleLabel.left = _plusImageView.right + [self plusTitleGap:[_model adjustDisplayName]];
        
    } else {
        _titleLabel.centerX = self.width/2;
    }
    
    
    //    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
    //        make.width.mas_equalTo([ArticleCategorySubscribeCell articleCategorySubscribeCellWidth] - kCellTitleBorderGap * 2);
    //    }];
    

    if ([[TTArticleCategoryManager currentSelectedCategoryID] isEqualToString:_model.categoryID] && ![self isEditing] && _model.subscribed) {
        _titleLabel.textColorThemeKey = kColorText4;
    }
    else if ([self isCanNotChangeCell]) {
        _titleLabel.textColorThemeKey = kColorText3;
    }
    else {
        if (_currentIsDragging) {
            _titleLabel.textColorThemeKey = kColorText3;
        } else {
            _titleLabel.textColorThemeKey = kColorText1;
        }
    }
}

- (CGFloat)plusTitleGap:(NSString *)title {
    BOOL lessThanFive = title.length < 5;
    if ([TTDeviceHelper isPadDevice] || [TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return lessThanFive ? 3.f : 5.f;
    }
    else if ([TTDeviceHelper is736Screen]) {
        return lessThanFive ? 3.f : 4.f;
    }
    else {
        return 2.f;
    }
}

- (void)refreshCategoryModel:(TTCategory *)model
{
    self.model = model;
    
    [self refreshTitleLabel];
    
    [self refrshButtonBackgroundColor];
    
    if (model.subscribed == 0) {
        self.plusImageView.hidden = NO;

        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            self.layer.shadowOpacity = 0;
            self.layer.shadowPath = nil;
        } else {
            self.layer.shadowColor = [UIColor blackColor].CGColor;
            self.layer.shadowOpacity = 0.10;
            self.layer.shadowRadius = 3;
            self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bgButton.layer.cornerRadius] CGPath];
        }
    } else {
        self.plusImageView.hidden = YES;
        self.layer.shadowOpacity = 0;
        self.layer.shadowPath = nil;
    }
    
    //[self reloadThemeUI];
    [self showTipNewIfNeed];
}

- (void)refrshButtonBackgroundColor {
    if (self.model.subscribed == 0) {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            self.bgButton.backgroundColor = [[TTThemeManager sharedInstance_tt] themedColorForKey:kColorBackground3];
        } else {
            self.bgButton.backgroundColor = [[TTThemeManager sharedInstance_tt] themedColorForKey:kColorBackground4];
        }
    } else {
        self.bgButton.backgroundColor = [[TTThemeManager sharedInstance_tt] themedColorForKey:kColorBackground3];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@" index %lu name %@ frame %@", _model.orderIndex, [_model adjustDisplayName], NSStringFromCGRect([self frame])];
}

- (BOOL)isCanNotChangeCell
{
    if (_model.isPreFixedCategory) {
        return YES;
    }
    if ([[_model categoryID] isEqualToString:kTTMainCategoryID]) {
        return YES;
    }
    
    NSString * cannotDragCID = TTLogicString(@"ArticleCategoryManagerViewFixationCategoryID", nil);
    if (!isEmptyString(cannotDragCID) && [[_model categoryID] isEqualToString:cannotDragCID]) {
        return YES;
    }
    return NO;
}

- (void)setShowBadge:(BOOL)showBadge
{
    _showBadge = showBadge;
    if (showBadge) {
        if (!self.badgeView) {
            self.badgeView = [[TTBadgeNumberView alloc] init];
            self.badgeView.badgeNumber = TTBadgeNumberPoint;
            [self addSubview:self.badgeView];
            
            [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo([TTDeviceHelper isPadDevice] ? 10 : 4);
                make.centerX.equalTo(self.mas_right).offset(-2);
                make.centerY.equalTo(self.mas_top).offset(2);
            }];
        }
    } else {
        [self.badgeView removeFromSuperview];
        self.badgeView = nil;
    }
}

- (BOOL)isBadgeShown
{
    return _showBadge;
}

//static CGFloat s_articleCategorySubscribeCellWidth = 0;
+ (CGFloat)articleCategorySubscribeCellWidth
{
    if ([TTDeviceHelper isPadDevice]) {                    // iPad
        UIView *view = [TTUIResponderHelper mainWindow];
        return ([TTUIResponderHelper splitViewFrameForView:view].size.width - (kCellNumberPerRow - 1) * kCategoryCellHorizonGapForPad - kCategoryCellLeftPadding * 2) / kCellNumberPerRow;
    }
    
//    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen]) { // iPhone 6 & iPhone 6P
//        s_articleCategorySubscribeCellWidth = 82.f;
//    } else {
//        s_articleCategorySubscribeCellWidth = 72.f;
//    }

    else if ([TTDeviceHelper is736Screen]) {  // iPhone 6P
        return 85.33f;
    }
    else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone 6
        return 80.f;
    }
    else {
        return 67.5f;
    }
}

//static CGFloat s_articleCategorySubscribeCellHeight = 0;
+ (CGFloat)articleCategorySubscribeCellHeight
{
    if ([TTDeviceHelper isPadDevice]) {                    // iPad
        return 50.f;
    }
    
//    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen]) { // iPhone 6 & iPhone 6P
//        s_articleCategorySubscribeCellHeight = 36.f;
//    } else {
//        s_articleCategorySubscribeCellHeight = 32.

//    }
    if ([TTDeviceHelper is736Screen]) { // iPhone 6P
        return 42.f;
    }
    else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) { // iPhone 6
        return 44.f;
    }
    else {
        return 40.f;
    }
}

+ (CGFloat)articleCategorySubscribeCellTitleFontSizeWithText:(NSString *)title
{
    if ([TTDeviceHelper isPadDevice]) {
        return 22.f;
    }
    else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 16.f;
    }
    else {
        return 14.f;
    }
}

+ (CGFloat)articleCategorySubscribeCellTitleFontSizeWithCategory:(TTCategory *)category
{
    NSUInteger length = [category adjustDisplayName].length;
    
    if (category.subscribed > 0) {
        if ([TTDeviceHelper isPadDevice]) {
            return length < 5 ? 22.f : 16.f;
        }
        else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
            return length < 5 ? 16.f : 13.f;
        }
        else {
            return length < 5 ? 14.f : 11.f;
        }
    }
    else {
        if ([TTDeviceHelper isPadDevice]) {
            return length < 4 ? 22.f : 16.f;
        }
        else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
            return length < 4 ? 16.f : (length < 5 ? 13.f : 11.f);
        }
        else {
            return length < 4 ? 14.f : (length < 5 ? 11.f : 10.f);
        }
    }
}

@end

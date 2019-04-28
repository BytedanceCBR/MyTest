//
//  ExploreArticleEssayADTypeCellView.m
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "ExploreArticleEssayADTypeCellView.h"
#import "EssayData.h"
#import "MTLabel.h"
#import "NewsUserSettingManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "TTUISettingHelper.h"
#import "SSAppStore.h"

@interface ExploreArticleEssayADTypeCellView ()

@property (nonatomic, strong) MTLabel *contentLabel;
@property (nonatomic, strong) MTLabel *extLabel;
@property (nonatomic, strong) SSThemedView *adBackgroundView;
@property (nonatomic, strong) SSThemedLabel *adLabel;
@property (nonatomic, strong) SSThemedButton *jumpURLButton;
@property (nonatomic, strong) UIView *sepLineView;
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation ExploreArticleEssayADTypeCellView

- (void)dealloc
{
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.contentLabel];
        [self addSubview:self.adBackgroundView];
        [self addSubview:self.extLabel];
        [self addSubview:self.adLabel];
        [self addSubview:self.jumpURLButton];
    }
    
    return self;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        NSUInteger cellType = [self cellTypeForCacheHeightFromOrderedData:orderedData];
        
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellType];
        if (cacheH > 0) {
            //NSLog(@"hit cacheH: %f %p %@", cacheH, (__bridge void*)orderedData, orderedData.essayData.content);
            if (![TTDeviceHelper isPadDevice] && [orderedData nextCellHasTopPadding]) {
                cacheH -= kCellSeprateViewHeight();
            }
            return cacheH;
        }
        
        EssayADData *essayAD = orderedData.essayADData;
        
        CGRect contentLabelRect = [[self class] frameForContentLabel:essayAD.title cellWidth:width isList:YES];
        
        CGFloat titleFontSize = [NewsUserSettingManager settedEssayTextFontSize];
        CGFloat lineH = [NewsUserSettingManager settedEssayTextFontLineHeight];
        CGFloat contentHeight = 0;
        if (contentLabelRect.size.height != 0) {
            contentHeight = contentLabelRect.size.height - (lineH - titleFontSize) + 3;
        }
        
#if SHOW_INFOBAR
        CGFloat sourceLabelHeight = cellInfoBarHeight();
#else
        CGFloat sourceLabelHeight = 0;
#endif
        
        CGFloat height;
        height = cellBottomPadding() + contentHeight + sourceLabelHeight;
        
        if ([TTDeviceHelper isPadDevice]) {
            height += [TTDeviceHelper ssOnePixel];
        }
        else {
            height += kCellSeprateViewHeight() + [TTDeviceHelper ssOnePixel];
        }
        
        if (![TTDeviceHelper isPadDevice] && [orderedData nextCellHasTopPadding]) {
            height -= kCellSeprateViewHeight();
        }
        
        height += 58 + 15;
        [orderedData saveCacheHeight:ceilf(height) forListType:listType cellType:cellType];
        
        return ceilf(height);
    }
    
    return 0.f;
}

- (NSUInteger)refer
{
    return [[self cell] refer];
}

- (id)cellData
{
    return self.orderedData;
}

- (MTLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[MTLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.backgroundColor = [UIColor clearColor];
        CGFloat titleFontSize;
        CGFloat lineH;
        titleFontSize = [NewsUserSettingManager settedEssayTextFontSize];
        lineH = [NewsUserSettingManager settedEssayTextFontLineHeight];
        _contentLabel.fontColor = [TTUISettingHelper cellViewTitleColor];
        
        if ([TTDeviceHelper isPadDevice]) {
            _contentLabel.font = [UIFont boldSystemFontOfSize:titleFontSize];
        }
        else {
            _contentLabel.font = [UIFont systemFontOfSize:titleFontSize];
        }
        
        _contentLabel.lineHeight = lineH;
        [_contentLabel setContentMode:UIViewContentModeRedraw];
    }
    return _contentLabel;
}

- (MTLabel *)extLabel
{
    if (!_extLabel) {
        _extLabel = [[MTLabel alloc] initWithFrame:CGRectZero];
        _extLabel.backgroundColor = [UIColor clearColor];
        CGFloat titleFontSize;
        CGFloat lineH;
        titleFontSize = [NewsUserSettingManager settedEssayTextFontSize];
        lineH = [NewsUserSettingManager settedEssayTextFontLineHeight];
        _extLabel.fontColor = [TTUISettingHelper cellViewTitleColor];
        _extLabel.font = [UIFont systemFontOfSize:14];
        _extLabel.lineHeight = lineH;
        [_extLabel setContentMode:UIViewContentModeRedraw];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickADBackgroundView)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [_extLabel addGestureRecognizer:singleTap];
    }
    return _extLabel;
}

- (SSThemedView *)adBackgroundView
{
    if (!_adBackgroundView) {
        _adBackgroundView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _adBackgroundView.backgroundColorThemeKey = kColorBackground3;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickADBackgroundView)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [_adBackgroundView addGestureRecognizer:singleTap];
        
    }
    return _adBackgroundView;
}

- (SSThemedLabel *)adLabel
{
    if (!_adLabel) {
        _adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _adLabel.font = [UIFont systemFontOfSize:10];
        _adLabel.layer.masksToBounds = YES;
        _adLabel.layer.cornerRadius = 3.f;
        _adLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _adLabel.textAlignment = NSTextAlignmentCenter;
        _adLabel.text = @"";
        _adLabel.size = CGSizeMake(26, 14);
        _adLabel.textColorThemeKey = kColorText5;
        _adLabel.borderColorThemeKey = kColorText5;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickADBackgroundView)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [_adLabel addGestureRecognizer:singleTap];
    }
    return _adLabel;
}

- (SSThemedButton *)jumpURLButton
{
    if (!_jumpURLButton) {
        _jumpURLButton = [[SSThemedButton alloc] initWithFrame:CGRectZero];
        [_jumpURLButton.titleLabel setTextColor:[UIColor redColor]];
        _jumpURLButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _jumpURLButton.layer.masksToBounds = YES;
        _jumpURLButton.layer.cornerRadius = 6;
        _jumpURLButton.layer.borderWidth = 1;
        _jumpURLButton.titleColorThemeKey = kColorBlueTextColor;
        _jumpURLButton.borderColorThemeKey = kColorBlueBorderColor;
        
        [_jumpURLButton addTarget:self action:@selector(didClickJumpURLButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _jumpURLButton;
}

- (void)didClickADBackgroundView
{
    if (self.orderedData.uniqueID && self.orderedData.categoryID) {
        [TTTrackerWrapper eventV3:@"joke_ad_click" params:@{@"card_id" : self.orderedData.uniqueID, @"category_name" : self.orderedData.categoryID, @"click_position" : @"cell"}];
    }
    
    [self didSelectWithContext:nil];
}

- (void)didClickJumpURLButton
{
    if (self.orderedData.uniqueID && self.orderedData.categoryID) {
        [TTTrackerWrapper eventV3:@"joke_ad_click" params:@{@"card_id" : self.orderedData.uniqueID, @"category_name" : self.orderedData.categoryID, @"click_position" : @"icon"}];
    }
    
    [self didSelectWithContext:nil];
}

- (void)updateContentColor
{
    if([self.orderedData hasRead])
    {
        _contentLabel.fontColor = [UIColor tt_themedColorForKey:kColorText3];
    }
    else
    {
        _contentLabel.fontColor = [TTUISettingHelper cellViewTitleColor];
    }
}

- (void)refreshUI
{
    EssayADData *essayAD = self.orderedData.essayADData;
    
    self.contentLabel.text = essayAD.title;
    self.contentLabel.frame = [[self class] frameForContentLabel:self.contentLabel.text cellWidth:self.frame.size.width isList:YES];
    
    self.adBackgroundView.frame = CGRectMake(self.contentLabel.left, self.contentLabel.bottom + 4, self.frame.size.width - 2 * self.contentLabel.left, 49);
    
    self.extLabel.text = essayAD.extTitle;
    CGRect rect = [self.extLabel.text boundingRectWithSize:CGSizeMake(FLT_MAX, FLT_MAX)
                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                       attributes:@{NSFontAttributeName:self.extLabel.font}
                                                   context:nil];
    self.extLabel.frame = CGRectMake(self.contentLabel.left + 10, self.contentLabel.bottom + 4 + 16, rect.size.width + 2, 15);
    self.adLabel.frame = CGRectMake(self.extLabel.right + 4, self.contentLabel.bottom + 4 + 16 + 1.5, 25, 15);
    self.jumpURLButton.frame = CGRectMake(self.frame.size.width - self.contentLabel.left - 10 - 72, self.contentLabel.bottom + 4 + 17 - 7, 72, 29);
    self.jumpURLButton.backgroundColor = [UIColor clearColor];
    [self.jumpURLButton setTitle:@"立即下载" forState:UIControlStateNormal];
    
    if (essayAD.label.length == 0) {
        self.adLabel.hidden = YES;
    } else {
        self.adLabel.hidden = NO;
        self.adLabel.text = essayAD.label;
    }
    
    if (essayAD.title.length == 0) {
        self.jumpURLButton.hidden = YES;
    } else {
        self.jumpURLButton.hidden = NO;
    }

    _sepLineView.frame = CGRectMake(0, self.adBackgroundView.bottom + 15, self.width, [TTDeviceHelper ssOnePixel]);
    if ([TTDeviceHelper isPadDevice]) {
        _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, 0);
    } else {
        _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, kCellSeprateViewHeight());
    }
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    if (!_sepLineView) {
        _sepLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _sepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
        [self addSubview:_sepLineView];
    }
    
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        if ([TTDeviceHelper isPadDevice]) {
            _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        }
        [self addSubview:_bottomView];
    }
}


+ (CGRect)frameForContentLabel:(NSString *)content cellWidth:(CGFloat)width isList:(BOOL)displayInList
{
    CGFloat titleFontSize;
    CGFloat lineH;
    if (displayInList) {
        titleFontSize = [NewsUserSettingManager settedEssayTextFontSize];
        lineH = [NewsUserSettingManager settedEssayTextFontLineHeight];
    }
    else{
        titleFontSize = [NewsUserSettingManager settedEssayDetailViewTextFontSize];
        lineH = [NewsUserSettingManager settedEssayDetailViewTextFontLineHeight];
    }
    UIFont *font = [UIFont systemFontOfSize:titleFontSize];
    
    CGFloat titleWidth = width - kCellLeftPadding - kCellRightPadding;
    CGFloat titleHeight = [MTLabel heightOfText:content lineHeight:lineH font:font width:titleWidth];
    
    CGRect frame = CGRectZero;
    frame.origin.x = kCellLeftPadding;
    frame.origin.y = cellTopPadding();
    frame.size.width = ceilf(titleWidth);
    frame.size.height = ceilf(titleHeight);
    
    return frame;
}


+ (CGFloat)viewTopPadding
{
    if ([TTDeviceHelper isPadDevice]) {
        return 20;
    } else {
        return 11;
    }
}

+ (CGFloat)viewBottomPadding
{
    if ([TTDeviceHelper isPadDevice]) {
        return 20;
    } else {
        return 11;
    }
}

- (void)ssLayoutSubviews {
    [super ssLayoutSubviews];
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    
    _sepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    [self updateContentColor];
    _extLabel.fontColor = [TTUISettingHelper cellViewTitleColor];
}

- (void)fontSizeChanged
{
    CGFloat titleFontSize;
    CGFloat lineH;
    titleFontSize = [NewsUserSettingManager settedEssayTextFontSize];
    lineH = [NewsUserSettingManager settedEssayTextFontLineHeight];
    
    if ([TTDeviceHelper isPadDevice]) {
        _contentLabel.font = [UIFont boldSystemFontOfSize:titleFontSize];
    }
    else {
        _contentLabel.font = [UIFont systemFontOfSize:titleFontSize];
    }
    _contentLabel.lineHeight = lineH;
    [super fontSizeChanged];
}

+ (NSUInteger)cellTypeForCacheHeightFromOrderedData:(id)orderedData
{
    if ([orderedData isKindOfClass:[ExploreOrderedData class]]) {
        // 由于同一个段子cell，位于不同的频道时UI有差别，故缓存高度时须附带频道ID
        return ((ExploreOrderedData *)orderedData).categoryID.hash;
    }
    return [[self class] hash];
}

// override
- (void)layoutInfoLabel
{
    if (![self shouldShowActionButtons]) {
    }
}

- (BOOL)shouldShowActionButtons
{
    // 优化的前提：同一列表中的orderedData有相同的categoryID
//    if (_shouldShowActionButtonsFlag == 0) {
        BOOL bShow = [ExploreCellHelper shouldShowEssayActionButtons:self.orderedData.categoryID];
//        _shouldShowActionButtonsFlag = bShow ? 1 : 2;
//    }
    
//    return (_shouldShowActionButtonsFlag == 1);
    return bShow;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context
{
    if (self.orderedData.uniqueID && self.orderedData.categoryID && context) {
        [TTTrackerWrapper eventV3:@"joke_ad_click" params:@{@"card_id" : self.orderedData.uniqueID, @"category_name" : self.orderedData.categoryID, @"click_position" : @"all"}];
    }
    
    EssayADData *essayAD = self.orderedData.essayADData;
    NSString *downloadURL = essayAD.URL;
    NSString *appleID = essayAD.appID;
    NSString *appName = @"内涵段子";
    
    UIViewController *topViewController = [TTUIResponderHelper topNavigationControllerFor:nil];
    [[SSAppStore shareInstance] openAppStoreByActionURL:downloadURL itunesID:appleID presentController:topViewController appName:appName];
}

@end

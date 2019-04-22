//
//  ExploreArticleSurveyListCellView.m
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "ExploreArticleSurveyListCellView.h"
#import "SurveyListData.h"
#import "MTLabel.h"
#import "NewsUserSettingManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "TTUISettingHelper.h"
#import "SSAppStore.h"
#import "TTThemeManager.h"
#import "TTNetworkDefine.h"
#import "TTNetworkManager.h"
#import "TTNetworkUtilities.h"
#import "TTNetworkTouTiaoDefine.h"
#import "NetworkUtilities.h"
#import "TTDeviceUIUtils.h"
#import "TTAlphaThemedButton.h"
#import "TTFeedDislikeView.h"
#import "ExploreMixListDefine.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOrderedData+TTAd.h"
#import <TTTracker/TTTracker.h>

@interface ExploreArticleSurveyListCellView ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) MTLabel *contentLabel;
@property (nonatomic, strong) SSThemedView *adBackgroundView;
@property (nonatomic, strong) SSThemedButton *unInterestedButton; //不感兴趣
@property (nonatomic, strong) UIView *sepLineView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *feedbackContentLabel;
@property (nonatomic, strong) UILabel *feedbackInfoLabel;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation ExploreArticleSurveyListCellView

- (void)dealloc
{
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.contentLabel];
        [self addSubview:self.adBackgroundView];
        [self addSubview:self.feedbackContentLabel];
        [self addSubview:self.feedbackInfoLabel];
        [self addSubview:self.unInterestedButton];
        [self addSubview:self.bgImageView];
        
        self.buttons = [[NSMutableArray alloc] init];
        for (int i = 0; i < 3; i++) {
            SSThemedButton *btn = [[SSThemedButton alloc] initWithFrame:CGRectZero];
            [btn setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 4;
            btn.backgroundColorThemeKey = kColorBackground7;
            btn.frame = CGRectZero;
            [self.buttons addObject:btn];
            [self addSubview:btn];
        }
    }
    return self;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        NSUInteger cellType = [self cellTypeForCacheHeightFromOrderedData:orderedData];
        CGFloat height = 132;
        if (![TTDeviceHelper isScreenWidthLarge320]) {
            height = 116;
        }
        
        height = height + kCellSeprateViewHeight();
        if (![TTDeviceHelper isPadDevice] && ![orderedData nextCellHasTopPadding]) {
            height += kCellSeprateViewHeight();
        }
        
        if (orderedData.surveyListData.hideNextTime) {
            if ([TTDeviceHelper isPadDevice]) {
                return 0.0f;
            } else {
                CGFloat newHeight = kCellSeprateViewHeight();;
                if ([orderedData nextCellHasTopPadding]) {
                    newHeight -= kCellSeprateViewHeight();
                }
                orderedData.surveyListData.height = height;
                return newHeight;
            }
        }
        
        [orderedData saveCacheHeight:ceilf(height) forListType:listType cellType:cellType];
        orderedData.surveyListData.height = height;
        
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

- (UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
    }
    return _bgImageView;
}

- (SSThemedButton *)unInterestedButton
{
    if (!_unInterestedButton) {
        _unInterestedButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _unInterestedButton.imageName = @"add_textpage.png";
        _unInterestedButton.backgroundColor = [UIColor clearColor];
        [_unInterestedButton addTarget:self action:@selector(unInterestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _unInterestedButton;
}

- (MTLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[MTLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.backgroundColor = [UIColor clearColor];
        CGFloat titleFontSize;
        CGFloat lineH;
        titleFontSize = [TTDeviceUIUtils tt_fontSize:19];
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

- (UILabel *)feedbackContentLabel
{
    if (!_feedbackContentLabel) {
        _feedbackContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _feedbackContentLabel.backgroundColor = [UIColor clearColor];

        _feedbackContentLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:19]];
    }
    return _feedbackContentLabel;
}

- (UILabel *)feedbackInfoLabel
{
    if (!_feedbackInfoLabel) {
        _feedbackInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _feedbackInfoLabel.backgroundColor = [UIColor clearColor];
        _feedbackInfoLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
    }
    return _feedbackInfoLabel;
}

- (SSThemedView *)adBackgroundView
{
    if (!_adBackgroundView) {
        _adBackgroundView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _adBackgroundView.backgroundColorThemeKey = kColorBackground3;
    }
    return _adBackgroundView;
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

- (void)unInterestButtonClicked:(id)sender
{
    [TTFeedDislikeView dismissIfVisible];
    [self showMenu];
}

- (void)showMenu
{
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = self.orderedData.article.filterWords;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = self.unInterestedButton.center;
    [dislikeView showAtPoint:point
                    fromView:self.unInterestedButton
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView {
    if (!self.orderedData) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    
    NSArray *filterWords = [dislikeView selectedWords];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

- (void)refreshUI
{
    SurveyListData *surveyListData = self.orderedData.surveyListData;
    CGFloat bgheight = 116;
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        bgheight = 127;
    }
    self.bgImageView.frame = CGRectMake(0, kCellSeprateViewHeight(), self.width, bgheight);
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
            self.bgImageView.image = [UIImage imageNamed:@"research_card_bg_6"];
        } else {
            self.bgImageView.image = [UIImage imageNamed:@"research_card_bg_night_6"];
        }
    } else {
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
            self.bgImageView.image = [UIImage imageNamed:@"research_card_bg_5"];
        } else {
            self.bgImageView.image = [UIImage imageNamed:@"research_card_bg_night_5"];
        }
    }
    
    self.unInterestedButton.frame = CGRectMake(self.width - 15 - 30 - 8, 0.5 - 3 - 3 + 4 + kCellSeprateViewHeight(), 60, 44);
    
    self.bgImageView.hidden = !self.orderedData.surveyListData.selected;
    
    self.feedbackContentLabel.text = @"感谢你的反馈！";
    self.feedbackContentLabel.textAlignment = NSTextAlignmentCenter;
    self.feedbackContentLabel.frame = CGRectMake(45, 39 + kCellSeprateViewHeight(), self.width - 90, 19.5);
    self.feedbackContentLabel.hidden = !self.orderedData.surveyListData.selected;
    
    self.feedbackInfoLabel.text = @"将帮助我们更好为你提供推荐内容";
    self.feedbackInfoLabel.textAlignment = NSTextAlignmentCenter;
    self.feedbackInfoLabel.frame = CGRectMake(45, 68 + kCellSeprateViewHeight(), self.width - 90, 19.5);
    self.feedbackInfoLabel.hidden = !self.orderedData.surveyListData.selected;
    
    _feedbackContentLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    _feedbackInfoLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    
    self.contentLabel.text = surveyListData.title;
    self.contentLabel.textAlignment = MTLabelTextAlignmentCenter;
    self.contentLabel.frame = CGRectMake(45, 22 - 3 + 4 + kCellSeprateViewHeight(), self.width - 90, 21);
    self.contentLabel.hidden = self.orderedData.surveyListData.selected;
    
    if (self.orderedData.surveyListData.selected) {
        self.orderedData.surveyListData.hideNextTime = YES;
    }
    
    NSUInteger count = surveyListData.selectionInfos.count;
    if (self.buttons.count < count) {
        NSUInteger btnCount = self.buttons.count;
        for (int i = 0; i < (count - btnCount); ++i) {
            SSThemedButton *btn = [[SSThemedButton alloc] initWithFrame:CGRectZero];
            [btn setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 4;
            btn.backgroundColorThemeKey = kColorBackground7;
            btn.frame = CGRectZero;
            [self.buttons addObject:btn];
            [self addSubview:btn];
        }
    }
    
    for (SSThemedButton *btn in self.buttons) {
        btn.frame = CGRectZero;
        [btn setTitle:@"" forState:UIControlStateNormal];
        btn.hidden = self.orderedData.surveyListData.selected;
    }
    
    CGFloat width = 76;
    CGFloat gap = [TTDeviceUIUtils tt_padding:30];
    int index = 0;
    CGFloat offset = 0;
    if (![TTDeviceHelper isScreenWidthLarge320]) {
        offset = -6;
        width = 72;
        gap = 27;
    }
    CGFloat start = (self.frame.size.width - width * count - gap * (count - 1)) / 2.0;
    for (SurveySelectionInfo *info in surveyListData.selectionInfos) {
        SSThemedButton *btn = [self.buttons objectAtIndex:index];
        [btn setTitle:info.label forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        btn.frame = CGRectMake(start, self.contentLabel.bottom + 25 +3 + offset, width, 28);
        btn.tag = index;
        index++;
        start += (width + gap);
        [btn addTarget:self action:@selector(didClick:) forControlEvents:UIControlEventTouchUpInside];
    }

    _sepLineView.frame = CGRectMake(0, 126 + 6, self.width, 0);
    _topView.frame = CGRectMake(0, 0, self.width, kCellSeprateViewHeight());
    if (![TTDeviceHelper isPadDevice] && ![self.orderedData nextCellHasTopPadding]) {
        _bottomView.frame = CGRectMake(0, self.height-kCellSeprateViewHeight(), self.width, kCellSeprateViewHeight());
    } else {
        _bottomView.frame = CGRectZero;
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
    
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        if ([TTDeviceHelper isPadDevice]) {
            _topView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        }
        [self addSubview:_topView];
    }
}

- (void)didClick:(SSThemedButton *)btn
{
    self.orderedData.surveyListData.selected = YES;
    
    for (SSThemedButton *button in self.buttons) {
        button.hidden = YES;
    }
    self.contentLabel.hidden = YES;
    self.feedbackContentLabel.hidden = NO;
    self.feedbackInfoLabel.hidden = NO;
    self.bgImageView.hidden = NO;
    
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setObject:@"list" forKey:@"survey_type"];
    [para setObject:@(btn.tag) forKey:@"prefer_id"];
    [para setValue:self.orderedData.surveyListData.evaluateID forKey:@"evaluate_id"];
    NSString *uniqueID = @"";
    if (self.orderedData.uniqueID) {
        uniqueID = self.orderedData.uniqueID;
    }
    [TTTrackerWrapper eventV3:@"survey_selection_button_click" params:@{@"type" : @"list", @"survey_id" : uniqueID, @"index" : @(btn.tag)}];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:@"http://ci.toutiao.com/eva/survey/"
                                                     params:para
                                                     method:@"POST"
                                           needCommonParams:YES
                                                   callback:^(NSError *error, id jsonObj) {
                                                   }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreOriginalDataUpdateNotification
                                                        object:nil
                                                      userInfo:@{@"uniqueID":@"survey_list_reload"}];
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
    
    _feedbackContentLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    _feedbackInfoLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    
    _sepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    _topView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    [self updateContentColor];
    
    for (SSThemedButton *btn in self.buttons) {
        btn.backgroundColorThemeKey = kColorBackground7;
        [btn setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
    }
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
            self.bgImageView.image = [UIImage imageNamed:@"research_card_bg_6"];
        } else {
            self.bgImageView.image = [UIImage imageNamed:@"research_card_bg_night_6"];
        }
    } else {
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
            self.bgImageView.image = [UIImage imageNamed:@"research_card_bg_5"];
        } else {
            self.bgImageView.image = [UIImage imageNamed:@"research_card_bg_night_5"];
        }
    }
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
}

@end

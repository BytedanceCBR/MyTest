//
//  ExploreArticleSurveyPairCellView.m
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "ExploreArticleSurveyPairCellView.h"
#import "SurveyPairData.h"
#import "MTLabel.h"
#import "NewsUserSettingManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "TTUISettingHelper.h"
#import "SSAppStore.h"
#import "TTRoute.h"
#import "TTImageView+TrafficSave.h"
#import "TTThemeManager.h"
#import "TTFeedDislikeView.h"
#import "TTAlphaThemedButton.h"
#import "ExploreMixListDefine.h"
#import "TTNetworkDefine.h"
#import "TTNetworkManager.h"
#import "TTNetworkUtilities.h"
#import "TTNetworkTouTiaoDefine.h"
#import "NetworkUtilities.h"
#import "ExploreOrderedData+TTAd.h"

@interface ExploreArticleSurveyPairCellView ()

@property (nonatomic, strong) MTLabel *contentLabel;
@property (nonatomic, strong) SSThemedView *adBackgroundView;
@property (nonatomic, strong) UIView *upSepLineView;
@property (nonatomic, strong) UIView *midSepLineView;
@property (nonatomic, strong) UIView *downSepLineView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) ExploreArticleSurveyPairCellChildView *upPairView;
@property (nonatomic, strong) ExploreArticleSurveyPairCellChildView *downPairView;

@property (nonatomic, strong) SSThemedButton *unInterestedButton; //不感兴趣

@property (nonatomic, strong) UILabel *feedbackContentLabel;
@property (nonatomic, strong) UILabel *feedbackInfoLabel;
@property (nonatomic, strong) UIImageView *bgImageView;

@end

@implementation ExploreArticleSurveyPairCellView

- (void)dealloc
{
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.contentLabel];
        [self addSubview:self.adBackgroundView];
        [self addSubview:self.upPairView];
        [self addSubview:self.downPairView];
        [self addSubview:self.feedbackContentLabel];
        [self addSubview:self.feedbackInfoLabel];
        [self addSubview:self.bgImageView];
        [self addSubview:self.unInterestedButton];
    }
    return self;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        NSUInteger cellType = [self cellTypeForCacheHeightFromOrderedData:orderedData];
        CGFloat height = 236;
        height += kCellSeprateViewHeight();
        
        if (orderedData.surveyPairData.selectedArticle ) {
            height = 132;
            if (![TTDeviceHelper isScreenWidthLarge320]) {
                height = 116;
            }
            height += kCellSeprateViewHeight();
        }
        
        if (![TTDeviceHelper isPadDevice] && ![orderedData nextCellHasTopPadding]) {
            height += kCellSeprateViewHeight();
        }
        
        if (orderedData.surveyPairData.hideNextTime) {
            if ([TTDeviceHelper isPadDevice]) {
                return 0.0f;
            } else {
                CGFloat hgt = kCellSeprateViewHeight();;
                if ([orderedData nextCellHasTopPadding]) {
                    hgt -= kCellSeprateViewHeight();
                }
                orderedData.surveyPairData.height = height;
                return hgt;
            }
        }
        
        orderedData.surveyPairData.height = height;
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

- (UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _bgImageView;
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

- (ExploreArticleSurveyPairCellChildView *)upPairView
{
    if (!_upPairView) {
        _upPairView = [[ExploreArticleSurveyPairCellChildView alloc] initWithFrame:CGRectZero];
        _upPairView.mainCell = self;
    }
    return _upPairView;
}

- (ExploreArticleSurveyPairCellChildView *)downPairView
{
    if (!_downPairView) {
        _downPairView = [[ExploreArticleSurveyPairCellChildView alloc] initWithFrame:CGRectZero];
        _downPairView.mainCell = self;
        
    }
    return _downPairView;
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
        _contentLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        _contentLabel.lineHeight = lineH;
        [_contentLabel setContentMode:UIViewContentModeRedraw];
    }
    return _contentLabel;
}

- (SSThemedView *)adBackgroundView
{
    if (!_adBackgroundView) {
        _adBackgroundView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _adBackgroundView.backgroundColorThemeKey = kColorBackground3;
    }
    return _adBackgroundView;
}

- (void)didReadArticle:(Article *)article
{
    Article *article1 = self.orderedData.surveyPairData.article1;
    Article *article2 = self.orderedData.surveyPairData.article2;
    if (article == article1) {
        self.orderedData.surveyPairData.hasReadUpActicle = YES;
    } else if (article == article2) {
        self.orderedData.surveyPairData.hasReadDownActicle = YES;
    } else {
    }
}

- (void)didSelectArticle:(Article *)article
{
    self.contentLabel.hidden = YES;
    self.adBackgroundView.hidden = YES;
    self.upPairView.hidden = YES;
    self.downPairView.hidden = YES;
    self.upSepLineView.hidden = YES;
    self.midSepLineView.hidden = YES;
    self.downSepLineView.hidden = YES;
    self.bgImageView.hidden = NO;
    self.feedbackContentLabel.hidden = NO;
    self.feedbackInfoLabel.hidden = NO;
    
    self.contentLabel.text = @"感谢您的反馈！";
    
    if (self.orderedData.surveyPairData.selectedArticle) {
        //return;
    }
   self.orderedData.surveyPairData.selectedArticle = article;
    
    NSInteger index = -1;
    Article *article1 = self.orderedData.surveyPairData.article1;
    Article *article2 = self.orderedData.surveyPairData.article2;
    if (self.orderedData.surveyPairData.selectedArticle == article1) {
        index = 0;
        self.upPairView.selectionStatus = SurveyPairCellSelectionStatusSelected;
        self.downPairView.selectionStatus = SurveyPairCellSelectionStatusUnselected;
    } else if (self.orderedData.surveyPairData.selectedArticle == article2) {
        index = 1;
        self.upPairView.selectionStatus = SurveyPairCellSelectionStatusUnselected;
        self.downPairView.selectionStatus = SurveyPairCellSelectionStatusSelected;
    } else {
        self.upPairView.selectionStatus = SurveyPairCellSelectionStatusNormal;
        self.downPairView.selectionStatus = SurveyPairCellSelectionStatusNormal;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreOriginalDataUpdateNotification
                                                        object:nil
                                                      userInfo:@{@"uniqueID":@"survey_pair_reload"}];
    
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setObject:@"pair" forKey:@"survey_type"];
    [para setObject:@(index) forKey:@"prefer_id"];
    [para setValue:self.orderedData.surveyPairData.evaluateID forKey:@"evaluate_id"];
    NSString *uniqueID = @"";
    if (self.orderedData.uniqueID) {
        uniqueID = self.orderedData.uniqueID;
    }
    [TTTrackerWrapper eventV3:@"survey_selection_button_click" params:@{@"type" : @"pair", @"survey_id" : uniqueID, @"index" : @(index)}];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:@"http://ci.toutiao.com/eva/survey/"
                                                     params:para
                                                     method:@"POST"
                                           needCommonParams:YES
                                                   callback:^(NSError *error, id jsonObj) {
                                                   }];
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

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView
{
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
    SurveyPairData *surveyPairData = self.orderedData.surveyPairData;
    
    Article *article1 = self.orderedData.surveyPairData.article1;
    Article *article2 = self.orderedData.surveyPairData.article2;
    self.upPairView.hasRead = self.orderedData.surveyPairData.hasReadUpActicle;
    self.upPairView.article = article1;
    self.downPairView.hasRead = self.orderedData.surveyPairData.hasReadDownActicle;
    self.downPairView.article = article2;
    
    CGFloat bgheight = 116;
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        bgheight = 127;
    }
    
    self.bgImageView.frame = CGRectMake(0, kCellSeprateViewHeight(), [UIScreen mainScreen].bounds.size.width, bgheight);
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
    
    self.feedbackContentLabel.text = @"感谢你的反馈！";
    self.feedbackContentLabel.textAlignment = NSTextAlignmentCenter;
    self.feedbackContentLabel.frame = CGRectMake(45, 39 + kCellSeprateViewHeight(), [UIScreen mainScreen].bounds.size.width - 90, 19.5);
    
    self.feedbackInfoLabel.text = @"将帮助我们更好为你提供推荐内容";
    self.feedbackInfoLabel.textAlignment = NSTextAlignmentCenter;
    self.feedbackInfoLabel.frame = CGRectMake(45, 68 + kCellSeprateViewHeight(), [UIScreen mainScreen].bounds.size.width - 90, 19.5);
    
    _feedbackContentLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    _feedbackInfoLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    
    if (self.orderedData.surveyPairData.selectedArticle) {
        self.contentLabel.text = @"感谢你的反馈！";
        
        if (self.orderedData.surveyPairData.selectedArticle == article1) {
            self.upPairView.selectionStatus = SurveyPairCellSelectionStatusSelected;
            self.downPairView.selectionStatus = SurveyPairCellSelectionStatusUnselected;
        } else if (self.orderedData.surveyPairData.selectedArticle == article2) {
            self.upPairView.selectionStatus = SurveyPairCellSelectionStatusUnselected;
            self.downPairView.selectionStatus = SurveyPairCellSelectionStatusSelected;
        } else {
        }
        
        self.contentLabel.hidden = YES;
        self.upPairView.hidden = YES;
        self.downPairView.hidden = YES;
        self.bgImageView.hidden = NO;
        self.feedbackContentLabel.hidden = NO;
        self.feedbackInfoLabel.hidden = NO;
        
        self.orderedData.surveyPairData.hideNextTime = YES;
        
    } else {
        self.contentLabel.text = surveyPairData.title;
        
        self.contentLabel.hidden = NO;
        self.upPairView.hidden = NO;
        self.downPairView.hidden = NO;
        self.bgImageView.hidden = YES;
        self.feedbackContentLabel.hidden = YES;
        self.feedbackInfoLabel.hidden = YES;
    }
    
    self.unInterestedButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 30 - 8, 0.5 - 3 + kCellSeprateViewHeight(), 60, 44);
    self.contentLabel.frame = CGRectMake(kCellLeftPadding, 10 + kCellSeprateViewHeight(), [UIScreen mainScreen].bounds.size.width - 2 * kCellLeftPadding, 17);
    _upSepLineView.frame = CGRectMake(kCellLeftPadding, self.contentLabel.bottom + 10, [UIScreen mainScreen].bounds.size.width - 2 * kCellLeftPadding, [TTDeviceHelper ssOnePixel]);
    self.upPairView.frame = CGRectMake(0, self.upSepLineView.bottom + 1 -1, [UIScreen mainScreen].bounds.size.width, 96.5);
    _midSepLineView.frame = CGRectMake(kCellLeftPadding, self.upPairView.bottom, [UIScreen mainScreen].bounds.size.width - 2 * kCellLeftPadding, [TTDeviceHelper ssOnePixel]);
    self.downPairView.frame = CGRectMake(0, self.upPairView.bottom + 1 - 1, [UIScreen mainScreen].bounds.size.width, 96.5);
    _downSepLineView.frame = CGRectMake(0, self.downPairView.bottom + 0, [UIScreen mainScreen].bounds.size.width, 0);
    _topView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kCellSeprateViewHeight());
    
    if (![TTDeviceHelper isPadDevice] && ![self.orderedData nextCellHasTopPadding]) {
        _bottomView.frame = CGRectMake(0, self.height - kCellSeprateViewHeight(), [UIScreen mainScreen].bounds.size.width, kCellSeprateViewHeight());
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
    
    if (!_upSepLineView) {
        _upSepLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _upSepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
        [self addSubview:_upSepLineView];
    }
    
    if (!_midSepLineView) {
        _midSepLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _midSepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
        [self addSubview:_midSepLineView];
    }
    
    if (!_downSepLineView) {
        _downSepLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _downSepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
        [self addSubview:_downSepLineView];
    }
    
    if (!_downSepLineView) {
        _downSepLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _downSepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
        [self addSubview:_downSepLineView];
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
    _upSepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    _midSepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    _downSepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    _topView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    
    [self updateContentColor];
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


@interface ExploreArticleSurveyPairCellChildView ()

@property (nullable, nonatomic, strong) TTImageView *imageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *extraLabel;
@property (nonatomic, strong) SSThemedLabel *commentLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) TTImageView *selectionView;
@property (nonatomic, strong) SSThemedButton *selectionButton;
@property (nonatomic, strong) SSThemedImageView *videoIcon;

@end

@implementation ExploreArticleSurveyPairCellChildView

- (void)dealloc
{
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.extraLabel];
        [self addSubview:self.commentLabel];
        [self addSubview:self.selectionView];
        [self addSubview:self.selectionButton];
        [self addSubview:self.lineView];
        [self addSubview:self.videoIcon];
        
        self.selectionStatus = SurveyPairCellSelectionStatusNormal;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClick)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *selectTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelect)];
        selectTap.numberOfTouchesRequired = 1;
        selectTap.numberOfTapsRequired = 1;
        [self.selectionView addGestureRecognizer:selectTap];
    }
    return self;
}

- (SSThemedImageView *)videoIcon
{
    if (_videoIcon == nil) {
        _videoIcon = [[SSThemedImageView alloc] initWithFrame:CGRectMake(34, 33.5, 30, 30)];
        _videoIcon.imageName = @"Play";
        _videoIcon.hidden = YES;
    }
    return _videoIcon;
}

- (void)didClick
{
    self.titleLabel.textColor = [UIColor colorWithDayColorName:@"999999" nightColorName:@"505050"];
    [self.mainCell didReadArticle:self.article];
    
    NSString *detailHost = @"detail";
    NSString *detailURL = [NSString stringWithFormat:@"sslocal://%@?groupid=%@", detailHost, self.article.groupID];
    [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:detailURL] userInfo:nil];
}

- (void)didSelect
{
    if (self.mainCell.selected) {
        return;
    }
    
    self.selectionStatus = SurveyPairCellSelectionStatusSelected;
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
        UIImage *selectionImage = [UIImage imageNamed:@"select_on"];
        [self.selectionView setImage:selectionImage];
    } else {
        UIImage *selectionImage = [UIImage imageNamed:@"select_on_night"];
        [self.selectionView setImage:selectionImage];
    }
    
    [self.mainCell didSelectArticle:self.article];
}

- (void)setSelectionStatus:(SurveyPairCellSelectionStatus)selectionStatus
{
    _selectionStatus = selectionStatus;
    
    if (_selectionStatus == SurveyPairCellSelectionStatusNormal) {
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
            UIImage *selectionImage = [UIImage imageNamed:@"select"];
            [self.selectionView setImage:selectionImage];
        } else {
            UIImage *selectionImage = [UIImage imageNamed:@"select_night"];
            [self.selectionView setImage:selectionImage];
        }
    }
    
    if (_selectionStatus == SurveyPairCellSelectionStatusSelected) {
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
            UIImage *selectionImage = [UIImage imageNamed:@"select_on"];
            [self.selectionView setImage:selectionImage];
        } else {
            UIImage *selectionImage = [UIImage imageNamed:@"select_on_night"];
            [self.selectionView setImage:selectionImage];
        }
    }
    
    if (_selectionStatus == SurveyPairCellSelectionStatusUnselected) {
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
            UIImage *selectionImage = [UIImage imageNamed:@"select_gray"];
            [self.selectionView setImage:selectionImage];
        } else {
            UIImage *selectionImage = [UIImage imageNamed:@"select_gray_night"];
            [self.selectionView setImage:selectionImage];
        }
    }
}

- (void)setArticle:(Article *)article
{
    _article = article;
    [self updateContentWithArticle:article];
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    
    self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.extraLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    self.commentLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    self.lineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    self.imageView.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    self.selectionButton.backgroundColorThemeKey = kColorBackground7;
    [self.selectionButton setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
    
    if (_selectionStatus == SurveyPairCellSelectionStatusNormal) {
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
            UIImage *selectionImage = [UIImage imageNamed:@"select"];
            [self.selectionView setImage:selectionImage];
        } else {
            UIImage *selectionImage = [UIImage imageNamed:@"select_night"];
            [self.selectionView setImage:selectionImage];
        }
    }
    
    if (_selectionStatus == SurveyPairCellSelectionStatusSelected) {
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
            UIImage *selectionImage = [UIImage imageNamed:@"select_on"];
            [self.selectionView setImage:selectionImage];
        } else {
            UIImage *selectionImage = [UIImage imageNamed:@"select_on_night"];
            [self.selectionView setImage:selectionImage];
        }
    }
    
    if (_selectionStatus == SurveyPairCellSelectionStatusUnselected) {
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
            UIImage *selectionImage = [UIImage imageNamed:@"select_gray"];
            [self.selectionView setImage:selectionImage];
        } else {
            UIImage *selectionImage = [UIImage imageNamed:@"select_gray_night"];
            [self.selectionView setImage:selectionImage];
        }
    }
}

- (void)updateContentWithArticle:(Article *)article
{
    self.imageView.frame = CGRectMake(15, 14.5, 68, 68);
    self.videoIcon.center = self.imageView.center;
    if ([article.hasVideo boolValue]) {
        self.videoIcon.hidden = NO;
    } else {
        self.videoIcon.hidden = YES;
    }
    
    TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:[article middleImageDict]];
    UIImage *image = [UIImage imageNamed:@"default_feed_share_icon"];
    [self.imageView setImageWithModelInTrafficSaveMode:model placeholderImage:image];
    
    self.titleLabel.frame = CGRectMake(15 + 68 + 10, 15.5 - 0.5 + 1 - 1, [UIScreen mainScreen].bounds.size.width - 58 - (15 + 68 + 10) - 15 - 15, 48);
    if (self.hasRead) {
        self.titleLabel.textColor = [UIColor colorWithDayColorName:@"999999" nightColorName:@"505050"];
    }
    else {
        self.titleLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    }

    if (article.abstract.length == 0) {
        article.abstract = article.title;
    }
    
    CGRect rect = [article.abstract boundingRectWithSize:CGSizeMake(self.titleLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]]} context:nil];
    CGSize textSize = [article.abstract sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]]}];
    NSUInteger textRow = (NSUInteger)(rect.size.height / textSize.height);
    
    NSInteger fix = 0;
    if (textRow < 2) {
        fix = 15;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:article.abstract];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:[TTDeviceUIUtils tt_padding:4.5f]];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [article.abstract length])];
    self.titleLabel.attributedText = attributedString;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.extraLabel.frame = CGRectMake(15 + 68 + 10, self.titleLabel.bottom + 3 - fix, 12.5 * article.source.length + 6, 13);
    self.extraLabel.text = article.source;
    self.extraLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    
    self.commentLabel.frame = CGRectMake(self.extraLabel.right + 1, self.titleLabel.bottom + 3 - fix, 100, 13);
    if (article.commentCount > 0) {
        self.commentLabel.hidden = NO;
        self.commentLabel.text = [NSString stringWithFormat:@"%d评论", article.commentCount];
    } else {
        self.commentLabel.hidden = YES;
    }
    self.commentLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    
    self.selectionButton.frame = CGRectMake(self.titleLabel.right + 15, 34.5, 58, 28);
    self.selectionButton.layer.masksToBounds = YES;
    self.selectionButton.layer.cornerRadius = 4;
    [self.selectionButton setTitle:@"选这个" forState:UIControlStateNormal];
    
    self.lineView.frame = CGRectZero;
    self.selectionView.frame = CGRectZero;
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        
    }
    return _lineView;
}

- (SSThemedButton *)selectionButton
{
    if (!_selectionButton) {
        _selectionButton = [[SSThemedButton alloc] initWithFrame:CGRectZero];
        _selectionButton.backgroundColorThemeKey = kColorBackground7;
        [_selectionButton setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
        _selectionButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        [_selectionButton addTarget:self action:@selector(didSelect) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectionButton;
}

- (TTImageView *)selectionView
{
    if (!_selectionView) {
        _selectionView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _selectionView.enableNightCover = NO;
    }
    return _selectionView;
}

- (TTImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _imageView.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    }
    return _imageView;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.text = @"";
        _titleLabel.size = CGSizeMake(26, 14);
        _titleLabel.borderColorThemeKey = kColorText1;
    }
    return _titleLabel;
}

- (SSThemedLabel *)extraLabel
{
    if (!_extraLabel) {
        _extraLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _extraLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _extraLabel.textAlignment = NSTextAlignmentLeft;
        _extraLabel.text = @"";
        _extraLabel.size = CGSizeMake(26, 14);
        _extraLabel.textColorThemeKey = kColorText3;
        _extraLabel.borderColorThemeKey = kColorText3;
    }
    return _extraLabel;
}

- (SSThemedLabel *)commentLabel
{
    if (!_commentLabel) {
        _commentLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _commentLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _commentLabel.textAlignment = NSTextAlignmentLeft;
        _commentLabel.text = @"";
        _commentLabel.size = CGSizeMake(26, 14);
        _commentLabel.textColorThemeKey = kColorText3;
        _commentLabel.borderColorThemeKey = kColorText3;
    }
    return _commentLabel;
}

@end


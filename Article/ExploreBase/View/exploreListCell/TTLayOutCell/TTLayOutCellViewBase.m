//
//  TTLayOutCellViewBase.m
//  Article
//
//  Created by 王双华 on 16/10/13.
//
//

#import "TTLayOutCellViewBase.h"
#import "TTLayOutCellViewBase+UGCCell.h"
#import "TTLayOutCellViewBase+UFCell.h"
#import "TTNetworkManager.h"
#import "TTFollowNotifyServer.h"
#import "SSImpressionModel.h"
#import "FriendDataManager.h"
#import "TTVideoAutoPlayManager.h"
#import "TTArticleCategoryManager.h"
//#import "TTPostThreadViewController.h"
#import "SSWebViewController.h"
//#import "TTRepostViewController.h"
//#import "TTRepostOriginModels.h"
#import <TTRelevantDurationTracker.h>
#import "TTPlatformSwitcher.h"
#import "TTFeedDislikeView.h"
//#import "TTRecommendUserCollectionViewWrapper.h"
#import "TTLayOutUFLargePicCellModel.h"
//#import "RecommendCardCache.h"
#import <TTTracker/TTTrackerProxy.h>
#import <TTAccountBusiness.h>
#import "TTRichSpanText+Emoji.h"
#import "UILabel+Tapping.h"

#import <TTServiceKit/TTServiceCenter.h>
//#import "TTRedPacketManager.h"
#import "TTAuthorizeManager.h"
#import "Card+CoreDataClass.h"
#import "TTTrackerProxy.h"

#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"
#import "SSADEventTracker.h"
#import "TTADAppStoreContainerController.h"
#import "TTADAppStoreContainerViewModel.h"
#import "TTAdAction.h"
#import "TTAdAppointAlertView.h"
#import "TTAdDetailActionModel.h"
#import "TTAdFeedModel.h"
#import "TTAdImpressionTracker.h"
#import "TTAdManager.h"
#import "TTAdManagerProtocol.h"
#import "TTAdMonitorManager.h"

#import "JSONAdditions.h"

extern BOOL ttvs_isVideoFeedURLEnabled(void);

@interface TTLayOutCellViewBase() </*TTRecommendUserCollectionViewDelegate,*/ TTLabelTappingDelegate>
// 优化：系统prepareforCell时会调用setHighlighted:NO，setSelected:NO，函数中代码会在列表滚动时调用，记录此变量避免不必要的调用
@property (nonatomic, assign) BOOL                              isViewHighlighted;
@property (nonatomic, strong) FriendDataManager                *friendManager;
//推人卡片
//@property (nonatomic, strong) TTRecommendUserCollectionViewWrapper *collectionViewWrapper;
@property (nonatomic, strong) SSThemedButton *foldRecommendButton;
@property (nonatomic, strong) SSThemedImageView *sanjiaoIcon;
@property (nonatomic, assign) BOOL folding;
@property (nonatomic, assign) BOOL reuseinit;
@property (nonatomic, assign) BOOL                      handlingExpand;

@end

@implementation TTLayOutCellViewBase

- (void)dealloc
{
    self.orderedData = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        [self setLabelsColorClear:NO];
        [self setupSubViewsForCommon];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readModeChanged:) name:kReadModeChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeStatusChanged:) name:kEntrySubscribeStatusChangedNotification object:nil];
    }
    return self;
}

- (NSUInteger)refer {
    return [[self cell] refer];
}

- (void)setOrderedData:(ExploreOrderedData *)orderedData {
    _orderedData = orderedData;
    self.reuseinit = YES;
    if (_orderedData) {
        self.originalData = [_orderedData originalData];
    } else {
        self.originalData = nil;
    }
}

- (id)cellData {
    return [self orderedData];
}

- (BOOL)shouldRefresh {
    if ([[self originalData] needRefreshUI]) {
        return [[self originalData] needRefreshUI];
    }
    return NO;
}

- (void)refreshDone {
    if ([self originalData]) {
        [[self originalData] setNeedRefreshUI:NO];
    }
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    [self setLabelsColorClear:NO];
    
    self.titleLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    self.titleLabel.highlightedTextColor = [TTUISettingHelper cellViewHighlightedtTitleColor];
    
    self.commentLabel.highlightedTextColor = [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"%@%@", kCellCommentViewTextColor, @"Highlighted"]];
    
    [self layoutTypeLabel];
    
    [self updateContentColor];
}

- (void)updateContentColor
{
    ExploreOriginalData *originalData = self.orderedData.originalData;
    if (originalData.managedObjectContext)
    {
        BOOL hasRead = [self.orderedData hasRead];
        if ([self.orderedData.categoryID isEqualToString:kTTFollowCategoryID]) {
            hasRead = NO;
        }
        self.titleLabel.highlighted = hasRead;
        self.commentLabel.highlighted = hasRead;
        self.abstractLabel.highlighted = hasRead;
        if ([self.orderedData isUGCCell]) {
            self.sourceLabel.highlighted = hasRead;
            self.entityLabel.highlighted = hasRead;
        }
        else if ([self.orderedData isPlainCell]){
            self.sourceLabel.highlighted = hasRead;
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted)
    {
        if (!self.isViewHighlighted) {
            [self setLabelsColorClear:YES];
            self.backgroundView.alpha = 0.5f;
            self.backgroundColor = [TTUISettingHelper cellViewHighlightedBackgroundColor];
            self.isViewHighlighted = YES;
        }
    }
    else
    {
        if (self.isViewHighlighted) {
            [self setLabelsColorClear:NO];
            self.backgroundView.alpha = 1.f;
            self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
            self.isViewHighlighted = NO;
        }
    }
}

- (void)setLabelsColorClear:(BOOL)clear
{
    UIColor *color;
    
    if (clear) {
        color = [UIColor clearColor];
    } else {
        color = [TTUISettingHelper cellViewBackgroundColor];
    }
    
    _titleLabel.backgroundColor = color;
    _subTitleLabel.backgroundColor = color;
    _sourceLabel.backgroundColor = color;
    _typeLabel.backgroundColor = color;
    _abstractLabel.backgroundColor = color;
    _commentLabel.backgroundColor = color;
    _infoLabel.backgroundColor = color;
    _likeLabel.backgroundColor = color;
    _entityLabel.backgroundColor = color;
    _subscriptLabel.backgroundColor = color;
    _timeLabel.backgroundColor = color;
    _digButton.backgroundColor = color;
    _commentButton.backgroundColor = color;
    _forwardButton.backgroundColor = color;
    _userNameLabel.backgroundColor = color;
    _userVerifiedLabel.backgroundColor = color;
    _recommendLabel.backgroundColor = color;
}

- (void)readModeChanged:(NSNotification*)notification
{
    [self refreshUI];
}

- (void)subscribeStatusChanged:(NSNotification *)notification
{
    [self calculateFrameAndRefreshUI];
}

- (void)fontSizeChanged
{
    [self calculateFrameAndRefreshUI];
}

- (void)calculateFrameAndRefreshUI
{
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    self.orderedData.cellLayOut.needUpdateAllFrame = YES;
    //    [self refreshUI];
    //});
    
    // 只处理主线程的修改，忽略子线程中插入数据库过程中的修改，解决由此导致的crash
    if ([NSThread isMainThread]) {
        self.orderedData.cellLayOut.needUpdateAllFrame = YES;
        [self refreshUI];
    }
}

- (void)willAppear {
    if (self.orderedData.cellLayOut.isExpand) {
//        [self.collectionViewWrapper.collectionView willDisplay];
    }
}

- (void)didDisappear {
    if (self.orderedData.cellLayOut.isExpand) {
//        [self.collectionViewWrapper.collectionView didEndDisplaying];
    }
}

- (FriendDataManager *)friendManager {
    if (_friendManager == nil) {
        _friendManager = [[FriendDataManager alloc] init];
    }
    return _friendManager;
}

- (TTVideoEmbededAdButton *)adButton
{
    if (!_adButton && [self.orderedData.adModel isCreativeAd]) {
        _adButton = [[TTVideoEmbededAdButton alloc] init];
    }
    _adButton.actionModel = self.orderedData;
    
    return _adButton;
}

/**
 设置列表cell基本样式
 */
- (void)setupSubViewsForCommon
{
    [self setupSubviewsForUGCCell];
    [self setupSubviewsForUFCell];
    /** 标题 */
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    titleLabel.highlightedTextColor = [TTUISettingHelper cellViewHighlightedtTitleColor];
    titleLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    titleLabel.clipsToBounds = YES;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    /** 图片 */
    TTArticlePicView *picView = [[TTArticlePicView alloc] initWithStyle:TTArticlePicViewStyleNone];
    [self addSubview:picView];
    self.picView = picView;
    
    /** 来源图片 */
    TTAsyncCornerImageView *sourceImageView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectZero allowCorner:YES];
    sourceImageView.borderWidth = 0.0f;
    [sourceImageView addTouchTarget:self action:@selector(sourceImageClick)];
    [self addSubview:sourceImageView];
    self.sourceImageView = sourceImageView;
    /** 来源 */
    SSThemedLabel *sourceLabel = [[SSThemedLabel alloc] init];
    sourceLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    sourceLabel.clipsToBounds = YES;
    UITapGestureRecognizer *sourceLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sourceImageClick)];
    [sourceLabel addGestureRecognizer:sourceLabelTapGestureRecognizer];
    [self addSubview:sourceLabel];
    self.sourceLabel = sourceLabel;
    /** 信息栏 位于来源后 */
    SSThemedLabel *infoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    infoLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    infoLabel.clipsToBounds = YES;
    [self addSubview:infoLabel];
    self.infoLabel = infoLabel;
    
    SSThemedImageView *sanjiaoIcon = [[SSThemedImageView alloc] init];
    sanjiaoIcon.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    sanjiaoIcon.imageName = @"sanjiao";
    sanjiaoIcon.width = 12;
    sanjiaoIcon.height = 5;
    sanjiaoIcon.alpha = 0;
    [self addSubview:sanjiaoIcon];
    self.sanjiaoIcon = sanjiaoIcon;
    /** 直播标签 */
    SSThemedLabel *liveTextLabel = [[SSThemedLabel alloc] init];
    liveTextLabel.text = @"直播";
    liveTextLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:10]];
    liveTextLabel.textColorThemeKey = kColorText8;
    liveTextLabel.backgroundColorThemeKey = kColorBackground15;
    liveTextLabel.textAlignment = NSTextAlignmentCenter;
    liveTextLabel.layer.cornerRadius = kCellPicLabelCornerRadius;
    liveTextLabel.clipsToBounds = YES;
    liveTextLabel.hidden = YES;
    SSThemedView *redDot = [[SSThemedView alloc] initWithFrame:CGRectMake(6, _liveTextLabel.height/2 - 3, 6, 6)];
    redDot.backgroundColorThemeKey = kColorText4;
    redDot.layer.cornerRadius = 3;
    [liveTextLabel addSubview:redDot];
    liveTextLabel.contentInset = UIEdgeInsetsMake(0, 3, 0, 0);
    liveTextLabel.right = self.picView.width - 6;
    liveTextLabel.bottom = self.picView.height - 6;
    liveTextLabel.hidden = YES;
    [self.picView addSubview:liveTextLabel];
    self.liveTextLabel = liveTextLabel;
    /** 类型标签 */
    SSThemedLabel *typeLabel =[[SSThemedLabel alloc] init];
    typeLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    typeLabel.textAlignment  = NSTextAlignmentCenter;
    typeLabel.font = [UIFont systemFontOfSize:kCellTypeLabelFontSize];
    typeLabel.layer.cornerRadius = kCellTypeLabelCornerRadius;
    typeLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    [self addSubview:typeLabel];
    self.typeLabel = typeLabel;
    /** 顶按钮 */
    TTAlphaThemedButton *digButton = [[TTAlphaThemedButton alloc] init];
    digButton.selectedTitleColorThemeKey = kColorText4;
    digButton.highlightedTitleColorThemeKey = kColorText4;
    digButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [digButton addTarget:self action:@selector(digButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    digButton.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    digButton.hitTestEdgeInsets = UIEdgeInsetsMake(-16, 0, -16, -16);
    [self addSubview:digButton];
    self.digButton = digButton;
    /** 评论按钮 */
    TTAlphaThemedButton *commentButton = [[TTAlphaThemedButton alloc] init];
    commentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [commentButton addTarget:self action:@selector(commentButtonClick) forControlEvents: UIControlEventTouchUpInside];
    commentButton.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    commentButton.hitTestEdgeInsets = UIEdgeInsetsMake(-16, 0, -16, -16);
    [self addSubview:commentButton];
    self.commentButton = commentButton;
    /** 转发按钮 */
    TTAlphaThemedButton *forwardButton = [[TTAlphaThemedButton alloc] init];
    forwardButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [forwardButton addTarget:self action:@selector(forwardButtonClick) forControlEvents:UIControlEventTouchUpInside];
    forwardButton.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    forwardButton.hitTestEdgeInsets = UIEdgeInsetsMake(-16, 0, -16, -16);
    [self addSubview:forwardButton];
    self.forwardButton = forwardButton;
    /** 不感兴趣 */
    SSThemedButton *unInterestedButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    unInterestedButton.imageName = @"add_textpage.png";
    unInterestedButton.backgroundColor = [UIColor clearColor];
    [unInterestedButton addTarget:self action:@selector(unInterestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:unInterestedButton];
    self.unInterestedButton = unInterestedButton;
    
    self.foldRecommendButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [self.foldRecommendButton addTarget:self action:@selector(operationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.foldRecommendButton.layer.cornerRadius =  4;
    self.foldRecommendButton.layer.masksToBounds = YES;
    self.foldRecommendButton.alpha = 0;
    self.foldRecommendButton.imageName = @"personal_home_arrow";
    self.foldRecommendButton.backgroundColorThemeKey = kColorBackground4;
    self.foldRecommendButton.borderColorThemeKey = kColorLine1;
    self.foldRecommendButton.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:28], [TTDeviceUIUtils tt_newPadding:28]);
    [self addSubview:self.foldRecommendButton];
    
    /** 摘要 */
    SSThemedLabel *abstractLabel = [[SSThemedLabel alloc] init];
    abstractLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    [self addSubview:abstractLabel];
    self.abstractLabel = abstractLabel;
    /** 评论内容 */
    TTHighlightedLabel *commentLabel = [[TTHighlightedLabel alloc] init];
    commentLabel.backgroundColorThemeKey = kColorBackground4;
    commentLabel.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
    commentLabel.highlightedTextColor = [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"%@%@", kCellCommentViewTextColor, @"Highlighted"]];
    commentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    UITapGestureRecognizer *commentLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                                initWithTarget:self action:@selector(commentLabelClick)];
    commentLabel.userInteractionEnabled = YES;
    [commentLabel addGestureRecognizer:commentLabelTapGestureRecognizer];
    [self addSubview:commentLabel];
    self.commentLabel = commentLabel;
    
    /** 热评cell的评论内容 */
    _commentAttrLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _commentAttrLabel.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *commentArrtLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                                    initWithTarget:self action:@selector(commentLabelClick)];
    _commentAttrLabel.userInteractionEnabled = YES;
    [_commentAttrLabel addGestureRecognizer:commentArrtLabelTapGestureRecognizer];
    [self addSubview:_commentAttrLabel];
    
    /** 背景view */
    SSThemedView *adBackgroundView = [[SSThemedView alloc] init];
    adBackgroundView.backgroundColor = [UIColor clearColor];
    [self addSubview:adBackgroundView];
    [self sendSubviewToBack:adBackgroundView];
    self.adBackgroundView = adBackgroundView;
    /** 评论文章的背景view */
    SSThemedView *backgroundView = [[SSThemedView alloc] init];
    backgroundView.userInteractionEnabled = YES;
    UITapGestureRecognizer *backgroundViewTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                                  initWithTarget:self action:@selector(backgroundClick)];
    [backgroundView addGestureRecognizer:backgroundViewTapGestureRecognizer];
    [self addSubview:backgroundView];
    [self sendSubviewToBack:backgroundView];
    self.backgroundView = backgroundView;
    /** 竖向分割线 */
    SSThemedView *separatorView = [[SSThemedView alloc] init];
    [self addSubview:separatorView];
    self.separatorView = separatorView;
    /** 关注按钮，需要判断cid，改为懒加载 */
    
    /** 顶部分割条 */
    SSThemedView *topRect = [[SSThemedView alloc] init];
    topRect.backgroundColorThemeKey = kColorBackground3;
    [self addSubview:topRect];
    self.topRect = topRect;
    /** 底部分割条 */
    SSThemedView *bottomRect = [[SSThemedView alloc] init];
    bottomRect.backgroundColorThemeKey = kColorBackground3;
    [self addSubview:bottomRect];
    self.bottomRect = bottomRect;
    /** 底部分割线 */
    SSThemedView *bottomLineView = [[SSThemedView alloc] init];
    bottomLineView.backgroundColorThemeKey = kCellBottomLineColor;
    [self addSubview:bottomLineView];
    self.bottomLineView = bottomLineView;
    /** 广告下载按钮 */
    ExploreActionButton *actionButton = [[ExploreActionButton alloc] init];
    
    [actionButton setTitleColor:[UIColor colorWithHexString:@"25265E"] forState:UIControlStateNormal];
    actionButton.layer.borderColor = [UIColor colorWithHexString:@"25265E99"].CGColor;
    actionButton.layer.masksToBounds = YES;
    actionButton.backgroundColorThemeKey = nil;
    actionButton.backgroundColors = nil;
    [actionButton addTarget:self action:@selector(downloadButtonActionFired:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:actionButton];
    self.actionButton = actionButton;
    /** 广告功能栏上的来源 */
    SSThemedLabel *adSubtitleLabel = [[SSThemedLabel alloc] init];
    adSubtitleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:adSubtitleLabel];
    self.adSubtitleLabel = adSubtitleLabel;
    self.adSubtitleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *adSubtitleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adLocationLabelClick:)];
    [self.adSubtitleLabel addGestureRecognizer:adSubtitleTapGestureRecognizer];
    
    //广告locationicon
    SSThemedImageView *adLocationIcon = [[SSThemedImageView alloc] init];
    adLocationIcon.imageName = @"lbs_ad_feed";
    //    adLocationIcon.image = [UIImage themedImageNamed:@"lbs_ad_feed"];
    [self addSubview:adLocationIcon];
    self.adLocationIcon = adLocationIcon;
    self.adLocationIcon.userInteractionEnabled = YES;
    UITapGestureRecognizer *adLocationIconTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adLocationLabelClick:)];
    [self.adLocationIcon addGestureRecognizer:adLocationIconTapGestureRecognizer];
    
    //广告location
    SSThemedLabel *adLocationLabel = [[SSThemedLabel alloc] init];
    adLocationLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:adLocationLabel];
    self.adLocationLabel = adLocationLabel;
    self.adLocationLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *adLocationLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adLocationLabelClick:)];
    [adLocationLabel addGestureRecognizer:adLocationLabelTapGestureRecognizer];
    
    /** 关注栏 */
    //    TTArticleCellEntityWordView *entityWordView = [[TTArticleCellEntityWordView alloc] initWithFrame:CGRectZero];
    //    [self addSubview:entityWordView];
    //    self.entityWordView = entityWordView;
    
    
    //轮播广告
    TTlayoutLoopInnerPicView *innerLoopPicView = [[TTlayoutLoopInnerPicView alloc] init];
    [self addSubview:innerLoopPicView];
    self.adInnerLoopPicView = innerLoopPicView;
}

- (TTFollowThemeButton *)subscribeButton {
    if (_subscribeButton == nil) {
        _subscribeButton = [self.orderedData.cellLayOut generateFollowButton];
        _subscribeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-7, -7, -7, -7);
        [_subscribeButton addTarget:self action:@selector(subscribeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_subscribeButton];
    }
    return _subscribeButton;
}

- (void)refreshWithData:(id)data
{
    [self removeKVOForCell];
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
        [self addKVOForCell];
        [self trackForU11CellShowInList];
#ifdef TTAdAccessibility
        [self accessibilityMark];
#endif
    } else {
        self.orderedData = nil;
    }
}

- (void)refreshUI
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    [cellLayOut updateFrameForData:self.orderedData cellWidth:self.width listType:self.listType];
    [self layoutComponents];
}

- (void)accessibilityMark {
    if ([self.orderedData respondsToSelector:@selector(ad_id)]) {
        if (self.orderedData.ad_id != nil) {
            [self.actionButton setAccessibilityIdentifier:@"action_button"];
            [self.titleLabel setAccessibilityIdentifier:@"title_label"];
            [self.subTitleLabel setAccessibilityIdentifier:@"subtitle_label"];
            [self setAccessibilityIdentifier:@"ad_view"];
            [self.unInterestedButton setAccessibilityIdentifier:@"dislike_button"];
        }
    }
}

- (void)layoutComponents
{
    if (self.handlingExpand) {
        return;
    }
    self.extraDic = nil;
    self.extraDicForUFCell = nil;
    [self updateContentColor];
    
    [self layoutComponentsForUGCCell];
    [self layoutComponentsForUFCell];
    
    [self layoutTitleLabel];
    [self layoutPicView];
    [self layoutSourceImageView];
    [self layoutSourceLabel];
    [self layoutInfoLabel];
    [self layoutLiveTextLabel];
    [self layoutTypeLabel];
    [self layoutDigButton];
    [self layoutCommentButton];
    [self layoutForwardButton];
    [self layoutUnInterestedButton];
    [self layoutAbstractLabel];
    [self layoutCommentLabel];
    [self layoutADBackgroundView];
    [self layoutBackgroundView];
    [self layoutSeparatorView];
    [self layoutSubscribeButton];
    [self layoutTopRect];
    [self layoutBottomRect];
    [self layoutBottomLineView];
    [self layoutActionButton];
    [self layoutADSubtitleLabel];
    [self layoutADLocationIcon];
    [self layoutADLocationLabel];
    [self layoutEntityWordView];
    [self layoutAdButton];
    [self layoutAdLoopInnerPicView];
//    [self layoutRecommendCardsComponents];
    
}

- (void)layoutTitleLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.titleLabel.hidden = cellLayOut.titleLabelHidden;
    if (!self.titleLabel.hidden) {
        self.titleLabel.numberOfLines = cellLayOut.titleLabelNumberOfLines;
        self.titleLabel.attributedText = cellLayOut.titleAttributedStr;
        self.titleLabel.frame = cellLayOut.titleLabelFrame;
        
        // 增加@和hashtag功能
        [self.titleLabel removeAllLinkAttributes];
        self.titleLabel.labelInactiveLinkAttributes = nil;
        self.titleLabel.labelActiveLinkAttributes = nil;
        self.titleLabel.labelTappingDelegate = nil;
        if ([self.originalData isKindOfClass:[Article class]]) {
            Article *article = (Article *)self.originalData;
            if (article.titleRichSpanJSONString) {
                TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:article.title richSpansJSONString:article.titleRichSpanJSONString];
                NSDictionary *inactiveLinkAttributes = @{NSForegroundColorAttributeName:[TTUISettingHelper detailViewCommentReplyUserNameColor]};
                NSDictionary *activeLinkAttributes = @{NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText5Highlighted)};
                
                self.titleLabel.labelInactiveLinkAttributes = inactiveLinkAttributes;
                self.titleLabel.labelActiveLinkAttributes = activeLinkAttributes;
                self.titleLabel.labelTappingDelegate = self;
                
                NSArray <TTRichSpanLink *> *richSpanLinks = [richSpanText richSpanLinksOfAttributedString];
                for (TTRichSpanLink *link in richSpanLinks) {
                    NSRange linkRange = NSMakeRange(link.start, link.length);
                    if (NSMaxRange(linkRange) <= article.title.length) {
                        [self.titleLabel addLinkToLabelWithURL:[NSURL URLWithString:link.link] range:linkRange];
                    }
                }
            }
        }
    }
}

- (void)label:(UILabel *)label didSelectLinkWithURL:(NSURL *)URL
{
    if ([[TTRoute sharedRoute] canOpenURL:URL]) {
        [[TTRoute sharedRoute] openURLByPushViewController:URL];
    }
}

- (void)layoutPicView
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.picView.hidden = cellLayOut.picViewHidden;
    if (!self.picView.hidden) {
        self.picView.style = cellLayOut.picViewStyle;
        self.picView.hiddenMessage = cellLayOut.picViewHiddenMessage;
        self.picView.frame = cellLayOut.picViewFrame;
        self.picView.userInteractionEnabled = cellLayOut.picViewUserInteractionEnabled;
        if ([self.orderedData isUnifyADCell]) {
            [self.picView updateADPics:self.orderedData];
        }
        else{
            [self.picView updatePics:self.orderedData];
        }
    }
}

- (void)layoutSourceImageView
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.sourceImageView.hidden = cellLayOut.sourceImageViewHidden;
    if (!self.sourceImageView.hidden) {
        self.sourceImageView.frame = cellLayOut.sourceImageViewFrame;
        self.sourceImageView.userInteractionEnabled = cellLayOut.sourceImageUserInteractionEnabled;
        self.sourceImageView.cornerRadius = cellLayOut.sourceImageViewFrame.size.width/2;
        self.sourceImageView.placeholderName = @"default_avatar";
        if (!isEmptyString(cellLayOut.sourceImageURLStr)){
            [self.sourceImageView tt_setImageWithURLString:cellLayOut.sourceImageURLStr];
        }
        else{
            [self.sourceImageView tt_setImageText:cellLayOut.sourceNameFirstWord fontSize:cellLayOut.sourceNameFirstWordFontSize textColorThemeKey:kColorText8 backgroundColorThemeKey:nil backgroundColors:[[self.orderedData article] sourceIconBackgroundColors]];
        }
        [self.sourceImageView setupVerifyViewForLength:self.sourceImageView.width adaptationSizeBlock:nil];
    }
}

- (void)layoutSourceLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.sourceLabel.hidden = cellLayOut.sourceLabelHidden;
    if (!self.sourceLabel.hidden) {
        self.sourceLabel.frame = cellLayOut.sourceLabelFrame;
        self.sourceLabel.textColorThemeKey = cellLayOut.sourceLabelTextColorThemeKey;
        self.sourceLabel.font = [UIFont tt_fontOfSize:cellLayOut.sourceLabelFontSize];
        self.sourceLabel.userInteractionEnabled = cellLayOut.sourceLabelUserInteractionEnabled;
        self.sourceLabel.text = cellLayOut.sourceLabelStr;
    }
}

- (void)layoutInfoLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.infoLabel.hidden = cellLayOut.infoLabelHidden;
    if (!self.infoLabel.hidden) {
        self.infoLabel.frame = cellLayOut.infoLabelFrame;
        self.infoLabel.font = [UIFont systemFontOfSize:cellLayOut.infoLabelFontSize];
        self.infoLabel.textColorThemeKey = cellLayOut.infoLabelTextColorThemeKey;
        self.infoLabel.text = self.orderedData.cellLayOut.infoLabelStr;
    }
}

- (void)layoutLiveTextLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.liveTextLabel.hidden = cellLayOut.liveTextLabelHidden;
    if (!self.liveTextLabel.hidden) {
        self.liveTextLabel.frame = cellLayOut.liveTextLabelFrame;
    }
}

- (void)layoutTypeLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.typeLabel.hidden = cellLayOut.typeLabelHidden;
    if (!self.typeLabel.hidden) {
        self.typeLabel.frame = cellLayOut.typeLabelFrame;
        NSString *typeString = [TTLayOutCellDataHelper getTypeStringWithOrderedData:self.orderedData];
        self.typeLabel.text = typeString;
        if ([self.orderedData isPlainCell]){
            if (self.orderedData.originalData.userRepined &&
                self.listType != ExploreOrderedDataListTypeFavorite && self.listType != ExploreOrderedDataListTypeReadHistory && self.listType != ExploreOrderedDataListTypePushHistory) {
                self.typeLabel.textColor = [UIColor tt_themedColorForKey:kCellTypeLabelTextRed];
                self.typeLabel.layer.borderColor = [UIColor tt_themedColorForKey:kCellTypeLabelLineRed].CGColor;
            }
            else{
                [ExploreCellHelper colorTypeLabel:self.typeLabel orderedData:self.orderedData];
            }
        }
        else{
            if ([self.orderedData.adModel isCreativeAd] || [self.orderedData labelStyle] == 3) {
                self.typeLabel.textColor = [UIColor colorWithHexString:@"999999"];
                self.typeLabel.layer.borderColor = [UIColor clearColor].CGColor;
            } else {
                self.typeLabel.textColor = [UIColor tt_themedColorForKey:kTagViewTextColorRed()];
                self.typeLabel.layer.borderColor = [UIColor tt_themedColorForKey:kTagViewLineColorRed()].CGColor;
            }
        }
    }
}

- (void)layoutDigButton
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.digButton.hidden = cellLayOut.digButtonHidden;
    if (!self.digButton.hidden){
        self.digButton.frame = cellLayOut.digButtonFrame;
        NSString *digCount = [TTLayOutCellDataHelper getDigNumberStringWithOrderedData:self.orderedData];
        
        self.digButton.titleColorThemeKey = cellLayOut.digButtonTextColorThemeKey;
        self.digButton.imageName = cellLayOut.digButtonImageName;
        self.digButton.selectedImageName = cellLayOut.digButtonSelectedImageName;
        self.digButton.titleLabel.font = [UIFont tt_fontOfSize:cellLayOut.digButtonFontSize];
        self.digButton.contentEdgeInsets = cellLayOut.digButtonContentInsets;
        self.digButton.titleEdgeInsets = cellLayOut.digButtonTitleInsets;
        self.digButton.selected = [TTLayOutCellDataHelper userDiggWithOrderedData:self.orderedData];
        
        [self.digButton setTitle:digCount forState:UIControlStateNormal];
        [self.digButton setTitle:digCount forState:UIControlStateSelected];
    }
}

- (void)layoutCommentButton
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.commentButton.hidden = cellLayOut.commentButtonHidden;
    if (!self.commentButton.hidden) {
        self.commentButton.frame = cellLayOut.commentButtonFrame;
        NSString *commentCount = [TTLayOutCellDataHelper getCommentNumberStringWithOrderedData:self.orderedData];
        
        self.commentButton.titleColorThemeKey = cellLayOut.commentButtonTextColorThemeKey;
        self.commentButton.imageName = cellLayOut.commentButtonImageName;
        self.commentButton.titleLabel.font = [UIFont tt_fontOfSize:cellLayOut.commentButtonFontSize];
        self.commentButton.contentEdgeInsets = cellLayOut.commentButtonContentInsets;
        self.commentButton.titleEdgeInsets = cellLayOut.commentButtonTitleInsets;
        
        self.commentButton.frame = cellLayOut.commentButtonFrame;
        [self.commentButton setTitle:commentCount forState:UIControlStateNormal];
    }
}

- (void)layoutForwardButton
{
    TTLayOutCellBaseModel *cellLayout = self.orderedData.cellLayOut;
    self.forwardButton.hidden = cellLayout.forwardButtonHidden;
    if (!self.forwardButton.hidden) {
        self.forwardButton.frame = cellLayout.forwardButtonFrame;
        self.forwardButton.titleColorThemeKey = cellLayout.forwardButtonTextColorThemeKey;
        self.forwardButton.imageName = cellLayout.forwardButtonImageName;
        self.forwardButton.titleLabel.font = [UIFont tt_fontOfSize:cellLayout.forwardButtonFontSize];
        self.forwardButton.contentEdgeInsets = cellLayout.forwardButtonContentInsets;
        self.forwardButton.titleEdgeInsets = cellLayout.forwardButtonTitleInsets;
        [self.forwardButton setTitle:[TTLayOutCellDataHelper getForwardStringWithOrderedData:self.orderedData]
                            forState:UIControlStateNormal];
    }
}

- (void)layoutUnInterestedButton
{
    BOOL ugcVideoBelongToUser = NO;
    if ([self.orderedData.originalData isKindOfClass:[Article class]]) {
        ugcVideoBelongToUser = [self.orderedData.article isVideoSourceUGCVideo] && !isEmptyString([[self.orderedData.article userInfo] tt_stringValueForKey:@"user_id"]) && [[[self.orderedData.article userInfo] tt_stringValueForKey:@"user_id"] isEqualToString:[TTAccountManager userID]];
    }
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.unInterestedButton.hidden = cellLayOut.unInterestedButtonHidden || ugcVideoBelongToUser;
    if (!self.unInterestedButton.hidden) {
        self.unInterestedButton.frame = cellLayOut.unInterestedButtonFrame;
    }
}

- (void)layoutAbstractLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.abstractLabel.hidden = cellLayOut.abstractLabelHidden;
    if (!self.abstractLabel.hidden){
        self.abstractLabel.frame = cellLayOut.abstractLabelFrame;
        self.abstractLabel.numberOfLines = cellLayOut.abstractLabelNumberOfLines;
        self.abstractLabel.textColorThemeKey = cellLayOut.abstractLabelTextColorThemeKey;
        self.abstractLabel.attributedText = cellLayOut.abstractAttributedStr;
    }
}

- (void)layoutCommentLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.commentLabel.hidden = cellLayOut.commentLabelHidden;
    if (!self.commentLabel.hidden) {
        self.commentLabel.frame = cellLayOut.commentLabelFrame;
        self.commentLabel.numberOfLines = cellLayOut.commentLabelNumberOfLines;
        self.commentLabel.textColorThemeKey = cellLayOut.commentLabelTextColorThemeKey;
        self.commentLabel.attributedText = cellLayOut.commentAttributedStr;
        self.commentLabel.userInteractionEnabled = cellLayOut.commentLabelUserInteractionEnabled;
    }
}

- (void)layoutADBackgroundView
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.adBackgroundView.hidden = cellLayOut.adBackgroundViewHidden;
    if (!self.adBackgroundView.hidden) {
        self.adBackgroundView.frame = cellLayOut.adBackgroundViewFrame;
    }
}

- (void)layoutBackgroundView
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.backgroundView.hidden = cellLayOut.backgroundViewHidden;
    if (!self.backgroundView.hidden) {
        self.backgroundView.frame = cellLayOut.backgroundViewFrame;
        self.backgroundView.backgroundColorThemeKey = cellLayOut.backgroundViewBackgroundColorThemeKey;
    }
}

- (void)layoutSeparatorView
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.separatorView.hidden = cellLayOut.separatorViewHidden;
    if (!self.separatorView.hidden) {
        self.separatorView.frame = cellLayOut.separatorViewFrame;
        self.separatorView.backgroundColorThemeKey = cellLayOut.separatorViewBackgroundColorThemeKey;
    }
}

- (void)layoutSubscribeButton
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.subscribeButton.hidden = cellLayOut.subscribButtonHidden;
    if (!self.subscribeButton.hidden) {
        self.subscribeButton.top = cellLayOut.subscribButtonTop;
        self.subscribeButton.right = cellLayOut.subscribButtonRight;
        BOOL isFollowed = [TTLayOutCellDataHelper isFollowedWithOrderedData:self.orderedData];
//        if (!isFollowed && self.orderedData.cellLayOut.isExpand) {
//            //            _currentLayoutModel.isExpanded = NO;
//            [self handleExpandStateChange:NO];
//        }
        TTUnfollowedType unFollowType = TTUnfollowedType101;
        TTFollowedType followType = TTFollowedType101;
        TTFollowedMutualType mutualType = TTFollowedMutualType101;
        if ([self.orderedData.followButtonStyle integerValue] == 1) {
            followType = TTFollowedType101;
            mutualType = TTFollowedMutualType101 ;
//            if (self.orderedData.redpacketModel) {
//                unFollowType = [TTFollowThemeButton redpacketButtonUnfollowTypeButtonStyle:self.orderedData.redpacketModel.button_style.integerValue defaultType:TTUnfollowedType202];
//            }else {
                //无红包，默认未关注按钮样式
                unFollowType = TTUnfollowedType101;
//            }
        } else {
            followType = TTFollowedType102;
            mutualType = TTFollowedMutualType102;
//            if (self.orderedData.redpacketModel) {
//                unFollowType = [TTFollowThemeButton redpacketButtonUnfollowTypeButtonStyle:self.orderedData.redpacketModel.button_style.integerValue defaultType:TTUnfollowedType202];
//            }else {
                //无红包，默认未关注按钮样式
                unFollowType = TTUnfollowedType102;
//            }
        }
        self.subscribeButton.unfollowedType = unFollowType;
        self.subscribeButton.followedMutualType = mutualType;
        self.subscribeButton.followedType = followType;
        [self.subscribeButton refreshUI];
        [self.subscribeButton setFollowed:isFollowed];
    }
    
    if ([self.orderedData.followButtonStyle integerValue] == 1) {
        self.subscribeButton.layer.borderWidth = 1;
    } else {
        self.subscribeButton.layer.borderWidth = 0;
    }
}

- (void)layoutTopRect
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.topRect.hidden = cellLayOut.topRectHidden;
    if (!self.topRect.hidden) {
        self.topRect.frame = cellLayOut.topRectFrame;
    }
}

- (void)layoutBottomRect
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.bottomRect.hidden = cellLayOut.bottomRectHidden;
    if (!self.bottomRect.hidden) {
        self.bottomRect.frame = cellLayOut.bottomRectFrame;
    }
}

- (void)layoutBottomLineView
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.bottomLineView.hidden = cellLayOut.bottomLineViewHidden || self.hideBottomLine;
    if (!self.bottomLineView.hidden) {
        self.bottomLineView.frame = cellLayOut.bottomLineViewFrame;
    }
}

- (void)layoutActionButton
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.actionButton.hidden = cellLayOut.actionButtonHidden;
    if (!self.actionButton.hidden) {
        self.actionButton.actionModel = self.orderedData;
        [self.actionButton refreshCreativeIcon];
        self.actionButton.frame = cellLayOut.actionButtonFrame;
        self.actionButton.titleLabel.font = [UIFont tt_fontOfSize:cellLayOut.actionButtonFontSize];
        self.actionButton.layer.borderWidth = cellLayOut.actionButtonBorderWidth;
    }
}

- (void)layoutADSubtitleLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.adSubtitleLabel.hidden = cellLayOut.adSubtitleLabelHidden;
    if (!self.adSubtitleLabel.hidden) {
        self.adSubtitleLabel.frame = cellLayOut.adSubtitleLabelFrame;
        self.adSubtitleLabel.font = [UIFont tt_fontOfSize:cellLayOut.adSubtitleLabelFontSize];
        self.adSubtitleLabel.textColor = [UIColor colorWithHexString:cellLayOut.adSubtitleLabelTextColorHex];
        self.adSubtitleLabel.text = cellLayOut.adSubtitleLabelStr;
        self.adSubtitleLabel.userInteractionEnabled = cellLayOut.adSubtitleLabelUserInteractionEnabled;
    }
}


-(void)layoutADLocationIcon{
    
    TTLayOutCellBaseModel *cellLayout = self.orderedData.cellLayOut;
    self.adLocationIcon.hidden = cellLayout.adLocationIconHidden;
    if (!self.adLocationIcon.hidden) {
        self.adLocationIcon.frame = cellLayout.adLocationIconFrame;
    }
    
}

-(void)layoutADLocationLabel{
    
    TTLayOutCellBaseModel *cellLayout = self.orderedData.cellLayOut;
    self.adLocationLabel.hidden = cellLayout.adLocationLabelHidden;
    if (!self.adLocationLabel.hidden) {
        self.adLocationLabel.frame = cellLayout.adLocationLabelFrame;
        self.adLocationLabel.font = [UIFont tt_fontOfSize:cellLayout.adLocationLabelFontSize];
        self.adLocationLabel.textColorThemeKey = cellLayout.adLocationLabelTextColorThemeKey;
        self.adLocationLabel.text = cellLayout.adLocationLabelStr;
    }
}


- (void)layoutEntityWordView
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    
    if (cellLayOut && !cellLayOut.entityWordViewHidden && !self.entityWordView) {
        /** 关注栏 */
        TTArticleCellEntityWordView *entityWordView = [[TTArticleCellEntityWordView alloc] initWithFrame:CGRectZero];
        [self addSubview:entityWordView];
        self.entityWordView = entityWordView;
    }
    
    self.entityWordView.hidden = cellLayOut.entityWordViewHidden;
    if (self.entityWordView && !self.entityWordView.hidden) {
        self.entityWordView.frame = cellLayOut.entityWordViewFrame;
        [self.entityWordView updateEntityWordViewWithOrderedData:self.orderedData];
    }
}

- (void)layoutAdButton{
    if ([self.orderedData.adModel isCreativeAd] && [[self.orderedData.article hasVideo] boolValue]) {
        if([self.orderedData isAdButtonUnderPic]) {
            self.adButton.hidden = YES;
        } else {
            [self bringAdButtonBackToCell];
            self.adButton.hidden = YES;
        }
    } else{
        self.adButton.hidden = YES;
    }
}

- (void)layoutAdLoopInnerPicView{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    if (cellLayOut) {
        self.adInnerLoopPicView.hidden = cellLayOut.adInnerLoopPicViewHidden;
        
        if (!self.adInnerLoopPicView.hidden && self.orderedData) {
            self.adInnerLoopPicView.frame = cellLayOut.adInnerLoopPicViewFrame;
            [self.adInnerLoopPicView updatePicViewWithData:self.orderedData WithPerPicSize:cellLayOut.adInnerLoopPerPicSize WithbaseCell:[self cell] WithTabelView:self.tableView];
            
        }
    }
}

//- (void)layoutRecommendCardsComponents {
//
//
//    self.foldRecommendButton.left = self.subscribeButton.right + 10;
//    self.foldRecommendButton.centerY = self.subscribeButton.centerY;
//    if ([self.orderedData.cellLayOut isKindOfClass:[TTLayOutUFCellBaseModel class]]) {
//        TTLayOutUFCellBaseModel *layout = (TTLayOutUFCellBaseModel *)self.orderedData.cellLayOut;
//        if (!CGRectEqualToRect(self.collectionViewWrapper.frame, layout.recommendCardsFrame)) {
//            self.collectionViewWrapper.frame = layout.recommendCardsFrame;
//        }
//    }
//
//    self.sanjiaoIcon.centerX = self.foldRecommendButton.centerX;
//    self.sanjiaoIcon.bottom = self.collectionViewWrapper.top;
//
//    if (self.reuseinit && self.collectionViewWrapper.height > 0) {
//        if ([[[RecommendCardCache defaultCache] dataSourceForUniqId:self.orderedData.uniqueID] count] > 0) {
//            [self.collectionViewWrapper.collectionView configUserModels:[[RecommendCardCache defaultCache] dataSourceForUniqId:self.orderedData.uniqueID] requesetModel:nil];
//        } else {
//            WeakSelf;
//            [TTRecommendUserCollectionView requestDataWithSource:@"feedrec" scene:@"follow" sceneUserId:[[self.orderedData article] userIDForAction] groupId:self.orderedData.article.groupModel.groupID complete:^(NSArray<FRRecommendCardStructModel *> *models) {
//                StrongSelf;
//                if (models) {
//                    [[RecommendCardCache defaultCache] insertRecommendArray:self.collectionViewWrapper.collectionView.allUserModels forCellId:self.orderedData.uniqueID];
//                    [self.collectionViewWrapper.collectionView configUserModels:models requesetModel:nil];
//                }
//            }];
//        }
//    }
//
//    if (self.reuseinit && self.orderedData.cellLayOut.isExpand) {
//        self.foldRecommendButton.alpha = 1;
//        self.unInterestedButton.alpha = 0;
//        self.collectionViewWrapper.alpha = 1;
//        self.sanjiaoIcon.alpha = 1;
//    } else if (self.reuseinit) {
//        self.foldRecommendButton.alpha = 0;
//        self.unInterestedButton.alpha = 1;
//        self.collectionViewWrapper.alpha = 0;
//        self.sanjiaoIcon.alpha = 0;
//    }
//    if (self.subscribeButton.hidden) {
//        self.foldRecommendButton.alpha = 0;
//    }
//    self.reuseinit = NO;
//}

- (void)backgroundClick
{
    if ([self.orderedData.originalData isKindOfClass:[Article class]]) {
        Article *article = self.orderedData.article;
        NSString *openURL = article.articleOpenURL;
        if (!isEmptyString(openURL)) {
            if (!!([[article groupFlags] longLongValue] & kArticleGroupFlagsDetailTypeImageSubject) && ![SSCommonLogic appGalleryTileSwitchOn] && [SSCommonLogic appGallerySlideOutSwitchOn]) {
                NSMutableDictionary *statParams = [NSMutableDictionary dictionaryWithCapacity:2];
                [statParams setValue:@(0) forKey:@"animated"];
                
                [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL] userInfo:TTRouteUserInfoWithDict(statParams)];
            }
            else{
                [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL]];
            }
        }
    }
    else if ([self.orderedData.originalData isKindOfClass:[Comment class]]) {
        Comment *comment = self.orderedData.comment;
        NSString *openURL = [comment articleOpenURL];
        if (!isEmptyString(openURL)) {
            if (!!([[comment groupFlags] longLongValue] & kArticleGroupFlagsDetailTypeImageSubject) && ![SSCommonLogic appGalleryTileSwitchOn] && [SSCommonLogic appGallerySlideOutSwitchOn]) {
                NSMutableDictionary *statParams = [NSMutableDictionary dictionaryWithCapacity:2];
                [statParams setValue:@(0) forKey:@"animated"];
                
                [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL] userInfo:TTRouteUserInfoWithDict(statParams)];
            }
            else{
                [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL]];
            }
            
            NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithDictionary:self.extraDicForUFCell];
            [extraDic setValue:@(0) forKey:@"click_area"];
            [extraDic setValue:comment.aggrType forKey:@"aggr_type"];
//            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"cell" label:@"go_detail" value:comment.groupID source:nil extraDic:extraDic];
        }
    }
}

- (void)sourceImageClick
{
    if ([self.orderedData.originalData isKindOfClass:[Article class]]) {
        [[TTRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
        NSString *enteryForm = ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) ? @"click_headline" : @"click_category";
        [[TTRelevantDurationTracker sharedTracker] appendRelevantDurationWithGroupID:self.orderedData.article.groupModel.groupID
                                                                              itemID:self.orderedData.article.groupModel.itemID
                                                                           enterFrom:enteryForm
                                                                        categoryName:self.orderedData.categoryID
                                                                            stayTime:0
                                                                               logPb:self.orderedData.logPb];
        NSString *sourceUrl = [[self.orderedData article] sourceOpenUrl];
         WeakSelf;
        void(^ad_clickHeadImage)(void) = ^() {
             StrongSelf;
            [self ad_trackWithTag:@"embeded_ad" label:@"head_image_click" extra:nil];
            NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:2];
            NSMutableDictionary *ad_extra_data = [NSMutableDictionary dictionaryWithCapacity:8];
            TTTouchContext *touchContext = [[[TTTouchContext alloc] initWithTargetView:self.sourceImageView] toView:self];
            NSDictionary *touchInfo = [touchContext touchInfo];
            if (touchInfo) {
                [ad_extra_data addEntriesFromDictionary:touchInfo];
            }
            NSDictionary *adCellLayoutInfo = [self adCellLayoutInfo];
            if (adCellLayoutInfo) {
                [ad_extra_data addEntriesFromDictionary:adCellLayoutInfo];
            }
            [extrData setValue:[TTTouchContext format2JSON:ad_extra_data] forKey:@"ad_extra_data"];
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click" eventName:@"embeded_ad" extra:extrData duration:0];
        };
        
        if (!isEmptyString(sourceUrl) && [[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:sourceUrl]]){
            if ([self.orderedData isUGCCell]) {
                [self trackForCellWithLabel:@"click_source"];
            }

            else {
                [self trackForCellWithLabel:@"head_image_click"];
                if ([self.orderedData isAd]) {
                    ad_clickHeadImage();
                }
            }
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:sourceUrl]];
        }
        else if (!isEmptyString([[self.orderedData article] userIDForAction])){
            NSString *openURL = [NSString stringWithFormat:@"sslocal://profile?uid=%@", [[self.orderedData article] userIDForAction]];
            if ([self.orderedData isUGCCell]) {
                [self trackForCellWithLabel:@"click_source"];
            }
            else {
                [self trackForCellWithLabel:@"head_image_click"];
                if ([self.orderedData isAd]) {
                    ad_clickHeadImage();
                }
            }
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL]];
        }
    }
    else if ([self.orderedData.originalData isKindOfClass:[Comment class]]) {
        NSString *sourceUrl = [[self.orderedData comment] sourceOpenURL];
        if (!isEmptyString(sourceUrl)) {
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:sourceUrl]];
            [self trackForCellWithLabel:@"head_image_click"];
        }
    }
}

-(void)adLocationLabelClick:(UITapGestureRecognizer *)tap {
    BOOL canJump = NO;
    NSString *locationUrl = nil;
    NSString *web_title = nil;
    TTAdFeedModel* rawAdModel = self.orderedData.raw_ad;
    id<TTAdFeedModel> admodel = self.orderedData.adModel;
    //普通大小组图lbs广告
    if ([rawAdModel hasLocationInfo] && rawAdModel.adType == ExploreActionTypeWeb) {
        canJump = YES;
        locationUrl = rawAdModel.location_url;
        web_title = rawAdModel.webTitle;
    }//创意通投大小组图lbs广告
    else if ([admodel isCreativeAd]) {
        if (admodel.adType == ExploreActionTypeLocationForm || admodel.adType == ExploreActionTypeLocationAction || admodel.adType == ExploreActionTypeLocationcounsel){
            canJump = YES;
            locationUrl = admodel.location_url;
            web_title = admodel.webTitle;
        }
    }
    
    if (canJump) {
        TTAdDetailActionModel* actionModel = [[TTAdDetailActionModel alloc] initWithAdId:self.orderedData.ad_id logExtra:self.orderedData.log_extra webUrl:locationUrl openUrl:nil webTitle:web_title];
        [TTAdAction handleWebActionModel:actionModel];
        
        NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:2];
        if (tap && [tap isKindOfClass:[UITapGestureRecognizer class]]) {
            
            CGPoint tapPoint = [tap locationInView:self];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
            [dict setValue:@(self.width) forKey:@"width"];
            [dict setValue:@(self.height) forKey:@"height"];
            [dict setValue:@(tapPoint.x) forKey:@"click_x"];
            [dict setValue:@(tapPoint.y) forKey:@"click_y"];
            NSError *error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
            NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if (!isEmptyString(json)) {
                [extrData setValue:json forKey:@"ad_extra_data"];
            }
            
            [extrData setValue:@"2" forKey:@"ext_value"];
        }
        
        [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click" eventName:@"embeded_ad" extra:extrData duration:0];
        [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_shop" eventName:@"lbs_ad"];
    }
    
}

- (void)trackAdDislikeClick
{
    if (self.orderedData.adIDStr.longLongValue > 0) {
        [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"dislike" eventName:@"embeded_ad"];
    }
}

// MARK: -- dislike点击事件处理
- (void)unInterestButtonClicked:(id)sender
{
    [TTFeedDislikeView dismissIfVisible];
    [self showMenu];
    [self trackAdDislikeClick];
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

#pragma mark TTFeedDislikeView

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
    NSMutableDictionary *extra = [@{} mutableCopy];
    [extra setValue:filterWords forKey:@"filter_words"];
    [self ad_trackWithTag:@"embeded_ad" label:@"final_dislike" extra:@{@"ad_extra_data":[extra tt_JSONRepresentation]}];
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

// MARK: -- 顶、评论、分享、举报
- (void)digButtonClick:(TTAlphaThemedButton *)button {
    if ([self.orderedData.originalData isKindOfClass:[Article class]]) {
        if(self.orderedData.originalData.userBury) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经踩过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            return;
        }
    }
    if ([TTLayOutCellDataHelper userDiggWithOrderedData:self.orderedData]) {
        [self undoDigWithButton:button];
        return;
    }
    
    [self digButtonAnimationWith:button];
    if ([self.orderedData isUGCCell]) {
        [self trackForCellWithLabel:@"like"];
    }
    else{
        [self trackForCellWithLabel:@"digg_click"];
    }
    [self ad_trackWithTag:@"embeded_ad" label:@"digg_click" extra:nil];
}

- (void)undoDigWithButton:(TTAlphaThemedButton *)button {
    button.selected = NO;
    [self updateDiggCount:NO];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
    [dict setValue:self.orderedData.article.groupModel.groupID forKey:@"group_id"];
    [dict setValue:self.orderedData.article.groupModel.itemID forKey:@"item_id"];
    
    NSString *user_id = [self.orderedData.article.mediaInfo tt_stringValueForKey:@"media_id"]? :[self.orderedData.article.userInfo tt_stringValueForKey:@"user_id"];
    [dict setValue:user_id forKey:@"user_id"];
    [dict setValue:self.orderedData.groupSource forKey:@"group_source"];
    [dict setValue:self.orderedData.logPb forKey:@"log_pb"];
    [dict setValue:@"list" forKey:@"position"];
    if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
        [dict setValue:@"click_headline" forKey:@"enter_from"];
    }else{
        [dict setValue:@"click_category" forKey:@"enter_from"];
    }
    [dict setValue:self.cardId forKey:@"card_id"];
    [dict setValue:@(self.position).stringValue forKey:@"card_position"];
    if (self.orderedData.listLocation != 0) {
        [dict setValue:@"main_tab" forKey:@"list_entrance"];
    }
    
    [TTTracker eventV3:@"rt_unlike" params:[dict copy]];
}

- (void)digButtonAnimationWith:(TTAlphaThemedButton *)button
{

    [SSMotionRender motionInView:button.imageView byType:SSMotionTypeZoomInAndDisappear image:[UIImage themedImageNamed:@"add_all_dynamic.png"] offsetPoint:CGPointMake(4.f, -9.f)];
    WeakSelf;
    if (!button.selected){
        button.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        button.imageView.contentMode = UIViewContentModeCenter;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            button.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            button.alpha = 0;
        } completion:^(BOOL finished) {
            button.selected = YES;
            button.alpha = 0;
            [wself updateDiggCount:YES];
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                button.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                button.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }];
    }
}

- (void)updateDiggCount:(BOOL)digg;
{
    if ([self.orderedData.originalData isKindOfClass:[Article class]]) {
        if ([self.orderedData isUGCCell]){
            NSNumber *likeCount = nil;
            [self.originalData setUserLike:[NSNumber numberWithBool:digg]];
            likeCount = [self.originalData likeCount];
            likeCount = [NSNumber numberWithLongLong:digg? [likeCount longLongValue] + 1: [likeCount longLongValue] - 1];
            [[self.orderedData originalData] setLikeCount:likeCount];
            [self.itemActionManager sendActionForOriginalData:self.originalData adID:nil actionType:digg? DetailActionTypeLike: DetailActionTypeUnlike finishBlock:^(id userInfo, NSError *error) {
            }];
        }
        else{
            int likeCount = 0;
            [self.originalData setUserDigg:digg];
            likeCount = [self.originalData diggCount];
            likeCount = digg? likeCount + 1: likeCount - 1;
            [[self.orderedData originalData] setDiggCount:likeCount];
            [self.itemActionManager sendActionForOriginalData:self.originalData adID:nil actionType:digg? DetailActionTypeDig: DetailActionTypeUnDig finishBlock:^(id userInfo, NSError *error) {
            }];
        }
    }
    @try {
        [self.originalData save];
    } @catch (NSException *exception) {
        NSLog(@"save fail with error");
    }
}

- (void)dislikeButtonClicked:(NSArray<NSString *> *)selectedWords onlyOne:(BOOL)onlyOne {
    if (!self.orderedData) {
        return;
    }
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[kExploreMixListNotInterestItemKey] = self.orderedData;
    
    NSMutableDictionary *extraValueDic = [[NSMutableDictionary alloc] init];
    extraValueDic[@"log_extra"] = self.orderedData.log_extra;
    
    
    if ([selectedWords count] > 0) {
        userInfo[kExploreMixListNotInterestWordsKey] = selectedWords;
        if (onlyOne) {
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"confirm_dislike_only_reason" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:extraValueDic];
        } else {
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"confirm_dislike_with_reason" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:extraValueDic];
        }
    } else {
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"confirm_dislike_no_reason" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:extraValueDic];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

- (void)showComment:(id)sender
{
    TTFeedCellSelectContext *context = [TTFeedCellSelectContext new];
    context.refer = [self getRefer];
    context.orderedData = self.orderedData;
    context.clickComment = YES;
    if (self.isCardSubCellView) {
        context.categoryId = self.cardCategoryId;
    } else {
        context.categoryId = self.orderedData.categoryID;
    }
    [self didSelectWithContext:context];
}

- (NSString *)screenName {
    if (!isEmptyString(self.orderedData.categoryID)) {
        return [NSString stringWithFormat:@"channel_%@",self.orderedData.categoryID];
    }
    if (!isEmptyString(self.orderedData.concernID)) {
        return  [NSString stringWithFormat:@"channel_%@",self.orderedData.concernID];
    }
    return @"channel_unknown";
}

- (void)trackForCellWithLabel:(NSString *)label
{
    if ([self.orderedData.originalData isKindOfClass:[Article class]]) {
        if ([self.orderedData isUGCCell]) {
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:label value:self.orderedData.uniqueID source:nil extraDic:self.extraDic];
        }
        else{
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"cell" label:label value:self.orderedData.uniqueID source:nil extraDic:self.extraDicForUFCell];
        }
    }
    else if ([self.orderedData.originalData isKindOfClass:[Comment class]]) {
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"cell" label:label value:self.orderedData.comment.groupID source:nil extraDic:self.extraDicForUFCell];
    }
}

- (void)ad_trackWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra {
    
    NSParameterAssert(tag != nil);
    NSParameterAssert(label != nil);
    if (![self.orderedData isAd]) {
        return;
    }
    
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:8];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:tag forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
    [events setValue:@(nt) forKey:@"nt"];
    [events setValue:self.orderedData.ad_id forKey:@"value"];
    [events setValue:self.orderedData.log_extra forKey:@"log_extra"];
    [events setValue:self.orderedData.uniqueID forKey:@"ext_value"];
    if (extra != nil) {
        [events addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:events];
}

- (void)commentButtonClick {
    if ([self.orderedData.originalData isKindOfClass:[Comment class]]) {
        Comment *comment = self.orderedData.comment;
        if (comment != nil) {
            NSString *commentOpenURL = [self commentSchemeURLStr];
            if ([self.orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle8
                || [self.orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle9
                || [self.orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle11) {
                if (comment.commentCount){
                    commentOpenURL = [NSString stringWithFormat:@"%@&showComment=1&clickComment=1",commentOpenURL];
                }else{
                    commentOpenURL = [NSString stringWithFormat:@"%@&writeComment=1&clickComment=1",commentOpenURL];
                }
                //如果是微头条，需要发一个点击了评论按钮的埋点
                NSMutableDictionary *trackExtraDict = [NSMutableDictionary dictionaryWithCapacity:3];
                [trackExtraDict setValue:@"comment"forKey:@"group_type"];
                [trackExtraDict setValue:comment.commentID forKey:@"comment_id"];
                [trackExtraDict setValue:self.orderedData.categoryID forKey:@"category_id"];
                wrapperTrackEventWithCustomKeys(@"list_comment", @"click", comment.groupID, nil, trackExtraDict);
            }
            NSURL *commentURL = [TTStringHelper URLWithURLString:commentOpenURL];
            
            if ([[TTRoute sharedRoute] canOpenURL:commentURL]) {
                [[TTRoute sharedRoute] openURLByPushViewController:commentURL];
                [self trackForCellWithLabel:@"comment_click"];
                [self ad_trackWithTag:@"embeded_ad" label:@"comment_click" extra:nil];
                NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithDictionary:self.extraDicForUFCell];
                [extraDic setValue:@(0) forKey:@"click_area"];
//                [TTTrackerWrapper ttTrackEventWithCustomKeys:@"cell" label:@"go_detail" value:comment.groupID source:nil extraDic:extraDic];
            }
        }
    }
    else if([self.orderedData.originalData isKindOfClass:[Article class]]){
        [self showComment:nil];
        if (self.orderedData.article.hasVideo){
            if ([self.orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle8
                || [self.orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle9
                || [self.orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle11){
                //微头条下大图视频的样式，发送点击评论的埋点
                NSMutableDictionary *trackExtraDict = [NSMutableDictionary dictionaryWithCapacity:3];
                [trackExtraDict setValue:@"video"forKey:@"group_type"];
                [trackExtraDict setValue:self.orderedData.article.groupModel.itemID forKey:@"item_id"];
                [trackExtraDict setValue:self.orderedData.categoryID forKey:@"category_id"];
                wrapperTrackEventWithCustomKeys(@"list_comment", @"click", self.orderedData.article.groupModel.groupID, nil, trackExtraDict);
            }
        }
        if ([self.orderedData isUGCCell]) {
            [self trackForCellWithLabel:@"comment"];
        }
        else{
            [self trackForCellWithLabel:@"comment_click"];
        }
    }
    [self ad_trackWithTag:@"embeded_ad" label:@"comment_click" extra:nil];
}

- (void)forwardButtonClick {
    [self trackForCellWithLabel:@"share_weitoutiao"];
    [self ad_trackWithTag:@"embeded_ad" label:@"share_weitoutiao" extra:nil];
    
//    if ([self.orderedData.originalData isKindOfClass:[Comment class]]) { //feed中推出的评论，实际转发对象为文章，操作对象为文章
//        Comment *comment = self.orderedData.comment;
//        TTRepostOriginArticle *repostOriginArticle = [[TTRepostOriginArticle alloc] init];
//        repostOriginArticle.groupID = comment.groupID;
//        repostOriginArticle.itemID = comment.itemID;
//        repostOriginArticle.title = comment.title;
//        repostOriginArticle.userID = comment.articleUserID;
//        repostOriginArticle.userName = comment.articleUserName;
//        repostOriginArticle.isVideo = comment.hasVideo.boolValue;
//        repostOriginArticle.userAvatar = comment.articleUserAvatar;
//        if (!isEmptyString([comment articleImageUrl])) {
//            TTImageInfosModel *model= [[TTImageInfosModel alloc] initWithURL:[comment articleImageUrl]];
//            repostOriginArticle.thumbImage = [[FRImageInfoModel alloc] initWithTTImageInfosModel:model];
//        }
//        TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] init];
//        segment.username = comment.userName;
//        segment.userID = comment.userID;
//        segment.content = [[TTRichSpanText alloc] initWithText:comment.commentContent richSpans:nil];
//        NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//        [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                        originArticle:repostOriginArticle
//                                                                         originThread:nil
//                                                         originShortVideoOriginalData:nil
//                                                                    operationItemType:TTRepostOperationItemTypeComment
//                                                                      operationItemID:comment.commentID
//                                                                       repostSegments:segments];
//    }
//    if([self.orderedData.originalData isKindOfClass:[Article class]]){ //feed中推出的UGC视频，实际转发对象为文章，操作对象为文章
//        Article *article = self.orderedData.article;
//        TTRepostOriginArticle *repostOriginArticle = [[TTRepostOriginArticle alloc] initWithArticle:article];
//        [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                        originArticle:repostOriginArticle
//                                                                         originThread:nil
//                                                         originShortVideoOriginalData:nil
//                                                                    operationItemType:TTRepostOperationItemTypeArticle
//                                                                      operationItemID:article.itemID
//                                                                       repostSegments:nil];
//    }
}

- (void)commentLabelClick {
    if ([self.orderedData.originalData isKindOfClass:[Article class]]) {
        [self showComment:nil];
        if ([self.orderedData isUGCCell]) {
            [self trackForCellWithLabel:@"comment"];
        }
    }
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType {
    if (view == self.phoneShareView) {
        NSString *uniqueID = [@(self.orderedData.article.uniqueID) stringValue];
        BOOL hasVideo = ([[[self.orderedData article] hasVideo] boolValue] || [[self.orderedData article] isVideoSubject]);
        [self.activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor:self] sourceObjectType:(hasVideo ? TTShareSourceObjectTypeVideoList : TTShareSourceObjectTypeUGCFeed) uniqueId:uniqueID adID:nil platform:TTSharePlatformTypeOfMain groupFlags:[[self.orderedData article] groupFlags]];
        self.phoneShareView = nil;
        
        NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
        if (label) {
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"list_share" label:label value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:self.extraDic];
        }
    }
}

- (void)subscribeButtonClick:(id)seneder{
    if ([self.subscribeButton isLoading]){
        return;
    }
    
    if ([self.originalData isKindOfClass:[Article class]]){
        Article *article = [self.orderedData article];
        BOOL isFollowed = [TTLayOutCellDataHelper isFollowedWithOrderedData:self.orderedData];
        
        NSMutableDictionary * extraDic = @{}.mutableCopy;
        NSString * followEvent = nil;
        TTFollowNewSource source = TTFollowNewSourceFeedArticle;
        if (isFollowed) {
            followEvent = @"rt_unfollow";
        }else {
            followEvent = @"rt_follow";
//            if (self.orderedData.redpacketModel) {
//                source = TTFollowNewSourceFeedArticleRedPacket;
//                [extraDic setValue:@(1)
//                            forKey:@"is_redpacket"];
//            }
        }
        [extraDic setValue:[article userIDForAction]
                    forKey:@"to_user_id"];
        [extraDic setValue:[article.mediaInfo tt_stringValueForKey:@"media_id"]
                    forKey:@"media_id"];
        [extraDic setValue:@"from_group"
                    forKey:@"follow_type"];
        [extraDic setValue:article.groupModel.groupID
                    forKey:@"group_id"];
        [extraDic setValue:article.groupModel.itemID
                    forKey:@"item_id"];
        [extraDic setValue:@(source)
                    forKey:@"server_source"];
        [extraDic setValue:@"avatar_right"
                    forKey:@"position"];
        [extraDic setValue:self.orderedData.categoryID
                    forKey:@"category_name"];
        [extraDic setValue:@"list"
                    forKey:@"source"];
        [extraDic setValue:self.orderedData.logPb
                    forKey:@"log_pb"];
        [TTTrackerWrapper eventV3:followEvent
                           params:extraDic];
        
        if (!TTNetworkConnected()) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络不给力，请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            return;
        }
        
        NSString *userID = [article userIDForAction];
        if ([userID isEqualToString:[TTAccountManager userID]] || isEmptyString(userID)) {
            return;
        }
        [self changeFollowStatus:isFollowed userID:userID];
    }
    else if ([self.originalData isKindOfClass:[Comment class]]) {
        Comment *comment = [self.orderedData comment];
        BOOL isFollowed = [comment isFollowed];
        TTFollowNewSource source = TTFollowNewSourceFeedArticle;
        NSMutableDictionary * extraDic = @{}.mutableCopy;
        NSString * followEvent = nil;
        if (isFollowed) {
            followEvent = @"rt_unfollow";
        }else {
            followEvent = @"rt_follow";
//            if (self.orderedData.redpacketModel) {
//                source = TTFollowNewSourceFeedArticleRedPacket;
//                [extraDic setValue:@(1)
//                            forKey:@"is_redpacket"];
//            }
        }
        [extraDic setValue:comment.userID
                    forKey:@"to_user_id"];
        [extraDic setValue:@"from_group"
                    forKey:@"follow_type"];
        [extraDic setValue:comment.groupID
                    forKey:@"group_id"];
        [extraDic setValue:comment.itemID
                    forKey:@"item_id"];
        [extraDic setValue:@(source)
                    forKey:@"server_source"];
        [extraDic setValue:@"avatar_right"
                    forKey:@"position"];
        [extraDic setValue:self.orderedData.categoryID
                    forKey:@"category_name"];
        [extraDic setValue:@"list"
                    forKey:@"source"];
        [extraDic setValue:self.orderedData.logPb
                    forKey:@"log_pb"];
        [TTTrackerWrapper eventV3:followEvent
                           params:extraDic];
        
        if (!TTNetworkConnected()) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络不给力，请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            return;
        }
        
        NSString *userID = [comment userID];
        if ([userID isEqualToString:[TTAccountManager userID]] || isEmptyString(userID)) {
            return;
        }
        [self changeFollowStatus:isFollowed userID:userID];
    }
}

- (void)changeFollowStatus:(BOOL)isFollowed userID:(NSString *)userID
{
    WeakSelf;
    [self.subscribeButton startLoading];
    BOOL isLogin = [TTAccountManager isLogin];
    ExploreOrderedData * orderedData = self.orderedData;
    TTFollowNewSource source = TTFollowNewSourceFeedArticle;
//    if (!isFollowed && self.orderedData.redpacketModel) {
//        source = TTFollowNewSourceFeedArticleRedPacket;
//    }
    [[TTFollowManager sharedManager] startFollowAction:isFollowed? FriendActionTypeUnfollow: FriendActionTypeFollow  userID:userID platform:nil name:nil from:nil reason:nil newReason:nil newSource:@(source) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        StrongSelf;
        if (!error) {
            NSString *hint = nil;
            switch (type) {
                case FriendActionTypeFollow: {
                    [self ad_trackWithTag:@"embeded_ad" label:@"follow_click" extra:nil];
                    
                    
                    //                        hint = NSLocalizedString(@"关注成功", nil);
                    [TTLayOutCellDataHelper setFollowed:YES withOrderedData:self.orderedData];
//                    if (orderedData.redpacketModel) {
//                        [self.subscribeButton stopLoading:^{}];
//                        TTRedPacketTrackModel * redPacketTrackModel = [TTRedPacketTrackModel new];
//                        if ([self.originalData isKindOfClass:[Article class]]) {
//                            redPacketTrackModel.userId = [self.orderedData.article userIDForAction];
//                            redPacketTrackModel.mediaId = [self.orderedData.article.mediaInfo tt_stringValueForKey:@"media_id"];
//                        }else if ([self.originalData isKindOfClass:[Comment class]]) {
//                            redPacketTrackModel.userId = self.orderedData.comment.userID;
//                        }
//                        redPacketTrackModel.categoryName = self.orderedData.categoryID;
//                        redPacketTrackModel.source = @"list";
//                        redPacketTrackModel.position = @"avatar_right";
//                        [[TTRedPacketManager sharedManager] presentRedPacketWithRedpacket:orderedData.redpacketModel
//                                                                                   source:redPacketTrackModel
//                                                                           viewController:[TTUIResponderHelper topmostViewController]];
//                        [orderedData clearRedpacket];
//                    }else {
                        //无红包，请求推人卡片
//                        [self handleExpandStateChange:YES];
//                    }
                    break;
                }
                case FriendActionTypeUnfollow: {
                    [self ad_trackWithTag:@"embeded_ad" label:@"cancel_follow_click" extra:nil];
                    
                    //                        hint = NSLocalizedString(@"取消关注", nil);
                    [TTLayOutCellDataHelper setFollowed:NO withOrderedData:self.orderedData];
//                    [self handleExpandStateChange:NO];
                    
                    break;
                }
                default: {
                    [self.subscribeButton stopLoading:^{}];
                }
                    break;
            }
            [self layoutSubscribeButton];
            if (!isEmptyString(hint)) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            }
        }
        else{
            NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
            if (isEmptyString(hint)) {
                //                    hint = NSLocalizedString(type == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
            }
            [self.subscribeButton stopLoading:^{}];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            [self layoutSubscribeButton];
        }
    }];
}

- (void)operationBtnClick:(SSThemedButton *)btn
{
    self.folding = YES;
//    if (_orderedData.cellLayOut.isExpand) {
//        [self handleExpandStateChange:NO];
//    } else {
//        [self handleExpandStateChange:YES];
//    }
    btn.selected = !btn.selected;
    [UIView animateWithDuration:0.25 animations:^{
        if(btn.selected) {
            self.foldRecommendButton.imageView.transform =  CGAffineTransformMakeRotation(M_PI - 0.001);
        } else {
            self.foldRecommendButton.imageView.transform = CGAffineTransformRotate(self.foldRecommendButton.imageView.transform, M_PI + 0.001);
        }
    }];
}

- (void)bringAdButtonBackToCell
{
    if (self.orderedData.article.adModel && self.adButton) {
        [self.picView addSubview:self.adButton];
    }
    self.adButton.right = self.picView.width - [TTDeviceUIUtils tt_padding:kCellPicLabelHorizontalPadding];
    self.adButton.bottom = self.picView.height - [TTDeviceUIUtils tt_padding:kCellPicLabelHorizontalPadding];
}

- (NSDictionary *)extraDic {
    if (!_extraDic) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if ([self.orderedData originalData]) {
            if (self.originalData.uniqueID > 0) {
                dic[@"item_id"] = @(self.originalData.uniqueID);
            }
            if ([self.orderedData categoryID]) {
                dic[@"category_id"] = [self.orderedData categoryID];
            }
            if ([self.orderedData concernID]) {
                dic[@"concern_id"] = [self.orderedData concernID];
            }
            dic[@"refer"] = [NSNumber numberWithInteger:[self refer]];
            dic[@"gtype"] = @1;
        }
        _extraDic = dic;
    }
    return _extraDic;
}

- (NSDictionary *)extraDicForUFCell
{
    if (!_extraDicForUFCell) {
        NSDictionary *extraDic = [TTLayOutCellDataHelper getLogExtraDictionaryWithOrderedData:self.orderedData];
        _extraDicForUFCell = extraDic;
    }
    return _extraDicForUFCell;
}

- (ExploreItemActionManager *)itemActionManager {
    if (_itemActionManager == nil) {
        _itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    return _itemActionManager;
}

- (TTActivityShareManager *)activityActionManager {
    if (_activityActionManager == nil) {
        _activityActionManager = [[TTActivityShareManager alloc] init];
    }
    return _activityActionManager;
}

- (void)downloadButtonActionFired:(ExploreActionButton *)sender {
    if (self.orderedData) {
        id<TTAdFeedModel> adModel = self.orderedData.adModel;
        if ([adModel isCreativeAd]) {
            TTTouchContext *touchContext = [sender.lastTouchContext toView:self];
            NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:2];
            NSMutableDictionary *ad_extra_data = [NSMutableDictionary dictionaryWithCapacity:8];
            NSDictionary *adCellLayoutInfo = [self adCellLayoutInfo];
            if (adCellLayoutInfo) {
                [ad_extra_data addEntriesFromDictionary:adCellLayoutInfo];
            }
            NSDictionary *touchInfo = [touchContext touchInfo];
            if (touchInfo) {
                [ad_extra_data addEntriesFromDictionary:touchInfo];
            }
            
            [extrData setValue:[TTTouchContext format2JSON:ad_extra_data] forKey:@"ad_extra_data"];
            [extrData setValue:@"2" forKey:@"ext_value"];
            
            if ([adModel adType] == ExploreActionTypeApp){
                [extrData setValue:@"1" forKey:@"has_v3"];
                [[self class] trackRealTime:self.orderedData extraData:extrData];
            }
            
            NSString *adID = adModel.ad_id;
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click" eventName:@"embeded_ad" extra:extrData duration:0];
            NSTimeInterval duration = [[SSADEventTracker sharedManager] durationForAdThisTime:adID];
            NSString *trackInfo = [[TTAdImpressionTracker sharedImpressionTracker] endTrack:adID];
            NSMutableDictionary *adTrackExtra = [NSMutableDictionary dictionaryWithCapacity:1];
            [adTrackExtra setValue:trackInfo forKey:@"ad_extra_data"];
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"show_over" eventName:@"embeded_ad" extra:adTrackExtra duration:duration];
            
            if ([adModel adType] == ExploreActionTypeWeb) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"ad_click" eventName:@"embeded_ad" clickTrackUrl:NO];
            }
            else if ([adModel adType] == ExploreActionTypeAction) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_call" eventName:@"feed_call" extra:@"2" clickTrackUrl:NO];
                [self listenCall:adModel];
            }
            else if ([adModel adType] == ExploreActionTypeApp){
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_start" eventName:@"feed_download_ad" clickTrackUrl:NO];
            }else if ([adModel adType] == ExploreActionTypeForm){
                [self showForm:self.orderedData];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_button" eventName:@"feed_form" clickTrackUrl:NO];
            }
            else if (adModel.adType == ExploreActionTypeCounsel) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_counsel" eventName:@"feed_counsel" clickTrackUrl:NO];
            }
            else if ([adModel adType] == ExploreActionTypeLocationAction){
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_call" eventName:@"lbs_ad" clickTrackUrl:NO];
                [self listenCall:adModel];
            }
            else if ([adModel adType] == ExploreActionTypeLocationForm){
                [self showForm:self.orderedData];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_button" eventName:@"lbs_ad" clickTrackUrl:NO];
            }
            else if ([adModel adType] == ExploreActionTypeLocationcounsel){
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_counsel" eventName:@"lbs_ad" clickTrackUrl:NO];
            }
            else if ([adModel adType] == ExploreActionTypeDiscount){
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_discount" eventName:@"feed_discount" clickTrackUrl:NO];
            }
            else if ([adModel adType] == ExploreActionTypeCoupon) {
                [self showCoupon:self.orderedData];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_coupon" eventName:@"feed_coupon" clickTrackUrl:NO];
            }
            
            if ([self.cell respondsToSelector:@selector(didEndDisplaying)]) {
                [self.cell didEndDisplaying];
            }
            NSMutableDictionary *context = @{}.mutableCopy;
            context[@"source_cellview"] = self.cell;
            [self.actionButton actionButtonClicked:sender context:context];
        }
    }
}

- (void)showForm:(ExploreOrderedData *)orderdata
{
    id<TTAdFeedModel> adModel = orderdata.adModel;
    TTAdAppointAlertModel* model = [[TTAdAppointAlertModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra formUrl:adModel.form_url width:adModel.form_width height:adModel.form_height sizeValid:adModel.use_size_validation];
    
    [TTAdAction handleFormActionModel:model fromSource:TTAdApointFromSourceFeed completeBlock:^(TTAdApointCompleteType type) {
        if (type == TTAdApointCompleteTypeCloseForm) {
            if (adModel.adType == ExploreActionTypeLocationForm) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"click_cancel" eventName:@"lbs_ad"];
            }
            else {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"click_cancel" eventName:@"feed_form"];
            }
        }
        else if (type == TTAdApointCompleteTypeLoadFail){
            if (adModel.adType == ExploreActionTypeLocationForm) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"load_fail" eventName:@"lbs_ad"];
            }
            else {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"load_fail" eventName:@"feed_form"];
            }
        }
    }];
}


- (void)showCoupon:(ExploreOrderedData *)orderdata
{
    ExploreOrderedADModel* adModel = orderdata.article.adModel;
    TTAdAppointAlertModel* model = [[TTAdAppointAlertModel alloc] initWithAdId:orderdata.adIDStr logExtra:orderdata.logExtra formUrl:orderdata.raw_ad.form_url width:orderdata.raw_ad.form_width height:orderdata.raw_ad.form_height sizeValid:orderdata.raw_ad.use_size_validation];
    
    [TTAdAction handleFormActionModel:model fromSource:TTAdApointFromSourceFeed completeBlock:^(TTAdApointCompleteType type) {
        if (type == TTAdApointCompleteTypeLoadSuccess) {
            if (adModel.adType == ExploreActionTypeCoupon) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"coupon_show" eventName:@"feed_coupon"];
            }
        } else if (type == TTAdApointCompleteTypeCloseForm) {
            if (adModel.adType == ExploreActionTypeCoupon) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"click_cancel" eventName:@"feed_coupon"];
            }
        } else if (type == TTAdApointCompleteTypeLoadFail){
            if (adModel.adType == ExploreActionTypeCoupon) {
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"load_fail" eventName:@"feed_coupon"];
            }
        }
    }];
}


+ (void)trackRealTime:(ExploreOrderedData*)orderData extraData:(NSDictionary *)extraData
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:orderData.ad_id forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:orderData.log_extra forKey:@"log_extra"];
    [params setValue:@"2" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [params addEntriesFromDictionary:[orderData realTimeAdExtraData:@"embeded_ad" label:@"click" extraData:extraData]];
    [TTTracker eventV3:@"realtime_click" params:params];
}

//监听电话状态
- (void)listenCall:(id<TTAdFeedModel>)adModel
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:adModel.ad_id forKey:@"ad_id"];
    [dict setValue:adModel.log_extra forKey:@"log_extra"];
    [dict setValue:[NSDate date] forKey:@"dailTime"];
    [dict setValue:adModel.dialActionType forKey:@"dailActionType"];
    if (adModel && adModel.adType == ExploreActionTypeLocationAction) {
        [dict setValue:@"lbs_ad" forKey:@"position"];
    }
    else {
        [dict setValue:@"feed_call" forKey:@"position"];
    }
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance call_callAdDict:dict];
}

#pragma mark - KVO

- (void)addKVOForCell
{
    if ([self.orderedData.originalData isKindOfClass:[Article class]]) {
        [self addKVOForArticleCell];
    }
    else if ([self.orderedData.originalData isKindOfClass:[Comment class]]) {
        [self addKVOForCommentCell];
    }
}

- (void)removeKVOForCell
{
    if ([self.orderedData.originalData isKindOfClass:[Article class]]) {
        [self removeKVOForArticleCell];
    }
    else if ([self.orderedData.originalData isKindOfClass:[Comment class]]) {
        [self removeKVOForCommentCell];
    }
}

- (void)addKVOForArticleCell
{
    Article *article = self.orderedData.article;
    if (article && article.managedObjectContext) {
        WeakSelf;
        if (![self.orderedData isU11Cell]) {//非u11cell kvo的数量少一些
            [self.KVOController observe:article keyPaths:@[@"userRepined", @"commentCount"] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                StrongSelf;
                int64_t oldValue = [[change objectForKey:NSKeyValueChangeOldKey] longLongValue];
                int64_t newValue = [[change objectForKey:NSKeyValueChangeNewKey] longLongValue];
                if (oldValue == newValue) {
                    return;
                }
                [self calculateFrameAndRefreshUI];
            }];
            
            [self.KVOController observe:article keyPaths:@[@"hasRead"] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
                StrongSelf;
                BOOL old = [change[NSKeyValueChangeOldKey] boolValue];
                BOOL new = [change[NSKeyValueChangeNewKey] boolValue];
                if (old == new) {
                    return;
                }
                [self updateContentColor];
            }];
        }
        else {
            [self.KVOController observe:article keyPaths:@[@"userInfo.follow",@"userRelation.is_subscribe",@"userRepined",@"commentCount",@"diggCount",@"likeCount",@"actionDataModel.repostCount"] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
                StrongSelf;
                int64_t oldValue = [[change objectForKey:NSKeyValueChangeOldKey] longLongValue];
                int64_t newValue = [[change objectForKey:NSKeyValueChangeNewKey] longLongValue];
                if (oldValue == newValue) {
                    return;
                }
                [self calculateFrameAndRefreshUI];
            }];
            
            [self.KVOController observe:article keyPaths:@[@"hasRead"] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
                StrongSelf;
                BOOL old = [change[NSKeyValueChangeOldKey] boolValue];
                BOOL new = [change[NSKeyValueChangeNewKey] boolValue];
                if (old == new) {
                    return;
                }
                [self updateContentColor];
            }];
            
            [self.KVOController observe:article
                               keyPaths:@[@"userInfo.name",@"userInfo.verified_content",@"recommendReason",@"userInfo.user_auth_info",@"userInfo.avatar_url"]
                                options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block
                                       :^(id observer, id object, NSDictionary *change) {
                                           StrongSelf;
                                           NSString *old = change[NSKeyValueChangeOldKey];
                                           NSString *new = change[NSKeyValueChangeNewKey];
                                           if ([old isKindOfClass:[NSNull class]] || [new isKindOfClass:[NSNull class]]) {
                                               return;
                                           }
                                           if (isEmptyString(old) || isEmptyString(new) || [old isEqualToString:new]) {
                                               return;
                                           }
                                           [self calculateFrameAndRefreshUI];
                                       }];
        }
    }
}


//- (void)handleExpandStateChange:(BOOL)follow {
//    self.handlingExpand = YES;
//
//    if (follow) {
//        WeakSelf;
//        [TTRecommendUserCollectionView requestDataWithSource:@"feedrec" scene:@"follow" sceneUserId:[[self.orderedData article] userIDForAction] groupId:self.orderedData.article.groupModel.groupID complete:^(NSArray<FRRecommendCardStructModel *> *models) {
//            StrongSelf;
//            if (models) {
////                [[RecommendCardCache defaultCache] insertRecommendArray:self.collectionViewWrapper.collectionView.allUserModels forCellId:self.orderedData.uniqueID];
//
//                self.orderedData.cellLayOut.needUpdateAllFrame = YES;
//                self.orderedData.cellLayOut.isExpand = YES;
//                [self.collectionViewWrapper.collectionView configUserModels:models requesetModel:nil];
//
//                [TTTrackerWrapper eventV3:@"follow_card" params:@{@"action_type":@"show",
//                                                                  @"category_name":self.orderedData.categoryID,
//                                                                  @"source": @"list",
//                                                                  @"is_direct" : @(0)
//                                                                  }];
//                [self.tableView beginUpdates];
//                [self.tableView endUpdates];
//                self.handlingExpand = NO;
//
//                if (!self.folding) {
//                    self.unInterestedButton.alpha = 0;
//                }
//                [UIView animateWithDuration:0.25 animations:^{
//                    self.collectionViewWrapper.alpha = 1;
//                    [self calculateFrameAndRefreshUI];
//                    if (!self.folding) {
//                        self.foldRecommendButton.alpha = 1;
//                    } else {
//                        self.folding = NO;
//                    }
//                    self.sanjiaoIcon.alpha = 1;
//
//                } completion:^(BOOL finished) {
//                    [self.collectionViewWrapper.collectionView willDisplay];
//                    [self.subscribeButton stopLoading:^{}];
//                }];
//            } else {
//                [self.subscribeButton stopLoading:^{}];
//            }
//        }];
//    } else {
//        self.orderedData.cellLayOut.needUpdateAllFrame = YES;
//        self.orderedData.cellLayOut.isExpand = NO;
//        [self.tableView beginUpdates];
//        [self.tableView endUpdates];
//        self.handlingExpand = NO;
//        if (!self.folding) {
//            self.foldRecommendButton.alpha = 0;
//        }
//        [UIView animateWithDuration:0.25 animations:^{
//            self.collectionViewWrapper.alpha = 0;
//            [self calculateFrameAndRefreshUI];
//            self.sanjiaoIcon.alpha = 0;
//            if (!self.folding) {
//                self.unInterestedButton.alpha = 1;
//            } else {
//                self.folding = NO;
//            }
//        } completion:^(BOOL finished) {
//            [self.collectionViewWrapper.collectionView didEndDisplaying];
////            [[RecommendCardCache defaultCache] clearDataOfUniqId:self.orderedData.uniqueID];
//            [self.subscribeButton stopLoading:^{}];
//        }];
//    }
//
//}


- (void)removeKVOForArticleCell
{
    Article *article = self.orderedData.article;
    if (article && article.managedObjectContext) {
        @try {
            [self.KVOController unobserveAll];
        } @catch (NSException *exception) {
            //可能出现异常: Fatal Exception: NSInternalInconsistencyException
            // Cannot remove an observer <_FBKVOSharedController 0x1704213c0> for the key path "****" from <ExploreOrderedData 0x132a80620>, most likely because the value for the key "**" has changed without an appropriate KVO notification being sent. Check the KVO-compliance of the ExploreOrderedData class.
        } @finally {
        }
    }
}

- (void)addKVOForCommentCell
{
    Comment *comment = self.orderedData.comment;
    if (comment && comment.managedObjectContext) {
        WeakSelf;
        [self.KVOController observe:comment keyPaths:@[@"commentDict.digg_count",@"commentDict.user_digg",@"commentDict.reply_count",@"commentExtra.follow",@"commentExtra.forward_info.forward_count", @"hasRead"] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
            StrongSelf;
            int64_t oldValue = [[change objectForKey:NSKeyValueChangeOldKey] longLongValue];
            int64_t newValue = [[change objectForKey:NSKeyValueChangeNewKey] longLongValue];
            if (oldValue == newValue) {
                return;
            }
            [self calculateFrameAndRefreshUI];
        }];
    }
}

- (void)removeKVOForCommentCell
{
    Comment *comment = self.orderedData.comment;
    if (comment && comment.managedObjectContext) {
        @try {
            [self.KVOController unobserveAll];
        } @catch (NSException *exception) {
            //可能出现异常: Fatal Exception: NSInternalInconsistencyException
            // Cannot remove an observer <_FBKVOSharedController 0x1704213c0> for the key path "****" from <ExploreOrderedData 0x132a80620>, most likely because the value for the key "**" has changed without an appropriate KVO notification being sent. Check the KVO-compliance of the ExploreOrderedData class.
        } @finally {
        }
    }
}


- (void)trackForU11CellShowInList
{
    if ([self.orderedData isU11Cell]){
        if ([self.orderedData.originalData isKindOfClass:[Article class]]){
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"cell" label:@"show" value:self.orderedData.uniqueID source:nil extraDic:self.extraDicForUFCell];
            
            NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithDictionary:[TTLayOutCellDataHelper getLogExtraDictionaryWithOrderedData:self.orderedData]];
            [extraDic setValue:self.orderedData.uniqueID forKey:@"group_id"];
            [extraDic setValue:self.orderedData.categoryID forKey:@"source"];
            [extraDic setValue:self.orderedData.categoryID forKey:@"category_name"];
            [extraDic setValue:self.orderedData.logPb forKey:@"log_pb"];
            [TTTrackerWrapper eventV3:@"cell_show" params:extraDic isDoubleSending:YES];
        }
        else if ([self.orderedData.originalData isKindOfClass:[Comment class]]){
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"cell" label:@"show" value:self.orderedData.comment.groupID source:nil extraDic:self.extraDicForUFCell];
            
            NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithDictionary:[TTLayOutCellDataHelper getLogExtraDictionaryWithOrderedData:self.orderedData]];
            [extraDic setValue:self.orderedData.comment.groupID forKey:@"group_id"];
            [extraDic setValue:self.orderedData.categoryID forKey:@"source"];
            [extraDic setValue:self.orderedData.categoryID forKey:@"category_name"];
            [extraDic setValue:self.orderedData.logPb forKey:@"log_pb"];
            [TTTrackerWrapper eventV3:@"cell_show" params:extraDic isDoubleSending:YES];
        }
    }
}

- (void)trackCellShow {
//    if (self.orderedData.redpacketModel) {
//        NSMutableDictionary * showEventExtraDic  = [NSMutableDictionary dictionary];
//        [showEventExtraDic setValue:self.orderedData.redpacketModel.user_info.user_id
//                             forKey:@"user_id"];
//        [showEventExtraDic setValue:@"show"
//                             forKey:@"action_type"];
//        [showEventExtraDic setValue:@"avatar_right"
//                             forKey:@"position"];
//        [self trackWithEvent:@"red_button" extraDic:showEventExtraDic];
//    }
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    Comment *comment = self.orderedData.comment;
    if (comment) {
        comment.hasRead = @(YES);
        NSString *commentURLStr = [self commentSchemeURLStr];
        NSURL *commentURL = [TTStringHelper URLWithURLString:commentURLStr];
        if ([[TTRoute sharedRoute] canOpenURL:commentURL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:commentURL];
            NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithDictionary:[TTLayOutCellDataHelper getLogExtraDictionaryWithOrderedData:self.orderedData]];
            [extraDic setValue:@(1) forKey:@"click_area"];
            //产品用的埋点 这里发两个埋点，没毛病
//            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"cell" label:@"go_detail" value:comment.groupID source:nil extraDic:extraDic];
            [extraDic setValue:self.orderedData.itemID forKey:@"item_id"];
            [extraDic setValue:comment.aggrType forKey:@"aggr_type"];
        }
    } else {
        // 默认逻辑
        CGRect picViewFrame = CGRectZero;
        TTArticlePicViewStyle picViewStyle = TTArticlePicViewStyleNone;
        TTArticlePicView *picView = self.picView;
        if (picView && picView.superview) {
            picViewFrame = [picView convertRect:picView.bounds toView:self];
            picViewStyle = picView.style;
        }
        context.picViewFrame = picViewFrame;
        context.picViewStyle = picViewStyle;
        context.targetView = self;
        [super didSelectWithContext:context];
        if (self.orderedData.cellType == ExploreOrderedDataCellTypeAppDownload) {
            NSMutableDictionary *dict = [self.orderedData.raw_ad.detail_info mutableCopy];
            [dict setValue:self.actionButton.adModel.apple_id forKey:@"itunes_id"];
            [dict setValue:self.actionButton.adModel.ad_id forKey:@"ad_id"];
            [dict setValue:self.actionButton.adModel.log_extra forKey:@"log_extra"];
            if (self.orderedData.raw_ad.inner_open_type && [TTADAppStoreContainerViewModel validateInfoDict:dict]) {
                TTADAppStoreContainerViewModel *viewModel = [[TTADAppStoreContainerViewModel alloc] initWithDict:dict];
                TTADAppStoreContainerController *appStoreContainerController = [[TTADAppStoreContainerController alloc] initWithViewModel:viewModel];
                [[TTUIResponderHelper topNavigationControllerFor:self] pushViewController:appStoreContainerController animated:YES];
            } else {
                [self.actionButton actionButtonClicked:nil showAlert:YES];
            }
        }
    }
}


- (NSString*) commentSchemeURLStr {
    if ([self.orderedData.originalData isKindOfClass:[Comment class]]) {
        Comment *comment = self.orderedData.comment;
        if (comment != nil) {
            return [NSString stringWithFormat:@"%@&itemId=%@&sourceType=9&gtype=%@&recommendReson=%@&recommendType=%@&follow=%@&clickArea=%@&category_name=%@&commentId=%@&groupId=%@&uniqueID=%lld",comment.commentOpenURL,self.orderedData.itemID,@(SSImpressionModelTypeU11CellListItem),[self.orderedData ugcRecommendReason]?:@"",comment.recommendReasonType,@(comment.isFollowed),@(1),self.orderedData.categoryID?:@"", comment.commentID, comment.groupID, comment.uniqueID];
        }
    }
    return @"";
}

// 广告需要获取当前 cell 的布局信息
- (nullable NSDictionary *)adCellLayoutInfo {
    NSMutableDictionary *layoutInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    if (_unInterestedButton) {
        CGRect dislikeFrame = _unInterestedButton.bounds;
        dislikeFrame = [self convertRect:dislikeFrame fromView:_unInterestedButton];
        [layoutInfo setValue:@(CGRectGetMinX(dislikeFrame)) forKey:@"lu_x"];
        [layoutInfo setValue:@(CGRectGetMinY(dislikeFrame)) forKey:@"lu_y"];
        [layoutInfo setValue:@(CGRectGetMaxX(dislikeFrame)) forKey:@"rd_x"];
        [layoutInfo setValue:@(CGRectGetMaxY(dislikeFrame)) forKey:@"rd_y"];
    }
    [layoutInfo setValue:@(CGRectGetWidth(self.frame)) forKey:@"width"];
    [layoutInfo setValue:@(CGRectGetHeight(self.frame)) forKey:@"height"];
    return layoutInfo;
}

#pragma mark - GET/SET

//- (TTRecommendUserCollectionViewWrapper *)collectionViewWrapper {
//    if (!_collectionViewWrapper && [self.orderedData.cellLayOut isKindOfClass:[TTLayOutUFCellBaseModel class]]) {
//        TTLayOutUFCellBaseModel *layout = (TTLayOutUFCellBaseModel *)self.orderedData.cellLayOut;
//        if (!layout.isExpand) {
//            return _collectionViewWrapper;
//        }
//
//        _collectionViewWrapper = [[TTRecommendUserCollectionViewWrapper alloc] initWithFrame:CGRectZero isWeitoutiao:[self.orderedData.categoryID isEqualToString:kTTWeitoutiaoCategoryID]];;
//        _collectionViewWrapper.collectionView.recommendUserDelegate = self;
//        _collectionViewWrapper.backgroundColorThemeKey = kColorBackground3;
//        _collectionViewWrapper.alpha = 0;
//        [self addSubview:_collectionViewWrapper];
//    }
//    return _collectionViewWrapper;
//}

#pragma mark - TTRecommendUserCollectionViewDelegate

- (void)trackWithEvent:(NSString *)event extraDic:(NSDictionary *)extraDic {
    if (isEmptyString(event)) {
        return;
    }
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:self.orderedData.categoryID forKey:@"category_name"];
    if (extraDic) {
        [dict addEntriesFromDictionary:extraDic];
    }
    [dict setValue:@"list" forKey:@"source"];
    if ([event isEqualToString:@"follow"] || [event isEqualToString:@"unfollow"]) { // "rt_follow" 关注动作统一化 埋点
        NSMutableDictionary* rtFollowDict = [NSMutableDictionary dictionaryWithObject:@"from_recommend" forKey:@"follow_type"];
        [rtFollowDict setValue:self.orderedData.categoryID forKey:@"category_name"];
        [rtFollowDict setValue:@"list_follow_card_horizon" forKey:@"source"];
        [rtFollowDict setValue:self.orderedData.logPb forKey:@"log_pb"];
        [rtFollowDict setValue:[extraDic objectForKey:@"order"] forKey:@"order"];
        [rtFollowDict setValue:[extraDic objectForKey:@"user_id"] forKey:@"to_user_id"];
        [rtFollowDict setValue:[extraDic objectForKey:@"server_source"] forKey:@"server_source"];
        [rtFollowDict setValue:[extraDic objectForKey:@"is_redpacket"] forKey:@"is_redpacket"];
        
        if ([event isEqualToString:@"follow"]) {
            [TTTrackerWrapper eventV3:@"rt_follow" params:rtFollowDict];
        } else {
            [TTTrackerWrapper eventV3:@"rt_unfollow" params:rtFollowDict];
        }
    } else {
        [TTTrackerWrapper eventV3:event params:dict];
    }
}

- (NSDictionary *)impressionParams {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:self.orderedData.categoryID forKey:@"category_name"];
    [dict setValue:self.orderedData.uniqueID forKey:@"unique_id"];
    
    Article *article = [self.orderedData article];
    NSString *userID = [article userIDForAction];
    [dict setValue:userID forKey:@"profile_user_id"];
    
    return dict;
}

- (NSString *)categoryID {
    return self.orderedData.categoryID;
}

@end


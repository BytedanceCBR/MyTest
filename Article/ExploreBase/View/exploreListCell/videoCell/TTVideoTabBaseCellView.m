//
//  TTVideoTabBaseCellView.m
//  Article
//
//  Created by 王双华 on 15/10/10.
//
//
#import "TTVideoTabBaseCellView.h"
#import "TTImageView.h"
#import "SSThemed.h"
#import "Article.h"
#import "ExploreCellHelper.h"
#import "TTLabelTextHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTVPlayVideo.h"
#import "TTImageView+TrafficSave.h"
#import "ExploreItemActionManager.h"
#import "SSActivityView.h"
#import "TTActivityShareManager.h"
#import "ArticleShareManager.h"
#import "TTRoute.h"
#import "ExploreArticleVideoCellCommentView.h"
#import "NewsLogicSetting.h"
#import "TTAlphaThemedButton.h"
#import "TTVideoCommon.h"

#import "TTIndicatorView.h"
#import "TTReportManager.h"

#import "TTVideoAutoPlayManager.h"

//#import "TTVideoTabLiveCellView.h"
#import "TTUISettingHelper.h"
#import "TTVideoEmbededAdButton.h"
#import "TTMovieViewCacheManager.h"
#import "TTDeviceUIUtils.h"
#import "ExploreEntryManager.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTActivity.h"
#import "TTStringHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTActionPopView.h"
#import "TTFeedDislikeView.h"
#import "ExploreEntryManager.h"
#import "ExploreMixListDefine.h"
#import "TTTAttributedLabel.h"
#import "TTFollowNotifyServer.h"
#import "TTActionSheetController.h"
#import "TTMovieExitFullscreenAnimatedTransitioning.h"
//#import "FRRouteHelper.h"
#import <TTAccountBusiness.h>
#import "TTNetworkManager.h"

#import "NSObject+FBKVOController.h"
#import "SSURLTracker.h"
#import "TTArticleCategoryManager.h"
//#import "TTRepostViewController.h"
//#import "TTRepostOriginModels.h"
#import "TTNavigationController.h"

#import "FriendDataManager.h"
#import "TTVideoTabBaseCellPlayControl.h"
#import "TTVideoTabBaseCellOldPlayControl.h"
#import "TTVideoTabBaseCellNewPlayControl.h"
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import "TTPlatformSwitcher.h"
#import "TTFeedDislikeView.h"
#import <TTServiceKit/TTServiceCenter.h>
#import <TTTracker/TTTrackerProxy.h>
#import "UIView+SupportFullScreen.h"
//#import "TTRedPacketManager.h"

#import "TTActivityShareSequenceManager.h"
#import "TTURLUtils.h"
//#import "TTShareToRepostManager.h"
#import "TTVSettingsConfiguration.h"
#import "NSDictionary+TTGeneratedContent.h"


#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"
#import "NSDictionary+TTGeneratedContent.h"
#import "SSADEventTracker.h"
#import "TTAdAction.h"
#import "TTAdAppointAlertView.h"
#import "TTAdFeedModel.h"
#import "TTAdManagerProtocol.h"
#import "TTAdMonitorManager.h"

#import "TTVideoCellActionBar.h"
#import "TTVVideoDetailViewController.h"

#define kVideoTitleX 15
#define kVideoTitleY 12
#define B_kVideoTitleY 8

#define kSourceLabelFontSize 12
#define kSourceLabelBottomGap 6
#define kDurationLabelFontSize 10
#define kDurationLabelRight 6.0
#define kDurationLabelBottom 6.0
#define kDurationLabelInsetLeft 6.0
#define kDurationLabelHeight 20.0
#define kDurationLabelMinWidth 44.0

#define kTopMaskH 80
#define kBottomMaskH 40

#define kAbstractBottomPadding 8
#define kCommentViewBottomPadding 8
#define kBottomViewH [TTDeviceUIUtils tt_newPadding:6]
#define B_kBottomViewH [TTDeviceUIUtils tt_newPadding:3]

extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;
extern CGFloat ttvs_listVideoMaxHeight(void);
extern BOOL ttvs_isShareIndividuatioEnable(void);

@interface TTVideoTabBaseCellView()<SSActivityViewDelegate,UIGestureRecognizerDelegate ,TTVideoTabBaseCellPlayControlDelegate, TTActivityShareManagerDelegate>

@property (nonatomic, strong) SSThemedLabel *videoTitleLabel;
@property (nonatomic, strong) UILabel *playTimesLabel;

//下面的分割线
@property (nonatomic, strong) UIView      *sepLineView;
@property (nonatomic, strong) UIView      *bottomView;
@property (nonatomic, strong) UIImageView *topMaskView;
@property (nonatomic, strong) TTImageView *logo;
@property (nonatomic, strong) ExploreArticleVideoCellCommentView *videoCommentView;

@property (nonatomic, strong) ExploreItemActionManager *itemActionManager;
@property (nonatomic, strong) TTActivityShareManager   *activityActionManager;
@property (nonatomic, strong) SSActivityView           *phoneShareView;

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) TTActionSheetController *actionSheetController;

@property (nonatomic, strong) TTVideoTabBaseCellPlayControl *player;
@property (nonatomic, assign) BOOL hasRedPacket;
@end


@implementation TTVideoTabBaseCellView

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self reloadThemeUI];
        self.lock = [[NSLock alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeStatusChanged:) name:kPGCSubscribeStatusChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeStatusChangedFromVideoDetail:) name:kVideoDetailPGCSubscribeStatusChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStatusChanged:) name:RelationActionSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_refreshViewBeginRefresh:) name:@"kTTRefreshViewBeginRefresh" object:nil];
    }
    return self;
}

- (void)updateTypeLabel {
    
}

- (UIView *)infoBarView {
    return nil;
}

- (void)layoutInfoBarSubViews {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.actionBar.backgroundColor = self.backgroundColor;
}

- (ExploreArticleCellCommentView *)commentView
{
    if (!_videoCommentView) {
        _videoCommentView = [[ExploreArticleVideoCellCommentView alloc] initWithFrame:CGRectZero];
        _videoCommentView.delegate = self;
        [self addSubview:_videoCommentView];
        [self sendSubviewToBack:_videoCommentView];
    }
    return _videoCommentView;
}

- (void)setHasRedPacket:(BOOL)hasRedPacket
{
    if (_hasRedPacket != hasRedPacket) {
        _hasRedPacket = hasRedPacket;
        self.actionBar.redPacketFollowButton.hidden = !hasRedPacket;
        self.actionBar.followButton.hidden = hasRedPacket;
    }
}

- (TTVideoCellActionBar *)actionBar
{
    if (!_actionBar) {
        _actionBar = [[TTVideoCellActionBar alloc] initWithFrame:CGRectMake(0, self.logo.height, self.width, [self.class actionBarHeigth])];
        [self addSubview:_actionBar];
        [_actionBar.adActionButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_actionBar.avatarLabelButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_actionBar.avatarButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_actionBar.commentButton addTarget:self action:@selector(actionButtonClicked:)];
        [_actionBar.shareButton addTarget:self action:@selector(actionButtonClicked:)];
        [_actionBar.moreButton addTarget:self action:@selector(actionButtonClicked:)];
        [_actionBar.followButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_actionBar.redPacketFollowButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _actionBar.shareController.cellView = self;
    }
    return _actionBar;
}

- (void)removeCommentView
{
    if (_videoCommentView.superview) {
        _videoCommentView.delegate = nil;
        [_videoCommentView removeFromSuperview];
    }
}

#pragma mark -
/**
 *  width:图片宽度 height:图片高度 cwidth:容器宽度 proportionControllable:宽高比是否可控 proportion:宽高比
 */

+ (float)heightForImageWidth:(float)width height:(float)height constraintWidth:(float)cWidth proportion:(float)proportion
{
    if (proportion > 0.01) {//大于0.01做保护
        CGFloat height = cWidth / proportion;
        CGFloat maxHeight = ttvs_listVideoMaxHeight();
        if (maxHeight > 0 && height > maxHeight) {
            height = maxHeight;
        }
        height = ceilf(height);
        return height;
    }
    return [ExploreCellHelper heightForVideoImageWidth:width height:height constraintWidth:cWidth];
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheH > 0) {
            if (![TTDeviceHelper isPadDevice] && [orderedData nextCellHasTopPadding]) {
                
                if (ttvs_isVideoFeedCellHeightAjust() == 1) {
                    cacheH -= (B_kBottomViewH + [TTDeviceHelper ssOnePixel]) ;
                }else if (ttvs_isVideoFeedCellHeightAjust() > 1){
                    cacheH -= [TTDeviceHelper ssOnePixel];
                }else{
                    cacheH -= (kBottomViewH + [TTDeviceHelper ssOnePixel]) ;
                }
            }
            //NSLog(@"hit cacheH: %f %p %@", cacheH, (__bridge void*)orderedData, orderedData.essayData.content);
            return cacheH;
        }
        
        Article *article = orderedData.article;
        
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:orderedData.listLargeImageDict];
        
        // 根据图片实际宽高设置其在cell中的高度
        BOOL isPad = [TTDeviceHelper isPadDevice];
        float picWidth = isPad ? (width - 2 * kCellLeftPadding) : width;
        
        float imageHeight = [TTVideoTabBaseCellView heightForImageWidth:model.width height:model.height constraintWidth:picWidth proportion:[article.videoProportion floatValue]];
        
        CGFloat height = imageHeight;
        
        
        BOOL hasCommentView = [ExploreCellHelper shouldDisplayComment:article listType:listType];
        
        if (hasCommentView) {
            CGSize commentSize = [self updateCommentSize:article.commentContent cellWidth:width];
            height += commentSize.height + kCommentViewBottomPadding;
        }
        if ([TTDeviceHelper isPadDevice]) {
            height += [self actionBarHeigth] + [TTDeviceHelper ssOnePixel];
        }
        else {
            if (ttvs_isVideoFeedCellHeightAjust() == 1) {
                height += [self actionBarHeigth] + B_kBottomViewH + [TTDeviceHelper ssOnePixel];
            }else if (ttvs_isVideoFeedCellHeightAjust() > 1){
                height += [self actionBarHeigth];
            }else{
                height += [self actionBarHeigth] + kBottomViewH + [TTDeviceHelper ssOnePixel];
            }
        }
        
        height = ceilf(height);
        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];
        
        if (![TTDeviceHelper isPadDevice] && [orderedData nextCellHasTopPadding]) {
            
            if (ttvs_isVideoFeedCellHeightAjust() == 1) {
                height -= (B_kBottomViewH + [TTDeviceHelper ssOnePixel]) ;
            }else if (ttvs_isVideoFeedCellHeightAjust() > 1){
                height -= [TTDeviceHelper ssOnePixel];
            }else{
                height -= (kBottomViewH + [TTDeviceHelper ssOnePixel]) ;
            }
        }

        return ceilf(height);
    }
    
    return 0.f;
}

- (void)updatePic
{
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:self.orderedData.listLargeImageDict];
    self.logo.backgroundColorThemeKey = kColorBackground2;
    [self.logo setImageWithModelInTrafficSaveMode:model placeholderImage:nil success:^(UIImage *image, BOOL cached) {
        
    } failure:nil];
}

- (void)layoutPic
{
    // 根据图片实际宽高设置其在cell中的高度
    BOOL isPad = [TTDeviceHelper isPadDevice];
    float left = isPad ? kCellLeftPadding : 0;
    float picWidth = isPad ? (self.width - 2 * kCellLeftPadding) : self.width;
    
    float imageHeight = [TTVideoTabBaseCellView heightForImageWidth:self.logo.model.width height:self.logo.model.height constraintWidth:picWidth proportion:[[self.orderedData article].videoProportion floatValue]];
    self.logo.frame = CGRectMake(left, 0, picWidth, imageHeight);
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    if (self.orderedData && self.orderedData.managedObjectContext) {
        
        if ([self.orderedData isAdButtonUnderPic]) {
            //ab测
            self.actionBar.schemeType = TTVideoCellActionBarLayoutSchemeAD;
        }
        else if(self.actionBar.schemeType != TTVideoCellActionBarLayoutSchemeLive){
            self.actionBar.schemeType = TTVideoCellActionBarLayoutSchemeDefault;
        }
        
        Article *article = self.orderedData.article;
//        self.hasRedPacket = [self.orderedData redpacketModel] != nil;
        [self logShowRedPacketIfNeed];
        if (article && article.managedObjectContext) {
            if (!_logo) {
                _logo = [[TTImageView alloc] initWithFrame:CGRectZero];
                _logo.imageContentMode = TTImageViewContentModeScaleAspectFill;
                _logo.dayModeCoverHexString = @"00000033";
                [self addSubview:_logo];
            }
            
            if (!_topMaskView) {
                UIImage *topMaskImage = [[UIImage imageNamed:@"thr_shadow_video"] resizableImageWithCapInsets:UIEdgeInsetsZero];
                _topMaskView = [[UIImageView alloc] initWithImage:topMaskImage];
                _topMaskView.frame = CGRectMake(0, 0, self.width, kTopMaskH);
                [self.logo addSubview:_topMaskView];
            }
            
            if (!_videoTitleLabel) {
                _videoTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
                _videoTitleLabel.backgroundColor = [UIColor clearColor];
                CGFloat fontSize = [[self class] settedTitleFontSize];
                _videoTitleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
                _videoTitleLabel.textColor = [UIColor tt_themedColorForKey:kColorText10];
                [self.logo addSubview:_videoTitleLabel];
                _videoTitleLabel.numberOfLines = 2;
            }
            
            _videoTitleLabel.text = article.title;
            
            if (!_playTimesLabel) {
                _playTimesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                _playTimesLabel.font = [UIFont systemFontOfSize:12.f];
                if (ttvs_isVideoFeedCellHeightAjust() > 1){
                    _playTimesLabel.textColor = [UIColor tt_themedColorForKey:kColorLine1];
                }else{
                    _playTimesLabel.textColor = [UIColor tt_themedColorForKey:kColorText9];
                }
                [self.logo addSubview:_playTimesLabel];
            }
            self.playTimesLabel.hidden = NO;
            
            NSInteger playTimes = [article.videoDetailInfo longValueForKey:VideoWatchCountKey defaultValue:0];
            
            if (self.orderedData.isFakePlayCount) {
                _playTimesLabel.text = [[TTBusinessManager formatPlayCount:article.readCount] stringByAppendingString:@"次阅读"];
            }else{
                _playTimesLabel.text = [[TTBusinessManager formatPlayCount:playTimes] stringByAppendingString:@"次播放"];
            }
            
            [_playTimesLabel sizeToFit];
            
            [self updatePic];
            
            if (!_videoRightBottomLabel) {
                _videoRightBottomLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, kCellPicLabelWidth, kCellPicLabelHeight)];
                _videoRightBottomLabel.backgroundColorThemeKey = kColorBackground15;
                _videoRightBottomLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:10]];
                _videoRightBottomLabel.textColorThemeKey = kColorText12;
                _videoRightBottomLabel.layer.masksToBounds = YES;
                _videoRightBottomLabel.textAlignment = NSTextAlignmentCenter;
                [_videoRightBottomLabel setText:@"视频"];
                
                self.redDot = [[SSThemedView alloc] init];
                self.redDot.backgroundColorThemeKey = kColorText4;
                self.redDot.layer.cornerRadius = 3;
                self.redDot.hidden = YES;
                [_videoRightBottomLabel addSubview:self.redDot];
                
                [self.logo addSubview:_videoRightBottomLabel];
            }
            
            long long duration = [self.orderedData.article.videoDuration longLongValue];
            
            if (duration > 0) {
                int minute = (int)duration / 60;
                int second = (int)duration % 60;
                [_videoRightBottomLabel setText:[NSString stringWithFormat:@"%02i:%02i", minute, second]];
                _videoRightBottomLabel.hidden = NO;
            }
            else {
                [_videoRightBottomLabel setText:@"00:00"];
                _videoRightBottomLabel.hidden = YES;
            }
            
            if ([self.orderedData isListShowPlayVideoButton]) {
                if (!_playButton) {
                    self.playButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
                    NSString *imageName = [TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play";
                    _playButton.imageName = imageName;
                    _playButton.exclusiveTouch = YES;
                    [_playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
                    [self.logo addSubview:_playButton];
                }
                _playButton.hidden = NO;
            }
            else {
                _playButton.hidden = YES;
            }
            
            _playButton.userInteractionEnabled = ![self.orderedData isPlayInDetailView];
            
            [self updateAbstract];
            [self updateCommentView];
            
            
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
            
            if ([TTVSettingsConfiguration isNewPlayerEnabled] && ![self.orderedData couldAutoPlay] && self.orderedData.ad_id.longLongValue <= 0) {
                self.player = [[TTVideoTabBaseCellNewPlayControl alloc] init];
            }else{
                self.player = [[TTVideoTabBaseCellOldPlayControl alloc] init];
            }
            self.player.delegate = self;
            self.player.orderedData = self.orderedData;
            self.player.article = article;
            self.player.logo = self.logo;
            self.player.movieViewDelegateView = self;
            self.player.actionBar = self.actionBar;
        }
    }
}

- (void)fontSizeChanged
{
    CGFloat fontSize = [[self class] settedTitleFontSize];
    _videoTitleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    
    [super fontSizeChanged];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    _videoTitleLabel.textColor = [UIColor tt_themedColorForKey:kColorText10];
    _playTimesLabel.textColor = [UIColor tt_themedColorForKey:kColorText9];
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _sepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    if ([TTDeviceHelper isPadDevice]) {
        _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
}

static NSDictionary *fontSizes = nil;

+ (float)settedTitleFontSize {
    if (!fontSizes) {
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

+ (CGFloat)sourceLabelFontSize
{
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        return 14.0;
    } else {
        return 12.0;
    }
}

- (CGFloat)rightCornerLabelFontSize
{
    return 10;
}

- (void)changeFollowButton
{
    if (self.hasRedPacket) {
        [self.actionBar addSubview:self.actionBar.redPacketFollowButton];
        [self.actionBar.followButton removeFromSuperview];
    }else{
        [self.actionBar addSubview:self.actionBar.followButton];
        [self.actionBar.redPacketFollowButton removeFromSuperview];
    }
}

- (void)refreshUI
{
    [super refreshUI];
    [self layoutPic];
    
    [self changeFollowButton];
    
    _topMaskView.frame = CGRectMake(0, 0, self.logo.width, kTopMaskH);
    CGFloat height = [TTLabelTextHelper heightOfText:_videoTitleLabel.text fontSize:[[self class] settedTitleFontSize] forWidth:self.logo.width - kVideoTitleX * 2 constraintToMaxNumberOfLines:2];
    CGSize size = CGSizeMake(self.logo.width - kVideoTitleX * 2, height);
    
    
    if (ttvs_isVideoFeedCellHeightAjust() > 0) {
        _videoTitleLabel.frame = CGRectMake(kVideoTitleX, B_kVideoTitleY, size.width, size.height);
    }else{
        _videoTitleLabel.frame = CGRectMake(kVideoTitleX, kVideoTitleY, size.width, size.height);
    }
    _playTimesLabel.left = _videoTitleLabel.left;
    _playTimesLabel.top = _videoTitleLabel.bottom + 3;
    
    _videoRightBottomLabel.layer.cornerRadius = _videoRightBottomLabel.height / 2;
    
    _videoRightBottomLabel.right = self.logo.width - [TTDeviceUIUtils tt_padding:kDurationLabelRight];
    _videoRightBottomLabel.bottom = self.logo.height - [TTDeviceUIUtils tt_padding:kSourceLabelBottomGap];
    
    _playButton.frame = self.logo.bounds;
    
    _actionBar.frame = CGRectMake(0, self.logo.height, self.width, [self.class actionBarHeigth]);
    [_actionBar refreshWithData:self.orderedData];
    
    CGPoint origin = CGPointMake(kVideoTitleX, _actionBar.bottom);
    [self layoutAbstractAndCommentView:origin];
    self.hideBottomLine = YES;
    [self layoutBottomLine];
    
    CGFloat y = _actionBar.bottom;
    if (self.hasCommentView) {
        y += self.commentView.size.height;
        y += kCommentViewBottomPadding;
    }
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        _sepLineView.frame = CGRectMake(self.logo.left, y, self.logo.width, 0);
    }else{
        _sepLineView.frame = CGRectMake(self.logo.left, y, self.logo.width, [TTDeviceHelper ssOnePixel]);
    }
    if ([TTDeviceHelper isPadDevice]) {
        _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, 0);
    }
    else {
        if(ttvs_isVideoFeedCellHeightAjust() == 1){
            _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, B_kBottomViewH + ceilf([TTDeviceHelper ssOnePixel]));
            
        }else if(ttvs_isVideoFeedCellHeightAjust() > 1){
            _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width,0);
        }
        else{
            _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, kBottomViewH + ceilf([TTDeviceHelper ssOnePixel]));
        }
//        _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, kBottomViewH + ceilf([TTDeviceHelper ssOnePixel]));
    }
    
    if ([self.orderedData nextCellHasTopPadding]) {
        _sepLineView.hidden = YES;
    } else {
        _sepLineView.hidden = NO;
    }
    [self bringSubviewToFront:_actionBar];
}

- (void)layoutAbstractAndCommentView:(CGPoint)origin
{
    CGFloat x = origin.x;
    CGFloat y = origin.y;
    
    
    
    if (self.hasCommentView) {
        CGSize commentSize = [self.class updateCommentSize:[self.orderedData.article commentContent] cellWidth:self.width];
        self.commentView.frame = CGRectMake(x, y, self.width - kCellLeftPadding - kCellRightPadding, commentSize.height);
    }
}

+ (CGSize)updateCommentSize:(NSString*)commentContent cellWidth:(CGFloat)cellWidth
{
    CGSize result = CGSizeZero;
    if (!isEmptyString(commentContent)) {
        NSMutableAttributedString *attributedString = [TTLabelTextHelper attributedStringWithString:commentContent fontSize:kCellCommentViewFontSize lineHeight:kCellCommentViewLineHeight];
        
        CGFloat commentWidth = cellWidth - kCellLeftPadding - kCellRightPadding;
        
        result = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString withConstraints:CGSizeMake(commentWidth, 999) limitedToNumberOfLines:kCellCommentViewMaxLine];
        
        result.width = commentWidth;
        result.height = ceil(result.height);
    }
    
    return result;
}

- (void)playButtonClicked
{
    [self.player playButtonClicked];
}

- (UIView *)movieView
{
    return self.player.movieView;
}

- (void)didEndDisplaying
{
    [self.player didEndDisplaying];
    if (self.phoneShareView) {
        [self.phoneShareView dismissWithAnimation:YES];
        self.phoneShareView = nil;
    }
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    [self.player cellInListWillDisappear:context];
    if (self.phoneShareView) {
        [self.phoneShareView dismissWithAnimation:YES];
        self.phoneShareView = nil;
    }
    _actionBar.avatarView.hidden = NO;
    _actionBar.avatarView.alpha = 1;
}

#pragma mark -- notification

- (void)subscribeStatusChangedFromVideoDetail:(NSNotification *)notification
{
    NSDictionary *beforeMediaInfo = (NSDictionary *)notification.object;
    if ([beforeMediaInfo isKindOfClass:[NSDictionary class]]) {
        NSString *videoID = [beforeMediaInfo tt_stringValueForKey:@"video_id"];
        if ([videoID isEqualToString:self.orderedData.article.videoID]) {
            BOOL hasSubscribed = [beforeMediaInfo[@"subcribed"] boolValue];
            if (hasSubscribed) {
                [self clearRedPacket];
            }
            [self.orderedData.article setIsSubscribe:@(hasSubscribed)];
        }
    }
}

- (void)subscribeStatusChanged:(NSNotification *)notification
{
    BOOL hasSubscribed = self.orderedData.article.isSubscribe.boolValue;
    if (hasSubscribed) {
        [self clearRedPacket];
    }
    [self.orderedData.article setIsSubscribe:@(!hasSubscribed)];
}

- (void)ttv_refreshViewBeginRefresh:(NSNotification *)notification
{
    if ([[[notification userInfo] valueForKey:@"category_id"] isEqualToString:self.orderedData.categoryID]) {
        [self.player didEndDisplaying];
        self.player.movieView = nil;
    }
}

- (void)followStatusChanged:(NSNotification *)notification {
    
    NSString * userID = notification.userInfo[kRelationActionSuccessNotificationUserIDKey];
    
    if (!isEmptyString(userID) && [userID isEqualToString:self.orderedData.article.userIDForAction]) {
        
        NSInteger actionType = [(NSNumber *)notification.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
        if (actionType == FriendActionTypeFollow) {
            [self clearRedPacket];
            [self.orderedData.article updateFollowed:YES];
            
        }else if (actionType == FriendActionTypeUnfollow) {
            [self.orderedData.article updateFollowed:NO];
        }
        
        [self.actionBar stopFollowButtonIndicatorAnimating];
        
        self.orderedData.showFeedFollowedBtn = YES;
        [self.actionBar refreshWithData:self.orderedData];
    }
}

#pragma mark - 3G下播放优化

- (BOOL)isPlayingMovie
{
    return [self.player isPlaying];
}

- (BOOL)isMovieFullScreen
{
    return [self.player isMovieFullScreen];
}

- (BOOL)hasMovieView {
    return [self.player hasMovieView];
}

- (UIView *)detachMovieView {
    return [self.player detachMovieView];
}

- (void)attachMovieView:(UIView *)movieView {
    [self.player attachMovieView:movieView];
}

- (CGRect)logoViewFrame
{
    return self.logo.frame;
}

- (CGRect)movieViewFrameRect {
    return [self convertRect:self.logo.bounds fromView:self.logo];
}

#pragma mark - kvo

- (void)addKVO
{
    if (self.originalData) {
        [self.KVOController observe:self.originalData keyPaths:@[@"commentCount"] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)removeKVO
{
    if (self.originalData) {
        [self.KVOController unobserveAll];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    Article *article = nil;
    
    if (self.originalData && [self.originalData isKindOfClass:[Article class]]) {
        article = (Article *)(self.originalData);
    }
    
    NSNumber *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    NSNumber *newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (!newValue || [newValue isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    if ([oldValue isKindOfClass:[NSNull class]] || ([oldValue isKindOfClass:[NSNumber class]] && [newValue isKindOfClass:[NSNumber class]] && ![oldValue isEqualToNumber:newValue])) {
        if([keyPath isEqualToString:@"commentCount"]) {
            if ([NSThread isMainThread]) {
                [_actionBar.commentButton setTitle:[TTBusinessManager formatCommentCount:article.commentCount]];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_actionBar.commentButton setTitle:[TTBusinessManager formatCommentCount:article.commentCount]];
                });
            }
            
        }
    }
}

- (void)clearRedPacket
{
    [self.orderedData clearRedpacket];
    self.hasRedPacket = NO;
    [self.actionBar.redPacketFollowButton removeFromSuperview];
    [self.actionBar addSubview:self.actionBar.followButton];
}

- (void)actionButtonClicked:(id)sender
{
    Article *article = nil;
    
    if (self.originalData && [self.originalData isKindOfClass:[Article class]]) {
        article = (Article *)(self.originalData);
    }
    
    if (article.managedObjectContext == nil) {
        return;
    }
    
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    
    if (sender == _actionBar.shareButton) {
        [self shareButtonDidPress];
        self.activityActionManager.clickSource = @"list_share";
        [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton andSectionType:TTActivitySectionTypeListShare];
    }
    if (sender == _actionBar.moreButton) {
        [self moreButtonDidPress];
        _activityActionManager.clickSource = @"list_more";
        [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton andSectionType:TTActivitySectionTypeListMore];
        if (!ttvs_isVideoCellShowShareEnabled()) {
            //            [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton];
        }
    } else if (sender == _actionBar.commentButton) {
        [self commentButtonDidPress];
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:1];
        [extra setValue:article.itemID forKey:@"item_id"];
        [extra setValue:@"video" forKey:@"source"];
        [extra setValue:@"click_list" forKey:@"action"];
        wrapperTrackEventWithCustomKeys(@"enter_comment", [NSString stringWithFormat:@"click_%@", self.orderedData.categoryID], article.groupModel.groupID, nil, extra);
    } else if (sender == _actionBar.adActionButton) {
        if ([self.player isMovieFullScreen]) {
            [self.player exitFullScreen:YES completion:^(BOOL finished) {
                [self actionButtonClicked:sender];
            }];
            return;
        }
        ExploreOrderedData *orderedData = self.orderedData;
        id<TTAdFeedModel> adModel = orderedData.adModel;
        switch (adModel.adType) {
            case ExploreActionTypeApp:
                [[self class] trackRealTime:self.actionBar.adActionButton.actionModel extraData:nil];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"click_start" eventName:@"feed_download_ad" clickTrackUrl:NO];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"click" eventName:@"feed_download_ad" extra:@{@"has_v3":@"1"} duration:0];
                break;
            case ExploreActionTypeAction:
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"click_call" eventName:@"feed_call" clickTrackUrl:NO];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"click" eventName:@"feed_call"];
                [self listenCall:adModel];
                break;
            case ExploreActionTypeWeb:
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"ad_click" eventName:@"embeded_ad" clickTrackUrl:NO];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"click" eventName:@"embeded_ad"];
                break;
            case ExploreActionTypeForm:
                [self showForm:orderedData];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"click" eventName:@"embeded_ad"];
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"click_button" eventName:@"feed_form" clickTrackUrl:NO];
            default:
                break;
        }
        [self.actionBar.adActionButton actionButtonClicked:sender showAlert:NO];
    } else if (sender == _actionBar.followButton || sender == _actionBar.redPacketFollowButton) {
        FriendActionType actionType = ([article isFollowed]) ? FriendActionTypeUnfollow: FriendActionTypeFollow;
        
        NSString *label = ([article isFollowed]) ? @"unsubscribe": @"subscribe";
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:1];
        extra[@"item_id"] = article.itemID;
//        wrapperTrackEventWithCustomKeys(@"list", label, article.mediaUserID, nil, extra);
        
        [self.actionBar startFollowButtonIndicatorAnimating:[article isFollowed]];
        
        BOOL isRedPacketSender = NO;
        TTFollowNewSource source = TTFollowNewSourceVideoFeedFollow;
        if (sender == _actionBar.redPacketFollowButton) {
            source = TTFollowNewSourceVideoFeedFollowRedPacket;
            isRedPacketSender = YES;
        }
        [self followActionLogV3IsRedPacketSender:isRedPacketSender];
        [[TTFollowManager sharedManager] startFollowAction:actionType userID:article.mediaUserID  platform:nil name:nil from:nil reason:nil newReason:nil newSource:@(source) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
            [self.actionBar stopFollowButtonIndicatorAnimating];
            
            if (error) {
                
                NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                if (isEmptyString(hint)) {
                    hint = NSLocalizedString(actionType == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
                }
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                
                [self.actionBar refreshWithData:self.orderedData];
                
            }
//            else if (FriendActionTypeFollow == actionType) {
//
//                if (sender == _actionBar.redPacketFollowButton && ![article isFollowed] && self.hasRedPacket) {
//                    TTRedPacketTrackModel * redPacketTrackModel = [TTRedPacketTrackModel new];
//                    redPacketTrackModel.userId = [[self UserInfo] tt_stringValueForKey:@"user_id"];
//                    redPacketTrackModel.mediaId = [[self MediaInfo] tt_stringValueForKey:@"media_id"];
//                    redPacketTrackModel.categoryName = self.orderedData.categoryID;
//                    redPacketTrackModel.source = @"video";
//                    redPacketTrackModel.position = @"list";
//                    [[TTRedPacketManager sharedManager] presentRedPacketWithRedpacket:self.orderedData.redpacketModel
//                                                                               source:redPacketTrackModel
//                                                                       viewController:[TTUIResponderHelper topmostViewController]];
//                    [self clearRedPacket];
//                }
//                else {
//                    NSString *hint = [NSString stringWithFormat:@"已关注%@", article.userName];
//
//                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
//                }
//            }
        }];
    }
}

+ (void)trackRealTime:(ExploreOrderedData*)orderData extraData:(NSDictionary *)extraData
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:orderData.ad_id forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:orderData.logExtra forKey:@"log_extra"];
    [params setValue:@"1" forKey:@"ext_value"];
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
    [dict setValue:@"feed_call" forKey:@"position"];
    [dict setValue:adModel.dialActionType forKey:@"dailActionType"];
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance call_callAdDict:dict];
}

- (void)showForm:(ExploreOrderedData *)orderdata
{
    id<TTAdFeedModel> adModel = orderdata.adModel;
    
    TTAdAppointAlertModel* model = [[TTAdAppointAlertModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra formUrl:adModel.form_url width:adModel.form_width height:adModel.form_height sizeValid:adModel.use_size_validation];
    
    [TTAdAction handleFormActionModel:model fromSource:TTAdApointFromSourceFeed completeBlock:^(TTAdApointCompleteType type) {
        if (type == TTAdApointCompleteTypeCloseForm) {
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"click_cancel" eventName:@"feed_form"];
        }
        else if (type == TTAdApointCompleteTypeLoadFail){
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"load_fail" eventName:@"feed_form"];
        }
    }];
}

- (void)shareButtonDidPress {
    Article *article = self.orderedData.article;
    
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.miniProgramEnable = [self.orderedData.ad_id longLongValue] == 0;
        self.activityActionManager.delegate = self;
        self.activityActionManager.isVideoSubject = YES;
        self.activityActionManager.authorId = [self.orderedData.article.userInfo ttgc_contentID];
    }
    
    NSNumber *adID = @([self.orderedData.ad_id longLongValue]);
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setArticleCondition:article adID:adID showReport:YES];
    
    [activityItems enumerateObjectsUsingBlock:^(TTActivity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.activityType == TTActivityTypeReport) {
            [activityItems removeObject:obj];
            *stop = YES;
        }
    }];
    
    self.phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;

    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if ([self.player isMovieFullScreen]) {
        [adManagerInstance share_showInAdPage:@"1" groupId:self.orderedData.article.groupModel.groupID];
    }else{
        [adManagerInstance share_showInAdPage:self.orderedData.adModel.ad_id groupId:self.orderedData.article.groupModel.groupID];
    }
    _phoneShareView.activityItems = activityItems;
    [_phoneShareView showOnViewController:[TTUIResponderHelper correctTopViewControllerFor: self] useShareGroupOnly:NO isFullScreen:[self.player isMovieFullScreen]];
    
    if (self.orderedData.article) {
        wrapperTrackEvent(@"list_content", @"share_channel");
    }
}

- (void)moreButtonDidpress_newIfshowDislike:(BOOL)dislike{
    Article *article = self.orderedData.article;
    
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.miniProgramEnable = [self.orderedData.ad_id longLongValue] == 0;
        self.activityActionManager.delegate = self;
        self.activityActionManager.isVideoSubject = YES;
        self.activityActionManager.authorId = [self.orderedData.article.userInfo ttgc_contentID];
    }
    //    _activityActionManager.delegate = self;
    
    NSNumber *adID = @([self.orderedData.ad_id longLongValue]);
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setArticleCondition:article adID:adID showReport:YES];
    
    NSMutableArray *group1 = [NSMutableArray array];
    NSMutableArray *group2 = [NSMutableArray array];
    
    //头条号icon,放最后
    NSString * avatarUrl = nil;
    NSString * name = nil;
    NSString *msgKey = @"关注";
    
    if ([article.mediaInfo isKindOfClass:[NSDictionary class]] ) {
        avatarUrl = article.mediaInfo[@"avatar_url"];
        
        if (article.isSubscribe.boolValue) {
            name = [NSString stringWithFormat:@"取消%@",msgKey];
        }
        else {
            name = msgKey;
        }
    }
    
    BOOL hidePGCActivity = [article hasVideoSubjectID] || !article.mediaInfo || isEmptyString(avatarUrl) || isEmptyString(name);
    hidePGCActivity = YES;// 新样式不显示关注
    if (!hidePGCActivity) {
        TTActivity *pgcActivity = [TTActivity activityOfPGCWithAvatarUrl:avatarUrl showName:name];
        [group2 addObject:pgcActivity];
    }
    
    // 收藏
    TTActivity * favorite = [TTActivity activityOfVideoFavorite];
    favorite.selected = article.userRepined;
    [group2 addObject:favorite];
    
    //不感兴趣
    if (dislike) {
        TTActivity *dislikeActivity = [TTActivity activityOfDislike];
        [group2 addObject:dislikeActivity];
    }
    
    //顶踩
    NSString *diggCount = [NSString stringWithFormat:@"%@",@(article.diggCount)];
    if ([article.banDigg boolValue]) {
        if (article.userDigg) {
            diggCount = @"1";
        }
        else{
            diggCount = @"0";
        }
    }
    TTActivity *digUpActivity = [TTActivity activityOfDigUpWithCount:diggCount];
    digUpActivity.selected = article.userDigg;
    [group2 addObject:digUpActivity];
    
    NSString *buryCount = [NSString stringWithFormat:@"%@",@(article.buryCount)];
    if ([article.banBury boolValue]) {
        if (article.userBury) {
            buryCount = @"1";
        }
        else{
            buryCount = @"0";
        }
    }
    TTActivity *digDownActivity = [TTActivity activityOfDigDownWithCount:buryCount];
    digDownActivity.selected = article.userBury;
    [group2 addObject:digDownActivity];
    
    //当视频是ugc视频时将举报按钮替换成删除按钮
    NSString *uid = [[article userInfo] stringValueForKey:@"user_id" defaultValue:nil];
    NSString *accountUserID = [TTAccountManager userID];
    if (!isEmptyString(uid) && !isEmptyString(accountUserID) && [uid isEqualToString:accountUserID]) { //ugc视频
        [activityItems enumerateObjectsUsingBlock:^(TTActivity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.activityType == TTActivityTypeReport) {
                [activityItems replaceObjectAtIndex:idx withObject:[TTActivity activityOfDelete]];
                *stop = YES;
            }
        }];
    }
    
    //分开放，举报放最后边
    for (TTActivity *activity in activityItems) {
        if (activity.activityType == TTActivityTypeReport || activity.activityType == TTActivityTypeDetele) {
            [group2 addObject:activity];
        }
        else {
            [group1 addObject:activity];
        }
    }
    
    //视频特卖 放第一位置
    if ([self showCommodity]) {
        [group2 insertObject:[TTActivity activityOfVideoCommodity] atIndex:0];
    }

    self.phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;

    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if ([self.player isMovieFullScreen]) {
        [adManagerInstance share_showInAdPage:@"1"  groupId:self.orderedData.article.groupModel.groupID];
    }else{
        [adManagerInstance share_showInAdPage:self.orderedData.adModel.ad_id  groupId:self.orderedData.article.groupModel.groupID];
    }
    [_phoneShareView showActivityItems:@[group1,group2] isFullSCreen:[self.player isMovieFullScreen]];
    
    
    if (self.orderedData.article) {
        wrapperTrackEvent(@"list_content", @"share_channel");
    }
}

- (void)moreButtonDidPress_new {
    [self moreButtonDidpress_newIfshowDislike:YES];
}

- (void)moreButtonDidPressIfShowDisLike:(BOOL) SHowDislike {
    if (ttvs_isVideoCellShowShareEnabled()) {
        [self moreButtonDidpress_newIfshowDislike:SHowDislike];
        return;
    }
    Article *article = self.orderedData.article;
    
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.miniProgramEnable = [self.orderedData.ad_id longLongValue] == 0;
        self.activityActionManager.delegate = self;
        self.activityActionManager.isVideoSubject = YES;
        self.activityActionManager.authorId = [self.orderedData.article.userInfo ttgc_contentID];
    }
    
    NSNumber *adID = @([self.orderedData.ad_id longLongValue]);
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setArticleCondition:article adID:adID showReport:YES];
    
    NSMutableArray *group1 = [NSMutableArray array];
    NSMutableArray *group2 = [NSMutableArray array];
    
    //头条号icon,放最后
    NSString * avatarUrl = nil;
    NSString * name = nil;
    NSString *msgKey = @"关注";
    
    if ([article.mediaInfo isKindOfClass:[NSDictionary class]] ) {
        avatarUrl = article.mediaInfo[@"avatar_url"];
        
        if (article.isSubscribe.boolValue) {
            name = [NSString stringWithFormat:@"取消%@",msgKey];
        }
        else {
            name = msgKey;
        }
    }
    
    BOOL hidePGCActivity = [article hasVideoSubjectID] || !article.mediaInfo || isEmptyString(avatarUrl) || isEmptyString(name);
    hidePGCActivity = YES;// 新样式不显示关注
    if (!hidePGCActivity) {
        TTActivity *pgcActivity = [TTActivity activityOfPGCWithAvatarUrl:avatarUrl showName:name];
        [group2 addObject:pgcActivity];
    }
    
    // 收藏
    TTActivity * favorite = [TTActivity activityOfVideoFavorite];
    favorite.selected = article.userRepined;
    [group2 addObject:favorite];
    
    //不感兴趣
    if (SHowDislike) {
        TTActivity *dislikeActivity = [TTActivity activityOfDislike];
        [group2 addObject:dislikeActivity];
    }
    //顶踩
    NSString *diggCount = [NSString stringWithFormat:@"%@",@(article.diggCount)];
    if ([article.banDigg boolValue]) {
        if (article.userDigg) {
            diggCount = @"1";
        }
        else{
            diggCount = @"0";
        }
    }
    TTActivity *digUpActivity = [TTActivity activityOfDigUpWithCount:diggCount];
    digUpActivity.selected = article.userDigg;
    [group2 addObject:digUpActivity];
    
    NSString *buryCount = [NSString stringWithFormat:@"%@",@(article.buryCount)];
    if ([article.banBury boolValue]) {
        if (article.userBury) {
            buryCount = @"1";
        }
        else{
            buryCount = @"0";
        }
    }
    TTActivity *digDownActivity = [TTActivity activityOfDigDownWithCount:buryCount];
    digDownActivity.selected = article.userBury;
    [group2 addObject:digDownActivity];
    
    //当视频是ugc视频时将举报按钮替换成删除按钮
    NSString *uid = [[article userInfo] stringValueForKey:@"user_id" defaultValue:nil];
    NSString *accountUserID = [TTAccountManager userID];
    if (!isEmptyString(uid) && !isEmptyString(accountUserID) && [uid isEqualToString:accountUserID]) { //ugc视频
        [activityItems enumerateObjectsUsingBlock:^(TTActivity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.activityType == TTActivityTypeReport) {
                [activityItems replaceObjectAtIndex:idx withObject:[TTActivity activityOfDelete]];
                *stop = YES;
            }
        }];
    }
    
    //分开放，举报放最后边
    for (TTActivity *activity in activityItems) {
        if (activity.activityType == TTActivityTypeReport || activity.activityType == TTActivityTypeDetele) {
            [group2 addObject:activity];
        }
        else {
            [group1 addObject:activity];
        }
    }
    
    //视频特卖 放第一位置
    if ([self showCommodity]) {
        [group2 insertObject:[TTActivity activityOfVideoCommodity] atIndex:0];
    }
    
    self.phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if ([self.player isMovieFullScreen]) {
        [adManagerInstance share_showInAdPage:@"1" groupId:self.orderedData.article.groupModel.groupID];
    }else{
        [adManagerInstance share_showInAdPage:self.orderedData.adModel.ad_id groupId:self.orderedData.article.groupModel.groupID];
    }
    [_phoneShareView showActivityItems:@[group1, group2] isFullSCreen:[self.player isMovieFullScreen]];
    
    
    if (self.orderedData.article) {
        wrapperTrackEvent(@"list_content", @"share_channel");
    }
}

- (void)moreButtonDidPress {
    [self moreButtonDidPressIfShowDisLike:YES];
}

- (void)moreButtonOnMovieFinishViewDidPress
{
    Article *article = self.orderedData.article;
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.miniProgramEnable = [self.orderedData.ad_id longLongValue] == 0;
        self.activityActionManager.delegate = self;
        self.activityActionManager.isVideoSubject = YES;
        self.activityActionManager.authorId = [self.orderedData.article.userInfo ttgc_contentID];
    }
    NSNumber *adID = @([self.orderedData.ad_id longLongValue]);
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setArticleCondition:article adID:adID showReport:YES];
    
    _phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    _phoneShareView.activityItems = activityItems;
    
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if ([self.player isMovieFullScreen]) {
        [adManagerInstance share_showInAdPage:@"1" groupId:self.orderedData.article.groupModel.groupID];
    }else{
        [adManagerInstance share_showInAdPage:adID.stringValue groupId:self.orderedData.article.groupModel.groupID];
    }
    [_phoneShareView showOnViewController:[TTUIResponderHelper topViewControllerFor:self] useShareGroupOnly:NO isFullScreen:[self.player isMovieFullScreen]];
    
}

#pragma mark - TTActivityShareManagerDelegate

- (void)activityShareManager:(TTActivityShareManager *)activityShareManager
    completeWithActivityType:(TTActivityType)activityType
                       error:(NSError *)error {
//    if (!error) {
//        [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                                   repostType:TTThreadRepostTypeArticle
//                                                            operationItemType:TTRepostOperationItemTypeArticle
//                                                              operationItemID:self.orderedData.article.itemID
//                                                                originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.orderedData.article]
//                                                                 originThread:nil
//                                                               originShortVideoOriginalData:nil
//                                                            originWendaAnswer:nil
//                                                               repostSegments:nil];
//    }
}

+ (NSString *)labelNameForShareActivityType:(TTActivityType)activityType
{
    return [TTVideoCommon videoListlabelNameForShareActivityType:activityType];
}

- (void)commentButtonDidPress {
    [self showComment:_actionBar.commentButton];
}


#pragma mark -- SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view button:(UIButton *)button didCompleteByItemType:(TTActivityType)itemType{
    if (itemType == TTActivityTypeFavorite) {
        if (!TTNetworkConnected()){
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                     indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
            return;
        }
        button.selected = !button.selected;
        [self toggleFavorite];
    }
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (itemType == TTActivityTypeWeitoutiao || itemType == TTActivityTypeDislike || itemType ==TTActivityTypeReport || itemType == TTActivityTypeEMail || itemType == TTActivityTypeSystem ||itemType == TTActivityTypeMessage) {
        if ([self.player isKindOfClass:[TTVideoTabBaseCellNewPlayControl class] ]) {
            TTVideoTabBaseCellNewPlayControl *newplaycontrol = (TTVideoTabBaseCellNewPlayControl *)self.player;
            if ([newplaycontrol.movieView isKindOfClass:[TTVPlayVideo class]]) {
                TTVPlayVideo *movieView = (TTVPlayVideo *) newplaycontrol.movieView;
                if ([self.player isMovieFullScreen]) {
                    [movieView.player exitFullScreen:YES completion:^(BOOL finished) {
                    }];
                }
            }
        }else{
            if ([ExploreMovieView isFullScreen]) {
                ExploreMovieView *movieView = [ExploreMovieView currentFullScreenMovieView];
                [movieView exitFullScreen:NO completion:^(BOOL finished) {
                    [UIViewController attemptRotationToDeviceOrientation];
                }];
                
            }
        }
    }

    if (view == _phoneShareView) {
//        if (itemType == TTActivityTypeWeitoutiao) {
//            [self sendVideoShareTrackWithItemType:itemType];
//            [self forwardToWeitoutiao];
//            if (ttvs_isShareIndividuatioEnable()){
//                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//            }
//        }
        if (itemType == TTActivityTypePGC) {
            
            Article *article = self.orderedData.article;
            
            //关注通知
            if (![article.mediaInfo isKindOfClass:[NSDictionary class]] ) {
                return;
            }
            
            NSString * mediaId = [NSString stringWithFormat:@"%@",article.mediaInfo[@"media_id"]];
            
            if (article.isSubscribe.boolValue) {
                [self cancelSubscribArticle:mediaId];
                
                wrapperTrackEventWithCustomKeys(@"list_share", @"unconcern",self.orderedData.article.groupModel.groupID, nil, [self extraValueDic]);
            }
            else {
//                if ([TTFirstConcernManager firstTimeGuideEnabled]) {
//                    TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                    [manager showFirstConcernAlertViewWithDismissBlock:nil];
//                }
                [self subscribArticle:mediaId];
                
                wrapperTrackEventWithCustomKeys(@"list_share", @"concern", self.orderedData.article.groupModel.groupID, nil, [self extraValueDic]);
            }
            //统计
            wrapperTrackEvent(@"xiangping", @"video_list_pgc_button");
            
            self.phoneShareView= nil;
        }
        else if (itemType == TTActivityTypeFavorite) {
            [self toggleFavorite];
        }
        else if (itemType == TTActivityTypeDigUp){
            [self digUpActivityClicked];
//            [view dismissWithAnimation:YES];
        }
        else if (itemType == TTActivityTypeDigDown){
            [self digDownActivityClicked];
//            [view dismissWithAnimation:YES];
        }
        else if (itemType == TTActivityTypeDislike) {
            
            [self dislikeActivityClicked];
        }
        else if (itemType == TTActivityTypeReport) {
            self.actionSheetController = [[TTActionSheetController alloc] init];
            
            [self.actionSheetController insertReportArray:[TTReportManager fetchReportVideoOptions]];
            WeakSelf;
            [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
                StrongSelf;
                if (parameters[@"report"]) {
                    TTReportContentModel *model = [[TTReportContentModel alloc] init];
                    model.groupID = self.orderedData.article.groupModel.groupID;
                    model.videoID = self.orderedData.article.videoID;
                    NSString *contentType = kTTReportContentTypePGCVideo;
                    if ([self.orderedData.article isVideoSourceUGCVideo]) {
                        contentType = kTTReportContentTypeUGCVideo;
                    } else if ([self.orderedData.article isVideoSourceHuoShan]) {
                        contentType = kTTReportContentTypeHTSVideo;
                    }
                    
                    [[TTReportManager shareInstance] startReportVideoWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(nil, self.orderedData.categoryID) contentModel:model extraDic:nil animated:YES];
                }
            }];
            
        }
        else if (itemType == TTActivityTypeDetele){
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
            [extraDict setValue:self.orderedData.article.itemID forKey:@"item_id"];
            [extraDict setValue:@"click_video" forKey:@"source"];
            [extraDict setValue:@(1) forKey:@"aggr_type"];
            [extraDict setValue:@(1) forKey:@"type"];
            NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.orderedData.originalData.uniqueID];
            wrapperTrackEventWithCustomKeys(@"list_share", @"delete_ugc", uniqueID, nil, extraDict);
            WeakSelf;
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:[[self.orderedData.article userInfo] stringValueForKey:@"user_id" defaultValue:nil] forKey:@"user_id"];
            [params setValue:self.orderedData.article.itemID forKey:@"item_id"];
            [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting deleteUGCMovieURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
                StrongSelf;
                NSInteger errorCode = 0;
                if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                    errorCode = [(NSDictionary *)jsonObj tt_integerValueForKey:@"error_code"];
                }
                if (error || errorCode != 0) {
                    NSString *tip = NSLocalizedString(@"操作失败", nil);
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                } else {
                    NSString *tip = NSLocalizedString(@"操作成功", nil);
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                    
                    if (self.orderedData.originalData.uniqueID) {
                        //给feed发通知
                        NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.orderedData.originalData.uniqueID];
                        [[NSNotificationCenter defaultCenter] postNotificationName:TTVideoDetailViewControllerDeleteVideoArticle object:nil userInfo:@{@"uniqueID":uniqueID}];
                        //从数据库中删除
                        NSArray *orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID": uniqueID}];
                        [ExploreOrderedData removeEntities:orderedDataArray];
                    }
                }
            }];
        }
        else if(itemType == TTActivityTypeCommodity && [self showCommodity]){
            [self.player addCommodity];
            if(ttvs_isVideoFeedCellHeightAjust() > 1){
                [UIView animateWithDuration:.15
                                 animations:^{
                                     _actionBar.avatarView.alpha = 0;
                                 } completion:^(BOOL finished) {
                                     _actionBar.avatarView.hidden = YES;
                                     _actionBar.avatarView.alpha = 1;
                                 }];
            }
        }
        else {
            NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
            [_activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor: self] sourceObjectType:TTShareSourceObjectTypeVideoList uniqueId:uniqueID adID:nil platform:TTSharePlatformTypeOfMain groupFlags:self.orderedData.article.groupFlags isFullScreenShow:[self.player isMovieFullScreen]];
            [self sendVideoShareTrackWithItemType:itemType];
            self.phoneShareView= nil;
        }
    }
}

//- (void)forwardToWeitoutiao {
//    //实际转发对象为文章，操作对象为文章
//    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                    originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.orderedData.article]
//                                                                     originThread:nil
//                                                                   originShortVideoOriginalData:nil
//                                                                operationItemType:TTRepostOperationItemTypeArticle
//                                                                  operationItemID:self.orderedData.article.itemID
//                                                                   repostSegments:nil];
//}

//订阅
- (void)subscribArticle:(NSString *)entryID
{
    ExploreEntry *entry ;
    NSArray *entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];
    
    if(entries.count > 0)
    {
        entry = entries[0];
    }
    else {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:entryID forKey:@"id"];
        [dic setValue:@1 forKey:@"type"];
        [dic setValue:@0 forKey:@"subscribed"];
        [dic setValue:[NSNumber numberWithInteger:entryID.integerValue] forKey:@"media_id"];
        [dic setValue:entryID forKey:@"entry_id"];
        
        entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
    }
    
    
    [[ExploreEntryManager sharedManager] exploreEntry:entry
                                   changeToSubscribed:YES
                                               notify:YES
                                    notifyFinishBlock:^(ExploreEntry * _Nullable entry, NSError * _Nullable error) {
                                        
                                        //失败提示
                                        if (error) {
                                            NSString *msgFail = [NSString stringWithFormat:@"%@失败",@"关注"];
                                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                      indicatorText:msgFail
                                                                     indicatorImage:nil
                                                                        autoDismiss:YES
                                                                     dismissHandler:nil];
                                            return ;
                                        }
                                        if (!isEmptyString(entryID)) {
                                            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                                                             actionType:TTFollowActionTypeFollow
                                                                                               itemType:TTFollowItemTypeDefault
                                                                                               userInfo:nil];
                                        }
                                        
                                        //订阅成功
                                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"将增加推荐此头条号内容", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                                    }];
    
}

//取消订阅
- (void)cancelSubscribArticle:(NSString *)entryID
{
    
    ExploreEntry *entry ;
    NSArray *entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];
    
    if(entries.count > 0)
    {
        entry = entries[0];
    }
    else {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:entryID forKey:@"id"];
        [dic setValue:@1 forKey:@"type"];
        [dic setValue:@1 forKey:@"subscribed"];
        [dic setValue:[NSNumber numberWithInteger:entryID.integerValue] forKey:@"media_id"];
        [dic setValue:entryID forKey:@"entry_id"];
        
        entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
    }
    
    
    [[ExploreEntryManager sharedManager] exploreEntry:entry
                                   changeToSubscribed:NO
                                               notify:YES
                                    notifyFinishBlock:^(ExploreEntry * _Nullable entry, NSError * _Nullable error) {
                                        
                                        //失败提示
                                        if (error) {
                                            NSString *msgFail = [NSString stringWithFormat:@"取消%@失败",@"关注"];
                                            
                                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                      indicatorText:msgFail
                                                                     indicatorImage:nil
                                                                        autoDismiss:YES
                                                                     dismissHandler:nil];
                                            
                                            return ;
                                        }
                                        
                                        NSString *msgSuccess = [NSString stringWithFormat:@"已取消%@",@"关注"];
                                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                  indicatorText:msgSuccess
                                                                 indicatorImage:nil
                                                                    autoDismiss:YES
                                                                 dismissHandler:nil];
                                        if (!isEmptyString(entryID)) {
                                            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                                                             actionType:TTFollowActionTypeUnfollow
                                                                                               itemType:TTFollowItemTypeDefault
                                                                                               userInfo:nil];
                                        }
                                    }];
}


- (void)dislikeActivityClicked {
    
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = self.orderedData.article.filterWords;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = _actionBar.moreButton.center;
    [dislikeView showAtPoint:point
                    fromView:_actionBar.moreButton
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
    [self trackAdDislikeClick];
}

- (void)trackAdDislikeClick
{
    if (self.orderedData.adIDStr.longLongValue > 0) {
        [self trackWithTag:@"embeded_ad" label:@"dislike" extra:nil];
    }
}

- (void)trackAdDislikeConfirm:(NSArray *)filterWords
{
    if (self.orderedData.adIDStr.longLongValue > 0) {
        NSMutableDictionary *extra = [@{} mutableCopy];
        [extra setValue:filterWords forKey:@"filter_words"];
        [self trackWithTag:@"embeded_ad" label:@"final_dislike" extra:@{@"ad_extra_data": [extra JSONRepresentation]}];
    }
}

- (void)trackWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra {
    NSCParameterAssert(tag != nil);
    NSCParameterAssert(label != nil);
    TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:tag forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:@(nt) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    [events setValue:self.orderedData.ad_id forKey:@"value"];
    [events setValue:self.orderedData.log_extra forKey:@"log_extra"];
    if (extra) {
        [events addEntriesFromDictionary:extra];
    }
    [TTTracker eventData:events];
}

- (void)digUpActivityClicked
{
    Article *article = self.orderedData.article;
    
    if (article.userBury){
        NSString * tipMsg = NSLocalizedString(@"您已经踩过", nil);
        if (!isEmptyString(tipMsg)) {
            [self showIndicatorViewWithTip:tipMsg andImage:nil dismissHandler:nil];
        }
        return;
    }
    
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    if (article.userDigg) {
        article.userDigg = NO;
        article.diggCount = [article.banDigg boolValue]? 0 : MAX(0, article.diggCount - 1);
        [article save];
        [_itemActionManager sendActionForOriginalData:article adID:nil actionType:DetailActionTypeUnDig finishBlock:nil];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
        [dict setValue:self.orderedData.article.groupModel.groupID forKey:@"group_id"];
        [dict setValue:self.orderedData.article.groupModel.itemID forKey:@"item_id"];
        NSString *user_id = [self.orderedData.article.mediaInfo tt_stringValueForKey:@"media_id"]? :[self.orderedData.article.userInfo tt_stringValueForKey:@"user_id"];
        [dict setValue:user_id forKey:@"user_id"];
        [dict setValue:self.orderedData.groupSource forKey:@"group_source"];
        [dict setValue:self.orderedData.logPb forKey:@"log_pb"];
        if (self.orderedData.listLocation != 0) {
            [dict setValue:@"main_tab" forKey:@"list_entrance"];
        }
        [dict setValue:@"list" forKey:@"position"];
        if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
            [dict setValue:@"click_headline" forKey:@"enter_from"];
        }else{
            [dict setValue:@"click_category" forKey:@"enter_from"];
        }
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.orderedData.article.userInfo ttgc_contentID] forKey:@"author_id"];
        [TTTracker eventV3:@"rt_unlike" params:[dict copy]];

    } else {
        article.userDigg = YES;
        article.diggCount = [article.banDigg boolValue]? 1 : article.diggCount + 1;
        [article save];
        
        [_itemActionManager sendActionForOriginalData:article adID:nil actionType:DetailActionTypeDig finishBlock:^(id userInfo, NSError *error) {
            if (!error) {
                if ([userInfo isKindOfClass:[NSDictionary class]]) {
                    int diggCount = [[((NSDictionary *)userInfo) objectForKey:@"digg_count"] intValue];
                    if (diggCount == 1) {
                        article.diggCount = diggCount;
                        [article save];
                    }
                }
            }
        }];
//        wrapperTrackEvent(@"xiangping", @"video_list_digg");
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.orderedData.article.userInfo ttgc_contentID] forKey:@"author_id"];

        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_list_digg",nil,nil,dict);
    }
}

- (void)digDownActivityClicked
{
    Article *article = self.orderedData.article;
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    if (article.userDigg){
        NSString * tipMsg = NSLocalizedString(@"您已经赞过", nil);
        if (!isEmptyString(tipMsg)) {
            [self showIndicatorViewWithTip:tipMsg andImage:nil dismissHandler:nil];
        }
        return;
    }
    if (!article.userBury) {
        article.userBury = YES;
        article.buryCount = [article.banBury boolValue]? 1 : article.buryCount + 1;
        [article save];
        
        [_itemActionManager sendActionForOriginalData:article adID:nil actionType:DetailActionTypeBury finishBlock:^(id userInfo, NSError *error) {
            if (!error) {
                if ([userInfo isKindOfClass:[NSDictionary class]]) {
                    int buryCount = [[((NSDictionary *)userInfo) objectForKey:@"bury_count"] intValue];
                    if (buryCount == 1) {
                        article.buryCount = buryCount;
                        [article save];
                    }
                }
            }
        }];
//        wrapperTrackEvent(@"xiangping", @"video_list_bury");
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.orderedData.article.userInfo ttgc_contentID] forKey:@"author_id"];
        
        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_list_bury",nil,nil,dict);

    } else {
        article.userBury = NO;
        article.buryCount = [article.banBury boolValue]? 1 : MAX(0, article.buryCount - 1);
        [article save];
        
        [_itemActionManager sendActionForOriginalData:article adID:nil actionType:DetailActionTypeUnBury finishBlock:nil];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
        [dict setValue:self.orderedData.article.groupModel.groupID forKey:@"group_id"];
        [dict setValue:self.orderedData.article.groupModel.itemID forKey:@"item_id"];
        [dict setValue:[self.orderedData.article.mediaInfo tt_stringValueForKey:@"media_id"] forKey:@"user_id"];
        [dict setValue:self.orderedData.groupSource forKey:@"group_source"];
        [dict setValue:self.orderedData.logPb forKey:@"log_pb"];
        [dict setValue:@"list" forKey:@"position"];
        if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
            [dict setValue:@"click_headline" forKey:@"enter_from"];
        }else{
            [dict setValue:@"click_category" forKey:@"enter_from"];
        }
        if (self.orderedData.listLocation != 0) {
            [dict setValue:@"main_tab" forKey:@"list_entrance"];
        }
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.orderedData.article.userInfo ttgc_contentID] forKey:@"author_id"];
        [TTTracker eventV3:@"rt_unbury" params:[dict copy]];
    }
}

- (void)toggleFavorite
{
    Article *article = self.orderedData.article;
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    
    if (article.userRepined == YES) {
        __weak __typeof__(self) wself = self;
        [self.itemActionManager unfavoriteForOriginalData:article adID:nil finishBlock:^(id userInfo, NSError *error) {
            if (!error) {
                if (wself.orderedData.article.uniqueID == article.uniqueID) {
                    //[wself updateActionButtons:essayData];
                }
            }
        }];
        
        NSString * tipMsg = NSLocalizedString(@"取消收藏", nil);
        UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
        if (!isEmptyString(tipMsg)) {
            [self showIndicatorViewWithTip:tipMsg andImage:nil dismissHandler:nil];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.orderedData.article.userInfo ttgc_contentID] forKey:@"author_id"];
        
        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_list_unfavorite",nil,nil,dict);
    }
    else {
        __weak __typeof__(self) wself = self;
        [self.itemActionManager favoriteForOriginalData:article adID:nil finishBlock:^(id userInfo, NSError *error) {
            if (!error) {
                if (wself.orderedData.article.uniqueID == article.uniqueID) {
                    //[wself updateActionButtons:essayData];
                }
            }
        }];
        
        NSString * tipMsg = NSLocalizedString(@"收藏成功", nil);
        UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
        if (!isEmptyString(tipMsg)) {
            [self showIndicatorViewWithTip:tipMsg andImage:nil dismissHandler:nil];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"video" forKey:@"article_type"];
        [dict setValue:[self.orderedData.article.userInfo ttgc_contentID] forKey:@"author_id"];
        
        wrapperTrackEventWithCustomKeys(@"xiangping", @"video_list_favorite",nil,nil,dict);

    }
}

#pragma mark TTFeedDislikeView

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView {
    if (!self.orderedData) {
        return;
    }
    NSArray *filterWords = [dislikeView selectedWords];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
    }
    [self trackAdDislikeConfirm:filterWords];
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

#pragma mark -- Track
- (NSDictionary *)extraValueDic {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (self.orderedData.article.uniqueID > 0) {
        [dic setObject:@(self.orderedData.article.uniqueID) forKey:@"item_id"];
    }
    if (self.orderedData.categoryID) {
        [dic setObject:self.orderedData.categoryID forKey:@"category_id"];
    }
    if ([self getRefer]) {
        [dic setObject:[NSNumber numberWithUnsignedInteger:[self getRefer]] forKey:@"location"];
    }
    [dic setObject:@1 forKey:@"gtype"];
    return dic;
}


- (void)sendVideoShareTrackWithItemType:(TTActivityType)itemType
{
    TTActivitySectionType sectionType = 100; //100返回空
    NSString *iconSeat;
    if (_activityActionManager.clickSource) {
        if ([_activityActionManager.clickSource isEqualToString:@"list_more"]) {
            sectionType = TTActivitySectionTypeListMore;
            iconSeat = nil;
        }else if ([_activityActionManager.clickSource isEqualToString:@"player_more"]){
            sectionType = TTActivitySectionTypePlayerMore;
            iconSeat = nil;
        }else if ([_activityActionManager.clickSource isEqualToString:@"player_share"]){
            sectionType = TTActivitySectionTypePlayerShare;
            iconSeat = nil;
        }else if ([_activityActionManager.clickSource isEqualToString:@"list_video_over"]){
            sectionType = TTActivitySectionTypeListVideoOver;
            iconSeat = @"inside";
        }else if ([_activityActionManager.clickSource isEqualToString:@"list_video_over_direct"]){
            sectionType = TTActivitySectionTypeListVideoOver;
            iconSeat = @"exposed";
        }else if ([_activityActionManager.clickSource isEqualToString:@"list_share"]){
            sectionType = TTActivitySectionTypeListShare;
            iconSeat = nil;
        }
    }
    [self sendVideoShareTrackWithItemType:itemType andSectionType:sectionType withIconSeat:iconSeat];
}

- (void)sendVideoShareTrackWithItemType:(TTActivityType)itemType andSectionType:(TTActivitySectionType)sectionType withIconSeat:(NSString *)iconSeat
{
    NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeVideoList];
    NSString *label = [[self class] labelNameForShareActivityType:itemType];
    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionary];
    if ([self.orderedData.ad_id longLongValue] > 0) {
        NSString *adId = self.orderedData.ad_id;
        extValueDic[@"ext_value"] = adId;
    }
    NSString *sectionName = [TTVideoCommon videoSectionNameForShareActivityType:sectionType];
    if (sectionName) {
        [extValueDic setValue:sectionName forKey:@"section"];
        if (sectionType == TTActivitySectionTypePlayerShare || sectionType == TTActivitySectionTypePlayerMore){
            [extValueDic setValue:@"fullScreen" forKey:@"fullScreen"];
            [extValueDic setValue:@"video" forKey:@"source"];
        }
    }
    if ([self.orderedData.article hasVideoSubjectID]) {
        extValueDic[@"video_subject_id"] = self.orderedData.article.videoSubjectID;
    }
//    if (ttvs_isVideoCellShowShareEnabled()) {
//        extValueDic[@"bar"] = @" button_seat";
//    }
    if (iconSeat) {
        [extValueDic setValue:iconSeat forKey:@"icon_seat"];
    }
    wrapperTrackEventWithCustomKeys(tag, label, uniqueID, @"video", extValueDic);
    
}

- (void)sendVideoShareTrackWithItemType:(TTActivityType)itemType andSectionType:(TTActivitySectionType)sectionType
{
    [self sendVideoShareTrackWithItemType:itemType andSectionType:sectionType withIconSeat:nil];
}

- (ExploreCellStyle)cellStyle {
    return ExploreCellStyleVideo;
}

- (ExploreCellSubStyle)cellSubStyle {
    return ExploreCellSubStyleVideoPlayableInList;
}

static CGFloat sActionBarHeight = 0;
+ (CGFloat)actionBarHeigth {
    if(ttvs_isVideoFeedCellHeightAjust() >= 1){
        sActionBarHeight = [TTDeviceUIUtils tt_newPadding:48];
    }
    else{
        sActionBarHeight = [TTDeviceUIUtils tt_newPadding:52];
    }
    return sActionBarHeight;
}

#pragma mark TTVideoTabBaseCellPlayControlDelegate
- (void)ttv_shareButtonOnMovieTopViewDidPress
{
    [self shareButtonDidPress];
    self.activityActionManager.clickSource = @"player_share";
    [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton andSectionType:TTActivitySectionTypePlayerShare];
}

- (void)ttv_moreButtonOnMovieTopViewDidPress
{
    [self moreButtonDidPressIfShowDisLike:NO];
    self.activityActionManager.clickSource = @"player_more";
    [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton andSectionType:TTActivitySectionTypePlayerMore];
}

- (void)ttv_shareButtonOnMovieFinishViewDidPress
{
    [self shareButtonDidPress];
    self.activityActionManager.clickSource = @"list_video_over";
    [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton andSectionType:TTActivitySectionTypeListVideoOver];
}

- (void)ttv_movieViewReplayButtonDidPress{
}

- (void)ttv_shareActionClickedWithActivityType:(NSString *)activityType
{
    TTActivityType itemType = [TTActivityShareSequenceManager activityTypeFromStringActivityType:activityType];
    NSString *adId = self.orderedData.ad_id;
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.miniProgramEnable = [adId longLongValue] == 0;
        self.activityActionManager.delegate = self;
        self.activityActionManager.isVideoSubject = YES;
        self.activityActionManager.authorId = [self.orderedData.article.userInfo ttgc_contentID];
    }
    self.activityActionManager.clickSource = @"list_video_over_direct";
    NSString *groupId = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
//    if (itemType == TTActivityTypeWeitoutiao){
//        [self sendVideoShareTrackWithItemType:itemType];
//        [self forwardToWeitoutiao];
//        if (ttvs_isShareIndividuatioEnable()){
//            [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//        }
//    }else{
        Article *article = self.orderedData.article;
        NSNumber *adID = @([adId longLongValue]);
        [ArticleShareManager shareActivityManager:_activityActionManager setArticleCondition:article adID:adID showReport:YES];
        [self.activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor: self]  sourceObjectType:TTShareSourceObjectTypeVideoList uniqueId:groupId adID:adId platform:TTSharePlatformTypeOfMain groupFlags:self.orderedData.article.groupFlags isFullScreenShow:[self.player isMovieFullScreen]];
        [self sendVideoShareTrackWithItemType:itemType];
//    }
}

- (void)hiddenAvartViewAnimated
{
    if(ttvs_isVideoFeedCellHeightAjust() > 1){
        [UIView animateWithDuration:.15
                         animations:^{
                             _actionBar.avatarView.alpha = 0;
                         } completion:^(BOOL finished) {
                             if (self.player.movieView.superview == self.logo) {
                                 _actionBar.avatarView.hidden = YES;
                             }
                             _actionBar.avatarView.alpha = 1;
                         }];
    }
}

- (void)ttv_movieViewWillAppear:(UIView *)newView{
    if(ttvs_isVideoFeedCellHeightAjust() > 1){
        if (!newView) {
            if (self.player.movieView.superview == self.logo) {
                _actionBar.avatarView.hidden = NO;
            }else{
                _actionBar.avatarView.hidden = YES;
            }
        }else {
            if (newView != self.logo){
                _actionBar.avatarView.hidden = YES;
            } else{
                [self hiddenAvartViewAnimated];
            }
        }
    }
}

- (BOOL)showCommodity
{
    return NO;
    if (self.player) {
        return [self.player isKindOfClass:[TTVideoTabBaseCellNewPlayControl class]] && self.orderedData.article.commoditys.count > 0;
    }else{
        return self.orderedData.article.commoditys.count > 0;
    }
    return NO;
}

- (void)ttv_commodityViewClosed
{
    if (self.player.movieView.superview != self.logo) {
        self.actionBar.avatarView.hidden = NO;
    }
}

- (void)ttv_invalideMovieView
{
    
}

- (void)ttv_movieViewDidExitFullScreen
{
    
}

- (id)ttv_playerController
{
    return self.player;
}

- (BOOL)ttv_canUseNewPlayer
{
    if ([self.orderedData article]) {
        return ![self.player.movieView isKindOfClass:[ExploreMovieView class]] && [self.orderedData.ad_id longLongValue] <= 0;
    }
    return NO;
}

- (UIView *)ttv_playerSuperView
{
    return self.logo;
}

#pragma mark - toast: 顶／踩/收藏 适配全屏
//默认Image类类型
- (void)showIndicatorViewWithTip:(NSString *)tipMsg andImage:(UIImage *)indicatorImage dismissHandler:(DismissHandler)handler{
    TTIndicatorView *indicateView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:indicatorImage dismissHandler:handler];
//    [indicateView addTransFormIsFullScreen:[self.player isMovieFullScreen]];
    indicateView.autoDismiss = YES;
    [indicateView showFromParentView:self.phoneShareView.panelController.backWindow.rootViewController.view];
//    [indicateView changeFrameIsFullScreen:[self.player isMovieFullScreen]];
}

#pragma mark - 关注互动埋点 (3.0)
- (void)followActionLogV3IsRedPacketSender:(BOOL) isRedPacketSender
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [self followActionLogV3CommonParams:params];
    if (isRedPacketSender){
        [params setValue:@"1" forKey: @"is_redpacket"];
        [params setValue:@(TTFollowNewSourceVideoFeedFollowRedPacket) forKey:@"server_source"];
    }else{
        [params setValue:@"0" forKey: @"is_redpacket"];
    }
    [params setValue:@"video" forKey:@"article_type"];
    [params setValue:[self.orderedData.article.userInfo ttgc_contentID] forKey:@"author_id"];
    if ([self.orderedData.article isFollowed]){
        [TTTrackerWrapper eventV3:@"rt_unfollow" params:params];
    }else{

        [TTTrackerWrapper eventV3:@"rt_follow" params:params];
    }
    
}

- (void)followActionLogV3CommonParams:(NSMutableDictionary *)params
{
    NSString *categoryName = self.orderedData.categoryID;
    NSString *userId = [[self UserInfo] tt_stringValueForKey:@"user_id"];
    NSString *mediaId = [[self MediaInfo] tt_stringValueForKey:@"media_id"];

    [params setValue:@(TTFollowNewSourceVideoFeedFollow) forKey:@"server_source"];
    [params setValue:self.orderedData.article.itemID forKey:@"item_id"];
    [params setValue:[self.orderedData uniqueID] forKey:@"group_id"];
    [params setValue:@"click_category" forKey: @"enter_from"];
    [params setValue:self.orderedData.logPb forKey:@"log_pb"];
    [params setValue:@"0" forKey: @"not_default_follow_num"];
    [params setValue:categoryName forKey: @"category_name"];
    [params setValue:@"from_group" forKey: @"follow_type"];
    [params setValue:userId forKey: @"to_user_id"];
    [params setValue:mediaId forKey: @"media_id"];
    [params setValue:@"video" forKey: @"source"];
    [params setValue:@"list" forKey:@"position"];
    [params setValue:@"1" forKey: @"follow_num"];
    
}

#pragma mark - 红包关注样式埋点 (3.0)

- (void)logShowRedPacketIfNeed{
    BOOL isFollowed = [self.orderedData.article isFollowed];
    if (!isFollowed && self.hasRedPacket){
        NSString *categoryName = self.orderedData.categoryID;
        NSString *groupId = [self.orderedData uniqueID];
        NSString *actionType = @"show";
        NSString *position = @"list";
        NSString *userId = [[self UserInfo] tt_stringValueForKey:@"user_id"];
        NSString *mediaId = [[self MediaInfo] tt_stringValueForKey:@"media_id"];
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:userId forKey:@"user_id"];
        [param setValue:mediaId forKey:@"media_id"];
        [param setValue:groupId forKey:@"group_id"];
        [param setValue:actionType forKey:@"action_type"];
        [param setValue:position forKey:@"position"];
        [param setValue:@"video" forKey:@"source"];
        [param setValue:categoryName forKey:@"category_name"];
        [TTTrackerWrapper eventV3:@"red_button" params:param];
    }
}

- (NSDictionary *)UserInfo
{
    if ([self.orderedData.article hasVideoSubjectID]) {
        return self.orderedData.article.detailUserInfo;
    } else {
        return self.orderedData.article.userInfo;
    }
}

- (NSDictionary *)MediaInfo
{
    if ([self.orderedData.article hasVideoSubjectID]) {
        return self.orderedData.article.detailMediaInfo;
    } else {
        return self.orderedData.article.mediaInfo;
    }
}
@end

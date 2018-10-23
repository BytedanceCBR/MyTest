//
//  TTLayOutLargePicCell.m
//  Article
//
//  Created by 王双华 on 16/10/12.
//
//

#import "TTLayOutNewLargePicCell.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "TTDeviceHelper.h"
#import "ExploreCellHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreArticleCellView.h"
#import "TTLayOutPlainLargePicCellModel.h"
#import "TTLayOutUnifyADLargePicCellModel.h"
#import "TTLayOutUFLargePicCellModel.h"
#import "TTVPlayVideo.h"
#import "TTVPlayerUrlTracker.h"
#import "TTVPlayerAudioController.h"
#import "TTVideoAutoPlayManager.h"
#import "TTVAutoPlayManager.h"
#import "TTVPlayerTipAdOldCreator.h"
#import "TTVPlayerTipAdOldFinish.h"
#import "TTVPlayerTipShareCreater.h"
#import "TTVPlayerTipRelatedCreator.h"
#import "TTVPlayerCacheProgressController.h"
#import "TTVDemanderTrackerManager.h"

#import <TTShareActivity.h>
#import <TTShareManager.h>
#import "TTPanelActivity.h"
#import "TTShareMethodUtil.h"
#import "TTActivityShareSequenceManager.h"

#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTADVideoMZTracker.h"
#import "KVOController.h"
#import "TTSettingsManager.h"
#import "TTASettingConfiguration.h"

#import "TTVVideoPlayerModel.h"
#import "TTVPasterPlayer.h"

#import "SSCommonLogic.h"


extern BOOL ttvs_isVideoFeedURLEnabled(void);
extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern BOOL ttvs_isPlayerShowRelated(void);
extern NSInteger ttvs_isVideoShowDirectShare(void);
extern NSInteger ttvs_isShareTimelineOptimize(void);

extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;
extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;


@interface TTLayOutNewLargePicCell()
@property (nonatomic, strong) TTLayOutNewLargePicCellView *largePicCellView;

@end
@implementation TTLayOutNewLargePicCell

+ (Class)cellViewClass
{
    return [TTLayOutNewLargePicCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    if (!_largePicCellView) {
        self.largePicCellView = [[TTLayOutNewLargePicCellView alloc] initWithFrame:self.bounds];
        self.largePicCellView.cell = self;
    }
    return _largePicCellView;
}

- (void)willDisplay {
    [_largePicCellView willDisplay];
}

- (void)didEndDisplaying
{
    [_largePicCellView didEndDisplaying];
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    [_largePicCellView cellInListWillDisappear:context];
}

#pragma mark TTVAutoPlayingCell

- (TTVAutoPlayModel *)ttv_autoPlayModel
{
    //为了避免类型warning强转了一下。。。
    TTVAutoPlayModel *model = [TTVAutoPlayModel modelWithArticle:(id <TTVArticleProtocol>)_largePicCellView.orderedData.article category:_largePicCellView.orderedData.categoryID];
    return model;
}

- (BOOL)ttv_cellCouldAutoPlaying
{
    return [_largePicCellView.orderedData couldAutoPlay];
}

- (void)ttv_autoPlayVideo
{
    [_largePicCellView ttv_autoPlayVideo];
}

- (CGRect)ttv_logoViewFrame
{
    return [_largePicCellView ttv_logoViewFrame];
}

- (TTVPlayVideo *)ttv_movieView
{
    return [_largePicCellView ttv_movieView];
}

- (TTVPlayVideo *)movieView
{
    return [_largePicCellView ttv_movieView];
}

- (void)ttv_autoPlayingAttachMovieView:(UIView *)movieView {
    [_largePicCellView ttv_autoPlayingAttachMovieView:movieView];
}

@end

@interface TTLayOutNewLargePicCellView () <TTVDemandPlayerDelegate, TTShareManagerDelegate>

@property (nonatomic, strong) TTVPlayVideo          *movieView;         //列表页播放的视频
@property (nonatomic, strong) SSThemedButton        *playButton;        //播放按钮
@property (nonatomic, strong) id<TTActivityProtocol> directShareActivity;
@property (nonatomic, strong) NSMutableDictionary   *shareLogDic;
@property (nonatomic, assign) CGFloat                prevOffset;
@property (nonatomic, strong) TTShareManager * shareManager;

@end

@implementation TTLayOutNewLargePicCellView
       
- (void)dealloc
{
    [self invalideMovieView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /** 图片上的播放按钮 */
        SSThemedButton *playButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.picView addSubview:playButton];
        self.playButton = playButton;
        self.picView.playButton = playButton;
    }
    return self;
}

- (void)registerMovieViewNotification
{
    if (self.movieView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
    }
}

- (void)removeMovieViewNotification
{
    if (self.movieView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
    }
}

- (void)invalideMovieView
{
    if (self.movieView) {
        [self.movieView exitFullScreen:NO completion:nil];
        if (self.movieView.playerModel.isAutoPlaying) {
            [[TTVAutoPlayManager sharedManager] resetForce];
        }
        _movieView.player.delegate = nil;
        [self.movieView.player releaseAysnc];
        [self.movieView removeFromSuperview];
        self.movieView = nil;
        [self bringAdButtonBackToCell];
    }
}

- (void)willDisplay {
    [super willAppear];
    if (!self.tableView || ![self.tableView isKindOfClass:[UITableView class]]) {
        return;
    }
    WeakSelf;
    [self.KVOController observe:self.tableView keyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self tableviewScroll:self.tableView];
    }];
}



- (void)tableviewScroll:(UIScrollView *)scrollView
{
    if (!ttas_isVideoScrollPlayEnable()) {
        return;
    }
    if (![scrollView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    CGRect videoRect = [self convertRect:[self ttv_logoViewFrame] toView:scrollView];
    CGFloat offset = scrollView.contentOffset.y;
    
    BOOL halfAutoPlay = [TTDeviceHelper isPadDevice] ? NO : [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_autoplayad_halfshow" defaultValue:@NO freeze:NO] boolValue];
    CGFloat visibleHeight = videoRect.size.height;
    if (halfAutoPlay == YES) {
        visibleHeight = videoRect.size.height/2;
    }
    if (offset > self.prevOffset) { //向上滑动
        if (scrollView.bottom - (CGRectGetMinY(videoRect) - offset)> visibleHeight) {
            [self autoPlayMovie];
        }
    }
    else if (offset < self.prevOffset){//向下滑动
        if (CGRectGetMaxY(videoRect) - offset - scrollView.top > visibleHeight) {
            [self autoPlayMovie];
        }
    }
    self.prevOffset = scrollView.contentOffset.y;
}

- (void)autoPlayMovie
{
    TTVPlayVideo *movieView = [self ttv_movieView];
    TTVPlayVideo *currentPlayVideo = [TTVPlayVideo currentPlayingPlayVideo];
    BOOL canAutoPlay = [self ttv_cellCouldAutoPlaying] && (self.orderedData.adID.longLongValue>0);
    BOOL properStatus = YES;
    BOOL hasVideoPlaying = NO;
    if (movieView.player.context.playbackState == TTVVideoPlaybackStatePlaying ||
        movieView.player.context.playbackState == TTVVideoPlaybackStateFinished) {
        properStatus = NO;
    }
    if (currentPlayVideo && currentPlayVideo.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
        hasVideoPlaying = YES;
    }
    if (canAutoPlay && properStatus && !hasVideoPlaying) {
        [[TTVAutoPlayManager sharedManager] ttv_cellTriggerPlayVideoIfCould:self.cell];
    }
}


- (void)didEndDisplaying
{
    [super didDisappear];
    if (self.movieView && self.movieView.superview) {
        if (!self.movieView.player.context.isFullScreen && !self.movieView.player.context.isRotating) {
            [self invalideMovieView];
        }
    } else if(([[TTVAutoPlayManager sharedManager].model.uniqueID isEqualToString: self.orderedData.uniqueID])) {
        [[TTVAutoPlayManager sharedManager] resetForce];
    }
    [self.KVOController unobserveAll];
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    if (self.movieView && self.movieView.superview && ![self.movieView isAdMovie]) {
        if (!self.movieView.player.context.isFullScreen && !self.movieView.player.context.isRotating) {
            [self.movieView stop];
            self.movieView.hidden = YES;
        }
    }
}

#pragma mark -- notification

- (void)movieViewPlayFinished
{
    if (![self.movieView isAdMovie]) {
        if (!self.movieView.player.pasterPlayer.hasPasterAd) {
            // 没有后贴片直接将播放器移除和之前逻辑保持一致
            [self invalideMovieView];
        }
    } else
    {
        if ([self.orderedData.raw_ad_data tta_boolForKey:@"auto_replay"]) {
            //广告视频自动播放
            [self.movieView.player setLogoImageViewHidden:YES];
            [self.movieView.player play];
            //针对循环播放将这个状态置回
            self.movieView.player.playerStateStore.state.hasEnterDetail = NO;
        }else{
            self.picView.userInteractionEnabled = YES;
        }
    }
    
}

- (void)stopMovieViewPlay:(NSNotification *)notification
{
    [self invalideMovieView];
    [[TTVAutoPlayManager sharedManager] resetForce];
}

- (void)layoutPlayButton
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.playButton.hidden = cellLayOut.playButtonHidden;
    if (!self.playButton.hidden) {
        self.playButton.frame = cellLayOut.playButtonFrame;
        self.playButton.userInteractionEnabled = cellLayOut.playButtonUserInteractionEnable;
        self.playButton.imageName = cellLayOut.playButtonImageName;
    }
    if ([self ttv_cellCouldAutoPlaying] && self.orderedData.adID.longLongValue>0) {
        self.picView.userInteractionEnabled = NO;
    }
}

- (void)playButtonClicked:(id)sender
{
    Article *article = self.orderedData.article;
    
    [ExploreMovieView removeAllExploreMovieView];

    NSString *adID = article.adIDStr;
    NSString *logExtra = article.logExtra;
    NSString *videoID = article.videoID;
    if (isEmptyString(videoID)) {
        videoID = [article.videoPlayInfo objectForKey:VideoInfoIDKey];
    }
    
    TTVPlayerSP sp = ([self.orderedData.article.groupFlags longLongValue] & ArticleGroupFlagsDetailSP) > 0 ? TTVPlayerSPLeTV : TTVPlayerSPToutiao;
    
    TTVVideoPlayerModel *model = [[TTVVideoPlayerModel alloc] init];
    model.categoryID = self.orderedData.categoryID;
    model.groupID = [NSString stringWithFormat:@"%lld",article.uniqueID];
    model.itemID = article.itemID;
    model.aggrType = [article.aggrType integerValue];
    model.enterFrom = [self enterFrom];
    model.categoryName = self.orderedData.categoryID;
    model.adID = adID;

    if (!isEmptyString(article.videoLocalURL)) {
        if ([article.videoLocalURL rangeOfString:@"file://"].location != NSNotFound) {
            model.localURL = article.videoLocalURL;
        }
        else{
            model.localURL = [NSString stringWithFormat:@"file://%@%@", NSHomeDirectory(), article.videoLocalURL];
        }
    }

    model.enableResolution = YES;
    model.logExtra = logExtra;
    model.videoID = videoID;
    model.sp = sp;
    model.authorId = [article.userInfo tt_stringValueForKey:@"user_id"];
    //model.trackLabel = self.detailStateStore.state.entity.clickLabel;
    
    // 非点击的情况 自动播放
    if (!sender) {
        model.isAutoPlaying = YES;
        model.showMutedView = YES;
        model.mutedWhenStart = YES;
        self.picView.userInteractionEnabled = NO;

        //广告自动播放时每次从头播放
        [[TTVPlayerCacheProgressController sharedInstance] removeCacheForVideoID:videoID];
    } else {
        model.isAutoPlaying = NO;
    }
    if (article.isVideoSourceUGCVideo) {
        model.defaultResolutionType = TTVPlayerResolutionTypeHD;
    }
    if ([article hasVideoSubjectID]) {
        model.videoSubjectID = [article.videoDetailInfo valueForKey:kArticleInfoRelatedVideoSubjectIDKey];
    }
    BOOL isVideoFeedURLEnabled = ttvs_isVideoFeedURLEnabled();
    if (isVideoFeedURLEnabled && [article hasVideoPlayInfoUrl] && [article isVideoUrlValid]) {
        model.videoPlayInfo = article.videoPlayInfo;
    }
    
    NSInteger isVideoShowOptimizeShare = ttvs_isVideoShowOptimizeShare();
    if (isVideoShowOptimizeShare > 0){
        if (isEmptyString(model.adID)){
            model.playerShowShareMore = isVideoShowOptimizeShare;
        }
    }
    //只有admodel才行,号外广告显示正常视频UI
    if ([article isAd]) {//广告
        //视频广告自动播放
        if ([self.orderedData.raw_ad_data tta_boolForKey:@"auto_replay"]) {
            model.isLoopPlay = YES;
            model.disableFinishUIShow = YES;
        }
        model.enablePasterAd = NO;
        model.isAdBusiness = YES;
    }else{//非广告使用贴片功能
        model.enablePasterAd = YES;
        model.pasterAdFrom = @"textlink";
    }

    TTVPlayVideo *movie = [[TTVPlayVideo alloc] initWithFrame:self.picView.bounds playerModel:model];
    self.movieView = movie;
    //只有admodel才行,号外广告显示正常视频UI
    if ([article.adModel isCreativeAd]) {//广告
        self.movieView.player.tipCreator = [[TTVPlayerTipAdOldCreator alloc] init];
    }else{
        self.movieView.player.enableRotate = YES;
        if (ttvs_isPlayerShowRelated()) {
            self.movieView.player.tipCreator = [[TTVPlayerTipRelatedCreator alloc] init];
        }else{
            NSInteger isVideoShowDirectShare = ttvs_isVideoShowDirectShare();
            if ((isVideoShowDirectShare == 1 || isVideoShowDirectShare == 3)){
                self.movieView.player.tipCreator = [[TTVPlayerTipShareCreater alloc] init];
            }
        }
    }

    [self.movieView.player setVideoTitle:self.titleLabel.text];
    [self.movieView setVideoLargeImageDict:article.largeImageDict];
    self.movieView.player.showTitleInNonFullscreen = NO;
    [self.picView addSubview:_movieView];
    
    if (self.movieView) {
        [self.movieView.player readyToPlay];
        // 这个方法要在readyToPlay之后，不然playerStateStore没有初始化
        [self addUrlTracker];
        //预加载禁loadingView，要在ready之后，play之前。
        self.movieView.player.banLoading = YES;
        [self.movieView.player play];
        self.movieView.player.muted = [self.orderedData couldAutoPlay];
        self.movieView.player.delegate = self;
    }
    [self ttv_configADFinishedView:(TTVPlayerTipAdFinished *)self.movieView.player.tipCreator.tipFinishedView];

    [self bringAdButtonBackToCell];
}

- (void)ttv_configADFinishedView:(TTVPlayerTipAdFinished *)finishedView
{
    if ([finishedView isKindOfClass:[TTVPlayerTipAdOldFinish class]]){
        [finishedView setData:self.orderedData];
    }
}

- (void)addUrlTracker
{
    TTVPlayerUrlTracker *urlTracker = [self.orderedData videoPlayTracker];
    urlTracker.videoThirdMonitorUrl = self.orderedData.article.videoThirdMonitorUrl;
    [self.movieView.commonTracker registerTracker:urlTracker];
}

- (void)setMovieView:(TTVPlayVideo *)movieView
{
    if (_movieView != movieView) {
        [self removeMovieViewNotification];
        _movieView = movieView;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            //静音会卡住界面
//              _movieView.player.muted = [self.orderedData couldAutoPlay];
//        });
        [self registerMovieViewNotification];
        [_movieView.player setIsInDetail:NO];
        [_movieView.player setBannerHeight:0];
    }
}

- (TTVAutoPlayModel *)ttv_autoPlayModel
{
    TTVAutoPlayModel *model = [TTVAutoPlayModel modelWithArticle:(id <TTVArticleProtocol>)self.orderedData.article category:self.orderedData.categoryID];
    return model;
}

- (BOOL)ttv_cellCouldAutoPlaying
{
    return [self.orderedData couldAutoPlay];
}

- (void)ttv_autoPlayVideo
{
    [self playButtonClicked:nil];
}

- (TTVPlayVideo *)ttv_movieView
{
    return self.movieView;
}

- (CGRect)ttv_logoViewFrame
{
    return [self cell_logoViewFrame];
}

- (void)ttv_autoPlayingAttachMovieView:(UIView *)movieView {
    if ([movieView isKindOfClass:[TTVPlayVideo class]]) {
        TTVPlayVideo *_movieView = (TTVPlayVideo *)movieView;
        [self attachMovieView:_movieView];
    }
}

#pragma mark - TTVDemandPlayerDelegate

- (void)playerPlaybackState:(TTVVideoPlaybackState)state {
    
    switch (state) {
        case TTVVideoPlaybackStateFinished:
        {
            if ([self.movieView isAdMovie] && self.orderedData.trackSDK == 1) {
                [[TTADVideoMZTracker sharedManager] mzStopTrack];
            }
            [self movieViewPlayFinished];
        }
            break;
        case TTVVideoPlaybackStatePlaying:
        {
            if ([self.movieView isAdMovie] && self.orderedData.trackSDK == 1) {
                [[TTADVideoMZTracker sharedManager] mzTrackVideoUrls:self.orderedData.adPlayTrackUrls adView:self.movieView];
            }
        }
            break;
        default:
            break;
    }
}
//share
- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action {
   if (![action isKindOfClass:[TTVPlayerStateAction class]]) {
           return;
   }
   
    switch (action.actionType) {
         case TTVPlayerEventTypeFinishDirectShare:{
             if ([action.payload isKindOfClass:[NSString class] ]) {
                        [self playFinishDirectShareActionWithActivityType:action.payload];
             }
        }
             break;
         case TTVPlayerEventTypePlayingDirectShare:{
            if ([action.payload isKindOfClass:[NSString class] ]) {
                        [self playingDirectShareActionWithActivityType:action.payload];
            }
        }
             break;
        default:
            break;
    }
}

- (void)playFinishDirectShareActionWithActivityType:(NSString *)activityTypeString{
    [self.shareLogDic setValue:@"nofullscreen" forKey:@"fullscreen"];
    [self.shareLogDic setValue:@"list_video_over" forKey:@"section"];
    [self directShareActionWithActivityType:activityTypeString];
}

- (void)playingDirectShareActionWithActivityType:(NSString *)activityTypeString
{
    [self.shareLogDic setValue:@"fullscreen" forKey:@"fullscreen"];
    [self.shareLogDic setValue:@"player_click_share" forKey:@"section"];
    [self directShareActionWithActivityType:activityTypeString];
    
}
- (void)directShareActionWithActivityType:(NSString *)activityTypeString
{
    id<TTActivityContentItemProtocol> activityItem;
    if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        TTWechatTimelineContentItem *wcTlItem = [self wechatTimelineCotentItem];
        activityItem = wcTlItem;
        [self.shareLogDic setValue:@"weixin_moments" forKey:@"platform"];
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechat]){
        TTWechatContentItem *wcItem = [[TTWechatContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
        activityItem = wcItem;
        [self.shareLogDic setValue:@"weixin" forKey:@"platform"];
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQFriend]){
        TTQQFriendContentItem *qqItem = [[TTQQFriendContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
        activityItem = qqItem;
        [self.shareLogDic setValue:@"qq" forKey:@"platform"];
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQZone]){
        TTQQZoneContentItem *qqZoneItem = [[TTQQZoneContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
        activityItem = qqZoneItem;
        [self.shareLogDic setValue:@"qqzone" forKey:@"platform"];
    }
//    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeDingTalk]){
//        TTDingTalkContentItem *ddItem = [[TTDingTalkContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
//        activityItem = ddItem;
//        [self.shareLogDic setValue:@"ding" forKey:@"platform"];
//    }
    if (activityItem) {
        [self.shareManager shareToActivity:activityItem presentingViewController:nil];
    }

}

- (TTShareManager *)shareManager {
    if (nil == _shareManager) {
        _shareManager = [[TTShareManager alloc] init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}

#pragma mark - 3G下播放优化

- (BOOL)isPlayingMovie
{
    if (self.movieView && self.movieView.superview && self.movieView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
        return YES;
    }
    return NO;
}

- (BOOL)isMovieFullScreen
{
    if (self.movieView && self.movieView.superview && self.movieView.player.context.isFullScreen) {
        return YES;
    }
    return NO;
}

- (BOOL)hasMovieView {
    if (self.movieView && self.movieView.superview == self.picView) {
        return YES;
    }
    return NO;
}

- (TTVPlayVideo *)detachMovieView {
    TTVPlayVideo *movieView = self.movieView;
    
    BOOL iOS9OrLater = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_9_0;
    if (iOS9OrLater) {
        //ios8不移除，避免movieView被释放的问题
        [self.movieView removeFromSuperview];
    }
    self.movieView = nil;
    [self bringAdButtonBackToCell];
    return movieView;
}

- (void)attachMovieView:(TTVPlayVideo *)movieView {
    if (movieView) {
        self.movieView = movieView;
        [_movieView.player setIsInDetail:NO];
        [_movieView.player setBannerHeight:0];
        _movieView.player.enableRotate = NO;
        _movieView.player.delegate = self;
        [self.picView addSubview:movieView];
        [self.picView bringSubviewToFront:movieView];
        if (_movieView.player.context.playbackState == TTVVideoPlaybackStateFinished) {
            self.picView.userInteractionEnabled = YES;
        } else {
            self.picView.userInteractionEnabled = NO;
        }
        movieView.frame = self.picView.bounds;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //静音会卡住界面
            if ([self.orderedData couldAutoPlay]) {
                [[TTVPlayerAudioController sharedInstance] setActive:NO];
            }
            self.movieView.player.muted = [self.orderedData couldAutoPlay];
        });
    }
}

- (void)refreshUI
{
    [super refreshUI];
    [self layoutPlayButton];

    if (![self.orderedData preCellHasBottomPadding] && [self.orderedData hasTopPadding]) {
        CGRect bounds = self.bounds;
        bounds.origin.y = - kUFSeprateViewHeight();
        self.bounds = bounds;
        self.topRect.bottom = 0;
        self.topRect.width = self.width;
        self.topRect.hidden = NO;
    } else {
        CGRect bounds = self.bounds;
        bounds.origin.y = 0;
        self.bounds = bounds;
        self.topRect.hidden = YES;
    }
    
    if (![self.orderedData nextCellHasTopPadding] && [self.orderedData hasTopPadding]) {
        self.bottomRect.bottom = self.height + self.bounds.origin.y;
        self.bottomRect.width = self.width;
        self.bottomRect.hidden = NO;
    }
    else{
        self.bottomRect.hidden = YES;
    }
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    BOOL isExpand = orderedData.cellLayOut.isExpand;
    if ([orderedData article]) {
        if (!orderedData.cellLayOut || orderedData.cellLayOut.needUpdateAllFrame){
            TTAdFeedCellDisplayType displayType = [orderedData.adModel displayType];
            if (displayType == TTAdFeedCellDisplayTypeLarge && [orderedData.adModel showActionButton]) {
                orderedData.cellLayOut = [[TTLayOutUnifyADLargePicCellModel alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypeUnifyADCellLargePic;
            }
            else{
//                if ([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle5
//                    || [orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle8
//                    || [orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle9
//                    || [orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle11) {
//                    orderedData.cellLayOut = [[TTLayOutUFLargePicCellModelS2 alloc] init];
//                    orderedData.layoutUIType = TTLayOutCellUITypeUFCellLargePicS2;
//                }
                if ([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle6) {
                    orderedData.cellLayOut = [[TTLayOutPlainLargePicCellModelS1 alloc] init];
                    orderedData.layoutUIType = TTLayOutCellUITypePlainCellLargePicS1;
                }
                else if ([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle7) {
                    orderedData.cellLayOut = [[TTLayOutPlainLargePicCellModelS2 alloc] init];
                    orderedData.layoutUIType = TTLayOutCellUITypePlainCellLargePicS2;
                }
                else{
                    orderedData.cellLayOut = [[TTLayOutPlainLargePicCellModelS0 alloc] init];
                    orderedData.layoutUIType = TTLayOutCellUITypePlainCellLargePicS0;
                }
            }
        }
    }

    TTLayOutCellBaseModel *cellLayOut = orderedData.cellLayOut;
    orderedData.cellLayOut.isExpand = isExpand;
    if ([cellLayOut needUpdateHeightCacheForWidth:width]) {
        [cellLayOut updateFrameForData:orderedData cellWidth:width listType:listType];
    }
    
    CGFloat height = cellLayOut.cellCacheHeight;
    if (height > 0) {
        if ([orderedData hasTopPadding]) {
            if ([orderedData nextCellHasTopPadding]){
                height -= kUFSeprateViewHeight();
            }
            if ([orderedData preCellHasBottomPadding]) {
                height -= kUFSeprateViewHeight();
            }
            if (height > 0) {
                return height;
            }
        }
        else{
            return height;
        }
    }
    return 0;
}

- (ExploreCellStyle)cellStyle {
    if ([self.orderedData isUnifyADCell]){
        return ExploreCellStyleUnknown;
    }
    if (self.orderedData.article.isImageSubject) {
        return ExploreCellStylePhoto;
    } else {
        if ([[self.orderedData.article hasVideo] boolValue]){
            return ExploreCellStyleVideo;
        }
        else{
            return ExploreCellStyleArticle;
        }
    }
}

- (ExploreCellSubStyle)cellSubStyle {
    if ([self.orderedData isUnifyADCell]){
        return ExploreCellSubStyleUnknown;
    }
    if (self.orderedData.article.isImageSubject) {
        return ExploreCellSubStyleGalleryLargePic;
    } else {
        if ([[self.orderedData.article hasVideo] boolValue]) {
            if ([self.orderedData isPlayInDetailView]) {
                return ExploreCellSubStyleVideoNotPlayableInList;
            }
            else {
                return ExploreCellSubStyleVideoPlayableInList;
            }
        }
        else{
            return ExploreCellSubStyleLargePic;
        }
    }
}

#pragma mark TTVFeedPlayMovie

- (BOOL)cell_hasMovieView {
    return [self hasMovieView];
}

- (BOOL)cell_isPlayingMovie {
    return [self isPlayingMovie];
}

- (BOOL)cell_isMovieFullScreen {
    return [self isMovieFullScreen];
}

- (UIView *)cell_movieView {
    return self.movieView;
}

- (id)cell_detachMovieView {
    return [self detachMovieView];
}

- (void)cell_attachMovieView:(id)movieView {
    [self attachMovieView:movieView];
}

- (CGRect)cell_logoViewFrame {
    return self.picView.frame;
}

- (BOOL)cell_isPlaying {
    return self.movieView.player.context.playbackState == TTVVideoPlaybackStatePlaying;
}

- (BOOL)cell_isPaused {
    return self.movieView.player.context.playbackState == TTVVideoPlaybackStatePaused;
}

- (BOOL)cell_isPlayingFinished {
    return self.movieView.player.context.playbackState == TTVVideoPlaybackStateFinished;
}

- (CGRect)cell_movieViewFrameRect {
    return [self convertRect:self.picView.bounds fromView:self.picView];
}

//- (UIView *)animationFromView
//{
//    return self.picView;
//}
//
//- (UIImage *)animationFromImage
//{
//    return [self.picView animationFromView].imageView.image;
//}

#pragma mark - TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
//    if ([[activity contentItemType] isEqualToString:TTActivityContentItemTypeSystem] ||
//        [[activity contentItemType] isEqualToString:TTActivityContentItemTypeSMS] ||
//        [[activity contentItemType] isEqualToString:TTActivityContentItemTypeEmail] ||
      if ([[activity contentItemType] isEqualToString:TTActivityContentItemTypeForwardWeitoutiao] ||
        [[activity contentItemType] isEqualToString:TTActivityContentItemTypeReport])
    {
        if ([TTVPlayVideo currentPlayingPlayVideo].player.context.isFullScreen)
        {
            TTVPlayVideo *playVideo = [TTVPlayVideo currentPlayingPlayVideo];
            [playVideo exitFullScreen:YES completion:^(BOOL finished) {
                [UIViewController attemptRotationToDeviceOrientation];
            }];
        }
    }
    //埋点
    [self shareLogV3WithEventName:@"rt_share_to_platform" params:self.shareLogDic];
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    
    NSString *eventName = nil;
    if(error) {
        TTVActivityShareErrorCode errorCode = [TTActivityShareSequenceManager shareErrorCodeFromItemErrorCode:error WithActivity:activity];
        switch (errorCode) {
            case TTVActivityShareErrorFailed:
                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
                break;
            case TTVActivityShareErrorUnavaliable:
            case TTVActivityShareErrorNotInstalled:
            default:
                break;
        }
        eventName = @"share_fail";
    }else{
        [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
        eventName = @"share_done";
    }
    [self shareLogV3WithEventName:eventName params:self.shareLogDic];

    _directShareActivity = nil;
}


#pragma mark - shareLogs
//isfullScreen,source(暂时没有需要数据分析师给),section,platForm
- (void)shareLogV3WithEventName:(NSString *) eventName params:(NSDictionary *)params {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:params];
    [dictionary setValue:self.orderedData.categoryID forKey:@"category_name"];
    [dictionary setValue:[self enterFrom] forKey:@"enter_from"];
    [dictionary setValue:@"list" forKey:@"position"];
    [dictionary setValue:@"exposed" forKey:@"icon_seat"];
    [dictionary setValue:@"weixin_moments" forKey:@"share_platform"];
    [dictionary setValue:[NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID] forKey:@"group_id"];
    [dictionary setValue:self.orderedData.article.itemID forKey:@"item_id"];
    [dictionary setValue:self.orderedData.logPb forKey:@"log_pb"];
    dictionary[@"event_type"] = @"house_app2c_v2";

    [TTTrackerWrapper eventV3:eventName params:dictionary isDoubleSending:NO];
}

- (NSString *)enterFrom{
    if ([self.orderedData.categoryID isEqualToString:@"__all__"]) {
        return @"click_headline";
    }else{
        return @"click_category";
    }
}

#pragma mark -- shateItems
- (TTWechatTimelineContentItem *)wechatTimelineCotentItem{
    
    UIImage *shareImg = [self shareImage];
    NSString *timeLineText = [self shareTitle];
    TTShareType shareType;
    NSString *adID = self.orderedData.article.adIDStr;

    TTWechatTimelineContentItem *wcTlItem;
    if (!isEmptyString(adID)) {
        shareType = TTShareVideo;
    }else{
        UIImageView *originalImageView = [[UIImageView alloc] initWithImage:[self shareImage]];
        if (ttvs_isShareTimelineOptimize() == 2) {
            shareImg = [self imageWithView:originalImageView];
        }
        if (ttvs_isShareTimelineOptimize() > 0 )
        {
            shareType = TTShareWebPage;
        }
        else{
            shareType = TTShareVideo;
        }

        if (ttvs_isShareTimelineOptimize() > 2) {
            timeLineText = [self timeLineTitle];
        }
    }
    wcTlItem = [[TTWechatTimelineContentItem alloc] initWithTitle:timeLineText desc:timeLineText webPageUrl:[self shareUrl] thumbImage:shareImg shareType:shareType];
    return wcTlItem;
}

#pragma mark - share util

- (NSString *)shareTitle
{
    NSString *shareTitle;
        NSString *mediaName = self.orderedData.article.source;
    if (!isEmptyString(mediaName)) {
        shareTitle = [NSString stringWithFormat:@"【%@】%@", mediaName, self.orderedData.article.title];
    }
    else {
        shareTitle = self.orderedData.article.title;
    }
    
    return shareTitle;
}

- (NSString *)timeLineTitle
{
    NSString *timeLineTitle;
    if (!isEmptyString(self.orderedData.article.title)){
        timeLineTitle = [NSString stringWithFormat:@"%@", self.orderedData.article.title];
    }else{
        timeLineTitle = NSLocalizedString(@"真房源，好中介，快流通", nil);
    }
    return timeLineTitle;
}


- (NSString *)shareDesc
{
    NSString *detail = isEmptyString(self.orderedData.article.abstract) ? NSLocalizedString(@"真房源，好中介，快流通", nil) : self.orderedData.article.abstract;
    return detail;
}

- (NSString *)shareUrl
{
    NSString *shareUrl = self.orderedData.article.shareURL;
    return shareUrl;
}

- (UIImage *)shareImage
{
    return [TTShareMethodUtil weixinSharedImageForArticle:self.orderedData.article];
}

- (UIImage *)imageWithView:(UIView *)view
{
    UIImage *iconImg = [UIImage imageNamed:@"video_play_share_icon.png"];
    UIImageView *iconImgView = [[UIImageView alloc] initWithImage:iconImg];
    iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    //iconImgView 方形 和view高度形同大小
    view.frame = CGRectMake(0, 0, view.size.width, view.size.height);
    iconImgView.size = CGSizeMake(view.size.height, view.size.height);
    [view addSubview:iconImgView];
    iconImgView.center = view.center;
    CGSize pageSize = view.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSMutableDictionary *)shareLogDic{
    if (!_shareLogDic) {
        _shareLogDic = [NSMutableDictionary dictionary];
    }
    return _shareLogDic;
}

@end

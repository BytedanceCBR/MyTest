//
//  TTUGCU13VideoCellView.m
//  Article
//
//  Created by Jiyee Sheng on 11/12/2017.
//
//

#import "TTUGCU13VideoCellView.h"

#import "TTUGCU13CellView.h"
#import "ExploreMovieView.h"
#import "TTThreadImageViewCell.h"
#import "TTArticleCellConst.h"
#import "TTArticleCellHelper.h"

#import "TTVPlayVideo.h"

#import "TTVPlayerTipAdOldCreator.h"
#import "TTVPlayerTipAdOldFinish.h"
#import "TTVPlayerTipShareCreater.h"
#import "TTVPlayerTipRelatedCreator.h"
#import "TTVPlayerUrlTracker.h"
#import "TTVDemanderTrackerManager.h"

#import "TTHighlightedView.h"
#import "UIView+UGCAdditions.h"
#import "Thread.h"
#import "FRCommentRepost.h"

#import <TTShareActivity.h>
#import <TTShareManager.h>
#import "TTPanelActivity.h"
#import "TTShareMethodUtil.h"
#import "TTActivityShareSequenceManager.h"
#import "TTVSettingsConfiguration.h"
#import "UGCCellHelper.h"
#import "TTUGCDefine.h"

#import <TTBaseLib/TTDeviceHelper.h>
#import <TTThemeManager.h>
#import "TTVVideoPlayerModel.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "TTVVideoPlayerStateStore.h"
#import "TTVPasterPlayer.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTTrackerWrapper.h>

#import "ExploreOrderedData+TTAd.h"
#import "Article+TTADComputedProperties.h"


@interface TTUGCU13VideoCellView ()<TTVDemandPlayerDelegate,TTShareManagerDelegate>

@property (nonatomic, strong) SSThemedButton *playButton;

@property (nonatomic, strong) TTThreadImageViewCell *picView;

@property (nonatomic, strong) TTVPlayVideo *movieView;

//转发内容组件
@property (nonatomic, strong) SSThemedView *forwardedItemBackgroundView;
@property (nonatomic, strong) TTHighlightedView *forwardedItemContainerView;
@property (nonatomic, strong) TTUGCAttributedLabel *forwardedItemContentLabel;
@property (nonatomic, strong) NSArray<TTThreadImageViewCell *> *forwardedItemImageViews;

//转发内容状态组件
@property (nonatomic, strong) SSThemedLabel *forwardedItemStatusLabel;

@property (nonatomic, assign) BOOL isFowardedVideo;

@property (nonatomic, strong) NSMutableDictionary *videoShareLogDic;

@property (nonatomic, strong) TTShareManager *shareManager;

@end


@implementation TTUGCU13VideoCellView

- (void)createComponents {
    [super createComponents];
    WeakSelf;

    TTThreadImageViewCell * imageView = [[TTThreadImageViewCell alloc] init];
    imageView.enableNightCover = YES;
    imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    imageView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.08f].CGColor;
    imageView.backgroundColor = [UIColor tt_themedColorForKey:kPicViewBackgroundColor()];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    self.picView = imageView;
    
    self.forwardedItemBackgroundView = [self ugc_addSubviewWithClass:[SSThemedView class]];
    
    self.forwardedItemContainerView = [self.forwardedItemBackgroundView ugc_addSubviewWithClass:[TTHighlightedView class]];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.forwardedItemContainerView.layer.borderColor = [UIColor colorWithHexString:@"D4D4D4"].CGColor;
    } else {
        self.forwardedItemContainerView.layer.borderColor = [UIColor colorWithHexString:@"464646"].CGColor;
    }
    self.forwardedItemContainerView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.forwardedItemContainerView.touchUpInsideHandle = ^(CGPoint point) {
        [wself.action forwardedItemTouchUp];
    };
    
    self.forwardedItemContentLabel = [self.forwardedItemContainerView ugc_addSubviewWithClass:[TTUGCAttributedLabel class]];
    self.forwardedItemContentLabel.delegate = self.action;
    self.forwardedItemContentLabel.extendsLinkTouchArea = NO;
    
    //转发内容状态组件
    self.forwardedItemStatusLabel = [self ugc_addSubviewWithClass:[SSThemedLabel class] themePath:@"#ThreadU13ForwardStatusLabel"];
    [self.forwardedItemStatusLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:nil action:nil]]; //只要出现，屏蔽点击事件
    
    // FPS 优化
//    if ([self isOptimizeColorBlendEnabled]) {
//        [self.forwardedItemContainerView tt_backgroundColorBindViews:self.forwardedItemContentLabel, self.forwardedItemLocationIconImageView, self.forwardedItemLocationLabel, nil];
//    }
    
    
    SSThemedButton *playButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    playButton.frame = self.picView.bounds;
    [playButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.picView addSubview:playButton];
    self.picView.userInteractionEnabled = YES;
    self.playButton = playButton;
    self.playButton.imageName = [TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play";
}


- (void)didDisappear
{
    [super didDisappear];
    if (self.movieView && self.movieView.superview) {
        if (!self.movieView.player.context.isFullScreen && !self.movieView.player.context.isRotating) {
            [self invalidateMovieView];
        }
    }
    
}
- (void)willAppear
{
    [super willAppear];
}

- (void)stopPlayVideo
{
    if (self.movieView && self.movieView.superview) {
        if (!self.movieView.player.context.isFullScreen && !self.movieView.player.context.isRotating) {
            [self invalidateMovieView];
        }
    }
}

- (void)layoutComponents {
    [super layoutComponents];
    [self layoutForwardedItemComponent];
    [self layoutForwardedItemStatusComponent];
    [self layoutVideoComponent];
}

#pragma mark - Notification

- (void)themeChanged:(NSNotification *)notification {
    self.picView.layer.borderColor = [UIColor tt_themedColorForKey:kPicViewBorderColor()].CGColor;
    self.picView.backgroundColor = [UIColor tt_themedColorForKey:kPicViewBackgroundColor()];

    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.forwardedItemContainerView.layer.borderColor = [UIColor colorWithHexString:@"D4D4D4"].CGColor;
    } else {
        self.forwardedItemContainerView.layer.borderColor = [UIColor colorWithHexString:@"464646"].CGColor;
    }

    [super themeChanged:notification];
}

- (CGFloat)videoStartY
{
    if ( self.forwardedItemBackgroundView && self.picView.superview == self.forwardedItemBackgroundView) {
        return [self.forwardedItemBackgroundView convertPoint:self.picView.frame.origin toView:self].y;
    } else if (self.picView) {
        return self.picView.frame.origin.y;
    }
    return 0;
}

#pragma mark - 视频播放相关

- (void)layoutForwardedItemComponent
{
    self.forwardedItemBackgroundView.hidden = self.currentLayoutModel.forwardedItemComponentHidden;
    if (!self.currentLayoutModel.forwardedItemComponentHidden) {
        self.forwardedItemBackgroundView.frame = self.currentLayoutModel.forwardedItemBackgroundViewFrame;
        self.forwardedItemContainerView.frame = self.currentLayoutModel.forwardedItemContainerViewFrame;
        self.forwardedItemContentLabel.frame = self.currentLayoutModel.forwardedItemContentLabelFrame;
        self.forwardedItemContentLabel.numberOfLines = self.currentLayoutModel.forwardedItemContentLabelLineNumber;
        self.forwardedItemContentLabel.attributedTruncationToken = self.currentLayoutModel.forwardedItemContentTruncationToken;
        self.forwardedItemContentLabel.text = nil;
        self.forwardedItemContentLabel.attributedText = self.currentLayoutModel.forwardedItemContentLabelAttributedStr;
        
        for (TTUGCAttributedLabelLink* link in self.currentLayoutModel.forwardedItemContentLabelLinks) {
            WeakSelf;
            link.linkTapBlock = ^(TTUGCAttributedLabel * label, TTUGCAttributedLabelLink *link) {
                [wself.action linkTap:link.linkURL];
            };
            [self.forwardedItemContentLabel addLink:link];
        }
    }
}

- (void)layoutForwardedItemStatusComponent
{
    self.forwardedItemStatusLabel.hidden = self.currentLayoutModel.forwardedItemStatusLabelHidden;
    if (!self.currentLayoutModel.forwardedItemStatusLabelHidden) {
        self.forwardedItemStatusLabel.frame = self.currentLayoutModel.forwardedItemStatusLabelFrame;
        self.forwardedItemStatusLabel.borderColorThemeKey = kColorLine10;
        self.forwardedItemStatusLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.forwardedItemStatusLabel.contentInset = UIEdgeInsetsMake(0, kU13TitleLabelHPadding(), 0, 0);
        self.forwardedItemStatusLabel.text = self.currentLayoutModel.forwardedItemStatusLabelText;
        self.forwardedItemStatusLabel.font = [UIFont systemFontOfSize:kU13ThreadForwardContentFontSize()];
    }
}


- (void)layoutVideoComponent {
    //只保留一个picView，一个playButton，根据是否有本帖的图来决定是按照origin还是forward布局。
    self.picView.hidden = NO;
    if ([self.currentLayoutModel.thumbImageList count]) {
        //纯视频类型，
        self.picView.frame = [self.currentLayoutModel.imageViewRects firstObject].CGRectValue;
        [self.picView ugc_setImageWithModel:[self.currentLayoutModel.thumbImageList firstObject]];
        self.picView.userInteractionEnabled = self.currentLayoutModel.videoPlayInList;
        [self addSubview:self.picView];
        
        self.isFowardedVideo = NO;
    } else if ([self.currentLayoutModel.forwardThumbImageList count]) {
        //转发的视频或者评论转发的视频
        self.picView.frame = [self.currentLayoutModel.forwardedItemImageViewRects firstObject].CGRectValue;
        [self.picView ugc_setImageWithModel:[self.currentLayoutModel.forwardThumbImageList firstObject]];
        self.picView.userInteractionEnabled = self.currentLayoutModel.videoPlayInList;
        [self.forwardedItemBackgroundView addSubview:self.picView];
        
        self.isFowardedVideo = YES;
    }
    
    self.playButton.userInteractionEnabled = self.currentLayoutModel.videoPlayInList;
    self.playButton.hidden = !self.currentLayoutModel.showPlayButton;
    NSInteger durationTime = self.currentLayoutModel.videoDuration;
    if (durationTime > 0) {
        NSInteger minute = durationTime / 60;
        NSInteger second = durationTime % 60;
        [self.picView setTagLabelText:[NSString stringWithFormat:@"%02ld:%02ld", (long)minute, (long)second]];
    } else {
        [self.picView setTagLabelText:nil];
    }
}

- (void)playButtonClicked
{
    Article *article = [self videoArticle];
    
    TTVVideoPlayerModel *videoPlayModel = [[TTVVideoPlayerModel alloc] init];
    videoPlayModel.itemID = article.itemID;
    videoPlayModel.groupID = [NSString stringWithFormat:@"%lld", article.uniqueID];
    videoPlayModel.aggrType = article.aggrType.integerValue;
    videoPlayModel.videoID = article.videoID;
    if (isEmptyString(videoPlayModel.videoID)) {
        videoPlayModel.videoID = [article.videoPlayInfo objectForKey:VideoInfoIDKey];
    }
    if (isEmptyString(videoPlayModel.videoID)) {
        videoPlayModel.videoID = [article.videoDetailInfo objectForKey:VideoInfoIDKey];
    }
    if (article.videoLocalURL) {
        if ([article.videoLocalURL rangeOfString:@"file://"].location != NSNotFound) {
            videoPlayModel.localURL = article.videoLocalURL;
        } else {
            videoPlayModel.localURL = [NSString stringWithFormat:@"file://%@%@", NSHomeDirectory(), article.videoLocalURL];
        }
    }
    if (!self.currentLayoutModel.isInThreadDetail) {
        videoPlayModel.adID = self.orderedData.ad_id;//这个adId是广告视频需要的
        videoPlayModel.logExtra = self.orderedData.log_extra;
    } else {
        videoPlayModel.logExtra = article.logExtra;
        
    }
    videoPlayModel.categoryID = [self categoryID];
    videoPlayModel.categoryName = [self categoryID];
    videoPlayModel.logPb = [self logPb];
    videoPlayModel.enterFrom = [self enterFrom];
    videoPlayModel.authorId = [[self videoArticle].userInfo tt_stringValueForKey:@"user_id"];
    
    videoPlayModel.sp = ([article.groupFlags longLongValue] & ArticleGroupFlagsDetailSP) > 0 ? ExploreVideoSPLeTV : ExploreVideoSPToutiao;
    
    if (article.isVideoSourceUGCVideo) {
        videoPlayModel.defaultResolutionType = TTVPlayerResolutionTypeHD;
    }
    if ([article hasVideoSubjectID]) {
        videoPlayModel.videoSubjectID = [article.videoDetailInfo valueForKey:kArticleInfoRelatedVideoSubjectIDKey];
    }
    BOOL isVideoFeedURLEnabled = ttvs_isVideoFeedURLEnabled();
    if (!self.currentLayoutModel.isInThreadDetail) {
        if (isVideoFeedURLEnabled && [article hasVideoPlayInfoUrl] && [article isVideoUrlValid]) {
            videoPlayModel.videoPlayInfo = article.videoPlayInfo;
        }
    } else {
        if ([article hasVideoPlayInfoUrl] && [article isVideoUrlValid]) {
            videoPlayModel.videoPlayInfo = article.videoPlayInfo;
        }
    }
    
//    NSInteger isVideoShowOptimizeShare = ttvs_isVideoShowOptimizeShare();
    //在这里不显示播放器全屏右上角的分享按钮。
    videoPlayModel.playerShowShareMore = 0;
    
    //只有有admodel才行,号外广告显示正常视频UI
    if ([article isAd]) {//纯广告
        videoPlayModel.enablePasterAd = NO;
    }else{//非广告使用贴片功能
        //
        videoPlayModel.enablePasterAd = YES;
        if(!self.currentLayoutModel.isInThreadDetail) {
            videoPlayModel.pasterAdFrom = @"feed";
        } else {
            //!!!视频的一个埋点参数，穿什么？
            videoPlayModel.pasterAdFrom = @"textlink";
        }
    }
    //暂时不加自动播放的代码
    //想加的时候去feed的类里面，搜索auto，ps，feed的类的自动播放是针对纯广告的
    
    [ExploreMovieView removeAllExploreMovieView];//通过这个方法触发通知，停止其他正在播放的feed里的movieView
    self.movieView = [[TTVPlayVideo alloc] initWithFrame:self.picView.bounds playerModel:videoPlayModel];
    
    //下面这一堆事tipCreator，据说事播放完了之后的一些文案啥的。
    if ([article.adModel isCreativeAd]) {
        //纯广告有adId
        //tipCreator是啥,播放结束的文案啥的
        self.movieView.player.tipCreator = [[TTVPlayerTipAdOldCreator alloc] init];
    }else{
        if (ttvs_isPlayerShowRelated()) {
            //下面这一块是考过来的。
            self.movieView.player.tipCreator = [[TTVPlayerTipRelatedCreator alloc] init];
        }else{
            NSInteger isVideoShowDirectShare = ttvs_isVideoShowDirectShare();
            if ((isVideoShowDirectShare == 1 || isVideoShowDirectShare == 3)){
                self.movieView.player.tipCreator = [[TTVPlayerTipShareCreater alloc] init];
            }
        }
    }
    [self ttv_configADFinishedView:(TTVPlayerTipAdFinished *)self.movieView.player.tipCreator.tipFinishedView];
  
    self.movieView.layer.zPosition = 1;//通过这句话盖住那个时间的标签
    
    
    [self.picView addSubview:self.movieView];
    if (self.movieView) {
        self.movieView.player.delegate = self;
        [self.movieView.player readyToPlay];
        
        [self.movieView.player setVideoTitle:article.title];
        [self.movieView setVideoLargeImageDict:article.largeImageDict];
        self.movieView.player.showTitleInNonFullscreen = NO;//不展开的时候不显示title
        if (self.currentLayoutModel.isInThreadDetail) {
            if (article.detailShowPortrait) {
                [self.movieView.player setEnableRotate:NO];
            } else {
                [self.movieView.player setEnableRotate:YES];
            }
        } else {
            if (article.showPortrait) {
                [self.movieView.player setEnableRotate:NO];
            } else {
                [self.movieView.player setEnableRotate:YES];
            }
        }
        // 这个方法要在readyToPlay之后，不然playerStateStore没有初始化（拷贝别人的注释）
        [self addUrlTracker];
        [self.movieView.player play];
    }
    
    
}

//那个tip相关的方法
- (void)ttv_configADFinishedView:(TTVPlayerTipAdFinished *)finishedView
{
    if ([finishedView isKindOfClass:[TTVPlayerTipAdOldFinish class]]){
        [finishedView setData:self.orderedData];
    }
}

//视频的一些监控参数
- (void)addUrlTracker
{
    if (!self.currentLayoutModel.isInThreadDetail) {
        //feed
        TTVPlayerUrlTracker *urlTracker = [self.orderedData videoPlayTracker];
        urlTracker.videoThirdMonitorUrl = self.orderedData.article.videoThirdMonitorUrl;
        [self.movieView.commonTracker registerTracker:urlTracker];
    } else {
        //这块详情页得改，娶不到这些数据
        TTVPlayerUrlTracker *urlTracker = [[TTVPlayerUrlTracker alloc] init];
        urlTracker.videoThirdMonitorUrl = [self videoArticle].videoThirdMonitorUrl;
    }
    
}

- (void)addTrackExtra
{
    NSDictionary *videoPlayExtra = @{@"positin":self.currentLayoutModel.isInThreadDetail?@"detail":@"list",
                                     };
    self.movieView.player.playerStateStore.state.isInDetail = self.currentLayoutModel.isInThreadDetail;
    [self.movieView.player.commonTracker addExtra:videoPlayExtra forEvent:@"video_play"];
    [self.movieView.player.commonTracker addExtra:videoPlayExtra forEvent:@"video_over"];
}

- (void)setMovieView:(TTVPlayVideo *)movieView
{
    if (_movieView != movieView) {
        
        [self removeMovieViewNotification];
        _movieView = movieView;
        [self registerMovieViewNotification];
        //这里先写不在detail，不知道背后有啥逻辑
        //!!!看看isindetail是干啥的。问视频的人
        //控制了stateStore里面的state
        [_movieView.player setIsInDetail:NO];
    }
}

- (void)registerMovieViewNotification
{
    if (self.movieView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kUGCListShowPhotoNotification object:nil];
    }
}

- (void)removeMovieViewNotification
{
    if (self.movieView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kUGCListShowPhotoNotification object:nil];
    }
}

- (void)movieViewPlayFinished
{
    //这几个是列表页情况
    if (!self.currentLayoutModel.isInThreadDetail) {
        //feed 停止
        if (isEmptyString(self.movieView.playerModel.adID) ) {
            if (self.movieView.player.pasterPlayer.hasPasterAd) {
                [self invalidateMovieView];
            }
        }
    }
    
}

//播放器状态回调
#pragma mark - TTVDemandPlayerDelegate
- (void)playerPlaybackState:(TTVVideoPlaybackState)state
{
    switch (state) {
        case TTVVideoPlaybackStateFinished:
        {
            //播放结束，先只写着一个吧
            [self movieViewPlayFinished];
            
        }
            break;
            //其他状态暂时可以不加
        default:
            break;
    }
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action
{
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

- (CGRect)ttv_movieViewFrameAfterExitFullscreen {
    return self.picView.bounds;
}

#pragma mark - 视频分享相关。

- (void)playFinishDirectShareActionWithActivityType:(NSString *)activityTypeString{
    
    [self.videoShareLogDic setValue:@"nofullscreen" forKey:@"fullscreen"];
    [self.videoShareLogDic setValue:@"list_video_over" forKey:@"section"];
    [self directShareActionWithActivityType:activityTypeString];
}

- (void)playingDirectShareActionWithActivityType:(NSString *)activityTypeString
{
    [self.videoShareLogDic setValue:@"fullscreen" forKey:@"fullscreen"];
    [self.videoShareLogDic setValue:@"player_click_share" forKey:@"section"];
    [self directShareActionWithActivityType:activityTypeString];
    
}

- (void)directShareActionWithActivityType:(NSString *)activityTypeString
{
    id<TTActivityContentItemProtocol> activityContentItem;
    if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        TTWechatTimelineContentItem *wcTlItem = [self wechatTimelineCotentItem];
        activityContentItem = wcTlItem;
        [self.videoShareLogDic setValue:@"weixin_moments" forKey:@"platform"];
    } else if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechat]){
        TTWechatContentItem *wcItem = [[TTWechatContentItem alloc] initWithTitle:[self videoShareTitle] desc:[self videoShareDesc] webPageUrl:[self videoShareUrl] thumbImage:[self videoShareImage] shareType:TTShareWebPage];
        activityContentItem = wcItem;
        [self.videoShareLogDic setValue:@"weixin" forKey:@"platform"];
    } else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQFriend]){
        TTQQFriendContentItem *qqItem = [[TTQQFriendContentItem alloc] initWithTitle:[self videoShareTitle] desc:[self videoShareDesc] webPageUrl:[self videoShareUrl] thumbImage:[self videoShareImage] imageUrl:nil shareTye:TTShareWebPage];
        activityContentItem = qqItem;
        [self.videoShareLogDic setValue:@"qq" forKey:@"platform"];
    } else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQZone]){
        TTQQZoneContentItem *qqZoneItem = [[TTQQZoneContentItem alloc] initWithTitle:[self videoShareTitle] desc:[self videoShareDesc] webPageUrl:[self videoShareUrl] thumbImage:[self videoShareImage] imageUrl:nil shareTye:TTShareWebPage];
        activityContentItem = qqZoneItem;
        [self.videoShareLogDic setValue:@"qqzone" forKey:@"platform"];
    }
//    else if ([activityTypeString isEqualToString:TTActivityContentItemTypeDingTalk]){
//        TTDingTalkContentItem *ddItem = [[TTDingTalkContentItem alloc] initWithTitle:[self videoShareTitle] desc:[self videoShareDesc] webPageUrl:[self videoShareUrl] thumbImage:[self videoShareImage] shareType:TTShareWebPage];
//        activityContentItem = ddItem;
//        [self.videoShareLogDic setValue:@"ding" forKey:@"platform"];
//    }
    
    if (activityContentItem) {
        [self.shareManager shareToActivity:activityContentItem presentingViewController:nil];
    }
    
}

- (TTShareManager *)shareManager {
    if (!_shareManager) {
        _shareManager = [[TTShareManager alloc] init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}

- (NSMutableDictionary *)videoShareLogDic
{
    if (!_videoShareLogDic) {
        _videoShareLogDic = [NSMutableDictionary dictionary];
    }
    return _videoShareLogDic;
}

- (NSString *)videoShareTitle
{
    NSString *videoShareTitle;
    Article *videoArticle = [self videoArticle];
    NSString *mediaName = videoArticle.source;
    if (!isEmptyString(mediaName)) {
        videoShareTitle = [NSString stringWithFormat:@"【%@】%@", mediaName, videoArticle.title];
    }
    else {
        videoShareTitle = videoArticle.title;
    }
    
    return videoShareTitle;
}

- (NSString *)videoTimeLineTitle
{
    NSString *videoTimeLineTitle;
    Article *videoArticle = [self videoArticle];
    if (!isEmptyString(videoArticle.title)){
        videoTimeLineTitle = [NSString stringWithFormat:@"%@-%@", videoArticle.title, @""];
    }else{
        videoTimeLineTitle = NSLocalizedString(@"爱看", nil);
    }
    return videoTimeLineTitle;
}


- (NSString *)videoShareDesc
{
    Article *videoArticle = [self videoArticle];
    NSString *detail = isEmptyString(videoArticle.abstract) ? NSLocalizedString(@"爱看", nil) : videoArticle.abstract;
    return detail;
}

- (NSString *)videoShareUrl
{
    NSString *videoShareUrl = [self videoArticle].shareURL;
    return videoShareUrl;
}

- (UIImage *)videoShareImage
{
    return [TTShareMethodUtil weixinSharedImageForArticle:[self videoArticle]];
}

- (TTWechatTimelineContentItem *)wechatTimelineCotentItem{
    
    UIImage *shareImg = [self videoShareImage];
    NSString *timeLineText = [self videoShareTitle];
    TTShareType shareType;
    NSString *adID = [self videoArticle].adIDStr;
    
    TTWechatTimelineContentItem *wcTlItem;
    if (!isEmptyString(adID)) {
        shareType = TTShareVideo;
    }else{
        UIImageView *originalImageView = [[UIImageView alloc] initWithImage:[self videoShareImage]];
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
            timeLineText = [self videoTimeLineTitle];
        }
    }
    wcTlItem = [[TTWechatTimelineContentItem alloc] initWithTitle:timeLineText desc:timeLineText webPageUrl:[self videoShareUrl] thumbImage:shareImg shareType:shareType];
    return wcTlItem;
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
    [self shareLogV3WithEventName:eventName params:self.videoShareLogDic];
}

- (void)shareLogV3WithEventName:(NSString *) eventName params:(NSDictionary *)params {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:params];
    
    NSMutableDictionary *addedDict = [NSMutableDictionary dictionary];
    [addedDict setValue:[self videoArticle].itemID forKey:@"item_id"];
    [addedDict setValue:@"exposed" forKey:@"icon_seat"];
    [addedDict setValue:[NSString stringWithFormat:@"%lld", [self videoArticle].uniqueID] forKey:@"group_id"];
    [addedDict setValue:self.currentLayoutModel.isInThreadDetail?@"detail":@"list" forKey:@"position"];
    [addedDict setValue:@"video" forKey:@"source"] ;

    if (self.currentLayoutModel.isInThreadDetail) {
        [addedDict setValue:[self.commonV3Extra valueForKey:@"log_pb"] forKey:@"log_pb"];
        [addedDict setValue:[self.commonV3Extra tt_stringValueForKey:@"category_name"] forKey:@"category_name"];
        [addedDict setValue:[self.commonV3Extra tt_stringValueForKey:@"enter_from"] forKey:@"enter_from"];
    } else {
        [addedDict setValue:self.orderedData.logPb forKey:@"log_pb"];
        [addedDict setValue:self.orderedData.categoryID forKey:@"category_name"];
        NSString *enterFrom;
        if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
            enterFrom = @"click_headline";
        } else {
            enterFrom = @"click_category";
        }
        [addedDict setValue:enterFrom forKey:@"enter_from"];
    }
    [dictionary addEntriesFromDictionary:addedDict];
    [TTTrackerWrapper eventV3:eventName params:dictionary isDoubleSending:NO];
    
}
- (NSString *)v3EnterFrom
{
    if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
        return @"click_headline";
    } else {
        return @"click_category";
    }
}
- (void)stopMovieViewPlay:(NSNotification *)notification
{
    [self invalidateMovieView];
}

- (void)invalidateMovieView
{
    if (self.movieView) {
        [self.movieView exitFullScreen:NO completion:nil];
        self.movieView.player.delegate = nil;
        [self.movieView stop];
        [self.movieView removeFromSuperview];
        self.movieView = nil;
    }
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    if (self.movieView && self.movieView.superview && isEmptyString(self.movieView.playerModel.adID) ) {
        if (!self.movieView.player.context.isFullScreen && !self.movieView.player.context.isRotating) {
            
            [self.movieView stop];
            self.movieView.hidden = YES;
        }
    }
}

#pragma mark - 3G下播放优化

- (BOOL)isPlayingMovie
{
    if (self.movieView && self.movieView.superview && self.movieView.player.context.playbackState == TTVVideoPlaybackStatePlaying ) {
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
    [self.movieView removeFromSuperview];
    self.movieView = nil;
    return movieView;
}

- (void)attachMovieView:(TTVPlayVideo *)movieView {
    if (movieView) {
        self.movieView = movieView;
        //为修复详情页返回时movieView会突然跳动，把添加movieView放到另一个runloop，别人的注释
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.picView addSubview:movieView];
            [self.picView bringSubviewToFront:movieView];
            movieView.frame = self.picView.bounds;
            movieView.player.delegate = self;//英杰没有，我加的，应该OK
        });
    }
}


//保留这两个方法，讨论其存在必要
- (CGRect)logoViewFrame
{
    return self.picView.frame;
}

- (CGRect)movieViewFrameRect {
    return [self convertRect:self.picView.bounds fromView:self.picView];
}

- (ExploreCellStyle)cellStyle {
    //这块有了详情页时候可能要多些逻辑
    if (!self.currentLayoutModel.isInThreadDetail) {
        //feed保留老代码
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
    } else {
        //详情页，直接返回unknown了
        return ExploreCellStyleUnknown;
    }
    
}

- (ExploreCellSubStyle)cellSubStyle {
    if (!self.currentLayoutModel.isInThreadDetail) {
        //feed
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
    } else {
        //详情页，直接返回unknown
        return ExploreCellSubStyleUnknown;
    }
}

- (UIView *)animationFromView {
    return self.picView;
}

- (UIImage *)animationFromImage
{
    return self.picView.image;
}

- (Article *)videoArticle
{
    //需要考虑cell重用的问题，orderedData基本是考虑了重用的情况的
    if ([self.orderedData.article hasVideo].boolValue) {
        //feed中的视频
        return self.orderedData.article;
    } else if ([self.orderedData.thread.originGroup hasVideo].boolValue) {
        //feed中的转发视频
        return self.orderedData.thread.originGroup;
    } else if ([self.orderedData.commentRepostModel.originGroup hasVideo].boolValue) {
        //feed中的评论并转发视频
        return self.orderedData.commentRepostModel.originGroup;
    } else if ([self.article hasVideo].boolValue) {
        //帖子详情页和v2详情页中的用这个。
        return self.article;
    }
    
    return nil;
}


#pragma mark - Tracks
- (NSString *)enterFrom
{
    if (!self.currentLayoutModel.isInThreadDetail) {
        if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
            return @"click_headline";
        } else {
            return @"click_category";
        }
    } else {
        return [self.commonV3Extra tt_stringValueForKey:@"enter_from"];
    }
    
}

- (NSDictionary *)logPb
{
    if (!self.currentLayoutModel.isInThreadDetail) {
       return self.orderedData.logPb;
    } else {
        
        return [self.commonV3Extra tt_dictionaryValueForKey:@"log_pb"];
    }
}

- (NSString *)categoryID
{
    if (!self.currentLayoutModel.isInThreadDetail) {
        return self.orderedData.categoryID;
    } else {
        return [self.commonV3Extra tt_stringValueForKey:@"category_id"];
    }
}



@end


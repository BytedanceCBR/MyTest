//
//  TTUGCVideoCellView.m
//  Article
//
//  Created by SongChai on 2017/11/20.
//

#import "TTUGCVideoCellView.h"
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

#import <TTShareActivity.h>
#import <TTShareManager.h>
#import "TTPanelActivity.h"
#import "TTShareMethodUtil.h"
#import "TTActivityShareSequenceManager.h"
#import "TTUGCDefine.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import "TTVVideoPlayerModel.h"
#import "TTVSettingsConfiguration.h"
#import "TTVPasterPlayer.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTTrackerWrapper.h>
#import "UGCCellHelper.h"

#import "ExploreOrderedData+TTAd.h"
#import "Article+TTADComputedProperties.h"


//这个view应该只用作u12列表页播放

@interface TTUGCVideoCellView () <TTVDemandPlayerDelegate,TTShareManagerDelegate>

@property (nonatomic, strong) Article *article;

@property (nonatomic, strong) SSThemedButton *playButton;

@property (nonatomic, strong) TTThreadImageViewCell *picView;

@property (nonatomic, strong) TTVPlayVideo *movieView;

@property (nonatomic, strong) NSMutableDictionary *videoShareLogDic;
@property (nonatomic, strong) TTShareManager *shareManager;

@end

@implementation TTUGCVideoCellView

- (void)createComponents {
    [super createComponents];
    TTThreadImageViewCell * imageView = [[TTThreadImageViewCell alloc] init];
    imageView.enableNightCover = YES;
    imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    imageView.layer.borderColor = [UIColor tt_themedColorForKey:kPicViewBorderColor()].CGColor;
    imageView.backgroundColor = [UIColor tt_themedColorForKey:kPicViewBackgroundColor()];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    self.picView = imageView;
    [self addSubview:self.picView];
    
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

- (void)layoutComponents {
    [super layoutComponents];
    [self layoutVideoComponent];
}

- (void)willAppear
{
    [super willAppear];
}

#pragma -- mark 视频播放相关

- (void)layoutVideoComponent {
    self.picView.hidden = NO;
    //采用trick的方法将picView的isAppear设置为YES；
    self.picView.frame = [self.currentLayoutModel.imageViewRects firstObject].CGRectValue;
    [self.picView ugc_setImageWithModel:[self.currentLayoutModel.thumbImageList firstObject]];
    self.picView.userInteractionEnabled = self.currentLayoutModel.videoPlayInList;
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
    //    Article *article = self.orderedData.article;
    
    TTVVideoPlayerModel *videoPlayModel = [[TTVVideoPlayerModel alloc] init];
    videoPlayModel.itemID = self.article.itemID;
    videoPlayModel.groupID = [NSString stringWithFormat:@"%lld", self.article.uniqueID];
    videoPlayModel.aggrType = self.article.aggrType.integerValue;
    videoPlayModel.videoID = self.article.videoID;
    if (isEmptyString(videoPlayModel.videoID)) {
        videoPlayModel.videoID = [self.article.videoPlayInfo objectForKey:VideoInfoIDKey];
    }
    if (self.article.videoLocalURL) {
        if ([self.article.videoLocalURL rangeOfString:@"file://"].location != NSNotFound) {
            videoPlayModel.localURL = self.article.videoLocalURL;
        } else {
            videoPlayModel.localURL = [NSString stringWithFormat:@"file://%@%@", NSHomeDirectory(), self.article.videoLocalURL];
        }
    }
    videoPlayModel.adID = self.orderedData.ad_id;//这个adId是广告视频需要的
    videoPlayModel.logExtra = self.orderedData.log_extra;
    videoPlayModel.logPb = self.orderedData.logPb;//这一行原来没有，感觉加上没问题
    
    
    videoPlayModel.sp = ([self.article.groupFlags longLongValue] & ArticleGroupFlagsDetailSP) > 0 ? ExploreVideoSPLeTV : ExploreVideoSPToutiao;
    
    if (self.article.isVideoSourceUGCVideo) {
        videoPlayModel.defaultResolutionType = TTVPlayerResolutionTypeHD;
    }
    if ([self.article hasVideoSubjectID]) {
        videoPlayModel.videoSubjectID = [self.article.videoDetailInfo valueForKey:kArticleInfoRelatedVideoSubjectIDKey];
    }
    BOOL isVideoFeedURLEnabled = ttvs_isVideoFeedURLEnabled();

    if (isVideoFeedURLEnabled && [self.article hasVideoPlayInfoUrl] && [self.article isVideoUrlValid]) {
        videoPlayModel.videoPlayInfo = self.article.videoPlayInfo;
    }
    
    
//    NSInteger isVideoShowOptimizeShare = ttvs_isVideoShowOptimizeShare();
    //在这里不显示全屏右上角的分享按钮。
    videoPlayModel.playerShowShareMore = 0;

    //只有有admodel才行,号外广告显示正常视频UI
    if ([self.article isAd]) {//纯广告
        videoPlayModel.enablePasterAd = NO;
    }else{//非广告使用贴片功能
        videoPlayModel.enablePasterAd = YES;
        videoPlayModel.pasterAdFrom = @"feed";
    }
    //暂时不加自动播放的代码
    //想加的时候去feed的类里面，搜索auto，ps，feed的类的自动播放是针对纯广告的
    
    [ExploreMovieView removeAllExploreMovieView];//通过这个方法触发通知，停止其他正在播放的feed里的movieView
    self.movieView = [[TTVPlayVideo alloc] initWithFrame:self.picView.bounds playerModel:videoPlayModel];
    
    //下面这一堆事tipCreator，据说事播放完了之后的一些文案啥的。
    if ([self.article.adModel isCreativeAd]) {
        //纯广告有adId
        //tipCreator是,播放结束的文案啥的
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
        
        // 这个方法要在readyToPlay之后，不然playerStateStore没有初始化（拷贝别人的注释）
        if ([self.article showPortrait]) {
            [self.movieView.player setEnableRotate:NO];
        } else {
            [self.movieView.player setEnableRotate:YES];
        }
        [self.movieView.player setVideoTitle:self.currentLayoutModel.contentRichText.text];
        [self.movieView setVideoLargeImageDict:self.article.largeImageDict];
        self.movieView.player.showTitleInNonFullscreen = NO;//不展开的时候不显示title
        
        
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
    //feed
    TTVPlayerUrlTracker *urlTracker = [self.orderedData videoPlayTracker];
    urlTracker.videoThirdMonitorUrl = self.orderedData.article.videoThirdMonitorUrl;
    [self.movieView.commonTracker registerTracker:urlTracker];
    
    
}

- (void)setMovieView:(TTVPlayVideo *)movieView
{
    if (_movieView != movieView) {
        
        [self removeMovieViewNotification];
        _movieView = movieView;
        [self registerMovieViewNotification];
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
    if (isEmptyString(self.movieView.playerModel.adID) ) {
        if (self.movieView.player.pasterPlayer.hasPasterAd) {
            [self invalidateMovieView];
        }
    }
}

//播放器状态回调
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

//iOS8全屏需要的一个回调
- (CGRect)ttv_movieViewFrameAfterExitFullscreen {
    return self.picView.bounds;
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
    
    
}

- (ExploreCellSubStyle)cellSubStyle {
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
    
}

- (UIView *)animationFromView {
    return self.picView;
}

- (UIImage *)animationFromImage
{
    return self.picView.image;
}

- (Article *)article
{
    
    return self.orderedData.article;
}

#pragma mark 视频分享相关
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
    Article *videoArticle = self.article;
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
    Article *videoArticle = self.article;
    if (!isEmptyString(videoArticle.title)){
        videoTimeLineTitle = [NSString stringWithFormat:@"%@-%@", videoArticle.title, @""];
    }else{
        videoTimeLineTitle = NSLocalizedString(@"爱看", nil);
    }
    return videoTimeLineTitle;
}


- (NSString *)videoShareDesc
{
    Article *videoArticle = self.article;
    NSString *detail = isEmptyString(videoArticle.abstract) ? NSLocalizedString(@"爱看", nil) : videoArticle.abstract;
    return detail;
}

- (NSString *)videoShareUrl
{
    NSString *videoShareUrl = self.article.shareURL;
    return videoShareUrl;
}

- (UIImage *)videoShareImage
{
    return [TTShareMethodUtil weixinSharedImageForArticle:self.article];
}

- (TTWechatTimelineContentItem *)wechatTimelineCotentItem{
    
    UIImage *shareImg = [self videoShareImage];
    NSString *timeLineText = [self videoShareTitle];
    TTShareType shareType;
    NSString *adID = self.article.adIDStr;
    
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
    [addedDict setValue:self.orderedData.article.itemID forKey:@"item_id"];
    [addedDict setValue:@"exposed" forKey:@"icon_seat"];
    [addedDict setValue:[NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID] forKey:@"group_id"];
    [addedDict setValue:@"list" forKey:@"position"];
    [addedDict setValue:@"video" forKey:@"source"] ;
    
    [addedDict setValue:self.orderedData.logPb forKey:@"log_pb"];
    [addedDict setValue:self.orderedData.categoryID forKey:@"category_name"];
    NSString *enterFrom;
    if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
        enterFrom = @"click_headline";
    } else {
        enterFrom = @"click_category";
    }
    [addedDict setValue:enterFrom forKey:@"enter_from"];
    [dictionary addEntriesFromDictionary:addedDict];
    [TTTrackerWrapper eventV3:eventName params:dictionary isDoubleSending:NO];
    
}

@end






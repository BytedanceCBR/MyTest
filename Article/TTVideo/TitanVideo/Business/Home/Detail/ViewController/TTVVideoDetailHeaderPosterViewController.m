//
//  TTVVideoDetailHeaderPosterViewController.m
//  Article
//
//  Created by pei yun on 2017/5/8.
//
//

#import "TTVVideoDetailHeaderPosterViewController.h"
#import "TTVideoDetailHeaderPosterView.h"
#import "TTVVideoDetailMovieBanner.h"
#import "TTVideoShareMovie.h"
#import <KVOController/KVOController.h>
#import "TTDetailModel+videoArticleProtocol.h"
#import "TTMovieViewCacheManager.h"
#import "ExploreVideoDetailHelper.h"
#import "SSWebViewController.h"
#import "TTDetailModel.h"
#import "TTCommentViewController.h"
#import "TTVContainerScrollView.h"
#import "TTUIResponderHelper.h"
#import <TTVideoService/VideoFeed.pbobjc.h>
#import "ExploreOrderedADModel+TTVSupport.h"
#import "TTVVideoDetailNatantPGCViewController.h"
#import "TTVCellPlayMovie.h"
#import "TTVideoCommon.h"
#import "TTActivityShareManager.h"
#import "SSURLTracker.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTVDetailFollowRecommendViewController.h"

#import "TTVVideoPlayerModel.h"
#import "TTTrackerProxy.h"

static const NSTimeInterval kAnimDuration = 0.2;
static const CGFloat kCommentVCTolerance = 10;

extern CGFloat ttvs_detailVideoMaxHeight(void);

@implementation TTVVideoDetailInteractModel

@end

@interface TTVVideoDetailHeaderPosterViewController () <UIGestureRecognizerDelegate ,TTVDetailPlayControlDelegate>

@property (nonatomic, strong) TTVideoShareMovie *shareMovie;

@property (nonatomic, strong) TTVideoDetailHeaderPosterView              *movieShotView;
@property (nonatomic, strong) UIView                              *moviewViewContainer;

@property (nonatomic, strong, nullable) TTVVideoDetailInteractModel *interactModel;

@property (nonatomic, copy) NSString *landingURL;
@property (nonatomic, assign) BOOL movieViewInitiated;

@property (nonatomic, assign) BOOL beginShowComment;

@property (nonatomic, strong) UIPanGestureRecognizer *movieContainerViewPanGes;
@property (nonatomic, strong) UIPanGestureRecognizer *commentTableViewPanGes;
@property (nonatomic, assign) BOOL didDisAppear;

- (void)vdvi_commentTableViewDidScroll:(UIScrollView *)scrollView;
- (void)vdvi_commentTableViewDidEndDragging:(UIScrollView *)scrollView;
- (void)vdvi_changeMovieSizeWithStatus:(TTVVideoDetailViewShowStatus)status;
- (BOOL)vdvi_shouldFiltered;
- (void)vdvi_trackWithLabel:(NSString *)label source:(NSString *)source groupId:(NSString *)groupId;

@end

@implementation TTVVideoDetailHeaderPosterViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initPlayControl];
        _interactModel = [[TTVVideoDetailInteractModel alloc] init];
    }
    return self;
}

- (void)setDoubleTap666Delegate:(id<TTVPlayerDoubleTap666Delegate>)doubleTap666Delegate {
    _doubleTap666Delegate = doubleTap666Delegate;
    self.playControl.doubleTap666Delegate = doubleTap666Delegate;
}

- (void)setVideoInfo:(id<TTVArticleProtocol>)videoInfo
{
    if (videoInfo != _videoInfo) {
        _videoInfo = videoInfo;
        _playControl.videoInfo = videoInfo;
        _playControl.enableTrackSDK = _detailModel.orderedData.trackSDK;
    }
}

- (void)setShareMovie:(TTVideoShareMovie *)shareMovie
{
    if (shareMovie != _shareMovie) {
        if ([shareMovie.movieView isKindOfClass:[TTVPlayVideo class]]) {
            TTVPlayVideo *movieView = (TTVPlayVideo *)shareMovie.movieView;
            if ([movieView isAdMovie] && movieView.playerModel.isAutoPlaying) {
                [self sendADEvent:@"detail_ad" label:@"detail_play" value:self.videoInfo.adModel.ad_id extra:nil logExtra:self.videoInfo.adModel.log_extra];
            }
        }
        
        [self.KVOController unobserve:_shareMovie];
        _shareMovie = shareMovie;
        @weakify(self);
        [self.KVOController observe:_shareMovie keyPath:@keypath(_shareMovie,movieView) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            @strongify(self);
            [self.whiteboard setValue:shareMovie forKey:@"movieView"];
        }];
    }
}
- (void)setWhiteboard:(TTVWhiteBoard *)whiteboard
{
    if (_whiteboard != whiteboard) {
        _whiteboard = whiteboard;
        [self.whiteboard setValue:self.playControl forKey:@"playControl"];
    }
}

- (void)setDetailStateStore:(TTVDetailStateStore *)detailStateStore
{
    if (_detailStateStore != detailStateStore) {
        _detailStateStore = detailStateStore;
        _playControl.detailStateStore = detailStateStore;
    }
}

- (void)setReloadVideoInfoFinished:(BOOL)reloadVideoInfoFinished
{
    _reloadVideoInfoFinished = reloadVideoInfoFinished;
    
    if (reloadVideoInfoFinished) {
        [self _install];
        [self.playControl playMovieIfNeededAndRebindToMovieShotView:NO];
        // TODOPY: informationResponse增加landing_page_url字段
        TTVVideoInformationResponse *videoInfoResponse = nil;
        if ([self.videoInfo isKindOfClass:[TTVVideoInformationResponse class]]) {
            videoInfoResponse = (TTVVideoInformationResponse *)self.videoInfo;
        }
        if (videoInfoResponse && videoInfoResponse.landingPageURL.length > 0 && [self.detailModel.articleExtraInfo.adID longLongValue] > 0) {
            self.landingURL = videoInfoResponse.landingPageURL;
            [self.playControl showDetailButtonIfNeeded];
        }
    }
}

- (void)setDetailModel:(TTDetailModel *)detailModel
{
    if (detailModel != _detailModel) {
        _detailModel = detailModel;
        self.beginShowComment = [detailModel.baseCondition tt_boolValueForKey:@"showcomment"];
        self.shareMovie = detailModel.baseCondition[@"movie_shareMovie"];
        if (!self.shareMovie) {
            self.shareMovie = [[TTVideoShareMovie alloc] init];
        }
        _playControl.shareMovie = self.shareMovie;
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.playControl viewDidLoad];

    self.moviewViewContainer = self.view;
    [self.moviewViewContainer addSubview:self.movieShotView];
    [self.whiteboard setValue:self.movieShotView forKey:@"movieShotView"];
    [self.whiteboard setValue:self.shareMovie.movieView forKey:@"movieView"];
    [self layoutMovieShotView];
    [self updateMovieShotView];
}

#pragma mark - TTVWhiteBoard methods

- (UIView *)topPGCView
{
    id value = [self.whiteboard valueForKey:@"topPGCView"];
    if ([value isKindOfClass:[UIView class]]) {
        return (UIView *)value;
    } else if([value isKindOfClass:[TTVVideoDetailNatantPGCViewController class]]){
        TTVVideoDetailNatantPGCViewController *tempPGCvc = (TTVVideoDetailNatantPGCViewController *)value;
        return tempPGCvc.view;
    }else{
        return nil;
    }
}

//- (TTVideoDetailFloatCommentViewController *)floatCommentVC
//{
//    id value = [self.whiteboard valueForKey:@"floatCommentVC"];
//    if ([value isKindOfClass:[TTVideoDetailFloatCommentViewController class]]) {
//        return (TTVideoDetailFloatCommentViewController *)value;
//    } else {
//        return nil;
//    }
//}

- (TTVDetailFollowRecommendViewController *)followRecommendVC{
    id value = [self.whiteboard valueForKey:@"followRecommendVC"];
    if ([value isKindOfClass:[TTVDetailFollowRecommendViewController class]]){
        return (TTVDetailFollowRecommendViewController *)value;
    }
    return nil;
}

- (TTVVideoDetailMovieBanner *)movieBanner
{
    id value = [self.whiteboard valueForKey:@"movieBanner"];
    if ([value isKindOfClass:[TTVVideoDetailMovieBanner class]]) {
        return (TTVVideoDetailMovieBanner *)value;
    } else {
        return nil;
    }
}

- (UIView *)topView
{
    id value = [self.whiteboard valueForKey:@"topView"];
    if ([value isKindOfClass:[UIView class]]) {
        return (UIView *)value;
    } else {
        return nil;
    }
}

- (UIView *)videoAlbum
{
    id value = [self.whiteboard valueForKey:@"videoAlbum"];
    if ([value isKindOfClass:[UIView class]]) {
        return (UIView *)value;
    } else {
        return nil;
    }
}

- (void)_invalideMovieViewWithFinishedBlock:(TTVStopFinished)finishedBlock
{
    [self.playControl invalideMovieViewWithFinishedBlock:finishedBlock];
}

#pragma mark -

- (void)_install
{
    [self layoutMovieShotView];
    [self updateMovieShotView];
    if (![self vdvi_shouldFiltered] && self.interactModel.minMovieH != self.interactModel.maxMovieH) {
        [self.moviewViewContainer addGestureRecognizer:self.movieContainerViewPanGes];
        [self.ttvContainerScrollView addGestureRecognizer:self.commentTableViewPanGes];
    }
}

- (void)updateMovieShotView
{
    [self.movieShotView refreshWithArticle:self.detailModel.protocoledArticle];
}

- (UIView *)movieView
{
    if ([self.shareMovie.movieView isKindOfClass:[UIView class]]) {
        return self.shareMovie.movieView;
    }
    return nil;
}


- (UIView<TTVideoDetailHeaderPosterViewProtocol> *)movieShotView
{
    return (TTVideoDetailHeaderPosterView *)self.shareMovie.posterView;
}


#pragma mark - Layout

- (void)layoutMovieShotView
{
    self.moviewViewContainer.frame = [self frameForMovieContainerView];
    self.movieShotView.frame = [self frameForMovieShotView];
    [self.movieShotView refreshUI];
    if (self.movieView.superview == self.movieShotView) {
        self.movieView.frame = self.movieView.superview.bounds;
    }
    if (self.movieBanner) {
        self.movieBanner.bottom = self.moviewViewContainer.bottom;
    }
    
    if ([TTDeviceHelper isPadDevice]) {
        self.topView.left = self.movieShotView.left;
        self.topView.top = self.movieShotView.top;
    }
}

#pragma mark - Layout frame

- (CGFloat)maxWidth
{
    if (_homeActionDelegate && [_homeActionDelegate respondsToSelector:@selector(maxWidth)]) {
        return [_homeActionDelegate maxWidth];
    }
    return self.view.superview.bounds.size.width;
}

- (CGRect)frameForMovieShotView
{
    CGFloat proportion = 9.f/16.f;
    CGSize videoAreaSize = [ExploreVideoDetailHelper videoAreaSizeForMaxWidth:[self maxWidth] areaAspect:proportion];
    BOOL result = [[[TTSettingsManager sharedManager] settingForKey:@"video_detail_flexbile_proportion_enabled" defaultValue:@NO freeze:NO] boolValue];
    if (result || [self.videoInfo isVideoSourceUGCVideoOrHuoShan]) {
        proportion = [self.videoInfo.detailVideoProportion floatValue];
        if (proportion > 0) {
            proportion = 1.f/proportion;
        }
        else
        {
            proportion = 9.f/16.f;
        }
        videoAreaSize = [ExploreVideoDetailHelper videoAreaSizeForMaxWidth:[self maxWidth] areaAspect:proportion];
        CGFloat maxHeight = ttvs_detailVideoMaxHeight();
        if (maxHeight > 0 && videoAreaSize.height > maxHeight){//如果视频高度大于允许的最大高度
            videoAreaSize.height = maxHeight;
        }
        self.interactModel.minMovieH = ceilf([self maxWidth] * 9.f / 16.f);
        self.interactModel.maxMovieH = videoAreaSize.height;
    } else {
        self.interactModel.minMovieH = ceilf([self maxWidth] * proportion);
        self.interactModel.maxMovieH = ceilf([self maxWidth] * proportion);
    }
    if ([TTDeviceHelper isPadDevice]) {
        videoAreaSize = [ExploreVideoDetailHelper videoAreaSizeForMaxWidth:[self maxWidth] areaAspect:proportion];
        CGFloat maxHeight = ttvs_detailVideoMaxHeight();
        if (maxHeight > 0 && videoAreaSize.height > maxHeight){//如果视频高度大于允许的最大高度
            videoAreaSize.height = maxHeight;
        }
        self.interactModel.minMovieH = videoAreaSize.height;
        self.interactModel.maxMovieH = videoAreaSize.height;
        self.interactModel.curMovieH = videoAreaSize.height;
    }
    if (!self.interactModel.curMovieH) {
        if (self.beginShowComment) { //点击评论按钮进入，默认显示16：9
            self.interactModel.curMovieH = self.interactModel.minMovieH;
        } else {
            self.interactModel.curMovieH = self.interactModel.maxMovieH;
        }
        if ([self vdvi_shouldFiltered]) { //默认16:9
            self.interactModel.curMovieH = self.interactModel.minMovieH;
        }
    }
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant) {
        return CGRectMake(([self maxWidth] - videoAreaSize.width)/2, 0, videoAreaSize.width, self.interactModel.curMovieH);
    } else {
        return CGRectMake(0, 0, videoAreaSize.width, self.interactModel.curMovieH);
    }
}

- (CGRect)frameForMovieView
{
    CGSize size = [self frameForMovieShotView].size;
    return CGRectMake(0, 0, size.width, size.height);
}

- (CGRect)frameForMovieContainerView
{
    CGFloat topMargin = [TTDeviceHelper isIPhoneXDevice] ? 44.0f : 0.0f;
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant) {
        return CGRectMake(0, topMargin, [self maxWidth], [self frameForMovieShotView].size.height);
    } else {
        CGRect frame = [self frameForMovieShotView];
        return CGRectMake(0, topMargin, frame.size.width, frame.size.height);
    }
}

#pragma mark - VerticalInteract

- (UIPanGestureRecognizer *)movieContainerViewPanGes {
    if (!_movieContainerViewPanGes) {
        _movieContainerViewPanGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_handleMovieContainerViewPanned:)];
        _movieContainerViewPanGes.delegate = self;
    }
    return _movieContainerViewPanGes;
}

- (UIPanGestureRecognizer *)commentTableViewPanGes
{
    if (!_commentTableViewPanGes) {
        _commentTableViewPanGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_handleCommentTableViewPanned:)];
        _commentTableViewPanGes.delegate = self;
    }
    return _commentTableViewPanGes;
}

- (void)vdvi_commentTableViewDidScroll:(UIScrollView *)scrollView {
    if ([self vdvi_shouldFiltered] || self.videoAlbum.superview ) {
        return;
    }
    if (self.interactModel.isDraggingCommentTableView) {
        if (self.moviewViewContainer.height != self.interactModel.minMovieH) {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        } else {
            self.interactModel.isDraggingCommentTableView = NO;
            self.interactModel.shouldSendCommentTrackLater = YES;
        }
    }
}

- (void)vdvi_commentTableViewDidEndDragging:(UIScrollView *)scrollView {
    if (!self.interactModel.shouldSendCommentTrackLater) {
        return;
    }
    self.interactModel.shouldSendCommentTrackLater = NO;
    if (self.ttvContainerScrollView.contentOffset.y > 0) {
        self.interactModel.curMovieH = self.interactModel.minMovieH;
        NSString *label = @"reduction";
        NSString *source = @"player_outside";
        [self vdvi_trackWithLabel:label source:source groupId:self.videoInfo.groupModel.groupID];
    }
}

- (void)vdvi_changeMovieSizeWithStatus:(TTVVideoDetailViewShowStatus)status {
    if ([self vdvi_shouldFiltered]) {
        return;
    }
    NSString *label = @"";
    CGRect frame = self.moviewViewContainer.frame;
    if (status == TTVVideoDetailViewShowStatusComment) { //收起视频
        label = @"reduction";
        frame.size.height = self.interactModel.minMovieH;
    } else {
        label = @"enlargement";
        frame.size.height = self.interactModel.maxMovieH;
    }
    [self vdvi_trackWithLabel:label source:@"comment_button" groupId:self.videoInfo.groupModel.groupID];
    [self p_executeAnimationWithFrame:frame];
}

- (BOOL)vdvi_shouldFiltered {
    //广告视频和iPad不会添加交互手势
    TTVVideoInformationResponse *videoInfoResponse = nil;
    if ([self.videoInfo isKindOfClass:[TTVVideoInformationResponse class]]) {
        videoInfoResponse = (TTVVideoInformationResponse *)self.videoInfo;
    }
    if ([TTDeviceHelper isPadDevice] || ([self.videoInfo.adModel isCreativeAd]) || videoInfoResponse.hasPartnerVideo || [TTDeviceHelper OSVersionNumber] < 8.0) {
        return YES;
    }
    return NO;
}

- (void)vdvi_trackWithLabel:(NSString *)label source:(NSString *)source groupId:(NSString *)groupId {
    NSMutableDictionary *extraDict = [[NSMutableDictionary alloc] init];
    [extraDict setValue:source forKey:@"action_type"];
    wrapperTrackEventWithCustomKeys(@"video_player", label, groupId, nil, extraDict);
}

- (void)p_handleMovieContainerViewPanned:(UIPanGestureRecognizer *)ges {
    [self p_handlePanGesture:ges inView:self.moviewViewContainer];
}

- (void)p_handleCommentTableViewPanned:(UIPanGestureRecognizer *)ges {
    [self p_handlePanGesture:ges inView:self.ttvContainerScrollView.superview];
}

- (void)p_handlePanGesture:(UIPanGestureRecognizer *)ges inView:(UIView *)view {
    if (self.detailStateStore.state.hasCommodity) {
        if (self.videoAlbum.superview) {
            self.detailStateStore.state.isChangingMovieSize = NO;
            return;
        }
    }else{
        if ((self.ttvContainerScrollView.contentOffset.y > kCommentVCTolerance && ges != self.movieContainerViewPanGes) || self.videoAlbum.superview) {
            self.detailStateStore.state.isChangingMovieSize = NO;
            return;
        }
    }
    CGPoint velocityPoint = [ges velocityInView:view];
    CGPoint locationPoint = [ges locationInView:view];
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (ges == self.movieContainerViewPanGes) {
                self.interactModel.isDraggingMovieContainerView = YES;
                self.interactModel.lastY = locationPoint.y;
            } else {
                self.interactModel.cLastY = locationPoint.y;
            }
            [self p_markIsDraggingWithGesture:ges velocityPoint:velocityPoint];
            self.detailStateStore.state.isChangingMovieSize = YES;
            if (self.followRecommendVC.backActionFired && self.followRecommendVC.recommendView.isSpread) {
                self.followRecommendVC.backActionFired(); //收起相关推荐浮层
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self p_markIsDraggingWithGesture:ges velocityPoint:velocityPoint];
            CGFloat step = 0;
            if (ges == self.movieContainerViewPanGes) {
                step = locationPoint.y - self.interactModel.lastY;
                self.interactModel.lastY = locationPoint.y;
            } else {
                step = locationPoint.y - self.interactModel.cLastY;
                self.interactModel.cLastY = locationPoint.y;
            }
            CGRect frame = self.moviewViewContainer.frame;
            frame.size.height += step;
            if (frame.size.height > self.interactModel.maxMovieH) {
                frame.size.height = self.interactModel.maxMovieH;
            }
            if (frame.size.height < self.interactModel.minMovieH) {
                frame.size.height = self.interactModel.minMovieH;
            }
            if (self.moviewViewContainer.height != frame.size.height) {
                [self.playControl setToolBarHidden:YES];
            }
            self.moviewViewContainer.frame = frame;
            self.movieShotView.frame = self.moviewViewContainer.bounds;
            if (self.detailStateStore.state.hasCommodity) {
                self.ttvContainerScrollView.top = self.moviewViewContainer.bottom;
            } else{
                if (self.topPGCView) {
                    self.topPGCView.top = self.moviewViewContainer.bottom;
                    self.ttvContainerScrollView.top = self.topPGCView.bottom;
                } else {
                    self.ttvContainerScrollView.top = self.moviewViewContainer.bottom;
                }
            }
            if ([self.homeActionDelegate respondsToSelector:@selector(adjustContainerScrollViewHeight)]) {
                [self.homeActionDelegate adjustContainerScrollViewHeight];
            }
        }
            
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGRect frame = self.moviewViewContainer.frame;
            frame.size.height = velocityPoint.y > 0 ? self.interactModel.maxMovieH : self.interactModel.minMovieH;
            BOOL shouldSendTrack = frame.size.height != self.interactModel.curMovieH;
            [self p_executeAnimationWithFrame:frame];
            if (ges == self.movieContainerViewPanGes) {
                self.interactModel.isDraggingMovieContainerView = NO;
            }
            if (ges == self.commentTableViewPanGes) {
                self.interactModel.isDraggingCommentTableView = NO;
            }
            if (shouldSendTrack) {
                NSString *label = velocityPoint.y > 0 ? @"enlargement" : @"reduction";
                NSString *source = ges == self.commentTableViewPanGes ? @"player_outside" : @"player_inside";
                [self vdvi_trackWithLabel:label source:source groupId:self.videoInfo.groupModel.groupID];
            }
            self.detailStateStore.state.isChangingMovieSize = NO;
        }
            break;
        default:
            break;
    }
}

- (void)p_markIsDraggingWithGesture:(UIPanGestureRecognizer *)ges velocityPoint:(CGPoint)velocityPoint {
    if (ges == self.commentTableViewPanGes && !self.interactModel.isDraggingCommentTableView) {
        //如果手势是向上滑动并且评论列表已经到顶部并且视频高度不是最小，则可以缩小视频
        if (velocityPoint.y < 0 && self.ttvContainerScrollView.contentOffset.y <= kCommentVCTolerance && self.moviewViewContainer.height != self.interactModel.minMovieH) {
            self.interactModel.isDraggingCommentTableView = YES;
        }
    }
}

- (void)p_changeMovieViewContainerFrame:(CGRect)frame {
    self.moviewViewContainer.frame = frame;
    self.movieShotView.frame = self.moviewViewContainer.bounds;
    if (self.movieView.superview == self.movieShotView) {
        self.movieView.frame = self.movieShotView.bounds;
    }
    if (self.detailStateStore.state.hasCommodity) {
        self.ttvContainerScrollView.top = self.moviewViewContainer.bottom;
    }else{
        self.topPGCView.top = self.moviewViewContainer.bottom;
        self.followRecommendVC.view.top = self.topPGCView.bottom;
        if (self.topPGCView) {
            self.ttvContainerScrollView.top = self.topPGCView.bottom;
        } else {
            self.ttvContainerScrollView.top = self.moviewViewContainer.bottom;
        }
    }

    if ([self.homeActionDelegate respondsToSelector:@selector(adjustContainerScrollViewHeight)]) {
        [self.homeActionDelegate adjustContainerScrollViewHeight];
    }
    [self.playControl updateFrame];
    if (self.movieBanner) {
        self.movieBanner.bottom = self.moviewViewContainer.bottom;
    }
}

- (void)p_executeAnimationWithFrame:(CGRect)frame {
    self.detailStateStore.state.forbidLayout = YES;
    [UIView animateWithDuration:kAnimDuration animations:^{
        [self p_changeMovieViewContainerFrame:frame];
    } completion:^(BOOL finished) {
        self.interactModel.curMovieH = frame.size.height;
        self.detailStateStore.state.forbidLayout = NO;
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.interactModel.isDraggingMovieContainerView && gestureRecognizer == self.commentTableViewPanGes) {
        return NO;
    }
    CGPoint velocityPoint = CGPointZero;
    if (gestureRecognizer == self.movieContainerViewPanGes) {
        velocityPoint = [self.movieContainerViewPanGes velocityInView:self.moviewViewContainer];
    } else if (gestureRecognizer == self.commentTableViewPanGes) {
        velocityPoint = [self.commentTableViewPanGes velocityInView:self.ttvContainerScrollView.superview];
    }
    BOOL isHorizontal = fabs(velocityPoint.x) > fabs(velocityPoint.y);
    if (isHorizontal) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.commentTableViewPanGes) {
        if (otherGestureRecognizer.view == self.ttvContainerScrollView) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

+ (NSString *)labelNameForShareActivityType:(TTActivityType)activityType
{
    return [TTVideoCommon videoListlabelNameForShareActivityType:activityType];
}

- (void)initPlayControl
{
    self.playControl = [[TTVDetailPlayControl alloc] init];
    self.playControl.viewController = self;
    self.playControl.delegate = self;
    self.playControl.doubleTap666Delegate = self.doubleTap666Delegate;
    self.playControl.shareMovie = _shareMovie;
    self.playControl.movieBanner = [self movieBanner];
}

- (CGRect)ttv_playerControlerMovieFrame
{
    return [self frameForMovieView];
}


- (void)ttv_playerControlerShowDetailButtonClicked
{
    if (!isEmptyString(self.landingURL) && (self.videoInfo.adModel.ad_id.length > 0)) {
        UINavigationController *vc = [TTUIResponderHelper topNavigationControllerFor: self];
        ssOpenWebView([TTStringHelper URLWithURLString:self.landingURL], nil, vc, NO, nil);
        [self sendADEvent:@"embeded_ad" label:@"ad_click" value:self.videoInfo.adModel.ad_id extra:nil logExtra:self.videoInfo.adModel.log_extra];
    }
}

- (void)sendADEvent:(NSString *)event label:(NSString *)label value:(NSString *)value extra:(NSDictionary *)extra logExtra:(NSString *)logExtra
{
    TTAdBaseModel *adBaseModel = [[TTAdBaseModel alloc] init];
    adBaseModel.ad_id = self.detailModel.articleExtraInfo.adIDStr;
    adBaseModel.log_extra = self.detailModel.articleExtraInfo.logExtra;
    if (!SSIsEmptyArray(self.detailModel.articleExtraInfo.adClickTrackURLs)) {
        [[SSURLTracker shareURLTracker] trackURLs:self.detailModel.articleExtraInfo.adClickTrackURLs model:adBaseModel];
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:event forKey:@"tag"];
    [dict setValue:label forKey:@"label"];
    [dict setValue:value forKey:@"value"];
    [dict setValue:logExtra forKey:@"log_extra"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    if (self.videoInfo.groupModel.groupID) {
        [dict setValue:self.videoInfo.groupModel.groupID forKey:@"ext_value"];
    }
    
    [dict setValue:@([TTTrackerProxy sharedProxy].connectionType) forKey:@"nt"];

    if (extra.count > 0) {
        [dict addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:dict];
}

- (BOOL)ttv_playerControlerShouldShowDetailButton
{
    if (!isEmptyString(self.landingURL)) {
        return YES;
    }
    return NO;
}

- (CGRect)ttv_playerControlerMovieViewFrameAfterExitFullscreen
{
    return [self frameForMovieView];
}

#pragma mark -
#pragma mark PlayControlDelegate

- (void)replayButtonClickedInTrafficView
{
    self.movieBanner.hidden = YES;
}


- (void)ttv_playerControlerShareButtonClicked
{
    if (self.toolbarActionDelegate && [self.toolbarActionDelegate respondsToSelector:@selector(_shareActionFired:)]) {
        [self.toolbarActionDelegate _videoPlayShareActionFired];
    }
}

- (void)ttv_playerFinishTipShareButtonClicked
{
    if (self.toolbarActionDelegate && [self.toolbarActionDelegate respondsToSelector:@selector(_shareActionFired:)]) {
        [self.toolbarActionDelegate _videoOverShareActionFired];
    }
}

- (void)ttv_playerFinishTipMoreButtonClicked
{
    if (self.toolbarActionDelegate && [self.toolbarActionDelegate respondsToSelector:@selector(_shareActionFired:)]) {
        [self.toolbarActionDelegate _videoOverMoreActionFired];
    }
}

- (void)ttv_playerControlerMoreButtonClicked:(BOOL)isFullScreen
{
    if (self.toolbarActionDelegate && [self.toolbarActionDelegate respondsToSelector:@selector(_shareActionFired:)]) {
        [self.toolbarActionDelegate _videoPlayMoreActionFired:isFullScreen];
    }
}

- (void)ttv_playerFinishTipDirectShareActionWithActivityType:(NSString *)activityType
{
    if (self.toolbarActionDelegate && [self.toolbarActionDelegate respondsToSelector:@selector(_videoOverDirectShareItemActionWithActivityType:)]) {
        [self.toolbarActionDelegate _videoOverDirectShareItemActionWithActivityType:activityType];
    }
}

- (void)ttv_playingShareViewDirectShareActionWithActivityType:(NSString *)activityType
{
    if (self.toolbarActionDelegate && [self.toolbarActionDelegate respondsToSelector:@selector(_videoPlayDirectShareItemActionWithActivityType:)]) {
        [self.toolbarActionDelegate _videoPlayDirectShareItemActionWithActivityType:activityType];
    }
}

- (BOOL)ttv_shouldAllocTipAdNewCreator
{
    return [self.detailModel.protocoledArticle isKindOfClass:[TTVFeedItem class]];
}

//- (void)didMoveToParentViewController:(UIViewController *)parent
//{
//    [super didMoveToParentViewController:parent];
//    if (parent) {
//        parent.ttDragToRoot = self.detailModel.ttDragToRoot;
//        //copy from TTDetailContainerViewController
//        //给视频详情页加一个inset，因为现在是错误提示都贴在最外层的VC上，视频详情页顶部有个播放器的placeholder所以会重叠 -- nick add 5.7
//        //hardcode一下
//        parent.ttContentInset = UIEdgeInsetsMake(220,0,0,0);
//    }
//}

- (void)themeChanged:(NSNotification *)notification
{
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.playControl) {
        [self initPlayControl];
        self.playControl.detailStateStore = self.detailStateStore;
        self.playControl.videoInfo = self.videoInfo;
    }
    [self.playControl viewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.playControl viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.playControl viewWillDisappear];
}

- (void)ttv_playerControlerPreVideoDidPlay
{

}


- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (BOOL)isFromVideoFloat
{
    return self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat || self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloatRelated;
}

- (void)pauseMovieIfNeeded
{
    [self.playControl pauseMovieIfNeeded];
}

- (void)playMovieIfNeeded
{
    [self.playControl playMovieIfNeeded];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (![self.homeActionDelegate respondsToSelector:@selector(shouldPauseMovieWhenVCDidDisappear)] || [self.homeActionDelegate shouldPauseMovieWhenVCDidDisappear]) {
        [self.playControl viewDidDisappear];
    }
    _didDisAppear = YES;
    
}


@end

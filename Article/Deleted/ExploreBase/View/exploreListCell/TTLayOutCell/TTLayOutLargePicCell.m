//
//  TTLayOutLargePicCell.m
//  Article
//
//  Created by 王双华 on 16/10/12.
//
//

#import "TTLayOutLargePicCell.h"
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
#import "ExploreOrderedData+TTAd.h"

#import "TTVideoAutoPlayManager.h"
#import "Article+TTADComputedProperties.h"

extern BOOL ttvs_isVideoFeedURLEnabled(void);

@interface TTLayOutLargePicCell()
@property (nonatomic, strong) TTLayOutLargePicCellView *largePicCellView;

@end
@implementation TTLayOutLargePicCell

+ (Class)cellViewClass
{
    return [TTLayOutLargePicCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    if (!_largePicCellView) {
        self.largePicCellView = [[TTLayOutLargePicCellView alloc] initWithFrame:self.bounds];
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

- (BOOL)isPlayingMovie
{
    return [_largePicCellView isPlayingMovie];
}

- (BOOL)isMovieFullScreen
{
    return [_largePicCellView isMovieFullScreen];
}

- (BOOL)hasMovieView {
    return [_largePicCellView hasMovieView];
}

- (ExploreMovieView *)movieView
{
    return [_largePicCellView movieView];
}

- (ExploreMovieView *)detachMovieView {
    return [_largePicCellView detachMovieView];
}

- (void)attachMovieView:(ExploreMovieView *)movieView {
    [_largePicCellView attachMovieView:movieView];
}

- (CGRect)logoViewFrame
{
    return [_largePicCellView logoViewFrame];
}

- (CGRect)movieViewFrameRect {
    return [self convertRect:[_largePicCellView movieViewFrameRect] fromView:_largePicCellView];
}

//- (UIView *)animationFromView
//{
//    return [_largePicCellView animationFromView];
//}
//
//- (UIImage *)animationFromImage
//{
//    return [_largePicCellView animationFromImage];
//}
@end

@interface TTLayOutLargePicCellView ()

@property (nonatomic, strong) ExploreMovieView          *movieView;         //列表页播放的视频
@property (nonatomic, strong) SSThemedButton            *playButton;        //播放按钮

@end

@implementation TTLayOutLargePicCellView

- (void)dealloc
{
    [self invalideMovieView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /** 图片上的播放按钮 */
        SSThemedButton *playButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.picView addSubview:playButton];
        self.playButton = playButton;
    }
    return self;
}

- (void)registerMovieViewNotification
{
    if (self.movieView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewPlayFinished:) name:kExploreMovieViewPlaybackFinishNotification object:self.movieView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreStopMovieViewPlaybackNotification object:self.movieView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlayWithoutRemoveMovieView:) name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:nil];
    }
}

- (void)removeMovieViewNotification
{
    if (self.movieView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreMovieViewPlaybackFinishNotification object:self.movieView];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreStopMovieViewPlaybackNotification object:self.movieView];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:self.movieView];
    }
}

- (void)invalideMovieView
{
    if (self.movieView) {
        [self.movieView exitFullScreenIfNeed:NO];
        [self.movieView stopMovie];
        [self.movieView removeFromSuperview];
        self.movieView = nil;
        [self bringAdButtonBackToCell];
    }
}

- (void)willDisplay {
    [super willAppear];
}

- (void)didEndDisplaying
{
    [super didDisappear];
    if (self.movieView && self.movieView.superview) {
        if (!self.movieView.isMovieFullScreen && !self.movieView.isRotateAnimating) {
            [self.movieView stopMovieAfterDelay];
            self.movieView.hidden = YES;
        }
    }
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    if (self.movieView && self.movieView.superview && ![self.movieView isAdMovie]) {
        if (!self.movieView.isMovieFullScreen && !self.movieView.isRotateAnimating) {
            [self.movieView stopMovieAfterDelay];
            self.movieView.hidden = YES;
        }
    }
}

#pragma mark -- notification

- (void)movieViewPlayFinished:(NSNotification *)notification
{
    if ([notification object] == self.movieView) {
        [self.movieView removeFromSuperview];
        self.movieView = nil;
        [self bringAdButtonBackToCell];
    }
}

- (void)stopMovieViewPlay:(NSNotification *)notification
{
    [self invalideMovieView];
}

- (void)stopMovieViewPlayWithoutRemoveMovieView:(NSNotification *)notification
{
    if (self.movieView) {
        [self.movieView exitFullScreenIfNeed:NO];
        [self.movieView pauseMovie];
    }
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
}

- (void)playButtonClicked
{
    Article *article = self.orderedData.article;
    
    ExploreMovieViewModel *movieViewModel = [ExploreMovieViewModel viewModelWithOrderData:self.orderedData];
    movieViewModel.type                   = ExploreMovieViewTypeList;
    movieViewModel.gdLabel                = nil;
    movieViewModel.videoPlayType          = TTVideoPlayTypeNormal ;
    //直播cell类型
    NSInteger videoType = 0;
    if ([[self.orderedData.article.videoDetailInfo allKeys] containsObject:@"video_type"]) {
        videoType = ((NSNumber *)[self.orderedData.article.videoDetailInfo objectForKey:@"video_type"]).integerValue;
    }
    if (videoType == 1 && (self.orderedData.videoStyle == ExploreOrderedDataVideoStyle1 ||
                           self.orderedData.videoStyle == ExploreOrderedDataVideoStyle2))
    {
        movieViewModel.videoPlayType  = TTVideoPlayTypeLive;
    }
    
    self.movieView = [[ExploreMovieView alloc] initWithFrame:self.picView.bounds
                                              movieViewModel:movieViewModel];
    //    self.movieView.moviePlayerController.shouldShowShareMore = YES;
    self.movieView.enableMultiResolution = YES;
    [self.picView addSubview:_movieView];
    [_movieView setLogoImageDict:self.orderedData.article.largeImageDict];
    [_movieView setVideoDuration:[self.orderedData.article.videoDuration doubleValue]];
    
    if ([[TTVideoAutoPlayManager sharedManager] dataIsAutoPlaying:self.orderedData]) {
        self.movieView.tracker.isAutoPlaying = YES;
    }
    
    self.movieViewDelegate = [[ExploreArticleMovieViewDelegate alloc] init];
    self.movieViewDelegate.orderedData = self.orderedData;
    self.movieViewDelegate.logo = self.picView;
    _movieView.movieViewDelegate = self.movieViewDelegate;
    
    [_movieView setVideoTitle:self.titleLabel.text fontSizeStyle:TTVideoTitleFontStyleNormal showInNonFullscreenMode:NO];
    
    ExploreVideoSP sp = ([self.orderedData.article.groupFlags longLongValue] & ArticleGroupFlagsDetailSP) > 0 ? ExploreVideoSPLeTV : ExploreVideoSPToutiao;
    //    [_movieView playVideoForVideoID:self.orderedData.article.videoID exploreVideoSP:sp videoPlayType:movieViewModel.videoPlayType];
    if (ttvs_isVideoFeedURLEnabled() && [article hasVideoPlayInfoUrl] && [article isVideoUrlValid]) {
        [_movieView playVideoWithVideoInfo:article.videoPlayInfo exploreVideoSP:sp videoPlayType:movieViewModel.videoPlayType];
    }
    else
    {
        [_movieView playVideoForVideoID:article.videoID exploreVideoSP:sp videoPlayType:movieViewModel.videoPlayType];
    }
    
    [self bringAdButtonBackToCell];
    
}

- (void)setMovieView:(ExploreMovieView *)movieView
{
    if (_movieView != movieView) {
        [self removeMovieViewNotification];
        _movieView = movieView;
        _movieView.tracker.type = ExploreMovieViewTypeList;
        [self registerMovieViewNotification];
        [_movieView unMarkAsDetail];
    }
}

#pragma mark - 3G下播放优化

- (BOOL)isPlayingMovie
{
    if (self.movieView && self.movieView.superview && [self.movieView isPlaying]) {
        return YES;
    }
    return NO;
}

- (BOOL)isMovieFullScreen
{
    if (self.movieView && self.movieView.superview && [self.movieView isMovieFullScreen]) {
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

- (ExploreMovieView *)detachMovieView {
    ExploreMovieView *movieView = self.movieView;
    [self.movieView removeFromSuperview];
    self.movieView = nil;
    [self bringAdButtonBackToCell];
    return movieView;
}

- (void)attachMovieView:(ExploreMovieView *)movieView {
    if (movieView) {
        self.movieView = movieView;
        //为修复详情页返回时movieView会突然跳动，把添加movieView放到另一个runloop
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.picView addSubview:movieView];
            [self.picView bringSubviewToFront:movieView];
            [self bringAdButtonToMovie];
            movieView.frame = self.picView.bounds;
            movieView.movieViewDelegate = self.movieViewDelegate;
        });
    }
}

- (void)bringAdButtonToMovie
{
    if (self.orderedData.article.adModel && self.adButton) {
        UIView *toolBar = [self.movieView.moviePlayerController.controlView toolBar];
        [self.movieView.moviePlayerController.controlView insertSubview:self.adButton belowSubview:toolBar];
    }
}

- (CGRect)logoViewFrame
{
    return self.picView.frame;
}

- (CGRect)movieViewFrameRect {
    return [self convertRect:self.picView.bounds fromView:self.picView];
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

//- (UIView *)animationFromView
//{
//    return self.picView;
//}
//
//- (UIImage *)animationFromImage
//{
//    return [self.picView animationFromView].imageView.image;
//}
@end

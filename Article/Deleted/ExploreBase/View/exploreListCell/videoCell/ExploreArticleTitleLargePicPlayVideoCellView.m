//
//  ExploreArticleTitleLargePicPlayVideoCellView.m
//  Article
//
//  Created by Zhang Leonardo on 15-3-16.
//
//

#import "ExploreArticleTitleLargePicPlayVideoCellView.h"
#import "TTImageView.h"
#import "Article.h"
#import "Article+TTADComputedProperties.h"
#import "ExploreArticleMovieViewDelegate.h"
#import "ExploreArticleCellViewConsts.h"

#import "TTVideoAutoPlayManager.h"

#import "TTVideoEmbededAdButton.h"
#import "ExploreArticleTitleLargePicPlayVideoLiveCellView.h"
#import "TTDeviceUIUtils.h"
#import "UIImage+TTThemeExtension.h"
#import "TTAudioSessionManager.h"
#import "TTLayOutCellDataHelper.h"
#import "SSURLTracker.h"

#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
#import "ExploreMovieView.h"

//#define KLabelInfoHeight 20
//#define kVideoIconLeftGap 6

#define kDurationRightPadding 5
#define kDurationBottomPadding 3

extern BOOL ttvs_isVideoFeedURLEnabled(void);

@interface ExploreArticleTitleLargePicPlayVideoCellView()

@property (nonatomic, strong) ExploreArticleMovieViewDelegate *movieViewDelegate;
@property (nonatomic, strong) SSThemedImageView      *videoIconView;
@property (nonatomic, strong) SSThemedLabel          *videoDurationLabel;
@property (nonatomic, strong) ExploreMovieView       *movieView;
@property (nonatomic, strong) TTVideoEmbededAdButton *adButton;
@property (nonatomic, strong) SSThemedLabel          *adSubtitleLabel;
@property (nonatomic, strong) ExploreActionButton    *adActionButton;
@end

@implementation ExploreArticleTitleLargePicPlayVideoCellView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self invalideMovieView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (TTVideoEmbededAdButton *)adButton
{
    if (!_adButton && self.orderedData.adModel) {
        _adButton = [[TTVideoEmbededAdButton alloc] init];
    }
    _adButton.actionModel = self.orderedData;
   // _adButton.adModel = self.orderedData.adModel;
    
    return _adButton;
}

- (SSThemedLabel *)adSubtitleLabel
{
    if (!_adSubtitleLabel) {
        _adSubtitleLabel = [[SSThemedLabel alloc] init];
        _adSubtitleLabel.textAlignment = NSTextAlignmentLeft;
        _adSubtitleLabel.numberOfLines = 1;
        _adSubtitleLabel.font = [UIFont systemFontOfSize:14.f];
        _adSubtitleLabel.textColorThemeKey = kColorText2;
        [self.adInfoBgView addSubview:_adSubtitleLabel];
    }
    return _adSubtitleLabel;
}

- (ExploreActionButton *)adActionButton
{
    if (!_adActionButton) {
        _adActionButton = [[ExploreActionButton alloc] init];
        _adActionButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _adActionButton.layer.cornerRadius = 6;
        _adActionButton.layer.borderWidth = 1;
        _adActionButton.borderColorThemeKey = kColorLine3;
        _adActionButton.backgroundColorThemeKey = kColorBackground3;
        _adActionButton.clipsToBounds = YES;
        _adActionButton.titleColorThemeKey = kColorText6;
        [_adActionButton addTarget:self action:@selector(_adActionButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.adInfoBgView addSubview:_adActionButton];
    }
    return _adActionButton;
}

- (void)refreshWithData:(id)data
{
    [super refreshWithData:data];
    self.picView.hiddenMessage = YES;
    
    if (!_timeInfoBgView) {
        self.timeInfoBgView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        UIImage * image = [UIImage themedImageNamed:@"message_background_view"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2, image.size.width / 2, image.size.height / 2 - 1, image.size.width / 2 - 1) resizingMode:UIImageResizingModeTile];
        _timeInfoBgView.image = image;
        _timeInfoBgView.frame = CGRectMake(0, 0, 0, kCellPicLabelHeight);
        [self.picView addSubview:_timeInfoBgView];
    }
    
    if (!_videoIconView) {
        self.videoIconView = [[SSThemedImageView alloc] initWithImage:[UIImage themedImageNamed:@"palyicon_video_textpage.png"]];
        _videoIconView.imageName = @"palyicon_video_textpage.png";
        [self.timeInfoBgView addSubview:_videoIconView];
    }
    if (!_videoDurationLabel) {
        self.videoDurationLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _videoDurationLabel.backgroundColor = [UIColor clearColor];
        _videoDurationLabel.textColorThemeKey = kCellPicLabelTextColor;
        _videoDurationLabel.font = [UIFont systemFontOfSize:kCellPicLabelFontSize];
        [self.timeInfoBgView addSubview:_videoDurationLabel];
    }
    
    
    if (self.orderedData.adModel) {
        if ([self.orderedData isAdButtonUnderPic]) {
            [self.adButton removeFromSuperview];
            self.adButton.hidden = YES;
            //self.adActionButton.adModel = self.orderedData.adModel;
            self.adActionButton.actionModel = self.orderedData;
            [self.adSubtitleLabel setText:[TTLayOutCellDataHelper getSubtitleStringWithOrderedData:self.orderedData]];
            [self.adSubtitleLabel sizeToFit];
        }
        else {
            [self bringAdButtonBackToCell];
            self.adButton.hidden = NO;
        }
    } else {
        [self.adButton removeFromSuperview];
        self.adButton.hidden = YES;
    }
    
    long long duration = [self.orderedData.article.videoDuration longLongValue];
    
    if (duration > 0) {
        int minute = (int)duration / 60;
        int second = (int)duration % 60;
        [_videoDurationLabel setText:[NSString stringWithFormat:@"%02i:%02i", minute, second]];
    }
    else {
        [_videoDurationLabel setText:@""];
    }
    [_videoDurationLabel sizeToFit];
    _videoDurationLabel.frame = CGRectIntegral(_videoDurationLabel.frame);
    
    if ([self.orderedData isListShowPlayVideoButton]) {
        if (!_playButton) {
            self.playButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
            _playButton.imageName = [TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play";
            //_playButton.frame = CGRectMake(0, 0, 70, 70);
            //_playButton.imageView.contentMode = UIViewContentModeCenter;
            [_playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.picView addSubview:_playButton];
        }
        _playButton.hidden = NO;
    }
    else {
        _playButton.hidden = YES;
    }
    
    _playButton.userInteractionEnabled = ![self.orderedData isPlayInDetailView];
}

- (void)bringAdButtonToMovie
{
    if (self.orderedData.adModel && self.adButton) {
        UIView *toolBar = [self.movieView.moviePlayerController.controlView toolBar];
        [self.movieView.moviePlayerController.controlView insertSubview:self.adButton belowSubview:toolBar];
    }
}

- (void)bringAdButtonBackToCell
{
    if (self.orderedData.adModel && self.adButton) {
        [self.picView addSubview:self.adButton];
    }
    self.adButton.right = self.picView.width - [TTDeviceUIUtils tt_padding:kCellPicLabelHorizontalPadding];
    self.adButton.bottom = self.picView.height - [TTDeviceUIUtils tt_padding:kCellPicLabelHorizontalPadding];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
}

- (void)refreshUI
{
    [super refreshUI];
    
    if (!isEmptyString(_videoDurationLabel.text)) {
        _timeInfoBgView.hidden = NO;
        BOOL isListPlay = [self.orderedData isListShowPlayVideoButton];
        
        CGFloat width = kCellPicLabelHorizontalPadding * 2 + _videoDurationLabel.width + (isListPlay ? 0 : kCellPicLabelPlayAndTimePadding + _videoIconView.width);
        _timeInfoBgView.frame = CGRectMake(self.picView.width - width - kCellPicLabelRightPadding, self.picView.height - kCellPicLabelHeight - kCellPicLabelBottomPadding, width, kCellPicLabelHeight);
        _videoDurationLabel.hidden = NO;
        
        if (isListPlay) {
            _timeInfoBgView.frame = CGRectMake(self.picView.width - kCellPicLabelWidth - kCellPicLabelRightPadding, self.picView.height - kCellPicLabelHeight - kCellPicLabelBottomPadding, kCellPicLabelWidth, kCellPicLabelHeight);
            _videoIconView.hidden = YES;
            _videoDurationLabel.center = CGPointMake(_timeInfoBgView.width / 2, _timeInfoBgView.height / 2);
        } else {
            _videoIconView.hidden = NO;
            _videoIconView.left = kCellPicLabelHorizontalPadding;
            _videoIconView.centerY = _timeInfoBgView.height / 2;
            _videoDurationLabel.left = _videoIconView.right + kCellPicLabelPlayAndTimePadding;
            _videoDurationLabel.centerY = _timeInfoBgView.height / 2;
        }
    }
    else {
        if (![self.orderedData isListShowPlayVideoButton]) {
            _timeInfoBgView.hidden = NO;
            _timeInfoBgView.frame = CGRectMake(self.picView.width - kCellPicLabelWidth - kCellPicLabelRightPadding, self.picView.height - kCellPicLabelHeight - kCellPicLabelBottomPadding, kCellPicLabelWidth, kCellPicLabelHeight);
            _videoDurationLabel.hidden = YES;
            _videoIconView.hidden = NO;
            _videoIconView.center = CGPointMake(_timeInfoBgView.width / 2, _timeInfoBgView.height / 2);
        } else {
            _timeInfoBgView.hidden = YES;
        }
    }
    
    if (self.orderedData.adModel) {
        if ([self.orderedData isAdButtonUnderPic]) {
            
            self.timeInfoBgView.right = self.picView.width - [TTDeviceUIUtils tt_padding:kCellPicLabelHorizontalPadding];
            self.timeInfoBgView.bottom = self.picView.height - [TTDeviceUIUtils tt_padding:kCellPicLabelHorizontalPadding];
            
            const CGFloat containWidth = SSWidth(self.picView);
            const CGFloat containHeight = 48;
            const CGFloat space = 8.0f;
            const CGFloat actionButtonWidth = 72.0f;
            const CGFloat subtitleWidth = containWidth - space * 2 - actionButtonWidth - 20;
            
            self.adInfoBgView.frame = CGRectMake(self.picView.left, self.picView.bottom - [TTDeviceHelper ssOnePixel], containWidth, containHeight);
            self.adSubtitleLabel.frame = CGRectMake(space, 0, subtitleWidth, containHeight);
            self.adSubtitleLabel.centerY = SSHeight(self.adInfoBgView) / 2;
            self.adActionButton.frame = CGRectMake(0, 0, actionButtonWidth, 28);
            self.adActionButton.right = containWidth - space;
            self.adActionButton.centerY = self.adSubtitleLabel.centerY;
            
            self.adButton.hidden = YES;
        }
        else {
            self.adButton.right = self.picView.width - [TTDeviceUIUtils tt_padding:kCellPicLabelHorizontalPadding];
            self.adButton.bottom = self.picView.height - [TTDeviceUIUtils tt_padding:kCellPicLabelHorizontalPadding];
            self.timeInfoBgView.right = self.adButton.left - [TTDeviceUIUtils tt_padding:kCellPicLabelHorizontalPadding];
            self.timeInfoBgView.height = self.adButton.height;
            self.timeInfoBgView.centerY = self.adButton.centerY;
            self.adButton.hidden = NO;
        }
        //解决adbutton在不同设备上做了适配，导致timeInfoBgView的高度变化，里面布局没有相应调整
        _videoIconView.centerY = SSHeight(_timeInfoBgView) / 2.0;
        _videoDurationLabel.centerY = SSHeight(_timeInfoBgView) / 2.0;
    }

    _playButton.frame = self.picView.bounds;
    //解决视频广告，显示时间的bg view的圆角不正确的问题
//    self.timeInfoBgView.layer.cornerRadius = self.timeInfoBgView.height / 2.0; 
}

- (void)playButtonClicked
{
    Article *article = self.orderedData.article;

    ExploreMovieViewModel *movieViewModel = [ExploreMovieViewModel viewModelWithOrderData:self.orderedData];
    movieViewModel.type                   = ExploreMovieViewTypeList;
    movieViewModel.gdLabel                = nil;
    movieViewModel.videoPlayType          = TTVideoPlayTypeNormal ;
    
    //直播cell类型
    if ([self isKindOfClass:[ExploreArticleTitleLargePicPlayVideoLiveCellView class]]) {
        movieViewModel.videoPlayType  = TTVideoPlayTypeLive;
    }
    
    self.movieView = [[ExploreMovieView alloc] initWithFrame:self.picView.bounds
                                              movieViewModel:movieViewModel];
    self.movieView.enableMultiResolution = YES;
    [self.picView addSubview:_movieView];
    [_movieView setLogoImageDict:self.orderedData.listLargeImageDict];
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
    [self addMovieTrackerEvent3Data];
    if (ttvs_isVideoFeedURLEnabled() && [article hasVideoPlayInfoUrl] && [article isVideoUrlValid]) {
        [self.movieView playVideoWithVideoInfo:article.videoPlayInfo exploreVideoSP:sp videoPlayType:movieViewModel.videoPlayType];
    }
    else
    {
        [self.movieView playVideoForVideoID:article.videoID exploreVideoSP:sp videoPlayType:movieViewModel.videoPlayType];
    }
    [self bringAdButtonBackToCell];
    
}

- (void)_adActionButtonFired:(id)sender
{
    if ([self.movieView.moviePlayerController isMovieFullScreen]) {
        [self.movieView exitFullScreen:YES completion:^(BOOL finished) {
            [self _adActionButtonFired:sender];
        }];
        return;
    }
    
    id<TTAdFeedModel> adModel = self.orderedData.adModel;
    switch (adModel.adType) {
        case ExploreActionTypeApp:
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.adActionButton.actionModel label:@"click_start" eventName:@"feed_download_ad" clickTrackUrl:NO];
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.adActionButton.actionModel label:@"click" eventName:@"feed_download_ad"];
            break;
        case ExploreActionTypeAction:
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.adActionButton.actionModel label:@"click_call" eventName:@"feed_call" clickTrackUrl:NO];
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.adActionButton.actionModel label:@"click" eventName:@"feed_call"];
            [self listenCall:adModel];
            break;
        case ExploreActionTypeWeb:
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.adActionButton.actionModel label:@"ad_click" eventName:@"embeded_ad" clickTrackUrl:NO];
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.adActionButton.actionModel label:@"click" eventName:@"embeded_ad"];
            break;
        default:
            break;
    }
    [self.adActionButton actionButtonClicked:sender showAlert:NO];
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


- (void)registerMovieViewNotification
{
    if (_movieView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewPlayFinished:) name:kExploreMovieViewPlaybackFinishNotification object:_movieView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreStopMovieViewPlaybackNotification object:_movieView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlayWithoutRemoveMovieView:) name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:nil];
    }
}

- (void)removeMovieViewNotification
{
    if (_movieView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreMovieViewPlaybackFinishNotification object:_movieView];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreStopMovieViewPlaybackNotification object:_movieView];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:_movieView];
    }
}

- (void)setMovieView:(ExploreMovieView *)movieView
{
    if (_movieView != movieView) {
        [self removeMovieViewNotification];
        _movieView = movieView;
        _movieView.tracker.type = ExploreMovieViewTypeList;
        [self registerMovieViewNotification];
    }
}

- (void)invalideMovieView
{
    if (_movieView) {
        [_movieView exitFullScreenIfNeed:NO];
        [_movieView stopMovie];
        [_movieView removeFromSuperview];
        self.movieView = nil;
        [self bringAdButtonBackToCell];
    }
}

- (void)didEndDisplaying
{
    if (_movieView && _movieView.superview) {
        if (!_movieView.isMovieFullScreen && !_movieView.isRotateAnimating) {
            [_movieView stopMovieAfterDelay];
            self.movieView.hidden = YES;
        }
    }
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    if (_movieView && _movieView.superview && ![_movieView isAdMovie]) {
        [_movieView stopMovieAfterDelay];
        self.movieView.hidden = YES;
    }
}

- (CGFloat)rightCornerLabelFontSize
{
    return 10;
}

#pragma mark -- notification

- (void)movieViewPlayFinished:(NSNotification *)notification
{
    if ([notification object] == self.movieView) {
        [_movieView removeFromSuperview];
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
    if (_movieView) {
        [_movieView exitFullScreenIfNeed:NO];
        [_movieView pauseMovie];
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
//        [movieView stopMovie];
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

- (CGRect)logoViewFrame
{
    return self.picView.frame;
}

- (CGRect)movieViewFrameRect {
    return [self convertRect:self.picView.bounds fromView:self.picView];
}

- (ExploreCellStyle)cellStyle {
    return ExploreCellStyleVideo;
}

- (ExploreCellSubStyle)cellSubStyle {
    if ([self.orderedData isPlayInDetailView]) {
        return ExploreCellSubStyleVideoNotPlayableInList;
    }
    else {
        return ExploreCellSubStyleVideoPlayableInList;
    }
}

- (UIView *)animationFromView
{
    return self.picView;
}

- (UIImage *)animationFromImage
{
    return [self.picView animationFromView].imageView.image;
}

#pragma mark - 埋点3.0

- (void)addMovieTrackerEvent3Data{
    [self.movieView.tracker addExtraValue:self.orderedData.article.itemID forKey:@"item_id"];
    [self.movieView.tracker addExtraValue:[self.orderedData uniqueID] forKey:@"group_id"];
    [self.movieView.tracker addExtraValue:self.orderedData.article.aggrType forKey:@"aggr_type"];
    //self.detailModel.gdExtJsonDict
    [self.movieView.tracker addExtraValue:self.orderedData.logPb forKey:@"log_pb"];
    [self.movieView.tracker addExtraValue:self.orderedData.article.videoID forKey: @"video_id"];
 
}

@end

//
//  ExploreDetailMixedVideoADView.m
//  Article
//
//  Created by huic on 16/5/3.
//
//

#import "ExploreDetailMixedVideoADView.h"
#import "TTLabelTextHelper.h"
#import "TTDeviceUIUtils.h"
#import "TTAdDetailViewHelper.h"
#import "ExploreArticleMovieViewDelegate.h"
#import "TTAdAppointAlertView.h"
#import "TTVPlayerUrlTracker.h"
#import "TTVDemanderTrackerManager.h"
#import "ExploreMovieView.h"
#import "TTVDataPlayerTracker.h"
#import "TTVPlayerTrackerV3.h"
#import "TTVDemanderPlayerTracker.h"
#import "TTVDetailNatantADPlayerTracker.h"

#define kTopMaskH 80
#define kTitleTopPadding 11.5  //减去安全距离
#define kTitleHorizonPadding 12
#define kAppHorizonPadding 12
#define kAppHeight 44
#define kMoreInfoHeight 44
#define kMoreInfoLabelWidth 72
#define kMoreInfoLabelHeight 28

const CGFloat kTitleFontSpace = 1.4f;

inline CGFloat videoFitHeight(ArticleDetailADModel *adModel, CGFloat width) {
    CGFloat aspect = (adModel.videoInfo.videoHeight == 0) ? 0 : adModel.videoInfo.videoWidth / adModel.videoInfo.videoHeight;
    CGFloat imageHeight = (aspect == 0) ? 0 : width / aspect;
    imageHeight = ceilf(imageHeight);
    return imageHeight;
}

@interface ExploreDetailMixedVideoADView() <TTVBaseDemandPlayerDelegate>

//用来控制自动播放逻辑，在同一次show中只播放一次
@property(nonatomic, assign, nonatomic) BOOL isPlayFinished;

@property(nonatomic, strong)TTVDataPlayerTracker *dataTracker;
@property(nonatomic, strong)TTVDemanderPlayerTracker *commonTracker;
@property(nonatomic, strong)TTVPlayerTrackerV3 *logV3;
@property(nonatomic, strong)TTVDetailNatantADPlayerTracker *adTracker;

@end

@interface ExploreDetailBaseADView ()
//expose super method
- (void)bgButtonPressed:(id)sender;

@end

@implementation ExploreDetailMixedVideoADView

+ (void)load
{
    [TTAdDetailViewHelper registerViewClass:self withKey:@"mixed_video" forArea:TTAdDetailViewAreaGloabl];
    [TTAdDetailViewHelper registerViewClass:self withKey:@"mixed_video" forArea:TTAdDetailViewAreaVideo];
}

- (void)dealloc
{
    [self invalideMovieView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseMovie) name:kDetailVideoADDisappearNotification object:nil];
        _dataTracker = [[TTVDataPlayerTracker alloc] init];
        _commonTracker = [[TTVDemanderPlayerTracker alloc] init];
        _logV3 = [[TTVPlayerTrackerV3 alloc] init];

        [self buildView];
    }
    return self;
}


- (void)buildView
{
    [self addSubview:self.logo];
    [self.logo addSubview:self.topMaskView];
    [self.logo addSubview:self.titleLabel];
    [self.logo addSubview:self.playButton];
    [self.logo addSubview:self.videoDurationLabel];
    [self.logo addSubview:self.adLabel];
    [self addSubview:self.moreInfoButton];
    [self addSubview:self.sourceLabel];
    [self addSubview:self.moreInfoLabel];
    [self addSubview:self.bottomLine];
}

- (void)playVideoADInDetail {
    if ([self.delegate respondsToSelector:@selector(detailBaseADView:playInDetailWithModel:withProcess:)]) {
        CGFloat video_progress = 0;
        if (self.movieView && self.movieView.player.context.playPercent) {
            video_progress = (CGFloat)self.movieView.player.context.playPercent / 100;
        }
        //和之前的点击事件保持一致
        [self sendClickVideoTrack];
        [self.delegate detailBaseADView:self playInDetailWithModel:self.adModel withProcess:video_progress];
    }
}

- (void)bgButtonPressed:(id)sender {
    if (self.adModel.isVideoPlayInDetail) {
        [self playVideoADInDetail];
    } else {
        [super bgButtonPressed:sender];
    }
}

#pragma mark - refresh
- (void)setAdModel:(ArticleDetailADModel *)adModel {

    [super setAdModel:adModel];
    
    self.playButton.hidden = NO;
    
    [self.logo setImageWithURLString:adModel.videoInfo.coverURL];
    
    CGFloat imageHeight = videoFitHeight(adModel, self.width);
    self.logo.size = CGSizeMake(self.width, imageHeight);
    
    if (imageHeight > 0) {
        self.bottomLine.hidden = NO;
        self.bottomLine.origin = CGPointMake(0, imageHeight);
    } else {
        self.bottomLine.hidden = YES;
    }
    
//    self.titleLabel.text = adModel.titleString;
    self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:adModel.titleString fontSize:kDetailAdTitleFontSize lineHeight:kDetailAdTitleLineHeight];
    self.titleLabel.height = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:kDetailAdTitleFontSize forWidth:self.logo.width - 2 * kTitleHorizonPadding forLineHeight:kDetailAdTitleLineHeight constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    
    long long duration = self.adModel.videoInfo.videoDuration;
    if (duration > 0) {
        int minute = (int)duration / 60;
        int second = (int)duration % 60;
        [_videoDurationLabel setText:[NSString stringWithFormat:@"%02i:%02i", minute, second]];
        _videoDurationLabel.hidden = NO;
    }
    else {
        [_videoDurationLabel setText:@""];
        _videoDurationLabel.hidden = YES;
    }
    [_videoDurationLabel sizeToFit];
    _videoDurationLabel.size = CGSizeMake(_videoDurationLabel.width + 16.0, 20);
    _videoDurationLabel.layer.cornerRadius = _videoDurationLabel.height * 0.5;
    
    _sourceLabel.text = adModel.sourceString;
    NSString *buttonText = isEmptyString(adModel.buttonText) ? NSLocalizedString(@"查看详情", @"查看详情") : adModel.buttonText;
    [_moreInfoLabel setTitle:buttonText forState:UIControlStateNormal];
    if (adModel.isVideoPlayInDetail) {
        self.playButton.userInteractionEnabled = NO;
        self.logo.userInteractionEnabled = NO;
    }
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    
    [self layout];
}

- (void)layout
{
    //布局影片封面图片
    self.logo.origin = CGPointZero;
    
    //布局标题下方黑色渐变遮罩
    self.topMaskView.frame = CGRectMake(0, 0, self.logo.width, kTopMaskH);
    //没有title时，无遮罩
    if (isEmptyString(self.titleLabel.text)) {
        self.topMaskView.hidden = YES;
    } else {
        self.topMaskView.hidden = NO;
    }
    
    
    //布局标题
    self.titleLabel.width = self.logo.width - 2 * kTitleHorizonPadding;
    self.titleLabel.origin = CGPointMake(kTitleHorizonPadding, kTitleTopPadding);
    
    //布局播放按钮，覆盖除标题外全部封面
    //播放按钮相对于封面图片居中
    self.playButton.frame = CGRectMake(0, self.titleLabel.bottom, self.logo.width, self.logo.height - self.titleLabel.bottom);
    self.playButton.imageEdgeInsets = UIEdgeInsetsMake(-self.titleLabel.bottom, 0, 0, 0);
    
    //布局时长标签
    self.videoDurationLabel.right = self.logo.width - 6;
    self.videoDurationLabel.bottom = self.logo.height - 6;
    
    //布局推广标签
    self.adLabel.left = 6;
    self.adLabel.bottom = self.logo.height - 6;
    
    self.moreInfoButton.frame = CGRectMake(0, self.logo.bottom, self.width, kMoreInfoHeight);
    self.moreInfoLabel.size = CGSizeMake(kMoreInfoLabelWidth, kMoreInfoLabelHeight);
    self.moreInfoLabel.centerY = self.moreInfoButton.centerY;
    self.moreInfoLabel.right = self.width - 8;
    
    [self.sourceLabel sizeToFit];
    CGFloat soureMaxWidth = self.logo.width - kTitleHorizonPadding * 2 - 5 - kMoreInfoLabelWidth;
    self.sourceLabel.left = kTitleHorizonPadding;
    self.sourceLabel.width = soureMaxWidth;
    self.sourceLabel.centerY = self.moreInfoButton.centerY;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat imageHeight = videoFitHeight(adModel, width);
    imageHeight += kMoreInfoHeight;
    return imageHeight;
}


#pragma mark - response

- (void)playButtonClicked:(id)sender
{
    [ExploreMovieView removeAllExploreMovieView];
    TTVBasePlayerModel *movieViewModel = [[TTVBasePlayerModel alloc] init];
    movieViewModel.adID                    = [NSString stringWithFormat:@"%lld", self.adModel.ad_id.longLongValue];
    movieViewModel.logExtra               = self.adModel.log_extra;
    movieViewModel.enableResolution       = YES;
    movieViewModel.videoID                = self.adModel.videoInfo.videoID;
    movieViewModel.sp                     = TTVPlayerSPToutiao;
    movieViewModel.groupID                = self.adModel.groupId;
    //    movieViewModel.enableCommonTracker    = YES;
//    movieViewModel.videoPlayInfo = self.adModel.videoInfo;
    
    self.movieView = [[TTVBasePlayVideo alloc] initWithFrame:self.logo.bounds playerModel:movieViewModel];
    [self addSubview:_movieView];

    self.movieView.player.isInDetail = YES;
    self.movieView.player.enableRotate = YES;
    [self configTrackers];
    [self.movieView.player readyToPlay];
    [self addUrlTracker];
    [self.movieView.player play];
    self.movieView.player.showTitleInNonFullscreen = YES;
    [self.movieView.player setVideoTitle:self.titleLabel.text];
    [self.movieView.player setLogoImageView:[self coverImageViewWithUrl:self.adModel.videoInfo.coverURL]];
    self.movieView.player.delegate = self;
    
    if (self.adModel.isVideoPlayInDetail) {
        self.movieView.userInteractionEnabled = NO;
    }
    if (sender) {
        //只有当手动点击播放时才发click事件
        [self sendClickVideoTrack];
    } else {
        //自动播放默认静音
        movieViewModel.showMutedView = YES;
        [self.movieView.player setMuted:YES];
    }
}

- (void)configTrackers
{
    //adTracker懒加载防治第一次出师化时不够及时
    [self configureTracker:self.adTracker];
//    baseplayer里面自带一个commonTracker。。。
//    [self configureTracker:_commonTracker];
    [self configureTracker:_dataTracker];
    [self configureTracker:_logV3];
}

- (void)configureTracker:(TTVPlayerTracker *)tracker
{
    tracker.trackLabel = self.movieView.playerModel.trackLabel;
    tracker.itemID = self.movieView.playerModel.itemID;
    tracker.groupID = self.movieView.playerModel.groupID;
    tracker.aggrType = self.movieView.playerModel.aggrType;
    tracker.adID = self.movieView.playerModel.adID;
    tracker.logExtra = self.movieView.playerModel.logExtra;
    tracker.categoryID = self.movieView.playerModel.categoryID;
    tracker.videoSubjectID = self.movieView.playerModel.videoSubjectID;
    tracker.logPb = self.movieView.playerModel.logPb;
    tracker.enterFrom = self.movieView.playerModel.enterFrom;
    tracker.categoryName = self.movieView.playerModel.categoryName;
    tracker.authorId = self.movieView.playerModel.authorId;
    [self.movieView.player registerPart:tracker];
}

- (void)addUrlTracker
{
    TTVPlayerUrlTracker *urlTracker = [[TTVPlayerUrlTracker alloc] init];
    urlTracker.effectivePlayTime = self.adModel.effectivePlayTime;
    urlTracker.clickTrackURLs = self.adModel.click_track_urls;
    urlTracker.playTrackUrls = self.adModel.adPlayTrackUrls;
    urlTracker.activePlayTrackUrls = self.adModel.adPlayActiveTrackUrls;
    urlTracker.effectivePlayTrackUrls = self.adModel.adPlayActiveTrackUrls;
     urlTracker.playOverTrackUrls = self.adModel.adPlayOverTrackUrls;
//    urlTracker.videoThirdMonitorUrl = self.orderedData.article.videoThirdMonitorUrl;
    [self.movieView.commonTracker registerTracker:urlTracker];
}

- (UIView *)coverImageViewWithUrl:(NSString *)url
{
    if (url.length <= 0) {
        return nil;
    }
    TTImageView *firstFrame = [[TTImageView alloc] initWithFrame:self.bounds]; //loading的时候显示封面图
    firstFrame.backgroundColor = [UIColor blackColor];
    [firstFrame setImageWithURLString:url];
    return firstFrame;
}

- (void)sendClickVideoTrack
{
    NSString *tag = @"detail_ad";
    NSMutableDictionary *extra = @{}.mutableCopy;
    if (self.adModel.detailADType == ArticleDetailADModelTypePhone) {
        tag = @"detail_call";
    }
    else if (self.adModel.detailADType == ArticleDetailADModelTypeApp) {
        tag = @"detail_download_ad";
        [extra setValue:@"1" forKey:@"has_v3"];
        [self.adModel trackRealTimeDownload];
    }
    else if (self.adModel.detailADType == ArticleDetailADModelTypeAppoint) {
        tag = @"detail_form";
    }
    [self.adModel sendTrackEventWithLabel:@"click" eventName:tag extra:extra];
}

- (void)scrollInOrOutBlock:(BOOL)isVisible
{
    if (!isVisible) {
        [self pauseMovie];
        self.isPlayFinished = NO;
    }
}

- (void)moviePlayFinished:(NSNotification *)notification
{
    if (notification.object == self.movieView) {
        [self.movieView removeFromSuperview];
    }
}

- (void)pauseMovie
{
    [self.movieView.player pause];
    [self.movieView.player.controlView setToolBarHidden:NO needAutoHide:NO];
}

- (void)invalideMovieView
{
    if (_movieView) {
        [_movieView exitFullScreen:NO completion:nil];
        [_movieView stop];
        [_movieView removeFromSuperview];
        self.movieView = nil;
    }
}

- (void)_moreInfoActionFired:(id)sender {
    if (self.adModel.isVideoPlayInDetail) {
        [self playVideoADInDetail];
    } else {
        [self sendActionForTapEvent];
    }
}

- (void)_moreInfoLabelActionFired:(id)sender {
    [self sendActionForTapEvent];
}

- (void)restoreWithView:(ExploreDetailBaseADView *)view {
    if (![view isKindOfClass:[self class]]) {
        return ;
    }
    ExploreDetailMixedVideoADView *preView = (ExploreDetailMixedVideoADView *)view;
    // 修复视频全屏后，退出全屏时，exploreMovieView.movieFatherView被重置的问题
    BOOL isMovieViewOnADView = NO;
    TTVBasePlayVideo *exploreMovieView = nil;
    if (preView.movieView) {
        exploreMovieView = preView.movieView;
        if ([exploreMovieView superview] == preView) {
            isMovieViewOnADView = YES;
        }
        preView.movieView = nil;
    }
    
    if (!isEmptyString(exploreMovieView.playerModel.videoID) && [self.adModel.videoInfo.videoID isEqualToString:exploreMovieView.playerModel.videoID]) {
        if (isMovieViewOnADView) {
            exploreMovieView.frame = self.logo.bounds;
            [self addSubview:exploreMovieView];
        }
        self.movieView = exploreMovieView;
    }
}

#pragma mark - TTVDemandPlayerDelegate

- (void)playerPlaybackState:(TTVVideoPlaybackState)state {
    
    switch (state) {
        case TTVVideoPlaybackStateFinished:
        {
            [self movieViewPlayFinished];
        }
            break;
        default:
            break;
    }
}

#pragma mark - movie

- (void)registerMovieViewNotification
{
    if (_movieView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appointAlertViewShow:) name:TTAdAppointAlertViewShowKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appointAlertViewHide:) name:TTAdAppointAlertViewCloseKey object:nil];
    }
}

- (void)removeMovieViewNotification
{
    if (_movieView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TTAdAppointAlertViewShowKey object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TTAdAppointAlertViewCloseKey object:nil];
    }
}

- (void)setMovieView:(TTVBasePlayVideo *)movieView
{
    if (_movieView != movieView) {
        [self removeMovieViewNotification];
        _movieView = movieView;
        [self registerMovieViewNotification];
    }
}

#pragma mark -- notification

- (void)movieViewPlayFinished
{
    [_movieView removeFromSuperview];
    self.isPlayFinished = YES;
    self.movieView = nil;
}

- (void)stopMovieViewPlay:(NSNotification *)notification
{
    [self invalideMovieView];
}

- (void)appointAlertViewShow:(NSNotification *)notification
{
    if (_movieView) {
        [_movieView.player pause];
    }
}

- (void)appointAlertViewHide:(NSNotification *)notification
{
    if (_movieView) {
        [_movieView.player pause];
    }
}

- (void)tryAutoPlay
{
    if (self.isPlayFinished) {
        //在同一次show中只自动播放一次
        return;
    }
    self.adTracker.isAutoPlay = YES;
    if (_movieView) {
        [_movieView.player play];
    } else {
        [self playButtonClicked:nil];
    }
}

#pragma mark - getter

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:kDetailAdTitleFontSize];
        _titleLabel.textColorThemeKey = kColorText10;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
//        _titleLabel.lineHeight = [UIFont systemFontOfSize:16].pointSize * 1.4; //1.4倍行高，字体的1.4倍
    }
    return _titleLabel;
}

- (UIImageView *)topMaskView
{
    if (!_topMaskView) {
        UIImage *topMaskImage = [[UIImage imageNamed:@"thr_shadow_video"] resizableImageWithCapInsets:UIEdgeInsetsZero];
        _topMaskView = [[UIImageView alloc] initWithImage:topMaskImage];
        _topMaskView.frame = CGRectMake(0, 0, self.width, kTopMaskH);
    }
    return _topMaskView;
}

- (SSThemedView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[SSThemedView alloc] init];
        _bottomLine.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
        _bottomLine.backgroundColorThemeKey = kColorLine1;
        _bottomLine.hidden = YES;
    }
    return _bottomLine;
}

- (TTImageView *)logo
{
    if (!_logo) {
        _logo = [[TTImageView alloc] initWithFrame:self.bounds];
        _logo.backgroundColor = [UIColor clearColor];
        _logo.contentMode = UIViewContentModeScaleAspectFill;
        _logo.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _logo.layer.masksToBounds = YES;
        _logo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _logo;
}

- (SSThemedButton *)playButton
{
    if (!_playButton) {
        self.playButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _playButton.imageName = [TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play";
        [_playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (SSThemedLabel *)videoDurationLabel
{
    if (!_videoDurationLabel) {
        _videoDurationLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _videoDurationLabel.backgroundColorThemeKey = kColorBackground15;
        _videoDurationLabel.font = [UIFont systemFontOfSize:10];
        _videoDurationLabel.textColorThemeKey = kColorText8;
        _videoDurationLabel.layer.masksToBounds = YES;
        _videoDurationLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _videoDurationLabel;
}

- (SSThemedLabel *)adLabel
{
    if (!_adLabel) {
        _adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    }
    return _adLabel;
}

- (SSThemedLabel *)sourceLabel
{
    if (!_sourceLabel) {
        _sourceLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _sourceLabel.textAlignment = NSTextAlignmentLeft;
        _sourceLabel.font = [UIFont systemFontOfSize:14];
        _sourceLabel.textColorThemeKey = kColorText1;
    }
    return _sourceLabel;
}

- (SSThemedButton *)moreInfoButton {
    if (!_moreInfoButton) {
        _moreInfoButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _moreInfoButton.backgroundColorThemeKey = kColorBackground4;
        _moreInfoButton.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
        [_moreInfoButton addTarget:self action:@selector(_moreInfoActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreInfoButton;
}

- (SSThemedButton *)moreInfoLabel {
    if (!_moreInfoLabel) {
        _moreInfoLabel = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _moreInfoLabel.backgroundColor = [UIColor clearColor];
        _moreInfoLabel.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _moreInfoLabel.layer.cornerRadius = 6;
        _moreInfoLabel.layer.borderWidth = 1;
        _moreInfoLabel.borderColorThemeKey = kColorLine3;
        _moreInfoLabel.clipsToBounds = YES;
        _moreInfoLabel.titleColorThemeKey = kColorText6;
        _moreInfoLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
        _moreInfoLabel.backgroundColorThemeKey = kColorBackground4;
        _moreInfoLabel.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
        [_moreInfoLabel addTarget:self action:@selector(_moreInfoLabelActionFired:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _moreInfoLabel;
}

- (TTVDetailNatantADPlayerTracker *)adTracker {
    if (!_adTracker && !isEmptyString(self.adModel.ad_id)) {
        _adTracker = [[TTVDetailNatantADPlayerTracker alloc] init];
    }
    return _adTracker;
}
@end

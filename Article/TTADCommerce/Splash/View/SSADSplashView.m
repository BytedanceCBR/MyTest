//
//  SSADSplashView.m
//  Article
//
//  Created by Zhang Leonardo on 12-11-13.
//
//

#import "SSADSplashView.h"

#import "ArticleDetailHeader.h"
#import "SSADManager.h"
#import "SSADModel.h"
#import "SSADNewStyleViewButton.h"
#import "SSCommonLogic.h"
#import "SSSimpleCache.h"
#import "SSWebViewController.h"
#import "TTSplashADSkipButton.h"
#import "TTAVMoviePlayerController.h"
#import "TTAdManager.h"
#import "TTAdTrackManager.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "TTGifImageView.h"
#import "TTRouteService.h"
#import "TTTrackerProxy.h"
#import "TTUIResponderHelper.h"
#import "TTURLTracker.h"
#import "UIImage+TTThemeExtension.h"
#import "VVeboImageView.h"
#import <TTBaseLib/JSONAdditions.h>
#import <TTImage/TTImageInfosModel.h>
#import <TTTracker/TTTrackerProxy.h>
//#import "SSCommon+UIApplication.h"

#define showSplashAnimationTime 0.5f
#define hideSplashAnimationTime 0.5f

#pragma mark - SSADSplashView


/// 视频广告中断原因，用作事件统计.
typedef NS_ENUM(NSUInteger, SSADSplashVideoBreakReason) {
    SSADSplashVideoBreakReasonUnknown = 0, // 未知中断
    SSADSplashVideoBreakReasonEnterDetail, // 点击进落地页
    SSADSplashVideoBreakReasonSkip,        // 点击Skip跳过
    SSADSplashVideoBreakReasonEnterBackground = 7 // app 进入后台
};

@interface SSADSplashView()<TTAVMoviePlayerControllerDelegate>

@property (nonatomic, strong) UIImageView<TTAnimationImageView> *imageView;
@property (nonatomic, strong) UIButton *bgButton;
@property (nonatomic, strong) TTSplashADSkipButton *skipButton;
@property (nonatomic, strong) UIView *viewButton;

@property (nonatomic, strong, readwrite) SSADModel *model;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) NSTimeInterval backgroundTime;

@property (nonatomic, strong) TTAVMoviePlayerController *moviePlayerController;
@property (nonatomic, strong) UIImageView *logoImgView;
@property (nonatomic, strong) NSDictionary * currentImageInfo;

@property (nonatomic, strong) UIImageView *wifiImageView;

@property (nonatomic, assign) BOOL needNotifyOthersOnDeactivationForAudioSession;
@end

@implementation SSADSplashView {
    BOOL _hasAppear;
    ///...
    BOOL _markWillDismiss;
    
    NSInteger    _currentGifIndex;

}

- (void)dealloc
{
    LOGD(@"AD: SSADSplashView DEALLOC Called !!");
    
    if (_needNotifyOthersOnDeactivationForAudioSession) {
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self invalidPerform];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        
        if ([SSCommonLogic isAdGifImageViewEnable]) {
            _imageView = [[TTGifImageView alloc] initWithFrame:self.bounds];
        } else {
            _imageView = [[VVeboImageView alloc] initWithFrame:self.bounds];
        }
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _imageView.repeats = NO;
        _imageView.alpha = 0.2f;
        [self addSubview:_imageView];
        
        // bgButton, 是 skipButton 和 viewButton 的 superView。
        _bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgButton.frame = self.bounds;
        _bgButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_bgButton addTarget:self action:@selector(_enterLandingPageActionFired:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bgButton];
        
        _skipButton = [TTSplashADSkipButton buttonWithType:UIButtonTypeCustom];
        [_skipButton addTarget:self action:@selector(_skipActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [_bgButton addSubview:_skipButton];
        _skipButton.hidden = YES;
    }
    return self;
}

- (void)refreshModel:(SSADModel *)model {
    
    // 不知道之前的逻辑出于什么考虑要多次调用这个方法，开屏广告过于敏感，弄清楚之前没敢改动，只在这里做了这个限制，确保相同的广告资源不重复初始化；
    // 如果真的出现多次调用且model不同的情况，以下逻辑会将对之前的设置全部抹除，根据新的model重新初始化。
    if ([self.model.splashID isEqualToString:model.splashID]) {
        return;
    }
    self.model = model;
    
    _markWillDismiss = NO;
    [self invalidPerform];
    
    if (_logoImgView.superview) {
        [_logoImgView removeFromSuperview];
    }
    
    if (_wifiImageView.superview) {
        [_wifiImageView removeFromSuperview];
    }
    
    if ([self isVideoAD]) {
        
        // 这里只做UI的setup，真正的UI显示及布局在视频开始播放第一帧开始；
        // 视频从加载到播放之间有1s左右，虽然是本地视频.
        [self setupADVideo];
        
        // 为同步Android进度，把互动按钮去掉了，需要时打开注释即可.
        // [self setupDetailButtonIfNeeded];
        
    } else {
        //如果是Gif图,需要延迟加载,防止首帧和次帧之间主线程别的任务执行导致的卡顿
        if ([SSADManager shareInstance].resouceType == SSAdSplashResouceType_Gif) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupADImage];
                [self setupDetailButtonIfNeeded];
                [self refreshUI];
            });
        }
        else{
            [self setupADImage];
            [self setupDetailButtonIfNeeded];
            [self refreshUI];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([SSADManager shareInstance].resouceType == SSAdSplashResouceType_Gif) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([TTDeviceHelper isPadDevice]) {
                [self setupADImage];
            }
            [self refreshUI];
        });
    }
    else{
        if ([TTDeviceHelper isPadDevice]) {
            [self setupADImage];
        }
        [self refreshUI];
    }
    
}

- (void)willAppear
{
    [super willAppear];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didAppear
{
    [super didAppear];
    
    if (_hasAppear) {
        return;
    }
    _hasAppear = YES;
    
    if ([self isVideoAD]) {
        LOGD(@"AD: SplashView VideoAD maxDisplayTime : %@", @(_model.maxDisplayTime));
        NSTimeInterval duration = _model.maxDisplayTime;
        if (duration <= 0) {
            duration = 1;
        }
        [self performSelector:@selector(showedTimeOut) withObject:nil afterDelay:duration];
    } else {
        [self showADImage];
    }
}

- (void)willDisappear
{
    [super willDisappear];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didDisappear
{
    [super didDisappear];
}

- (void)refreshUI
{
    _bgButton.frame = self.bounds;
    
    //隔离iPad iPhone逻辑
    if (![TTDeviceHelper isPadDevice]) {
        // AD imageView
        if ([self.model.splashBannerMode intValue] == SSSplashADBannerModeShowBanner) {
            CGSize size = _imageView.image.size;
            if (size.width > 0 && size.height > 0) {
                _imageView.frame = CGRectMake(0, 0, self.width, (size.height * self.width)/size.width);
            }
        } else {
            _imageView.frame = self.bounds;
        }
    }
    else {
        
        CGFloat contentWidth,contentHeight;
        CGSize size = _imageView.image.size;
        
        if(self.width ==0 || self.height ==0 || size.width == 0 || size.height == 0) return;
        
        //非分屏幕情况
        TTSplitScreenMode splitScreen = [TTDeviceUIUtils currentSplitScreenWithSize:self.frame.size];
        if (splitScreen == TTSplitScreenFullMode) {
            contentWidth = self.width;
            contentHeight = self.height;
        }
        else {
            
            //分屏情况
            if(self.width/ self.height > 0.75) {
                
                contentWidth = 0.75 * self.height;
                contentHeight = self.height;
            }
            else {
                contentHeight = self.width/0.75;
                contentWidth = self.width;
                
            }
        }
        
        // AD imageView
        if ([self.model.splashBannerMode intValue] == SSSplashADBannerModeShowBanner) {
            
            CGSize size = _imageView.image.size;
            if(self.width/ self.height > 0.75) {
                _imageView.frame =  CGRectMake((self.width-contentWidth)/2, 0, contentWidth, contentWidth*size.height/size.width);
                
            }
            else {
                _imageView.frame = CGRectMake(0,(self.height-contentHeight)/2,contentWidth,contentWidth*size.height/size.width);
            }
            
        } else {
            _imageView.frame = CGRectMake(0, 0, contentWidth,contentHeight);
            _imageView.center = self.center;
        }
        
        _bgButton.frame = _imageView.frame;
    }

    
    // skip button
    _skipButton.hidden = NO;
    self.skipButton.origin = CGPointMake(_imageView.width - self.skipButton.width - 14, 4);
    self.skipButton.hidden = ![self.model.displaySkipButton boolValue];
    
    // wifiImageView位置调整
    CGFloat skipButtonBgBtnHeight = 44.0f;
    CGFloat skipButtonBgViewHeight = 24.0f;
    if ([TTDeviceHelper isPadDevice]) {
        skipButtonBgBtnHeight = 58.0f;
        skipButtonBgViewHeight = 32.0f;
    }
    
    if (SSSplashADTypeVideoFullscreen == self.model.splashADType) {
        
        self.moviePlayerController.view.frame = self.bounds;
        _logoImgView.frame = (CGRect){14, 14, _logoImgView.frame.size};
        
        // 已wifi预加载的imageView位置
        _wifiImageView.origin = CGPointMake(SSWidth(_imageView) - SSWidth(self.skipButton) - 14 - _wifiImageView.image.size.width - 9, self.skipButton.origin.y + (skipButtonBgBtnHeight - skipButtonBgViewHeight)/2);
        _wifiImageView.size = CGSizeMake(_wifiImageView.image.size.width, _wifiImageView.image.size.height);

    } else if (SSSplashADTypeVideoCenterFit_16_9 == self.model.splashADType) {
        CGSize videoSize = self.model.videoSize;
        if (CGSizeEqualToSize(videoSize, CGSizeZero)) {
            videoSize = CGSizeMake(16, 9);
        }
        if (videoSize.width > 0 && videoSize.height > 0) {
            self.moviePlayerController.view.frame = CGRectMake(0, 0,
                                                               CGRectGetWidth(self.frame),
                                                               (videoSize.height * CGRectGetWidth(self.frame))/videoSize.width);
            self.moviePlayerController.view.center = _imageView.center;
            
            // 已wifi预加载的imageView位置
            _wifiImageView.origin = CGPointMake(SSWidth(_imageView) - SSWidth(self.skipButton) - 14 - _wifiImageView.image.size.width - 9, self.skipButton.origin.y + (skipButtonBgBtnHeight - skipButtonBgViewHeight)/2);
            _wifiImageView.size = CGSizeMake(_wifiImageView.image.size.width, _wifiImageView.image.size.height);
        }
    }
    
    
    // detail button
    if (self.viewButton) {
        TTSplashClikButtonStyle clikButtonStyle = [self.model.displayViewButton integerValue];
        if (TTSplashClikButtonStyleStrip == clikButtonStyle || clikButtonStyle == TTSplashClikButtonStyleStripAction) {
            self.viewButton.size = CGSizeMake((_imageView.width),
                             ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) ? 50.0f : 44.0f);
            self.viewButton.center = CGPointMake(self.center.x, (_imageView.height) - (self.viewButton.height)/2);
            
        } else if (TTSplashClikButtonStyleRoundRect == clikButtonStyle) {
            [self.viewButton sizeToFit];
            self.viewButton.origin = CGPointMake((_imageView.width) - (self.viewButton.width) - 10, (_imageView.height) - (self.viewButton.height) - 10);
        }
    }
}


#pragma mark - Setup AD

- (void)setupADImage
{
    UIImage *adImage = nil;

    if (![TTDeviceHelper isPadDevice]) {
        NSData *data = nil;
        if (self.model.imageInfo) {
            TTImageInfosModel *imageInfo = [[TTImageInfosModel alloc] initWithDictionary:self.model.imageInfo];
            data = [[SSSimpleCache sharedCache] dataForImageInfosModel:imageInfo];
        }
        if (!data) {
            data = [[SSSimpleCache sharedCache] dataForUrl:_model.splashURLString];
        }
        if (!data) {
            adImage = [self.class splashImageForPrefix:@"Default" extension:@"png"];//应该不会发生，以防万一
        } else {
            adImage = [VVeboImage gifWithData:data];
        }
        
        [_imageView setImage:adImage];
    } else {
        //针对iPad转屏 处理一下帧数同步
        _currentGifIndex = _imageView.currentPlayIndex;

        NSData *data = nil;
        
        TTImageInfosModel *imageInfo;
        //非分屏情况下用横竖屏分别的图 如果分屏了 就用竖屏图
        TTSplitScreenMode splitScreen = [TTDeviceUIUtils currentSplitScreenWithSize:self.frame.size];
        if (splitScreen == TTSplitScreenFullMode) {
            
            NSDictionary * dic = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ?self.model.imageInfo : self.model.landscapeImageInfo;
            
            if ([dic isEqual:self.currentImageInfo] && _imageView.image != nil) {
                return;
            }
            imageInfo = [[TTImageInfosModel alloc] initWithDictionary:dic];
            self.currentImageInfo = dic;
            
        } else {
            
            NSDictionary * dic = self.model.imageInfo;
            
            if ([dic isEqual:self.currentImageInfo] && _imageView.image != nil) {
                return;
            }
            imageInfo = [[TTImageInfosModel alloc] initWithDictionary:dic];
            self.currentImageInfo = dic;
        }
        
 
        data = [[SSSimpleCache sharedCache] dataForImageInfosModel:imageInfo];
        if (!data) {
            data = [[SSSimpleCache sharedCache] dataForUrl:_model.splashURLString];
        }
        if (!data) {
            adImage = [self.class splashImageForPrefix:@"Default" extension:@"png"];//应该不会发生，以防万一
        } else {
            adImage = [VVeboImage gifWithData:data];
        }
        
        [_imageView setImage:adImage];
        
        _imageView.currentPlayIndex = _currentGifIndex;
    }
    
    _imageView.repeats = self.model.repeats.boolValue;
    
    __weak typeof(self) wself = self;
    _imageView.completionHandler = ^(BOOL finished) {
        __strong typeof(wself) self = wself;
        if (self.startDate) {
            NSTimeInterval displayTime = [[NSDate date] timeIntervalSinceDate:self.startDate];
            [self invalidPerform];
            // 剩余的时间
            NSTimeInterval restDuration = (self.model.maxDisplayTime - displayTime);
            if (restDuration < 0) {
                restDuration = 0;
            }
            // [weakSelf performSelector:@selector(showedTimeOut) withObject:nil afterDelay:restDuration];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(restDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showedTimeOut];
            });
        }
    };
}

- (void)setupADVideo
{
    if (_moviePlayerController) {
        [_moviePlayerController.view removeFromSuperview];
        [self removeVideoStatusNotification];
        self.moviePlayerController = nil;
    }
    if (_model.videoMute) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        self.needNotifyOthersOnDeactivationForAudioSession = YES;
    }

    _moviePlayerController = [[TTAVMoviePlayerController alloc] initWithOwnPlayer:NO];
    _moviePlayerController.delegate = self;
    // _moviePlayerController.view.frame = self.bounds;
    [(AVPlayerLayer *)_moviePlayerController.view.layer setVideoGravity:AVLayerVideoGravityResize];
    // _moviePlayerController.view.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:.7];
    
    
    if (SSSplashADTypeVideoFullscreen == _model.splashADType) {
        [self addSubview:_moviePlayerController.view];
        
        // 全屏类型的视频广告左上角显示头条logo
        if (!_logoImgView) {
            _logoImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ad_splash_video_logo"]];
            [_bgButton addSubview:_logoImgView];
        }
        
        if (!_wifiImageView) {
            _wifiImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_splash"]];
            [_bgButton addSubview:_wifiImageView];
        }
        
    } else if (SSSplashADTypeVideoCenterFit_16_9 == _model.splashADType) {
        
        // 用 imageView 作为视频的 superView，便于视频和底图作为一个整体来展示
        [self.imageView addSubview:_moviePlayerController.view];
        
        if (!_wifiImageView) {
            _wifiImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_splash"]];
            [_bgButton addSubview:_wifiImageView];
        }
    }
    
    // 添加通知
    [self addVideoStatusNotification];
    
    // 初始化视图层次结构
    [self bringSubviewToFront:_bgButton];
    // 先隐藏掉，开始播放后再出现(视频从加载到播放之间有1s左右，虽然是本地视频)。
    _moviePlayerController.view.hidden = YES;
    _bgButton.hidden = YES;
    
    // 加载视频
    NSString *filePath = [SSSimpleCache cachePath4VideoWithVideoId:self.model.videoId];
    _moviePlayerController.contentURL = [NSURL fileURLWithPath:filePath];
    _moviePlayerController.muted = self.model.videoMute;
    [_moviePlayerController prepareToPlay];
    [_moviePlayerController play];
}


- (void)setupDetailButtonIfNeeded
{
    TTSplashClikButtonStyle clikButtonStyle = [self.model.displayViewButton integerValue];
    BOOL showDetailButton = (clikButtonStyle > TTSplashClikButtonStyleNone);
    if (showDetailButton) {
        if (self.viewButton.superview) {
            [self.viewButton removeFromSuperview];
        }
        const CGRect stripRect = CGRectMake(0, 0, 100, 50);
        if (TTSplashClikButtonStyleRoundRect == clikButtonStyle) {
            self.viewButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [(UIButton *)self.viewButton setBackgroundImage:[UIImage themedImageNamed:@"viewicon_splash"]
                                                   forState:UIControlStateNormal];
            [(UIButton *)self.viewButton addTarget:self
                                            action:@selector(_enterLandingPageActionFired:forEvent:)
                                  forControlEvents:UIControlEventTouchUpInside];
        } else if (TTSplashClikButtonStyleStripAction == clikButtonStyle) {
            self.viewButton = [[SSADNewStyleViewButton alloc] initWithFrame:stripRect];
            NSString *buttonText = self.model.buttonText;
            if (isEmptyString(buttonText)) {
                buttonText = NSLocalizedString(@"打开应用", @"打开应用");
            }
            [((SSADNewStyleViewButton *)self.viewButton) setTitleText: buttonText];
            __weak typeof(self) wself = self;
            [(SSADNewStyleViewButton *)self.viewButton setButtonTapActionBlock:^() {
                __strong typeof(wself) self = wself;
                [self _fireAction:self.viewButton forEvent:nil];
            }];
        } else { // TTSplashClikButtonStyleStrip == clikButtonStyle 默认设计样式
            self.viewButton = [[SSADNewStyleViewButton alloc] initWithFrame:stripRect];
             [((SSADNewStyleViewButton *)self.viewButton) setTitleText:NSLocalizedString(@"点击查看", @"点击查看")];
            __weak typeof(self) wself = self;
            [(SSADNewStyleViewButton *)self.viewButton setButtonTapActionBlock:^() {
                __strong typeof(wself) self = wself;
                [self _enterLandingPageActionFired:self.viewButton forEvent:nil];
            }];
        }
        
        [self.bgButton addSubview:self.viewButton];
        
    } else {
        [self.viewButton removeFromSuperview];
        self.viewButton = nil;
    }
}

- (BOOL)isVideoAD
{
    return (SSSplashADTypeVideoFullscreen == _model.splashADType || SSSplashADTypeVideoCenterFit_16_9 == _model.splashADType);
}

- (void)addVideoStatusNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)removeVideoStatusNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}


#pragma mark - Show AD

- (void)showADImage
{
    VVeboImage *image = (VVeboImage *)_imageView.image;
    // 这个动画比较蛋疼，现在判断条件如下，如果是gif 但是只有1桢或者不是gif的话，就展示动画，否则不展示动画.
    BOOL animated = (_imageView.alpha != 1.0 && (([image isKindOfClass:[VVeboImage class]] && image.count == 1) || ![image isKindOfClass:[VVeboImage class]]));
    if (animated) {
        [UIView animateWithDuration:0.15f animations:^{
            _imageView.alpha = 1.f;
        }];
    } else {
        _imageView.alpha = 1.0;
    }
    
    NSTimeInterval duration = _model.maxDisplayTime;
    if (duration <= 0) {
        duration = 1;
    }
    [self performSelector:@selector(showedTimeOut) withObject:nil afterDelay:duration];
    LOGD(@"AD: SplashView ImageAD maxDisplayTime : %@", @(_model.maxDisplayTime));
    
    // 开始计时， 广告倒计时
    self.startDate = [NSDate date];
    
    // event track : 图片类型广告图展示
    [self eventTrack4ImageADShowed];
    if ([self.model.displayViewButton integerValue] == TTSplashClikButtonStyleStripAction) {
        [self eventTrack4ImageADShowActionButton];
    }
}

- (void)showADVideo
{
    if (SSSplashADTypeVideoFullscreen == self.model.splashADType) { // 全屏视频广告
        
        [self prepareToDisplayADVideoWithRelatedView:self.moviePlayerController.view];
        
    } else if (SSSplashADTypeVideoCenterFit_16_9 == self.model.splashADType) { // 带底图的视频广告
        
        NSData *data;
        if (self.model.imageInfo) {
            TTImageInfosModel *imageInfo = [[TTImageInfosModel alloc] initWithDictionary:self.model.imageInfo];
            data = [[SSSimpleCache sharedCache] dataForImageInfosModel:imageInfo];
        }
        UIImage *adImage = [UIImage imageWithData:data];
        if (adImage.size.height > 0 && adImage.size.width > 0) {
            
            // 底图
            self.imageView.image = adImage;
            
            [self prepareToDisplayADVideoWithRelatedView:self.imageView];
            
            // event track : 底图展现
            [self eventTrack4VideoADWithLabel:@"banner_show"];
        }
    }
    
    if (self.viewButton && !self.bgButton.hidden) {
        // event track : 交互按钮展示
        [self eventTrack4VideoADWithLabel:@"button_show"];
    }
    
    // event track : 视频播放
    [self eventTrack4VideoADWithLabel:@"play"];
    
    // 第三方监控: 视频开始播放
    if (self.model.videoPlayTrackURLArray.count > 0) {
LOGD(@">>>>>>>>>>>>>>>>>>>> 第三方监控: 视频开始播放.");
        ttTrackURLsModel(self.model.videoPlayTrackURLArray, self.trackUrlModel);
    }
}

- (void)prepareToDisplayADVideoWithRelatedView:(UIView *)videoRelatedView
{
    // 显示之前初始化后被隐藏的view
    self.moviePlayerController.view.hidden = NO;
    self.bgButton.hidden = NO;
    
    videoRelatedView.alpha = 0.2;
    self.bgButton.alpha = 0.2;
    
    [self refreshUI];
    
    [UIView animateWithDuration:.35 animations:^{
        videoRelatedView.alpha = 1;
        self.bgButton.alpha = 1;
    }];
}


#pragma mark - Timer
/**
 开屏广告 展示结束
 */
- (void)showedTimeOut {
    
    if (_markWillDismiss) {
        return;
    }
    _markWillDismiss = YES;
    
    // 先取消超时自动关闭
    [self invalidPerform];
    
    if (_delegate && [_delegate respondsToSelector:@selector(splashViewShowFinished:)]) {
        [_delegate performSelector:@selector(splashViewShowFinished:) withObject:self];
    }
}

- (void)invalidPerform {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


#pragma mark - Action

- (BOOL)haveClickAction {
    return [SSADManager splashADModelHasAction:_model];
}

- (void)_skipActionFired:(id)sender {
// 先取消超时自动关闭
//    [self invalidPerform];
    
    if ([self isVideoAD]) {
        
        // event track : 点击跳过按钮
        [self eventTrack4VideoADWithLabel:@"skip"];
        // event track : 视频播放中断(点击跳过广告)
        [self eventTrack4VideoADPlayBreakWithReason:SSADSplashVideoBreakReasonSkip];
        
        ///...
//        if (_moviePlayerController.isPlaying) {
//            [_moviePlayerController stop];
//        }
        [self removeVideoStatusNotification];
        
    } else { // 图片类型广告
        
        // event track : 图片类型广告图跳过
        [self eventTrack4ImageADSkipped];
    }
        
    [self showedTimeOut];
}


/**
 点击背景 事件
 */
- (void)_enterLandingPageActionFired:(id)sender forEvent:(UIEvent*)event {
    if ([self isVideoAD] && [self haveClickAction]) {
//        [self invalidPerform];
        
        if (sender == self.viewButton) { // 点击了交互按钮
            // event track : 点击交互按钮
            [self eventTrack4VideoADWithLabel:@"button_click"];
LOGD(@">>>>>>>>>>>>>>>>>>> Touched ViewButton.");
            
        } else if (sender == self.bgButton) { // 点击了交互按钮外的其余区域
            
            BOOL touchedVideo = NO;
            
            if (SSSplashADTypeVideoFullscreen == self.model.splashADType) {
                touchedVideo = YES;
            } else if (SSSplashADTypeVideoCenterFit_16_9 == self.model.splashADType) {
                
                UITouch *touch = [[event allTouches] anyObject];
                CGPoint point = [touch locationInView:_moviePlayerController.view];
                if ([_moviePlayerController.view pointInside:point withEvent:event]) { // 点击了视频区域
                    
                    touchedVideo = YES;
                    
                } else {
LOGD(@">>>>>>>>>>>>>>>>>>> Touched OUTSide Movie view.");
                    // event track : 点击底图
                    [self eventTrack4VideoADWithLabel:@"banner_click"];
                }
            }
            
            if (touchedVideo) {
LOGD(@">>>>>>>>>>>>>>>>>>> Touched Movie view.");
                // event track : 点击视频
                [self eventTrack4VideoADWithLabel:@"click"];
            }
        }
        
        // event track : 中断(进落地页)
        [self eventTrack4VideoADPlayBreakWithReason:SSADSplashVideoBreakReasonEnterDetail]; // 中断
        
        // 第三方监控: 进广告详情页
        if (self.model.videoActionTrackURLArray.count > 0) {
LOGD(@">>>>>>>>>>>>>>>>>>>> 第三方监控: 进广告详情页.");
            ttTrackURLsModel(self.model.videoActionTrackURLArray, self.trackUrlModel);
//            ssTrackURLsModel(self.model.videoActionTrackURLArray,self.trackUrlModel);
        }
        
//        if (_moviePlayerController.isPlaying) {
//            [_moviePlayerController stop];
//        }
        [self removeVideoStatusNotification];
        
        
        if (_delegate && [_delegate respondsToSelector:@selector(splashViewClickBackgroundAction)]) {
            [_delegate performSelector:@selector(splashViewClickBackgroundAction)];
        }
        
        [self showedTimeOut];
        
        return;
    }
    
    // 以下是对图片类型广告的处理
    NSTimeInterval timeInterval = 0;
    if (self.startDate) {
        timeInterval = [[NSDate date] timeIntervalSinceDate:self.startDate];
    }
    self.startDate = nil;
    
    if ([self haveClickAction]) {
        //开屏九宫格情况
        if (![TTDeviceHelper isPadDevice] && self.model.splashADType == SSSplashADTypeImage_ninebox && [self isTouchInImageViewSender:sender forEvent:event]) {
            NSInteger index = [self indexOfNineBoxSender:sender forEvent:event];
            [self nineBoxActionWithModel:self.model index:index];
            
        }
        else
        {
            // event track : 图片广告的展示时长
            [self eventTrack4ImageADEnterDetailWithShowTime:timeInterval
                                          clickedViewButton:(sender == self.viewButton)];
            [self clickADImageTrackURLs:self.model];
            
            if (_delegate && [_delegate respondsToSelector:@selector(splashViewClickBackgroundAction)]) {
                [_delegate performSelector:@selector(splashViewClickBackgroundAction)];
            }
            
            [self showedTimeOut];
        }
        
    }
}

- (BOOL)isTouchInImageViewSender:(id)sender forEvent:(UIEvent*)event
{
    if (sender == self.bgButton) {
        UIButton* bgButton = (UIButton*)sender;
        UITouch* touch = [[event touchesForView:bgButton] anyObject];
        CGPoint point = [touch locationInView:bgButton];
        return CGRectContainsPoint(self.imageView.frame, point);
    }
    return NO;
}

- (NSInteger)indexOfNineBoxSender:(id)sender forEvent:(UIEvent*)event
{
    UIButton* bgButton = (UIButton*)sender;
    UITouch* touch = [[event touchesForView:bgButton] anyObject];
    CGPoint point = [touch locationInView:bgButton];
    
    NSInteger index = 0;
    CGFloat width = self.imageView.width/3;
    CGFloat height = self.imageView.height/3;
    for (int i = 0; i < 9; i++) {
        CGRect rect = CGRectMake((i%3)*width, (i/3)*height, width, height);
        if (CGRectContainsPoint(rect, point)) {
            index = i;
            return index;
        }
    }
    return index;
}

- (void)nineBoxActionWithModel:(SSADModel *)model index:(NSInteger)index
{
    NSString* openUrl = nil;
    NSString* webUrl = nil;
    if (model.splashOpenUrlList.count > index) {
        openUrl = model.splashOpenUrlList[index];
    }
    if (model.splashWebUrlList.count > index) {
        webUrl = model.splashWebUrlList[index];
    }
    
    if (!isEmptyString(openUrl) && [[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openUrl]]) {
        
        NSMutableDictionary *conditions = [NSMutableDictionary dictionaryWithCapacity:2];
        [conditions setValue:model.splashID forKey:@"ad_id"];
        [conditions setValue:model.logExtra forKey:@"log_extra"];
        [conditions setValue:@"splash" forKey:@"gd_label"];
        [conditions setValue:@(NewsGoDetailFromSourceSplashAD) forKey:kNewsGoDetailFromSourceKey];
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openUrl] userInfo:TTRouteUserInfoWithDict(conditions)];
        NSMutableDictionary* pdict = [NSMutableDictionary dictionary];
        TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
        [pdict setValue:@(index+1) forKey:@"pic_position"];
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:self.model.logExtra forKey:@"log_extra"];
        [dict setValue:[pdict tt_JSONRepresentation] forKey:@"ad_extra_data"];
        [dict setValue:@(connectionType) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        [TTAdTrackManager trackWithTag:@"splash_ad" label:@"click" value:self.model.splashID extraDic:dict];
        [self clickADImageTrackURLs:self.model];
        [self showedTimeOut];
    }
    else if ([model.splashActionType isEqualToString:@"web"] && !isEmptyString(webUrl)) {
        NSString * title = NSLocalizedString(@"网页浏览", nil);
        if (!isEmptyString(model.splashWebTitle)) {
            title = model.splashWebTitle;
        }
        NSMutableDictionary *conditions = [NSMutableDictionary dictionaryWithCapacity:2];
        [conditions setValue:model.splashID forKey:@"ad_id"];
        [conditions setValue:model.logExtra forKey:@"log_extra"];
        [conditions setValue:@"splash" forKey:@"gd_label"];
        [conditions setValue:@(NewsGoDetailFromSourceSplashAD) forKey:kNewsGoDetailFromSourceKey];
        UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor: nil];
        [SSWebViewController openWebViewForNSURL:[TTStringHelper URLWithURLString:webUrl] title:title navigationController:topController supportRotate:YES conditions:conditions];
        
        NSMutableDictionary* pdict = [NSMutableDictionary dictionary];
        [pdict setValue:@(index+1) forKey:@"pic_position"];
        TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:self.model.logExtra forKey:@"log_extra"];
        [dict setValue:[pdict tt_JSONRepresentation] forKey:@"ad_extra_data"];
        [dict setValue:@(connectionType) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        [TTAdTrackManager trackWithTag:@"splash_ad" label:@"click" value:self.model.splashID extraDic:dict];
        [self clickADImageTrackURLs:self.model];
        [self showedTimeOut];
    }
    else {
        //do nothing
    }
}


/**
 点击action Button 吊起落地页 3 （第三方app）
 */
- (void)_fireAction:(id)sender forEvent:(UIEvent *)event {
    if (![self isVideoAD]) {
        // 以下是对图片类型广告的处理
        NSTimeInterval timeInterval = 0;
        if (self.startDate) {
            timeInterval = [[NSDate date] timeIntervalSinceDate:self.startDate];
        }
        self.startDate = nil;
        
        // event track : 图片广告的展示时长
        [self eventTrack4ImageADEnterDetailWithShowTime:timeInterval clickedViewButton:YES];
        [self clickADImageTrackURLs:self.model];
        
        if (_delegate && [_delegate respondsToSelector:@selector(splashViewWithAction)]) {
            [_delegate performSelector:@selector(splashViewWithAction)];
        }
        
        [self showedTimeOut];
    }
}


- (TTURLTrackerModel*)trackUrlModel
{
    TTURLTrackerModel* model = [[TTURLTrackerModel alloc] initWithAdId:self.model.splashID logExtra:self.model.logExtra];
    return model;
}


#pragma mark - Notification for VideoAD

- (void)playerController:(TTAVMoviePlayerController *)playerController playbackDidFinish:(NSDictionary *)reason
{

    if (playerController != _moviePlayerController) {
        return;
    }
    
    switch ([reason[TTMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue]) {
        case TTMovieFinishReasonPlaybackEnded: // 播放结束
        {
            // event track : 播放完成
            [self eventTrack4VideoADWithLabel:@"play_over"
                                    extraInfo:[self videoInfoAboutPlabackTimeAndPercent]];
LOGD(@">>>>>>>> 播放结束 -- paly info : %@.", [self videoInfoAboutPlabackTimeAndPercent]);
            
            // 第三方监控: 视频播放结束
            if (self.model.videoPlayOverTrackURLArray.count > 0) {
LOGD(@">>>>>>>>>>>>>>>>>>>> 第三方监控: 视频播放结束.");
                ttTrackURLsModel(self.model.videoPlayOverTrackURLArray, self.trackUrlModel);
//                ssTrackURLsModel(self.model.videoPlayOverTrackURLArray,self.adBaseModel);
            }
            
            [self showedTimeOut];
        }
            break;
            
        case TTMovieFinishReasonPlaybackError: // 播放失败
            
LOGD(@"播放失败 : %@", reason[@"error"]);
            
            // event track : 播放失败
            [self eventTrack4VideoADWithLabel:@"play_fail"];
            
            [self showedTimeOut];
            
            break;
            
//        case TTMovieFinishReasonUserExited:
//            // 中途停止，比如开屏广告点了跳过
//            LOGD(@"点击skip跳过");
//            break;
            
        default:
            break;
    }
}

- (void)playerControllerIsPrepareToPlay:(TTAVMoviePlayerController *)player
{
    // 开始播放第一帧画面
    [self showADVideo];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    if (![self isVideoAD]) {
        return;
    }
    
    if (self.moviePlayerController.isPlaying) {
        // event track : 视频播放中断(退后台)
        [self eventTrack4VideoADPlayBreakWithReason:SSADSplashVideoBreakReasonEnterBackground];
    }
    
    [self showedTimeOut];
}


#pragma mark - Event Track for ImageAD

- (void)eventTrack4ImageADShowed
{
    if (!isEmptyString(_model.splashID)) {
        NSMutableDictionary *events = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"umeng", @"category",
                                       @"splash_ad", @"tag",
                                       @"show", @"label",
                                       _model.splashID, @"value", nil];
        if (!isEmptyString(_model.logExtra)) {
            [events setValue:_model.logExtra forKey:@"log_extra"];
        }
        
        TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
        [events setValue:@(connectionType) forKey:@"nt"];
        [events setValue:@"1" forKey:@"is_ad_event"];
        [TTTrackerWrapper eventData:events];
    }
    
    if ([_model.splashTrackURLStrings isKindOfClass:[NSArray class]] && _model.splashTrackURLStrings.count > 0) {
        ttTrackURLsModel(_model.splashTrackURLStrings, self.trackUrlModel);
    }
}

- (void)eventTrack4ImageADSkipped
{
    NSTimeInterval timeInterval = 0;
    if (self.startDate) {
        timeInterval = [[NSDate date] timeIntervalSinceDate:self.startDate];
    }
    // 统计完了之后就没用了
    self.startDate = nil;
    
    NSMutableDictionary *dict = [@{@"category":@"umeng", @"tag":@"splash_ad", @"label":@"skip"} mutableCopy];
    if (!isEmptyString(_model.splashID)) {
        [dict setValue:_model.splashID forKey:@"value"];
    }
    if (timeInterval > 0) {
        // 如果timeInterval <= 0 则不发送show_time
        [dict setValue:@((NSInteger)(timeInterval * 1000)) forKey:@"show_time"];
    }
   
    [dict setValue:_model.logExtra forKey:@"log_extra"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];;
    [dict setValue:@(connectionType) forKey:@"nt"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    [TTTrackerWrapper eventData:dict];
}

- (void)eventTrack4ImageADEnterDetailWithShowTime:(NSTimeInterval)timeInterval
                                clickedViewButton:(BOOL)clickViewButton
{
    if ([_model.splashID length] > 0) {
        NSMutableDictionary *dict = [@{@"category":@"umeng", @"tag":@"splash_ad", @"label":@"click", @"value":_model.splashID} mutableCopy];
        if (timeInterval > 0) {
            // 如果timeInterval <= 0 则不发送show_time
            [dict setValue:@((NSInteger)(timeInterval * 1000)) forKey:@"show_time"];
        }
        // 拓展字段, 展示时间show_time, 单位是ms
        // 补充在哪里点击的? btn还是屏幕其他位置. area. 0是点击其他区域(可以不传), 1是点击btn
        [dict setValue:@(clickViewButton) forKey:@"area"];
        [dict setValue:_model.logExtra forKey:@"log_extra"];
        TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];;
        [dict setValue:@(connectionType) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        [TTTrackerWrapper eventData:dict];
    }
}

- (void)clickADImageTrackURLs:(SSADModel *)model {
    if (model.adModelType == SSADModelTypeSplash && (model.splashADType == SSSplashADTypeImage|| model.splashADType == SSSplashADTypeImage_ninebox)) {
        TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:model.splashID logExtra:model.logExtra];
        ttTrackURLsModel(model.splashClickTrackURLStrings, trackModel);
    }
}

- (void)eventTrack4ImageADShowActionButton {
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:7];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:@"splash_ad" forKey:@"tag"];
    [events setValue:@"open_url_show" forKey:@"label"];
    [events setValue:self.model.splashID forKey:@"value"];
    [events setValue:self.model.logExtra forKey:@"log_extra"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];;
    [events setValue:@(connectionType) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    
    [TTTrackerWrapper eventData:events];
}

#pragma mark - Event Track for VideoAD

- (void)eventTrack4VideoADPlayBreakWithReason:(SSADSplashVideoBreakReason)breakReason
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self videoInfoAboutPlabackTimeAndPercent]];
    [dict setValue:@(breakReason) forKey:@"break_reason"];
    [self eventTrack4VideoADWithLabel:@"play_break" extraInfo:dict];
}

- (void)eventTrack4VideoADWithLabel:(NSString *)label
{
    [self eventTrack4VideoADWithLabel:label extraInfo:nil];
}

- (void)eventTrack4VideoADWithLabel:(NSString *)label extraInfo:(NSDictionary *)infoDict
{
    if (isEmptyString(label)) {
        return;
    }
    
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:3];
    if (!isEmptyString(self.model.logExtra)) {
        [extraDict setValue:self.model.logExtra forKey:@"log_extra"];
    }
    
    if (infoDict.allKeys.count > 0) {
        [extraDict addEntriesFromDictionary:infoDict];
    }
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [extraDict setValue:@(connectionType) forKey:@"nt"];
    [extraDict setValue:@"1" forKey:@"is_ad_event"];
    wrapperTrackEventWithCustomKeys(@"splash_ad", label, self.model.splashID, nil, extraDict);
}

- (NSDictionary *)videoInfoAboutPlabackTimeAndPercent
{
    NSTimeInterval plabackTime = self.moviePlayerController.currentPlaybackTime;
    NSTimeInterval duration = self.moviePlayerController.duration;
    
    NSUInteger percent = 0;
    if (plabackTime > 0 && duration > 0) {
        percent = (NSUInteger)(((CGFloat)plabackTime / (CGFloat)duration) * 100);
    }
    NSDictionary *extraInfoDict = @{@"duration" : @((NSUInteger)(plabackTime * 1000)),
                                    @"percent"  : @(percent)};
    return extraInfoDict;
}

+ (UIImage *)splashImageForPrefix:(NSString*)prefix extension:(NSString*)extension
{
    NSMutableString *imageName = [NSMutableString stringWithString:prefix];
    if (![TTDeviceHelper isPadDevice])
    {
        if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen])
        {
            [imageName appendString:@"-568h"];
        }
        else if([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice])
        {
            [imageName appendString:@"-667h"];
        }
        else if([TTDeviceHelper is736Screen])
        {
            [imageName appendString:@"-736h"];
        }
    }
    else {
        if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        {
            [imageName appendString:@"-Portrait"];
        }
        else
        {
            [imageName appendString:@"-Landscape"];
        }
    }
    
    if(isEmptyString(extension)) extension = @"png";
    [imageName appendFormat:@".%@", extension];
    return [UIImage imageNamed:imageName];
}

@end

//
//  TTAdSplashSettingVC.m
//  Article
//
//  Created by yin on 2017/11/15.
//

#import "TTAdSplashSettingVC.h"

#import "TTNavigationController.h"
#import "TTAdSplashModel.h"
#import "VVeboImageView.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+TTThemeExtension.h"
#import "ArticleDetailHeader.h"
#import "SSWebViewController.h"
#import "TTRouteService.h"
#import "TTAdSplashMediator.h"
#import "TTAdSplashSkipButton.h"
#import "TTAdSplashVideoView.h"
#import "TTAdSplashCache.h"
#import "TTAdSplashImageInfosModel.h"
#import "TTAdSplashManager+Action.h"

@interface TTAdSplashSettingCell : UICollectionViewCell<TTAdSplashVideoViewDelegate, TTAdSplashVideoViewDelegate>

//@property (nonatomic, strong) SSADNewStyleViewButton *style1ViewButton;
@property (nonatomic, strong) UIButton *style1ViewButton;
@property (nonatomic, strong) UIButton               *style2ViewButton;
@property (nonatomic, strong) TTAdSplashVideoView *videoView;
@property (nonatomic, strong) UIImageView *logoImgView;
@property (nonatomic, strong) UIView *viewButton;
@property (nonatomic, strong) TTAdSplashSkipButton *skipButton;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSDictionary * currentImageInfo;

@property (nonatomic, strong) UIImageView *wifiImageView;

- (void)setupCellWithADModel:(TTAdSplashModel *)adModel;

@end

@implementation TTAdSplashSettingCell
{
    VVeboImageView *_adSplashImgView;
    TTAdSplashModel      *_adModel;
    UIImageView    *_bgImgView;
    
    NSInteger    _currentGifIndex;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _bgImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        NSString *imgName = @"LaunchImage-800-Portrait-736h@3x.png";
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            imgName = @"LaunchImage-800-Portrait-736h@3x.png";
        }
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 &&
            ([UIScreen mainScreen].bounds.size.height == 480)) {
            imgName = @"LaunchImage-700@2x.png";
        }
        _bgImgView.image = [UIImage imageNamed:imgName];
        _bgImgView.backgroundColor = [UIColor whiteColor];
        _bgImgView.contentMode = UIViewContentModeScaleAspectFit;
        if ([TTDeviceHelper isPadDevice]) {
            _bgImgView.image = [UIImage imageNamed:@"LaunchImage-700-Portrait~ipad.png"];
        }
        _bgImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:_bgImgView];
        WeakSelf;
        [_bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(wself.contentView);
        }];
        
        
        _adSplashImgView = [[VVeboImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_adSplashImgView];
        
        _wifiImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi_splash"]];
        _wifiImageView.hidden = YES;
        [_adSplashImgView addSubview:_wifiImageView];
        
        _skipButton = [TTAdSplashSkipButton buttonWithType:UIButtonTypeCustom];
        _skipButton.frame = CGRectMake(CGRectGetWidth(_adSplashImgView.frame) - CGRectGetWidth(_skipButton.frame) - 14.0f, 4.0f, CGRectGetWidth(_skipButton.frame), CGRectGetHeight(_skipButton.frame));
        _skipButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_skipButton addTarget:self action:@selector(skipButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_adSplashImgView addSubview:_skipButton];
        
        _adSplashImgView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOn:)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)tapGestureOn:(UITapGestureRecognizer*)tap
{
    CGPoint point = [tap locationInView:_adSplashImgView];
    
    //开屏九宫格跳转
    if (![TTDeviceHelper isPadDevice] && _adModel.splashADType == SSSplashADTypeImage_ninebox && CGRectContainsPoint(_adSplashImgView.frame, point)) {
        NSInteger index = 0;
        CGFloat width = _adSplashImgView.width/3;
        CGFloat height = _adSplashImgView.height/3;
        for (int i = 0; i < 9; i++) {
            CGRect rect = CGRectMake((i%3)*width, (i/3)*height, width, height);
            if (CGRectContainsPoint(rect, point)) {
                index = i;
            }
        }
        [[TTAdSplashManager shareInstance] splashViewClickNineBoxIndex:_adModel index:index];
    } else {
        [[TTAdSplashManager shareInstance] splashViewClickBackground:_adModel];
    }
}

- (void)skipButtonPressed:(id)sender {
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate skipButtonPressed:sender];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _adSplashImgView.image = nil;
    _videoView.hidden = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([TTDeviceHelper isPadDevice]) {
        
        [self setupADImage];
        
    }
    [self refreshUI];
}

- (void)setupCellWithADModel:(TTAdSplashModel *)adModel
{
    _adModel = adModel;
    
    if ([self isVideoAD]) {
        // 这里只做UI的setup，真正的UI显示及布局在视频开始播放第一帧开始；
        // 视频从加载到播放之间有1s左右，虽然是本地视频.
        [self setupADVideo];
        
        // 为同步Android进度，把互动按钮去掉了，需要时打开注释即可.
        // [self setupDetailButtonIfNeeded];
        
    } else {
        [self setupADImage];
    }
    [self refreshUI];
}

- (void)refreshUI
{
    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.top = 0;  //很奇怪 iphoneX会出现cell的top在collectView上-36的问题
    }
    //隔离iPhone 和iPad的布局
    if (![TTDeviceHelper isPadDevice]) {
        // AD imageView
        if ([_adModel.splashBannerMode intValue] == TTAdSplashBannerModeShowBanner) {
            CGSize size = _adSplashImgView.image.size;
            if (size.width > 0 && size.height > 0) {
                _adSplashImgView.frame = CGRectMake(0, 0, self.width, (size.height * self.width)/size.width);
            }
        } else {
            _adSplashImgView.frame = self.bounds;
        }
        
        
    }
    else { //iPad
        
        CGFloat contentWidth,contentHeight;
        CGSize size = _adSplashImgView.image.size;
        
        if(self.width==0 || self.height==0 || size.width == 0 || size.height == 0) return;
        
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
        
        if ([_adModel.splashBannerMode intValue] == TTAdSplashBannerModeShowBanner) {
            
            CGSize size = _adSplashImgView.image.size;
            if(self.width/ self.height > 0.75) {
                _adSplashImgView.frame =  CGRectMake((self.width-contentWidth)/2, 0, contentWidth, contentWidth*size.height/size.width);
                
            }
            else {
                _adSplashImgView.frame = CGRectMake(0,(self.height-contentHeight)/2,contentWidth,contentWidth*size.height/size.width);
            }
            
        } else {
            _adSplashImgView.frame = CGRectMake(0, 0, contentWidth,contentHeight);
            _adSplashImgView.center = self.center;
        }
        
        
    }
    
    // wifiImageView位置调整
    CGFloat skipButtonBgBtnHeight = 44.0f;
    CGFloat skipButtonBgViewHeight = 24.0f;
    if ([TTDeviceHelper isPadDevice]) {
        skipButtonBgBtnHeight = 58.0f;
        skipButtonBgViewHeight = 32.0f;
    }
    
    _logoImgView.hidden = YES;
    if (TTAdSplashADTypeVideoFullscreen == _adModel.splashADType) {
        // 全屏视频
        self.videoView.frame = self.bounds;
        self.logoImgView.hidden = NO;
        
        // 已wifi预加载的imageView位置
        _wifiImageView.hidden = NO;
        _wifiImageView.origin = CGPointMake(SSWidth(_adSplashImgView) - SSWidth(_skipButton) - 14 - _wifiImageView.image.size.width - 9, _skipButton.origin.y + (skipButtonBgBtnHeight - skipButtonBgViewHeight)/2);
        _wifiImageView.size = CGSizeMake(_wifiImageView.image.size.width, _wifiImageView.image.size.height);
        
    } else if (TTAdSplashADTypeVideoCenterFit_16_9 == _adModel.splashADType) {
        // 插屏视频
        CGSize videoSize = _adModel.videoSize;
        if (CGSizeEqualToSize(videoSize, CGSizeZero)) {
            videoSize = CGSizeMake(16, 9);
        }
        if (videoSize.width > 0 && videoSize.height > 0) {
            self.videoView.frame = CGRectMake(0, 0,
                                                               CGRectGetWidth(self.frame),
                                                               (videoSize.height * CGRectGetWidth(self.frame))/videoSize.width);
            self.videoView.center = _adSplashImgView.center;
        }
        
        // 已wifi预加载的imageView位置
        _wifiImageView.hidden = NO;
        _wifiImageView.origin = CGPointMake(SSWidth(_adSplashImgView) - SSWidth(_skipButton) - 14 - _wifiImageView.image.size.width - 9, _skipButton.origin.y + (skipButtonBgBtnHeight - skipButtonBgViewHeight)/2);
        _wifiImageView.size = CGSizeMake(_wifiImageView.image.size.width, _wifiImageView.image.size.height);
        
    } else {
        _wifiImageView.hidden = YES;
    }
    
    _style1ViewButton.hidden = _style2ViewButton.hidden = YES;
    if ([_adModel.displayViewButton intValue] > 0 && ![self isVideoAD]) { // 视频广告不显示交互按钮
        CGSize sizeOfADSplashImgView = _adSplashImgView.frame.size;
        if (1 == [_adModel.displayViewButton intValue]) {
            
            CGFloat height = ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen]) ? 44.0f : 40.0f;
            self.style1ViewButton.frame = CGRectMake(0, sizeOfADSplashImgView.height-self.style1ViewButton.frame.size.height, CGRectGetWidth(_adSplashImgView.frame), height);
            _style1ViewButton.hidden = NO;
            
        } else if (2 == [_adModel.displayViewButton intValue]) {
            [self.style2ViewButton sizeToFit];
            self.style2ViewButton.origin = CGPointMake(
                                                       sizeOfADSplashImgView.width - self.style2ViewButton.width - 10,
                                                       sizeOfADSplashImgView.height - self.style2ViewButton.height - 10);
            _style2ViewButton.hidden = NO;
        }
    }
    
    [_adSplashImgView bringSubviewToFront:_wifiImageView];
    [_adSplashImgView bringSubviewToFront:_skipButton];
    [_adSplashImgView bringSubviewToFront:_style2ViewButton];
    [_adSplashImgView bringSubviewToFront:_style1ViewButton];
}


#pragma mark - Setup AD

- (void)setupADImage
{
    if (![TTDeviceHelper isPadDevice]) {
        
        TTAdSplashImageInfosModel *imageInfo = [[TTAdSplashImageInfosModel alloc] initWithDictionary:_adModel.imageInfo];
        NSData *imageData = [[TTAdSplashCache sharedCache] dataForImageInfosModel:imageInfo];
        if (imageData) {
            _adSplashImgView.image = [VVeboImage gifWithData:imageData];;
        }
    }
    else {
        
        //针对iPad转屏 处理一下帧数同步
        _currentGifIndex = _adSplashImgView.currentPlayIndex;
        
        TTAdSplashImageInfosModel *imageInfo;
        //非分屏情况下用横竖屏分别的图 如果分屏了 就用竖屏图
        TTSplitScreenMode splitScreen = [TTDeviceUIUtils currentSplitScreenWithSize:self.frame.size];
        if (splitScreen == TTSplitScreenFullMode) {
            
            NSDictionary * dic = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ?_adModel.imageInfo : _adModel.landscapeImageInfo;
            if ([dic isEqual:self.currentImageInfo] && _adSplashImgView.image != nil) {
                return;
            }
            imageInfo = [[TTAdSplashImageInfosModel alloc] initWithDictionary:dic];
            
            self.currentImageInfo = dic;
            
        }
        else {
            
            NSDictionary * dic = _adModel.imageInfo;
            if ([dic isEqual:self.currentImageInfo] && _adSplashImgView.image != nil) {
                return;
            }
            
            imageInfo = [[TTAdSplashImageInfosModel alloc] initWithDictionary:dic];
            self.currentImageInfo = dic;
            
        }
        NSData *imageData = [[TTAdSplashCache sharedCache] dataForImageInfosModel:imageInfo];
        if (imageData) {
            _adSplashImgView.image = [VVeboImage gifWithData:imageData];;
        }
        
        //针对iPad转屏 处理一下帧数同步
        _adSplashImgView.currentPlayIndex = _currentGifIndex;
        
        
    }
}

- (void)setupADVideo
{
    // 加载视频
    NSString *filePath = [TTAdSplashCache cachePath4VideoWithVideoId:_adModel.videoId];
    if (emptyString(filePath)) {
        return;
    }
    self.videoView = [[TTAdSplashVideoView alloc] initWithUrl:[NSURL fileURLWithPath:filePath]];
    self.videoView.delegate = self;
    self.videoView.mute = _adModel.videoMute;
    [_adSplashImgView addSubview:self.videoView];
    
}



- (BOOL)isVideoAD
{
    return (TTAdSplashADTypeVideoFullscreen == _adModel.splashADType || TTAdSplashADTypeVideoCenterFit_16_9 == _adModel.splashADType);
}

#pragma mark - Show AD

- (void)showADVideo
{
    if (TTAdSplashADTypeVideoFullscreen == _adModel.splashADType) { // 全屏视频广告
        
        [self prepareToDisplayADVideoWithRelatedView:self.videoView];
        
    } else if (TTAdSplashADTypeVideoCenterFit_16_9 == _adModel.splashADType) { // 带底图的视频广告
        
        // 非全屏视频底图
        [self setupADImage];
        CGSize size = _adSplashImgView.image.size;
        if (size.width > 0 && size.height > 0) {
            [self prepareToDisplayADVideoWithRelatedView:_adSplashImgView];
        }
    }
}

- (void)prepareToDisplayADVideoWithRelatedView:(UIView *)videoRelatedView
{
    // 显示之前初始化后被隐藏的view
    self.videoView.hidden = NO;
    videoRelatedView.alpha = 0.2;
    
    [self refreshUI];
    
    [UIView animateWithDuration:.35 animations:^{
        videoRelatedView.alpha = 1;
    }];
}

#pragma mark -  TTAdSplashVideoViewDelegate

- (void)splashVideoView:(TTAdSplashVideoView *)videoView playStatus:(TTAdSplashVideoStatus)status
{
    if (videoView != self.videoView) {
        return;
    }
    switch (status) {
        case TTAdSplashVideoStatus_Ready:
        {
            // 开始播放第一帧画面
            [self showADVideo];
        }
            break;
        default:
            break;
    }
}

#pragma mark - getter methods

- (UIImageView *)logoImgView
{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ad_splash_video_logo"]];
        _logoImgView.frame = (CGRect){14, 14, _logoImgView.frame.size};
        [self.videoView addSubview:_logoImgView];
    }
    return _logoImgView;
}

- (UIButton *)style1ViewButton
{
    if (!_style1ViewButton) {
        _style1ViewButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _style1ViewButton.userInteractionEnabled = NO;
        _style1ViewButton.hidden = YES;
        [_adSplashImgView addSubview:_style1ViewButton];
    }
    return _style1ViewButton;
}

- (UIButton *)style2ViewButton
{
    if (!_style2ViewButton) {
        _style2ViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _style2ViewButton.userInteractionEnabled = NO;
        _style2ViewButton.hidden = YES;
        [_style2ViewButton setBackgroundImage:[UIImage themedImageNamed:@"viewicon_splash"]
                                     forState:UIControlStateNormal];
        [_adSplashImgView addSubview:_style2ViewButton];
    }
    return _style2ViewButton;
}

@end


#pragma mark -
#pragma mark - TTAdSplashCollectionView

@interface TTAdSplashCollectionView : UICollectionView
@end

@implementation TTAdSplashCollectionView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self];
        CGFloat threshold = [TTDeviceHelper isPadDevice]?[UIScreen mainScreen].bounds.size.width:160;
        if (velocity.x > 0 && self.contentOffset.x == 0 &&
            [gestureRecognizer locationInView:self].x < threshold) {
            return NO;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

@end


#pragma mark -
#pragma mark - TTSettingADSplashVC

@interface TTAdSplashSettingVC () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, assign) UIEdgeInsets safeEdgeInsets;
@end

static NSString * const kTTAdSplashSettingCellIdentifier = @"kTTAdSplashSettingCellIdentifier";

@implementation TTAdSplashSettingVC
{
    TTAdSplashCollectionView *_adSplashCollectionView;
    NSArray                    *_adSplashModelArray;
    
    NSInteger                  _page;
    BOOL                       _needNotifyOthersOnDeactivationForAudioSession;
    TTAdSplashModel                  *_currentAdModel;
}

- (void)dealloc {
    if (_needNotifyOthersOnDeactivationForAudioSession) {
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ttHideNavigationBar = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _adSplashCollectionView = [[TTAdSplashCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:[self flowLayout]];
    _adSplashCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _adSplashCollectionView.backgroundColor = [UIColor clearColor];
    _adSplashCollectionView.dataSource = self;
    _adSplashCollectionView.delegate = self;
    _adSplashCollectionView.pagingEnabled = YES;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _adSplashCollectionView.bounces = NO;
    }
    [_adSplashCollectionView registerClass:[TTAdSplashSettingCell class]
                forCellWithReuseIdentifier:kTTAdSplashSettingCellIdentifier];
    [self.view addSubview:_adSplashCollectionView];
    
    
    // 获取当前可用的广告资源,改为只要缓存在本地的广告都会展示
    _adSplashModelArray = [self suitableADSplashModels];
    
    if (_adSplashModelArray.count == 0) {
        UIImageView *bgImgView = [TTAdSplashSettingVC adSplashBgImageViewWithFrame:self.view.frame];
        if ([TTDeviceHelper isPadDevice]) {
            bgImgView.image = [UIImage imageNamed:@"LaunchImage-700-Portrait~ipad.png"];
            bgImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
        }
        [self.view insertSubview:bgImgView atIndex:0];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    }
    else{
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationNone];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.ttStatusBarStyle = UIStatusBarStyleDefault;
    }
    else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationNone];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        self.safeEdgeInsets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
    } else {
        self.safeEdgeInsets = UIEdgeInsetsZero;
    }
    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.view.backgroundColor = [UIColor blackColor];
    }
    else{
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    _adSplashCollectionView.frame = CGRectMake(0, self.safeEdgeInsets.top, self.view.width, self.view.height - self.safeEdgeInsets.top);
    // 处理横竖屏旋转时距左右间距的变化
    //    [self updateNatantViewWithSubjectModel:_currSubjectModel];
    //        setFrameWithX(_titleLabel, kSidePadding);
    
    // 处理横竖屏旋转时Cell错位的问题
    
    if (_adSplashModelArray.count > 0) {
        [_adSplashCollectionView.collectionViewLayout  invalidateLayout];
        [_adSplashCollectionView setCollectionViewLayout:[self flowLayout] animated:NO];
        
        
        [_adSplashCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_page inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    
    //
    //    if (!_hasRefreshBarAppearanceWhenLoad) {
    //        [self doShowOrHideBarsAnimationWithOrientationChanged:YES];
    //        _hasRefreshBarAppearanceWhenLoad = YES;
    //    }
    
}

- (UICollectionViewFlowLayout *)flowLayout
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0.0f;
    flowLayout.minimumLineSpacing = 0.0f;
    flowLayout.itemSize = _adSplashCollectionView.bounds.size;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    return flowLayout;
}

+ (UIImageView *)adSplashBgImageViewWithFrame:(CGRect)viewFrame
{
    UIImageView *bgImgaeView = [[UIImageView alloc] initWithFrame:viewFrame];
    
    NSString *imgName = @"LaunchImage-800-Portrait-736h@3x.png";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        imgName = @"LaunchImage-800-Portrait-736h@3x.png";
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 &&
        ([UIScreen mainScreen].bounds.size.height == 480)) {
        imgName = @"LaunchImage-700@2x.png";
    }
    bgImgaeView.image = [UIImage imageNamed:imgName];
    bgImgaeView.backgroundColor = [UIColor whiteColor];
    bgImgaeView.contentMode = UIViewContentModeScaleAspectFit;
    return bgImgaeView;
}

// 获取当前可用的广告资源
- (NSArray *)suitableADSplashModels
{
    NSArray *splashModels = [TTAdSplashManager getSplashModels];
    if ([splashModels count] == 0) {
        return nil;
    }
    
    NSMutableArray *suitableADSplashModelArray = [NSMutableArray arrayWithCapacity:splashModels.count];
    
    // NSLog(@"---- 目前共 %@ 组广告资源", @([splashModels count]));
    [splashModels enumerateObjectsUsingBlock:^(TTAdSplashModel *adModel, NSUInteger idx, BOOL *stop) {
        // NSLog(@">>>> 第 %@ 组广告资源", @(idx));
        
        __block TTAdSplashModel *suitableADModel;
        
        // 先找是否有符合条件的分时广告图
        [adModel.intervalCreatives enumerateObjectsUsingBlock:^(TTAdSplashModel *icADModel, NSUInteger idx, BOOL *stop) {
            if ([TTAdSplashSettingVC isSuitableADModel:icADModel isIntervalCreatives:YES]) {
                suitableADModel = icADModel;
                *stop = YES;
                // NSLog(@"Get 分时广告: [%@]", icADModel.splashURLString);
            }
        }];
        
        // 若找到，则 continue；否则，再找是否有符合条件的默认广告图
        if (!suitableADModel) {
            if ([TTAdSplashSettingVC isSuitableADModel:adModel isIntervalCreatives:NO]) {
                suitableADModel = adModel;
                // NSLog(@"Get 默认广告: [%@]", adModel.splashURLString);
            }
        }
        
        if (suitableADModel) {
            [suitableADSplashModelArray addObject:suitableADModel];
        }
    }];
    
    return suitableADSplashModelArray;
}

- (void)skipButtonPressed:(UIButton *)skipButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

//分时广告
+ (BOOL)isSuitableADModel:(TTAdSplashModel *)model isIntervalCreatives:(BOOL)isInterval
{
    //1 广告未过期
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval expireTime = model.splashExpireSeconds + model.requestTimeInterval + model.splashDisplayAfterSecond;
    if (currentTime > expireTime) {
        return NO;
    }
    //2  头条封面展示当天广告
    NSTimeInterval deadlineTime = currentTime;
    if (!isInterval) {
        NSDate *currentDate = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:currentDate];
        [components setHour:24-components.hour];
        [components setMinute:-components.minute];
        [components setSecond:-components.second];
        deadlineTime = [[cal dateByAddingComponents:components toDate:currentDate options:0] timeIntervalSince1970];
        //deadlineTime设置为当天23:59:59
        deadlineTime -= 5;
    }
    NSTimeInterval startTime = model.requestTimeInterval + model.splashDisplayAfterSecond;
    
    if (deadlineTime < startTime) {
        return NO;
    }
    
    return YES;
    
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _adSplashModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTAdSplashSettingCell *adSplashCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTTAdSplashSettingCellIdentifier forIndexPath:indexPath];
    TTAdSplashModel * adModel = _adSplashModelArray[indexPath.row];
    _currentAdModel = adModel;
    [self adjustAudioSessionWithAdModel:adModel];
    [adSplashCell setupCellWithADModel:adModel];
    adSplashCell.delegate = self;
    return adSplashCell!=nil ? adSplashCell : [[UICollectionViewCell alloc] init];
}

#pragma mark - UICollectionViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self adjustPage:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self adjustPage:scrollView];
    }
}

- (void)adjustPage:(UIScrollView *)scrollView {
    CGFloat width = scrollView.width;
    if (width > 0) {
        _page = floor(scrollView.contentOffset.x / width);
    }
    if (_page < _adSplashModelArray.count) {
        TTAdSplashModel * adModel = _adSplashModelArray[_page];
        if (adModel != _currentAdModel) {
            _currentAdModel = adModel;
            [self adjustAudioSessionWithAdModel:adModel];
        }
    }
}

- (void)adjustAudioSessionWithAdModel:(TTAdSplashModel *)adModel {
    if (TTAdSplashADTypeVideoFullscreen == adModel.splashADType || TTAdSplashADTypeVideoCenterFit_16_9 == adModel.splashADType) {
        //视频广告
        if (adModel.videoMute) {
            //无声
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
            if (_needNotifyOthersOnDeactivationForAudioSession) {
                [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
                _needNotifyOthersOnDeactivationForAudioSession = NO;
            }else{
                [[AVAudioSession sharedInstance] setActive:NO error:nil];
            }
        }else {
            //有声
            if (!_needNotifyOthersOnDeactivationForAudioSession) {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
                _needNotifyOthersOnDeactivationForAudioSession = YES;
            }
        }
    }else {
        //图片广告
        if (_needNotifyOthersOnDeactivationForAudioSession) {
            [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
            _needNotifyOthersOnDeactivationForAudioSession = NO;
        }
    }
}

@end

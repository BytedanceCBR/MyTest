//
//  FHDetailPictureViewController.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/15.
//

#import "FHDetailPictureViewController.h"
#import "TTShowImageView.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "UIImage+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "TTTracker.h"
#import "TTImagePreviewAnimateManager.h"
#import "ALAssetsLibrary+TTImagePicker.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHFloorPanPicShowViewController.h"
#import "FHDetailPictureNavView.h"
#import "FHDetailPictureTitleView.h"
#import "TTNavigationController.h"
#import "FHShowVideoView.h"
#import <Photos/Photos.h>
#import "HTSDeviceManager.h"
#import "FHDetailVideoInfoView.h"
#import "NSDictionary+TTAdditions.h"
#import "FHLoadingButton.h"
#define kFHDPTopBarHeight 44.f
#define kFHDPBottomBarHeight 54.f

#define kFHDPMoveDirectionStartOffset 20.f
NSString *const kFHDetailLoadingNotification = @"kFHDetailLoadingNotification";

@interface FHDetailPictureViewController ()<UIScrollViewDelegate, TTShowImageViewDelegate,TTPreviewPanBackDelegate,UIGestureRecognizerDelegate, FHVideoViewDelegate>
{
    BOOL alreadyFinished;// 防止多次点击回调造成多次popController
    BOOL _addedToContainer;
    BOOL _navBarHidden;
    BOOL _statusBarHidden;
    UIStatusBarStyle _lastStatusBarStyle;
    BOOL _isRotating;
    BOOL _reachDismissCondition; //是否满足关闭图片控件条件
    BOOL _reachDragCondition; //是否满足过一次触发手势条件
}
@property(nonatomic, copy)TTPhotoScrollViewDismissBlock dismissBlock;
@property(nonatomic, strong)UIScrollView * photoScrollView;
@property(nonatomic, strong)UIView *containerView;

@property(nonatomic, assign, readwrite)NSInteger currentIndex;
@property(nonatomic, assign, readwrite)NSInteger photoCount;

@property(nonatomic, strong) NSMutableSet * photoViewPools;

@property (nonatomic, strong)   FHDetailMediaHeaderModel       *mediaHeaderModel;
@property (nonatomic, assign)   NSUInteger       vedioCount;// 视频的个数
@property (nonatomic, assign)   BOOL       isShowenVideo;// 是否正在显示视频
@property(nonatomic, strong) NSMutableSet * vedioViewPools;
@property (nonatomic, strong)   FHDetailVideoInfoView       *videoInfoView;
@property (nonatomic, assign)   BOOL       startDismissSelf;
@property (nonatomic, assign)   BOOL       disableAutoPlayVideo;// 禁用自动播放和暂停功能
@property (nonatomic, assign)   BOOL       didEnterFullscreen;// 进入全屏视频

@property(nonatomic, strong)UIView * topBar;
@property (nonatomic, strong)   FHDetailPictureNavView       *naviView;
@property (nonatomic, strong)   FHDetailPictureTitleView       *pictureTitleView;
@property (nonatomic, strong)   NSArray       *pictureTitles;
@property (nonatomic, strong)   NSArray       *pictureNumbers;

@property(nonatomic, strong)UIView * bottomBar;
@property (nonatomic, strong)   UIButton       *onlineBtn;
@property (nonatomic, strong)   FHLoadingButton       *contactBtn;

@property(nonatomic, strong)UIPanGestureRecognizer * panGestureRecognizer;
@property(nonatomic, strong)UILongPressGestureRecognizer *longPressGestureRecognizer;

//手势识别方向
@property (nonatomic, assign) TTPhotoScrollViewMoveDirection direction;
//进入的设备方向，如果与点击退出不同，则使用渐隐动画
@property (nonatomic, assign) UIInterfaceOrientation enterOrientation;

//交互式推动退出所需的属性
@property (nonatomic, strong) TTImagePreviewAnimateManager *animateManager;
@property (nonatomic, copy) NSArray<NSValue *> *animateFrames;
@property (nonatomic, copy) NSString *locationStr;

@end

@implementation FHDetailPictureViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _startDismissSelf = NO;
        _startWithIndex = 0;
        _currentIndex = -1;
        _photoCount = 0;
        _vedioCount = 0;
        _isShowenVideo = NO;
        _longPressToSave = YES;
        _disableAutoPlayVideo = NO;
        _didEnterFullscreen = NO;
        _isShowAllBtns = YES;
        
        self.ttHideNavigationBar = YES;
        
        _addedToContainer = NO;
        
        self.photoViewPools = [[NSMutableSet alloc] initWithCapacity:5];
        self.vedioViewPools = [[NSMutableSet alloc] initWithCapacity:2];
        
        self.ttDisableDragBack = YES;
        
        _isRotating = NO;
        
        _whiteMaskViewEnable = YES;
        
        _statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
        _lastStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        [self setCurrentStatusStyle];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFollowStatus:) name:@"follow_up_did_changed" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshCallBtnLoadingState:) name:kFHDetailLoadingNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self resetStatusStyle];
    @try {
        [self removeObserver:self forKeyPath:@"self.view.frame"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}
- (void)refreshCallBtnLoadingState:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSString *houseId = [userInfo tt_stringValueForKey:@"house_id"];
    NSInteger loading = [userInfo tt_integerValueForKey:@"show_loading"];
    if (![houseId isEqualToString:self.houseId]) {
        return;
    }
    if (loading) {
        [self.contactBtn startLoading];
    }else {
        [self.contactBtn stopLoading];
    }
}
- (void)refreshFollowStatus:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSString *followId = [userInfo tt_stringValueForKey:@"followId"];
    NSInteger followStatus = [userInfo tt_integerValueForKey:@"followStatus"];
    if (![followId isEqualToString:self.houseId]) {
        return;
    }
    self.followStatus = followStatus;
}
- (void)setFollowStatus:(NSInteger)followStatus
{
    _followStatus = followStatus;
    [self.videoInfoView setFollowStatus:followStatus];
}

- (void)setCurrentStatusStyle {
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)resetStatusStyle {
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                            withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:_lastStatusBarStyle];
}

#pragma mark - View Life Cycle
- (void)loadView
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.view = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addObserver:self forKeyPath:@"self.view.frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCurrentStatusStyle];
    self.topVC.ttStatusBarStyle = UIStatusBarStyleLightContent;
    // 修复iOS7下，photoScrollView 子视图初始化位置不正确的问题
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // self.view
    self.view.backgroundColor = [UIColor clearColor];
    _containerView = [[UIView alloc] initWithFrame:self.view.frame];
    _containerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_containerView];
    
    // photoScrollView
    _photoScrollView = [[UIScrollView alloc] initWithFrame:[self frameForPagingScrollView]];
    _photoScrollView.delegate = self;
    
    _photoScrollView.backgroundColor = [UIColor clearColor];
    _photoScrollView.pagingEnabled = YES;
    _photoScrollView.showsVerticalScrollIndicator = NO;
    _photoScrollView.showsHorizontalScrollIndicator = YES;
    
    if(@available(iOS 11.0 , *)){
        _photoScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:_photoScrollView];
    CGFloat topInset = 0;
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        topInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    if (topInset < 1) {
        topInset = 20;
    }
    _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kFHDPTopBarHeight + topInset)];
    _topBar.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.3]; // [UIColor clearColor];
    [self.view addSubview:_topBar];
    __weak typeof(self) weakSelf = self;
    _naviView = [[FHDetailPictureNavView alloc] initWithFrame:CGRectMake(0, topInset, self.view.width, kFHDPTopBarHeight)];
    _naviView.showAlbum = self.smallImageInfosModels > 0;
    _naviView.backActionBlock = ^{
        [weakSelf finished];
    };
    _naviView.albumActionBlock  = ^{
        [weakSelf albumBtnClick];
    };
    _naviView.videoTitle.currentTitleBlock = ^(NSInteger currentIndex) {
        // 1 视频 2 图片
        if (weakSelf.vedioCount > 0) {
            NSInteger tempIndex = 0;
            if (currentIndex == 1) {
                tempIndex = 0; // 视频
            }
            if (currentIndex == 2) {
                if (weakSelf.currentIndex < weakSelf.vedioCount) {
                    tempIndex = weakSelf.vedioCount;
                }
            }
            if (tempIndex >= 0 && tempIndex < weakSelf.photoCount && tempIndex != weakSelf.currentIndex) {
                CGFloat pageWidth = weakSelf.photoScrollView.frame.size.width;
                [weakSelf.photoScrollView setContentOffset:CGPointMake(pageWidth * tempIndex, 0) animated:NO];
            }
        }
    };
    _naviView.hasVideo = self.vedioCount > 0;
    if (self.vedioCount > 0) {
        // 有视频
        if (_startWithIndex < self.vedioCount) {
            _naviView.videoTitle.isSelectVideo = YES;
        } else {
            _naviView.videoTitle.isSelectVideo = NO;
        }
        // 特殊处理，如果只有视频
        if (self.photoCount == self.vedioCount) {
            _naviView.hasVideo = NO;
            _naviView.titleLabel.text = @"视频";
        }
    }
    [_topBar addSubview:_naviView];
    
    _pictureTitleView = [[FHDetailPictureTitleView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, 42)];
    _pictureTitleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_pictureTitleView];
    self.pictureTitleView.titleNames = self.pictureTitles;
    self.pictureTitleView.titleNums = self.pictureNumbers;
    self.pictureTitleView.currentIndexBlock = ^(NSInteger currentIndex) {
        // 选中图片标签
        NSInteger tempIndex = currentIndex;
        if (currentIndex == 0) {
            // 选中第一个标签，跳过视频
            tempIndex += weakSelf.vedioCount;
        }
        if (tempIndex >= 0 && tempIndex < weakSelf.photoCount) {
            CGFloat pageWidth = weakSelf.photoScrollView.frame.size.width;
            [weakSelf.photoScrollView setContentOffset:CGPointMake(pageWidth * tempIndex, 0) animated:NO];
        }
    };
    
    if (self.vedioCount > 0 && _isShowAllBtns) {
        _videoInfoView = [[FHDetailVideoInfoView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 67)];
        _videoInfoView.hidden = _startWithIndex >= self.vedioCount;
        [self.view addSubview:_videoInfoView];
        [self.videoInfoView setFollowStatus:self.followStatus];
        self.videoInfoView.priceLabel.text = self.priceStr;
        self.videoInfoView.infoLabel.text = self.infoStr;
        self.videoInfoView.shareActionBlock = self.shareActionBlock;
        self.videoInfoView.collectActionBlock = self.collectActionBlock;
    }
    
    if (self.isShowAllBtns) {
        _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - kFHDPBottomBarHeight, self.view.width, kFHDPBottomBarHeight)];
        _bottomBar.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_bottomBar];
    }
    
    
    if (self.mediaHeaderModel.contactViewModel) {
        CGFloat itemWidth = self.view.width - 40;
        BOOL showenOnline = self.mediaHeaderModel.contactViewModel.showenOnline;
        if (showenOnline) {
            itemWidth = (itemWidth - 15) / 2.0;
            // 在线联系
            UIButton *online = self.onlineBtn;
            if (self.mediaHeaderModel.contactViewModel.onLineName.length > 0) {
                NSString *title = self.mediaHeaderModel.contactViewModel.onLineName;
                [online setTitle:title forState:UIControlStateNormal];
                [online setTitle:title forState:UIControlStateHighlighted];
            }
            online.frame = CGRectMake(20, 0, itemWidth, 44);
            [self.bottomBar addSubview:online];
            // 电话咨询
            UIButton *contact = self.contactBtn;
            if (self.mediaHeaderModel.contactViewModel.phoneCallName.length > 0) {
                NSString *title = self.mediaHeaderModel.contactViewModel.phoneCallName;
                [contact setTitle:title forState:UIControlStateNormal];
                [contact setTitle:title forState:UIControlStateHighlighted];
            }
            contact.frame = CGRectMake(20 + itemWidth + 10, 0, itemWidth, 44);
            [self.bottomBar addSubview:contact];
        } else {
            // 电话咨询
            UIButton *contact = self.contactBtn;
            if (self.mediaHeaderModel.contactViewModel.phoneCallName.length > 0) {
                NSString *title = self.mediaHeaderModel.contactViewModel.phoneCallName;
                [contact setTitle:title forState:UIControlStateNormal];
                [contact setTitle:title forState:UIControlStateHighlighted];
            }
            contact.frame = CGRectMake(20, 0, itemWidth, 44);
            [self.bottomBar addSubview:contact];
        }
    }
    
    // layout
    NSInteger maxIndex = MAX(MAX([_imageInfosModels count], [_imageURLs count]), MAX([_images count], [_assetsImages count]))-1;
    _startWithIndex = MAX(0, MIN(maxIndex, _startWithIndex));
    [self setPhotoScrollViewContentSize];
    
    [self setCurrentIndex:_startWithIndex];
    [self scrollToIndex:_startWithIndex];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_panGestureRecognizer];
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    self.longPressGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_longPressGestureRecognizer];
    
    if ([TTImagePreviewAnimateManager interativeExitEnable]){
        self.animateManager.panDelegate = self;
        [_animateManager registeredPanBackWithGestureView:self.view];
        [self frameTransform];
    }
    TTNavigationController *navi = self.topVC.navigationController;
    if (navi && [navi isKindOfClass:[TTNavigationController class]]) {
        navi.panRecognizer.enabled = NO;
    }
    // 是否正在显示 视频
    self.isShowenVideo = _naviView.videoTitle.isSelectVideo;
    // lead_show 埋点
    if (self.mediaHeaderModel.contactViewModel) {
        [self addLeadShowLog:self.mediaHeaderModel.contactViewModel.contactPhone baseParams:[self.mediaHeaderModel.contactViewModel baseParams]];
    }
}

- (void)setIsShowenVideo:(BOOL)isShowenVideo {
    _isShowenVideo = isShowenVideo;
    if (isShowenVideo) {
        _pictureTitleView.hidden = YES;
        _videoInfoView.hidden = NO;
        [self.videoVC play];
    } else {
        _pictureTitleView.hidden = NO;
        _videoInfoView.hidden = YES;
        [self.videoVC pause];
    }
}

- (void)addLeadShowLog:(FHDetailContactModel *)contactPhone baseParams:(NSDictionary *)dic
{
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tracerDic = dic.mutableCopy;
        tracerDic[@"is_im"] = !isEmptyString(contactPhone.imOpenUrl) ? @"1" : @"0";
        tracerDic[@"is_call"] = contactPhone.phone.length < 1 ? @"0" : @"1";
        tracerDic[@"is_report"] = contactPhone.phone.length < 1 ? @"1" : @"0";
        tracerDic[@"is_online"] = contactPhone.unregistered ? @"1" : @"0";
        tracerDic[@"element_from"] = [self elementFrom];
        [FHUserTracker writeEvent:@"lead_show" params:tracerDic];
    }
}

- (void)closeBtnClick
{
    [self finished];
}

- (void)stayCallBack:(NSInteger)stayTime
{
    if (self.albumImageStayBlock) {
        self.albumImageStayBlock(self.currentIndex,stayTime);
    }
}

- (NSString *)elementFrom {
    NSString *element_from = @"be_null";
    if (self.currentIndex < self.vedioCount) {
        element_from = @"video";
    } else {
        element_from = @"large";
    }
    return element_from;
}

- (NSString *)videoId {
    NSString *video_id = @"";
    if (self.vedioCount <= 0) {
        return video_id;
    }
    if (self.currentIndex < self.vedioCount && self.mediaHeaderModel.vedioModel.videoID.length > 0) {
        video_id = self.mediaHeaderModel.vedioModel.videoID;
    } else {
        video_id = @"";
    }
    return video_id;
}

// 在线联系点击
- (void)onlineButtonClick:(UIButton *)btn {
    if (self.mediaHeaderModel.contactViewModel) {
        NSString *fromStr = @"app_oldhouse_picview";
        NSNumber *cluePage = nil;
        if (_houseType == FHHouseTypeNewHouse) {
            fromStr = @"app_newhouse_picview";
            cluePage = @(FHClueIMPageTypeCNewHousePicview);
        }
        NSMutableDictionary *extraDic = @{@"realtor_position":@"online",
                                          @"position":@"online",
                                          @"element_from":[self elementFrom],
                                          @"from":fromStr
                                          }.mutableCopy;
        NSString *vid = [self videoId];
        if ([vid length] > 0) {
            extraDic[@"item_id"] = vid;
        }
        if (cluePage) {
            extraDic[kFHCluePage] = cluePage;
        }
        [self.mediaHeaderModel.contactViewModel onlineActionWithExtraDict:extraDic];
    }
}

// 电话咨询点击
- (void)contactButtonClick:(UIButton *)btn {
    if (self.mediaHeaderModel.contactViewModel) {
        NSString *fromStr = @"app_oldhouse_picview";
        NSNumber *cluePage = nil;
        if (_houseType == FHHouseTypeNewHouse) {
            fromStr = @"app_newhouse_picview";
            cluePage = @(FHClueIMPageTypeCNewHousePicview);
        }
        NSMutableDictionary *extraDic = @{@"realtor_position":@"phone_button",
                                          @"position":@"report_button",
                                          @"element_from":[self elementFrom]
                                          }.mutableCopy;
        NSString *vid = [self videoId];
        if ([vid length] > 0) {
            extraDic[@"item_id"] = vid;
        }
        extraDic[@"from"] = fromStr;
        if (cluePage) {
            extraDic[kFHCluePage] = cluePage;
        }
        // todo zjing form clue_page

        [self.mediaHeaderModel.contactViewModel contactActionWithExtraDict:extraDic];
    }
}

- (UIButton *)onlineBtn {
    if (!_onlineBtn) {
        _onlineBtn = [[UIButton alloc] init];
        _onlineBtn.layer.cornerRadius = 4;
        _onlineBtn.titleLabel.font = [UIFont themeFontRegular:16];
        _onlineBtn.backgroundColor = [UIColor colorWithHexStr:@"#151515"];
        [_onlineBtn setTitleColor:[UIColor themeGray5] forState:UIControlStateNormal];
        [_onlineBtn setTitleColor:[UIColor themeGray5] forState:UIControlStateHighlighted];
        [_onlineBtn setTitle:@"在线联系" forState:UIControlStateNormal];
        [_onlineBtn setTitle:@"在线联系" forState:UIControlStateHighlighted];
        [_onlineBtn addTarget:self action:@selector(onlineButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _onlineBtn;
}

- (FHLoadingButton *)contactBtn {
    if (!_contactBtn) {
        _contactBtn = [[FHLoadingButton alloc]init];
        _contactBtn.layer.cornerRadius = 4;
        _contactBtn.titleLabel.font = [UIFont themeFontRegular:16];
        _contactBtn.backgroundColor = [UIColor colorWithHexStr:@"#151515"];
        [_contactBtn setTitleColor:[UIColor themeGray5] forState:UIControlStateNormal];
        [_contactBtn setTitleColor:[UIColor themeGray5] forState:UIControlStateHighlighted];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateNormal];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateHighlighted];
        [_contactBtn addTarget:self action:@selector(contactButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contactBtn;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        [self refreshUI];
    }
    CGFloat topInset = 0;
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        topInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    if (topInset < 1) {
        topInset = 20;
    }
    self.bottomBar.frame = CGRectMake(0, self.view.height - kFHDPBottomBarHeight - bottomInset, self.view.width, kFHDPBottomBarHeight);
    self.topBar.frame = CGRectMake(0, 0, self.view.width, kFHDPTopBarHeight + topInset);
    self.naviView.frame = CGRectMake(0, topInset, self.view.width, kFHDPTopBarHeight);
    self.pictureTitleView.frame = CGRectMake(0, topInset + kFHDPTopBarHeight, self.view.width, 42);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setCurrentStatusStyle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    TTNavigationController *navi = self.topVC.navigationController;
    if (navi && [navi isKindOfClass:[TTNavigationController class]]) {
        navi.panRecognizer.enabled = NO;
    }
    [self setCurrentStatusStyle];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf setCurrentStatusStyle];
    });
    if (self.currentIndex < self.vedioCount && !self.disableAutoPlayVideo) {
        // 视频
        if (self.videoVC.playbackState != TTVPlaybackState_Playing) {
            [self.videoVC play];
        }
    }
    self.disableAutoPlayVideo = NO;
    [self.pictureTitleView.colletionView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    TTNavigationController *navi = self.topVC.navigationController;
    if (navi && [navi isKindOfClass:[TTNavigationController class]]) {
        navi.panRecognizer.enabled = YES;
    }
    if (self.currentIndex < self.vedioCount && !self.startDismissSelf && !self.disableAutoPlayVideo) {
        // 视频
        if (self.videoVC.playbackState == TTVPlaybackState_Playing) {
            [self.videoVC pause];
        }
    }
    self.disableAutoPlayVideo = NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    _photoScrollView.delegate = nil;
    _isRotating = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    _photoScrollView.delegate = self;
    _isRotating = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"self.view.frame"]) {
        [self refreshUI];
    }
}

- (void)refreshUI
{
    // 横屏直接返回
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        return;
    }
    if (self.didEnterFullscreen) {
        // 进入全屏视频
        return;
    }
    self.containerView.frame = self.view.frame;
    _photoScrollView.frame = [self frameForPagingScrollView];
    [self setPhotoScrollViewContentSize];
    
    for (UIView * view in [_photoScrollView subviews]) {
        if ([view isKindOfClass:[TTShowImageView class]]) {
            TTShowImageView * v = (TTShowImageView *)view;
            v.frame = [self frameForPageAtIndex:v.tag];
            [v resetZoom];
            [v refreshUI];
        }
    }
    
    [self scrollToIndex:_currentIndex];
}


#pragma mark - Setter & Getter
// 设置初始化数据入口
- (void)setMediaHeaderModel:(FHDetailMediaHeaderModel *)mediaHeaderModel mediaImages:(NSArray *)images {
    if (mediaHeaderModel || images) {
        // 视频
        if (mediaHeaderModel.vedioModel && mediaHeaderModel.vedioModel.videoID.length > 0) {
            self.vedioCount = 1; // 有视频，目前只支持一个视频
        }
        // titles
        self.mediaHeaderModel = mediaHeaderModel;
        // 图片
        if ([images isKindOfClass:[NSArray class]]) {
            // 图片（视频 + 图片）
            [self setMediaImages:images];
        }
    }
}

- (void)setMediaHeaderModel:(FHDetailMediaHeaderModel *)mediaHeaderModel {
    if (_mediaHeaderModel != mediaHeaderModel) {
        _mediaHeaderModel = mediaHeaderModel;
        NSMutableArray *titles = [NSMutableArray new];
        NSMutableArray *numbers = [NSMutableArray new];
        __block BOOL isFirstItem = YES;
        for (FHDetailOldDataHouseImageDictListModel *listModel in mediaHeaderModel.houseImageDictList) {
            if (listModel.houseImageTypeName.length > 0) {
                NSInteger tempCount = 0;
                for (FHImageModel *imageModel in listModel.houseImageList) {
                    if (imageModel.url.length > 0) {
                        tempCount += 1;
                    }
                }
                if (tempCount > 0) {
                    [titles addObject:[NSString stringWithFormat:@"%@（%ld）",listModel.houseImageTypeName,tempCount]];
                    if (isFirstItem) {
                        isFirstItem = NO;
                        tempCount += self.vedioCount; // 把视频添加到第一个图片归类中
                    }
                    [numbers addObject:@(tempCount)];
                }
            }
        }
        // 只有一个分类时隐藏
        if (titles.count > 1) {
            self.pictureTitles = titles;
            self.pictureNumbers = numbers;
        }
    }
}

- (void)setMediaImages:(NSArray *)images {
    BOOL hasVideo = NO;
    if (self.mediaHeaderModel.vedioModel && self.mediaHeaderModel.vedioModel.videoID.length > 0) {
        hasVideo = YES;
    }
    if (images.count <= 0 && !hasVideo) {
        return;
    }
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:images.count];
    for(id<FHDetailPhotoHeaderModelProtocol> imgModel in images)
    {
        NSMutableDictionary *dict = [[imgModel toDictionary] mutableCopy];
        //change url_list from string array to dict array
        NSMutableArray *dictUrlList = [[NSMutableArray alloc] initWithCapacity:imgModel.urlList.count];
        for (NSString * url in imgModel.urlList) {
            if ([url isKindOfClass:[NSString class]]) {
                [dictUrlList addObject:@{@"url":url}];
            }else{
                [dictUrlList addObject:url];
            }
        }
        dict[@"url_list"] = dictUrlList;
        
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        model.imageType = TTImageTypeLarge;
        if (model) {
            [models addObject:model];
        }
    }
    // 视频
    if (self.mediaHeaderModel.vedioModel && self.mediaHeaderModel.vedioModel.videoID.length > 0) {
        NSMutableArray *dictUrlList = [NSMutableArray new];
        [dictUrlList addObject:@{@"url":self.mediaHeaderModel.vedioModel.imageUrl}];
        NSDictionary *dict = @{@"url_list":dictUrlList};
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        model.imageType = TTImageTypeLarge;
        if (model) {
            [models insertObject:model atIndex:0];
        }
    }
    self.imageInfosModels = models;
}

- (void)setImageURLs:(NSArray *)imageURLs
{
    if (_imageURLs != imageURLs) {
        _imageURLs = imageURLs;
        
        if (_imageURLs) {
            self.imageInfosModels = nil;
            self.images = nil;
            self.assetsImages = nil;
            self.multipleTypeImages = nil;
            _photoCount = [_imageURLs count];
        }
    }
}

- (void)setImageInfosModels:(NSArray *)imageInfosModels
{
    if (_imageInfosModels != imageInfosModels) {
        _imageInfosModels = imageInfosModels;
        
        if (_imageInfosModels) {
            self.imageURLs = nil;
            self.images = nil;
            self.assetsImages = nil;
            self.multipleTypeImages = nil;
            _photoCount = [_imageInfosModels count];
        }
    }
}

- (void)setImages:(NSArray *)images
{
    if (_images != images)
    {
        _images = images;
        
        if (_images)
        {
            self.imageURLs = nil;
            self.imageInfosModels = nil;
            self.assetsImages = nil;
            self.multipleTypeImages = nil;
            _photoCount = [_images count];
        }
    }
}

- (void)setAssetsImages:(NSArray *)assetsImages
{
    if (_assetsImages != assetsImages)
    {
        _assetsImages = assetsImages;
        
        if (_assetsImages)
        {
            self.imageURLs = nil;
            self.imageInfosModels = nil;
            self.images = nil;
            self.multipleTypeImages = nil;
            _photoCount = [assetsImages count];
        }
    }
}

- (void)setMultipleTypeImages:(NSArray *)multipleTypeImages
{
    if (_multipleTypeImages != multipleTypeImages)
    {
        _multipleTypeImages = multipleTypeImages;
        
        if (_multipleTypeImages)
        {
            self.imageURLs = nil;
            self.imageInfosModels = nil;
            self.images = nil;
            self.assetsImages = nil;
            _photoCount = [_multipleTypeImages count];
        }
    }
}

- (TTImagePreviewAnimateManager *)animateManager{
    if (_animateManager == nil){
        _animateManager = [[TTImagePreviewAnimateManager alloc] init];
        _animateManager.whiteMaskViewEnable = _whiteMaskViewEnable;
    }
    return _animateManager;
}

- (void)setWhiteMaskViewEnable:(BOOL)whiteMaskViewEnable{
    _whiteMaskViewEnable = whiteMaskViewEnable;
    _animateManager.whiteMaskViewEnable = whiteMaskViewEnable;
}

- (BOOL)newGestureEnable
{
    if (![TTImagePreviewAnimateManager interativeExitEnable]){
        return NO;
    }
    CGRect origionViewFrame = [self ttPreviewPanBackGetOriginView].frame;
    if (CGRectGetHeight(origionViewFrame) == 0 || CGRectGetWidth(origionViewFrame) == 0){
        return NO;
    }
    
    if (self.currentIndex < self.vedioCount) {
        // 视频不支持pan
        return NO;
    }
    
    return [self showImageViewAtIndex:_currentIndex].currentImageView.image != nil;
}

#pragma mark - Public

static BOOL kFHStaticPhotoBrowserAtTop = NO;
+ (BOOL)photoBrowserAtTop
{
    return kFHStaticPhotoBrowserAtTop;
}

#pragma mark - Private

- (void)frameTransform{
    UIView *targetView = [self ttPreviewPanBackGetBackMaskView];
    if (nil == targetView){
        return;
    }
    NSMutableArray *mutArray = [NSMutableArray array];
    for (NSValue *frameValue in self.placeholderSourceViewFrames){
        if ([frameValue isKindOfClass:[NSNull class]]){
            [mutArray addObject:[NSValue valueWithCGRect:CGRectZero]];
            continue;
        }
        CGRect frame = frameValue.CGRectValue;
        if (CGRectEqualToRect(frame, CGRectZero)){
            [mutArray addObject:frameValue];
            continue;
        }
        CGRect animateFrame = [targetView convertRect:frame fromView:nil];
        [mutArray addObject:[NSValue valueWithCGRect:animateFrame]];
    }
    _animateFrames = [mutArray copy];
}

- (void)setPlaceholderSourceViewFrames:(NSArray *)placeholderSourceViewFrames {
    _placeholderSourceViewFrames = placeholderSourceViewFrames;
    if ([TTImagePreviewAnimateManager interativeExitEnable]){
        [self frameTransform];
    }
}

- (CGRect)frameForPagingScrollView
{
    return self.view.bounds;
}

- (void)setPhotoScrollViewContentSize
{
    NSInteger pageCount = _photoCount;
    if (pageCount == 0) {
        pageCount = 1;
    }
    
    CGSize size = CGSizeMake(_photoScrollView.frame.size.width * pageCount, _photoScrollView.frame.size.height);
    [_photoScrollView setContentSize:size];
}

- (CGRect)frameForPageAtIndex:(NSInteger)index
{
    CGRect pageFrame = _photoScrollView.bounds;
    pageFrame.origin.x = (index * pageFrame.size.width);
    return pageFrame;
}

- (void)setCurrentIndex:(NSInteger)newIndex
{
    if (_currentIndex == newIndex || newIndex < 0) {
        return;
    }
    
    _currentIndex = newIndex;
    self.pictureTitleView.selectIndex = newIndex;
    self.naviView.videoTitle.isSelectVideo = newIndex < self.vedioCount;
    self.isShowenVideo = self.naviView.videoTitle.isSelectVideo;
    [self unloadPhoto:_currentIndex + 2];
    [self unloadPhoto:_currentIndex - 2];
    
    [self loadPhoto:_currentIndex visible:YES];
    [[self showImageViewAtIndex:_currentIndex] restartGifIfNeeded];
    [self loadPhoto:_currentIndex + 1 visible:NO];
    [self loadPhoto:_currentIndex - 1 visible:NO];
}

- (void)scrollToIndex:(NSInteger)index
{
    [_photoScrollView setContentOffset:CGPointMake((CGRectGetWidth(_photoScrollView.frame) * index), 0)
                              animated:NO];
}

- (void)setUpShowImageView:(TTShowImageView *)showImageView atIndex:(NSUInteger)index
{
    showImageView.tag = index;
    showImageView.gifRepeatIfHave = YES;
    [showImageView resetZoom];
    
    if ([_placeholders count] > index && [[_placeholders objectAtIndex:index] isKindOfClass:[UIImage class]]) {
        showImageView.placeholderImage = [_placeholders objectAtIndex:index];
    } else {
        showImageView.placeholderImage = nil;
    }
    
    if ([_placeholderSourceViewFrames count] > index && [_placeholderSourceViewFrames objectAtIndex:index] != [NSNull null]) {
        showImageView.placeholderSourceViewFrame = [[_placeholderSourceViewFrames objectAtIndex:index] CGRectValue];
    } else {
        showImageView.placeholderSourceViewFrame = CGRectZero;
    }
    
    if ([_imageInfosModels count] > index) {
        [showImageView setImageInfosModel:[_imageInfosModels objectAtIndex:index]];
    }
    else if ([_imageURLs count] > index) {
        [showImageView setLargeImageURLString:[_imageURLs objectAtIndex:index]];
    }
    else if ([_images count] > index) {
        [showImageView setImage:[_images objectAtIndex:index]];
    }
    else if ([_assetsImages count] > index) {
        id assetImage = [_assetsImages objectAtIndex:index];
        if ([assetImage isKindOfClass:[ALAsset class]]) {
            [showImageView setAsset:assetImage];
        } else if ([assetImage isKindOfClass:[UIImage class]]) {
            [showImageView setImage:assetImage];
        }
    }
    else if ([_multipleTypeImages count] > index) {
        
        id multipleTypeImage = [_multipleTypeImages objectAtIndex:index];
        
        if ([multipleTypeImage isKindOfClass:[ALAsset class]]) {
            [showImageView setAsset:multipleTypeImage];
        } else if ([multipleTypeImage isKindOfClass:[UIImage class]]) {
            [showImageView setImage:multipleTypeImage];
        }
        else if ([multipleTypeImage isKindOfClass:[NSURL class]]) {
            
            ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib assetForURL:multipleTypeImage resultBlock:^(ALAsset *asset) {
                [showImageView setImage:[ALAssetsLibrary tt_getBigImageFromAsset:asset]];
            } failureBlock:^(NSError *error) {
                [showImageView setLargeImageURLString:multipleTypeImage];
            }];
        }
        else if ([multipleTypeImage isKindOfClass:[NSString class]]) {
            [showImageView setLargeImageURLString:multipleTypeImage];
        }
        else if ([multipleTypeImage isKindOfClass:[TTImageInfosModel class]]) {
            [showImageView setImageInfosModel:multipleTypeImage];
        }
    }
}

- (void)loadPhoto:(NSInteger)index visible:(BOOL)visible
{
    if (index < 0 || index >= _photoCount) {
        return;
    }
    
    if (index < self.vedioCount) {
        // 视频
        if ([self isPhotoViewExistInScrollViewForIndex:index]) {
            [[self showImageViewAtIndex:index] setVisible:visible];
            FHShowVideoView * tempVedioView = (FHShowVideoView *)[self showImageViewAtIndex:index];
            
            if (visible) {
                [tempVedioView setNeedsLayout];
                // 是否可见
                tempVedioView.videoVC = self.videoVC;
            }
            [tempVedioView currentImageView].alpha = 0;
            tempVedioView.visible = visible;
            return;
        }
        
        FHShowVideoView * showVedioView = [_vedioViewPools anyObject];
        
        if (showVedioView == nil) {
            showVedioView = [[FHShowVideoView alloc] initWithFrame:[self frameForPageAtIndex:index]];
            showVedioView.videoVC = self.videoVC;
            showVedioView.delegate = self;
            showVedioView.backgroundColor = [UIColor clearColor];
            showVedioView.delegate = self;
        }
        else {
            [_vedioViewPools removeObject:showVedioView];
        }
        
        showVedioView.frame = [self frameForPageAtIndex:index];
        if (self.mediaHeaderModel.vedioModel) {
            
        }
        showVedioView.loadingCompletedAnimationBlock = ^{
            // nothing
        };
        // 显示图片
        [self setUpShowImageView:showVedioView atIndex:index];
        showVedioView.visible = visible;
        [showVedioView currentImageView].alpha = 0;
        // 设置视频数据
        if (visible) {
            // 是否可见
            [showVedioView setNeedsLayout];
            showVedioView.videoVC = self.videoVC;
        } else {
            
        }
        
        [_photoScrollView addSubview:showVedioView];
    } else {
        // 图片
        if ([self isPhotoViewExistInScrollViewForIndex:index]) {
            [[self showImageViewAtIndex:index] setVisible:visible];
            return;
        }
        
        TTShowImageView * showImageView = [_photoViewPools anyObject];
        
        if (showImageView == nil) {
            showImageView = [[TTShowImageView alloc] initWithFrame:[self frameForPageAtIndex:index]];
            showImageView.backgroundColor = [UIColor clearColor];
            showImageView.delegate = self;
        }
        else {
            [_photoViewPools removeObject:showImageView];
        }
        [showImageView currentImageView].alpha = 1;
        showImageView.frame = [self frameForPageAtIndex:index];
        
        showImageView.loadingCompletedAnimationBlock = ^{
            // nothing
        };
        [self setUpShowImageView:showImageView atIndex:index];
        showImageView.visible = visible;
        
        [_photoScrollView addSubview:showImageView];
    }
}

- (BOOL)isPhotoViewExistInScrollViewForIndex:(NSInteger)index
{
    BOOL exist = NO;
    for (UIView * subView in [_photoScrollView subviews]) {
        if ([subView isKindOfClass:[TTShowImageView class]] && subView.tag == index) {
            exist = YES;
        }
    }
    return exist;
}

- (TTShowImageView *)showImageViewAtIndex:(NSInteger)index
{
    if (index < 0 || index >= _photoCount) {
        return nil;
    }
    
    for (UIView * subView in [_photoScrollView subviews]) {
        if ([subView isKindOfClass:[TTShowImageView class]] && subView.tag == index) {
            return (TTShowImageView *)subView;
        }
    }
    
    return nil;
}

- (void)unloadPhoto:(NSInteger)index
{
    if (index < 0 || index >= _photoCount) {
        return;
    }
    
    NSArray *tempSubViews = [[_photoScrollView subviews] copy];
    for (UIView * subView in tempSubViews) {
        if ([subView isKindOfClass:[TTShowImageView class]] && subView.tag == index) {
            if (index < self.vedioCount) {
                // 视频
                [_vedioViewPools addObject:subView];
                [subView removeFromSuperview];
            } else {
                // 图片
                [_photoViewPools addObject:subView];
                [subView removeFromSuperview];
            }
        }
    }
}

- (void)finished
{
    if (_dismissBlock) {
        _dismissBlock();
    }
    if (_addedToContainer) {
        [self dismissSelf];
        _addedToContainer = NO;
    } else {
        [self dismissAnimated:NO];
    }
}

- (void)albumBtnClick
{
    if (self.imageInfosModels.count == 0) {
        return;
    }
    
    if (self.albumImageBtnClickBlock) {
        self.albumImageBtnClickBlock(self.currentIndex);
    }
    
    FHFloorPanPicShowViewController *showVC = [[FHFloorPanPicShowViewController alloc] init];
    showVC.pictsArray = self.smallImageInfosModels;
    __weak typeof(self)weakSelf = self;
    showVC.albumImageBtnClickBlock = ^(NSInteger index){
        if (index >= 0) {
            [weakSelf.photoScrollView setContentOffset:CGPointMake(self.view.frame.size.width * index, 0) animated:NO];
        }
    };
    
    showVC.albumImageStayBlock = ^(NSInteger index, NSInteger stayTime) {
        [self stayCallBack:stayTime];
    };
    
    [self presentViewController:showVC animated:NO completion:nil];
}

- (void)backButtonClicked
{
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated
{
    if (alreadyFinished) {
        return;
    }
    
    if(self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:animated];
    }
    else
    {
        [self dismissViewControllerAnimated:animated completion:NULL];
    }
    kFHStaticPhotoBrowserAtTop = NO;
    alreadyFinished = YES;
}

#pragma mark - UIScrollViewDelegate
//When you flick quickly and continuously, scrollViewDidEndDecelerating method will not receive any message,which means not be called, while scrollViewDidEndDragging:willDecelerate still receive the message. because the dragging is so quick that the previous decelerating be ignored.
//From: http://stackoverflow.com/questions/12002853/how-to-determine-if-uiscrollview-flicks-to-next-page-when-paging

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    
    float fractionalPage = (scrollView.contentOffset.x + pageWidth / 2) / pageWidth;
    
    NSInteger page = floor(fractionalPage);
    if (page != _currentIndex) {
        if (self.indexUpdatedBlock) {
            self.indexUpdatedBlock(_currentIndex, page);
        }
        [self setCurrentIndex:page];
    }
}

#pragma mark - TTShowImageViewDelegate

- (void)showImageViewOnceTap:(TTShowImageView *)imageView
{
    if ([imageView isKindOfClass:[FHShowVideoView class]]) {
        // 视频
        UITapGestureRecognizer *tapGes = imageView.tapGestureRecognizer;
        if (tapGes) {
            CGRect frame = [imageView currentImageView].frame;
            UIView * touchView = tapGes.view;
            
            CGPoint point = [tapGes locationInView:touchView];
            if (!CGRectContainsPoint(frame, point)) {
                [self finished];
            } else {
                // 相当于是视频部分被点击了
                // [self videoViewClick:imageView];
            }
        } else {
            [self finished];
        }
    } else {
        [self finished];
    }
}

#pragma mark - FHVideoViewDelegate

- (void)videoFrameChanged:(CGRect)videoFrame isVerticalVideo:(BOOL)isVerticalVideo {
    if (self.currentIndex >= self.vedioCount) {
        // 非视频
        return;
    }
    CGSize mainSize = [UIScreen mainScreen].bounds.size;
    if (isVerticalVideo) {
        CGFloat bottomInset = 0;
        if (@available(iOS 11.0, *)) {
            bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        }
        self.videoInfoView.frame = CGRectMake(0, mainSize.height - (bottomInset + 141), mainSize.width, 141);
        self.videoInfoView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.3];
    } else {
        self.videoInfoView.backgroundColor = [UIColor clearColor];
        self.videoInfoView.frame = CGRectMake(0, videoFrame.size.height + videoFrame.origin.y + 14, mainSize.width, 67);
    }
}

// 进入全屏
- (void)playerDidEnterFullscreen {
    _disableAutoPlayVideo = YES;
    _didEnterFullscreen = YES;
}

// 离开全屏
- (void)playerDidExitFullscreen {
    _disableAutoPlayVideo = YES;
    _didEnterFullscreen = NO;
}

#pragma mark -- rotate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    BOOL result = NO;
    if([TTDeviceHelper isPadDevice])
    {
        result = YES;
    }
    else
    {
        result = interfaceOrientation == UIInterfaceOrientationPortrait;
    }
    
    return result;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (![TTDeviceHelper isPadDevice]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)saveButtonClicked:(id)sender
{
    TTShowImageView * currentImageView = [self showImageViewAtIndex:_currentIndex];
    [currentImageView saveImage];
    if(self.saveImageBlock){
        self.saveImageBlock(self.currentIndex);
    }
}


- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    if (_dragToCloseDisabled || self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        return;
    }
    if (self.currentIndex < self.vedioCount) {
        // 视频不支持pan
        return;
    }
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    CGPoint velocity = [recognizer velocityInView:recognizer.view.superview];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            [self refreshPhotoViewFrame:translation velocity:velocity];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self animatePhotoViewWhenGestureEnd];
            break;
        }
        default:
            break;
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (!_longPressToSave || self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        return;
    }
    
    if (self.currentIndex < self.vedioCount) {
        // 视频不支持pan
        return;
    }
    
    TTShowImageView * currentImageView = [self showImageViewAtIndex:_currentIndex];
    CGRect frame = [currentImageView currentImageView].frame;
    UIView * touchView = recognizer.view;
    
    CGPoint point = [recognizer locationInView:touchView];
    if (!CGRectContainsPoint(frame, point)) {
        return;
    }
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self alertSheetShow];
            break;
        default:
            break;
    }
}

- (void)alertSheetShow {
    if (self.topVC) {
        __weak typeof(self) weakSelf = self;
        UIAlertController *alertController = [[UIAlertController alloc] init];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"保存图片到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (PHAuthorizationStatusAuthorized == status) {
                [weakSelf saveButtonClicked:nil];
            } else {
                // 请求权限
                [HTSDeviceManager requestPhotoLibraryPermission:^(BOOL success) {
                    if (success) {
                        [weakSelf saveButtonClicked:nil];
                    } else {
                        [HTSDeviceManager presentPhotoLibraryDeniedAlert];
                    }
                }];
            }
        }]];
        
        [self.topVC presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Pan close gesture
//整体的动画
- (void)refreshPhotoViewFrame:(CGPoint)translation velocity:(CGPoint)velocity
{
    if (self.direction == TTPhotoScrollViewMoveDirectionNone) {
        //刚开始识别方向
        if (translation.y > kFHDPMoveDirectionStartOffset) {
            self.direction = TTPhotoScrollViewMoveDirectionVerticalBottom;
        }
        if (translation.y < -kFHDPMoveDirectionStartOffset) {
            self.direction = TTPhotoScrollViewMoveDirectionVerticalTop;
        }
    } else {
        //重新识别方向
        TTPhotoScrollViewMoveDirection currentDirection = TTPhotoScrollViewMoveDirectionNone;
        if (translation.y > kFHDPMoveDirectionStartOffset) {
            currentDirection = TTPhotoScrollViewMoveDirectionVerticalBottom;
        } else if (translation.y < -kFHDPMoveDirectionStartOffset) {
            currentDirection = TTPhotoScrollViewMoveDirectionVerticalTop;
        } else {
            currentDirection = TTPhotoScrollViewMoveDirectionNone;
        }
        
        if (currentDirection == TTPhotoScrollViewMoveDirectionNone) {
            self.direction = currentDirection;
            return; //忽略其他手势
        }
        
        BOOL verticle = (self.direction == TTPhotoScrollViewMoveDirectionVerticalBottom || self.direction == TTPhotoScrollViewMoveDirectionVerticalTop);
        CGFloat y = 0;
        if (self.direction == TTPhotoScrollViewMoveDirectionVerticalTop) {
            y = translation.y + kFHDPMoveDirectionStartOffset;
        } else if (self.direction == TTPhotoScrollViewMoveDirectionVerticalBottom){
            y = translation.y - kFHDPMoveDirectionStartOffset;
        }
        
        CGFloat yFraction = fabs(translation.y / CGRectGetHeight(self.photoScrollView.frame));
        yFraction = fminf(fmaxf(yFraction, 0.0), 1.0);
        
        //距离判断+速度判断
        if (verticle) {
            if (yFraction > 0.2) {
                _reachDismissCondition = YES;
            } else {
                _reachDismissCondition  = NO;
            }
            
            if (velocity.y > 1500) {
                _reachDismissCondition = YES;
            }
        }
        
        CGRect frame = CGRectMake(0, y, CGRectGetWidth(self.photoScrollView.frame), CGRectGetHeight(self.photoScrollView.frame));
        self.photoScrollView.frame = frame;
        
        //下拉动画
        if (verticle) {
            _reachDragCondition = YES;
            [self addAnimatedViewToContainerView:yFraction];
        }
        
    }
    
}

//释放的动画
- (void)animatePhotoViewWhenGestureEnd
{
    TTShowImageView *imageView = [self showImageViewAtIndex:_currentIndex];
    if (!_reachDragCondition) {
        imageView.hidden = NO;
        return; //未曾满足过一次识别手势，不触发动画
    } else {
        _reachDragCondition = NO;
    }
    
    CGRect endRect = [self frameForPagingScrollView];
    CGFloat opacity = 1;
    
    if (_reachDismissCondition) {
        if (self.direction == TTPhotoScrollViewMoveDirectionVerticalBottom)
        {
            endRect.origin.y += CGRectGetHeight(self.photoScrollView.frame);
        } else if (self.direction == TTPhotoScrollViewMoveDirectionVerticalTop) {
            endRect.origin.y -= CGRectGetHeight(self.photoScrollView.frame);
        }
        opacity = 0;
    }else{
        imageView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.photoScrollView.frame = endRect;
        [self addAnimatedViewToContainerView: 1 - opacity];
    } completion:^(BOOL finished) {
        self.direction = TTPhotoScrollViewMoveDirectionNone;
        if (_reachDismissCondition) {
            [self finished];
        } else {
            [self removeAnimatedViewToContainerView];
        }
    }];
}

//添加顶部和底部的动画
- (void)addAnimatedViewToContainerView:(CGFloat)yFraction
{
    [self resetStatusStyle];
    self.containerView.alpha = (1 - yFraction * 2 / 3);
    [UIView animateWithDuration:0.15 animations:^{
        //        self.indexPromptLabel.alpha = 0;
    }];
}

//移除顶部和底部的动画
- (void)removeAnimatedViewToContainerView
{
    self.photoScrollView.frame = [self frameForPagingScrollView];
    self.containerView.alpha = 1;
    [UIView animateWithDuration:0.15 animations:^{
        //        self.indexPromptLabel.alpha = 1;
        [self setCurrentStatusStyle];
    }];
}

#pragma mark - Present View

- (void)presentPhotoScrollView
{
    [self presentPhotoScrollViewWithDismissBlock:nil];
}

- (void)presentPhotoScrollViewWithDismissBlock:(TTPhotoScrollViewDismissBlock)block
{
    kFHStaticPhotoBrowserAtTop = YES;
    
    [self setCurrentStatusStyle];
    
    _enterOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.dismissBlock = block;
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    if (self.topVC) {
        rootViewController = self.topVC;
    }
    [rootViewController addChildViewController:self];
    
    self.view.alpha = 0;
    _addedToContainer = YES;
    
    TTShowImageView * startShowImageView = [self showImageViewAtIndex:_startWithIndex];
    if (!startShowImageView.isDownloading && self.placeholderSourceViewFrames.count > _startWithIndex && [self.placeholderSourceViewFrames objectAtIndex:_startWithIndex] != [NSNull null]) {
        
        __weak TTShowImageView * weakShowImageView = startShowImageView;
        __weak FHDetailPictureViewController * weakSelf = self;
        
        startShowImageView.loadingCompletedAnimationBlock = ^() {
            
            UIImageView * largeImageView = [weakShowImageView displayImageView];
            CGRect endFrame = largeImageView.frame;
            
            // [largeImageView.superview convertRect:endFrame toView:nil];
            // 全屏展示，无需转换 (由于navigation bar的存在，转换后的y可能差一个navigation bar的高度)
            CGRect transEndFrame = endFrame;
            
            UIView *containerView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
            containerView.backgroundColor = [UIColor clearColor];
            
            CGRect beginFrame = [[_placeholderSourceViewFrames objectAtIndex:_startWithIndex] CGRectValue];
            if ([weakShowImageView isKindOfClass:[FHShowVideoView class]] && _startWithIndex == 0) {
                // 视频cell
                beginFrame = self.videoVC.videoFrame;
                containerView.backgroundColor = [UIColor blackColor];
            }
            largeImageView.frame = beginFrame;
            largeImageView.alpha = 1;
            UIView *originalSupperView = largeImageView.superview;
            [containerView addSubview:largeImageView];
            [rootViewController.view addSubview:self.view]; //图片放大动画情况下，先加入view再加入遮罩
            [rootViewController.view addSubview:containerView];
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            [UIView animateWithDuration:0.35f animations:^{
                containerView.backgroundColor = [UIColor blackColor];
                largeImageView.frame = transEndFrame;
            } completion:^(BOOL finished) {
                largeImageView.frame = endFrame;
                [originalSupperView addSubview:largeImageView];
                [containerView removeFromSuperview];
                
                weakSelf.view.alpha = 1;
                weakShowImageView.loadingCompletedAnimationBlock = nil;
                [weakShowImageView showGifIfNeeded];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }];
        };
        
    } else {
        UIView *containerView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
        containerView.backgroundColor = [UIColor clearColor];
        [rootViewController.view addSubview:containerView];
        [rootViewController.view addSubview:self.view];
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        [UIView animateWithDuration:.3f animations:^{
            self.view.alpha = 1; //本地加载图片，淡入动画
            containerView.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            [containerView removeFromSuperview];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }
}

- (void)dismissSelf
{
    self.startDismissSelf = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                            withAnimation:NO];
    // 关闭 页面时隐藏
    self.topBar.hidden = YES;
    self.bottomBar.hidden = YES;
    self.pictureTitleView.hidden = YES;
    self.videoInfoView.hidden = YES;
    
    if (_reachDismissCondition) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [UIView animateWithDuration:.25f animations:^{
            self.view.layer.opacity = 0.0f;
        } completion:^(BOOL finished) {
            kFHStaticPhotoBrowserAtTop = NO;
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    } else {
        if (self.placeholderSourceViewFrames.count > _currentIndex && [self.placeholderSourceViewFrames objectAtIndex:_currentIndex] != [NSNull null]) {
            // 如果显示图片前后的设备方向不同，直接渐隐动画
            UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            if ((UIInterfaceOrientationIsPortrait(_enterOrientation) && UIInterfaceOrientationIsLandscape(currentOrientation))
                || (UIInterfaceOrientationIsLandscape(_enterOrientation) && UIInterfaceOrientationIsPortrait(currentOrientation))) {
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                
                [UIView animateWithDuration:.2f animations:^{
                    self.view.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    kFHStaticPhotoBrowserAtTop = NO;
                    [self.view removeFromSuperview];
                    [self removeFromParentViewController];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }];
                return;
            }
            
            TTShowImageView * showImageView = [self showImageViewAtIndex:_currentIndex];
            UIImageView * largeImageView = [showImageView displayImageView];
            CGRect endFrame = [[_placeholderSourceViewFrames objectAtIndex:_currentIndex] CGRectValue];
            if ([showImageView isKindOfClass:[FHShowVideoView class]] && _currentIndex == 0) {
                // 视频cell
                endFrame = self.videoVC.videoFrame;
            }
            largeImageView.hidden = NO;
            CGRect beginFrame = largeImageView.frame;
            
            //largeImageView可能被放大了，因此需要转换
            CGRect transBeginFrame = [largeImageView.superview convertRect:beginFrame toView:nil];
            
            //[showImageView hideGifIfNeeded];
            largeImageView.frame = transBeginFrame;
            
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (rootViewController.presentedViewController) {
                rootViewController = rootViewController.presentedViewController;
            }
            if (self.topVC) {
                rootViewController = self.topVC;
            }
            UIView * containerView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
            containerView.backgroundColor = [UIColor blackColor];
            [rootViewController.view addSubview:containerView];
            
            //如果有提供dismissInsets来控制放大图片动画的边距
            if (!UIEdgeInsetsEqualToEdgeInsets(self.dismissMaskInsets, UIEdgeInsetsZero)) {
                CGRect adjustedRect = UIEdgeInsetsInsetRect(containerView.frame, self.dismissMaskInsets);
                BOOL isContains = CGRectContainsRect(adjustedRect, endFrame);
                // 当减去insets后不包含原图的frame时，添加遮罩
                if (!isContains) {
                    UIView *maskView = [[UIView alloc] initWithFrame:containerView.frame];
                    CGRect maskRect = containerView.frame;
                    CGFloat width = containerView.frame.size.width;
                    CGFloat height = containerView.frame.size.height;
                    if (CGRectGetMinX(endFrame) < self.dismissMaskInsets.left) {
                        maskRect = UIEdgeInsetsInsetRect(maskRect, UIEdgeInsetsMake(0, self.dismissMaskInsets.left, 0, 0));
                    }
                    if (width - CGRectGetMaxX(endFrame) < self.dismissMaskInsets.right) {
                        maskRect = UIEdgeInsetsInsetRect(maskRect, UIEdgeInsetsMake(0, 0, 0, self.dismissMaskInsets.right));
                    }
                    if (CGRectGetMinY(endFrame) < self.dismissMaskInsets.top) {
                        maskRect = UIEdgeInsetsInsetRect(maskRect, UIEdgeInsetsMake(self.dismissMaskInsets.top, 0, 0, 0));
                    }
                    if (height - CGRectGetMaxY(endFrame) < self.dismissMaskInsets.bottom) {
                        maskRect = UIEdgeInsetsInsetRect(maskRect, UIEdgeInsetsMake(0, 0, self.dismissMaskInsets.bottom, 0));
                    }
                    
                    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                    CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
                    maskLayer.path = path;
                    CGPathRelease(path);
                    maskView.layer.mask = maskLayer;
                    maskView.backgroundColor = [UIColor clearColor];
                    
                    [containerView addSubview:maskView];
                    [maskView addSubview:largeImageView];
                } else {
                    [containerView addSubview:largeImageView];
                }
            } else {
                [containerView addSubview:largeImageView];
            }
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            [UIView animateWithDuration:0.25f animations:^{
                
                largeImageView.alpha = 0;
                self.containerView.alpha = 0;
                containerView.alpha = 0;
            } completion:^(BOOL finished) {
                [containerView removeFromSuperview];
                kFHStaticPhotoBrowserAtTop = NO;
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }];
            
        } else {
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            [UIView animateWithDuration:.35f animations:^{
                self.view.alpha = 0.0f;
            } completion:^(BOOL finished) {
                kFHStaticPhotoBrowserAtTop = NO;
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }];
        }
    }
}

#pragma TTPreviewPanBackDelegate

- (void)ttPreviewPanBackStateChange:(TTPreviewAnimateState)currentState scale:(float)scale{
    TTShowImageView *imageView = [self showImageViewAtIndex:_currentIndex];
    switch (currentState) {
        case TTPreviewAnimateStateWillBegin:
            [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                                    withAnimation:NO];
            self.pictureTitleView.alpha = 0;
            self.topBar.alpha = 0;
            self.bottomBar.alpha = 0;
            self.videoInfoView.alpha = 0;
            imageView.hidden = YES;
            break;
        case TTPreviewAnimateStateChange:
            self.containerView.alpha = MAX(0,(scale*14-13 - _animateManager.minScale)/(1 - _animateManager.minScale));
            if (self.containerView.alpha < 0.5) {
                [self resetStatusStyle];
            } else {
                [self setCurrentStatusStyle];
            }
            break;
        case TTPreviewAnimateStateDidFinish:
            _reachDismissCondition = YES;
            self.containerView.alpha = 0;
            [self resetStatusStyle];
            [self finished];
            [TTTracker ttTrackEventWithCustomKeys:@"slide_over" label:@"random_slide_close" value:nil source:nil extraDic:nil];
            break;
        case TTPreviewAnimateStateWillCancel:
            break;
        case TTPreviewAnimateStateDidCancel:
            [self setCurrentStatusStyle];
            self.containerView.alpha = 1;
            self.pictureTitleView.alpha = 1;
            self.topBar.alpha = 1;
            self.bottomBar.alpha = 1;
            self.videoInfoView.alpha = 1;
            imageView.hidden = NO;
        default:
            break;
    }
}

- (UIView *)ttPreviewPanBackGetOriginView {
    return [self showImageViewAtIndex:_currentIndex].currentImageView;
}

- (UIView *)ttPreviewPanBackGetBackMaskView{
    return _targetView ? _targetView : self.finishBackView;
};

- (CGRect)ttPreviewPanBackTargetViewFrame{
    if (_currentIndex >= self.animateFrames.count){
        return CGRectZero;
    }
    NSValue *frameValue = [self.animateFrames objectAtIndex:_currentIndex];
    
    return frameValue.CGRectValue;
}

- (UIView *)ttPreviewPanBackGetFinishBackgroundView{
    if (self.finishBackView == nil){
        self.finishBackView = [UIApplication sharedApplication].delegate.window;
        if (self.finishBackView == nil){
            self.finishBackView = [UIApplication sharedApplication].keyWindow;
        }
    }
    return self.finishBackView;
}

- (void)ttPreviewPanBackFinishAnimationCompletion{
    self.containerView.alpha = 0;
}

- (void)ttPreviewPanBackCancelAnimationCompletion{
    self.containerView.alpha = 1;
}

- (BOOL)ttPreviewPanGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return [self newGestureEnable];
}

#pragma UIGestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.panGestureRecognizer){
        return ![self newGestureEnable];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

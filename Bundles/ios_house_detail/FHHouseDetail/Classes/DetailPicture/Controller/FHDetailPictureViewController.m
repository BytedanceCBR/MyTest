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
#import <ByteDanceKit/UIDevice+BTDAdditions.h>
#import <ByteDanceKit/ByteDanceKit.h>
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import "TTImagePreviewAnimateManager.h"
#import "ALAssetsLibrary+TTImagePicker.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHFloorPanPicShowViewController.h"
#import "FHDetailPictureNavView.h"
#import "FHDetailPictureTitleView.h"
#import "TTNavigationController.h"
#import "FHShowVideoView.h"
#import "FHShowVRView.h"
#import <Photos/Photos.h>
#import "HTSDeviceManager.h"
#import "FHDetailVideoInfoView.h"
#import <NSDictionary+BTDAdditions.h>
#import "FHLoadingButton.h"
#import "FHDetailBaseModel.h"
#import <FHHouseBase/FHUserTracker.h>

#define kFHDPTopBarHeight 44.f
#define kFHDPBottomBarHeight 60.f

#define kFHDPMoveDirectionStartOffset 20.f
NSString *const kFHDetailLoadingNotification = @"kFHDetailLoadingNotification";

@interface FHDetailPictureViewController ()<UIScrollViewDelegate, TTShowImageViewDelegate,TTPreviewPanBackDelegate,UIGestureRecognizerDelegate, FHVideoViewDelegate>
{
    BOOL _navBarHidden;
    BOOL _statusBarHidden;
    UIStatusBarStyle _lastStatusBarStyle;
    BOOL _isRotating;
    BOOL _reachDragCondition; //是否满足过一次触发手势条件
}
@property (nonatomic, assign) BOOL reachDismissCondition; //是否满足关闭图片控件条件

@property(nonatomic, copy)TTPhotoScrollViewDismissBlock dismissBlock;
@property(nonatomic, strong)UIView *containerView;

@property(nonatomic, assign, readwrite)NSInteger currentIndex;
@property(nonatomic, assign, readwrite)NSInteger photoCount;

@property (nonatomic, copy) NSArray <NSString *>* rootGroupName;
@property (nonatomic, copy) NSArray <NSString *>* titleNames;
@property (nonatomic, copy) NSArray <NSNumber *>* titleNums;
@property (nonatomic, copy) NSArray <NSNumber *>* pretitleSum;

@property(nonatomic, strong) NSMutableSet * photoViewPools;
@property(nonatomic, strong) NSMutableSet * videoViewPools;
@property(nonatomic, strong) NSMutableSet * vrViewPools;

@property (nonatomic, strong)   FHDetailVideoInfoView       *videoInfoView;


@property (nonatomic, assign)   BOOL       startDismissSelf;
@property (nonatomic, assign)   BOOL       disableAutoPlayVideo;// 禁用自动播放和暂停功能
@property (nonatomic, assign)   BOOL       didEnterFullscreen;// 进入全屏视频

@property(nonatomic, strong)UIView * topBar;
@property (nonatomic, strong)   FHDetailPictureNavView       *naviView;
@property (nonatomic, strong)   FHDetailPictureTitleView       *pictureTitleView;
@property (nonatomic, strong)   UILabel  *bottomTitleLabel;
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

@property (nonatomic, copy) NSString *currentTypeName;

@property (nonatomic, assign) BOOL isCloseButtonAnimation;
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
        _longPressToSave = YES;
        _disableAutoPlayVideo = NO;
        _didEnterFullscreen = NO;
        _isShowBottomBar = YES;
        _isShowSegmentView = YES;
        
        self.ttHideNavigationBar = YES;
                
        self.photoViewPools = [[NSMutableSet alloc] initWithCapacity:5];
        self.videoViewPools = [[NSMutableSet alloc] initWithCapacity:3];
        self.vrViewPools = [[NSMutableSet alloc] initWithCapacity:3];
                
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
    NSString *houseId = [userInfo btd_stringValueForKey:@"house_id"];
    NSInteger loading = [userInfo btd_integerValueForKey:@"show_loading"];
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
    NSString *followId = [userInfo btd_stringValueForKey:@"followId"];
    NSInteger followStatus = [userInfo btd_integerValueForKey:@"followStatus"];
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
    self.topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kFHDPTopBarHeight + topInset)];
    self.topBar.backgroundColor = [UIColor clearColor]; //[UIColor colorWithHexString:@"#000000" alpha:0.3];
    [self.view addSubview:self.topBar];
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(kFHDPTopBarHeight + topInset + 42);
    }];
    
    UIImageView *topBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_detail_header_bg"]];
    topBgImageView.frame = self.topBar.bounds;
    [self.topBar addSubview:topBgImageView];
    [topBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    __weak typeof(self) weakSelf = self;
    self.naviView = [[FHDetailPictureNavView alloc] initWithFrame:CGRectMake(0, topInset, self.view.width, kFHDPTopBarHeight)];
    self.naviView.showAlbum = self.albumImageBtnClickBlock ? YES : NO;
    self.naviView.backActionBlock = ^{
        weakSelf.isCloseButtonAnimation = YES;
        [weakSelf finished];
    };
    self.naviView.albumActionBlock = ^{
        [weakSelf albumBtnClick];
    };
    
    [self.topBar addSubview:self.naviView];
    [self.naviView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topInset);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kFHDPTopBarHeight);
    }];
    
    if (self.titleNames.count > 1 && self.titleNums.count > 1 && self.isShowSegmentView) {
        self.pictureTitleView = [[FHDetailPictureTitleView alloc] initWithFrame:CGRectMake(0, topInset + kFHDPTopBarHeight, self.view.width, 42)];
        self.pictureTitleView.backgroundColor = [UIColor clearColor];
        [self.topBar addSubview:self.pictureTitleView];
        [self.pictureTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(42);
            make.top.mas_equalTo(self.naviView.mas_bottom);
        }];
        self.pictureTitleView.titleNames = self.titleNames;
        self.pictureTitleView.titleNums = self.titleNums;
        self.pictureTitleView.currentIndexBlock = ^(NSInteger currentIndex) {
            
            if (weakSelf.clickTitleTabBlock) {
                weakSelf.clickTitleTabBlock(currentIndex);
            }
            if (currentIndex >= 0 && currentIndex < weakSelf.detailPictureModel.itemList.count) {
                CGFloat pageWidth = weakSelf.photoScrollView.frame.size.width;
                [weakSelf.photoScrollView setContentOffset:CGPointMake(pageWidth * currentIndex, 0) animated:NO];
                [weakSelf playIfCurrentIndexIsVideo];
            }
        };
        [self.pictureTitleView reloadData];
    }


    
    if (self.isShowBottomBar) {
        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - kFHDPBottomBarHeight, self.view.width, kFHDPBottomBarHeight)];
        self.bottomBar.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.bottomBar];
        [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
            make.height.mas_equalTo(120 + bottomInset);
        }];
        
        UIImageView *bottomBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_detail_bottombar_bg"]];
        bottomBgImageView.frame = self.bottomBar.bounds;
        [self.bottomBar addSubview:bottomBgImageView];
        [bottomBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        UILabel *bottomTitleLabel = [[UILabel alloc] init];
        bottomTitleLabel.font = [UIFont themeFontSemibold:20];
        bottomTitleLabel.textColor = [UIColor whiteColor];
        [self.bottomBar addSubview:bottomTitleLabel];
        [bottomTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.height.mas_equalTo(60);
            make.top.mas_equalTo(0);
        }];
        self.bottomTitleLabel = bottomTitleLabel;
        bottomTitleLabel.hidden = YES;
        
        if (self.contactViewModel) {
            CGFloat itemWidth = self.view.width - 30;
            BOOL showenOnline = self.contactViewModel.showenOnline;
            if (showenOnline) {
                itemWidth = (itemWidth - 15) / 2.0;
                // 在线联系
                if (self.contactViewModel.onLineName.length > 0) {
                    NSString *title = self.contactViewModel.onLineName;
                    [self.onlineBtn setTitle:title forState:UIControlStateNormal];
                    [self.onlineBtn setTitle:title forState:UIControlStateHighlighted];
                }
                self.onlineBtn.frame = CGRectMake(15, 0, itemWidth, 44);
                [self.bottomBar addSubview:self.onlineBtn];
                [self.onlineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(15);
                    make.top.mas_equalTo(60);
                    make.width.mas_equalTo(itemWidth);
                    make.height.mas_equalTo(44);
                }];
                // 电话咨询
                if (self.contactViewModel.phoneCallName.length > 0) {
                    NSString *title = self.contactViewModel.phoneCallName;
                    [self.contactBtn setTitle:title forState:UIControlStateNormal];
                    [self.contactBtn setTitle:title forState:UIControlStateHighlighted];
                }
                self.contactBtn.frame = CGRectMake(20 + itemWidth + 10, 0, itemWidth, 44);
                [self.bottomBar addSubview:self.contactBtn];
                [self.contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(-15);
                    make.top.mas_equalTo(self.onlineBtn.mas_top);
                    make.width.mas_equalTo(self.onlineBtn.mas_width);
                    make.height.mas_equalTo(self.onlineBtn.mas_height);
                }];
            } else {
                // 电话咨询
                if (self.contactViewModel.phoneCallName.length > 0) {
                    NSString *title = self.contactViewModel.phoneCallName;
                    [self.contactBtn setTitle:title forState:UIControlStateNormal];
                    [self.contactBtn setTitle:title forState:UIControlStateHighlighted];
                }
                self.contactBtn.frame = CGRectMake(15, 0, itemWidth, 44);
                [self.bottomBar addSubview:self.contactBtn];
                [self.contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(15);
                    make.top.mas_equalTo(60);
                    make.width.mas_equalTo(itemWidth);
                    make.height.mas_equalTo(44);
                }];
            }
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
    UINavigationController *navi = self.topVC.navigationController;
    if (navi && [navi isKindOfClass:[TTNavigationController class]]) {
        navi.interactivePopGestureRecognizer.enabled = NO;
    }
    // 是否正在显示 视频
//    if (_isShowBottomBar) {
//        _videoInfoView = [[FHDetailVideoInfoView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 67)];
//        _videoInfoView.hidden = (itemModel.itemType != FHDetailPictureModelTypeVideo);
//        [self.view addSubview:_videoInfoView];
//        [self.videoInfoView setFollowStatus:self.followStatus];
//        self.videoInfoView.priceLabel.text = self.priceStr;
//        self.videoInfoView.infoLabel.text = self.infoStr;
//        self.videoInfoView.shareActionBlock = self.shareActionBlock;
//        self.videoInfoView.collectActionBlock = self.collectActionBlock;
//    }
        
//    _naviView.videoTitle.isSelectVideo;
    // lead_show 埋点
    if (self.contactViewModel && self.bottomBar && self.bottomBar.hidden == NO) {
        [self addLeadShowLog:self.contactViewModel.contactPhone baseParams:[self.contactViewModel baseParams]];
    }
}

- (void)addLeadShowLog:(FHDetailContactModel *)contactPhone baseParams:(NSDictionary *)dic
{
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tracerDic = dic.mutableCopy;
        tracerDic[@"is_im"] = !isEmptyString(contactPhone.imOpenUrl) ? @"1" : @"0";
        tracerDic[@"is_call"] = contactPhone.enablePhone ? @"1" : @"0";
        tracerDic[@"is_report"] = contactPhone.enablePhone ? @"0" : @"1";
        tracerDic[@"is_online"] = contactPhone.unregistered ? @"1" : @"0";
        tracerDic[@"element_from"] = [self elementFrom];
        tracerDic[@"biz_trace"] = contactPhone.bizTrace?:@"be_null";
        [FHUserTracker writeEvent:@"lead_show" params:tracerDic];
    }
}

- (NSString *)elementFrom {
    NSString *element_from = @"be_null";
    element_from = @"large";
    return element_from;
}

- (NSString *)videoId {
    NSString *video_id = @"";
    if ([self isVideoImageView:self.currentIndex]) {
        FHDetailPictureItemModel *itemModel = self.detailPictureModel.itemList[self.currentIndex];
        FHDetailPictureItemVideoModel *videoModel = (FHDetailPictureItemVideoModel *)itemModel;
        video_id = videoModel.videoModel.videoID.length ? videoModel.videoModel.videoID : @"";
    } else {
        video_id = @"";
    }
    return video_id;
}

// 在线联系点击
- (void)onlineButtonClick:(UIButton *)btn {
    if (self.contactViewModel) {
        NSMutableDictionary *extraDic = @{}.mutableCopy;
        extraDic[@"realtor_position"] = @"im_button";
        extraDic[@"position"] = @"online";
        extraDic[@"element_from"] = [self elementFrom];
        extraDic[@"picture_type"] = self.currentTypeName?:@"be_null";
        NSString *vid = [self videoId];
        if ([vid length] > 0) {
            extraDic[@"item_id"] = vid;
        }
        // 头图im入口线索透传
        extraDic[kFHAssociateInfo] = [self associateInfoFromIndex:self.currentIndex];
        
        [self.contactViewModel onlineActionWithExtraDict:extraDic];
    }
}

// 电话咨询点击
- (void)contactButtonClick:(UIButton *)btn {
    if (self.contactViewModel) {
        
        NSMutableDictionary *extraDic = @{@"realtor_position":@"phone_button",
                                          @"position":@"report_button",
                                          @"element_from":[self elementFrom],
                                          @"picture_type": self.currentTypeName?:@"be_null",
                                          @"enter_type": @"click_button"
                                          }.mutableCopy;
        NSString *vid = [self videoId];
        if ([vid length] > 0) {
            extraDic[@"item_id"] = vid;
        }
        
        NSDictionary *associateInfoDict = nil;
        FHDetailContactModel *contactPhone = self.contactViewModel.contactPhone;
        
        FHClueAssociateInfoModel *associateInfoModel = [self associateInfoFromIndex:self.currentIndex];
        if (contactPhone.enablePhone) {
            associateInfoDict = associateInfoModel.phoneInfo;
        }else {
            associateInfoDict = associateInfoModel.reportFormInfo;
        }
        extraDic[kFHAssociateInfo] = associateInfoDict;
        [self.contactViewModel contactActionWithExtraDict:extraDic];
    }
}

- (FHClueAssociateInfoModel *)associateInfoFromIndex:(NSUInteger)index {
    FHClueAssociateInfoModel *associateInfoModel = nil;
    if ([self isVideoImageView:index] && self.videoImageAssociateInfo) {
        associateInfoModel = self.videoImageAssociateInfo;
    } else if ([self isVRImageView:index] && self.vrImageAssociateInfo) {
        associateInfoModel = self.vrImageAssociateInfo;
    } else if ([self isImageView:index] && self.imageGroupAssociateInfo) {
        associateInfoModel = self.imageGroupAssociateInfo;
    }
    return associateInfoModel;
}

- (UIButton *)onlineBtn {
    if (!_onlineBtn) {
        _onlineBtn = [[UIButton alloc] init];
        _onlineBtn.layer.cornerRadius = 22;
        _onlineBtn.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
        _onlineBtn.layer.borderWidth = 1.0;///UIScreen.mainScreen.scale;
        _onlineBtn.titleLabel.font = [UIFont themeFontRegular:16];
        _onlineBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [_onlineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_onlineBtn setTitle:@"在线联系" forState:UIControlStateNormal];
        [_onlineBtn setTitle:@"在线联系" forState:UIControlStateHighlighted];
        [_onlineBtn addTarget:self action:@selector(onlineButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _onlineBtn;
}

- (FHLoadingButton *)contactBtn {
    if (!_contactBtn) {
        _contactBtn = [[FHLoadingButton alloc]init];
        _contactBtn.layer.cornerRadius = 22;
        _contactBtn.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
        _contactBtn.layer.borderWidth = 1.0;///UIScreen.mainScreen.scale;
        _contactBtn.titleLabel.font = [UIFont themeFontRegular:16];
        _contactBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [_contactBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateNormal];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateHighlighted];
        [_contactBtn addTarget:self action:@selector(contactButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contactBtn;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if ([UIDevice btd_isPadDevice]) {
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
    [self.topBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kFHDPTopBarHeight + topInset + 42);
    }];
    
    [self.naviView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topInset);
    }];

    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(120 + bottomInset);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setCurrentStatusStyle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setCurrentStatusStyle];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf setCurrentStatusStyle];
        
        UINavigationController *navi = self.topVC.navigationController;
        if (navi && [navi isKindOfClass:[TTNavigationController class]]) {
            navi.interactivePopGestureRecognizer.enabled = NO;
        }
    });
    if ([self isVideoImageView:self.currentIndex] && !self.disableAutoPlayVideo) {
        // 视频
        FHShowVideoView *tempVedioView = (FHShowVideoView *)[self showImageViewAtIndex:self.currentIndex];
        tempVedioView.videoVC.hasLeftCurrentVC = NO;
        if (tempVedioView.videoVC.playbackState != TTVPlaybackState_Playing) {
            [tempVedioView.videoVC play];
        }
    }
    self.disableAutoPlayVideo = NO;
    if (self.pictureTitleView) {
        [self.pictureTitleView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self isVideoImageView:self.currentIndex]/*&&!self.startDismissSelf */&& !self.disableAutoPlayVideo) {
        // 视频
        FHShowVideoView *tempVedioView = (FHShowVideoView *)[self showImageViewAtIndex:self.currentIndex];
        tempVedioView.videoVC.hasLeftCurrentVC = YES;
        if (tempVedioView.videoVC.playbackState == TTVPlaybackState_Playing) {
            [tempVedioView.videoVC pause];
        }
    }
    self.disableAutoPlayVideo = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    UINavigationController *navi = self.topVC.navigationController;
    if (navi && [navi isKindOfClass:[TTNavigationController class]]) {
        [(TTNavigationController *)navi panRecognizer].enabled = YES;
    }
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

- (void)updateBottomTitleLabel {
    if (self.currentIndex < 0 || self.currentIndex >= self.detailPictureModel.itemList.count) {
        return;
    }
    FHDetailPictureItemModel *itemModel = self.detailPictureModel.itemList[self.currentIndex];
    if (itemModel.desc.length > 0) {
        self.bottomTitleLabel.hidden = NO;
        self.bottomTitleLabel.text = itemModel.desc;
    } else {
        self.bottomTitleLabel.hidden= YES;
    }
}

- (void)updateNavHeaderTitle {
    NSInteger titleIndex = 0;
    NSInteger left = 0, right = self.pretitleSum.count - 1;
    while (left <= right) {
        NSInteger mid = (left + right) / 2;
        NSNumber *midNum = self.pretitleSum[mid];
        if (self.currentIndex < midNum.unsignedIntegerValue) {
            titleIndex = mid;
            right = mid - 1;
        } else {
            left = mid + 1;
        }
    }
    
    if (titleIndex < self.titleNums.count && titleIndex < self.pretitleSum.count) {
        NSNumber *num = self.titleNums[titleIndex];
        NSNumber *sum = [NSNumber numberWithInteger:0];
        if (titleIndex > 0) {
            sum = self.pretitleSum[titleIndex - 1];
        }
        if (titleIndex < self.rootGroupName.count) {
            self.currentTypeName = self.rootGroupName[titleIndex];
        }
        
        self.naviView.titleLabel.text = [NSString stringWithFormat:@"%@ %ld/%d",self.currentTypeName ,self.currentIndex - sum.unsignedIntValue + 1,num.unsignedIntValue];
    }
}

#pragma mark - Setter & Getter
- (void)setDetailPictureModel:(FHDetailPictureModel *)detailPictureModel {
    _detailPictureModel = detailPictureModel;
    NSMutableArray *rootGroupName = [NSMutableArray array];
    NSMutableArray *numbers = [NSMutableArray array];
    NSMutableArray *titles = [NSMutableArray array];
    NSMutableArray *preSum = [NSMutableArray array];
    
    for (FHDetailPictureItemModel *item in detailPictureModel.itemList) {
        if (item.rootGroupName.length > 0 && [item.rootGroupName isEqualToString:rootGroupName.lastObject]) {
            NSNumber *lastNumber = numbers.lastObject;
            NSNumber *itemCount = [NSNumber numberWithUnsignedInteger:lastNumber.unsignedIntegerValue + 1];
            [numbers removeLastObject];
            [numbers addObject:itemCount];
        } else {
            NSNumber *itemCount = [NSNumber numberWithUnsignedInteger:1];
            [numbers addObject:itemCount];
            [rootGroupName addObject:item.rootGroupName];
        }
    }
    
    for (NSUInteger i = 0; i < rootGroupName.count; i++) {
        NSNumber *number = numbers[i];
        NSString *groupName = rootGroupName[i];
        [titles addObject:[NSString stringWithFormat:@"%@（%lu）", groupName, (unsigned long)number.unsignedIntegerValue]];
        NSNumber *lastSum = preSum.lastObject;
        [preSum addObject:[NSNumber numberWithUnsignedInteger:lastSum.unsignedIntegerValue + number.unsignedIntegerValue]];
    }
    
    self.titleNums = numbers.copy;
    self.titleNames = titles.copy;
    self.pretitleSum = preSum.copy;
    self.rootGroupName = rootGroupName.copy;
    
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:detailPictureModel.itemList.count];
    for (FHDetailPictureItemModel *item in detailPictureModel.itemList) {
        FHImageModel *imgModel = item.image;
        NSMutableDictionary *dict = [[imgModel toDictionary] mutableCopy];
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
    if ([self isVideoImageView:self.currentIndex]) {
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

- (BOOL)isVRImageView :(NSInteger)index {
    if (index < 0 || index >= self.detailPictureModel.itemList.count) {
        return NO;
    }
    FHDetailPictureItemModel *itemModel = self.detailPictureModel.itemList[index];
    if (itemModel.itemType == FHDetailPictureModelTypeVR && [itemModel isKindOfClass:[FHDetailPictureItemVRModel class]]) {
        return YES;
    }
    return NO;
}

- (BOOL)isVideoImageView :(NSInteger)index {
    if (index < 0 || index >= self.detailPictureModel.itemList.count) {
        return NO;
    }
    FHDetailPictureItemModel *itemModel = self.detailPictureModel.itemList[index];
    if (itemModel.itemType == FHDetailPictureModelTypeVideo && [itemModel isKindOfClass:[FHDetailPictureItemVideoModel class]]) {
        return YES;
    }
    return NO;
}

- (BOOL)isImageView: (NSInteger)index {
    if (index < 0 || index >= self.detailPictureModel.itemList.count) {
        return NO;
    }
    FHDetailPictureItemModel *itemModel = self.detailPictureModel.itemList[index];
    if (itemModel.itemType == FHDetailPictureModelTypePicture && [itemModel isKindOfClass:[FHDetailPictureItemPictureModel class]]) {
        return YES;
    }
    return NO;
}

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
    CGFloat topInset = 0;
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        topInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    if (topInset < 1) {
        topInset = 20;
    }
    CGFloat topMargin = kFHDPTopBarHeight + topInset + 42;
    CGFloat botttomMargin = 76 + bottomInset;
    return CGRectMake(0, topMargin, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - topMargin - botttomMargin);
//    return self.view.bounds;
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
    if ([self isVideoImageView:_currentIndex]) {
        FHShowVideoView * tempVedioView = (FHShowVideoView *)[self showImageViewAtIndex:self.currentIndex];
        [tempVedioView.videoVC pause];
    }
    _currentIndex = newIndex;
    [self updateNavHeaderTitle];
    [self updateBottomTitleLabel];
    if (self.pictureTitleView) {
        self.pictureTitleView.selectIndex = newIndex;
    }
    [self unloadPhoto:_currentIndex + 2];
    [self unloadPhoto:_currentIndex - 2];
    
    [[self showImageViewAtIndex:_currentIndex] restartGifIfNeeded];
    [self loadPhoto:_currentIndex + 1 visible:NO];
    [self loadPhoto:_currentIndex - 1 visible:NO];
    [self loadPhoto:_currentIndex visible:YES];
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
    
    if ([self isVideoImageView:index]) {
        // 视频

        if ([self isPhotoViewExistInScrollViewForIndex:index]) {
            [[self showImageViewAtIndex:index] setVisible:visible];
            FHShowVideoView * tempVedioView = (FHShowVideoView *)[self showImageViewAtIndex:index];
            tempVedioView.frame = [self frameForPageAtIndex:index];
            [tempVedioView currentImageView].alpha = 0;
            tempVedioView.visible = visible;
            
            FHDetailPictureItemPictureModel *itemModel = self.detailPictureModel.itemList[index];
            FHDetailPictureItemVideoModel *videoModel = (FHDetailPictureItemVideoModel *)itemModel;
            [tempVedioView.videoVC updateData:videoModel.videoModel];
            [tempVedioView setNeedsLayout];
            if (visible) {
//                [tempVedioView.videoVC play];
//                if (tempVedioView.videoVC.view.alpha < 1.0) {
//                    tempVedioView.videoVC.view.alpha = 1.0;
//                }
            } else {
                [tempVedioView.videoVC pause];
            }
            return;
        }
        
        FHShowVideoView * showVedioView = [_videoViewPools anyObject];
        
        if (showVedioView == nil) {
            showVedioView = [[FHShowVideoView alloc] initWithFrame:[self frameForPageAtIndex:index]];
            showVedioView.delegate = self;
            showVedioView.backgroundColor = [UIColor clearColor];
            
            FHVideoViewController *videoVC = [[FHVideoViewController alloc] init];
            videoVC.view.frame = self.photoScrollView.bounds;
            videoVC.tracerDic = self.videoTracerDict;
            showVedioView.videoVC = videoVC;
        }
        else {
            [_videoViewPools removeObject:showVedioView];
        }
        
        showVedioView.frame = [self frameForPageAtIndex:index];
        [_photoScrollView addSubview:showVedioView];
        
        FHDetailPictureItemPictureModel *itemModel = self.detailPictureModel.itemList[index];
        FHDetailPictureItemVideoModel *videoModel = (FHDetailPictureItemVideoModel *)itemModel;
        [showVedioView.videoVC updateData:videoModel.videoModel];
        showVedioView.loadingCompletedAnimationBlock = ^{
            // nothing
        };
        // 显示图片
        [self setUpShowImageView:showVedioView atIndex:index];
        showVedioView.visible = visible;
        [showVedioView currentImageView].alpha = 0;

        // 设置视频数据
        if (visible) {
//            [showVedioView.videoVC play];
//            if (showVedioView.videoVC.view.alpha < 1.0) {
//                showVedioView.videoVC.view.alpha = 1.0;
//            }
        }
        [showVedioView setNeedsLayout];
        
    } else if ([self isVRImageView:index]) {
        // VR
        if ([self isPhotoViewExistInScrollViewForIndex:index]) {
            [[self showImageViewAtIndex:index] setVisible:visible];
            return;
        }
        
        FHShowVRView * showImageView = [_vrViewPools anyObject];
        
        if (showImageView == nil) {
            showImageView = [[FHShowVRView alloc] initWithFrame:[self frameForPageAtIndex:index]];
            showImageView.backgroundColor = [UIColor clearColor];
            showImageView.delegate = self;
        }
        else {
            [_vrViewPools removeObject:showImageView];
        }
        [showImageView currentImageView].alpha = 1;
        showImageView.frame = [self frameForPageAtIndex:index];
        
        showImageView.loadingCompletedAnimationBlock = ^{
            // nothing
        };
        [showImageView showVRIcon];
        [self setUpShowImageView:showImageView atIndex:index];
        showImageView.visible = visible;
        
        [_photoScrollView addSubview:showImageView];
    }
    else {
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

- (void)playIfCurrentIndexIsVideo {
    // 视频
    if ([self isVideoImageView:self.currentIndex]) {
        FHShowVideoView * tempVedioView = (FHShowVideoView *)[self showImageViewAtIndex:self.currentIndex];
        if (tempVedioView.videoVC.hasLeftCurrentVC) {
            return;
        }
        [tempVedioView setNeedsLayout];
        [tempVedioView.videoVC play];
        if (tempVedioView.videoVC.view.alpha < 1.0) {
            tempVedioView.videoVC.view.alpha = 1.0;
        }
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
            if ([self isVideoImageView:index]) {
                // 视频
                [_videoViewPools addObject:subView];
                [subView removeFromSuperview];
            } else if ([self isVRImageView:index]) {
                [_vrViewPools addObject:subView];
                [subView removeFromSuperview];
            }
            else {
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
    [self dismissSelf];
}

- (void)albumBtnClick
{
    if (self.albumImageBtnClickBlock) {
        self.albumImageBtnClickBlock(self.currentIndex);
    }
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self playIfCurrentIndexIsVideo];
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
    } else if ([imageView isKindOfClass:[FHShowVRView class]]) {
        // VR
        UITapGestureRecognizer *tapGes = imageView.tapGestureRecognizer;
        if (tapGes) {
            CGRect frame = [imageView currentImageView].frame;
            UIView * touchView = tapGes.view;
            
            CGPoint point = [tapGes locationInView:touchView];
            if (!CGRectContainsPoint(frame, point)) {
                [self finished];
            } else {
                if (self.clickImageBlock) {
                    self.clickImageBlock(imageView.tag);
                }
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
    if (self.currentIndex < 0 || self.currentIndex >= self.detailPictureModel.itemList.count) {
        return;
    }
    if (![self isVideoImageView:self.currentIndex]) {
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
    if([UIDevice btd_isPadDevice])
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
    if (![UIDevice btd_isPadDevice]) {
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
    if (self.currentIndex < 0 || self.currentIndex >= self.detailPictureModel.itemList.count) {
        return;
    }
    if ([self isVideoImageView:self.currentIndex]) {
        // 视频不支持pan
        return;
    }
    
    if (_dragToCloseDisabled || self.interfaceOrientation != UIInterfaceOrientationPortrait) {
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
    
    if (self.currentIndex < 0 || self.currentIndex >= self.detailPictureModel.itemList.count) {
        return;
    }
    if ([self isVideoImageView:self.currentIndex]) {
        // 视频不支持
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
                self.reachDismissCondition = YES;
            } else {
                self.reachDismissCondition  = NO;
            }
            
            if (velocity.y > 1500) {
                self.reachDismissCondition = YES;
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
    
    if (self.reachDismissCondition) {
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
        if (self.reachDismissCondition) {
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
    
    [rootViewController.view addSubview:self.view]; //图片放大动画情况下，先加入view再加入遮罩
    
    self.view.alpha = 0;
    TTShowImageView * startShowImageView = [self showImageViewAtIndex:_startWithIndex];
    if (!startShowImageView.isDownloading && self.placeholderSourceViewFrames.count > _startWithIndex && [self.placeholderSourceViewFrames objectAtIndex:_startWithIndex] != [NSNull null]) {
        
        __weak TTShowImageView * weakShowImageView = startShowImageView;
        __weak typeof(self) weakSelf = self;
        
        startShowImageView.loadingCompletedAnimationBlock = ^() {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            UIImageView * largeImageView = [weakShowImageView displayImageView];
            CGRect endFrame = largeImageView.frame;
            
            UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:endFrame];
            if ([largeImageView isKindOfClass:[UIImageView class]]) {
                animationImageView.image = largeImageView.image;
            }
            animationImageView.contentMode = largeImageView.contentMode;
            
            // [largeImageView.superview convertRect:endFrame toView:nil];
            // 全屏展示，无需转换 (由于navigation bar的存在，转换后的y可能差一个navigation bar的高度)
            //[weakSelf.photoScrollView convertRect:endFrame fromView:largeImageView]
            CGRect transEndFrame = endFrame;
            transEndFrame = CGRectOffset(transEndFrame, 0, [strongSelf frameForPagingScrollView].origin.y);
            
            UIView *containerView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
            containerView.backgroundColor = [UIColor clearColor];
            
            CGRect beginFrame = [[strongSelf.placeholderSourceViewFrames objectAtIndex:strongSelf.startWithIndex] CGRectValue];
            if ([weakShowImageView isKindOfClass:[FHShowVideoView class]] && strongSelf.startWithIndex == 0) {
                // 视频cell
                beginFrame = [strongSelf frameForPagingScrollView];
            }
            containerView.alpha = 0;
            largeImageView.alpha = 0;
            animationImageView.frame = beginFrame;
            [containerView addSubview:animationImageView];
            [rootViewController.view addSubview:containerView];
            
            CGRect topBarFrame = strongSelf.topBar.frame;
            strongSelf.topBar.frame = CGRectOffset(topBarFrame, 0, -topBarFrame.size.height);
            strongSelf.topBar.alpha = 0;
            
            CGRect bottomBarFrame = strongSelf.bottomBar.frame;
            strongSelf.bottomBar.frame = CGRectOffset(bottomBarFrame, 0, bottomBarFrame.size.height);
            strongSelf.bottomBar.alpha = 0;
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            [UIView animateWithDuration:0.35f animations:^{
                containerView.alpha = 1;
                animationImageView.frame = transEndFrame;
                
                strongSelf.topBar.alpha = 1;
                strongSelf.topBar.frame = topBarFrame;
                
                strongSelf.bottomBar.frame = bottomBarFrame;
                strongSelf.bottomBar.alpha = 1;

                strongSelf.view.alpha = 1;
            } completion:^(BOOL finished) {
                largeImageView.alpha = 1;
//                [originalSupperView addSubview:largeImageView];
                [containerView removeFromSuperview];
                
                weakShowImageView.loadingCompletedAnimationBlock = nil;
                [weakShowImageView showGifIfNeeded];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                [strongSelf didMoveToParentViewController:rootViewController];
            }];
        };
        
    } else {
        UIView *containerView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
        containerView.backgroundColor = [UIColor clearColor];
        [rootViewController.view addSubview:containerView];
        [rootViewController.view addSubview:self.view];
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        [UIView animateWithDuration:.2f animations:^{
            self.view.alpha = 1; //本地加载图片，淡入动画
            containerView.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            [containerView removeFromSuperview];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [self didMoveToParentViewController:rootViewController];
        }];
    }
}

- (void)dismissSelf
{
    self.startDismissSelf = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                            withAnimation:NO];
    
    [self willMoveToParentViewController:nil];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    if (self.topVC) {
        rootViewController = self.topVC;
    }
    rootViewController.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    self.videoInfoView.hidden = YES;
    if (self.reachDismissCondition) {
        // 关闭 页面时隐藏
        self.topBar.hidden = YES;
        self.bottomBar.hidden = YES;
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [UIView animateWithDuration:.2f animations:^{
            self.view.layer.opacity = 0.0f;
        } completion:^(BOOL finished) {
            kFHStaticPhotoBrowserAtTop = NO;
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    } else if (self.isCloseButtonAnimation) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        CGRect frame = self.view.frame;
        frame = CGRectOffset(frame, 0, frame.size.height);

        [UIView animateWithDuration:0.2f animations:^{
            self.view.frame = frame;
        } completion:^(BOOL finished) {
            kFHStaticPhotoBrowserAtTop = NO;
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }
    else if (self.placeholderSourceViewFrames.count > _currentIndex && [self.placeholderSourceViewFrames objectAtIndex:_currentIndex] != [NSNull null]) {
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
        
        largeImageView.hidden = NO;
        CGRect beginFrame = largeImageView.frame;
        
        //largeImageView可能被放大了，因此需要转换
        CGRect transBeginFrame = [largeImageView.superview convertRect:beginFrame toView:nil];
        //            transBeginFrame = CGRectOffset(transBeginFrame, 0, [self frameForPagingScrollView].origin.y);
        
        CGRect endFrame = [[_placeholderSourceViewFrames objectAtIndex:_currentIndex] CGRectValue];
        if ([showImageView isKindOfClass:[FHShowVideoView class]]) {
            // 视频cell
            endFrame = [self frameForPagingScrollView];
            transBeginFrame = endFrame;
        }
        
        largeImageView.frame = transBeginFrame;
        
        UIView * containerView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
        containerView.backgroundColor = [UIColor clearColor];
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
        
        CGRect topBarFrame = self.topBar.frame;
        topBarFrame = CGRectOffset(topBarFrame, 0, -topBarFrame.size.height);
        
        CGRect bottomBarFrame = self.bottomBar.frame;
        bottomBarFrame = CGRectOffset(bottomBarFrame, 0, bottomBarFrame.size.height);
        [UIView animateWithDuration:0.35f animations:^{
            
            self.topBar.frame = topBarFrame;
            self.topBar.alpha = 0;
            
            self.bottomBar.frame = bottomBarFrame;
            self.bottomBar.alpha = 0;
            
            largeImageView.frame = endFrame;
            self.view.alpha = 0;
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
            if (self.willBeginPanBackBlock) {
                self.willBeginPanBackBlock(self.currentIndex);
            }
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
            self.reachDismissCondition = YES;
            self.containerView.alpha = 0;
            [self resetStatusStyle];
            [self finished];
            [BDTrackerProtocol trackEventWithCustomKeys:@"slide_over" label:@"random_slide_close" value:nil source:nil extraDic:nil];
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

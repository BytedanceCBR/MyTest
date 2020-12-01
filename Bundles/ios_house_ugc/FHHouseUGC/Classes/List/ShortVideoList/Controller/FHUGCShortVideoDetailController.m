//
//  AWEVideoDetailViewController.m
//  LiveStreaming
//
//  Created by 01 on 17/5/3.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "FHUGCShortVideoDetailController.h"
#import "AWEVideoDetailViewController.h"
#import "AWEReportViewController.h"
// View
#import "AWEVideoPlayView.h"
#import "AWEVideoCommentCell.h"
//#import "AWECommentInputBar.h"
// Model
#import "TSVShortVideoOriginalData.h"
#import "AWECommentModel.h"
#import "AWEUserModel.h"
// Bridge
#import "AWEVideoPlayAccountBridge.h"
#import "AWEVideoPlayShareBridge.h"
#import "AWEVideoPlayTransitionBridge.h"
#import "AWEVideoPlayTrackerBridge.h"
// Manager
#import "AWEVideoUserInfoManager.h"
#import "AWEVideoDetailManager.h"
#import "AWEVideoCommentDataManager.h"
#import "HTSDeviceManager.h"
// Util
#import <Masonry/Masonry.h>
//#import <AFNetworking/AFNetworking.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIScrollView+Refresh.h"
#import "HTSVideoPlayToast.h"
#import "BTDMacros.h"
#import "BTDResponder.h"
#import "BTDNetworkUtilities.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIButton+TTAdditions.h"
#import "EXTKeyPathCoding.h"
#import "TTURLUtils.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "TTNavigationController.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTModuleBridge.h"
#import "AWEVideoConstants.h"
#import "AWEVideoContainerViewController.h"
#import "AWEVideoDetailControlOverlayViewController.h"
#import "TSVShortVideoDetailFetchManager.h"
#import "TSVShortVideoCategoryFetchManager.h"
#import "NSObject+FBKVOController.h"
#import "EXTKeyPathCoding.h"
#import "HTSVideoPageParamHeader.h"
#import "TTImagePreviewAnimateManager.h"
#import "TSVShortVideoDetailExitManager.h"
#import "TTInteractExitHelper.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import "UIViewController+TabBarSnapShot.h"
#import "UIImageView+WebCache.h"
#import "AWEVideoDetailFirstUsePromptViewController.h"
#import <TTReporter/TTReportManager.h>
#import "TTMonitor.h"
#import "TSVVideoDetailPromptManager.h"
#import "AWEVideoShareModel.h"
#import "TTShareManager.h"
#import "TTServiceCenter.h"

#import "TTAdManagerProtocol.h"
#import "TTShortVideoModel+TTAdFactory.h"
#import "TTAdShortVideoModel.h"

#import "TTIndicatorView.h"
#import <TTThemed/UIImage+TTThemeExtension.h>
#import "DetailActionRequestManager.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTDeviceHelper.h"
//#import "TSVProfileViewController.h"
//#import "TSVProfileViewModel.h"
#import "TTSettingsManager.h"
#import "TSVSlideUpPromptViewController.h"
#import "TSVSlideLeftEnterProfilePromptViewController.h"
#import <TTUIWidget/UIView+CustomTimingFunction.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "TSVDownloadManager.h"
#import "TSVSlideUpPromptViewController.h"
//#import "TSVProfileConfig.h"
#import "TSVDetailViewModel.h"
#import "UIImageView+YYWebImage.h"
#import "UIImage+YYWebImage.h"
#import "SDWebImageManager.h"
#import <TTBaseLib/TTStringHelper.h>
#import "TTCustomAnimationDelegate.h"
#import "TSVStartupTabManager.h"
#import "TSVUIResponderHelper.h"
#import "AWEVideoDetailScrollConfig.h"
#import "TSVTransitionAnimationManager.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "CommonURLSetting.h"
#import "TSVVideoDetailShareHelper.h"
#import "TSVVideoShareManager.h"
#import "TTTrackerWrapper.h"
#import "TSVPrefetchImageManager.h"
#import "TSVDetailRouteHelper.h"
#import "TSVPrefetchVideoManager.h"
#import "TTAudioSessionManager.h"

#import "ExploreOrderedData.h"
#import "TTBusinessManager+StringUtils.h"

#import "FHPostDetailCommentWriteView.h"
#import "SSCommonLogic.h"
#import "SSCommentInputHeader.h"
#import "FHUserTracker.h"


#import "FHShortVideoDetailFetchManager.h"
#import "TSVWriteCommentButton.h"
#import "FHShortVideoTracerUtil.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "TTAccountManager.h"
#import "NSDictionary+BTDAdditions.h"
#import "HMDTTMonitor.h"

#import "UIDevice+BTDAdditions.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHShortVideoPerLoaderManager.h"
#import "FHHouseUGCAPI.h"
#import "FHUtils.h"
#define kPostMessageFinishedNotification    @"kPostMessageFinishedNotification"

@import AVFoundation;


///评论页状态 未弹出/点击弹出／上滑弹出
typedef NS_ENUM(NSInteger, TSVDetailCommentViewStatus) {
    TSVDetailCommentViewStatusNone,
    TSVDetailCommentViewStatusPopByClick,
    TSVDetailCommentViewStatusPopBySlideUp,
};

@interface FHUGCShortVideoDetailController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, AWEVideoCommentCellOperateDelegate, TTRouteInitializeProtocol, TTPreviewPanBackDelegate, TTShareManagerDelegate, TTInteractExitProtocol,TTCommentWriteManagerDelegate>

// View
@property (nonatomic, strong) SSThemedView *commentView;
@property (nonatomic, strong) SSThemedLabel *commentHeaderLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWEVideoContainerViewController *videoContainerViewController;
@property (nonatomic, strong) UIView *emptyHintView;
@property (nonatomic, strong) UIView *keyboardMaskView;
@property (nonatomic, strong) AWEReportViewController *commentReportVC;
@property (nonatomic, strong) AWEReportViewController *videoReportVC;
@property (nonatomic, strong) SSThemedView *fakeInputBar;
// Data
@property (nonatomic, strong) TSVDetailViewModel *viewModel;
@property (nonatomic, strong) AWEVideoCommentDataManager *commentManager;
@property (nonatomic, strong) FHShortVideoDetailFetchManager *dataFetchManager;
@property (nonatomic, strong) id<TSVShortVideoDataFetchManagerProtocol> originalDataFetchManager;
@property (nonatomic, copy) NSDictionary *pageParams;
@property (nonnull, copy) NSString *groupID;
@property (nonnull, copy) NSString *topID;
@property (nonatomic, copy) NSString *groupSource;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, strong) NSNumber *showComment;//0不弹，1弹起评论浮层，2弹输入框
@property (nonatomic, copy) NSDictionary *commonTrackingParameter;
@property (nonatomic, copy) NSDictionary *initialLogPb;
//外面传的埋点信息 by xsm
@property (nonatomic, strong) NSDictionary *extraDic;
// 状态
@property (nonatomic, assign) BOOL firstLoadFinished;
@property (nonatomic, assign) BOOL isFirstTimeShowCommentListOrKeyboard;

@property (nonatomic, assign) BOOL isDisliked;
@property (nonatomic, assign) BOOL hasMore;      // 还有没有评论数据可以拉取
@property (nonatomic, assign) NSInteger offset;  // 请求新数据的时候，offet参数
@property (nonatomic, assign) AWEVideoDetailCloseStyle closeStyle;
@property (nonatomic, assign) NSTimeInterval totalDuration;
// 详情页数据
@property (nonatomic, strong) FHFeedUGCCellModel *model;
@property (nonatomic, strong) NSArray<NSDictionary *> *userReportOptions;
@property (nonatomic, strong) NSArray<NSDictionary *> *videoReportOptions;
// 用于避免重复digg
@property (nonatomic, strong) NSLock *diggLock;
@property (nonatomic, strong) NSLock *commentDiggLock;
// observers
@property (nonatomic, strong) NSMutableArray *observerArray;

///下拉关闭相关属性
@property (nonatomic, strong) TTImagePreviewAnimateManager *animateManager;
@property (nonatomic, strong) TSVShortVideoDetailExitManager *exitManager;
@property (nonatomic, strong) UIView *finishBackView;
@property (nonatomic, strong) SSThemedView *blackMaskView;
@property (nonatomic, strong) UIView *popToView;
@property (nonatomic, strong) UIView *bottomTabbarView;
@property (nonatomic, strong) UIImage *fakeBackImage;

@property (nonatomic, strong) TSVVideoDetailPromptManager *detailPromptManager;

@property (nonatomic, strong) NSMutableArray *dislikeGroupIDArray;
@property (nonatomic, strong) DetailActionRequestManager *actionManager;
///浮层（评论浮层／作品集浮层）上滑手势
@property (nonatomic, strong) UIPanGestureRecognizer *slideUpGesture;
@property (nonatomic, assign) TSVDetailSlideUpViewType slideUpViewType;
///下滑手势
@property (nonatomic, strong) UIPanGestureRecognizer *commentSlideDownGesture;
//@property (nonatomic, strong) UIPanGestureRecognizer *profileSlideDownGesture;
///浮层
@property (nonatomic, assign) BOOL allowCommentSlideDown;
@property (nonatomic, assign) BOOL allowProfileSlideDown;

@property (nonatomic, assign) BOOL commentScrollEnable;
@property (nonatomic, assign) BOOL profileScrollEnable;

@property (nonatomic, strong) UIView *commentViewMaskView;
@property (nonatomic, strong) UIView *profileViewMaskView;

@property (nonatomic, assign) BOOL isCommentViewAnimating;
@property (nonatomic, assign) BOOL isProfileViewAnimating;

@property (nonatomic, assign) CGFloat commentBeginDragContentOffsetY;
@property (nonatomic, assign) CGFloat profileBeginDragContentOffsetY;

@property (nonatomic, assign) TSVDetailCommentViewStatus commentViewStatus;

@property (nonatomic, assign) UIStatusBarStyle originalStatusBarStyle;

@property (nonatomic, strong) TTShareManager *shareManager;
///当前详情页是从个人作品浮层push进来的
@property (nonatomic, assign) BOOL pushFromProfileVC;

///左滑手势:进个人主页
@property (nonatomic, strong) UIPanGestureRecognizer *slideLeftGesture;

//push
@property (nonatomic, copy) NSString *ruleID;   //推送gid对应的唯一标识
@property (nonatomic, copy) NSString *originalGroupID;  //schema中的初始gid

@property (nonatomic, strong) ExploreOrderedData            *orderedData;

@property (nonatomic, assign) BOOL loadingShareImage;//加载分享图片时 点击分享按钮

@property (nonatomic, strong) FHPostDetailCommentWriteView *commentWriteView;
@property (nonatomic, strong) TTGroupModel *groupModel;

@property (nonatomic, strong) NSDictionary *tracerDic;

@property (nonatomic, strong) UIView *topBarView;
@property (nonatomic, strong) UIButton *closeButton;
@end

static const CGFloat kFloatingViewOriginY = 230;

@implementation FHUGCShortVideoDetailController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];

    if (self) {
        /// query 里是以url传入的参数
        NSDictionary *params = paramObj.queryParams;
        /// extra 里是以dict传入的参数
        NSDictionary *extraParams = paramObj.userInfo.extra;
        /// allParams 里是以上两个字典的并集，extra会覆盖 query
//        _tracerDic = paramObj.userInfo.extra;
        _pageParams = paramObj.allParams.copy;

        _groupID = [params[AWEVideoGroupId] copy] ?: @"";
        _topID =  [params[AWEVideocTopId] copy] ?: @"";
        _originalGroupID = [params[AWEVideoGroupId] copy] ?: @"";
        _ruleID = [params[AWEVideoRuleId] copy];
        _groupSource = [params[VideoGroupSource] copy] ?: @"";
        _showComment = [params[AWEVideoShowComment] copy];
        
        if (!_showComment) {
            _showComment = [extraParams[AWEVideoShowComment] copy];
        }
        _categoryName = [params btd_stringValueForKey:AWEVideoCategoryName];
        _commonTrackingParameter = @{
                                     @"enter_from": [params[AWEVideoEnterFrom] copy] ?: @"",
                                     @"category_name": [params[AWEVideoCategoryName] copy] ?: @""
                                     };

        if (params[@"log_pb"]) {
            id logPb = [NSJSONSerialization JSONObjectWithData:[params[@"log_pb"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSAssert(logPb, @"logPb must not be nil");
            _initialLogPb = logPb?: @{};
            NSAssert([_initialLogPb isKindOfClass:[NSDictionary class]], @"log_pb must be a dictionary");
        }
        
        [self initReportOptions];
        [self initProperty];
        self.dataFetchManager = [[FHShortVideoDetailFetchManager alloc]init];
        self.dataFetchManager.currentIndex= 0;
        self.dataFetchManager.shouldShowNoMoreVideoToast = YES;
        self.dataFetchManager.categoryId = @"f_house_smallvideo_flow";
        if(paramObj.allParams[@"extraDic"] && [paramObj.allParams[@"extraDic"] isKindOfClass:[NSDictionary class]]){
            self.extraDic = paramObj.allParams[@"extraDic"];
            self.dataFetchManager.tracerDic = self.extraDic;
          }
        self.dataFetchManager.groupID = self.groupID;
        self.dataFetchManager.topID = self.topID;
        self.dataFetchManager.currentShortVideoModel = extraParams[@"current_video"];
        self.dataFetchManager.otherShortVideoModels = extraParams[@"other_videos"];
        @weakify(self);
        [RACObserve(self, dataFetchManager) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if ([self.dataFetchManager respondsToSelector:@selector(dataDidChangeBlock)]) {
                self.dataFetchManager.dataDidChangeBlock = ^{
                    @strongify(self);
                    [self endLoading];
                    if ([self.dataFetchManager numberOfShortVideoItems] == 0) {
                        [self.emptyView showEmptyWithTip:@"数据走丢了" errorImageName:@"short_video_nodata" showRetry:YES];
                        return;
                    }else {
                        self.emptyView.hidden = YES;
                    }
                    [self updateData];
                };
            }
        }];

        if (extraParams[HTSVideoDetailExitManager]) {
            self.exitManager = extraParams[HTSVideoDetailExitManager];
        }
        if (extraParams[TSVDetailPushFromProfileVC]) {
            self.pushFromProfileVC = [extraParams btd_boolValueForKey:TSVDetailPushFromProfileVC];
        }
        
        if (extraParams[HTSVideoDetailOrderedData]) {
            self.orderedData = extraParams[HTSVideoDetailOrderedData];
        }
        
        TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.groupID itemID:self.groupID impressionID:nil aggrType:1];
        self.groupModel = groupModel;
    }
    return self;
}

- (void)initReportOptions
{
    self.userReportOptions = [TTReportManager fetchReportUserOptions];
    self.videoReportOptions = [TTReportManager fetchReportVideoOptions];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;//获取当前的视图控制其
    if (![viewControllers containsObject:self]) {
        [self.videoContainerViewController videoOverTracer];
    }
}

- (void)initProperty
{
    _offset = 0;
    _diggLock = [NSLock new];
    _commentDiggLock = [NSLock new];
    _observerArray = [NSMutableArray array];
    _commentManager = [[AWEVideoCommentDataManager alloc] init];
    _isFirstTimeShowCommentListOrKeyboard = YES;
    _isCommentViewAnimating = NO;
    _isProfileViewAnimating = NO;
    _slideUpViewType = [TSVSlideUpPromptViewController slideUpViewType];
    self.ttHideNavigationBar = YES;
    _isDisliked = NO;
    _closeStyle = AWEVideoDetailCloseStyleNavigationPan;//默认为右滑

    self.detailPromptManager = [[TSVVideoDetailPromptManager alloc] init];
}

- (void)dealloc
{
    [AWEVideoPlayShareBridge stopListenShare];

    [[TTModuleBridge sharedInstance_tt] removeListener:self forKey:@"AWELoginResult"];
    for (id observer in self.observerArray) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }

    if(!self.model){
        return;
    }

    if ([_dislikeGroupIDArray count] > 0){
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:_dislikeGroupIDArray forKey:@"group_id_array"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSVShortVideoDeleteCellNotification"
                                                            object:self
                                                          userInfo:userInfo
         ];
    }

    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //黑色背景
    self.blackMaskView = ({
        SSThemedView *blackMaskView = [[SSThemedView alloc] initWithFrame:self.view.frame];
        blackMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blackMaskView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        blackMaskView;
    });
    
    if (![AWEVideoPlayAccountBridge isLogin]) {
        [AWEVideoPlayAccountBridge fetchTTAccount];
    }
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden = YES;
    self.view.clipsToBounds = YES;

    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
        CGFloat topInset = 0;
    if (@available(iOS 11.0, *)) {
        topInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }

    // Views
    self.videoContainerViewController = ({
        AWEVideoContainerViewController *controller = [[AWEVideoContainerViewController alloc] init];
        controller.dataFetchManager = self.dataFetchManager;
        controller.commonTrackingParameter = self.commonTrackingParameter;
        controller.extraDic = self.extraDic;
        controller.needCellularAlert = (self.pageParams[AWEVideoPageParamNonWiFiAlert] && [self.pageParams[AWEVideoPageParamNonWiFiAlert] isKindOfClass:[NSNumber class]]) ? [self.pageParams[AWEVideoPageParamNonWiFiAlert] boolValue] : YES;
        @weakify(self)
        controller.loadMoreBlock = ^(BOOL preload) {
            @strongify(self);
            [self loadMoreAutomatically:preload showLoading:NO];
        };
        controller.didScroll = ^{
            @strongify(self);
            [self loadVideoDataIfNeeded];
        };
        controller.detailPromptManager = self.detailPromptManager;
        controller.configureOverlayViewController = ^(id<TSVControlOverlayViewController> _Nonnull viewController) {
            @strongify(self);
            viewController.viewModel = ({
                TSVControlOverlayViewModel *viewModel = [[TSVControlOverlayViewModel alloc] init];
                viewModel.commonTrackingParameter = self.commonTrackingParameter;
                viewModel.listEntrance = [self entrance];
                viewModel.writeCommentButtonDidClick = ^{
                            @strongify(self);
                           NSInteger rank = [self.model.tracerDic btd_integerValueForKey:@"rank" default:0];
                    [FHShortVideoTracerUtil clickCommentWithModel:self.model eventIndex:rank eventPosition:@"detail_comment"];
                            [self playView:nil didClickInputWithModel:self.model];
                        };
                viewModel.showProfilePopupBlock = ^{
                };
                viewModel.showCommentPopupBlock = ^{
                    @strongify(self);
                    [self playView:nil didClickCommentWithModel:self.model];

                };
                viewModel.moreButtonDidClick = ^{
                    @strongify(self);
                    [self topView:nil didClickReportWithModel:self.model];
                };
                viewModel;
            });
        };
        controller;
    });

    @weakify(self);

    [self addChildViewController:self.videoContainerViewController];
    
    self.videoContainerViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:self.videoContainerViewController.view];
    [self.videoContainerViewController didMoveToParentViewController:self];

    [self addDefaultEmptyViewFullScreen];
    self.emptyView.backgroundColor = [UIColor clearColor];
    self.emptyView.retryBlock = ^{
        @strongify(self);
        self.emptyView.hidden = YES;
        [self loadMoreAutomatically:YES showLoading:YES];
    };
    [self.emptyView.retryButton setBackgroundImage:[FHUtils createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [self.emptyView.retryButton setBackgroundImage:[FHUtils createImageWithColor:[UIColor clearColor]] forState:UIControlStateHighlighted];
    [self.emptyView.retryButton setTitle:@"重新加载" forState:UIControlStateNormal];
    
    self.topBarView = [[UIView alloc] init];
    self.topBarView.frame = CGRectMake(15, topInset, CGRectGetWidth(self.view.bounds) -30, 64.0);
    self.topBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.topBarView];

    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage imageNamed:@"shortvideo_close"] forState:UIControlStateNormal];
    [_closeButton setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 0)];
    [_closeButton addTarget:self action:@selector(handleCloseClick:) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-12, -12, -12, -12);

    [self.topBarView addSubview:_closeButton];
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.topBarView);
        make.height.equalTo(@48.0);
        make.width.equalTo(@30.0);
    }];
    
    
    self.commentView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kFloatingViewOriginY)];
//    self.commentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.commentView.layer.cornerRadius = 6.0;
    self.commentView.backgroundColorThemeKey = kColorBackground4;
    self.commentView.hidden = YES;
    [self.view addSubview:self.commentView];

    self.commentHeaderLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.commentView.bounds) - 15.0 - 44.0 - 15.0, 49.0)];
    self.commentHeaderLabel.centerX = self.commentView.centerX;
     self.commentHeaderLabel.textAlignment = NSTextAlignmentCenter;
    self.commentHeaderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    self.commentHeaderLabel.font = [UIFont systemFontOfSize:17.0f];
    self.commentHeaderLabel.textColorThemeKey = kColorText1;
    [self.commentView addSubview:self.commentHeaderLabel];

    SSThemedView *sepline = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.commentHeaderLabel.frame), CGRectGetWidth(self.commentView.bounds), [UIDevice btd_onePixel])];
    sepline.backgroundColorThemeKey = kColorLine1;
    [self.commentView addSubview:sepline];

    SSThemedButton *commentViewCloseButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    commentViewCloseButton.right = self.commentView.width;
    commentViewCloseButton.centerY = self.commentHeaderLabel.centerY;
    commentViewCloseButton.imageName = @"tsv_close";
    [commentViewCloseButton addTarget:self action:@selector(closeCommentList:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentView addSubview:commentViewCloseButton];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.commentHeaderLabel.bounds), CGRectGetWidth(self.commentView.bounds), CGRectGetHeight(self.commentView.bounds) - CGRectGetHeight(self.commentHeaderLabel.bounds) - 44) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 10)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 37)];
    [self.commentView addSubview:self.tableView];


    [self.tableView registerClass:[AWEVideoCommentCell class] forCellReuseIdentifier:CommentCellIdentifier];

    [self.tableView addPullUpWithInitText:@"上拉可以加载更多数据" pullText:@"松开立即加载更多数据" loadingText:@"加载中..." noMoreText:@"没有更多啦～" timeText:nil lastTimeKey:nil ActioinHandler:^{
        @strongify(self);
        [self handleLoadMoreComments];
    }];

    self.emptyHintView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.commentHeaderLabel.frame), CGRectGetWidth(self.view.bounds),CGRectGetHeight(self.tableView.bounds))];
    self.emptyHintView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.emptyHintView.hidden = YES;
    [self.commentView addSubview:self.emptyHintView];

    UIGestureRecognizer *imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFakeInputBarClick:)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"short_video_comment"]];
    imageView.size = CGSizeMake(115, 115);
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:imageGesture];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    imageView.centerX = CGRectGetWidth(self.emptyHintView.bounds) / 2;
    imageView.centerY = CGRectGetHeight(self.emptyHintView.bounds) / 2.0-20;
    [self.emptyHintView addSubview:imageView];

     UIGestureRecognizer *labelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFakeInputBarClick:)];
    UILabel *emptyHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame)+10, CGRectGetWidth(self.emptyHintView.bounds), 18)];
    emptyHintLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    emptyHintLabel.font = [UIFont boldSystemFontOfSize:15];
    emptyHintLabel.userInteractionEnabled = YES;
    [emptyHintLabel addGestureRecognizer:labelGesture];
    emptyHintLabel.textColor = [UIColor colorWithHexString:@"999999"];
    emptyHintLabel.textAlignment = NSTextAlignmentCenter;
    emptyHintLabel.text = @"暂无评论，点击抢沙发";
    [self.emptyHintView addSubview:emptyHintLabel];
    
    UIGestureRecognizer *inputTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFakeInputBarClick:)];
    SSThemedView *fakeInputBar = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), CGRectGetWidth(self.commentView.bounds), 44)];
       fakeInputBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
       fakeInputBar.backgroundColorThemeKey = kColorBackground4;
       fakeInputBar.borderColorThemeKey = kColorLine7;
       fakeInputBar.separatorAtTOP = YES;
       [fakeInputBar addGestureRecognizer:inputTapGesture];
       [self.commentView addSubview:fakeInputBar];
       self.fakeInputBar = fakeInputBar;
       
       SSThemedView *fakeTextBackgroundView = [[SSThemedView alloc] initWithFrame:CGRectMake(14, 6, CGRectGetWidth(fakeInputBar.bounds) - 28, CGRectGetHeight(fakeInputBar.bounds) - 12)];
       fakeTextBackgroundView.backgroundColorThemeKey = @"grey7";
       fakeTextBackgroundView.layer.cornerRadius = CGRectGetHeight(fakeTextBackgroundView.bounds) / 2;
       fakeTextBackgroundView.layer.masksToBounds = YES;
       fakeTextBackgroundView.layer.borderWidth = [UIDevice btd_onePixel];
       fakeTextBackgroundView.borderColorThemeKey = @"grey7";
       [fakeInputBar addSubview:fakeTextBackgroundView];
    
    SSThemedLabel *inputLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(15, 6, CGRectGetWidth(fakeTextBackgroundView.frame) - 15 , 20)];
    inputLabel.text = @"写评论...";
    inputLabel.font = [UIFont systemFontOfSize:14.0];
    inputLabel.textColorThemeKey = @"grey3";
    [fakeTextBackgroundView addSubview:inputLabel];
    

    [self.observerArray addObject:[[NSNotificationCenter defaultCenter] addObserverForName:@"RelationActionSuccessNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) { // 头条关注通知
        @strongify(self);
        NSString *userID = note.userInfo[@"kRelationActionSuccessNotificationUserIDKey"];
        if ([self.model.user.userId isEqualToString:userID]) {
            NSInteger actionType = [(NSNumber *)note.userInfo[@"kRelationActionSuccessNotificationActionTypeKey"] integerValue];
            if (actionType == 11) {//关注
                self.model.user.relation.isFollowing = @"1";
//                [self.model save];
                [self updateViews];
            }else if (actionType == 12) {//取消关注
                self.model.user.relation.isFollowing = @"0";
//                [self.model save];
                [self updateViews];
            }
        }
    }]];

    [self.tableView triggerPullUp];

    if ([self.dataFetchManager numberOfShortVideoItems]) {
        self.model = [self.dataFetchManager itemAtIndex:[self.dataFetchManager currentIndex]];
    } else {
        [self loadMoreAutomatically:YES showLoading:YES];
    }
    
//    }

    self.commentSlideDownGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentSlideDownGesture:)];
    self.commentSlideDownGesture.delegate = self;
    [self.commentView addGestureRecognizer:self.commentSlideDownGesture];

    self.allowCommentSlideDown = YES;
    self.allowProfileSlideDown = YES;

    self.commentScrollEnable = YES;
    self.profileScrollEnable = YES;

    RACChannelTo(self, tableView.scrollEnabled) = RACChannelTo(self, commentScrollEnable);
    [RACObserve(self, dataFetchManager.currentIndex) subscribeNext:^(id x) {
        @strongify(self);
        if ([self.dataFetchManager numberOfShortVideoItems] > 0){
            self.model = [self.dataFetchManager itemAtIndex:self.dataFetchManager.currentIndex];
            [self loadVideoDataIfNeeded];

            [TSVDownloadManager preloadAppStoreForGroupSourceIfNeeded:self.model.groupSource];
        }
    }];

    RAC(self, groupID) = RACObserve(self, model.groupId);

    self.viewModel = [[TSVDetailViewModel alloc] init];
    RAC(self, viewModel.dataFetchManager) = RACObserve(self, dataFetchManager);
    RAC(self, viewModel.commonTrackingParameter) = RACObserve(self, commonTrackingParameter);
    RAC(self, videoContainerViewController.viewModel) = RACObserve(self, viewModel);
    
}


- (void)handleCloseClick:(UIButton *)btn {
      [self dismissByClickingCloseButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarHidden:[self shouldHideStatusBar] withAnimation:UIStatusBarAnimationNone];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [TSVStartupTabManager sharedManager].detailViewControllerVisibility = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSVVideoDetailVisibilityDidChangeNotification object:nil userInfo:@{
                                                                                                                                   TSVVideoDetailVisibilityDidChangeNotificationVisibilityKey : @YES,
                                                                                                                                   TSVVideoDetailVisibilityDidChangeNotificationEntranceKey   : @([self entrance])
                                                                                                                                   }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kExploreMovieViewStartPlaybackNotification" object:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [UIApplication sharedApplication].statusBarStyle = self.originalStatusBarStyle;

//    [self.inputBar resignActive];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kExploreMovieViewPlaybackFinishNotification" object:self];

    [self.detailPromptManager hidePrompt];
    
    [TSVStartupTabManager sharedManager].detailViewControllerVisibility = NO;
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TSVVideoDetailVisibilityDidChangeNotification object:nil userInfo:@{TSVVideoDetailVisibilityDidChangeNotificationVisibilityKey:@NO}];
    }

    if ([self isBeingPopOrDismissed] && self.ruleID) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:3];
        [parameters setValue:self.ruleID forKey:@"rule_id"];
        [parameters setValue:self.originalGroupID forKey:@"group_id"];
        [parameters setValue:@"hotsoon" forKey:@"message_type"];
        [TTTrackerWrapper eventV3:@"push_page_back_to_feed"
                           params:[parameters copy]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *visibleVC = [TSVUIResponderHelper topmostViewController];
        if (![visibleVC isKindOfClass:[self class]]) {
            [[TTAudioSessionManager sharedInstance] setActive:NO];
        }
    });
}

//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        for (UIViewController *viewController in self.childViewControllers) {
            [viewController didMoveToParentViewController:nil];
        }
    }

    if (!parent) {
        //退出详情页时重置下替换的model和index
//        [self.dataFetchManager replaceModel:nil atIndex:NSNotFound];
        
        NSString *backType = nil;
        switch (self.closeStyle) {
            case AWEVideoDetailCloseStyleNavigationPan:
                backType = @"gesture";
                break;
            case AWEVideoDetailCloseStyleCloseButton:
                backType = @"btn_close";
                break;
            case AWEVideoDetailCloseStylePullPanDown:
                backType = @"pull";
                break;
            default:
                break;
        }
    }
}

//确保没wifi的情况下流量弹框弹出后再根据feed页传入的参数显示keyboard或者评论列表
- (void)firstShowCommentListOrKeyboard
{
    if(self.isFirstTimeShowCommentListOrKeyboard){
        self.isFirstTimeShowCommentListOrKeyboard = NO;

        if ([self.showComment integerValue] == ShowCommentModal){
            [self showCommentsListWithStatus:TSVDetailCommentViewStatusPopByClick];
        } else if([self.showComment integerValue] == ShowKeyboardOnly){
//            self.inputBar.params[@"source"] = @"video_play";
//            [self.inputBar becomeActive];
            [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO replyToCommentID:nil];
        }
    }
}

#pragma mark - getter & setter

- (void)setModel:(FHFeedUGCCellModel *)model
{
    if ([model isEqual:_model]) {
        return;
    }

    _model = model;

    if (self.model.logPb) {
        self.initialLogPb = nil;
    } else if (self.initialLogPb) {
        self.model.logPb = self.initialLogPb;
        self.initialLogPb = nil;
    }

    [self updateModel];

    self.commentManager = [[AWEVideoCommentDataManager alloc] init];
    self.offset = 0;
    [self.tableView reloadData];
    [self handleLoadMoreComments];
    self.tableView.contentOffset = CGPointZero;
}

- (DetailActionRequestManager *)actionManager
{
    if(!_actionManager) {
        _actionManager = [[DetailActionRequestManager alloc] init];
    }
    return _actionManager;
}
- (TTShareManager *)shareManager {
    if (nil == _shareManager) {
        _shareManager = [[TTShareManager alloc] init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}

#pragma mark - Private Methods

- (void)reloadCommentHeaderWithCount:(NSNumber *)commentCount
{
//    self.commentHeaderLabel.text = commentCount ? [NSString stringWithFormat:@"%@条回复", [TTBusinessManager formatCommentCount:commentCount.longLongValue]] : @"暂无回复";
    self.commentHeaderLabel.text  = @"评论";
}

- (void)updateModel
{
    self.model.groupSource = self.model.groupSource ?: ToutiaoGroupSource;

    [self updateViews];

    if ([self.showComment integerValue] == ShowCommentModal) {
        [self showCommentsListWithStatus:TSVDetailCommentViewStatusPopByClick];
    } else if ([self.showComment integerValue] == ShowKeyboardOnly) {
//        self.inputBar.params[@"source"] = @"video_play";
//        [self.inputBar becomeActive];
        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO replyToCommentID:nil];
    }
}

- (void)updateData
{
    if (!self.model && [self.dataFetchManager numberOfShortVideoItems]) {
        self.model = [self.dataFetchManager itemAtIndex:0];
    }
    [self.videoContainerViewController refresh];
}

- (void)loadMoreAutomatically:(BOOL)isAuto showLoading:(BOOL)showLoading
{
    if(![TTReachability isNetworkConnected]){
        if (showLoading) {
            [self.emptyView showEmptyWithTip:@"数据走丢了" errorImageName:@"short_video_nodata" showRetry:YES];
        }
        return;
    }

    if (self.dataFetchManager.isLoadingRequest) {
        return;
    }

    @weakify(self);
    if (showLoading && self.dataFetchManager.numberOfShortVideoItems== 0) {
        [self startLoading];
    }
    
    [self.dataFetchManager requestDataAutomatically:isAuto finishBlock:^(NSUInteger increaseCount, NSError *error) {
        @strongify(self);
        [self endLoading];
        if (error || increaseCount == 0) {
//
            return;
        }else {
//
        }

        [self updateData];

//        [TSVPrefetchImageManager prefetchDetailImageWithDataFetchManager:self.dataFetchManager forward:YES];

        [FHShortVideoPerLoaderManager startPrefetchShortVideoInDetailWithDataFetchManager:self.dataFetchManager];

        if (!self.firstLoadFinished) {
            self.firstLoadFinished = YES;
            [self loadVideoDataIfNeeded];
        }
    }];
}

- (void)loadVideoDataIfNeeded
{
    NSInteger numberOfItemLeft = self.dataFetchManager.numberOfShortVideoItems - self.dataFetchManager.currentIndex;
    if (numberOfItemLeft <= 4 ) {
        [self loadMoreAutomatically:YES showLoading:NO];
    }
}

- (BOOL)isShowingOnTop
{
    return self.view.window != nil;
}

- (BOOL)isBeingPopOrDismissed
{
    if (self.isBeingDismissed) {
        return YES;
    }
    return ![[self.navigationController viewControllers] containsObject:self];
}

- (void)updateViews
{
    [self reloadCommentHeaderWithCount:@([self.model.commentCount floatValue])];
}

- (void)doCommentSafeDiggWithCell:(AWEVideoCommentCell *)cell model:(AWECommentModel *)commentModel cancelDigg:(BOOL)cancelDigg
{
    if (cancelDigg) {
        commentModel.userDigg = NO;
        commentModel.diggCount = @([commentModel.diggCount integerValue] - 1);
    } else {
        commentModel.userDigg = YES;
        commentModel.diggCount = @([commentModel.diggCount integerValue] + 1);
    }
    __weak typeof(cell) weakCell = cell;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakCell) strongCell = cell;
        [strongCell refreshCellWithDiggModel: commentModel cancelDigg:cancelDigg];
    });

    NSString *userId = [AWEVideoPlayAccountBridge currentLoginUserId];
    [self.commentManager diggCommentItemWithCommentId:commentModel.id
                                               itemID:self.model.itemId
                                              groupID:self.model.groupId
                                               userID:userId
                                           cancelDigg:cancelDigg
                                           completion:nil];

}

//按照头条逻辑 在评论发布器出现的时候使用的方法
- (BOOL)alertIfNotLoginWithCompletion:(void(^)(BOOL success))completion
{
    if (![AWEVideoPlayAccountBridge isLogin]) {
        [AWEVideoPlayAccountBridge fetchTTAccount];
        if (![AWEVideoPlayAccountBridge isLogin]) {
            @weakify(self);
            
            [[TTModuleBridge sharedInstance_tt] removeListener:self forKey:@"HTSLoginResult"];
            [[TTModuleBridge sharedInstance_tt] registerListener:self object:nil forKey:@"HTSLoginResult" withBlock:^(id  _Nullable params) {
                completion([params[@"success"] boolValue]);
            }];
            [AWEVideoPlayAccountBridge showLoginView];
            return YES;
        }
    }
    return NO;
}

- (BOOL)alertIfNotLogin
{
    if (![AWEVideoPlayAccountBridge isLogin]) {
        [AWEVideoPlayAccountBridge showLoginView];
        return YES;
    }
    return NO;
}

- (BOOL)alertIfCanNotShare
{
//    if (!self.model.user.relation.allowShare) {
//        [HTSVideoPlayToast show:@"视频正在审核中，暂时不能分享。"];
//        return YES;
//    }
    return NO;
}

- (BOOL)alertIfCanNotComment
{
//    if (!self.model.allowComment) {
//        [HTSVideoPlayToast show:@"视频正在审核中，暂时不能评论。"];
//        return YES;
//    }
    return NO;
}

- (BOOL)alertIfNotValid
{
//    if (self.model.isDelete) {
//        [HTSVideoPlayToast show:@"视频已被删除"];
//        return YES;
//    }
    return !self.model;
}

- (void)showEmptyHint:(BOOL)show
{
    self.emptyHintView.hidden = !show;
    self.tableView.pullUpView.hidden = show;
}

- (void)showCommentViewMaskView:(BOOL)show
{
    if (show) {
        if (!self.commentViewMaskView) {
            self.commentViewMaskView = [[UIView alloc] init];
            self.commentViewMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self.commentViewMaskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCommentListWithShadow)]];
            [self.commentViewMaskView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCommentListWithShadow)]];
        }
        self.commentViewMaskView.frame = self.view.bounds;
        [self.view insertSubview:self.commentViewMaskView belowSubview:self.commentView];
    } else {
        [self.commentViewMaskView removeFromSuperview];
    }
}

- (void)closeCommentList:(UIButton *)button
{
    [self dismissCommentListWithCancelType:@"button"];
}

- (void)dismissCommentListWithShadow
{
    [self dismissCommentListWithCancelType:@"shadow"];
}

- (void)showCommentsListWithStatus:(TSVDetailCommentViewStatus)status
{
    /// 此处传参数TSVDetailCommentViewStatusNone 表示未改变状态
    if (status != TSVDetailCommentViewStatusNone) {
        self.commentViewStatus = status;
    }
    if (status == TSVDetailCommentViewStatusPopBySlideUp) {
        //滑出过一次不再出引导
        [TSVSlideUpPromptViewController setSlideUpPromotionShown];
    }

    self.commentView.hidden = NO;

    [UIView animateWithDuration:.2 customTimingFunction:CustomTimingFunctionCubicOut animation:^{
        self.commentView.frame = CGRectMake(0, kFloatingViewOriginY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kFloatingViewOriginY);
    } completion:^(BOOL finished) {
        if ([self.model.commentCount intValue] == 0) {
            [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO replyToCommentID:nil];
        };
    }];
    [self showCommentViewMaskView:YES];
    [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:YES];
    
  
    
}

- (void)dismissCommentListWithCancelType:(NSString *)cancelType
{
    if (self.isCommentViewAnimating) {
        return;
    }

    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:[self commentExtraPositionDict]];
    [extra setValue:cancelType forKey:@"cancel_type"];

    self.commentViewStatus = TSVDetailCommentViewStatusNone;

    self.isCommentViewAnimating = YES;

    @weakify(self);
    [UIView animateWithDuration:0.2 customTimingFunction:CustomTimingFunctionCubicOut animation:^{
        self.commentView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.commentView.bounds));
    } completion:^(BOOL finished) {
        @strongify(self);
        self.commentView.hidden = YES;
//        self.inputBar.hidden = YES;
        self.isCommentViewAnimating = NO;
    }];

    [self showCommentViewMaskView:NO];
    [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:NO];
}


- (UIView *)innerTransitionView
{
    for (UIView *subview in self.navigationController.view.subviews) {
        if ([subview isMemberOfClass:NSClassFromString(@"UINavigationTransitionView")]) {
            return subview;
        }
    }
    return nil;
}

- (TTNavigationController *)ttNaviController
{
    TTNavigationController *naviController = (TTNavigationController *)self.navigationController;
    if ([naviController isKindOfClass:[TTNavigationController class]]) {
        return naviController;
    }
    return nil;
}


#pragma mark - Actions
- (void)handleFavoriteVideoWithContentItem:(TTFavouriteContentItem *)contentItem
{
    NSString *itemID = self.model.itemId;
    NSString *groupID = self.model.groupId ?: self.groupID;

    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = [[TTGroupModel alloc] initWithGroupID:groupID itemID:itemID impressionID:nil aggrType:1];
    @weakify(self, contentItem);
    self.actionManager.finishBlock = ^(id userInfo, NSError *error) {
        @strongify(self, contentItem);
        //由于分享面板在pod中，暂时使用string构造class
        __block UIWindow * activityPanelControllerWindow = nil;
        Class activityPanelControllerWindowClass = NSClassFromString(@"TTActivityPanelControllerWindow");
        [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:activityPanelControllerWindowClass]) {
                activityPanelControllerWindow = obj;
                *stop = YES;
            }
        }];
        if (!error) {
            self.model.userRepin = !self.model.userRepin;
//            [self.model save];
            [self.orderedData setValue:@(self.model.userRepin) forKeyPath:@"originalData.userRepined"];
            
            contentItem.selected = self.model.userRepin;
            if(self.model.userRepin) {
                TTIndicatorView * indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                                    indicatorText:NSLocalizedString(@"收藏成功", nil)
                                                                                   indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"]
                                                                                   dismissHandler:nil];
                [indicatorView showFromParentView:activityPanelControllerWindow];
            }else {
                TTIndicatorView * indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                                    indicatorText:NSLocalizedString(@"取消收藏", nil)
                                                                                   indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"]
                                                                                   dismissHandler:nil];
                [indicatorView showFromParentView:activityPanelControllerWindow];
            }
            if (groupID.length > 0 ) {
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"group_id"] = groupID;
                userInfo[@"action"] = @(self.model.userRepin);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHUGCUserRepinStateChangeNotification" object:nil userInfo:userInfo];
            }
        } else {
            TTIndicatorView * indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                                indicatorText:NSLocalizedString(@"操作失败", nil)
                                                                               indicatorImage:nil
                                                                               dismissHandler:nil];
            [indicatorView showFromParentView:activityPanelControllerWindow];
        }

    };
    [self.actionManager setContext:context];
    [self.actionManager startItemActionByType:self.model.userRepin ? DetailActionTypeUnFavourite : DetailActionTypeFavourite];
}

- (void)handleReportVideo
{
    self.videoReportVC = [[AWEReportViewController alloc] init];
    self.videoReportVC.reportType = @"video_report";

    @weakify(self);
    [self.videoReportVC performWithReportOptions:self.videoReportOptions completion:^(NSDictionary * _Nonnull parameters) {
        @strongify(self);
        TTReportContentModel *model = [[TTReportContentModel alloc] init];
        model.groupID = self.model.groupId;
        model.videoID = self.model.itemId;
        [[TTReportManager shareInstance] startReportVideoWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeAWEVideo reportFrom:TTReportFromByEnterFromAndCategory(self.model.enterFrom, self.model.categoryId) contentModel:model extraDic:nil animated:YES];

        if((!parameters[@"report"] && !parameters[@"criticism"]) || (isEmptyString(((NSString *)parameters[@"report"])) && isEmptyString(((NSString *)parameters[@"criticism"])))){
            return;
        }

        NSString *reasonStr;

        if(isEmptyString(((NSString *)parameters[@"criticism"]))){
            NSArray *reportType = [parameters[@"report"] componentsSeparatedByString:@","];
            NSMutableArray *reason = [NSMutableArray new];
            for(NSString *type in reportType){
                for(NSDictionary *item in self.videoReportOptions){
                    if ([item[@"type"] isKindOfClass:[NSString class]]&&[type isEqualToString:item[@"type"]]) {
                        [reason addObject:item[@"text"]];
                        break;
                    }else if([item[@"type"] respondsToSelector:@selector(stringValue)]&&[type isEqualToString:[item[@"type"] stringValue]]){
                        [reason addObject:item[@"text"]];
                        break;
                    }
                }
            }
            reasonStr = [reason componentsJoinedByString:@","];
        }else{
            reasonStr = parameters[@"criticism"];
        }
    }];
}

- (void)handleDislikeVideo
{
    NSString *itemID = self.model.itemId;
    NSString *groupID = self.model.groupId ?: self.groupID;

    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = [[TTGroupModel alloc] initWithGroupID:groupID itemID:itemID impressionID:nil aggrType:1];
//    context.actionExtra = self.model.actionExtra;
    context.dislikeSource = @"1";//1表示详情页
//
    
    @weakify(self);
    self.actionManager.finishBlock = ^(id userInfo, NSError *error) {
        @strongify(self);
        if (!error) {
            //通知feed删除cell
            
            NSMutableDictionary *userInfo = @{}.mutableCopy;
            userInfo[@"group_id"] = self.model.groupId;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSVShortVideoDislikeNotification"
                                                                object:self
                                                              userInfo:userInfo];
            if (!self.dislikeGroupIDArray) {
                self.dislikeGroupIDArray = [NSMutableArray array];
            }
            if (!isEmptyString(self.model.groupId)){
                [self.dislikeGroupIDArray addObject:self.model.groupId];
            }
            [[ToastManager manager] showToast:@"将减少推荐类似内容"];
            
            self.isDisliked = YES;
        } else {
            [[ToastManager manager] showToast:@"操作失败"];
        }
    };
    [self.actionManager setContext:context];
    [self.actionManager startItemActionByType:DetailActionTypeNewVersionDislike];
}

- (void)handleDeleteVideo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.model.user.userId forKey:@"user_id"];
    [params setValue:self.model.groupId forKey:@"item_id"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting deleteUGCMovieURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSInteger errorCode = 0;
        if ([jsonObj isKindOfClass:[NSDictionary class]]) {
            errorCode = [(NSDictionary *)jsonObj btd_integerValueForKey:@"error_code"];
        }
        if (error || errorCode != 0) {
            NSString *tip = NSLocalizedString(@"操作失败", nil);
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        } else {
            NSString *tip = NSLocalizedString(@"操作成功", nil);
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            
            /// 给混排列表发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kTSVShortVideoDeleteNotification object:nil userInfo:@{kTSVShortVideoDeleteUserInfoKeyGroupID : self.model.groupId? : @""}];
            /// 标记下需要删除
//            self.model.shouldDelete = YES;
            /// 如果已收藏需要取消收藏
            self.model.userRepin = NO;
            self.closeStyle = AWEVideoDetailCloseStyleNavigationPan;
            self.blackMaskView.hidden = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)handleClose:(BOOL)animated
{
    if ([[self.navigationController viewControllers] firstObject] == self || [[self.navigationController viewControllers] firstObject] == self.parentViewController) {
        [self dismissViewControllerAnimated:animated completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:animated];
    }
}

- (void)handleLoadMoreComments
{
    [self showEmptyHint:NO];

    if ([self.commentManager canLoadMore]) {
        FHFeedUGCCellModel *model = self.model;

        @weakify(self, model);
        [self.commentManager requestCommentListWithID:self.model.itemId groupID:self.model.groupId count:@(CommentFetchCount) offset:[NSNumber numberWithInteger:self.offset] completion:^(AWECommentResponseModel *response, NSError *error) {
            if (error || !response) {
                return;
            }

            @strongify(self, model);
            if(response.totalNumber){
                model.commentCount = [NSString stringWithFormat:@"%@",response.totalNumber] ;
//                [model save];
                [self reloadCommentHeaderWithCount:response.totalNumber];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                if ([self.commentManager canLoadMore]) {
                    self.tableView.hasMore = YES;
                    [self.tableView finishPullUpWithSuccess:!error];
                } else if ([self.commentManager isEmpty]) {
                    self.tableView.hasMore = NO;
                    [self showEmptyHint:YES];
                    [self.tableView finishPullUpWithSuccess:!error];
                } else {
                    self.tableView.hasMore = NO;
                    [self.tableView finishPullUpWithSuccess:!error];
                }
                self.offset += CommentFetchCount;
                [self.tableView reloadData];
            });
        }];
    } else if ([self.commentManager isEmpty]) {
        self.tableView.hasMore = NO;
        [self showEmptyHint:YES];
        [self.tableView finishPullUpWithSuccess:YES];
    } else {
        self.tableView.hasMore = NO;
        [self.tableView finishPullUpWithSuccess:YES];
    }
}

- (void)handleDismissKeyboard
{
//    [self.inputBar resignActive];
}

- (void)handleFakeInputBarClick:(id)sender
{
    NSInteger rank = [self.model.tracerDic btd_integerValueForKey:@"rank" default:0];
    [FHShortVideoTracerUtil clickCommentWithModel:self.model eventIndex:rank eventPosition:@"feed_comment"];

    if ([self alertIfNotValid]) {
        return;
    }
//    [self.inputBar becomeActive];
    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO replyToCommentID:nil];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.commentManager currentCommentCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AWECommentModel *commentModel = [self.commentManager commentForIndexPath:indexPath];
    return [AWEVideoCommentCell heightForTableView:tableView withCommentModel:commentModel];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 预先loadmore
    if (indexPath.row >= [self.commentManager currentCommentCount] - 6) {
        if ([self.commentManager canLoadMore]) {
            [self handleLoadMoreComments];
        }
    }

    AWEVideoCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
    if(!cell){
        cell = [[AWEVideoCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentCellIdentifier];
    }
    AWECommentModel *commentModel = [self.commentManager commentForIndexPath:indexPath];

    [cell configCellWithCommentModel:commentModel videoId:self.model.itemId authorId:self.model.user.userId];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AWECommentModel *commentModel = [self.commentManager commentForIndexPath:indexPath];
//    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:[self commentExtraPositionDict]];
//    [extra setValue:[commentModel.id stringValue] ?: @"" forKey:@"comment_id"];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self alertIfNotValid]) {
        return;
    }

    if ([self alertIfCanNotComment]) {
        return;
    }


    // 自己评论不弹窗
    if ([AWEVideoPlayAccountBridge isCurrentLoginUser:[commentModel.userId stringValue]]) {
        // 草稿是回复A，现在要回复B
        [self.commentWriteView clearInputBar];
        return;
    }

//    if (commentModel.userId && ![self.inputBar.targetCommentModel.userId isEqualToNumber: commentModel.userId]) {
//         草稿是回复视频或回复A，现在要回复B
//        [self.inputBar clearInputBar];
//    }

//    self.inputBar.targetCommentModel = commentModel;
//    self.inputBar.inputTextView.internalGrowingTextView.placeholder = [NSString stringWithFormat:@"@%@：", commentModel.userName];

//    [self.inputBar becomeActive];
    
    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO replyToCommentID:commentModel.id.stringValue];
    [self.commentWriteView setTextViewPlaceholder:[NSString stringWithFormat:@"@%@：", commentModel.userName]];
}


#pragma mark - HTSVideoDetailTopViewDelegate

- (void)topView:(UIViewController *)viewController didClickCloseWithModel:(FHFeedUGCCellModel *)model
{
    [self dismissByClickingCloseButton];
}

- (void)dismissByClickingCloseButton
{
    self.closeStyle = AWEVideoDetailCloseStyleCloseButton;
    self.blackMaskView.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
//    [self.animateManager dismissWithoutGesture];
}

- (void)topView:(UIViewController *)viewController didClickReportWithModel:(FHFeedUGCCellModel *)model
{
    if (!self.model) {
        return;
    }

    if (self.loadingShareImage) {
        //正在加载分享图片 不显示分享弹窗
        return;
    }
    self.loadingShareImage = YES;
    
    @weakify(self);

    [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:YES];

    //小视频暂时不出分享广告
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance share_showInAdPage:@"1" groupId:self.model.groupId];

    NSString *imageURL = [self.model.video.originCover.urlList firstObject];
    [AWEVideoPlayShareBridge loadImageWithUrl:imageURL completion:^(UIImage * _Nonnull image) {
        @strongify(self);
        self.loadingShareImage = NO;
        AWEVideoShareType shareType = AWEVideoShareTypeMore;
        if ([self entrance] == TSVShortVideoListEntranceStory) {
            shareType = AWEVideoShareTypeMoreForStory;
        }
//        if ([self.model isAd]) {
//            shareType = AWEVideoShareTypeAd;
//        }
        AWEVideoShareModel *shareModel = [[AWEVideoShareModel alloc] initWithModel:self.model image:image shareType:shareType];
        [self.shareManager displayActivitySheetWithContent:[shareModel shareContentItems]];
    }];
}

#pragma mark -

- (void)playView:(AWEVideoPlayView *)view didClickInputWithModel:(FHFeedUGCCellModel *)model
{
    if ([self alertIfNotValid]) {
        return;
    }

    if ([self alertIfCanNotComment]) {
        return;
    }

//    if (self.inputBar.targetCommentModel) {
//        // 草稿是回复A，现在要回复视频
//        [self.inputBar clearInputBar];
//    }
//
//    self.inputBar.params[@"source"] = @"video_play";
//    [self.inputBar becomeActive];
    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO replyToCommentID:nil];
}

- (void)playView:(AWEVideoPlayView *)view didClickCommentWithModel:(FHFeedUGCCellModel *)model
{
    [self showCommentsListWithStatus:TSVDetailCommentViewStatusPopByClick];
}

#pragma mark - AWEVideoCommentCellOperateDelegate

- (void)commentCell:(AWEVideoCommentCell *)cell didClickDeleteWithModel:(AWECommentModel *)commentModel
{
    if ([self alertIfNotValid]) {
        return;
    }
    if ([self alertIfNotLogin]) {
        return;
    }

    if (![AWEVideoPlayAccountBridge isCurrentLoginUser:[commentModel.userId stringValue]]) {// 加保护
        [[ToastManager manager] showToast:@"不能删除别人的评论！"];
        return;
    }

    @weakify(self);
    [self.commentManager deleteCommentItemWithId:commentModel.id completion:^(id response, NSError *error) {
        if (!error && [response[@"message"] isEqualToString:@"success"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.tableView reloadData];
                [[ToastManager manager] showToast:@"评论删除成功！"];
                if ([self.commentManager isEmpty]) {
                    [self showEmptyHint:YES];
                }
                self.model.commentCount = [NSString stringWithFormat:@"%ld",[self.commentManager totalCommentCount]] ;
//                [self.model save];
                [self updateViews];
                //发送通知 其他页面同步评论数
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"group_id"] = self.model.groupId;
                userInfo[@"comment_conut"] = @([self.model.commentCount floatValue]);
                [[NSNotificationCenter defaultCenter] postNotificationName:kPostMessageFinishedNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
                
            });
        }else{
            [[ToastManager manager] showToast:@"操作失败，请重试"];
        }
    }];
}

- (void)commentCell:(AWEVideoCommentCell *)cell didClickReportWithModel:(AWECommentModel *)commentModel
{
    self.commentReportVC = [[AWEReportViewController alloc] init];
    self.commentReportVC.reportType = @"comment_report";
    @weakify(self);
    [self.commentReportVC performWithReportOptions:self.userReportOptions completion:^(NSDictionary * _Nonnull parameters) {
        @strongify(self);
        [self.commentManager reportCommentWithType:parameters[@"report"] userInputText:parameters[@"criticism"] userID:[commentModel.userId stringValue] commentID:commentModel.id momentID:nil groupID:self.model.groupId postID:self.model.itemId completion:^(id response, NSError *error) {
            if(error || response[@"extra"]){
                [[ToastManager manager] showToast:@"举报失败"];
            }else{
                [[ToastManager manager] showToast:@"举报成功"];
            }
        }];
    }];
}

- (void)commentCell:(AWEVideoCommentCell *)cell didClickShieldWithModel:(AWECommentModel *)commentModel
{
//    [FHHouseUGCAPI commentShield:self.model.groupId commentId:commentModel.id.stringValue completion:^(bool success, NSError * _Nonnull error) {
//        if(success){
            [[ToastManager manager] showToast:@"屏蔽成功"];
//        }else{
//            [[ToastManager manager] showToast:@"屏蔽失败"];
//        }
//    }];
}

- (void)commentCell:(AWEVideoCommentCell *)cell didClickLikeWithModel:(AWECommentModel *)commentModel
{
    if (![TTAccountManager isLogin]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *page_type = [FHShortVideoTracerUtil pageType];
        [params setObject:page_type forKey:@"enter_from"];
        [params setObject:@"click_publisher" forKey:@"enter_type"];
        // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
        [params setObject:@(YES) forKey:@"need_pop_vc"];
        params[@"from_ugc"] = @(YES);
        [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                //登录成功 走发送逻辑
                if ([TTAccountManager isLogin]) {
                    [self commentCellLoginSuccess:cell didClickLikeWithModel:commentModel];
                }
            }
        }];
    }else {
        [self commentCellLoginSuccess:cell didClickLikeWithModel:commentModel];
    }
}

- (void)commentCellLoginSuccess:(AWEVideoCommentCell *)cell didClickLikeWithModel:(AWECommentModel *)commentModel {
    NSString *eventName = commentModel.userDigg ? @"click_dislike" : @"click_like";
    NSString *position = @"comment";
    NSInteger rank = [self.model.tracerDic btd_integerValueForKey:@"rank" default:0];
    [FHShortVideoTracerUtil clickLikeOrdisLikeWithWithName:eventName eventPosition:position eventModel:self.model eventIndex:rank commentId:[commentModel.id stringValue]];
    if ([self alertIfNotValid]) {
        return;
    }

    BOOL cancelDigg = commentModel.userDigg;
    [self doCommentSafeDiggWithCell:cell model:commentModel cancelDigg:cancelDigg];
}

- (void)commentCell:(AWEVideoCommentCell *)cell didClickUserWithModel:(AWECommentModel *)commentModel
{
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:[self commentExtraPositionDict]];
    [extra setValue:[commentModel.userId stringValue] ?: @"" forKey:@"user_id"];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.categoryName forKey:@"category_name"];
    [params setValue:@"comment_list" forKey:@"from_page"];
    [params setValue:self.model.groupId forKey:@"group_id"];
    [AWEVideoPlayTransitionBridge openProfileViewWithUserId:[commentModel.userId stringValue] params:params];
}

- (void)commentCell:(AWEVideoCommentCell *)cell didClickUserNameWithModel:(AWECommentModel *)commentModel
{
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:[self commentExtraPositionDict]];
    [extra setValue:[commentModel.userId stringValue] ?: @"" forKey:@"user_id"];

    //进入个人主页ab
    [AWEVideoPlayTransitionBridge openProfileViewWithUserId:[commentModel.userId stringValue] params:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tableView]) {
        if (scrollView.contentOffset.y <= 0) {
            [scrollView setContentOffset:CGPointZero];
            self.allowCommentSlideDown = YES;
        } else {
            self.allowCommentSlideDown = NO;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tableView]) {
        self.commentBeginDragContentOffsetY = scrollView.contentOffset.y;
    }
    [self loadVideoDataIfNeeded];
}

#pragma mark - handle slideGesture
- (void)handleSlideLeftGesture:(UIPanGestureRecognizer *)gesture
{
    CGFloat progress = fabs([gesture translationInView:self.view].x / self.view.bounds.size.width);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [TSVTransitionAnimationManager sharedManager].enterProfilePercentDrivenTransition = [UIPercentDrivenInteractiveTransition new];
        NSMutableDictionary *extraUserInfo = [NSMutableDictionary dictionary];
        [extraUserInfo setValue:self.model.user.name forKey:@"username"];
        [extraUserInfo setValue:self.model.user.avatarUrl forKey:@"avatar"];
        [extraUserInfo setValue:self.model.user.userAuthInfo forKey:@"userAuthInfo"];
        [extraUserInfo setValue:@([self.model.user.relation.isFollowing floatValue]) forKey:@"isFollowing"];
        [extraUserInfo setValue:@([self.model.user.relation.isFollowed floatValue]) forKey:@"isFollowed"];
        [extraUserInfo setValue:self.model.user.desc forKey:@"desc"];
        [extraUserInfo setValue:@([self.model.user.relationCount.followingsCount floatValue]) forKey:@"followingCount"];
        [extraUserInfo setValue:@([self.model.user.relationCount.followersCount floatValue]) forKey:@"followedCount"];
        [AWEVideoPlayTransitionBridge openProfileViewWithUserId:self.model.user.userId params:nil userInfo:@{@"extra_user_info": extraUserInfo}];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [[TSVTransitionAnimationManager sharedManager].enterProfilePercentDrivenTransition updateInteractiveTransition:progress];
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [gesture velocityInView:self.view];
        if (progress > 0.3 || fabs(velocity.x) > 500) {
            //用户左滑进过个人主页，标记下，之后不在出引导
            [TSVSlideLeftEnterProfilePromptViewController setSlideLeftPromotionShown];
            [[TSVTransitionAnimationManager sharedManager].enterProfilePercentDrivenTransition finishInteractiveTransition];
        } else {
            [[TSVTransitionAnimationManager sharedManager].enterProfilePercentDrivenTransition cancelInteractiveTransition];
        }
        [TSVTransitionAnimationManager sharedManager].enterProfilePercentDrivenTransition = nil;
    }
}

//- (void)layoutProfileViewController
//{
//    if (!self.profileViewController.parentViewController) {
//        self.profileViewController.view.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kFloatingViewOriginY);
//        self.profileViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.profileViewController.view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
//        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//        maskLayer.frame = self.profileViewController.view.bounds;
//        maskLayer.path = maskPath.CGPath;
//        self.profileViewController.view.layer.mask = maskLayer;
//
//        self.profileViewController.view.hidden = YES;
//        self.profileSlideDownGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfileSlideDownGesture:)];
//        self.profileSlideDownGesture.delegate = self;
//        [self.profileViewController.view addGestureRecognizer:self.profileSlideDownGesture];
//        [self addChildViewController:self.profileViewController];
//        [self.view addSubview:self.profileViewController.view];
//    }
//}
//
//- (void)updateProfileViewModelIfNeeded
//{
//    if ([self.profileViewController.viewModel.cellViewModelArray count] == 0 || ![self.profileViewController.viewModel.userID isEqualToString:self.model.author.userID]){
//        ///如果uid不相同，需要拉取新的个人作品数据
//        self.profileViewController.viewModel = [[TSVProfileViewModel alloc] initWithModel:self.model commonTrackingParameter:self.commonTrackingParameter dataFetchManager:nil];
//    }
//}

- (void)handleSlideUpGesture:(UIPanGestureRecognizer *)gesture
{
    UIView *floatingView = nil;
//    if (self.slideUpViewType == TSVDetailSlideUpViewTypeProfile) {
//        [self layoutProfileViewController];
//        floatingView = self.profileViewController.view;
//    }
    if (self.slideUpViewType == TSVDetailSlideUpViewTypeComment) {
        floatingView = self.commentView;
    }

    if (!floatingView) {
        return;
    }

    CGPoint transition = [gesture translationInView:self.view];
    CGPoint velocity = [gesture velocityInView:self.view];

    if (gesture.state == UIGestureRecognizerStateBegan) {
//        if (self.slideUpViewType == TSVDetailSlideUpViewTypeProfile) {
//            [self updateProfileViewModelIfNeeded];
//        }
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        floatingView.hidden = NO;
        floatingView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - MIN(CGRectGetHeight(floatingView.bounds), MAX(- transition.y, 0)), CGRectGetWidth(self.view.bounds), CGRectGetHeight(floatingView.bounds));
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        if (CGRectGetMaxY(floatingView.frame) - CGRectGetHeight(self.view.bounds) >= CGRectGetHeight(floatingView.bounds) * 2.0 / 3.0 && - velocity.y < 500) {
//            if (self.slideUpViewType == TSVDetailSlideUpViewTypeProfile) {
//                [self dismissProfileViewWithCancelType:@"gesture"];
//            }
            if (self.slideUpViewType == TSVDetailSlideUpViewTypeComment) {
                [self dismissCommentListWithCancelType:@"gesture"];
            }
        } else {
//            if (self.slideUpViewType == TSVDetailSlideUpViewTypeProfile) {
//                //滑出过一次不再出引导
//                [TSVSlideUpPromptViewController setSlideUpPromotionShown];
//                [self showProfileView];
//            }
            if (self.slideUpViewType == TSVDetailSlideUpViewTypeComment) {


                [self showCommentsListWithStatus:TSVDetailCommentViewStatusPopBySlideUp];
            }
        }
    }
}

- (void)handleCommentSlideDownGesture:(UIPanGestureRecognizer *)gesture
{
    UIView *floatingView = self.commentView;
    CGPoint transition = [gesture translationInView:floatingView];
    CGPoint location = [gesture locationInView:floatingView];
    CGPoint velocity = [gesture velocityInView:floatingView];

    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (location.y <= 49) {
            //点击范围在标题栏，标志位清零
            self.allowCommentSlideDown = YES;
            self.commentBeginDragContentOffsetY = 0;
        }
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (self.allowCommentSlideDown) {
            self.commentScrollEnable = NO;
            CGFloat diff = transition.y - self.commentBeginDragContentOffsetY;
            floatingView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - CGRectGetHeight(floatingView.bounds) + MAX(0, diff), CGRectGetWidth(self.view.bounds), CGRectGetHeight(floatingView.bounds));
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        if (CGRectGetMaxY(floatingView.frame) - CGRectGetHeight(self.view.bounds) >= CGRectGetHeight(floatingView.bounds) / 3.0 || (velocity.y >= 500 && !self.commentScrollEnable)) {
            [self dismissCommentListWithCancelType:@"gesture"];
        } else {
            [self showCommentsListWithStatus:TSVDetailCommentViewStatusNone];
        }
        self.commentScrollEnable = YES;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.slideUpGesture) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.view];
        float x = velocity.x;
        float y = velocity.y;
        
        double angle = atan2(x, y) * 180.0f / M_PI;
        
        if (angle < 0) {
            angle += 360.f;
        }
        
        if (angle > 225.f) {
            return NO;
        }
        
        if (self.slideUpViewType == TSVDetailSlideUpViewTypeComment) {
            return y < 0 && self.commentView.hidden;
        } else {
            return NO;
        }
    }
    if (gestureRecognizer == self.commentSlideDownGesture) {
        return [self.commentSlideDownGesture translationInView:self.commentView].y > 0;
    }
//    if (gestureRecognizer == self.profileSlideDownGesture) {
//        return [self.profileSlideDownGesture translationInView:self.profileViewController.view].y > 0;
//    }
    if (gestureRecognizer == self.slideLeftGesture) {
        //限制左滑，且非个人主页进的详情页
        BOOL enterFromProfile = ([self entrance] == TSVShortVideoListEntranceProfile);
        return [self.slideLeftGesture translationInView:self.view].x < 0 && !enterFromProfile;
    }

    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.commentSlideDownGesture && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return YES;
    }
//    else if (gestureRecognizer == self.profileSlideDownGesture && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
//        return YES;
//    }
    return NO;
}
#pragma mark - Orientation

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (UIView *)finishBackView{
    if (_finishBackView == nil){
        _finishBackView = [TTInteractExitHelper getSuitableFinishBackViewInPreViewController];
    }
    return _finishBackView;
}

- (void)addPreviousVCToNaviView
{
    NSArray *VCs = [[self.navigationController.viewControllers reverseObjectEnumerator] allObjects];
    if (VCs.count > 1){
        UIViewController *VC = [VCs objectAtIndex:1];

        _popToView = VC.view;
        _popToView.frame = self.navigationController.view.bounds;
        [self.navigationController.view addSubview:_popToView];
        if ([VCs count] == 2 && VC.tabBarController) {
            ///截图会触发列表页的collectionView的layoutSubviews,使得下拉退出时能回到正确的位置，修改时需要注意！！！
            _bottomTabbarView = [UIViewController tabBarSnapShotView];
        }
        [self.navigationController.view addSubview:_bottomTabbarView];
        [self.navigationController.view addSubview:_blackMaskView];
    }
}

- (void)removePreviousVCFromNaviView
{
    [_popToView removeFromSuperview];
    [_blackMaskView removeFromSuperview];
    [_bottomTabbarView removeFromSuperview];
}

#pragma mark - TTPreviewPanBackDelegate
- (BOOL)ttPreviewPanGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
{
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        return [self.videoContainerViewController canPullToClose];
//    }
    return NO;
}

//scale仅仅在 TTPreviewAnimateStateChange下 有正确的值，其他都为0
- (void)ttPreviewPanBackStateChange:(TTPreviewAnimateState)currentState scale:(float)scale
{
    switch (currentState) {
        case TTPreviewAnimateStateWillBegin:
        {
            FHFeedUGCCellModel *model = (FHFeedUGCCellModel*)[self.originalDataFetchManager itemAtIndex:self.originalDataFetchManager.currentIndex replaced:NO];

            NSURL *URL = nil;
//            URL = [NSURL URLWithString:[model.animatedImageModel.urlWithHeader firstObject][@"url"] ?:@""];
            FHFeedContentImageListModel *imageModel = [model.animatedImageList firstObject];
            URL = [NSURL URLWithString:imageModel.url?:@""];
            NSString *cacheKey = [[YYWebImageManager sharedManager] cacheKeyForURL:URL];
            if ([[[YYWebImageManager sharedManager] cache] containsImageForKey:cacheKey]) {
                self.fakeBackImage = [[[YYWebImageManager sharedManager] cache]  getImageForKey:cacheKey];
            } else if (model.largeImageList.count>0) {
                FHFeedContentImageListModel *largeImage = [model.animatedImageList firstObject];
                NSURL *stillImageURL = [NSURL URLWithString:largeImage.url?:@""];
                NSString *stillImageCacheKey = [[YYWebImageManager sharedManager] cacheKeyForURL:stillImageURL];
                if ([[[YYWebImageManager sharedManager] cache] containsImageForKey:stillImageCacheKey]) {
                   self.fakeBackImage = [[[YYWebImageManager sharedManager] cache]  getImageForKey:stillImageCacheKey];
                } else {
                    @weakify(self);
                    [[SDWebImageManager sharedManager] loadImageWithURL:stillImageURL options:SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                        @strongify(self);
                        self.fakeBackImage = image;
                    }];
                }
            }
            [self removePreviousVCFromNaviView];
            [self addPreviousVCToNaviView];
            [self.videoContainerViewController pauseCurrentVideo];
            [UIApplication sharedApplication].statusBarStyle = self.originalStatusBarStyle;
        }
            break;
        case TTPreviewAnimateStateChange:
        {
            self.blackMaskView.alpha = MAX(0,(scale*14-13 - _animateManager.minScale)/(1 - _animateManager.minScale));
        }
            break;
        case TTPreviewAnimateStateDidFinish:
        {
            [self removePreviousVCFromNaviView];
            [self handleClose:NO];
        }
            break;
        case TTPreviewAnimateStateWillCancel:
        {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        }
            break;
        case TTPreviewAnimateStateDidCancel:
        {
            [self removePreviousVCFromNaviView];
            [self.videoContainerViewController playCurrentVideo];
        }
            break;
        default:
            break;
    }
}

- (UIView *)ttPreviewPanBackGetOriginView
{
    return [self.videoContainerViewController exitScreenshotView];
}

- (UIView *)ttPreviewPanBackGetBackMaskView
{
    if (self.exitManager.updateTargetViewBlock){
        return self.exitManager.updateTargetViewBlock();
    }
    return self.finishBackView;
}

- (CGRect)ttPreviewPanBackTargetViewFrame;
{
    if (self.exitManager.updateImageFrameBlock) {
        return self.exitManager.updateImageFrameBlock();
    }
    return CGRectZero;
}

//最终的画布，用于解决遮挡的问题，一个理想的view。- -!
- (UIView *)ttPreviewPanBackGetFinishBackgroundView
{
    return self.finishBackView;
}

//可以在finish和cancel一起动画
- (void)ttPreviewPanBackFinishAnimationCompletion{
    self.blackMaskView.alpha = 0;

    if (self.closeStyle == AWEVideoDetailCloseStyleNavigationPan) {
        self.closeStyle = AWEVideoDetailCloseStylePullPanDown;
    }
}

- (void)ttPreviewPanBackCancelAnimationCompletion{
    self.blackMaskView.alpha = 1;
}

- (UIImage *)ttPreviewPanBackImageForSwitch;
{
    return _fakeBackImage;
}

- (TTImageViewContentMode)ttPreViewPanBackImageViewForSwitchContentMode
{
    if (self.exitManager.fakeImageContentMode) {
        return self.exitManager.fakeImageContentMode;
    }
    return TTImageViewContentModeScaleAspectFillRemainTop;
}

#pragma TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
    [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:NO];
    [self.viewModel didShareToActivityNamed:activity.contentItemType];

    id<TTActivityContentItemProtocol> contentItem = activity.contentItem;
    if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeFavourite]) {
        [self handleFavoriteVideoWithContentItem:(TTFavouriteContentItem *)contentItem];
    } else if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeDislike]) {
        [self handleDislikeVideo];
    } else if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeBlock]) {
        [self handleDislikeVideo];
    }else if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeReport]) {
        [self handleReportVideo];
    } else if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeDelete]) {
        [self handleDeleteVideo];
    } else if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
        [FHShortVideoTracerUtil clicksharePlatForm:self.model eventPlantFrom:@"weitoutiao"];
        [TSVVideoDetailShareHelper handleForwardUGCVideoWithModel:self.model];
    } else if (!isEmptyString(contentItem.contentItemType)){
        NSString *type = [AWEVideoShareModel labelForContentItemType:contentItem.contentItemType];
        NSAssert(type, @"Type should not be empty");
        [FHShortVideoTracerUtil clicksharePlatForm:self.model eventPlantFrom:type?:@""];
    } else {
    }
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    [TSVVideoShareManager synchronizeUserDefaultsWithAvtivityType:activity.contentItemType];
}

- (void)p_willOpenWriteCommentViewWithReservedText:(NSString *)reservedText switchToEmojiInput:(BOOL)switchToEmojiInput replyToCommentID:(NSString *)replyToCommentID {
    
    NSMutableDictionary *condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:self.groupModel forKey:kQuickInputViewConditionGroupModel];
    [condition setValue:reservedText forKey:kQuickInputViewConditionInputViewText];
    [condition setValue:@(NO) forKey:kQuickInputViewConditionHasImageKey];
    if(replyToCommentID){
        [condition setValue:replyToCommentID forKey:kQuickInputViewConditionReplyToCommentID];
    }
    
    NSString *fwID = self.groupID;
    
//    TTArticleReadQualityModel *qualityModel = [[TTArticleReadQualityModel alloc] init];
//    double readPct = (self.mainScrollView.contentOffset.y + self.mainScrollView.frame.size.height) / self.mainScrollView.contentSize.height;
//    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
//    qualityModel.readPct = @(percent);
    //    qualityModel.stayTimeMs = @([self.detailModel.sharedDetailManager currentStayDuration]);
    
    __weak typeof(self) wSelf = self;
    
    TTCommentWriteManager *commentManager = [[TTCommentWriteManager alloc] initWithCommentCondition:condition commentViewDelegate:self commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fwID;
        [wSelf clickSubmitComment];
    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:nil];
    commentManager.enterFrom = @"feed_detail";
    commentManager.enter_type = @"submit_comment";
    commentManager.reportParams = self.tracerDic[@"extraDic"];
    
    self.commentWriteView = [[FHPostDetailCommentWriteView alloc] initWithCommentManager:commentManager];

    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;
    
    [self.commentWriteView showInView:self.view animated:YES];
}

- (void)clickSubmitComment {
    NSInteger rank = [self.model.tracerDic btd_integerValueForKey:@"rank" default:0];
     [FHShortVideoTracerUtil clickCommentSubmitWithModel:self.model eventIndex:rank];
}

#pragma mark - TTWriteCommentViewDelegate

- (void)commentView:(TTCommentWriteView *) commentView cancelledWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager {
    // commentWriteManager.delegate = nil;
}

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData
{
    //数据处理
    AWECommentModel *model = nil;
    NSError *mappingError = nil;
    NSDictionary *dataDic = [responseData objectForKey:@"data"];
    if([dataDic isKindOfClass:[NSDictionary class]]){
        model = [MTLJSONAdapter modelOfClass:[AWECommentModel class]
                          fromJSONDictionary:dataDic
                                       error:&mappingError];
    }
    if(model){
        [self.commentManager.commentArray insertObject:model atIndex:0];
        self.commentManager.totalCount += 1;
    }
    
    commentWriteManager.delegate = nil;
    [self.commentWriteView dismissAnimated:YES];
    
    [self.commentWriteView clearInputBar];
    self.model.commentCount = [NSString stringWithFormat:@"%ld", [self.commentManager totalCommentCount]];
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    userInfo[@"group_id"] = self.model.groupId;
    userInfo[@"comment_conut"] = @([self.model.commentCount floatValue]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kPostMessageFinishedNotification
                                                        object:nil
                                                      userInfo:userInfo];
//    [self.model save];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showEmptyHint:NO];
        [self.tableView reloadData];
        [self updateViews];
        
        if (self.commentView.hidden) {
            [self showCommentsListWithStatus:TSVDetailCommentViewStatusPopByClick];
        }
        // 滑动定位到评论位置
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.tableView numberOfSections] - 1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
}

#pragma mark -

/// 评论浮层里的埋点需要区分：是不是上滑出的浮层
- (NSDictionary *)commentExtraPositionDict
{
    if (self.commentViewStatus == TSVDetailCommentViewStatusPopBySlideUp) {
        return @{@"position": @"draw_bottom"};
    } else {
        return @{@"position": @"detail"};
    }
}

/// comment_bottom是为了和底部的“写评论”框区分，"写评论"的框和写评论相关的三个埋点 @马怡民
- (NSDictionary *)writeCommentExtraPositionDict
{
    if (self.commentViewStatus == TSVDetailCommentViewStatusPopBySlideUp) {
        return @{@"position": @"draw_bottom"};
    } else if (self.commentViewStatus == TSVDetailCommentViewStatusPopByClick) {
        return @{@"position": @"comment_bottom"};
    } else {
        return @{@"position": @"detail"};
    }
}

#pragma mark -
- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    self.tableView.height = CGRectGetHeight(self.commentView.bounds) - CGRectGetHeight(self.commentHeaderLabel.bounds) - 44 - self.view.tt_safeAreaInsets.bottom;
    self.fakeInputBar.top = self.tableView.bottom;
}

- (BOOL)shouldHideStatusBar
{
    return ![UIDevice btd_isIPhoneXSeries];
}

#pragma mark -  InteractExitProtocol

- (UIView *)suitableFinishBackView{
//    return self.profileViewController.collectionView;
    return nil;
}

#pragma mark - Entrance

- (TSVShortVideoListEntrance)entrance
{
    TSVShortVideoListEntrance ret = TSVShortVideoListEntranceOther;
    
//    if ([self.dataFetchManager respondsToSelector:@selector(entrance)]) {
//        ret = self.dataFetchManager.entrance;
//    }
    
    return ret;
}

@end

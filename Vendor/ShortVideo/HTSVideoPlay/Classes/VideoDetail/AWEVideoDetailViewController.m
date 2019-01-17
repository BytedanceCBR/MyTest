//
//  AWEVideoDetailViewController.m
//  LiveStreaming
//
//  Created by 01 on 17/5/3.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "AWEVideoDetailViewController.h"
#import "AWEReportViewController.h"
// View
#import "AWEVideoPlayView.h"
#import "AWEVideoCommentCell.h"
#import "AWECommentInputBar.h"
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
#import <TTNavigationController.h>
#import <UIImage+TTThemeExtension.h>
#import <TTDeviceHelper.h>
#import <TTModuleBridge.h>
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
#import <TTInteractExitHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import "UIViewController+TabBarSnapShot.h"
#import "UIImageView+WebCache.h"
#import "AWEVideoDetailFirstUsePromptViewController.h"
#import "AWEVideoDetailTracker.h"
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
#import <TTAudioSessionManager.h>

#import "ExploreOrderedData.h"

#define kPostMessageFinishedNotification    @"kPostMessageFinishedNotification"

@import AVFoundation;

NSString * const TSVVideoDetailVisibilityDidChangeNotification = @"TSVVideoDetailVisibilityDidChangeNotification";
NSString * const TSVVideoDetailVisibilityDidChangeNotificationVisibilityKey = @"TSVVideoDetailVisibilityDidChangeNotificationVisibilityKey";
NSString * const TSVVideoDetailVisibilityDidChangeNotificationEntranceKey = @"TSVVideoDetailVisibilityDidChangeNotificationEntranceKey";

///评论页状态 未弹出/点击弹出／上滑弹出
typedef NS_ENUM(NSInteger, TSVDetailCommentViewStatus) {
    TSVDetailCommentViewStatusNone,
    TSVDetailCommentViewStatusPopByClick,
    TSVDetailCommentViewStatusPopBySlideUp,
};

@interface AWEVideoDetailViewController () <UITableViewDataSource, UITableViewDelegate, HTSVideoPlayGrowingTextViewDelegate, UIGestureRecognizerDelegate, AWEVideoCommentCellOperateDelegate, TTRouteInitializeProtocol, TTPreviewPanBackDelegate, TTShareManagerDelegate, TTInteractExitProtocol>

// View
@property (nonatomic, strong) SSThemedView *commentView;
@property (nonatomic, strong) SSThemedLabel *commentHeaderLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWEVideoContainerViewController *videoContainerViewController;
//@property (nonatomic, strong) TSVProfileViewController *profileViewController;
@property (nonatomic, strong) UIView *emptyHintView;
@property (nonatomic, strong) AWECommentInputBar *inputBar;
@property (nonatomic, strong) UIView *keyboardMaskView;
@property (nonatomic, strong) AWEReportViewController *commentReportVC;
@property (nonatomic, strong) AWEReportViewController *videoReportVC;
@property (nonatomic, strong) SSThemedView *fakeInputBar;
// Data
@property (nonatomic, strong) TSVDetailViewModel *viewModel;
@property (nonatomic, strong) AWEVideoCommentDataManager *commentManager;
@property (nonatomic, strong) id<TSVShortVideoDataFetchManagerProtocol> dataFetchManager;
@property (nonatomic, strong) id<TSVShortVideoDataFetchManagerProtocol> originalDataFetchManager;
@property (nonatomic, copy) NSDictionary *pageParams;
@property (nonnull, copy) NSString *groupID;
@property (nonatomic, copy) NSString *groupSource;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, strong) NSNumber *showComment;//0不弹，1弹起评论浮层，2弹输入框
@property (nonatomic, copy) NSDictionary *commonTrackingParameter;
@property (nonatomic, copy) NSDictionary *initialLogPb;
// 状态
@property (nonatomic, assign) BOOL firstLoadFinished;
@property (nonatomic, assign) BOOL isFirstTimeShowCommentListOrKeyboard;

@property (nonatomic, assign) BOOL isDisliked;
@property (nonatomic, assign) BOOL hasMore;      // 还有没有评论数据可以拉取
@property (nonatomic, assign) NSInteger offset;  // 请求新数据的时候，offet参数
@property (nonatomic, assign) AWEVideoDetailCloseStyle closeStyle;
@property (nonatomic, assign) NSTimeInterval totalDuration;
// 详情页数据
@property (nonatomic, strong) TTShortVideoModel *model;
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
;

@end

static const CGFloat kFloatingViewOriginY = 230;

@implementation AWEVideoDetailViewController

+ (void)load
{
    RegisterRouteObjWithEntryName(@"awemevideo");
    RegisterRouteObjWithEntryName(@"ugc_video_recommend");
    RegisterRouteObjWithEntryName(@"huoshanvideo");
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];

    if (self) {
        /// query 里是以url传入的参数
        NSDictionary *params = paramObj.queryParams;
        /// extra 里是以dict传入的参数
        NSDictionary *extraParams = paramObj.userInfo.extra;
        /// allParams 里是以上两个字典的并集，extra会覆盖 query
        _pageParams = paramObj.allParams.copy;

        if ([TTDeviceHelper OSVersionNumber] < 8.) {
            [[TTMonitor shareManager] trackService:@"shortvideo_detail_unsupported_os"
                                        attributes:@{
                                                     @"enter_from": [params[AWEVideoEnterFrom] copy] ?: @"",
                                                     @"category_name": [params[AWEVideoCategoryName] copy] ?: @"",
                                                     @"url": [paramObj.sourceURL absoluteString],
                                                     }];
            return nil;
        }

        _groupID = [params[AWEVideoGroupId] copy] ?: @"";
        _originalGroupID = [params[AWEVideoGroupId] copy] ?: @"";
        _ruleID = [params[AWEVideoRuleId] copy];
        _groupSource = [params[VideoGroupSource] copy] ?: @"";
        _showComment = [params[AWEVideoShowComment] copy];
        _categoryName = [params tt_stringValueForKey:AWEVideoCategoryName];
        _commonTrackingParameter = @{
                                     @"enter_from": [params[AWEVideoEnterFrom] copy] ?: @"",
                                     @"category_name": [params[AWEVideoCategoryName] copy] ?: @""
                                     };

        if ([paramObj.host isEqualToString:@"huoshanvideo"]) {
            // 引导老火山详情页到新的页面并进行上报
            [[TTMonitor shareManager] trackService:@"huoshan_old_detail"
                                             value:@1
                                             extra:@{
                                                     @"url": [paramObj.sourceURL absoluteString] ?: @"",
                                                     }];
        }

        if (params[@"log_pb"]) {
            id logPb = [NSJSONSerialization JSONObjectWithData:[params[@"log_pb"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSAssert(logPb, @"logPb must not be nil");
            _initialLogPb = logPb?: @{};
            NSAssert([_initialLogPb isKindOfClass:[NSDictionary class]], @"log_pb must be a dictionary");
        }
        
        [self initReportOptions];
        [self initProperty];

        if (extraParams[HTSVideoListFetchManager]) {
            self.dataFetchManager = extraParams[HTSVideoListFetchManager];
        } else if ([params[@"load_more"] integerValue] == 1) {
            self.dataFetchManager = [[TSVShortVideoDetailFetchManager alloc] initWithGroupID:self.groupID
                                                                             loadMoreType:TSVShortVideoListLoadMoreTypePersonalHome];
            self.dataFetchManager.shouldShowNoMoreVideoToast = YES;
        } else if ([params[@"load_more"] integerValue] == 2) {
            self.dataFetchManager = [[TSVShortVideoCategoryFetchManager alloc] init];
        } else if ([params[@"load_more"] integerValue] == 3) {
            NSString *forumID = [params tt_stringValueForKey:@"forum_id"];
            NSString *topCursor = [params tt_stringValueForKey:@"top_cursor"];
            NSString *cursor = [params tt_stringValueForKey:@"cursor"];
            NSString *seq = [params tt_stringValueForKey:@"seq"];
            NSString *sortType = [params tt_stringValueForKey:@"sort_type"];
            self.dataFetchManager = [[TSVShortVideoDetailFetchManager alloc] initWithGroupID:self.groupID
                                                                                loadMoreType:TSVShortVideoListLoadMoreTypeActivity
                                                                             activityForumID:forumID
                                                                           activityTopCursor:topCursor
                                                                              activityCursor:cursor
                                                                                 activitySeq:seq
                                                                            activitySortType:sortType];
            self.dataFetchManager.shouldShowNoMoreVideoToast = YES;
        } else if ([params[@"load_more"] integerValue] == 4) {
            self.dataFetchManager = [[TSVShortVideoDetailFetchManager alloc] initWithGroupID:self.groupID
                                                                                loadMoreType:TSVShortVideoListLoadMoreTypeWeiTouTiao];
            self.dataFetchManager.shouldShowNoMoreVideoToast = YES;
        } else if ([params[@"load_more"] integerValue] == 5) {
            self.dataFetchManager = [[TSVShortVideoDetailFetchManager alloc] initWithGroupID:self.groupID
                                                                                loadMoreType:TSVShortVideoListLoadMoreTypePush];
            self.dataFetchManager.shouldShowNoMoreVideoToast = YES;
        } else {
            self.dataFetchManager = [[TSVShortVideoDetailFetchManager alloc] initWithGroupID:self.groupID
                                                                             loadMoreType:TSVShortVideoListLoadMoreTypeNone];
            self.dataFetchManager.shouldShowNoMoreVideoToast = NO;
        }
        self.originalDataFetchManager = self.dataFetchManager;

        @weakify(self);
        [RACObserve(self, dataFetchManager) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if ([self.dataFetchManager respondsToSelector:@selector(dataDidChangeBlock)]) {
                self.dataFetchManager.dataDidChangeBlock = ^{
                    @strongify(self);
                    [self updateData];
                };
            }
        }];

        if (extraParams[HTSVideoDetailExitManager]) {
            self.exitManager = extraParams[HTSVideoDetailExitManager];
        }
        if (extraParams[TSVDetailPushFromProfileVC]) {
            self.pushFromProfileVC = [extraParams tt_boolValueForKey:TSVDetailPushFromProfileVC];
        }
        
        if (extraParams[HTSVideoDetailOrderedData]) {
            self.orderedData = extraParams[HTSVideoDetailOrderedData];
        }
    }
    return self;
}

- (void)initReportOptions
{
    self.userReportOptions = [TTReportManager fetchReportUserOptions];
    self.videoReportOptions = [TTReportManager fetchReportVideoOptions];
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
    
    [[TTCustomAnimationManager sharedManager] registerFromVCClass:[self class] toVCClass:[self class] animationClass:[TSVProfileVCEnterDetailAnimation class]];
    [TSVDetailRouteHelper registerCustomPushAnimationFromVCClass:[self class]];
    
    self.animateManager = ({
        TTImagePreviewAnimateManager *manager = [[TTImagePreviewAnimateManager alloc] init];
        if (!isEmptyString(self.exitManager.maskViewThemeColorKey)) {
            manager.maskViewThemeColorKey = self.exitManager.maskViewThemeColorKey;
        }
        manager.panDelegate = self;
        [manager registeredPanBackWithGestureView:self.view];
        manager;
    });

    //黑色背景
    self.blackMaskView = ({
        SSThemedView *blackMaskView = [[SSThemedView alloc] initWithFrame:self.view.frame];
        blackMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blackMaskView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        blackMaskView;
    });

    if (![AWEVideoPlayAccountBridge isLogin]) {
        [AWEVideoPlayAccountBridge fetchTTAccount];
//        [AWEVideoPlayAccountBridge checkin];
    }
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden = YES;
    self.view.clipsToBounds = YES;

    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    self.modeChangeActionType = ModeChangeActionTypeNone;

    // Views
    self.videoContainerViewController = ({
        AWEVideoContainerViewController *controller = [[AWEVideoContainerViewController alloc] init];
        controller.dataFetchManager = self.dataFetchManager;
        controller.commonTrackingParameter = self.commonTrackingParameter;
        controller.needCellularAlert = (self.pageParams[AWEVideoPageParamNonWiFiAlert] && [self.pageParams[AWEVideoPageParamNonWiFiAlert] isKindOfClass:[NSNumber class]]) ? [self.pageParams[AWEVideoPageParamNonWiFiAlert] boolValue] : YES;
        @weakify(self)
        controller.wantToClosePage = ^{
            @strongify(self);
            [self dismissByClickingCloseButton];
        };
        controller.loadMoreBlock = ^(BOOL preload) {
            @strongify(self);
            [self loadMoreAutomatically:preload];
        };
        controller.detailPromptManager = self.detailPromptManager;
        controller.configureOverlayViewController = ^(id<TSVControlOverlayViewController> _Nonnull viewController) {
            @strongify(self);
            viewController.viewModel = ({
                TSVControlOverlayViewModel *viewModel = [[TSVControlOverlayViewModel alloc] init];
                viewModel.commonTrackingParameter = self.commonTrackingParameter;
                viewModel.listEntrance = [self entrance];
                viewModel.closeButtonDidClick = ^{
                    @strongify(self);
                    [self dismissByClickingCloseButton];
                };
                viewModel.writeCommentButtonDidClick = ^{
                    @strongify(self);
                    [self playView:nil didClickInputWithModel:self.model];
                };
                viewModel.showProfilePopupBlock = ^{
                    @strongify(self);
//                    [self layoutProfileViewController];
//                    [self updateProfileViewModelIfNeeded];
//                    [self showProfileView];
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
//            viewController.delegate = self;
//            viewController.detailPromptManager = self.detailPromptManager;
        };
        controller;
    });

    @weakify(self);

    [self addChildViewController:self.videoContainerViewController];
    self.videoContainerViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.videoContainerViewController.view];
    [self.videoContainerViewController didMoveToParentViewController:self];

    self.commentView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kFloatingViewOriginY)];
//    self.commentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.commentView.layer.cornerRadius = 6.0;
    self.commentView.backgroundColorThemeKey = kColorBackground4;
    self.commentView.hidden = YES;
    [self.view addSubview:self.commentView];

    self.commentHeaderLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.commentView.bounds) - 15.0 - 44.0 - 15.0, 49.0)];
    self.commentHeaderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    self.commentHeaderLabel.font = [UIFont systemFontOfSize:17.0f];
    self.commentHeaderLabel.textColorThemeKey = kColorText1;
    [self.commentView addSubview:self.commentHeaderLabel];

    SSThemedView *sepline = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.commentHeaderLabel.frame), CGRectGetWidth(self.commentView.bounds), [TTDeviceHelper ssOnePixel])];
    sepline.backgroundColorThemeKey = kColorLine1;
    [self.commentView addSubview:sepline];

    SSThemedButton *commentViewCloseButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    commentViewCloseButton.right = self.commentView.width;
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

    SSThemedView *fakeInputBar = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), CGRectGetWidth(self.commentView.bounds), 44)];
    fakeInputBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    fakeInputBar.backgroundColorThemeKey = kColorBackground4;
    UIGestureRecognizer *inputTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFakeInputBarClick:)];
    fakeInputBar.borderColorThemeKey = kColorLine7;
    fakeInputBar.separatorAtTOP = YES;
    [fakeInputBar addGestureRecognizer:inputTapGesture];
    [self.commentView addSubview:fakeInputBar];
    self.fakeInputBar = fakeInputBar;
    
    SSThemedView *fakeTextBackgroundView = [[SSThemedView alloc] initWithFrame:CGRectMake(14, 6, CGRectGetWidth(fakeInputBar.bounds) - 28, CGRectGetHeight(fakeInputBar.bounds) - 12)];
    fakeTextBackgroundView.backgroundColorThemeKey = kFHColorPaleGrey;
    fakeTextBackgroundView.layer.cornerRadius = CGRectGetHeight(fakeTextBackgroundView.bounds) / 2;
    fakeTextBackgroundView.layer.masksToBounds = YES;
    fakeTextBackgroundView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    fakeTextBackgroundView.borderColorThemeKey = kFHColorPaleGrey;
    [fakeInputBar addSubview:fakeTextBackgroundView];

//    SSThemedImageView *inputIcon = [[SSThemedImageView alloc] initWithFrame:CGRectMake(9, 4, 24, 24)];
//    inputIcon.imageName = @"hts_vp_write_new";
//    [fakeTextBackgroundView addSubview:inputIcon];

    SSThemedLabel *inputLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(15, 6, CGRectGetWidth(fakeTextBackgroundView.frame) - 15 , 20)];
    inputLabel.text = @"写评论...";
    inputLabel.font = [UIFont systemFontOfSize:14.0];
    inputLabel.textColorThemeKey = kFHColorCoolGrey3;
    [fakeTextBackgroundView addSubview:inputLabel];

    [self.tableView registerClass:[AWEVideoCommentCell class] forCellReuseIdentifier:CommentCellIdentifier];

    [self.tableView addPullUpWithInitText:@"上拉可以加载更多数据" pullText:@"松开立即加载更多数据" loadingText:@"加载中..." noMoreText:@"没有更多啦～" timeText:nil lastTimeKey:nil ActioinHandler:^{
        @strongify(self);
        [self handleLoadMoreComments];
    }];

    self.emptyHintView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.commentHeaderLabel.frame), CGRectGetWidth(self.view.bounds), 90.0)];
    self.emptyHintView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.emptyHintView.hidden = YES;
    [self.commentView addSubview:self.emptyHintView];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hts_vp_sofa_icon"]];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    imageView.center = CGPointMake(CGRectGetWidth(self.emptyHintView.bounds) / 2.0, 33.0);
    [self.emptyHintView addSubview:imageView];

    UILabel *emptyHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 58, CGRectGetWidth(self.emptyHintView.bounds), 18)];
    emptyHintLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    emptyHintLabel.font = [UIFont boldSystemFontOfSize:15];
    emptyHintLabel.textColor = [UIColor colorWithHexString:@"999999"];
    emptyHintLabel.textAlignment = NSTextAlignmentCenter;
    emptyHintLabel.text = @"暂无评论，还不快抢沙发～";
    [self.emptyHintView addSubview:emptyHintLabel];

    self.inputBar = [[AWECommentInputBar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), 44) textViewDelegate:self sendBlock:^(AWECommentInputBar * _Nonnull inputBar, NSString * _Nullable text) {
        @strongify(self);
        [self handleSendComment:text fromInputBar:inputBar];
    }];
    self.inputBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.inputBar.hidden = YES;
    [self.view addSubview:self.inputBar];

    self.observerArray = [NSMutableArray array];
    [self.observerArray addObject:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        if ([self isShowingOnTop] && [self.inputBar isActive]) {
            CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
            keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
            NSTimeInterval keyboardAnimationDuration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            // 只移评论发布器 评论view不用上移
            self.inputBar.hidden = NO;
            [UIView animateWithDuration:keyboardAnimationDuration animations:^{
                [self.inputBar setMaxY:CGRectGetMinY(keyboardFrame)];
            }];

            [self showKeyboardMaskView:YES inputBarTargetY:(CGRectGetMinY(keyboardFrame) - CGRectGetHeight(self.inputBar.bounds))];

            // fix 第三方输入法
            [[UIApplication sharedApplication] setStatusBarHidden:[self shouldHideStatusBar] withAnimation:UIStatusBarAnimationNone];
        }
    }]];
    [self.observerArray addObject:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        if ([self isShowingOnTop]) {
            NSTimeInterval keyboardAnimationDuration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            CGFloat targetMinY = CGRectGetHeight(self.view.bounds);
            [UIView animateWithDuration:keyboardAnimationDuration animations:^{
                [self.inputBar setMinY:targetMinY];
            } completion:^(BOOL finished) {
                self.inputBar.hidden = YES;
            }];

            [self showKeyboardMaskView:NO inputBarTargetY:targetMinY];

            if (self.inputBar.textView.text.length == 0) {
                // 没有输入内容的时候情空
                [self.inputBar clearInputBar];
            }

            // fix 第三方输入法
            [[UIApplication sharedApplication] setStatusBarHidden:[self shouldHideStatusBar] withAnimation:UIStatusBarAnimationNone];
        }
    }]];
    [self.observerArray addObject:[[NSNotificationCenter defaultCenter] addObserverForName:@"RelationActionSuccessNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) { // 头条关注通知
        @strongify(self);
        NSString *userID = note.userInfo[@"kRelationActionSuccessNotificationUserIDKey"];
        if ([self.model.author.userID isEqualToString:userID]) {
            NSInteger actionType = [(NSNumber *)note.userInfo[@"kRelationActionSuccessNotificationActionTypeKey"] integerValue];
            if (actionType == 11) {//关注
                self.model.author.isFollowing = YES;
                [self.model save];
                [self updateViews];
            }else if (actionType == 12) {//取消关注
                self.model.author.isFollowing = NO;
                [self.model save];
                [self updateViews];
            }
        }
    }]];

    [self.tableView triggerPullUp];

    if ([self.dataFetchManager numberOfShortVideoItems]) {
        self.model = [self.dataFetchManager itemAtIndex:[self.dataFetchManager currentIndex]];
    } else {
        [self loadMoreAutomatically:YES];
    }
    
    if ([AWEVideoDetailScrollConfig direction] == AWEVideoDetailScrollDirectionVertical) {
        self.slideLeftGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSlideLeftGesture:)];
        self.slideLeftGesture.delegate = self;
        [self.view addGestureRecognizer:self.slideLeftGesture];
    } else {
        self.slideUpGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSlideUpGesture:)];
        self.slideUpGesture.delegate = self;
        [self.view addGestureRecognizer:self.slideUpGesture];
    }

    self.commentSlideDownGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentSlideDownGesture:)];
    self.commentSlideDownGesture.delegate = self;
    [self.commentView addGestureRecognizer:self.commentSlideDownGesture];

    self.allowCommentSlideDown = YES;
    self.allowProfileSlideDown = YES;

    self.commentScrollEnable = YES;
    self.profileScrollEnable = YES;

    RACChannelTo(self, tableView.scrollEnabled) = RACChannelTo(self, commentScrollEnable);
//    RAC(self, allowProfileSlideDown) = RACObserve(self, profileViewController.allowGesture);
//    RACChannelTo(self, profileViewController.scrollEnable) = RACChannelTo(self, profileScrollEnable);
//    RACChannelTo(self, profileBeginDragContentOffsetY) = RACChannelTo(self, profileViewController.beginDragContentOffsetY);
    [RACObserve(self, dataFetchManager.currentIndex) subscribeNext:^(id x) {
        @strongify(self);
        if ([self.dataFetchManager numberOfShortVideoItems] > 0){
            self.model = [self.dataFetchManager itemAtIndex:self.dataFetchManager.currentIndex];
            [self loadVideoDataIfNeeded];

            [TSVDownloadManager preloadAppStoreForGroupSourceIfNeeded:self.model.groupSource];
        }
    }];

    RAC(self, groupID) = RACObserve(self, model.groupID);

    self.viewModel = [[TSVDetailViewModel alloc] init];
    RAC(self, viewModel.dataFetchManager) = RACObserve(self, dataFetchManager);
    RAC(self, viewModel.commonTrackingParameter) = RACObserve(self, commonTrackingParameter);
    RAC(self, videoContainerViewController.viewModel) = RACObserve(self, viewModel);
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

    [self.inputBar resignActive];

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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        for (UIViewController *viewController in self.childViewControllers) {
            [viewController didMoveToParentViewController:nil];
        }
    }

    if (!parent) {
        //退出详情页时重置下替换的model和index
        [self.dataFetchManager replaceModel:nil atIndex:NSNotFound];
        
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
        [AWEVideoDetailTracker trackEvent:@"detail_back"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"back_type": backType
                                            }];
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
            self.inputBar.params[@"source"] = @"video_play";
            [self.inputBar becomeActive];
        }
    }
}

#pragma mark - getter & setter

- (void)setModel:(TTShortVideoModel *)model
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

//- (TSVProfileViewController *)profileViewController
//{
//    if (!_profileViewController) {
//        _profileViewController = [[TSVProfileViewController alloc] init];
//        _profileViewController.pushFromProfileVC = self.pushFromProfileVC;
//        if (self.pushFromProfileVC) {
//            ///对于从个人作品浮层进入的新页面，个人作品浮层的dataFetchManager和当前详情页是相同的
//            _profileViewController.viewModel = [[TSVProfileViewModel alloc] initWithModel:self.model commonTrackingParameter:self.commonTrackingParameter dataFetchManager:(TSVShortVideoProfileFetchManager *)self.dataFetchManager];
//        }
//        @weakify(self);
//        _profileViewController.didselectItemBlock = ^(TSVShortVideoProfileFetchManager *manager, TSVProfileReplaceMode replaceMode) {
//            @strongify(self);
//            if (replaceMode == TSVProfileReplaceModeReplaceList) {
//                self.dataFetchManager = manager;
//                [self.videoContainerViewController replaceDataFetchManager:manager];
//                [self dismissProfileViewWithCancelType:@"video_play"];
//            } else if (replaceMode == TSVProfileReplaceModeReplaceModel) {
//                [self.dataFetchManager replaceModel:[manager itemAtIndex:manager.currentIndex] atIndex:self.dataFetchManager.currentIndex];
//                self.model = [self.dataFetchManager itemAtIndex:self.dataFetchManager.currentIndex];
//                [self.videoContainerViewController refreshCurrentModel];
//                [self dismissProfileViewWithCancelType:@"video_play"];
//            }
//        };
//        _profileViewController.dismissBlock = ^(NSString *cancelType) {
//            @strongify(self);
//            [self dismissProfileViewWithCancelType:cancelType];
//        };
//    }
//    return _profileViewController;
//}

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
    self.commentHeaderLabel.text = commentCount ? [NSString stringWithFormat:@"%@条回复", commentCount] : @"暂无回复";
}

- (void)updateModel
{
    self.model.groupSource = self.model.groupSource ?: ToutiaoGroupSource;

    [self updateViews];

    if ([self.showComment integerValue] == ShowCommentModal) {
        [self showCommentsListWithStatus:TSVDetailCommentViewStatusPopByClick];
    } else if ([self.showComment integerValue] == ShowKeyboardOnly) {
        self.inputBar.params[@"source"] = @"video_play";
        [self.inputBar becomeActive];
    }
}

- (void)updateData
{
    if (!self.model && [self.dataFetchManager numberOfShortVideoItems]) {
        self.model = [self.dataFetchManager itemAtIndex:0];
    }
    [self.videoContainerViewController refresh];
}

- (void)loadMoreAutomatically:(BOOL)isAuto
{
    if (!BTDNetworkConnected()) {
        [HTSVideoPlayToast show:@"没有网络"];
        return;
    }
    if (self.dataFetchManager.isLoadingRequest) {
        return;
    }

    @weakify(self);
    [self.dataFetchManager requestDataAutomatically:isAuto finishBlock:^(NSUInteger increaseCount, NSError *error) {
        @strongify(self);

        if (error || increaseCount == 0) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:self.commonTrackingParameter[@"enter_from"] forKey:@"enter_from"];
            [params setValue:self.categoryName forKey:@"category_name"];
            TTShortVideoModel *videoDetail = nil;
            if ([self.dataFetchManager numberOfShortVideoItems]) {
                videoDetail = [self.dataFetchManager itemAtIndex:[self.dataFetchManager numberOfShortVideoItems] - 1];//取最后一个
                [params setValue:videoDetail.listEntrance forKey:@"list_entrance"];
                [params setValue:videoDetail.groupID forKey:@"from_group_id"];
                [params setValue:videoDetail.groupSource forKey:@"from_group_source"];
                if (videoDetail.categoryName) {
                    [params setValue:videoDetail.categoryName forKey:@"category_name"];
                }
                if (videoDetail.enterFrom) {
                    [params setValue:videoDetail.enterFrom forKey:@"enter_from"];
                }
            }else{
                [params setValue:self.groupID forKey:@"from_group_id"];
                [params setValue:self.groupSource forKey:@"from_group_source"];
            }
            [AWEVideoPlayTrackerBridge trackEvent : @"video_draw_fail"
                                           params : params];
            return;
        }

        [self updateData];
        
        [TSVPrefetchImageManager prefetchDetailImageWithDataFetchManager:self.dataFetchManager forward:YES];
        
        [TSVPrefetchVideoManager startPrefetchShortVideoInDetailWithDataFetchManager:self.dataFetchManager];

        if (!self.firstLoadFinished) {
            self.firstLoadFinished = YES;
            [self loadVideoDataIfNeeded];
        }
    }];
}

- (void)loadVideoDataIfNeeded
{
    NSInteger numberOfItemLeft = self.dataFetchManager.numberOfShortVideoItems - self.dataFetchManager.currentIndex;
    if (numberOfItemLeft <= 4 && [self.dataFetchManager hasMoreToLoad]) {
        [self loadMoreAutomatically:YES];
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
    [self reloadCommentHeaderWithCount:@(self.model.commentCount)];
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
                                               itemID:self.model.itemID
                                              groupID:self.model.groupID
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
                @strongify(self);
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
    if (!self.model.allowShare) {
        [HTSVideoPlayToast show:@"视频正在审核中，暂时不能分享。"];
        return YES;
    }
    return NO;
}

- (BOOL)alertIfCanNotComment
{
    if (!self.model.allowComment) {
        [HTSVideoPlayToast show:@"视频正在审核中，暂时不能评论。"];
        return YES;
    }
    return NO;
}

- (BOOL)alertIfNotValid
{
    if (self.model.isDelete) {
        [HTSVideoPlayToast show:@"视频已被删除"];
        return YES;
    }
    return !self.model;
}

- (void)showEmptyHint:(BOOL)show
{
    self.emptyHintView.hidden = !show;
    self.tableView.pullUpView.hidden = show;
}

- (void)showKeyboardMaskView:(BOOL)show inputBarTargetY:(CGFloat)inputBarTargetY
{
    if (show) {
        if (!self.keyboardMaskView) {
            self.keyboardMaskView = [[UIView alloc] init];
            self.keyboardMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self.keyboardMaskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissKeyboard)]];
            [self.keyboardMaskView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissKeyboard)]];
        }
        UIView *superView = self.view.window;
        CGPoint barOrigin = [self.inputBar.superview convertPoint:CGPointMake(0, inputBarTargetY) toView:superView];
        self.keyboardMaskView.frame = CGRectMake(0, 0, CGRectGetWidth(superView.bounds), barOrigin.y);
        [superView addSubview:self.keyboardMaskView];
    } else {
        [self.keyboardMaskView removeFromSuperview];
    }
    [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:show];
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

//- (void)showProfileViewMaskView:(BOOL)show
//{
//    if (show) {
//        if (!self.profileViewMaskView) {
//            self.profileViewMaskView = [[UIView alloc] init];
//            self.profileViewMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//            [self.profileViewMaskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissProfileViewWithShadow)]];
//            [self.profileViewMaskView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dismissProfileViewWithShadow)]];
//        }
//        self.profileViewMaskView.frame = self.view.bounds;
//        [self.view insertSubview:self.profileViewMaskView belowSubview:self.profileViewController.view];
//    } else {
//        [self.profileViewMaskView removeFromSuperview];
//    }
//}

//- (void)dismissProfileViewWithShadow
//{
//    [self dismissProfileViewWithCancelType:@"shadow"];
//}

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

    [UIView animateWithDuration:0.2 customTimingFunction:CustomTimingFunctionCubicOut animation:^{
        self.commentView.frame = CGRectMake(0, kFloatingViewOriginY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kFloatingViewOriginY);
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
    [AWEVideoDetailTracker trackEvent:@"comment_cancel"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:extra];

    self.commentViewStatus = TSVDetailCommentViewStatusNone;

    self.isCommentViewAnimating = YES;

    @weakify(self);
    [UIView animateWithDuration:0.2 customTimingFunction:CustomTimingFunctionCubicOut animation:^{
        self.commentView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.commentView.bounds));
    } completion:^(BOOL finished) {
        @strongify(self);
        self.commentView.hidden = YES;
        self.inputBar.hidden = YES;
        self.isCommentViewAnimating = NO;
    }];

    [self showCommentViewMaskView:NO];
    [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:NO];
}

//- (void)showProfileView
//{
//    self.profileViewController.view.hidden = NO;
//    [UIView animateWithDuration:0.2 customTimingFunction:CustomTimingFunctionCubicOut animation:^{
//        self.profileViewController.view.frame = CGRectMake(0, kFloatingViewOriginY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kFloatingViewOriginY);
//    } completion:^(BOOL finished) {
//    }];
//    [self showProfileViewMaskView:YES];
//    [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:YES];
//}

//- (void)dismissProfileViewWithCancelType:(NSString *)cancelType
//{
//    if (self.isProfileViewAnimating) {
//        return;
//    }
//
//    if (!isEmptyString(cancelType)) {
//        [AWEVideoDetailTracker trackEvent:@"profile_float_cancel"
//                                    model:self.model
//                          commonParameter:self.commonTrackingParameter
//                           extraParameter:@{
//                                            @"position": @"draw_bottom",
//                                            @"cancel_type": cancelType,
//                                            }];
//    }
//    self.isProfileViewAnimating = YES;
//    [UIView animateWithDuration:0.2 customTimingFunction:CustomTimingFunctionCubicOut animation:^{
//        self.profileViewController.view.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.profileViewController.view.bounds));
//    } completion:^(BOOL finished) {
//        self.profileViewController.view.hidden = YES;
//        self.isProfileViewAnimating = NO;
//    }];
//    [self showProfileViewMaskView:NO];
//    [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:NO];
//}

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
    NSString *itemID = self.model.itemID;
    NSString *groupID = self.model.groupID ?: self.groupID;

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
            [self.model save];

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
        model.groupID = self.model.groupID;
        model.videoID = self.model.itemID;
        [[TTReportManager shareInstance] startReportVideoWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeAWEVideo reportFrom:TTReportFromByEnterFromAndCategory(self.model.enterFrom, self.model.categoryName) contentModel:model extraDic:nil animated:YES];

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

        [AWEVideoDetailTracker trackEvent:@"rt_report"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"reason" : reasonStr ?: @"",
                                            @"position": @"detail_top_bar",
                                            }];
    }];
}

- (void)handleDislikeVideo
{
    NSString *itemID = self.model.itemID;
    NSString *groupID = self.model.groupID ?: self.groupID;

    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = [[TTGroupModel alloc] initWithGroupID:groupID itemID:itemID impressionID:nil aggrType:1];
    context.actionExtra = self.model.actionExtra;
    context.dislikeSource = @"1";//1表示详情页
    
    if ([self.model isAd]) {
        TTAdShortVideoModel *rawAd = self.model.rawAd;
        context.adID = rawAd.ad_id;
        NSMutableDictionary *adExtra = @{}.mutableCopy;
        adExtra[@"clicked"] = @(1);
        adExtra[@"log_extra"] = rawAd.log_extra2;
        context.adExtra = adExtra;
        if (isEmptyString(context.groupModel.groupID)) {
            context.groupModel = [[TTGroupModel alloc] initWithGroupID:rawAd.ad_id itemID:rawAd.ad_id impressionID:nil aggrType:1];
        }
    }
    
    @weakify(self);
    self.actionManager.finishBlock = ^(id userInfo, NSError *error) {
        @strongify(self);
        if (!error) {
            //通知feed删除cell
            
            NSMutableDictionary *userInfo = @{}.mutableCopy;
            userInfo[@"group_id"] = self.model.groupID;
            if ([self.model isAd]) {
                TTAdShortVideoModel *rawAd = self.model.rawAd;
                [rawAd trackDrawWithTag:@"embeded_ad" label:@"final_dislike" extra:nil];
                userInfo[@"ad_id"] = rawAd.ad_id;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSVShortVideoDislikeNotification"
                                                                object:self
                                                              userInfo:userInfo];
            if (!self.dislikeGroupIDArray) {
                self.dislikeGroupIDArray = [NSMutableArray array];
            }
            if (!isEmptyString(self.model.groupID)){
                [self.dislikeGroupIDArray addObject:self.model.groupID];
            }
            [HTSVideoPlayToast show:@"将减少推荐类似内容"];
            self.isDisliked = YES;
        } else {
            [HTSVideoPlayToast show:@"操作失败"];
        }
    };
    [self.actionManager setContext:context];
    [self.actionManager startItemActionByType:DetailActionTypeNewVersionDislike];
}

- (void)handleDeleteVideo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.model.author.userID forKey:@"user_id"];
    [params setValue:self.model.groupID forKey:@"item_id"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting deleteUGCMovieURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSInteger errorCode = 0;
        if ([jsonObj isKindOfClass:[NSDictionary class]]) {
            errorCode = [(NSDictionary *)jsonObj tt_integerValueForKey:@"error_code"];
        }
        if (error || errorCode != 0) {
            NSString *tip = NSLocalizedString(@"操作失败", nil);
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        } else {
            NSString *tip = NSLocalizedString(@"操作成功", nil);
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            
            /// 给混排列表发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kTSVShortVideoDeleteNotification object:nil userInfo:@{kTSVShortVideoDeleteUserInfoKeyGroupID : self.model.groupID? : @""}];
            /// 标记下需要删除
            self.model.shouldDelete = YES;
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

- (void)handleSendComment:(NSString *)comment fromInputBar:(AWECommentInputBar *)inputBar
{
    [AWEVideoDetailTracker trackEvent:@"comment_write_confirm"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:[self writeCommentExtraPositionDict]];
    if (!BTDNetworkConnected()) {
        [HTSVideoPlayToast show:@"当前无网络，请稍后重试"];
        return;
    }

    // 判断输入是否全是空格
    comment = [comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (comment.length == 0) {
        [HTSVideoPlayToast show:@"请添加回复内容后再尝试"];
        return;
    }

    if (comment.length > 2000) {
        [HTSVideoPlayToast show:@"评论字数不能超过2000字"];
        return;
    }

    NSString *groupID = self.model.groupID ?: self.groupID;
    NSString *itemID = self.model.itemID;

    [self.inputBar resignActive];

    AWECommentModel *replyToModel = inputBar.targetCommentModel;

    @weakify(self);
    AWEAwemeAddCommentResponseBlock callback = ^(AWECommentModel *model, NSError *error) {
        @strongify(self);
        if (!error) {
            if (model.replyToComment == nil) {
                [AWEVideoDetailTracker trackEvent:@"rt_post_reply"
                                            model:self.model
                                  commonParameter:self.commonTrackingParameter
                                   extraParameter:[self writeCommentExtraPositionDict]];
            }

            [self.inputBar clearInputBar];

            self.model.commentCount = [self.commentManager totalCommentCount];
            NSMutableDictionary *userInfo = @{}.mutableCopy;
            userInfo[@"group_id"] = self.model.groupID;
            [[NSNotificationCenter defaultCenter] postNotificationName:kPostMessageFinishedNotification
                                                                object:nil
                                                              userInfo:userInfo];
            [self.model save];
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self showEmptyHint:NO];
                [self.tableView reloadData];
                [self updateViews];

                if (self.commentView.hidden) {
                    [self showCommentsListWithStatus:TSVDetailCommentViewStatusPopByClick];
                }
                // 滑动定位到评论位置
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.tableView numberOfSections] - 1] atScrollPosition:UITableViewScrollPositionTop animated:YES];

                [HTSVideoPlayToast show:replyToModel ? @"发送成功" : @"发布成功"];
            });
        } else {
            NSString *prompts = error.userInfo[@"prompts"] ?: @"操作失败，请重试";
            [HTSVideoPlayToast show:prompts];
        }
    };

    BOOL notLogin = [self alertIfNotLoginWithCompletion:^(BOOL success) {
        @strongify(self);
        //登录成功就发生出，否则重新弹起登录框
        if (success) {
            if (replyToModel) {
                if([AWEVideoPlayAccountBridge isCurrentLoginUser:[replyToModel.userId stringValue]]){
                    return;
                }
                [self.commentManager commentAwemeItemWithID:itemID groupID:groupID content:comment replyCommentID:replyToModel.id completion:callback];
            } else {
                [self.commentManager commentAwemeItemWithID:itemID groupID:groupID content:comment completion:callback];
            }
        } else {
            [self.inputBar becomeActive];
        }
    }];
    if (notLogin) {
        return;
    }

    if (replyToModel) {
        [self.commentManager commentAwemeItemWithID:itemID groupID:groupID content:comment replyCommentID:replyToModel.id completion:callback];
    } else {
        [self.commentManager commentAwemeItemWithID:itemID groupID:groupID content:comment completion:callback];
    }

}

- (void)handleLoadMoreComments
{
    [self showEmptyHint:NO];

    if ([self.commentManager canLoadMore]) {
        TTShortVideoModel *model = self.model;

        @weakify(self, model);
        [self.commentManager requestCommentListWithID:self.model.itemID groupID:self.model.groupID count:@(CommentFetchCount) offset:[NSNumber numberWithInteger:self.offset] completion:^(AWECommentResponseModel *response, NSError *error) {
            if (error || !response) {
                return;
            }

            @strongify(self, model);
            if(response.totalNumber){
                model.commentCount = [response.totalNumber integerValue];
                [model save];
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
    [self.inputBar resignActive];
}

- (void)handleFakeInputBarClick:(id)sender
{
    [AWEVideoDetailTracker trackEvent:@"comment_write_button"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:[self writeCommentExtraPositionDict]];

    if ([self alertIfNotValid]) {
        return;
    }
    [self.inputBar becomeActive];
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

    [cell configCellWithCommentModel:commentModel videoId:self.model.itemID authorId:self.model.author.userID];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AWECommentModel *commentModel = [self.commentManager commentForIndexPath:indexPath];
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:[self commentExtraPositionDict]];
    [extra setValue:[commentModel.id stringValue] ?: @"" forKey:@"comment_id"];
    [AWEVideoDetailTracker trackEvent:@"rt_post_reply"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:extra];

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
        [self.inputBar clearInputBar];
        return;
    }

    if (commentModel.userId && ![self.inputBar.targetCommentModel.userId isEqualToNumber: commentModel.userId]) {
        // 草稿是回复视频或回复A，现在要回复B
        [self.inputBar clearInputBar];
    }

    self.inputBar.targetCommentModel = commentModel;
    self.inputBar.textView.placeholder = [NSString stringWithFormat:@"@%@：", commentModel.userName];

    [self.inputBar becomeActive];
}


#pragma mark - HTSVideoDetailTopViewDelegate

- (void)topView:(UIViewController *)viewController didClickCloseWithModel:(TTShortVideoModel *)model
{
    [self dismissByClickingCloseButton];
}

- (void)dismissByClickingCloseButton
{
    self.closeStyle = AWEVideoDetailCloseStyleCloseButton;
    self.blackMaskView.hidden = YES;
    [self.animateManager dismissWithoutGesture];
}

- (void)topView:(UIViewController *)viewController didClickReportWithModel:(TTShortVideoModel *)model
{
    if (!self.model) {
        return;
    }

    @weakify(self);
    [AWEVideoDetailTracker trackEvent:@"click_more"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{
                                        @"position": @"detail_top_bar",
                                        }];

    [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:YES];

    //小视频暂时不出分享广告
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance share_showInAdPage:@"1" groupId:self.model.groupID];

    NSString *imageURL = [self.model.video.originCover.urlList firstObject];
    [AWEVideoPlayShareBridge loadImageWithUrl:imageURL completion:^(UIImage * _Nonnull image) {
        @strongify(self);
        AWEVideoShareType shareType = AWEVideoShareTypeMore;
        if ([self entrance] == TSVShortVideoListEntranceStory) {
            shareType = AWEVideoShareTypeMoreForStory;
        }
        if ([self.model isAd]) {
            shareType = AWEVideoShareTypeAd;
        }
        AWEVideoShareModel *shareModel = [[AWEVideoShareModel alloc] initWithModel:self.model image:image shareType:shareType];

        [self.shareManager displayActivitySheetWithContent:[shareModel shareContentItems]];
    }];
}

#pragma mark -

- (void)playView:(AWEVideoPlayView *)view didClickInputWithModel:(TTShortVideoModel *)model
{
   //point:在详情页点击写评论
    [AWEVideoDetailTracker trackEvent:@"comment_write_button"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{
                                        @"position": @"detail_bottom_bar",
                                        }];

    if ([self alertIfNotValid]) {
        return;
    }

    if ([self alertIfCanNotComment]) {
        return;
    }

    if (self.inputBar.targetCommentModel) {
        // 草稿是回复A，现在要回复视频
        [self.inputBar clearInputBar];
    }

    self.inputBar.params[@"source"] = @"video_play";
    [self.inputBar becomeActive];
}

- (void)playView:(AWEVideoPlayView *)view didClickCommentWithModel:(TTShortVideoModel *)model
{
    [AWEVideoDetailTracker trackEvent:@"comment_list_show"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{@"position": @"detail"}];

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
        [HTSVideoPlayToast show:@"不能删除别人的评论！"];
        return;
    }

    @weakify(self);
    [self.commentManager deleteCommentItemWithId:commentModel.id completion:^(id response, NSError *error) {
        if (!error && [response[@"message"] isEqualToString:@"success"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.tableView reloadData];
                [HTSVideoPlayToast show:@"评论删除成功！"];
                if ([self.commentManager isEmpty]) {
                    [self showEmptyHint:YES];
                }
                self.model.commentCount = [self.commentManager totalCommentCount];
                [self.model save];
                [self updateViews];
            });
        }else{
            [HTSVideoPlayToast show:@"操作失败，请重试"];
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
        [self.commentManager reportCommentWithType:parameters[@"report"] userInputText:parameters[@"criticism"] userID:[commentModel.userId stringValue] commentID:commentModel.id momentID:nil groupID:self.model.groupID postID:self.model.itemID completion:^(id response, NSError *error) {
            if(error || response[@"extra"]){
                [HTSVideoPlayToast show:@"举报失败"];
            }else{
                [HTSVideoPlayToast show:@"举报成功"];
            }
        }];
    }];
}

- (void)commentCell:(AWEVideoCommentCell *)cell didClickLikeWithModel:(AWECommentModel *)commentModel
{
    NSString *eventName = commentModel.userDigg ? @"rt_unlike" : @"rt_like";
    [AWEVideoDetailTracker trackEvent:eventName
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{@"position": @"reply",
                                        @"comment_id": [commentModel.id stringValue]}];

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
    [AWEVideoDetailTracker trackEvent:@"comment_click_avatar"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:extra];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.categoryName forKey:@"category_name"];
    [params setValue:@"detail_short_video_comment" forKey:@"from_page"];
    [params setValue:self.model.groupID forKey:@"group_id"];
    [AWEVideoPlayTransitionBridge openProfileViewWithUserId:[commentModel.userId stringValue] params:params];
}

- (void)commentCell:(AWEVideoCommentCell *)cell didClickUserNameWithModel:(AWECommentModel *)commentModel
{
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:[self commentExtraPositionDict]];
    [extra setValue:[commentModel.userId stringValue] ?: @"" forKey:@"user_id"];
    [AWEVideoDetailTracker trackEvent:@"comment_click_nick_name"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:extra];

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
}

#pragma mark - handle slideGesture
- (void)handleSlideLeftGesture:(UIPanGestureRecognizer *)gesture
{
    CGFloat progress = fabs([gesture translationInView:self.view].x / self.view.bounds.size.width);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [TSVTransitionAnimationManager sharedManager].enterProfilePercentDrivenTransition = [UIPercentDrivenInteractiveTransition new];
        NSMutableDictionary *extraUserInfo = [NSMutableDictionary dictionary];
        [extraUserInfo setValue:self.model.author.name forKey:@"username"];
        [extraUserInfo setValue:self.model.author.avatarURL forKey:@"avatar"];
        [extraUserInfo setValue:self.model.author.userAuthInfo forKey:@"userAuthInfo"];
        [extraUserInfo setValue:@(self.model.author.isFollowing) forKey:@"isFollowing"];
        [extraUserInfo setValue:@(self.model.author.isFollowed) forKey:@"isFollowed"];
        [extraUserInfo setValue:self.model.author.desc forKey:@"desc"];
        [extraUserInfo setValue:@(self.model.author.followingsCount) forKey:@"followingCount"];
        [extraUserInfo setValue:@(self.model.author.followersCount) forKey:@"followedCount"];
        [AWEVideoPlayTransitionBridge openProfileViewWithUserId:self.model.author.userID params:nil userInfo:@{@"extra_user_info": extraUserInfo}];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [[TSVTransitionAnimationManager sharedManager].enterProfilePercentDrivenTransition updateInteractiveTransition:progress];
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [gesture velocityInView:self.view];
        if (progress > 0.3 || fabs(velocity.x) > 500) {
            //用户左滑进过个人主页，标记下，之后不在出引导
            [TSVSlideLeftEnterProfilePromptViewController setSlideLeftPromotionShown];
            [AWEVideoDetailTracker trackEvent:@"draw_profile"
                                        model:self.model
                              commonParameter:self.commonTrackingParameter
                               extraParameter:@{@"position": @"draw_bottom"}];
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
//                [AWEVideoDetailTracker trackEvent:@"draw_profile"
//                                            model:self.model
//                                  commonParameter:self.commonTrackingParameter
//                                   extraParameter:@{@"position": @"draw_bottom"}];
//                //滑出过一次不再出引导
//                [TSVSlideUpPromptViewController setSlideUpPromotionShown];
//                [self showProfileView];
//            }
            if (self.slideUpViewType == TSVDetailSlideUpViewTypeComment) {
                [AWEVideoDetailTracker trackEvent:@"enter_comment"
                                            model:self.model
                                  commonParameter:self.commonTrackingParameter
                                   extraParameter:@{@"position": @"draw_bottom"}];

                [AWEVideoDetailTracker trackEvent:@"comment_list_show"
                                            model:self.model
                                  commonParameter:self.commonTrackingParameter
                                   extraParameter:@{@"position": @"draw_bottom"}];

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
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return [self.videoContainerViewController canPullToClose];
    }
    return NO;
}

//scale仅仅在 TTPreviewAnimateStateChange下 有正确的值，其他都为0
- (void)ttPreviewPanBackStateChange:(TTPreviewAnimateState)currentState scale:(float)scale
{
    switch (currentState) {
        case TTPreviewAnimateStateWillBegin:
        {
            TTShortVideoModel *model = [self.originalDataFetchManager itemAtIndex:self.originalDataFetchManager.currentIndex replaced:NO];

            NSURL *URL = nil;
            URL = [NSURL URLWithString:[model.animatedImageModel.urlWithHeader firstObject][@"url"] ?:@""];
            NSString *cacheKey = [[YYWebImageManager sharedManager] cacheKeyForURL:URL];
            if ([[[YYWebImageManager sharedManager] cache] containsImageForKey:cacheKey]) {
                self.fakeBackImage = [[[YYWebImageManager sharedManager] cache]  getImageForKey:cacheKey];
            } else if (model.detailCoverImageModel.urlWithHeader) {
                NSURL *stillImageURL = [NSURL URLWithString:[model.detailCoverImageModel.urlWithHeader firstObject][@"url"] ?:@""];
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
        [AWEVideoDetailTracker trackEvent:self.model.userRepin? @"rt_unfavourite" : @"rt_favourite"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"position": @"detail",
                                            }];
        [self handleFavoriteVideoWithContentItem:(TTFavouriteContentItem *)contentItem];
    } else if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeDislike]) {
        [AWEVideoDetailTracker trackEvent:@"rt_dislike"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"position": @"detail_top_bar",
                                            }];
        [self handleDislikeVideo];
    } else if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeReport]) {
        [self handleReportVideo];
    } else if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeDelete]) {
        [AWEVideoDetailTracker trackEvent:@"profile_delete"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"position": @"detail_top_bar",
                                            }];
        [self handleDeleteVideo];
    } else if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
        [AWEVideoDetailTracker trackEvent:@"rt_share_to_platform"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"share_platform":@"weitoutiao",
                                            @"position": @"detail",
                                            @"event_type": @"house_app2c_v2"
                                            }];
        [TSVVideoDetailShareHelper handleForwardUGCVideoWithModel:self.model];
//    } else if ([contentItem.contentItemType isEqualToString:TTActivityContentItemTypeSaveVideo]) {
//        [AWEVideoDetailTracker trackEvent:@"video_cache"
//                                    model:self.model
//                          commonParameter:self.commonTrackingParameter
//                           extraParameter:nil];
//        [TSVVideoDetailShareHelper handleSaveVideoWithModel:self.model];
//    }
    } else if (!isEmptyString(contentItem.contentItemType)){
        NSString *type = [AWEVideoShareModel labelForContentItemType:contentItem.contentItemType];
        NSAssert(type, @"Type should not be empty");
        [AWEVideoDetailTracker trackEvent:@"rt_share_to_platform"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"share_platform": type?:@"",
                                            @"position": @"detail",
                                            @"event_type": @"house_app2c_v2"
                                            }];
    } else {
        [AWEVideoDetailTracker trackEvent:@"click_more_cancel"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"position": @"detail_top_bar",
                                            }];
    }
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    NSString *eventName = error ? @"share_fail" : @"share_done";
    NSString *sharePlatform = [AWEVideoShareModel labelForContentItemType:activity.contentItemType] ?: @"";
    id<TTActivityContentItemProtocol> contentItem = activity.contentItem;
    NSArray *shareContentItemTypes = @[
                                       TTActivityContentItemTypeWechat,
                                       TTActivityContentItemTypeWechatTimeLine,
                                       TTActivityContentItemTypeForwardWeitoutiao,
                                       TTActivityContentItemTypeQQFriend,
                                       TTActivityContentItemTypeQQZone
//                                       TTActivityContentItemTypeSystem,
                                       ];
    if ([shareContentItemTypes containsObject:contentItem.contentItemType]) {
        [AWEVideoDetailTracker trackEvent:eventName
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"share_platform": sharePlatform,
                                            @"position": @"detail_top_bar",
                                            @"event_type": @"house_app2c_v2"
                                            }];
    }
    [TSVVideoShareManager synchronizeUserDefaultsWithAvtivityType:activity.contentItemType];
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
    return ![TTDeviceHelper isIPhoneXDevice];
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
    
    if ([self.dataFetchManager respondsToSelector:@selector(entrance)]) {
        ret = self.dataFetchManager.entrance;
    }
    
    return ret;
}

@end

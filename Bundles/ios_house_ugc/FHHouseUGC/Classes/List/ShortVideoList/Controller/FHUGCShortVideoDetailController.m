//
//  FHUGCShortVideoDetailController.m
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
#import "AWECommentModel.h"
// Bridge
#import "AWEVideoPlayAccountBridge.h"
#import "AWEVideoPlayShareBridge.h"
#import "AWEVideoPlayTransitionBridge.h"
// Manager
#import "AWEVideoCommentDataManager.h"
// Util
#import "UIScrollView+Refresh.h"
#import "UIViewController+NavigationBarStyle.h"

#import "TTModuleBridge.h"
#import "AWEVideoConstants.h"
#import "AWEVideoContainerViewController.h"
#import "AWEVideoDetailControlOverlayViewController.h"
#import <TTReporter/TTReportManager.h>
#import "TSVVideoDetailPromptManager.h"
#import "AWEVideoShareModel.h"
#import "TTShareManager.h"
#import "TTServiceCenter.h"
#import "TTAdManagerProtocol.h"
#import "TTShortVideoModel+TTAdFactory.h"
#import "TTIndicatorView.h"
#import <TTThemed/UIImage+TTThemeExtension.h>
#import "DetailActionRequestManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTUIWidget/UIView+CustomTimingFunction.h>
#import "TSVSlideUpPromptViewController.h"
#import "TSVStartupTabManager.h"
#import "TSVUIResponderHelper.h"
#import "CommonURLSetting.h"
#import "TSVVideoShareManager.h"
#import "TTAudioSessionManager.h"
#import "FHPostDetailCommentWriteView.h"
#import "SSCommentInputHeader.h"
#import "FHShortVideoDetailFetchManager.h"
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
#import <FHShareManager.h>
#define kPostMessageFinishedNotification    @"kPostMessageFinishedNotification"

@import AVFoundation;


///评论页状态 未弹出/点击弹出／上滑弹出
typedef NS_ENUM(NSInteger, TSVDetailCommentViewStatus) {
    TSVDetailCommentViewStatusNone,
    TSVDetailCommentViewStatusPopByClick,
    TSVDetailCommentViewStatusPopBySlideUp,
};

@interface FHUGCShortVideoDetailController () <UITableViewDataSource, UITableViewDelegate, AWEVideoCommentCellOperateDelegate,UIGestureRecognizerDelegate, TTRouteInitializeProtocol, TTShareManagerDelegate,TTCommentWriteManagerDelegate>

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
@property (nonatomic, copy) NSDictionary *pageParams;
@property (nonnull, copy) NSString *groupID;
@property (nonnull, copy) NSString *topID;
@property (nonatomic, copy) NSString *groupSource;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, strong) NSNumber *showComment;//0不弹，1弹起评论浮层，2弹输入框
@property (nonatomic, copy) NSDictionary *initialLogPb;
//外面传的埋点信息 by xsm
@property (nonatomic, strong) NSDictionary *extraDic;
// 状态
@property (nonatomic, assign) BOOL firstLoadFinished;
@property (nonatomic, assign) BOOL hasMore;      // 还有没有评论数据可以拉取
@property (nonatomic, assign) NSInteger offset;  // 请求新数据的时候，offet参数
// 详情页数据
@property (nonatomic, strong) FHFeedUGCCellModel *model;
@property (nonatomic, strong) NSArray<NSDictionary *> *userReportOptions;
@property (nonatomic, strong) NSArray<NSDictionary *> *videoReportOptions;
// observers
@property (nonatomic, strong) NSMutableArray *observerArray;
@property (nonatomic, strong) UIView *popToView;
@property (nonatomic, strong) UIView *bottomTabbarView;

@property (nonatomic, strong) TSVVideoDetailPromptManager *detailPromptManager;

@property (nonatomic, strong) NSMutableArray *dislikeGroupIDArray;
@property (nonatomic, strong) DetailActionRequestManager *actionManager;
///浮层（评论浮层／作品集浮层）上滑手势
@property (nonatomic, strong) UIPanGestureRecognizer *slideUpGesture;
@property (nonatomic, assign) TSVDetailSlideUpViewType slideUpViewType;
///下滑手势
@property (nonatomic, strong) UIPanGestureRecognizer *commentSlideDownGesture;
///浮层
@property (nonatomic, assign) BOOL allowCommentSlideDown;

@property (nonatomic, assign) BOOL commentScrollEnable;

@property (nonatomic, strong) UIView *commentViewMaskView;
@property (nonatomic, strong) UIView *profileViewMaskView;

@property (nonatomic, assign) BOOL isCommentViewAnimating;

@property (nonatomic, assign) CGFloat commentBeginDragContentOffsetY;
@property (nonatomic, assign) CGFloat profileBeginDragContentOffsetY;

@property (nonatomic, assign) TSVDetailCommentViewStatus commentViewStatus;

@property (nonatomic, assign) UIStatusBarStyle originalStatusBarStyle;

@property (nonatomic, strong) TTShareManager *shareManager;


@property (nonatomic, copy) NSString *originalGroupID;  //schema中的初始gid


@property (nonatomic, assign) BOOL loadingShareImage;//加载分享图片时 点击分享按钮

@property (nonatomic, assign) BOOL canLoadMore;//是否可以加载更多
 
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
        _canLoadMore = [paramObj.host isEqualToString:@"small_video_detail"];
        _groupID = [params[AWEVideoGroupId] copy] ?: @"";
        _topID =  [params[AWEVideocTopId] copy] ?: @"";
        _originalGroupID = [params[AWEVideoGroupId] copy] ?: @"";
        _groupSource = [params[VideoGroupSource] copy] ?: @"";
        _showComment = [params[AWEVideoShowComment] copy];
        
        if (!_showComment) {
            _showComment = [extraParams[AWEVideoShowComment] copy];
        }
        _categoryName = [params btd_stringValueForKey:AWEVideoCategoryName];
        
        [self initReportOptions];
        [self initProperty];
        self.dataFetchManager = [[FHShortVideoDetailFetchManager alloc]init];
        self.dataFetchManager.currentIndex= 0;
        self.dataFetchManager.shouldShowNoMoreVideoToast = YES;
        self.dataFetchManager.categoryId = @"f_house_smallvideo_flow";
        if(paramObj.allParams[@"tracer"] && [paramObj.allParams[@"tracer"] isKindOfClass:[NSDictionary class]]){
            self.extraDic = paramObj.allParams[@"tracer"];
            self.dataFetchManager.tracerDic = self.extraDic;
          }
        self.dataFetchManager.groupID = self.groupID;
        self.dataFetchManager.topID = self.topID;
        self.dataFetchManager.canLoadMore = self.canLoadMore;
        FHFeedUGCCellModel *currentShortVideoModel = extraParams[@"current_video"];
        TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.groupID itemID:self.groupID impressionID:nil aggrType:1];
        self.groupModel = groupModel;
        if (!currentShortVideoModel) {
            [self startLoading];
        }
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
    }
    return self;
}
- (void)setGroupID:(NSString *)groupID {
    _groupID = groupID;
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
    _observerArray = [NSMutableArray array];
    _commentManager = [[AWEVideoCommentDataManager alloc] init];
    _isCommentViewAnimating = NO;
    _slideUpViewType = [TSVSlideUpPromptViewController slideUpViewType];
    self.ttHideNavigationBar = YES;
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
                viewModel.listEntrance = [self entrance];
                viewModel.writeCommentButtonDidClick = ^{
                            @strongify(self);
                           NSInteger rank = [self.model.tracerDic btd_integerValueForKey:@"rank" default:0];
                    [FHShortVideoTracerUtil clickCommentWithModel:self.model eventIndex:rank eventPosition:@"detail_comment"];
                            [self playView:nil didClickInputWithModel:self.model];
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
    self.commentSlideDownGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentSlideDownGesture:)];
    self.commentSlideDownGesture.delegate = self;
    [self.commentView addGestureRecognizer:self.commentSlideDownGesture];

    self.allowCommentSlideDown = YES;
    self.commentScrollEnable = YES;

    RACChannelTo(self, tableView.scrollEnabled) = RACChannelTo(self, commentScrollEnable);
    [RACObserve(self, dataFetchManager.currentIndex) subscribeNext:^(id x) {
        @strongify(self);
        if ([self.dataFetchManager numberOfShortVideoItems] > 0){
            self.model = [self.dataFetchManager itemAtIndex:self.dataFetchManager.currentIndex];
            [self loadVideoDataIfNeeded];
        }
    }];

    RAC(self, groupID) = RACObserve(self, model.groupId);

    self.viewModel = [[TSVDetailViewModel alloc] init];
    RAC(self, viewModel.dataFetchManager) = RACObserve(self, dataFetchManager);
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kExploreMovieViewPlaybackFinishNotification" object:self];
    [self.detailPromptManager hidePrompt];
    [TSVStartupTabManager sharedManager].detailViewControllerVisibility = NO;
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TSVVideoDetailVisibilityDidChangeNotification object:nil userInfo:@{TSVVideoDetailVisibilityDidChangeNotificationVisibilityKey:@NO}];
    }
    
    [self.commentWriteView dismissAnimated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *visibleVC = [TSVUIResponderHelper topmostViewController];
        if (![visibleVC isKindOfClass:[self class]]) {
            [[TTAudioSessionManager sharedInstance] setActive:NO];
        }
    });
    [self dismissCommentListWithCancelType:@"push"];
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
    self.commentHeaderLabel.text  = @"评论";
}

- (void)updateModel
{
    self.model.groupSource = self.model.groupSource ?: ToutiaoGroupSource;

    [self updateViews];

    if ([self.showComment integerValue] == ShowCommentModal) {
        [self showCommentsListWithStatus:TSVDetailCommentViewStatusPopByClick];
    } else if ([self.showComment integerValue] == ShowKeyboardOnly) {
        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO replyToCommentID:nil podition:@"detail_comment"];
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
            return;
        }
        [self updateData];
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


- (BOOL)alertIfNotLogin
{
    if (![AWEVideoPlayAccountBridge isLogin]) {
        [AWEVideoPlayAccountBridge showLoginView];
        return YES;
    }
    return NO;
}


- (BOOL)alertIfNotValid
{
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
            [FHShortVideoTracerUtil clickCommentWithModel:self.model eventIndex:0 eventPosition:@"feed_comment"];
            [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO replyToCommentID:nil podition:@"feed_comment"];
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
            
            [FHShortVideoTracerUtil clickFavoriteBtn:self.model favorite:self.model.userRepin];
            
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
            self.model.userRepin = NO;
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


- (void)handleFakeInputBarClick:(id)sender
{
    NSInteger rank = [self.model.tracerDic btd_integerValueForKey:@"rank" default:0];
    [FHShortVideoTracerUtil clickCommentWithModel:self.model eventIndex:rank eventPosition:@"feed_comment"];

    if ([self alertIfNotValid]) {
        return;
    }
    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO replyToCommentID:nil podition:@"feed_comment"];
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
    
    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO replyToCommentID:commentModel.id.stringValue podition:@"reply"];
    [FHShortVideoTracerUtil clickCommentWithModel:self.model eventIndex:indexPath.row eventPosition:@"reply"];
    [self.commentWriteView setTextViewPlaceholder:[NSString stringWithFormat:@"@%@：", commentModel.userName]];
}


#pragma mark - HTSVideoDetailTopViewDelegate

- (void)topView:(UIViewController *)viewController didClickCloseWithModel:(FHFeedUGCCellModel *)model
{
    [self dismissByClickingCloseButton];
}

- (void)dismissByClickingCloseButton
{
    [self.navigationController popViewControllerAnimated:YES];
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

        if([[FHShareManager shareInstance] isShareOptimization]) {
            [self showSharePanel:image];
            return;
        }
        
        AWEVideoShareModel *shareModel = [[AWEVideoShareModel alloc] initWithModel:self.model image:image shareType:shareType];
        [self.shareManager displayActivitySheetWithContent:[shareModel shareContentItems]];
    }];
}

- (void)showSharePanel:(UIImage *)image {
    FHFeedContentRawDataSmallVideoShareModel *shareModel = self.model.share;
    
    NSString *shareTitle = nil;
    if (shareModel.shareTitle.length > 0) {
        shareTitle = shareModel.shareTitle;
    } else {
        shareTitle = [NSString stringWithFormat:@"%@的精彩视频", self.model.user.name];
    }
    
    NSString *desc = shareModel.shareDesc;
    if (desc.length > 0) {
        desc = [desc length] > 30 ? [[desc substringToIndex:30] stringByAppendingString:@"..."] : desc;
    } else {
        desc = @"这是我私藏的视频。一般人我才不分享！";
    }

    FHShareDataModel *dataModel = [[FHShareDataModel alloc] init];

    FHShareCommonDataModel *commonDataModel = [[FHShareCommonDataModel alloc] init];
    commonDataModel.title = shareTitle;
    commonDataModel.desc = desc;
    commonDataModel.shareUrl = shareModel.shareUrl;
    commonDataModel.thumbImage = image;
    commonDataModel.imageUrl  = [self.model.video.originCover.urlList firstObject];
    commonDataModel.shareType = BDUGShareWebPage;
    dataModel.commonDataModel = commonDataModel;

    FHShareReportDataModel *reportDataModel = [[FHShareReportDataModel alloc] init];
    WeakSelf;
    reportDataModel.reportBlcok = ^{
        StrongSelf;
        [self handleReportVideo];
    };
    dataModel.reportDataModel = reportDataModel;
    
    FHShareCollectDataModel *collectDataModel = [[FHShareCollectDataModel alloc] init];
    collectDataModel.collected = self.model.userRepin;
    collectDataModel.collectBlcok = ^{
        StrongSelf;
        [self handleFavoriteVideoWithContentItem:nil];
    };
    dataModel.collectDataModel = collectDataModel;
    
    NSArray *contentItemArray = @[
        @[@(FHShareChannelTypeWeChat),@(FHShareChannelTypeWeChatTimeline),@(FHShareChannelTypeQQFriend),@(FHShareChannelTypeQQZone),@(FHShareChannelTypeCopyLink)],
        @[@(FHShareChannelTypeCollect),@(FHShareChannelTypeDislike),@(FHShareChannelTypeReport),@(FHShareChannelTypeBlock)],
    ];
    
    FHShareContentModel *model = [[FHShareContentModel alloc] initWithDataModel:dataModel contentItemArray:contentItemArray];
    [[FHShareManager shareInstance] showSharePanelWithModel:model tracerDict:[self shareParams]];
}

- (NSDictionary *)shareParams {
    FHFeedUGCCellModel *model = self.model;
    NSDictionary *logPb = [model.logPb copy];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"group_id"] = model.groupId ?: @"be_bull";
    params[@"group_source"] = logPb[@"group_source"] ?: @"be_bull";
    params[@"impr_id"] = logPb[@"impr_id"] ?: @"be_bull";
    params[@"origin_from"] = model.tracerDic[@"origin_from"] ?: @"be_null";
    params[@"enter_from"] = model.tracerDic[@"enter_from"] ?: @"be_null";
    params[@"category_name"] = @"f_house_smallvideo_flow";
    params[@"page_type"] = @"small_video_detail";

    NSDictionary *tracerDict = self.pageParams;
    NSDictionary *extraDic = tracerDict[@"extraDic"];
    if([extraDic isKindOfClass:[NSDictionary class]]) {
        params[@"element_type"] = extraDic[@"element_type"] ?: @"be_null";
    }
    return params;
}

#pragma mark -

- (void)playView:(AWEVideoPlayView *)view didClickInputWithModel:(FHFeedUGCCellModel *)model
{
    if ([self alertIfNotValid]) {
        return;
    }

//    if (self.inputBar.targetCommentModel) {
//        // 草稿是回复A，现在要回复视频
//        [self.inputBar clearInputBar];
//    }
//
//    self.inputBar.params[@"source"] = @"video_play";
//    [self.inputBar becomeActive];
    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO replyToCommentID:nil podition:@"detail_comment"];
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

- (void)p_willOpenWriteCommentViewWithReservedText:(NSString *)reservedText switchToEmojiInput:(BOOL)switchToEmojiInput replyToCommentID:(NSString *)replyToCommentID podition:(NSString *)position {
    
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
        [wSelf clickSubmitComment:position];
    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:nil];
    commentManager.enterFrom = @"feed_detail";
    commentManager.enter_type = @"submit_comment";
    commentManager.reportParams = self.tracerDic[@"extraDic"];
    
    self.commentWriteView = [[FHPostDetailCommentWriteView alloc] initWithCommentManager:commentManager];

    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;
    
    [self.commentWriteView showInView:self.view animated:YES];
}

- (void)clickSubmitComment:(NSString *)position {
    NSInteger rank = [self.model.tracerDic btd_integerValueForKey:@"rank" default:0];
     [FHShortVideoTracerUtil clickCommentSubmitWithModel:self.model eventIndex:rank eventPosition:position];
}

#pragma mark - TTWriteCommentViewDelegate

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


#pragma mark - Entrance

- (TSVShortVideoListEntrance)entrance
{
    TSVShortVideoListEntrance ret = TSVShortVideoListEntranceOther;
    
    return ret;
}

@end

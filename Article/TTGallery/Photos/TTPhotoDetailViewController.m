//
//  TTPhotoDetailViewController.m
//  Article
//
//  Created by yuxin on 4/18/16.
//
//

#import "TTPhotoDetailViewController.h"
#import "TTDetailModel.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTPhotoDetailViewModel.h"
#import "ArticleInfoManager.h"
#import "TTCommentDataManager.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "ExploreDetailSaveImageManager.h"
#import "TTArticleDetailViewModel.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "SSWebViewUtil.h"
#import "TTPhotoDetailViewController+ToolbarFunc.h"

#import "TTURLUtils.h"
#import "SSImpressionManager.h"
#import "ArticleFriend.h"
#import "TTPhotoDetailContainerViewController.h"
#import "TTImageView.h"
#import "SSURLTracker.h"
#import "TTIndicatorView.h"
#import "NetworkUtilities.h"
#import <Crashlytics/Crashlytics.h>
#import "TTAdManager.h"
#import "TTDeviceHelper.h"
#import "ExploreMixListDefine.h"

#import "TTReportManager.h"
#import "NSObject+FBKVOController.h"
#import <TTAccountBusiness.h>
#import "ExploreEntry.h"
#import "ExploreEntryManager.h"
#import "FriendDataManager.h"
#import "NewsDetailLogicManager.h"

#import "TTURLTracker.h"
#import <TTTracker/TTTrackerProxy.h>
#import "TTServiceCenter.h"
#import "TTKitchenHeader.h"

//爱看
#import "AKHelper.h"
#import "AKAwardCoinArticleMonitorManager.h"

@interface TTPhotoDetailViewController () <TTDetailWebviewDelegate,
                                            TTDetailWebViewRequestProcessorDelegate,
                                            TTPhotoNativeDetailViewDelegate,
                                            ExploreDetailManagerDelegate,
                                            TTSaveImageAlertViewDelegate,
                                            SSActivityViewDelegate,
                                            UIViewControllerErrorHandler,
											TTCommentViewControllerDelegate>



//传入的DetailModel
@property (nonatomic, strong, readwrite) TTDetailModel *detailModel;

//图片保存manager
@property(nonatomic, strong) ExploreDetailSaveImageManager * saveImageManager;
//统计Tracker
@property(nonatomic, strong, readwrite) TTPhotoDetailTracker *tracker;

//web图集的相关参数
@property (nonatomic, strong) SSThemedView   *webGalleryTopBgView;
@property (nonatomic, assign) NSInteger      countOfImage;
@property (nonatomic, assign) NSInteger      showedCountOfImage;
@property (nonatomic, assign) NSInteger      currentShowedImageIndex;

@property (nonatomic, assign,readwrite) BOOL isShowingRelated;
@property (nonatomic, assign) BOOL           domReady;
@property (nonatomic, copy) NSArray        *webGalleryRecommedInfoArray;
@property (nonatomic, copy) NSArray        *recommendImageInfoArray;

//图片轻点的flag 主要用来隐藏top和toolbar
@property (nonatomic, assign) BOOL           tapOn;
// web图集加载超时
@property (nonatomic, assign) BOOL           webViewLoadedTimeout;
// 统计
@property (nonatomic, copy  ) NSString       *webViewTrackKey;
// staypage统计
@property (nonatomic, assign) BOOL           hasDidAppeared;
@property (nonatomic, assign) BOOL           isAppearing;

//记录底部toolbar 上次的alpha状态
@property (nonatomic, assign) CGFloat        toolbarLastAlpha;

//广告相关
@property (nonatomic, copy) NSDictionary *titleADDic;
@property (nonatomic, strong) UIImageView *titleBarADView;
@property (nonatomic, assign) BOOL hasMakeStepAfterTwo;
@property (nonatomic, assign) BOOL hasCheckAdLoadFinish;
@property (nonatomic, assign) BOOL hasImageDownload;
@property (nonatomic, strong) UIView *slideOutTipView;
@property (nonatomic, strong) UIView *slideOutCoverView;
@property (nonatomic, assign) NSUInteger currentRealIndex;
@property (nonatomic, assign) TTPhotoDetailImagePositon imagePositionType; //标示当前显示的图片类型 普通、广告、图集推荐
@property (nonatomic, assign) BOOL isFirstShowAdPage;   //是否是进入此图集第一次展示广告页面
@property (nonatomic, strong) AKAwardCoinArticleMonitorManager *manager;
@end


@implementation TTPhotoDetailViewController {
    // web图集
    BOOL _script4GalleryRecommendHadExecuted;
    BOOL _imageRecommendViewHadAppeared;

    BOOL _isWebViewLoading;
    BOOL _webViewHasError;
    BOOL _webviewHasInsertedInformationJS;
    BOOL _webTypeContentStatusCodeChecked;
    BOOL _webViewDidFinished;
    BOOL _informationAntiHijackJSInjected;
    BOOL _webGalleryTransformed;
    NSString *_latestWebViewRequestURLString;

    TTShareSourceObjectType _shareSourceType;
    
    NSDate *_vcDidLoadTime;
}

@synthesize leftBarButton;
@synthesize rightBarButtons;
@synthesize dataSource;
@synthesize delegate;

- (instancetype)initWithDetailViewModel:(TTDetailModel *)model
{
    //create detailView
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _detailModel = model;
        [self.detailModel sharedDetailManager].delegate = self;

        //状态栏 navbar 状态等
        self.ttHideNavigationBar = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
        self.imagePositionType = TTPhotoDetailImagePositon_NormalImage;
        self.toolbarLastAlpha = -1;
        self.isFirstShowAdPage = YES;
        _webTypeContentStatusCodeChecked = NO;
        _webGalleryTransformed = NO;
        _isInVertiMoveGesture = NO;
        [self addNotifiationObservers];

        [self addKVO];

        [self _logGoDetail];
    }
    return self;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self removeKVO];

    // 发送广告落地页面跳转次数的统计
    [self.tracker tt_sendJumpEventTrack];

    if (self.tracker.startLoadDate) {
        [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatCancel error:nil];
        [self.tracker tt_resetStartLoadDate];
    }

    [self.tracker tt_sendJumpLinksTrackWithKey:self.webViewTrackKey];

    CGFloat pct = 0;
    CGFloat pageCount = 0;
    if (self.webContainer) {
        if (self.countOfImage > 0) {
            pct = MIN(_showedCountOfImage/(CGFloat)_countOfImage, 1);
            pageCount = _countOfImage;
        }
//        [self.tracker tt_sendStayTimeImpresssion];

        if (!self.domReady) {
            //统计：正文还未加载出来用户即离开详情页
            [self.tracker tt_sendDetailLoadTimeOffLeave];
        }
        [self.webContainer.webView ttr_fireEvent:@"close" data:nil];

        // 延时释放，确保close事件调用成功
        TTDetailWebviewContainer * webContainer = self.webContainer;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 这里随便写了一条语句，避免编译器把这个block优化没了
            webContainer.natantStyle = 0;
        });
    }
    else if (self.nativeDetailView) {
        if (self.detailModel.article.galleries.count > 0) {
            pct = MIN((CGFloat)(self.nativeDetailView.maximumVisibleIndex)/self.detailModel.article.galleries.count, 1);
            pageCount = self.detailModel.article.galleries.count;
        }
    }

//    [self.tracker tt_sendReadTrackWithPCT:pct pageCount:pageCount];

    NSDictionary *extras = @{@"show_pic":@(_showedCountOfImage),
                             @"all_pic":@(_countOfImage)};

    [self.tracker tt_sendDetailTrackEventWithTag:@"slide_over"
                                        label:self.detailModel.sharedDetailManager.eventLabel
                                        extra:extras];
    [self.tracker tt_sendDetailDeallocTrack:_backButtonTouched];
}

- (void)_logGoDetail
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.detailModel.adID.stringValue forKey:@"ext_value"];
    [dic setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
    if (self.detailModel.relateReadFromGID) {
        [dic setValue:[NSString stringWithFormat:@"%@",self.detailModel.relateReadFromGID] forKey:@"from_gid"];
    }
    BOOL hasZzComment = self.detailModel.article.zzComments.count > 0;
    [dic setValue:@(hasZzComment?1:0) forKey:@"has_zz_comment"];
    if (hasZzComment) {
        [dic setValue:self.detailModel.article.firstZzCommentMediaId forKey:@"mid"];
    }
    
    if (self.detailModel.gdExtJsonDict.count > 0) {
        [dic addEntriesFromDictionary:self.detailModel.gdExtJsonDict];
    }
    [dic setValue:self.detailModel.logPb forKey:@"log_pb"];
    id value = self.detailModel.article.groupModel.groupID;
    
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        wrapperTrackEventWithCustomKeys(@"go_detail", self.detailModel.clickLabel, value, nil, dic);
    }
    
    //log3.0 doubleSending
    NSMutableDictionary *logv3Dic = [NSMutableDictionary dictionaryWithCapacity:5];
    [logv3Dic setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
    [logv3Dic setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
    [logv3Dic setValue:[NewsDetailLogicManager enterFromValueForLogV3WithClickLabel:self.detailModel.clickLabel categoryID:self.detailModel.categoryID] forKey:@"enter_from"];
    NewsGoDetailFromSource fromSource = self.detailModel.fromSource;
    if (fromSource == NewsGoDetailFromSourceHeadline ||
        fromSource == NewsGoDetailFromSourceCategory) {
        [logv3Dic setValue:self.detailModel.categoryID forKey:@"category_name"];
    }
    [logv3Dic setValue:self.detailModel.logPb forKey:@"log_pb"];
    [logv3Dic setValue:self.detailModel.adID.stringValue forKey:@"ad_id"];
    [logv3Dic setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
    if (self.detailModel.relateReadFromGID) {
        [logv3Dic setValue:[NSString stringWithFormat:@"%@",self.detailModel.relateReadFromGID] forKey:@"from_gid"];
    }
    [logv3Dic setValue:@(hasZzComment?1:0) forKey:@"has_zz_comment"];
    if (hasZzComment) {
        [logv3Dic setValue:self.detailModel.article.firstZzCommentMediaId forKey:@"mid"];
    }
    
    if (self.detailModel.gdExtJsonDict) {
        [logv3Dic setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
    }

    [TTTrackerWrapper eventV3:@"go_detail" params:logv3Dic isDoubleSending:YES];
}

#pragma mark Life cycle & Components load

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.tapOn
                                            withAnimation:UIStatusBarAnimationFade];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 第一次进入是在内容加载完成后才开始记录staypage时间，push到其他页面时停止记录staypage，返回时重新开始记录
    if (_hasDidAppeared) {
        [self.detailModel.sharedDetailManager startStayTracker];
    }

    _hasDidAppeared = YES;
    _isAppearing = YES;

    if (self.webContainer && self.isShowingRelated) {
        [self impressionStart4ImageRecommend];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.commentShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
        self.commentShowDate = nil;
    }
    
    NSDictionary *commentDic = @{@"stay_comment_time":[[NSNumber numberWithDouble:round(self.commentShowTimeTotal)] stringValue]};
    [self.detailModel.sharedDetailManager extraTrackerDic:commentDic];
    [self.detailModel.sharedDetailManager endStayTracker];
    self.commentShowTimeTotal = 0;
    _isAppearing = NO;

    if (self.webContainer && self.isShowingRelated) {
        [self impressionEnd4ImageRecommend];
    }

    //added 5.7.*:disappear也发送read_pct事件
    CGFloat pct = 0;
    CGFloat pageCount = 0;
    if (self.webContainer) {
        if (self.countOfImage > 0) {
            pct = MIN(_showedCountOfImage/(CGFloat)_countOfImage, 1);
            pageCount = _countOfImage;
        }
    }
    else if (self.nativeDetailView) {
        if (self.detailModel.article.galleries.count > 0) {
            pct = MIN((CGFloat)(self.nativeDetailView.maximumVisibleIndex)/self.detailModel.article.galleries.count, 1);
            pageCount = self.detailModel.article.galleries.count;
        }
    }
    [self.tracker tt_sendReadTrackWithPCT:pct pageCount:pageCount];
    [self.tracker tt_sendStayTimeImpresssion];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithHexString:@"#1B1B1B"];

    _vcDidLoadTime = [NSDate date];
    
    WeakSelf;
    [self.KVOController observe:self.view keyPath:@"ttLoadingView" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        if ([self.view.ttLoadingView isKindOfClass:[SSThemedView class]]) {
            ((SSThemedView *)self.view.ttLoadingView).themeMode = SSThemeModeAlwaysNight;
        }
    }];
    [self buildTopView];

    if (self.detailModel.isArticleReliable) {
        [self commonLoadView];
    }
    else {
        [self tt_startUpdate];
    }
    TLS_LOG(@"TTPhotoDetailViewController viewDidLoad with groupID %lld", self.detailModel.article.uniqueID);
    self.manager = [AKAwardCoinArticleMonitorManager ak_startMonitorIfNeedWithGroupID:self.detailModel.article.groupModel.groupID
                                                                           fromSource:self.detailModel.fromSource];
}


- (void)detailContainerViewController:(nullable SSViewControllerBase *)container reloadData:(nullable TTDetailModel *)detailModel {

    [self tt_endUpdataData];

    _detailModel = detailModel;

    [self commonLoadView];

}

- (void)detailContainerViewController:(nullable SSViewControllerBase *)container loadContentFailed:(nullable NSError *)error{
    [self tt_endUpdataData];
}

- (void)detailContainerViewController:(SSViewControllerBase *)container reloadDataIfNeeded:(TTDetailModel *)detailModel {
    if (self.webViewLoadedTimeout && !self.nativeDetailView) {
        LOGD(@"reloadDataIfNeeded");
        [self startLoadNativeContentAfter:0];
    }
}

- (BOOL)shouldShowErrorPageInDetailContaierViewController:(SSViewControllerBase *)container {
    return YES;
}

- (void)commonLoadView {


    self.viewModel = [[TTPhotoDetailViewModel alloc] initViewModel:_detailModel];

    [self buildToolBarIfNeed];

    [self updateToolbar];

    BOOL isNativeGallary = _detailModel.article.articleType == ArticleTypeNativeContent;
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_isNativePhotoAlbum:)]) {
        [adManagerInstance photoAlbum_isNativePhotoAlbum:isNativeGallary];
    }
    
    if ([self shouldLoadNativeGallery]) {
        [self loadNativePhotoDetailView];
        [self.detailModel.sharedDetailManager startStayTracker];
        [self tt_sendLoadTimeMonitorWithPhotoType:@"native_photo_load_ready"];
    }
    else {
        [self tt_startUpdate];
        [self loadWebPhotoDetailView];
        [self.topView.avatarView removeFromSuperview];
    }

    [self.view bringSubviewToFront:self.toolbarView];

    // detailModel和webContainer变化时需要重新创建tracker
    [self initTracker];

    __weak typeof(self) wself = self;
    [self.viewModel tt_startFetchInformationWithFinishBlock:^(ArticleInfoManager *infoManager, NSError *error) {

        // 统计进入详情页之后进行的页面跳转
        wself.webViewTrackKey = infoManager.webViewTrackKey;

        // native相关图集和搜索词
        wself.recommendImageInfoArray = infoManager.relateImagesArticles;
        [wself.nativeDetailView.imageCollectionView setupRecommendImageInfoArray:infoManager.relateImagesArticles andRecommendSearchWordsArray:infoManager.relateSearchWordsArray];

        // webview图集 采用js方式加入
        wself.webGalleryRecommedInfoArray = infoManager.webRecommandPhotosArray;

        if (wself.webContainer && wself.domReady) {
            [wself exeScript4GalleryRecommendIfNeeded];
        }

        // media_info数据只在info接口中返回，所以需要刷新一下
        [wself showOriginalImageIfNeeded];
        wself.topView.avatarView.disableNightMode = YES;
        wself.topView.avatarView.verifyView.disableNightMode = YES;
        wself.topView.avatarView.enableRoundedCorner = YES;
        wself.topView.avatarView.backgroundColor = [UIColor clearColor];
        wself.topView.avatarView.borderColorThemeKey = nil;
        wself.topView.avatarView.layer.borderColor = [UIColor tt_defaultColorForKey:kColorLine1].CGColor;
        //预加载titlebar广告数据
        [wself updateTitleBarADView:infoManager.detailADJsonDict];

        [wself _injectInformationAntihijackJSIfNeed];
        //图集评论区上方浮层，，目前只支持放出管理链接
        wself.commentViewController.infoManager = infoManager;

        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:error.description forKey:@"error_description"];
        [extra setValue:@(error.code) forKey:@"error_code"];
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", wself.detailModel.article.uniqueID];
        [extra setValue:uniqueID forKey:@"group_id"];
        [extra setValue:wself.detailModel.article.itemID forKey:@"item_id"];
        [extra setValue:[TTAccountManager userID] forKey:@"user_id"];
        [wself.nativeDetailView.imageCollectionView updateimageSubjectsFromArticle:wself.detailModel.article];
        if (!error) {
            //added 5.9.9 取回info后尝试转码
            if (!_webGalleryTransformed) {
                NSTimeInterval timeoutDelay = [SSCommonLogic webContentArticleProtectionTimeoutInterval];
                [wself startLoadNativeContentAfter:timeoutDelay];
            }

            [[TTMonitor shareManager] trackService:@"photo_get_info" status:1 extra:extra];
            if (SSIsEmptyArray(wself.recommendImageInfoArray)) {
                [[TTMonitor shareManager] trackService:@"photo_relate_images_lost" status:1 extra:extra];
            }
            if(SSIsEmptyArray(wself.webGalleryRecommedInfoArray)) {
                [[TTMonitor shareManager] trackService:@"photo_relate_images_lost" status:2 extra:extra];
            }
            
            // added 6.4.1 图集下架逻辑，以前缺失
            [wself _deletePhotoIfNeeded];
            
        } else {
            [[TTMonitor shareManager] trackService:@"photo_get_info" status:2 extra:extra];
        }
    }];
    
    if ([self shouldBeginShowComment]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _showCommentActionFired:nil];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)orientationDidChangeNotification:(NSNotification *)notification{
    //统一处理视图发生旋转
    //1、更新顶部导航的渐变图层
    self.topViewGradLayer.frame = self.topView.bounds;
//    [self.writeCommentView dismissAnimated:YES];
//    self.writeCommentView.delegate = nil;
}

- (void)loadNativePhotoDetailView
{
    self.nativeDetailView = [[TTPhotoNativeDetailView alloc] initWithFrame:self.view.bounds model:self.detailModel];
    self.nativeDetailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.nativeDetailView.delegate = self;

    //相关图集推荐的代理在这设置
    //这个case的原因是首次是以web的方式加载，失败后转成native的方式，需要在这设置delegate。。。
    TTPhotoDetailContainerViewController * containerViewController = (TTPhotoDetailContainerViewController *)[self ss_nextResponderWithClass:[TTPhotoDetailContainerViewController class]];
    self.nativeDetailView.imageCollectionView.cellScrolldelegate = containerViewController;

    UIEdgeInsets edgeInsets = self.nativeDetailView.contentInset;
    edgeInsets.bottom = self.toolbarView.frame.size.height;
    edgeInsets.top = self.topView.frame.size.height;
    self.nativeDetailView.contentInset = edgeInsets;

    [self.view insertSubview:self.nativeDetailView atIndex:0];
    //self.detailView = detailView;
    self.toolbarView.backgroundColorThemeKey = kColorBackground15;
}

- (void)loadWebPhotoDetailView
{
    self.webContainer  = [[TTDetailWebviewContainer alloc] initWithFrame:self.view.bounds disableWKWebView:YES hiddenWebView:nil webViewDelegate:nil];
    self.webContainer.delegate = self;
    self.webContainer.webView.backgroundColor = [UIColor colorWithHexString:@"#222222"];
    self.webContainer.webView.scrollView.bounces = NO;
    self.webContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (@available(iOS 11.0, *)) {
        self.webContainer.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.webContainer.containerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self.view insertSubview:self.webContainer atIndex:0];

    self.toolbarView.backgroundColor = [[UIColor colorWithHexString:@"#1B1B1B"] colorWithAlphaComponent:.7f];


    self.saveImageManager = [[ExploreDetailSaveImageManager alloc] init];

    [self registerWebViewUserAgent];

    [self registerPhotoWebViewJSCallback];

    [self startLoadWebTypeContent];

    //added 5.4:导流页超时加载转码页+web图集超时加载native图集机制
    NSTimeInterval timeoutDelay = [SSCommonLogic webContentArticleProtectionTimeoutInterval];
    [self startLoadNativeContentAfter:timeoutDelay];
}

//导流页是否可以加载转码页
- (BOOL)canLoadNativeContentForWebTypeGallery
{
    if ([SSCommonLogic webContentArticleProtectionTimeoutDisabled]) {
        return NO;
    }

    //是native图集则返回
    if (self.nativeDetailView) {
        return NO;
    }

    if ([self.detailModel.adID longLongValue]) {
        return NO;
    }

    if ([self.detailModel.article.ignoreWebTranform boolValue]) {
        return NO;
    }

    return YES;
}

- (void)startLoadNativeContentAfter:(NSTimeInterval)timeoutDelay
{
    if (![self canLoadNativeContentForWebTypeGallery]) {
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.domReady) {
            return;
        }

        __weak typeof(self) wself = self;
        [self.webContainer.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML;" completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
            __strong typeof(wself) self = wself;
            if (!error && !isEmptyString(result)) {
                return;
            }

            if (timeoutDelay > 0) {
                LOGD(@"webViewLoadedTimeout");
            }

            [self loadTransformNativePageForWebGallery];
        }];
    });
}

- (void)loadTransformNativePageForWebGallery
{
    self.webViewLoadedTimeout = YES;

    // 转码内容请求接口未返回时不加载转码页，接口返回时收到通知再加载转码页
    BOOL articleContentFetched = !isEmptyString(self.detailModel.article.detail.content);
    if (!articleContentFetched) {
        LOGD(@"articleContentNotAvailable");
        return;
    }
    if ([self.detailModel.article.ignoreWebTranform boolValue] ||
        _webGalleryTransformed) {
        return;
    }
    // 统计打点
    [self.tracker tt_sendStartLoadNativeContentForWebTimeoffTrack];
    
    _webGalleryTransformed = YES;

    [self.webContainer.webView stopLoading];

    [self replaceWebViewWithNativeView];
}

//导流页超时，加载转码页
- (void)replaceWebViewWithNativeView
{
    LOGD(@"replaceWebViewWithNativeView");
    [self tt_endWebPhotoUpdateIfCould];
    [self.webContainer removeFromSuperview];
    self.webContainer.delegate = nil;
    self.webContainer = nil;

    // 本次web图集加载时长丢弃，转码重计
    _vcDidLoadTime = [NSDate date];
    
    [self commonLoadView];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    parent.ttDragToRoot = [SSCommonLogic detailQuickExitEnabled];
}

- (void)_injectInformationAntihijackJSIfNeed {
    if (_webViewDidFinished && !_informationAntiHijackJSInjected && !isEmptyString(self.viewModel.infomationAntiHijackJS)) {
        [self.webContainer.webView stringByEvaluatingJavaScriptFromString:self.viewModel.infomationAntiHijackJS completionHandler:nil];
        _informationAntiHijackJSInjected = YES;
    }
}

#pragma mark - 图集下架

- (void)_deletePhotoIfNeeded
{
    if ([_detailModel.article.articleDeleted boolValue]) {
        _detailModel.article.galleries = nil;
        [_detailModel.article save];
        
        [self clearPhotoDetailViewComponents];
        
        self.view.ttViewType = TTFullScreenErrorViewTypeDeleted;
        [self.view tt_endUpdataData:NO error:nil];
        
        if (_detailModel.orderedData) {
            NSDictionary * userInfo = @{kExploreMixListDeleteItemKey:_detailModel.orderedData};
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListItemDeleteNotification object:nil userInfo:userInfo];
        }
        
        _detailModel.orderedData = nil;
        
        [[TTMonitor shareManager] trackService:@"article_deleted" status:1 extra:nil];
        
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", _detailModel.article.uniqueID];
        [ExploreOrderedData deleteObjectsWhere:@"WHERE uniqueID = ?" arguments:@[uniqueID]];
    }
}

- (void)clearPhotoDetailViewComponents
{
    for (UIView *subView in self.view.subviews) {
        if (subView == self.topView) {
            for (UIView *subItem in self.topView.subviews) {
                if (subItem != self.topView.backButton) {
                    [subItem removeFromSuperview];
                }
            }
        }
        else {
            [subView removeFromSuperview];
        }
    }
}

- (void)tt_endWebPhotoUpdateIfCould
{
    if (![self.detailModel.article.articleDeleted boolValue]) {
        [self tt_endUpdataData];
    }
}

#pragma mark - 响应链

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (touch.view == self.nativeDetailView.imageCollectionView.natantView){
        //点中了摘要
        [self.nativeDetailView.imageCollectionView doShowOrHideBarsAnimationWithOrientationChanged:NO];
        [self photoNativeDetailView:nil imagePositionType: TTPhotoDetailImagePositon_NormalImage tapOn:YES];
    }
}

#pragma mark - TopView & Bottom ToolBar

- (void)buildTopView {

    self.topView = [[ExploreDetailNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    self.topView.backgroundColor = [[UIColor colorWithHexString:@"#1B1B1B"] colorWithAlphaComponent:.7f];
    self.topViewGradLayer = [_topView insertVerticalGrowAlphaLayerWithStartAlpha:0.6 endAlpha:0];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.topView];
    if ([SSCommonLogic appGallerySlideOutSwitchOn]) {
        self.topView.backButton.imageName = @"photo_detail_titlebar_close";
    }
    else{
        self.topView.backButton.imageName = @"white_lefterbackicon_titlebar";;
    }

    self.titleBarADView = [[UIImageView alloc] init];
    self.titleBarADView.userInteractionEnabled = NO;
    self.titleBarADView.alpha = 0;
    self.titleBarADView.backgroundColor = [UIColor clearColor];
    [self.topView addSubview:self.titleBarADView];


    self.hasCheckAdLoadFinish = NO;
    self.hasMakeStepAfterTwo = NO;
    self.hasImageDownload = NO;

    [self.topView.backButton addTarget:self action:@selector(_backActionFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView.moreButton addTarget:self action:@selector(_moreActionFired:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buildToolBarIfNeed {

    if (self.commentViewController && self.toolbarView) { //WebView已构造，不需要再次构造
        return;
    }
    //condition
//    if (self.toolbarView.superview || ![self.viewModel needShowToolBar]) {
//        return;
//    }

    self.commentViewController = [[TTPhotoCommentViewController alloc] initViewModel:self.detailModel delegate:self];
    self.commentViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.commentViewController];
    [self.commentViewController didMoveToParentViewController:self];
    self.toolbarView = [[ExploreDetailToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ExploreDetailGetToolbarHeight())];
    self.toolbarView.toolbarType = ExploreDetailToolbarTypePhotoComment;
    self.toolbarView.viewStyle = TTDetailViewStylePhotoComment;

    [self.toolbarView.commentButton addTarget:self action:@selector(_showCommentActionFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.emojiButton addTarget:self action:@selector(_writeCommentActionFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.writeButton addTarget:self action:@selector(_writeCommentActionFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.collectButton addTarget:self action:@selector(_collectActionFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.shareButton addTarget:self action:@selector(_shareActionFired:) forControlEvents:UIControlEventTouchUpInside];


//    ExploreDetailManager *manager = [self.viewModel sharedDetailManager];
//    [manager trackToolbarMode];


    self.toolbarView.badgeLabel.backgroundColorThemeKey = nil;
    self.toolbarView.badgeLabel.backgroundColor = [UIColor colorWithHexString:@"f85959"];
    self.toolbarView.badgeLabel.textColorThemeKey = nil;
    self.toolbarView.badgeLabel.textColor = [UIColor whiteColor];

    self.toolbarView.collectButton.selected = self.detailModel.article.userRepined;
    self.toolbarView.frame = CGRectMake(0, self.view.frame.size.height - ExploreDetailGetToolbarHeight(), self.toolbarView.frame.size.width, ExploreDetailGetToolbarHeight());
    self.toolbarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.toolbarView];

}

- (void)updateToolbar
{
    self.toolbarView.collectButton.selected = self.detailModel.article.userRepined;
    self.toolbarView.commentBadgeValue = [@(self.detailModel.article.commentCount) stringValue];
}

- (BOOL)shouldShowAvatarView
{
    NSString *avatarURLStr = _detailModel.article.mediaInfo[@"avatar_url"];
    return !_detailModel.article || !isEmptyString(avatarURLStr);
}

- (void)showOriginalImageIfNeeded {
    if ([self shouldShowAvatarView]) {
        if ([SSCommonLogic articleNavBarShowFansNumEnable] && ![self.detailModel.article.mediaInfo tt_boolValueForKey:@"subcribed"] && !self.detailModel.article.isFollowed){
            self.topView.barType = ExploreDetailNavigationBarTypeShowFans;
        }else{
            self.topView.barType = ExploreDetailNavigationBarTypeDefault;
        }
        [self.topView updateAvartarViewWithArticleInfo:_detailModel.article isSelf:[[self.detailModel.article.userInfo tt_stringValueForKey:@"user_id"] isEqualToString:[TTAccountManager userID]]];
        [self.topView.avatarView addTouchTarget:self action:@selector(orignialActionFired:)];
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        [tapGestureRecognizer addTarget:self action:@selector(orignialActionFired:)];
        [self.topView.mediaName addGestureRecognizer:tapGestureRecognizer];
        self.topView.mediaName.userInteractionEnabled = YES;

        [self.topView.followButton addTarget:self action:@selector(followButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)followButtonClick:(id)sender {
    if (self.topView.followButton.isLoading) {
        return;
    }
    [self.topView.followButton startLoading];

    FriendDataManager *manager = [FriendDataManager sharedManager];
    FriendActionType type = [self.detailModel.article.mediaInfo tt_boolValueForKey:@"subcribed"] ? FriendActionTypeUnfollow : FriendActionTypeFollow;
    
    NSMutableDictionary * trackExtraDic = @{}.mutableCopy;
    NSString * followEvent = nil;
    if (FriendActionTypeUnfollow == type) {
        followEvent = @"rt_unfollow";
    }else {
        followEvent = @"rt_follow";
    }
    [trackExtraDic setValue:@(TTFollowNewSourcePicsFollow)
                     forKey:@"server_source"];
    [trackExtraDic setValue:self.detailModel.article.userIDForAction
                     forKey:@"to_user_id"];
    [trackExtraDic setValue:[self.detailModel.article.mediaInfo tt_stringValueForKey:@"media_id"]
                     forKey:@"media_id"];
    [trackExtraDic setValue:@"from_group"
                     forKey:@"follow_type"];
    [trackExtraDic setValue:self.detailModel.article.groupModel.groupID
                     forKey:@"group_id"];
    [trackExtraDic setValue:self.detailModel.article.groupModel.itemID
                     forKey:@"item_id"];
//    [trackExtraDic setValue:[self.detailModel clickFromLabel]
//                     forKey:@"enter_from"];
    [trackExtraDic setValue:self.detailModel.categoryID
                     forKey:@"category_name"];
    [trackExtraDic setValue:@"gallery_detail"
                     forKey:@"source"];
    [trackExtraDic setValue:@"top_title_bar"
                     forKey:@"position"];
    [TTTrackerWrapper eventV3:followEvent
                       params:trackExtraDic];

    WeakSelf;
    [[TTFollowManager sharedManager] startFollowAction:type userID:self.detailModel.article.mediaUserID platform:nil name:nil from:nil reason:nil newReason:nil newSource:[NSNumber numberWithUnsignedInteger:TTFollowNewSourcePicsFollow] completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        StrongSelf;
        [self.topView.followButton stopLoading:^{
            StrongSelf;
            if (error) {
                [self pgcReserve:(type == FriendActionTypeUnfollow) success:NO];
                return;
            }
            [self pgcReserve:(type == FriendActionTypeFollow) success:YES];
        }];
    }];
}

- (void)pgcReserve:(BOOL)reserve success:(BOOL)success
{
    NSString *text;
    NSMutableDictionary *mediaInfo = [[NSMutableDictionary alloc] initWithDictionary:self.detailModel.article.mediaInfo];
    //状态
    if (!success && reserve) {
        text = @"取消关注失败!";
        [mediaInfo setValue:@1 forKey:@"subcribed"];
    }
    else if (!success && !reserve) {
        text = @"关注失败!";
        [mediaInfo setValue:@0 forKey:@"subcribed"];
    }
    else if (success && reserve) {
        text = @"";
        [mediaInfo setValue:@1 forKey:@"subcribed"];
    }
    else if (success && !reserve) {
        text = @"";
        [mediaInfo setValue:@0 forKey:@"subcribed"];
    }

    self.detailModel.article.mediaInfo = mediaInfo;
    self.topView.followButton.followed = reserve;

    //提示
    if (!isEmptyString(text)){
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:text
                                 indicatorImage:nil
                                    autoDismiss:YES
                                 dismissHandler:nil];
    }
}

- (void)updateToggleGalleryBarsState
{
    if (!self.tapOn) {
        self.topView.functionView.alpha = 1;
        self.topView.alpha = 1;
    } else {
        self.topView.alpha = 0;
    }
}

- (void)updateTitleBarADView:(NSDictionary *)adDic
{
    if ([adDic.allKeys containsObject:@"image_titlebar"]) {
        self.titleADDic = (NSDictionary *)[adDic objectForKey:@"image_titlebar"];

        NSString *imageUrl = [self.titleADDic objectForKey:@"image"];
        if (imageUrl) {

            NSNumber *width = [self.titleADDic objectForKey:@"image_width"];
            if (!width) {
                width = @(360);
            }
            NSNumber *height = [self.titleADDic objectForKey:@"image_height"];
            if (!height) {
                height = @(48);
            }

            [self.titleBarADView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.topView.mas_centerX).offset(- width.floatValue/4);
                make.top.mas_equalTo(self.topView.mas_centerY).offset(10 - height.floatValue/4);
                make.width.mas_equalTo(width.floatValue/2);
                make.height.mas_equalTo(height.floatValue/2);
            }];


            //下载广告图片、发送是否已经下载的统计
            __weak typeof(self) wself = self;
            TTImageView *loadView = [[TTImageView alloc] init];
            [loadView setImageWithURLString:imageUrl placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
                if (image) {

                    [wself.titleBarADView setImage:image];

                    NSNumber *adID = [wself.titleADDic objectForKey:@"id"];
                    NSString *adExtraString = [wself.titleADDic objectForKey:@"log_extra"];
                    NSData *adExtraData = [adExtraString dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *adExtraDic = [NSDictionary new];
                    if (adExtraData) {
                        adExtraDic = [NSJSONSerialization JSONObjectWithData:adExtraData options:NSJSONReadingMutableContainers error:nil];
                    }
                    [wself.tracker tt_trackTitleBarAdWithTag:@"title_bar" label:@"load_finish" value:adID.stringValue extraDic:adExtraDic];
                    wself.hasImageDownload = YES;
                }

            } failure:^(NSError *error) {
                wself.hasImageDownload = NO;
            }];

        }
    }
}

#pragma mark - webView

- (void)registerWebViewUserAgent
{
    [SSWebViewUtil registerUserAgent:_detailModel.article.shouldUseCustomUserAgent];
}

- (void)registerPhotoWebViewJSCallback
{

    WeakSelf;
    //图片的单击事件
    [self.webContainer.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        __unused StrongSelf;
        [wself photoNativeDetailView:nil imagePositionType:TTPhotoDetailImagePositon_NormalImage tapOn:YES];
        wrapperTrackEvent(@"slide_detail", !wself.tapOn ? @"show_content":@"hide_content");
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"toggleGalleryBars"];

    //捕捉normalImage里的任意滑动(展示普通图集)
    [self.webContainer.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        __unused StrongSelf;
        //滑到普通图页面
        [[UIApplication sharedApplication] setStatusBarHidden:self.tapOn
                                                withAnimation:UIStatusBarAnimationFade];
        wself.imagePositionType = TTPhotoDetailImagePositon_NormalImage;
        if (wself.isShowingRelated) {
            [wself impressionEnd4ImageRecommend];
        }
        wself.isShowingRelated = NO;

        [wself showWebGalleryTopBgViewIfNeeded];

        NSInteger imageCount = [[result valueForKey:@"all_pic"] integerValue];

        wself.currentShowedImageIndex = [[result valueForKey:@"cur_index"] integerValue] + 1;

        if (wself.showedCountOfImage < imageCount) {
            wself.showedCountOfImage = [[result valueForKey:@"cur_index"] integerValue] + 1;
            wself.countOfImage = imageCount;
        }
        if (wself.currentShowedImageIndex == imageCount){
            [wself photoNativeDetailView:nil didScrollToIndex:wself.currentShowedImageIndex isLastPic:YES];
        }
                  
        wself.currentGalleryUrl = result[@"image_url"];

        [UIView animateWithDuration:.25f animations:^{
            wself.topView.recomLabel.alpha = 0;
            wself.topView.adLabel.alpha = 0;
            if (!wself.isInVertiMoveGesture) {
                [wself updateToggleGalleryBarsState];
                [wself refreshToolBarAlpha];
            }
        }];

        [[TTPhotoDetailManager shareInstance] setTransitionActionValid:YES];

        [wself refreshTitleBarAdAlpha:NO fromScroll:YES];

        TTR_CALLBACK_SUCCESS
    } forMethodName:@"slideShow"];

    //展示推荐图集
    [self.webContainer.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        __unused StrongSelf;
        //滑到推荐图集页面中
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationFade];
        wself.imagePositionType = TTPhotoDetailImagePositon_Recom;
        if (!wself.isShowingRelated) {
            [wself impressionStart4ImageRecommend];
        }
        wself.isShowingRelated = YES;

        [wself showWebGalleryTopBgViewIfNeeded];
        if (wself.showedCountOfImage == wself.countOfImage) {
            wself.showedCountOfImage ++;
        }
        wself.currentShowedImageIndex = wself.countOfImage + 1;

        [UIView animateWithDuration:.25f animations:^{

            wself.topView.alpha = 1;
            wself.topView.recomLabel.alpha = 1;
            wself.topView.adLabel.alpha = 0;
            wself.topView.functionView.alpha = 0;

            [wself refreshToolBarAlpha];

        }];

        [wself _sendEvent4ImageRecommendViewHadAppearedIfNeeded];
        [self.manager ak_readComplete];

        [[TTPhotoDetailManager shareInstance] setTransitionActionValid:YES];

        [wself refreshTitleBarAdAlpha:YES fromScroll:YES];

        TTR_CALLBACK_SUCCESS
    } forMethodName:@"relatedShow"];

    //展示广告图片
    [self.webContainer.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        __unused StrongSelf;
        //滑到推荐图集页面中
        wself.imagePositionType = TTPhotoDetailImagePositon_Ad;
        [wself photoNativeDetailView:nil didScrollToImagePostionType:TTPhotoDetailImagePositon_Ad];
        //使用子超的逻辑，web图集滚动到ad页时，当做滚动到recom页处理titleBarAdView
        [wself refreshTitleBarAdAlpha:YES fromScroll:YES];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"adImageShow"];

    //图片长按事件
    [self.webContainer.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        __unused __strong typeof(wself) self = wself;
        wself.saveImageManager.imageUrl = [result objectForKey:@"image_url"];
        [wself.saveImageManager showOnWindowFromViewController:(UIViewController <TTSaveImageAlertViewDelegate> *)wself];
        [((UIViewController <TTSaveImageAlertViewDelegate> *)wself) alertDidShow];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"slideDownload"];

    //图片双击缩放
    [self.webContainer.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {

        NSString *state = [result objectForKey:@"value"];
        if ([state isEqualToString:@"zoomIn"]) {
            [[TTPhotoDetailManager shareInstance] setTransitionActionValid:NO];
        }
        //normal
        else {
            [[TTPhotoDetailManager shareInstance] setTransitionActionValid:YES];
        }

        TTR_CALLBACK_SUCCESS
    } forMethodName:@"zoomStatus"];



    //广告图片加载成功
    [self.webContainer.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_trackAdImageFinishLoad)]) {
            [adManagerInstance photoAlbum_trackAdImageFinishLoad];
        }
        
        TTR_CALLBACK_SUCCESS;
    } forMethodName:@"adImageLoadFinish"];

    //广告图片单击
    [self.webContainer.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        //点击广告图片跳转到广告详情页
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_adImageClickWithResponder:)]) {
            [adManagerInstance photoAlbum_adImageClickWithResponder:wself];
        }
        TTR_CALLBACK_SUCCESS;
    } forMethodName:@"adImageClick"];
    
    //最后一页显示关注按钮
    [self.webContainer.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        CGFloat percent = [result tt_floatValueForKey:@"percent"];
        StrongSelf;
        [self photoNativeDetailView:nil scrollPercent:percent];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"setupFollowButton"];
}

- (void)_sendEvent4ImageRecommendViewHadAppearedIfNeeded
{
    if (_imageRecommendViewHadAppeared) {
        return;
    }
    _imageRecommendViewHadAppeared = YES;
    
    [self.viewModel sendEvent4ImageRecommendShow];
}

#pragma mark - Gallery


- (void)updateTTGalleryBottomGap
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *jsMethod;
        if ([TTDeviceHelper isPadDevice] || UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            jsMethod = @"TTGallery.showBottomGap();";
        }
        else {
            jsMethod = @"TTGallery.hideBottomGap();";
        }
        [self.webContainer.webView stringByEvaluatingJavaScriptFromString:jsMethod
                                                     completionHandler:nil];
    });
}

- (void)showWebGalleryTopBgViewIfNeeded
{
    if (!self.webGalleryTopBgView) {
        self.webGalleryTopBgView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, MAX(self.view.frame.size.width, self.view.frame.size.height), 64)];
        self.webGalleryTopBgView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        [self.view insertSubview:self.webGalleryTopBgView belowSubview:self.topView];
    }
    self.webGalleryTopBgView.hidden = [TTDeviceHelper isPadDevice] || !_isShowingRelated || UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

- (void)startLoadWebTypeContent
{
    if (isEmptyString(_detailModel.article.articleURLString)) {
        return;
    }
    //    //判断是否是最近加载的URL
    //    NSString * latestRequestURLString = [manager latestWebViewRequestURLString];
    //    if (!isEmptyString(latestRequestURLString) && [latestRequestURLString isEqualToString:[[request URL] absoluteString]]) {
    //        [self tt_endUpdataData];
    //
    //        return;
    //    }

    [self.webContainer.webView stopLoading];
    [self.webContainer.webView loadRequest:[self.viewModel tt_requstForWebContentPhotoView:self.webContainer.webView]];
}

- (void)exeScript4GalleryRecommendIfNeeded
{
    if (_script4GalleryRecommendHadExecuted) {
        return;
    }
    _script4GalleryRecommendHadExecuted = YES;
    //兼容image数据为空即没有广告的情况
    NSDictionary* imageDict = nil;
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbumImageDic)]) {
        imageDict = [adManagerInstance photoAlbumImageDic];
    }
    
    if (self.webGalleryRecommedInfoArray) {
        NSDictionary* dict = @{@"related_slides":self.webGalleryRecommedInfoArray, @"image_recom":imageDict?imageDict:@""};
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *exeScriptStr = [NSString stringWithFormat:@"if(typeof TTGallery == \"object\"){TTGallery.appendSlides(%@)}", jsonStr];

        [self.webContainer.webView evaluateJavaScriptFromString:exeScriptStr completionBlock:nil];

        self.webGalleryRecommedInfoArray = nil;
    }
}

#pragma mark - webView delegate

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType
{
    //检测404跳转, 命中加载转码页
    if (!self.webViewLoadedTimeout && !self.nativeDetailView) {
        if (!_webTypeContentStatusCodeChecked) {
            NSURLRequest *noCacheRequest = [NSURLRequest requestWithURL:request.URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3.f];
            NSURLConnection *connection = [NSURLConnection connectionWithRequest:noCacheRequest delegate:self];
            if (!connection) {
                LOGD(@"cannot create webTypeContent httpHeader check connection");
            }
            else {
                return NO;
            }
        }
    }

    if ([self.detailModel.adID longLongValue] != 0) {
        /// 如果是广告的，则需要统计连接跳转。需求说明一下，这是一个很蛋疼的统计，要统计广告落地页中，所有跳转的统计
        BOOL needReport = (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted);
        if (needReport) {
            self.tracker.jumpCount ++;
            if (navigationType == UIWebViewNavigationTypeLinkClicked) {
                self.tracker.clickLinkCount ++;
            }
        }
    }

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        self.tracker.userHasClickLink = YES;
    }

    if ([request.URL.absoluteString rangeOfString:@"enter_from=related"].location != NSNotFound) {
        NSDictionary *queryItems = [TTURLUtils queryItemsForURL:request.URL];
        [self.viewModel sendEvent4ImageRecommendClick:queryItems];
    }

    //统计跳转到某个URL
    if (!isEmptyString(request.URL.absoluteString)) {
        [self.tracker.jumpLinks addObject:request.URL.absoluteString];
    }

    return YES;
}

- (void)webViewDidStartLoad:(YSWebView *)webView
{
    if (!isEmptyString(_latestWebViewRequestURLString)) {
        BOOL isHTTP = [webView.request.URL.scheme isEqualToString:@"http"] ||
        [webView.request.URL.scheme isEqualToString:@"https"];

        if (![webView.request.URL.absoluteString isEqualToString:_latestWebViewRequestURLString] && isHTTP) {
            // 页面发生跳转，发送取消事件(里面会判断是否已经发送过其他事件，如果发送过，则不会重复发送)
            [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatCancel error:nil];
        }
    }
    _isWebViewLoading = YES;
    _latestWebViewRequestURLString = webView.request.URL.absoluteString;
}

- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    _webViewDidFinished = YES;
    [self tt_endWebPhotoUpdateIfCould];
    [self _injectInformationAntihijackJSIfNeed];
    // finishLoad会回调多次，这里使用变量标记，确保js和统计只调用一次
    if (!_webviewHasInsertedInformationJS) {
        _webviewHasInsertedInformationJS = YES;
        // 相关图集
        [self exeScript4GalleryRecommendIfNeeded];

        [self updateTTGalleryBottomGap];

        //广告监控统计 注入js
        NSNumber *adIDNumber = _detailModel.adID;
        if ([adIDNumber longLongValue] > 0) {
            [webView stringByEvaluatingJavaScriptFromString:[SSCommonLogic shouldEvaluateActLogJsStringForAdID:[adIDNumber stringValue]] completionHandler:nil];
        }
        
        [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatLoadFinish error:nil];
        
        // web图集加载时长监控
        [self tt_sendLoadTimeMonitorWithPhotoType:@"web_photo_finish_load"];
    }

    _webViewHasError = NO;
}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error
{
    __weak typeof(self) wself = self;
    [webView evaluateJavaScriptFromString:@"document.body.childElementCount;" completionBlock:^(NSString * _Nullable result, NSError * _Nullable error) {
        __strong typeof(wself) sself = wself;
        if ([result isEqualToString:@"0"]) {
            if (sself) {
                sself->_webViewHasError = YES;
            }
        }
    }];

    [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatLoadFail error:nil];
    
    if (!TTNetworkConnected()) {
        [self tt_endUpdataData:NO error:[NSError errorWithDomain:NSLocalizedString(@"没有网络连接", nil) code:-3 userInfo:@{@"errmsg":NSLocalizedString(@"没有网络连接", nil)}]];
    } else {
        [self tt_endWebPhotoUpdateIfCould];
    }
}


- (void)webView:(nullable TTDetailWebviewContainer *)webViewContainer scrollViewDidScroll:(nullable UIScrollView *)scrollView
{

}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    LOGD(@"[TTArticleDetail]webTypeContent connection:didReceiveResponse");
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger status = [httpResponse statusCode];

        BOOL shouldLoadNativeTypeContent = NO;
        if (status == 404) {
            //404页面尝试加载转码页
            LOGD(@"[TTPhotoDetailViewController]webTypeContent 404 fileNotFoundStatusCode found, will load nativeType content");
            shouldLoadNativeTypeContent = YES;
        }
        else {
            LOGD(@"[TTPhotoDetailViewController]webTypeContent http status code: %ld", status);
        }

        _webTypeContentStatusCodeChecked = YES;
        [connection cancel];

        if (shouldLoadNativeTypeContent && [self canLoadNativeContentForWebTypeGallery]) {
            [self loadTransformNativePageForWebGallery];
        }
        else {
            [self.webContainer.webView loadRequest:[self.viewModel tt_requstForWebContentPhotoView:self.webContainer.webView]];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    LOGD(@"[TTArticleDetail]webTypeContent connection:didReceiveData");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    LOGD(@"[TTArticleDetail]webTypeContentconnection:didFailWithError - %@", error);
    if (error) {
        _webTypeContentStatusCodeChecked = YES;
        [connection cancel];

        if ([self canLoadNativeContentForWebTypeGallery]) {
            [self loadTransformNativePageForWebGallery];
        }
        else {
            [self.webContainer.webView loadRequest:[self.viewModel tt_requstForWebContentPhotoView:self.webContainer.webView]];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    LOGD(@"[TTArticleDetail]webTypeContent connectionDidFinishLoading");
}

#pragma mark - TTDetailWebViewRequestProcessorDelegate

- (void)processRequestReceiveDomReady
{
    self.domReady = YES;
    //做统计
    [self.tracker tt_sendStartLoadDateTrackIfNeeded];

    [self.detailModel.sharedDetailManager startStayTracker];
}

#pragma mark - TTCommentViewControllerDelegate

- (void)tt_commentViewControllerDidFetchCommentsWithError:(NSError *)error {
    // toolbar 禁表情
    BOOL  isBanRepostOrEmoji = ![KitchenMgr getBOOL:KKCCommentRepostFirstDetailEnable] || (self.detailModel.adID > 0) || ak_banEmojiInput();
    self.toolbarView.banEmojiInput = self.commentViewController.banEmojiInput || isBanRepostOrEmoji;
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return NO;
}

#pragma mark -- rotate support

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    [self refreshCommentViewFrame];

    [self refreshToolBarAlpha];

    [self refreshTitleBarAdWithOritation:fromInterfaceOrientation];

}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.webContainer.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"TTGallery.updateSize();TTGallery.setDescriptionPadding(%@);", @([TTUIResponderHelper paddingForViewWidth:self.view.width])] completionHandler:nil];
    });

    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {

        UIEdgeInsets edgeInsets = self.nativeDetailView.contentInset;
        edgeInsets.bottom = 0;
        self.nativeDetailView.contentInset = edgeInsets;


    }
    else {

        UIEdgeInsets edgeInsets = self.nativeDetailView.contentInset;
        edgeInsets.bottom = self.toolbarView.frame.size.height;
        self.nativeDetailView.contentInset = edgeInsets;

    }
    [self updateTTGalleryBottomGap];

    if ([TTDeviceHelper OSVersionNumber] < 9.0) {
        [self hiddenMoreSettingActivityView];
    }
}

#pragma mark - TTPhotoNativeDetailView Delegate

- (void)photoNativeDetailView:(TTPhotoNativeDetailView *)photoNativeDetailView imagePositionType:(TTPhotoDetailImagePositon)imagePositionType tapOn:(BOOL)tapOn {

    if (imagePositionType == TTPhotoDetailImagePositon_NormalImage) {
        self.tapOn = !self.tapOn;

        [[UIApplication sharedApplication] setStatusBarHidden:self.tapOn
                                                withAnimation:UIStatusBarAnimationFade];

        if (self.tapOn) {

            [UIView animateWithDuration:.25 animations:^{
                [self refreshToolBarAlpha];
                self.topView.alpha = 0;
            }];

        }
        else {

            [UIView animateWithDuration:.25 animations:^{
                self.topView.alpha = 1;
                self.topView.functionView.alpha = 1;

                [self refreshToolBarAlpha];

            }];
        }
    }
    else if (imagePositionType == TTPhotoDetailImagePositon_Ad)
    {
        //点击广告图片跳转到广告详情页
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_adImageClickWithResponder:)]) {
            [adManagerInstance photoAlbum_adImageClickWithResponder:self];
        }
        
    }
    [[TTPhotoDetailManager shareInstance] setTransitionActionValid:YES];
    if ([SSCommonLogic needToShowSlideDownOutTip] && [SSCommonLogic appGallerySlideOutSwitchOn] && ![self isCurrentOrientationLandScape]) {
        [self showSlideOutTipViewIfNeed:imagePositionType == TTPhotoDetailImagePositon_Recom];
    }
    [self refreshTitleBarAdAlpha:imagePositionType == TTPhotoDetailImagePositon_Recom fromScroll:YES];
}




//滑动图片的回调
-(void)photoNativeDetailView:(TTPhotoNativeDetailView *)photoNativeDetailView didScrollToImagePostionType:(TTPhotoDetailImagePositon)imagePositionType
{
    //修改self.imagePositionType
    self.imagePositionType = imagePositionType;
    switch (imagePositionType) {
        case TTPhotoDetailImagePositon_NormalImage:
        {
            self.topView.alpha = !self.tapOn;
            self.topView.functionView.alpha = !self.tapOn;
            [[UIApplication sharedApplication] setStatusBarHidden:self.tapOn
                                                    withAnimation:UIStatusBarAnimationFade];
            [UIView animateWithDuration:.25f animations:^{
                self.topView.recomLabel.alpha = 0;
                self.topView.adLabel.alpha = 0;
                self.topView.avatarView.alpha = 1;
                self.topView.mediaName.alpha = 1;
                self.topView.fansLabel.alpha = 1;

                [self refreshToolBarAlpha];
            }];

            [[TTPhotoDetailManager shareInstance] setTransitionActionValid:YES];
            if ([SSCommonLogic needToShowSlideDownOutTip] && [SSCommonLogic appGallerySlideOutSwitchOn] && ![self isCurrentOrientationLandScape]) {
                [self showSlideOutTipViewIfNeed:NO];
            }
            [self refreshTitleBarAdAlpha:NO fromScroll:YES];
        }
            break;
        case TTPhotoDetailImagePositon_Ad:
        {
            self.topView.alpha = 1;
            self.topView.functionView.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:self.tapOn
                                                    withAnimation:UIStatusBarAnimationFade];
            [UIView animateWithDuration:.25f animations:^{
                self.topView.recomLabel.alpha = 0;
                self.topView.adLabel.alpha = 1;
                self.topView.avatarView.alpha = 0;
                self.topView.mediaName.alpha = 0;
                self.topView.fansLabel.alpha = 0;
                [self refreshToolBarAlpha];
            }];

            [[TTPhotoDetailManager shareInstance] setTransitionActionValid:YES];
            if ([SSCommonLogic needToShowSlideDownOutTip] && [SSCommonLogic appGallerySlideOutSwitchOn] && ![self isCurrentOrientationLandScape]) {
                [self showSlideOutTipViewIfNeed:NO];
            }
            [self refreshTitleBarAdAlpha:NO fromScroll:YES];
            if (self.isFirstShowAdPage == YES) {
                
                id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
                if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_trackAdImageShow)]) {
                    [adManagerInstance photoAlbum_trackAdImageShow];
                }
                
                //第一次展示之后，置为NO，重复翻到adPage，并不发show统计
                self.isFirstShowAdPage = NO;
            }

        }
            break;
        case TTPhotoDetailImagePositon_Recom:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                    withAnimation:UIStatusBarAnimationFade];
            self.topView.alpha = 1;
            self.topView.functionView.alpha = 0;
            [UIView animateWithDuration:.25f animations:^{
                self.topView.recomLabel.alpha = 1;
                self.topView.adLabel.alpha = 0;
                self.topView.avatarView.alpha = 0;
                self.topView.mediaName.alpha = 0;
                self.topView.fansLabel.alpha = 0;
                [self refreshToolBarAlpha];
            }];

            [[TTPhotoDetailManager shareInstance] setTransitionActionValid:YES];
            if ([SSCommonLogic needToShowSlideDownOutTip] && [SSCommonLogic appGallerySlideOutSwitchOn] && ![self isCurrentOrientationLandScape]) {
                [self showSlideOutTipViewIfNeed:YES];
            }
            [self refreshTitleBarAdAlpha:YES fromScroll:YES];

        }
            break;

        default:
            break;
    }

}

- (void)photoNativeDetailView:(TTPhotoNativeDetailView *)photoNativeDetailView scrollPercent:(CGFloat)scrollPercent {
    if (scrollPercent < 0) {
        scrollPercent += 1;
    }
    if (self.topView.showFollowedButton) {
        [self.topView setupFollowedButtonWithScrollPercent:scrollPercent];
    }
}

- (void)photoNativeDetailView:(TTPhotoNativeDetailView *)photoNativeDetailView didScrollToIndex:(NSUInteger)index isLastPic:(BOOL)isLastPic {
    if (isLastPic) {
        [self.manager ak_readComplete];
    }
    if (isLastPic && self.topView.showFollowedButton) {
        NSMutableDictionary *extraDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        [extraDic setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
        [extraDic setValue:self.detailModel.article.itemID forKey:@"item_id"];
        wrapperTrackEventWithCustomKeys(@"slide_detail", @"show_follow_button", self.detailModel.article.mediaUserID, nil, extraDic);
    }
}

#pragma mark - ExploreDetailManagerDelegate

- (void)detailManager:(ExploreDetailManager *)manager showTipMsg:(NSString *)tipMsg {
    if (!isEmptyString(tipMsg)) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
}

- (void)detailManager:(ExploreDetailManager *)manager showTipMsg:(NSString *)tipMsg icon:(UIImage *)image {
    if (!isEmptyString(tipMsg)) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
    }
}

- (void)detailManager:(ExploreDetailManager *)manager showTipMsg:(NSString *)tipMsg icon:(UIImage *)image dismissHandler:(DismissHandler)handler{
    if (!isEmptyString(tipMsg)) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:handler];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[Article class]]) {
        [self updateToolbar];
    }
}

- (void)addKVO
{
    [self.detailModel.article addObserver:self forKeyPath:@"userRepined" options:NSKeyValueObservingOptionNew context:NULL];
    [self.detailModel.article addObserver:self forKeyPath:@"actionDataModel.commentCount" options:NSKeyValueObservingOptionNew context:NULL];

}

- (void)removeKVO
{
    [self.detailModel.article removeObserver:self forKeyPath:@"userRepined"];
    [self.detailModel.article removeObserver:self forKeyPath:@"actionDataModel.commentCount"];
}

#pragma mark - NSNotification
- (void)addNotifiationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(applicationDidEnterBackground:)
                                                name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPGCSubscribeState:) name:kEntrySubscribeStatusChangedNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChangeNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (_isAppearing) {
        // 如果加载期间切换到后台，则放弃这一次统计
        [self.tracker tt_resetStartLoadDate];
        [self.tracker tt_sendJumpLinksTrackWithKey:self.webViewTrackKey];
        if (self.commentShowDate) {
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
            self.commentShowTimeTotal += timeInterval*1000;
            self.commentShowDate = nil;
        }
        NSDictionary *commentDic = @{@"stay_comment_time":[[NSNumber numberWithDouble:round(self.commentShowTimeTotal)] stringValue]};
        [self.detailModel.sharedDetailManager extraTrackerDic:commentDic];
        [self.detailModel.sharedDetailManager endStayTracker];
        self.commentShowTimeTotal = 0;

        //added 5.7.*:退到后台也发送read_pct事件
        CGFloat pct = 0;
        CGFloat pageCount = 0;
        if (self.webContainer) {
            if (self.countOfImage > 0) {
                pct = MIN(_showedCountOfImage/(CGFloat)_countOfImage, 1);
                pageCount = _countOfImage;
            }
        }
        else if (self.nativeDetailView) {
            if (self.detailModel.article.galleries.count > 0) {
                pct = MIN((CGFloat)(self.nativeDetailView.maximumVisibleIndex)/self.detailModel.article.galleries.count, 1);
                pageCount = self.detailModel.article.galleries.count;
            }
        }
        [self.tracker tt_sendReadTrackWithPCT:pct pageCount:pageCount];
        [self.tracker tt_sendStayTimeImpresssion];
    }
    
    //进入后台，记录时间 @Liangxinyu
    if (self.commentShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if (_isAppearing) {
        [self.detailModel.sharedDetailManager startStayTracker];
    }
    //进入前台，时间重置 @liangxinyu
    if(self.commentShowDate)
        self.commentShowDate = [NSDate date];
}

- (void)refreshPGCSubscribeState:(NSNotification *)notification
{
    ExploreEntry *entry = [[notification userInfo] objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    NSMutableDictionary *mediaInfo = [[NSMutableDictionary alloc] initWithDictionary:self.detailModel.article.mediaInfo];
    if ([[mediaInfo tt_stringValueForKey:@"media_id"] isEqualToString:entry.entryID] || [self.detailModel.article.mediaUserID isEqualToString:[entry.userID stringValue]]) {
        [mediaInfo setValue:entry.subscribed forKey:@"subcribed"];
        BOOL preFollowStatus = [self.detailModel.article.userInfo tt_boolValueForKey:@"follow"];
        BOOL currentFollowStatus = entry.subscribed.boolValue;
        if (preFollowStatus != currentFollowStatus){
            NSMutableDictionary *userInfo = [self.detailModel.article.userInfo mutableCopy];
            long long fansCount = [userInfo tt_longlongValueForKey:@"fans_count"];
            if (currentFollowStatus){
                fansCount += 1;
            }else{
                fansCount -= 1;
            }
            [userInfo setValue:@(fansCount) forKey:@"fans_count"];
            self.detailModel.article.userInfo = userInfo;
        }
        self.detailModel.article.mediaInfo = mediaInfo;
        self.topView.followButton.followed = [entry.subscribed boolValue];
        [self.topView updateAvartarViewWithArticleInfo:self.detailModel.article isSelf:YES];;
    }
}

#pragma mark - TTSaveImageAlertViewDelegate

- (void)alertDidShow
{
    [self.tracker tt_trackGalleryWithTag:@"slide_detail"
                                label:@"long_press"
                         appendExtkey:nil
                       appendExtValue:nil];
}

- (void)shareButtonFired:(id)sender
{
    //检测一下图片是否已经下载
    TTShowImageView *showImageView = [self.nativeDetailView currentShowImageView];
    if (showImageView.imageData == nil){
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"图片正在下载，请稍后再试", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
        [alert showFrom:self animated:YES];
        return;
    }
    
    [self currentGalleryShareUseActivityController];
    [self destructSaveImageAlert];
    [self.tracker tt_trackGalleryWithTag:@"slide_detail"
                                label:@"long_press_share_button"
                         appendExtkey:@"position"
                       appendExtValue:@(self.nativeDetailView.currentVisibleIndex)];
}

- (void)saveButtonFired:(id)sender{
    if (self.nativeDetailView) {
        [self.nativeDetailView saveCurrentNativeGalleryIfCould];
    }
    else {
        self.saveImageManager = [[ExploreDetailSaveImageManager alloc] init];
        self.saveImageManager.imageUrl = [self currentShowGalleryURL];
        [self.saveImageManager saveImageData];
    }
    [self destructSaveImageAlert];
    [self.tracker tt_trackGalleryWithTag:@"slide_detail"
                                label:@"save_pic"
                         appendExtkey:@"position"
                       appendExtValue:@(self.nativeDetailView.currentVisibleIndex)];
}

- (void)cancelButtonFired:(id)sender{
    [self destructSaveImageAlert];
}

- (void)destructSaveImageAlert
{
    if (self.nativeDetailView) {
        [self.nativeDetailView destructSaveImageAlert];
    }
    else {
        [self.saveImageManager destructSaveAlert];
    }
}

#pragma mark - other

- (BOOL)shouldLoadNativeGallery
{
    BOOL isNativeGallary = _detailModel.article.articleType == ArticleTypeNativeContent;

    return isNativeGallary || self.webViewLoadedTimeout;
}

- (void)showSlideOutTipViewIfNeed:(BOOL)showRecommend
{

    if (!self.slideOutTipView) {

        self.slideOutTipView = [[UIView alloc] initWithFrame:CGRectMake(0, -375, self.view.frame.size.width, 375)];
        self.slideOutTipView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"five_shadow_imgdetails"]];
        self.slideOutTipView.alpha = 0 ;
        [self.view addSubview:self.slideOutTipView];

        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down_imgdetails"]];
        [self.slideOutTipView addSubview:arrowView];

        UITextView *textView = [[UITextView alloc] init];
        textView.backgroundColor = [UIColor clearColor];
        textView.text = @"下\n滑\n退\n出\n图\n集\n";
        textView.textColor = [UIColor whiteColor];
        textView.font = [UIFont systemFontOfSize:12];
        [self.slideOutTipView addSubview:textView];

        [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.slideOutTipView.mas_centerX).offset(-19);
            make.top.equalTo(self.slideOutTipView.mas_top);
            make.width.mas_equalTo(14);
            make.height.mas_equalTo(140);
        }];


        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.slideOutTipView.mas_centerX).offset(5);
            make.top.equalTo(self.slideOutTipView.mas_top).offset(14);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(140);
        }];

        CGFloat topInset = self.view.tt_safeAreaInsets.top;
        self.slideOutCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, topInset, self.view.frame.size.width, 375)];
        self.slideOutCoverView.backgroundColor = [UIColor clearColor];
        self.slideOutCoverView.hidden = YES;
        [self.view addSubview:self.slideOutCoverView];
    }

    //当图片就是最后一张
    if ([self currentVisibleIndex] == self.detailModel.article.galleries.count) {
        if (!self.nativeDetailView.imageCollectionView.recommendImageInfoArray) {
            showRecommend = YES;
        }
    }

    if (showRecommend) {

        CGRect frame =  self.slideOutTipView.frame;
        frame.size.width = self.view.frame.size.width;
        self.slideOutTipView.frame = frame;
        self.slideOutTipView.alpha = 1;
        self.slideOutCoverView.hidden = NO;
        CGFloat topInset = self.view.tt_safeAreaInsets.top;
        [UIView animateWithDuration:1 animations:^{
            CGRect frame =  self.slideOutTipView.frame;
            frame.origin.y = topInset;
            self.slideOutTipView.frame = frame;

        } completion:^(BOOL finished) {

            [UIView animateWithDuration:2 animations:^{

                self.slideOutTipView.alpha = 0;

            } completion:^(BOOL finished) {

                CGRect frame =  self.slideOutTipView.frame;
                frame.origin.y = - self.slideOutTipView.frame.size.height;
                self.slideOutTipView.frame = frame;
                self.slideOutCoverView.hidden = YES;
            }];

        }];

        [SSCommonLogic setGallerySlideDownOutTip:@(1)];
    }
}

- (void)initTracker {
    self.tracker = [[TTPhotoDetailTracker alloc] initWithDetailModel:self.detailModel
                                                       detailWebView:self.webContainer];
}

- (void)tt_sendLoadTimeMonitorWithPhotoType:(NSString *)photoType
{
    if (_vcDidLoadTime) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_vcDidLoadTime];
        if (timeInterval > 0 && timeInterval < 100.f) {
            [[TTMonitor shareManager] trackService:@"photo_finish_load"
                                             value:[NSString stringWithFormat:@"%.1f", timeInterval * 1000]
                                             extra:({
                NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                [extra setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
                [extra setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
                [extra setValue:@(self.detailModel.article.groupModel.aggrType) forKey:@"aggr_type"];
                [extra setValue:self.detailModel.adID forKey:@"ad_id"];
                [extra setValue:photoType forKey:@"type"];
                [extra copy];
            })];
        }
    }
}

#pragma mark -- Gallary Index
- (NSUInteger)maximumVisibleIndex {

    if (self.nativeDetailView) {
        return self.nativeDetailView.maximumVisibleIndex;
    }
    else {
        return self.showedCountOfImage;
    }
}

- (NSUInteger)currentVisibleIndex {
    if (self.nativeDetailView) {
        return self.nativeDetailView.currentVisibleIndex;
    }
    else {
        return self.currentShowedImageIndex;
    }
}

#pragma mark -- refreshToolBarAlpha

- (void)refreshTitleBarAdWithOritation:(UIInterfaceOrientation)fromOrientation
{
    if (fromOrientation == UIDeviceOrientationLandscapeLeft ||
        fromOrientation == UIDeviceOrientationLandscapeRight) {

        BOOL showRecommend = self.imagePositionType == TTPhotoDetailImagePositon_Recom ? YES:NO;

        [self refreshTitleBarAdAlpha:showRecommend fromScroll:NO];
    }
    else {

        self.titleBarADView.alpha = 0;
        self.topView.avatarView.alpha = 1;
    }
}

- (void)refreshTitleBarAdAlpha:(BOOL)showRecommend fromScroll:(BOOL)didScroll
{
    //title_bar广告显示控制
    NSNumber *adID = [self.titleADDic objectForKey:@"id"];
    NSString *adExtraString = [self.titleADDic objectForKey:@"log_extra"];
    NSData *adExtraData = [adExtraString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *adExtraDic = [NSDictionary new];
    if (adExtraData) {
        adExtraDic = [NSJSONSerialization JSONObjectWithData:adExtraData options:NSJSONReadingMutableContainers error:nil];
    }
    NSString *trackUrl = [self.titleADDic objectForKey:@"track_url"];
    NSArray *trackUrlList = [self.titleADDic objectForKey:@"track_url_list"];
    NSUInteger currentIndex = [self currentVisibleIndex];

    //用于处理屏幕旋转引起的视图虚假滑动
    if (!didScroll) {
        currentIndex = self.currentRealIndex;
    }
    else {
        self.currentRealIndex = currentIndex;
    }

    if (currentIndex == 1) {
        self.titleBarADView.alpha = 0;
        self.topView.avatarView.alpha = 1;
    }
    else if (currentIndex == 2) {

        BOOL isLandScale = ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft ||
                             [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight);

        if (!self.hasCheckAdLoadFinish && !self.hasMakeStepAfterTwo && !isLandScale) {
            self.hasCheckAdLoadFinish = YES;
            if (self.hasImageDownload) {
                self.titleBarADView.alpha = 1;
                self.topView.avatarView.alpha = 0;

                [self.tracker tt_trackTitleBarAdWithTag:@"title_bar" label:@"show" value:adID.stringValue extraDic:adExtraDic];
                TTAdBaseModel *adBaseModel = [[TTAdBaseModel alloc] init];
                adBaseModel.ad_id = [adID stringValue];
                if (trackUrlList.count > 0) {
//                    [[SSURLTracker shareURLTracker] trackURLs:trackUrlList];
                    ttTrackURLs(trackUrlList);
                }
                else {
                    ttTrackURL(trackUrl);
//                    [[SSURLTracker shareURLTracker] trackURL:trackUrl];
                }
            }
        }

        if (self.hasCheckAdLoadFinish) {
            self.titleBarADView.alpha = @(self.hasImageDownload).floatValue;
            self.topView.avatarView.alpha = @(!self.hasImageDownload).floatValue;;
            self.titleBarADView.alpha = @(!showRecommend).floatValue;
        }

    }
    else if (currentIndex > self.detailModel.article.galleries.count)
    {
        self.titleBarADView.alpha = 0;
        self.hasMakeStepAfterTwo = YES;

    }
    else {

        if (self.hasCheckAdLoadFinish) {
            self.titleBarADView.alpha = @(self.hasImageDownload).floatValue;
            self.topView.avatarView.alpha = @(!self.hasImageDownload).floatValue;
            self.titleBarADView.alpha = @(!showRecommend).floatValue;
        }

        self.hasMakeStepAfterTwo = YES;
    }

    //横屏不展示
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ||
        [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {

        self.titleBarADView.alpha = 0;
        if (!showRecommend) {
            self.topView.avatarView.alpha = 1;
        }
    }
    //统一处理广告页和推荐图集页titleBarADView隐藏，currentIndex不对，后期得去掉
    if (self.imagePositionType == TTPhotoDetailImagePositon_Recom||self.imagePositionType == TTPhotoDetailImagePositon_Ad) {
        self.titleBarADView.alpha = 0;
    }
}

- (void)refreshToolBarAlpha {

    if ([TTDeviceHelper isPadDevice]) {
        //是否在推荐图集index
        if (self.imagePositionType == TTPhotoDetailImagePositon_Recom) {
            self.toolbarView.alpha = 1;
        }
        else if (self.imagePositionType == TTPhotoDetailImagePositon_NormalImage){

            if (!self.tapOn) {
                self.toolbarView.alpha = 1;
            }
            else {
                self.toolbarView.alpha = 0;
            }
        }
        else //ad
        {
            self.toolbarView.alpha = 0;
        }
    }
    else {
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {//横屏
            //是否在推荐图集index
            if (self.imagePositionType == TTPhotoDetailImagePositon_Recom) {
                self.toolbarView.alpha = 1;
            }
            else if (self.imagePositionType == TTPhotoDetailImagePositon_NormalImage){
                self.toolbarView.alpha = 0;
            }
            else
            {
                self.toolbarView.alpha = 0;
            }
        }
        else {//竖屏
            //是否在推荐图集index
            if (self.imagePositionType == TTPhotoDetailImagePositon_Recom) {
                self.toolbarView.alpha = 1;
            }
            else if (self.imagePositionType == TTPhotoDetailImagePositon_NormalImage){
                if (!self.tapOn) {
                    self.toolbarView.alpha = 1;
                }
                else {
                    self.toolbarView.alpha = 0;
                }
            }
            else //ad
            {
                self.toolbarView.alpha = 0;
            }
        }
    }

}

- (void)refreshCommentViewFrame {
    self.commentViewController.originRect = self.view.frame;
}
-(void)hideMoreActivityView
{
    [self hiddenMoreSettingActivityView];
}

#pragma mark - Impression

- (void)impressionStart4ImageRecommend
{
    [self recordImpression4VisibleItemsWithStatus:SSImpressionStatusRecording];
}

- (void)impressionEnd4ImageRecommend
{
    [self recordImpression4VisibleItemsWithStatus:SSImpressionStatusEnd];
}

- (void)recordImpression4VisibleItemsWithStatus:(SSImpressionStatus)status
{
    if (self.recommendImageInfoArray.count <= 0) {
        return;
    }
    __weak typeof(self) wself = self;
    [self.recommendImageInfoArray enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull imgInfoDic, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(wself) self = wself;
        Article *article = [imgInfoDic valueForKey:@"article"];
        if ([article isKindOfClass:[Article class]]) {
            [self recordImpressionWithRelatedArticleGroupModel:article.groupModel impressionStatus:status];
        }
    }];
}

- (void)recordImpressionWithRelatedArticleGroupModel:(TTGroupModel *)rGroupModel impressionStatus:(SSImpressionStatus)status
{
    NSString *groupId = rGroupModel.groupID;
    NSString *itemId  = rGroupModel.itemID;

    if (isEmptyString(groupId) || isEmptyString(itemId)) {
        return;
    }

    NSString *keyName = [NSString stringWithFormat:@"%@_%@", self.detailModel.article.groupModel.groupID, self.detailModel.article.groupModel.itemID];
    NSString *itemID = [NSString stringWithFormat:@"%@_%@", groupId, itemId];
    NSDictionary *extraDict = @{@"item_id":     itemId,
                                @"aggr_type":   @(rGroupModel.aggrType)
                                };

    [[SSImpressionManager shareInstance] recordImageRecommendImpressionWithKeyName:keyName
                                                                            status:status
                                                                            itemID:itemID
                                                                          userInfo:@{@"extra":extraDict}];
}


#pragma mark -- Helper

- (BOOL)isCurrentOrientationLandScape {
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft
            || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight);
}

//来源-[TTDetailModel shouldBeginShowComment]
- (BOOL)shouldBeginShowComment {
    NSDictionary *params = self.detailModel.baseCondition;
    
    BOOL beginShowComment = [params tt_boolValueForKey:@"showcomment"];
    BOOL beginShowCommentUGC = [params tt_boolValueForKey:@"showCommentUGC"];
    return beginShowComment || beginShowCommentUGC;
}

#pragma safeInset

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets safeInset = self.view.safeAreaInsets;
    if (safeInset.top > 0 || [TTDeviceHelper isIPhoneXDevice]){
        self.topView.height = safeInset.top + 44;
        self.webGalleryTopBgView.height = self.topView.height;
    }
}

@end

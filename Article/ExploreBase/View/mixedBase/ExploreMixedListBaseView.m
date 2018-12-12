//
//  ExploreMixedListBaseView.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-14.
//
//

#import "ExploreMixedListBaseView.h"
#import <TTAccountBusiness.h>
#import "Article.h"
#import "WapData.h"
#import "HuoShan.h"
#import "LastRead.h"
#import <TTRoute/TTRoute.h>
#import "StockData.h"
#import "Card+CoreDataClass.h"
#import "LianZai.h"
#import "TTCategoryDefine.h"
#import "TSVShortVideoOriginalData.h"
//#import "RecommendUserCardsData.h"
//#import "RecommendUserLargeCardData.h"
//#import "MomentsRecommendUserData.h"
#import "ExploreFetchListManager.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreFetchListDefines.h"
#import "ExploreArticleCardCell.h"
#import "NewsListLogicManager.h"
#import "ExploreArticleWebCellView.h"
#import "ArticleListNotifyBarView.h"
#import "NetworkUtilities.h"
#import "NewsDetailConstant.h"
#import "TTArticleCategoryManager.h"
#import "ExploreCellHelper.h"
#import "ExploreMixListDefine.h"
#import "NewsDetailLogicManager.h"
#import "NewsFetchArticleDetailManager.h"
#import "ExploreItemActionManager.h"
#import "ArticleCityViewController.h"
#import "ExploreLogicSetting.h"
#import "TTIndicatorView.h"
#import "SSTipModel.h"
#import "WDBaseCell.h"
#import "EXTKeyPathCoding.h"
#import "TTReachability.h"
#import "TTArticleTabBarController.h"
#import "TTFeedPreloadTask.h"
//#import "SurveyListData.h"
//#import "SurveyPairData.h"
//#import "FantasyCardData.h"

#import "ExploreListHelper.h"
#import "SSImpressionManager.h"
#import "ArticleImpressionHelper.h"

#import "TTTrackerWrapper.h"

#import "TTFeedDislikeView.h"
#import "ArticleUpdateManager.h"
#import "ExploreMovieView.h"

#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "TTSubEntranceBar.h"
#import "TTSubEntranceObj.h"
#import "TTSubEntranceManager.h"
#import "SSActionManager.h"
#import "TTPGCFetchManager.h"
#import "TTVideoAutoPlayManager.h"

#import "NewsBaseDelegate.h"
#import "UIViewController+NavigationBarStyle.h"

#import "TTLocationManager.h"
#import "TTVideoPGCBar.h"

#import "PGCAccountManager.h"

#import "TTModuleBridge.h"
#import "NSDictionary+TTAdditions.h"

#import "TTUGCDefine.h"
#import "TTURLTracker.h"
#import <TTTracker/TTTrackerProxy.h>

#import "ExploreMixedListBaseView+TrackEvent.h"
#import "ExploreMixedListBaseView+HeaderView.h"
#import "ExploreMixedListBaseView+Monitor.h"
#import "ExploreMixedListBaseView+LastRead.h"
#import "ExploreMixedListBaseView+Concern.h"
#import "TTAuthorizeHintView.h"

#import "NSObject+MultiDelegates.h"
#import "TTURLUtils.h"
#import "TTRNBridge.h"

#import "TTStringHelper.h"
#import "NSObject+TTAdditions.h"

//#import "Live.h"
//#import "Thread.h"
#import "ExploreEntryManager.h"
#import "UIImage+TTThemeExtension.h"

#import "TTRNView.h"
#import "NSObject+FBKVOController.h"
#import "TTLayOutCellViewBase.h"
#import <Crashlytics/Crashlytics.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import "ArticleURLSetting.h"
//#import "TTForumCellHelper.h"
#import "TTSearchHomeSugModel.h"

#import "TTUIResponderHelper.h"
#import "ExploreArticleCellView.h"
#import "TTTrackInitTime.h"
#import "TTInfiniteLoopFetchNewsListRefreshTipManager.h"
#import "TTCategoryBadgeNumberManager.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTPlatformSwitcher.h"
#import "TTFeedCollectionViewController.h"
#import "TTLoginDialogStrategyManager.h"
#import "TTVPlayVideo.h"
#import "TTVFullscreenProtocol.h"
#import "TTArticleSearchManager.h"
#import "TTFeedGuideView.h"
#import "ExploreMixedListSuggestionWordsView.h"

#import <TTServiceKit/TTServiceCenter.h>
#import "TTVAutoPlayManager.h"
#import "TTAuthorizeManager.h"
#import "TTFreeFlowTipManager.h"

#import "ExploreBaseADCell.h"
#import "ExploreOrderedData+TTAd.h"
#import "SSADEventTracker.h"
#import "TTADBaseCell.h"
#import "TTAdFeedModel.h"
//#import "SSADManager.h"
#import "TTAdSplashMediator.h"
#import "TTAdImpressionTracker.h"
#import "TTAdManager.h"
#import "TTAdManagerProtocol.h"
#import "TTAdSiteWebPreloadManager.h"
#import "TTAppLinkManager.h"

#import "NewsListTipsReminderView.h"
#import "TTLayOutNewLargePicCell.h"
//#import "TTHashtagCardData.h"

#import <TTDialogDirector/TTDialogDirector.h>
//f100
//#import <TTDialogDirector/CLLocationManager+MutexDialogAdapter.h>
#import <TTDialogDirector/TTDialogDirector+ClientAB.h>
//#import "RecommendRedpacketData.h"
//#import "FRThreadSmartDetailManager.h"
#import "TTKitchenHeader.h"
#import "TTVOwnPlayerPreloaderWrapper.h"
#import "TTVSettingsConfiguration.h"
//#import "TTFollowCategoryFetchExtraManager.h"
#import "TTTabBarProvider.h"
#import "Article+TTADComputedProperties.h"
#import "TTASettingConfiguration.h"
#import "TTVVideoDetailViewController.h"
#import "FHHomeConfigManager.h"
#import "FHFeedHouseCellHelper.h"
#import "FHFeedHouseItemCell.h"
#import "Bubble-Swift.h"

#define kPreloadMoreThreshold           10
#define kInsertLastReadMinThreshold     5
#define kMaxLastReadLookupInterval      (24 * 60 * 60 * 1000)  //毫秒
#define kShowOldLastReadMinThreshold    60      //超过60篇旧文章后才可能显示“以下为24小时前的文章”

const NSUInteger ExploreMixedListBaseViewSectionFHouseCells = 0;
//const NSUInteger ExploreMixedListBaseViewSectionFHouseCells = 0;
//const NSUInteger ExploreMixedListBaseViewSectionFunctionAreaCells = 1;
const NSUInteger ExploreMixedListBaseViewSectionExploreCells = 1;

void tt_listView_preloadWebRes(Article *article, NSDictionary *rawAdData) {
    if (article) {
        ExploreOrderedData *orderedData = [[ExploreOrderedData alloc] initWithArticle:article];
        orderedData.raw_ad_data = rawAdData;
        [TTAdManageInstance preloadWebRes_preloadResource:orderedData];
    }
}

@implementation LOTAnimationView (Refresh)
- (void)startLoadingAnimation
{
    if (!self.isAnimationPlaying) {
        [self play];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (frame.size.width * frame.size.height < 1) {
        [self stop];
    }
}
@end

@interface ExploreMixedListBaseView()
<
UITableViewDataSource,
UITableViewDelegate,
SSImpressionProtocol,
UIViewControllerErrorHandler,
TTAccountMulticastProtocol,
TTRefreshViewDelegate
> {
    
    /**
     *  收到账户变更信息后，需要刷新列表，默认是NO
     */
    BOOL _accountChangedNeedReadloadList;
    BOOL _isShowing;
    BOOL _isNewFeedImpressionEnabled;
    BOOL _isShowWithScenesEnabled;
}
/**
 *  保存外部传递的condition
 */
@property(nonatomic, retain)NSDictionary * externalRequestCondtion;
@property(nonatomic, assign)NSUInteger loadMoreCount;
@property(nonatomic, retain, readwrite)ExploreFetchListManager * fetchListManager;

@property(nonatomic, retain)NSTimer *preloadTimer;
@property(nonatomic, retain)ExploreItemActionManager * itemActionManager;

@property (nonatomic, strong) NSDate *disappearDate;

@property(nonatomic, assign) BOOL isLastReadRefresh;

/**
 *  用于保存不感兴趣的数据.
 *  点击不敢兴趣按钮后,会出现蓝条，点击蓝条的撤销， 需要恢复，该字段保存该临时变量。
 *  蓝条消失后，该字段变为nil
 */
@property(nonatomic, retain)ExploreOrderedData * notInterestingData;


//是否是app启动后首次获取列表
@property(nonatomic, assign)BOOL isFirstRefreshListAfterLaunch;
/**
 *  用于保存上次看到这的数据.
 *  上次看到这消失后，该字段变为nil
 *  上次看到这出现后，临时保存
 */
@property(nonatomic, retain)ExploreOrderedData * lastReadOrderData;
@property(nonatomic, retain)LastRead * lastReadData;

@property(nonatomic, assign)BOOL isLastReadInDB;   //数据库中有lastread

// 网络切换时，分离cell中的movieView
@property(nonatomic, strong)id movieView;
@property(nonatomic, strong)ExploreOrderedData *movieViewCellData;

//@property(nonatomic, strong)NSDictionary *concernInfo;


//请求影评详情页视频Tab时的参数
@property(nonatomic, assign)NSUInteger movieCommentVideoAPIOffset;

//垂直通用视频API offset参数
@property(nonatomic, assign)NSUInteger verticalVideoAPIOffset;

//记录是否是从列表页点击cell离开列表
@property(nonatomic, assign)BOOL isClickCellLeaveList;

@property(nonatomic, assign) CGFloat scrollViewOffsetY;
@property(nonatomic, assign) BOOL hasHitPushed;
@property(nonatomic, strong) NewsListTipsReminderView *remindView;

@property(nonatomic, assign) BOOL refreshButtonTemporaryHide;
@property(nonatomic, strong) NSMutableArray *movieViews;
@property(nonatomic, assign) BOOL isPlayerOnRotateAnimation;
@property(nonatomic, assign) BOOL readyToReload;

@property (nonatomic, weak) TTFeedGuideView *feedGuideView;
@property(nonatomic, strong) UIView *adRefreshAnimationView;
@property(nonatomic, strong) dispatch_source_t silentFetchTimer;
@property(nonatomic, assign) BOOL isSilentFetchTimerFired;
@property(nonatomic, assign) BOOL isScrolling;
@property(nonatomic, assign) BOOL isInBackground;
@property(nonatomic, assign) BOOL isFeedTipsShowStrategyEnable;
@property(nonatomic, assign) BOOL shouldReloadBackAfterLeaveCurrentCategory;
@property(nonatomic, assign) BOOL isPerformingReloadData;

@property(nonatomic, retain) ExploreMixedListSuggestionWordsView *suggestionWordsView;
@property(nonatomic, assign) CGRect defaultRect;

@property(nonatomic, strong) NSMutableDictionary *cellIdDict;
@end

@implementation ExploreMixedListBaseView

+ (void)load
{
    /**
     *  返回一个mixedbase列表
     *
     *  @param params   NSString *frame, //NSStringFromCGRect得到的NSString
     NSUInteger listType // 列表类型ExploreOrderedDataListType
     *
     *  @return @{
     @"mixedBaseListView":view,
     @"tableView":view.listView
     }
     */
    [[TTModuleBridge sharedInstance_tt] registerAction:@"GetMixedBaseListView" withBlock:^id(id object, NSDictionary *params) {
        CGRect frame = CGRectZero;
        ExploreOrderedDataListType listType = ExploreOrderedDataListTypeCategory;
        ExploreOrderedDataListLocation listLocation = ExploreOrderedDataListLocationCategory;
        ExploreFetchListApiType apiType = ExploreFetchListApiTypeStream;
        NSString *categoryID = nil;
        NSString *concernID = nil;
        NSString *movieCommentVideoID = nil;
        NSString *movieCommentEntireID = nil;
        NSString *concernName = nil;
        
        if ([params isKindOfClass:[NSDictionary class]]) {
            NSString *rectStr = [params valueForKey:@"frame"];
            if (!isEmptyString(rectStr)) {
                frame = CGRectFromString(rectStr);
            }
            
            listType = [params tt_unsignedIntegerValueForKey:@"listType"];
            listLocation = [params tt_unsignedIntegerValueForKey:@"listLocation"];
            apiType = [params tt_unsignedIntegerValueForKey:@"apiType"];
            categoryID = [params valueForKey:@"categoryID"];
            concernName = [params valueForKey:@"concernName"];
            concernID = [params valueForKey:@"concernID"];
            movieCommentVideoID = [params valueForKey:@"movieCommentVideoID"];
            movieCommentEntireID = [params valueForKey:@"movieCommentEntireIDKey"];
        }
        ExploreMixedListBaseView *view = [[ExploreMixedListBaseView alloc] initWithFrame:frame listType:listType listLocation:listLocation];
        view.apiType = apiType;
        
        if (!isEmptyString(categoryID)) {
            view.categoryID = categoryID;
        } else {
            view.categoryID = @"";
        }
        if (!isEmptyString(concernID)) {
            view.concernID = concernID;
            //            if (isEmptyString(categoryID)) {
            //                view.categoryID = concernID;
            //            }
        } else {
            view.concernID = @"";
        }
        if (!isEmptyString(concernName)) {
            view.concernName = concernName;
        }
        
        view.movieCommentVideoID = !isEmptyString(movieCommentVideoID) ? movieCommentVideoID : nil;
        view.movieCommentEntireID = !isEmptyString(movieCommentEntireID) ? movieCommentEntireID : nil;
        
        NSUInteger refer = [[params objectForKey:@"refer"] unsignedIntegerValue];
        if (refer != 1 && refer != 2 ) {
            //refer数值非法（1.频道主页，2.关心主页）
            refer = 1;
        }
        view.refer = refer;
        view.specialConcernPage = [params tt_boolValueForKey:@"specialConcernPage"];
        
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setValue:view forKey:@"mixedBaseListView"];
        [result setValue:view.listView forKey:@"tableView"];
        
        return result;
    }];
    
    /**
     *  下拉刷新mixedbase列表
     *
     *  @param params params字典,包含mixedbase列表(对应key：mixedBaseListView)
     *
     *  @return nil
     */
    [[TTModuleBridge sharedInstance_tt] registerAction:@"PullAndRefreshMixedBaseList" withBlock:^id(id object,NSDictionary * params) {
        
        ExploreMixedListBaseView *mixedListBaseView = object;
        if ([mixedListBaseView isKindOfClass:[ExploreMixedListBaseView class]]) {
            [mixedListBaseView pullAndRefresh];
        }
        return nil;
    }];
    
    /**
     *  在父类dealloc中调用,ugly code ， 不掉用有内存问题，之后修复
     *
     */
    [[TTModuleBridge sharedInstance_tt] registerAction:@"mixedBaseListRemoveDelegates" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        
        ExploreMixedListBaseView *mixedListBaseView = object;
        if ([mixedListBaseView isKindOfClass:[ExploreMixedListBaseView class]]) {
            [mixedListBaseView removeDelegates];
        }
        
        return nil;
    }];
}

- (void)dealloc
{
    [self.KVOController unobserve:_listView.pullDownView];
    [self removeDelegates];
    
    [_fetchListManager cancelAllOperations];
    
    [_listView tt_removeAllDelegates];
    
    _listView.delegate = nil;
    _listView.dataSource = nil;
    [self dismissCityPopoverAnimated:NO];
    
    [self removeNotifications];
    
    if (self.silentFetchTimer) {
        dispatch_source_cancel(self.silentFetchTimer);
        self.silentFetchTimer = nil;
    }
}

- (id)initWithFrame:(CGRect)frame listType:(ExploreOrderedDataListType)listType listLocation:(ExploreOrderedDataListLocation)listLocation
{
    self = [super initWithFrame:frame];
    if (self) {
        _loadMoreCount = 0;
        _isDisplayView = YES;
        _listType = listType;
        _listLocation = listLocation;
        _apiType = ExploreFetchListApiTypeStream;
        _refer = 1;//默认是频道主页
        _isClickCellLeaveList = NO;
        _isShowing = YES;
        _isNewFeedImpressionEnabled = [SSCommonLogic isNewFeedImpressionEnabled];
        _isFeedTipsShowStrategyEnable = [SSCommonLogic feedTipsShowStrategyEnable];
        _isShowWithScenesEnabled = [SSCommonLogic showWithScensEnabled];
        
        CGRect rect = [self frameForListView];
        self.listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height - 0) style:UITableViewStylePlain];
        self.ttErrorToastView = [ArticleListNotifyBarView addErrorToastViewWithTop:self.ttContentInset.top width:self.width height:[SSCommonLogic articleNotifyBarHeight]];
        self.listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.separatorColor = [UIColor clearColor];
//        _listView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor whiteColor];
        _listView.backgroundColor = [UIColor whiteColor];
        _listView.backgroundView = nil;
        _listView.estimatedRowHeight = 0;
        _listView.estimatedSectionHeaderHeight = 0;
        _listView.estimatedSectionFooterHeight = 0;
        _listView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 0.1)]; //to do:设置header0.1，防止系统自动设置高度
        _listView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 0.1)]; //to do:设置header0.1，防止系统自动设置高度
        _listView.sectionHeaderHeight = 0;
        _listView.sectionFooterHeight = 0;
//        _listView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0);
        
        
        
        if (@available(iOS 11.0, *)) {
        _listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        
        [ExploreCellHelper registerAllCellClassWithTableView:_listView];
//        _listView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_listView];
        
        self.fetchListManager = [[ExploreFetchListManager alloc] init];
        
        [self registNotifications];
        
        [[SSImpressionManager shareInstance] addRegist:self];
        [self themeChanged:nil];
        
        [self addPullDownRefreshView];
        
        self.movieViews = [NSMutableArray array];
        self.cellIdDict = [NSMutableDictionary dictionary];

        WeakSelf;
        [[NSNotificationCenter defaultCenter] addObserverForName:kTTVPlayerIsOnRotateAnimation object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            StrongSelf;
            NSDictionary *dic = [note userInfo];
            NSNumber *value = [dic valueForKey:@"isAnimating"];
            if ([value isKindOfClass:[NSNumber class]]) {
                self.isPlayerOnRotateAnimation = [value boolValue];
            }
            if (!self.isPlayerOnRotateAnimation && self.readyToReload) {
                [self reloadListViewWithVideoPlaying];
                self.readyToReload = NO;
            }
        }];
        
        if (_isFeedTipsShowStrategyEnable) {
            NewsListTipsReminderViewType type = [SSCommonLogic feedTipsShowStrategyType];
            NewsListTipsReminderViewColor color = [SSCommonLogic feedTipsShowStrategyColor];
            self.remindView = [[NewsListTipsReminderView alloc] initWithSize:CGSizeMake(160, 32) andType:type andColor:color];
            self.remindView.text = @"";
            self.remindView.delegate = self;
            self.remindView.appearActionBlock = ^(BOOL finished){
                StrongSelf;
                [self clearTipCount];
            };
            if ([[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey]) {
                self.remindView.enabled = YES;
            }
            
            [self addSubview:self.remindView];
        }
        
        _defaultRect = [self frameForListView];

        if ([SSCommonLogic feedLoadingInitImageEnable]) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"refresh" ofType:@"json" inDirectory:@"RefreshAnimation.bundle"];
            _animationView = [LOTAnimationView animationWithFilePath:filePath];
            _animationView.contentMode = UIViewContentModeScaleToFill;
            _animationView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
            _animationView.loopAnimation = YES;
        }
        
        [[FHHomeConfigManager sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
            StrongSelf;
            [self reloadFHHomeHeaderCell];
        }];
    }
    return self;
}

- (void)reloadFHHomeHeaderCell
{
    if ([_categoryID isEqualToString:@"f_house_news"]) {
        [self.listView reloadSections:[NSIndexSet indexSetWithIndex:ExploreMixedListBaseViewSectionFHouseCells] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)setupSilentFetchTimer
{
    NSTimeInterval period = [SSCommonLogic feedAutoInsertTimeInterval] / 1000.;
    self.silentFetchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.silentFetchTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    WeakSelf;
    dispatch_source_set_event_handler(self.silentFetchTimer, ^{
        StrongSelf;
        if (!self.isScrolling && [self.fetchListManager canSilentFetchItems] && [self isNewTab] && !self.isInBackground) {
            [self trySilentFetchIfNeeded];
        }
    });
    dispatch_source_set_cancel_handler(self.silentFetchTimer, ^{
        StrongSelf;
        self.silentFetchTimer = nil;
    });
}

- (void)tryInsertSilentFetchedItem
{
    [_fetchListManager tryInsertSilentFetchedItem];
    [self reloadListViewWithVideoPlaying];
}

- (void)trySilentFetchIfNeeded
{
    if ([self isNewTab]) {
        [self trySilentFetch];
    }
    
    // 下面是静默插入的另一种方案
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([SSCommonLogic feedAutoInsertTimeInterval] * NSEC_PER_SEC / 1000.)), dispatch_get_main_queue(), ^{
    //        if (!self.isScrolling && [_fetchListManager canSilentFetchItems]) {
    //            [self trySilentFetchIfNeeded];
    //        }
    //    });
}

- (void)trySilentFetch
{
    [_fetchListManager updateLastSilentFetchTime];
    
    BOOL fromLocal = NO, fromRemote = YES, getMore = YES;
    
    NSMutableDictionary * exploreMixedListConsumeTimeStamps = [NSMutableDictionary dictionary];
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListTriggerRequestTimeStampKey];
    
    [_fetchListManager reuserAllOperations];
    
    NSMutableDictionary *condition = [NSMutableDictionary dictionaryWithDictionary:_externalRequestCondtion];
    
    // 有频道ID，没有关心ID
    if (!isEmptyString(_categoryID)) {
        if (isEmptyString(_concernID)) {
            // 从频道model里取关心ID
            TTCategory *categoryModel = [TTArticleCategoryManager categoryModelByCategoryID:_categoryID];
            _concernID = categoryModel.concernID;
        }
    }else {
        _categoryID = @"";
    }
    
    if (isEmptyString(_concernID)) {
        _concernID = @""; // 加保护，确保保存ExploreOrderedData时，主键不为nil
    }
    
    [condition setValue:_categoryID forKey:kExploreFetchListConditionListUnitIDKey];
    [condition setValue:_concernID forKey:kExploreFetchListConditionListConcernIDKey];
    [condition setValue:@(_apiType) forKey:kExploreFetchListConditionApiType];
    [condition setValue:@(_refer) forKey:kExploreFetchListConditionListReferKey];
    [condition setValue:self.movieCommentVideoID forKey:kExploreFetchListConditionListMovieCommentVideoIDKey];
    [condition setValue:self.movieCommentEntireID forKey:kExploreFetchListConditionListMovieCommentEntireIDKey];
    [condition setValue:exploreMixedListConsumeTimeStamps forKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
    
    [condition setValue:@(_refreshFromType) forKey:kExploreFetchListConditionReloadFromTypeKey];
    if(!getMore) {
        _loadMoreCount = 0;
        self.movieCommentVideoAPIOffset = 0;
        [condition setValue:@(0) forKey:kExploreFetchListConditionVerticalVideoAPIOffsetKey];
    }else {
        [condition setValue:@(self.verticalVideoAPIOffset) forKey:kExploreFetchListConditionVerticalVideoAPIOffsetKey];
    }
    
    [condition setValue:@(self.movieCommentVideoAPIOffset) forKey:kExploreFetchListConditionListMovieCommentVideoAPIOffsetKey];
    [condition setValue:@(_loadMoreCount) forKey:kExploreFetchListConditionLoadMoreCountKey];
    
    NSNumber *lastReadOrderIndex = nil;
    lastReadOrderIndex = [self handleLastReadBeforeRefreshIfNeeded:getMore fromRemote:fromRemote];
    
    [condition setValue:@(1) forKey:kExploreFetchListSilentFetchFromRemoteKey];
    
    __weak ExploreMixedListBaseView * weakSelf = self;
    [_fetchListManager startExecuteWithCondition:condition
                                       fromLocal:fromLocal
                                      fromRemote:fromRemote
                                         getMore:getMore
                                    isDisplyView:_isDisplayView
                                        listType:_listType
                                    listLocation:_listLocation
                                     finishBlock:^(NSArray *increaseItems, id operationContext, NSError *error) {
                                         if ([weakSelf isNewTab] && increaseItems.count > 0 && !error) {
                                             [weakSelf tryInsertSilentFetchedItem];
                                         }
                                     }];
}

- (void)addPullDownRefreshView
{
    //nick add for new refresh util
    _listView.hasMore = NO;
    
    NSString *loadingText = [SSCommonLogic isNewPullRefreshEnabled] ? nil : @"推荐中";
    __weak typeof(self) wself = self;
    [_listView addPullDownWithInitText:@"下拉推荐"
                              pullText:@"松开推荐"
                           loadingText:loadingText
                            noMoreText:@"暂无新数据"
                              timeText:nil
                           lastTimeKey:nil
                         actionHandler:^{
                             if (wself.listView.pullDownView.isUserPullAndRefresh) {
                                 /*
                                  *这里故意没有使用wself，修复自动化测试在ios9上crash的问题
                                  *                                       --yingjie
                                  */
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixedListRefreshTypeNotification object:self userInfo:@{@"refresh_reason" : @(ExploreMixedListRefreshTypeUserPull)}];
                                 
                                 if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                                     [wself trackEventForLabel:[wself modifyEventLabelForRefreshEvent:@"refresh_pull"]];
                                 }
                                 //log3.0
                                 [wself trackRefershEvent3ForLabel:@"pull"];
                                 wself.refreshFromType = ListDataOperationReloadFromTypePull;
                             }
                             if (wself.remindView) {
                                 [wself.remindView refreshAndHide];
                             }
                             [wself fetchFromLocal:![wself tt_hasValidateData] fromRemote:YES getMore:NO];
                             if (![FHHomeConfigManager sharedInstance].currentDataModel)
                             {
                                 if ([[EnvContext shared] respondsToSelector:@selector(client)] && [[[EnvContext shared] client] respondsToSelector:@selector(onStart)]) {
                                     [[[EnvContext shared] client] onStart];
                                 }
                             }
                         }];
    CGFloat barH = [SSCommonLogic articleNotifyBarHeight];
    self.ttMessagebarHeight = barH;
    if ([SSCommonLogic isNewPullRefreshEnabled]) {
        _listView.pullDownView.pullRefreshLoadingHeight = barH;
        _listView.pullDownView.messagebarHeight = barH;
    }
    @weakify(self);
    [self.KVOController unobserve:_listView.pullDownView];
    [self.KVOController observe:_listView.pullDownView keyPath:@keypath(_listView.pullDownView,  state) options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        @strongify(self);
        if (self.listView.pullDownView.state == PULL_REFRESH_STATE_LOADING && [self isVideoBusiness]) {
            [self didFinishLoadTable];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:self.categoryID forKey:@"category_id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kTTRefreshViewBeginRefresh" object:nil userInfo:dic];
        }
    }];
    
    [_listView tt_addDefaultPullUpLoadMoreWithHandler:^{
        __strong typeof(self) sself = wself;
        sself.refreshFromType = ListDataOperationReloadFromTypeLoadMore;
        [wself loadMoreWithUmengLabel:[wself modifyEventLabelForRefreshEvent:@"load_more"]];
    }];
}

- (void)didFinishLoadTable
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    NSArray *cells = [_listView visibleCells];
    NSMutableArray *visibleCells = [NSMutableArray arrayWithCapacity:cells.count];
    for (ExploreCellBase<ExploreMovieViewCellProtocol> *cellBase in cells) {
        if ([cellBase respondsToSelector:@selector(movieView)]) {
            UIView *view = [cellBase movieView];
            if (view) {
                [visibleCells addObject:view];
            }
        }
    }
    
    for (UIView *view in self.movieViews) {
        if ([view isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *movieView = (ExploreMovieView *)view;
            if (!movieView.isMovieFullScreen && !movieView.isRotateAnimating && ![visibleCells containsObject:movieView]) {
                if (![movieView isStoped]) {
                    [movieView stopMovie];
                }
                [movieView removeFromSuperview];
            }
        }
        
        if ([view isKindOfClass:[TTVPlayVideo class]]) {
            TTVPlayVideo *movieView = (TTVPlayVideo *)view;
            if (!movieView.player.context.isFullScreen &&
                !movieView.player.context.isRotating && ![visibleCells containsObject:movieView]) {
                if (movieView.player.context.playbackState != TTVVideoPlaybackStateBreak || movieView.player.context.playbackState != TTVVideoPlaybackStateFinished) {
                    [movieView stop];
                }
                [movieView removeFromSuperview];
            }
        }
    }
    
    self.movieViewCellData = nil;
    self.movieView = nil;
    [self.movieViews removeAllObjects];
}


- (void)willFinishLoadTable
{
    __unused __strong typeof(self) strongSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didFinishLoadTable) object:nil];
    [self performSelector:@selector(didFinishLoadTable) withObject:nil afterDelay:0.1];
}

- (void)removeDelegates
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [_fetchListManager resetManager];
    [[SSImpressionManager shareInstance] removeRegist:self];
    
    self.delegate = nil;
    [_preloadTimer invalidate];
    _preloadTimer = nil;
}

- (void)setIsDisplayView:(BOOL)isDisplayView
{
    if (isDisplayView == _isDisplayView) {
        return;
    }
    _isDisplayView = isDisplayView;
    
    if (![TTExploreMainViewController isNewFeed]) {
        if (!_isDisplayView) {
            for (UITableViewCell * cell in  [_listView visibleCells]) {
                if ([cell isKindOfClass:[ExploreCellBase class]]) {
                    [((ExploreCellBase *)cell) cellInListWillDisappear:CellInListDisappearContextTypeChangeCategory];
                }
            }
        }
    }
}

- (void)setCategoryID:(NSString *)categoryID
{
//    if (!_suggestionWordsView) {
//        CGRect rect = [self frameForListView];
//        _suggestionWordsView = [[ExploreMixedListSuggestionWordsView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 44)];
//        if (self.superview) {
//            [self.superview addSubview:_suggestionWordsView];
//            [self.superview bringSubviewToFront:self];
//        }
//    }
    
    if (!isEmptyString(categoryID) && !isEmptyString(_categoryID) && [_categoryID isEqualToString:categoryID]) {
        return;
    }
    
    NSString * originalCID = [_categoryID copy];
    _categoryID = categoryID;
    
    if (![TTExploreMainViewController isNewFeed]) {
        //记录impression, 切换列表的时候，记录
        if (self.isDisplayView) {
            [[SSImpressionManager shareInstance] enterGroupViewForCategoryID:self.categoryID concernID:self.concernID refer:self.refer];
        }
        else {
            [[SSImpressionManager shareInstance] leaveGroupViewForCategoryID:self.categoryID concernID:self.concernID refer:self.refer];
        }
    }
//    [self categoryIDDidChange];

    if (originalCID && ![originalCID isEqualToString:_categoryID]) {
        [self clearListContent];
        [self reportDelegateCancelRequest];
    }
    
    if (self.remindView) {
        self.remindView.categoryID = categoryID;
    }
    
    [self setADRefreshView];
}

- (void)setADRefreshView{
    if (!self.adRefreshAnimationView) {
        
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        
        if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(refresh_createAnimateViewWithFrame:WithLoadingText:WithPullLoadingHeight:)]) {
            self.adRefreshAnimationView = [adManagerInstance refresh_createAnimateViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.listView.pullDownView.frame),CGRectGetHeight(self.listView.pullDownView.frame)) WithLoadingText:self.listView.pullDownView.refreshLoadingText WithPullLoadingHeight:self.listView.pullDownView.pullRefreshLoadingHeight];
        }
    }
    
    self.listView.pullDownView.delegate = self;
    
}

- (CGRect)frameForListView
{
    return self.bounds;
}

- (CGRect)defaultRect
{
    if ([TTDeviceHelper isPadDevice]) {
        return self.bounds;
    } else {
        return _defaultRect;
    }
}

- (void)registNotifications
{
    [TTAccount addMulticastDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCoreDataCacheClearedNotification:) name:kExploreClearedCoreDataCacheNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCacheNotification:) name:@"SettingViewClearCachdNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readModeChanged:) name:kReadModeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveItemDeleteNotification:) name:kExploreMixListItemDeleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePublishCommentWithZZNotification:) name:kTTPublishCommentSuccessWithZZNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteZZCommentNotification:) name:kTTDeleteZZCommentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotInterestNotification:) name:kExploreMixListNotInterestNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChanged:) name:kSettingFontSizeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCityDidChangedNotification:) name:kArticleCityDidChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRNCellActiveRefreshListNotification:) name:kTTRNCellActiveRefreshListViewNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(articleUpdated:) name:ArticleDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webCellUpdated:) name:kExploreWebCellDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(originalDataUpdate:) name:kExploreOriginalDataUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recommendChannelAutoUpdate:) name:kRecommendChannelAutoRefresh object:nil];
    
    if ([self needShowRemoteAutoTip]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveShowRemoteReloadTipNotification:) name:kNewsListFetchedRemoteReloadTipNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFetchRemoteReloadTipNotification:) name:kNewsListShouldFetchedRemoteReloadTipNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFirstRefreshTipNotification:) name:kFirstRefreshTipsSettingEnabledNotification object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseCity:) name:kExploreWebCellChooseCityNotification object:nil];
    
    // 发帖
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadSendingNotification:) name:kTTForumPostingThreadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadFailNotification:) name:kTTForumPostThreadFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadSuccessNotification:) name:kTTForumPostThreadSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFakeThreadNotification:) name:kTTForumDeleteFakeThreadNotification object:nil];
    //删帖
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteThreadNotification:) name:kTTForumDeleteThreadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteVideoNotification:) name:TTVideoDetailViewControllerDeleteVideoArticle object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteShortVideoNotification:) name:kTSVShortVideoDeleteNotification object:nil];
    
    //订阅状态变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeStatusChangedNotification:) name:kEntrySubscribeStatusChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBeComeactive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)didAppear
{
    [super didAppear];
    _isShowing = YES;
    
    if ([[TTVideoAutoPlayManager sharedManager] cachedAutoPlayingCellInView:self.listView]) {
        [[TTVideoAutoPlayManager sharedManager] restoreCellMovieIfCould];
    }
    
    if ([[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey] && !self.hasHitPushed && self.remindView) {
        self.remindView.enabled = YES;
        [self.remindView show:YES];
    } else {
        if ([[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey] && self.remindView) {
            self.remindView.enabled = YES;
        }
    }
    self.hasHitPushed = NO;
    
    if (!self.shouldReloadBackAfterLeaveCurrentCategory) {
        if ([[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey]) {
            NSDictionary *infoDic = [NewsListLogicManager newsListShowRefreshInfo];
            if (infoDic && [_fetchListManager items].count > 0) {
                self.refreshShouldLastReadUpate = YES;
                self.refreshFromType = ListDataOperationReloadFromTypeAuto;
                [self pullAndRefresh];
                
                [NewsListLogicManager setNewsListShowRefreshInfo:nil];
            }
        }
    }
    
    self.listView.backgroundColor = [UIColor whiteColor];
}

- (void)willAppear
{
    [super willAppear];
    _isShowing = YES;
    if (!self.categoryID && [SSCommonLogic shouldUseOptimisedLaunch]) {
        return;
    }
    
    if ([SSCommonLogic feedSearchEntryEnable]) {
        NSArray *subEntranceObjArray = [TTSubEntranceManager subEntranceObjArrayForCategory:self.categoryID concernID:self.concernID];
        SubEntranceType type = [TTSubEntranceManager subEntranceTypeForCategory:self.categoryID];
        if (type == SubEntranceTypeStick) {
            if (subEntranceObjArray && [subEntranceObjArray isKindOfClass:[NSArray class]] && subEntranceObjArray.count > 0) {
                [self.suggestionWordsView refreshWithData:subEntranceObjArray animated:NO superviewIsShowing:YES];
            } else {
                [self.suggestionWordsView refreshWithData:nil animated:NO superviewIsShowing:YES];
            }
        }
    }
    
    if ([TTExploreMainViewController isNewFeed]) {
        [[SSImpressionManager shareInstance] enterGroupViewForCategoryID:self.categoryID concernID:self.concernID refer:self.refer];
    } else {
        if (self.isDisplayView) {
            [[SSImpressionManager shareInstance] enterGroupViewForCategoryID:self.categoryID concernID:self.concernID refer:self.refer];
        }
    }
    _isFeedTipsShowStrategyEnable = [SSCommonLogic feedTipsShowStrategyEnable];
    _isShowWithScenesEnabled = [SSCommonLogic showWithScensEnabled];

    NSUInteger originalCount = [_fetchListManager.items count];
    [_fetchListManager refreshItemsForListType:_listType];

    
//    if ([self.categoryID isEqualToString:kTTFollowCategoryID] &&  [KitchenMgr getBOOL:kKUGCFollowCategoryClearUnFollowThreadEnable]) {
//        [_fetchListManager checkFollowCategoryFollowStatus];
//    }
    
    if ([_fetchListManager.items count] != originalCount) {
        [self reloadListView];
    }
    else if ([_fetchListManager.items count] > 0) {
        if ([SSCommonLogic shouldUseOptimisedLaunch]) {
            if (SharedAppDelegate.mainViewDidShow) {
                [self reloadVisibleCellsIfNeeded];
            }
        }else{
            [self reloadVisibleCellsIfNeeded];
        }
    }
    
    [self resumeTrackAdCellsInVisibleCells];
    
    self.shouldReloadBackAfterLeaveCurrentCategory = [self shouldReloadBackAfterLeaveCurrentCategory];
    
    //唤醒后刷新
    if ((self.shouldReloadBackAfterLeaveCurrentCategory && [_fetchListManager items].count > 0) || ([FHHomeConfigManager sharedInstance].isNeedTriggerPullDownUpdate && [_fetchListManager items].count > 0)) {
        self.refreshShouldLastReadUpate = YES;
        self.refreshFromType = ListDataOperationReloadFromTypeAuto;
        [self pullAndRefresh];
        
        [FHHomeConfigManager sharedInstance].isNeedTriggerPullDownUpdate = NO;
    }

    for (ExploreCellBase * cell in  [_listView visibleCells]) {
        if ([cell isKindOfClass:[ExploreCellBase class]]) {
            NSIndexPath *indexPath = [_listView indexPathForCell:cell];
            if (indexPath.row >= [self listViewMaxModelIndex]) {
                continue;
            }
            ExploreOrderedData *obj = [[_fetchListManager items] objectAtIndex:indexPath.row];
            if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                if ([cell isKindOfClass:[ExploreCellBase class]]) {
                    [cell willAppear];
                }
            }
        }
    }
    
    if ([[TTVAutoPlayManager sharedManager] cachedAutoPlayingCellInView:_listView]) {
        [[TTVAutoPlayManager sharedManager] continuePlayCachedMovie];
    }
    [[TTAdImpressionTracker sharedImpressionTracker] startTrackForce];
}

- (void)resumeTrackAdCellsInVisibleCells{
    if (!_listView) {
        return;
    }
    
    if (!_isShowing) {
        return;
    }
    
    TTExploreMainViewController *mainListView = [(NewsBaseDelegate *)[[UIApplication sharedApplication] delegate] exploreMainViewController];
    
    [[TTAdImpressionTracker sharedImpressionTracker] reset:self.listView];
    for (UITableViewCell * cell in  [_listView visibleCells]) {
        if ([cell isKindOfClass:[ExploreCellBase class]]) {
            NSIndexPath *indexPath = [_listView indexPathForCell:cell];
            if (indexPath.row >= [self listViewMaxModelIndex]) {
                continue;
            }
            ExploreOrderedData *obj = [[_fetchListManager items] objectAtIndex:indexPath.row];
            if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                if ([obj isAd]) {
                    NSString *ad_id = obj.ad_id;
    
                    if (_isShowWithScenesEnabled) {
                        // 不是切换频道的情况都是return
                        TTADShowScene scene = mainListView.isChangeChannel ? TTADShowChangechannelScene : TTADShowReturnScene;
                        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                        if (obj.adExtraData) {
                            [extra addEntriesFromDictionary:obj.adExtraData];
                        }
                        
                        [[SSADEventTracker sharedManager] willShowAD:ad_id scene:scene];
                        [[SSADEventTracker sharedManager] trackEventWithOrderedData:obj label:@"show" eventName:@"embeded_ad" extra:extra duration:0 scene:scene];
                    } else {
                        // TTADShowRefreshScene 用来占位，没实际意义
                        [[SSADEventTracker sharedManager] willShowAD:ad_id scene:TTADShowRefreshScene];
                    }

                    if ([SSCommonLogic videoVisibleEnabled] &&
                        (obj.cellFlag & ExploreOrderedDataCellFlagAutoPlay) &&
                        [cell conformsToProtocol:@protocol(TTVAutoPlayingCell)]) {
                        [[TTAdImpressionTracker sharedImpressionTracker] track:ad_id visible:cell.frame scrollView:self.listView movieCell:(id<TTVAutoPlayingCell>)cell];

                    } else {
                        [[TTAdImpressionTracker sharedImpressionTracker] track:ad_id visible:cell.frame scrollView:self.listView];
                    }
                    [(ExploreCellBase *)cell resumeDisplay];
                }
            }
        }
    }
    
    if (mainListView.isChangeChannel) {
        mainListView.isChangeChannel = NO;
    }
    [[TTAdImpressionTracker sharedImpressionTracker] startTrackForce];
}

-(void)suspendTrackAdCellsInVisibleCells{
    if (!_listView) {
        return;
    }
    if (!_isShowing) {
        return;
    }
    for (UITableViewCell * cell in  [_listView visibleCells]) {
        if ([cell isKindOfClass:[ExploreCellBase class]]) {
            NSIndexPath *indexPath = [_listView indexPathForCell:cell];
            if (indexPath.row >= [self listViewMaxModelIndex]) {
                continue;
            }
            ExploreOrderedData *obj = [[_fetchListManager items] objectAtIndex:indexPath.row];
            
            if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                void (^ad_show_over)(NSString *) = ^(NSString *ad_id) {
                    NSString *trackInfo = [[TTAdImpressionTracker sharedImpressionTracker] endTrack:ad_id];
                    NSDictionary *adExtra = [NSMutableDictionary dictionaryWithCapacity:1];
                    [adExtra setValue:trackInfo forKey:@"ad_extra_data"];
                    
                    NSTimeInterval duration = [[SSADEventTracker sharedManager] durationForAdThisTime:ad_id];
                    if (_isShowWithScenesEnabled) {
                        TTADShowScene scene = [[SSADEventTracker sharedManager] showOverSceneForAd:ad_id];
                        [[SSADEventTracker sharedManager] trackEventWithOrderedData:obj label:@"show_over" eventName:@"embeded_ad" extra:adExtra duration:duration scene:scene];
                    } else {
                        [[SSADEventTracker sharedManager] trackEventWithOrderedData:obj label:@"show_over" eventName:@"embeded_ad" extra:adExtra duration:duration];
                    }
                };
                if (obj.ad_id.longLongValue > 0) {
                    ad_show_over(obj.ad_id);
                }
            }
        }
    }
}

- (void)willDisappear
{
    [super willDisappear];
    [TTFeedDislikeView dismissIfVisible];
    [self.feedGuideView dismiss];
    
    if ([TTExploreMainViewController isNewFeed]) {
        [[SSImpressionManager shareInstance] leaveGroupViewForCategoryID:self.categoryID concernID:self.concernID refer:self.refer];
    } else {
        if (self.isDisplayView) {
            [[SSImpressionManager shareInstance] leaveGroupViewForCategoryID:self.categoryID concernID:self.concernID refer:self.refer];
        }
    }
    [self suspendTrackAdCellsInVisibleCells];
//    这个标志位的修改要放到suspendTrackAdCellsInVisibleCells后，这个方法里面有些逻辑要依赖_isShowing
    _isShowing = NO;
    
    for (ExploreCellBase * cell in  [_listView visibleCells]) {
        if ([cell isKindOfClass:[ExploreCellBase class]]) {
            NSIndexPath *indexPath = [_listView indexPathForCell:cell];
            if (indexPath.row >= [self listViewMaxModelIndex]) {
                continue;
            }
            ExploreOrderedData *obj = [[_fetchListManager items] objectAtIndex:indexPath.row];
            if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                if ([cell isKindOfClass:[ExploreCellBase class]]) {
                    [self oldMovieAutoOverTrack:cell stop:NO];
                    [self newMovieAutoOverTrack:cell orderData:obj stop:NO];
                    [cell cellInListWillDisappear:CellInListDisappearContextTypeGoDetail];
                    
                    if([cell isKindOfClass:[ExploreArticleCardCell class]]){
                        [cell didEndDisplaying];
                    }
                }
                
            }
        }
    }
    
    [self saveLeaveCurrentCategoryDate];
    
    if (_isClickCellLeaveList){
        _isClickCellLeaveList = NO;
    }
}

- (void)didDisappear
{
    [super didDisappear];
    
    if (self.remindView) {
        [self.remindView hide];
        self.remindView.enabled = NO;
    }
    NSArray *vcArray = self.navigationController.viewControllers;
    if (vcArray.count > 1) {
        self.hasHitPushed = YES;
    }
}

- (void)newMovieAutoOverTrack:(ExploreCellBase *)cellBase orderData:(ExploreOrderedData *)orderData stop:(BOOL)stop
{
    if ([orderData.uniqueID isEqualToString:[TTVAutoPlayManager sharedManager].model.uniqueID]) {
        if ([cellBase conformsToProtocol:@protocol(TTVAutoPlayingCell)] && [cellBase respondsToSelector:@selector(movieView)]) {
            UITableViewCell <TTVAutoPlayingCell> *movieCell = (UITableViewCell <TTVAutoPlayingCell> *)cellBase;
            if ([[movieCell ttv_movieView] isKindOfClass:[TTVPlayVideo class]]) {
                [[TTVAutoPlayManager sharedManager] trackForFeedAutoOver:[TTVAutoPlayModel  modelWithOrderedData:orderData] movieView:[movieCell ttv_movieView]];
                if (stop && [[TTVAutoPlayManager sharedManager].model.uniqueID isEqualToString:orderData.uniqueID]) {
                    [[TTVAutoPlayManager sharedManager] resetForce];
                }
            }
        }
    }
}

- (void)oldMovieAutoOverTrack:(ExploreCellBase *)cellBase stop:(BOOL)stop
{
    if ([[TTVideoAutoPlayManager sharedManager] cellIsAutoPlaying:cellBase]) {
        //自动播放时，禁止出小窗
        if ([cellBase conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)] && [cellBase respondsToSelector:@selector(movieView)]) {
            id<ExploreMovieViewCellProtocol> movieCell = (id<ExploreMovieViewCellProtocol>)cellBase;
            if ([[movieCell movieView] isKindOfClass:[ExploreMovieView class]]) {
                [[TTVideoAutoPlayManager sharedManager] trackForFeedAutoOver:cellBase.cellData movieView:[movieCell movieView]];
                if (stop) {
                    [[TTVideoAutoPlayManager sharedManager] dataStopAutoPlay:cellBase.cellData];
                }
            }
        }
    }
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
//    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    
    self.backgroundColor = [UIColor whiteColor];
    self.listView.backgroundColor = self.backgroundColor;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if (_fetchListManager.items.count == 0) {
//        //uploading section + function area section
//        return ExploreMixedListBaseViewSectionFunctionAreaCells + 1;
//    }
//    //uploading section + function area section + explore section
    
    if (_fetchListManager.items.count == 0) {
        return ExploreMixedListBaseViewSectionFHouseCells + ExploreMixedListBaseViewSectionExploreCells;
    } else {
        return ExploreMixedListBaseViewSectionFHouseCells + ExploreMixedListBaseViewSectionExploreCells + 1;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    if (section == ExploreMixedListBaseViewSectionUploadingCells) {
//        return [self uploadingCellCountInTableView:tableView];
//    if (section == ExploreMixedListBaseViewSectionFunctionAreaCells) {
//        return 1;
//    }else {
//        NSUInteger count = [[_fetchListManager items] count];
//        return count;
//    }
    if (section == ExploreMixedListBaseViewSectionFHouseCells) {
        if (isEmptyString(_categoryID))
        {
            return 0;
        }
        if ([_categoryID isEqualToString:@"f_house_news"]) {
            BOOL isHasFindHouseCategory = [[[TTArticleCategoryManager sharedManager] allCategories] containsObject:[TTArticleCategoryManager categoryModelByCategoryID:@"f_find_house"]];
            
            if (_fetchListManager.items.count > 0 && !isHasFindHouseCategory) {
                return 1;
            }else
            {
                return 0;
            }
        }
        return 0;
    }else
    {
        NSUInteger count = [[_fetchListManager items] count];
        return count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if ([indexPath section] == ExploreMixedListBaseViewSectionUploadingCells) {
//        return [self heightForUploadingCellAtIndex:[indexPath row] inTableView:tableView];
//    if ([indexPath section] == ExploreMixedListBaseViewSectionFunctionAreaCells) {
//        return [self heightForFunctionAreaCell];
//    }else {
    
    if ([indexPath section] == ExploreMixedListBaseViewSectionFHouseCells) {
        return [ExploreCellHelper heightForFHHomeHeaderCellViewType];
    }else
    {
        if (indexPath.row < [self listViewMaxModelIndex]) {
            id obj = [[_fetchListManager items] objectAtIndex:indexPath.row];
            
            if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                if (!((ExploreOrderedData *)obj).managedObjectContext || ! ((ExploreOrderedData *)obj).originalData.managedObjectContext) {
                    return 0;//fault的item高度返回0
                }
            }
            
            CGFloat cellWidth = [TTUIResponderHelper splitViewFrameForView:tableView].size.width;
            
            return [ExploreCellHelper heightForData:obj cellWidth:cellWidth listType:_listType];
        }
        
        return 44;
    }
    
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if ([indexPath section] == ExploreMixedListBaseViewSectionUploadingCells) {
//        return [self uploadingCellAtIndex:[indexPath row] inTableView:tableView];
//    if ([indexPath section] == ExploreMixedListBaseViewSectionFunctionAreaCells) {
//        return [self functionAreaCell];
//    }
    
    if ([indexPath section] == ExploreMixedListBaseViewSectionFHouseCells) {
        //首页头部cell
        NSString *cellIdentifier = NSStringFromClass([ExploreCellHelper cellClassFromCellViewType:ExploreCellViewTypeHomeHeaderTableViewCell data:nil]);
        ExploreCellBase *tableCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (tableCell) {
            [tableCell refreshUI];
            return tableCell;
        }
        else {
            Class cellClass = NSClassFromString(cellIdentifier);
            tableCell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [tableCell refreshUI];
            return tableCell;
        }
        return tableCell;
    }

    UITableViewCell * tableCell = nil;
    ExploreCellBase *cell = nil;
    
    if (indexPath.row < [self listViewMaxModelIndex]) {
        id obj = [[_fetchListManager items] objectAtIndex:indexPath.row];
        
        tableCell = [ExploreCellHelper dequeueTableCellForData:obj tableView:tableView atIndexPath:indexPath refer:self.refer];
        if ([tableCell isKindOfClass:[ExploreCellBase class]]) {
            cell = (ExploreCellBase *)tableCell;
            cell.refer = self.refer;
            [cell setDataListType:_listType];
            [cell refreshWithData:obj];
        }
        else if ([tableCell isKindOfClass:[WDBaseCell class]])
        {
            if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                WDBaseCell *wdCell = (WDBaseCell *)tableCell;
                if (wdCell) {
                    ExploreOrderedData *orderData = (ExploreOrderedData *)obj;
                    wdCell.tableView = tableView;
                    [wdCell refreshWithData:orderData.originalData];
                    return  wdCell;
                }
                else {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"preventCrashCellIdentifier"];
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"preventCrashCellIdentifier"];
                    }
                    cell.textLabel.text = @"";
                    return cell;
                }
            }
        }
        
        
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            ExploreOrderedData * orderData = (ExploreOrderedData *)obj;
            
            if (orderData.managedObjectContext && orderData.originalData.managedObjectContext) {
                
                if (_isShowing && !_isNewFeedImpressionEnabled) {
                    SSImpressionStatus impressionStatus = (self.isDisplayView && _isShowing) ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
                    [self recordGroupForExploreOrderedData:orderData status:impressionStatus cellBase:cell];
                }
                
                //先判断order 和origin 是否存在， 不存在不实例化cell， 用最后的保证机制，生成一个没有内容的cell
                id oriData = orderData.originalData;
                // 文章类型的CallToAction
                Article *article = oriData;
                
                if (_listType == ExploreOrderedDataListTypeCategory && [article isKindOfClass:[Article class]] && !isEmptyString(article.adPromoter)) {
                    if (cell) {
                        ExploreOrderedDataCellType cellType = orderData.cellType;
                        if (cellType == ExploreOrderedDataCellTypeAppDownload) {
                            ExploreBaseADCell *adCell = (ExploreBaseADCell *)cell;
                            if ([adCell respondsToSelector:@selector(setReadPersistAD:)]) {
                                adCell.readPersistAD = [article.hasRead boolValue];
                            }
                        }
                    }
                } else {
                    cell.tabType = ((NSNumber *)[self.externalRequestCondtion objectForKey:kExploreFetchListConditionListFromTabKey]).integerValue;
                    // 非广告类型的文章，如果带有stat_url_list字段，也需要向第三方发送url track统计（5.3）
                    if ([orderData.statURLs isKindOfClass:[NSArray class]] && orderData.statURLs.count > 0) {
                        ttTrackURLs(orderData.statURLs);
                        
                        // ssTrackURLs(orderData.statURLs);
                    }
                }
            }
            orderData.comefrom |= ExploreOrderedDataFromOptionMemory;
        }
    }
    
    if (!cell) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"preventCrashCellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"preventCrashCellIdentifier"];
        }
        cell.textLabel.text = @"";
        return cell;
    }
    
    return cell;
        
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (/*[indexPath section] == ExploreMixedListBaseViewSectionUploadingCells ||*/ [indexPath section] == ExploreMixedListBaseViewSectionFunctionAreaCells) {
//      return;
//    }
    
    if ([indexPath section] == ExploreMixedListBaseViewSectionFHouseCells) {
        //to do


        return;
    }

    NSInteger modelRowIndex = indexPath.row;
    if (_delegate && [_delegate respondsToSelector:@selector(mixListView:didSelectRowAtIndex:)]) {
        [_delegate mixListView:self didSelectRowAtIndex:indexPath];
    }
    
    if (indexPath.row >= [self listViewMaxModelIndex]) {
        //load more
        self.refreshFromType = ListDataOperationReloadFromTypeLoadMore;
        [self loadMoreWithUmengLabel:[self modifyEventLabelForRefreshEvent: @"load_more"]];
    }
    else {
        _isClickCellLeaveList = YES;
        id obj = [[_fetchListManager items] objectAtIndex:modelRowIndex];
        
        // 读`热`文
//        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
//            NSString *typeString = [TTLayOutCellDataHelper getTypeStringWithOrderedData:obj];
//            if ([typeString isEqualToString:@"热"]) {
//                TTAuthorizePushGuideChangeFireReason(TTPushNoteGuideFireReasonReadTopArticle);
//            }
//        }
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[LastRead class]]) {
            if (self.shouldShowRefreshButton) {
                [self didSelectLastReadCell];
            }
        }
        else if ([cell isKindOfClass:[ExploreCellBase class]]) {
            if ([SSCommonLogic feedVideoEnterBackEnabled]) {
                if (![cell isKindOfClass:[TTLayOutNewLargePicCell class]]
                || ![(TTLayOutNewLargePicCell *)cell ttv_movieView]) {
                    [ExploreMovieView removeAllExploreMovieView];
                    [[TTVAutoPlayManager sharedManager] resetForce];
                }
            }
            TTFeedCellSelectContext *context = [TTFeedCellSelectContext new];
            context.refer = self.refer;
            context.orderedData = obj;
            context.categoryId = self.categoryID;
            //            [self convertPicViewInfoForContext:context fromCell:(ExploreCellBase *)cell];
            [(ExploreCellBase *)cell didSelectWithContext:context];
            return;
        }
        else if ([cell isKindOfClass:[WDBaseCell class]]) {
            if ([cell respondsToSelector:@selector(didSelected:apiParam:)]) {
                [(WDBaseCell *)cell didSelected:((ExploreOrderedData *)obj).originalData apiParam:@""];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (/*[indexPath section] == ExploreMixedListBaseViewSectionUploadingCells ||*/ [indexPath section] == ExploreMixedListBaseViewSectionFunctionAreaCells) {
//        return;
//    }
    
    if ([indexPath section] == ExploreMixedListBaseViewSectionFHouseCells) {
        //to do


        return;
    }
    
    if (self.movieViewCellData && self.movieView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(willFinishLoadTable) object:nil];
        [self willFinishLoadTable];
    }
    
    
    if (indexPath.row < [self listViewMaxModelIndex]) {
        ExploreOrderedData * obj = [[_fetchListManager items] objectAtIndex:indexPath.row];
        
        if (![_cellIdDict[obj.itemID] isEqual: @""]) {
            
            NSMutableDictionary *dictTraceParams = [NSMutableDictionary dictionary];
            
            [dictTraceParams setValue:obj.categoryID forKey:@"category_name"];
            
            [dictTraceParams setValue:@"click_category" forKey:@"enter_from"];
            
            if ([obj.categoryID isEqualToString:@"f_wenda"])
            {
                [dictTraceParams setValue:obj.categoryID forKey:@"category_name"];
                [dictTraceParams setValue:@"house_app2c_v2" forKey:@"event_type"];
                [dictTraceParams setValue:obj.article.groupModel.groupID forKey:@"group_id"];
                [dictTraceParams setValue:obj.itemID forKey:@"item_id"];
                [dictTraceParams setValue:obj.logPb[@"impr_id"] forKey:@"impr_id"];
                [dictTraceParams setValue:obj.logPb forKey:@"log_pb"];
                [dictTraceParams setValue:@"be_null" forKey:@"ansid"];
                [dictTraceParams setValue:obj.article.groupModel.groupID forKey:@"qid"];
                [dictTraceParams setValue:@(obj.cellType) ? : @"be_null" forKey:@"cell_type"];
                [TTTracker eventV3:@"client_show" params:dictTraceParams];
                
            }else {
                
                [dictTraceParams setValue:@"house_app2c_v2" forKey:@"event_type"];
                [dictTraceParams setValue:obj.article.groupModel.groupID forKey:@"group_id"];
                [dictTraceParams setValue:obj.itemID forKey:@"item_id"];
                [dictTraceParams setValue:obj.logPb[@"impr_id"] forKey:@"impr_id"];
                [dictTraceParams setValue:obj.logPb forKey:@"log_pb"];
                [dictTraceParams setValue:@(obj.cellType) ? : @"be_null" forKey:@"cell_type"];
                [TTTracker eventV3:@"client_show" params:dictTraceParams];
                
                [_cellIdDict setObject:@"" forKey:obj.itemID];
                
            }
            
        }else
        {
            NSLog(@"xx index.row = %ld",indexPath.row);
        }
        
        obj.witnessed = YES;
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            //下载广告app store页面预加载
            [self preloadAppStoreAd:(ExploreOrderedData *)obj];
            if (obj.article)
            {
                BOOL shouldDisplay = [ExploreCellHelper shouldDisplayComment:obj.article listType:_listType];
                if (shouldDisplay) {
                    NSString * label = @"headline_comment_show";
                    if (!isEmptyString(self.categoryID) && ![self.categoryID isEqualToString:kTTMainCategoryID]) {
                        label = [NSString stringWithFormat:@"%@_comment_show", self.categoryID];
                    }
                    BOOL hasZZComments = obj.article.zzComments.count > 0;
                    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:3];
                    [extra setValue:@(obj.article.uniqueID) forKey:@"gid"];
                    [extra setValue:obj.article.itemID forKey:@"item_id"];
                    [extra setValue:@(hasZZComments?1:0) forKey:@"has_zz_comment"];
                    if (hasZZComments) {
                        [extra setValue:obj.article.firstZzCommentMediaId forKey:@"mid"];
                    }
                    NSString *commentId = [obj.article.displayComment tt_stringValueForKey:@"comment_id"];
                    
                    [TTTrackerWrapper event:@"click_list_comment" label:label value:obj.ad_id extValue:commentId extValue2:nil dict:extra];
                }
                
                [self attachVideoIfNeededForCell:cell data:obj];
                
            }
//            else if (obj.essayData) {
//                BOOL shouldDisplay = [ExploreCellHelper shouldDisplayEssayComment:obj.essayData listType:_listType];
//                if (shouldDisplay) {
//                    NSString * label = @"headline_comment_show";
//                    if (!isEmptyString(self.categoryID) && ![self.categoryID isEqualToString:kTTMainCategoryID]) {
//                        label = [NSString stringWithFormat:@"%@_comment_show", self.categoryID];
//                    }
//                    wrapperTrackEvent(@"click_list_comment", label);
//                }
//            }
            else if (obj.wapData) {
                if (cell.height > 0) {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                    [dict setValue:@"umeng" forKey:@"category"];
                    [dict setValue:@"widget" forKey:@"tag"];
                    
                    NSString *label;
                    if ([self.categoryID isEqualToString:kTTMainCategoryID]) {
                        label = @"headline";
                    } else {
                        label = self.categoryID;
                    }
                    label = [NSString stringWithFormat:@"show_%@", label];
                    [dict setValue:label forKey:@"label"];
                    NSString *gid = [NSString stringWithFormat:@"%lld", obj.wapData.uniqueID];
                    [dict setValue:gid forKey:@"value"];
                    [TTTrackerWrapper eventData:dict];
                }
            }
            else if(obj.stockData){
            }
//            else if(obj.live){
//                Live *live = (Live *)obj.live;
//                wrapperTrackEventWithCustomKeys(@"livetalk", @"show", [NSString stringWithFormat:@"%@", live.liveId], nil, @{@"stat": [NSString stringWithFormat:@"%@", live.status]});
//            }
            else if([((ExploreOrderedData *)obj).originalData isKindOfClass:[Card class]]) {
                Card *cardObj = (Card *)(((ExploreOrderedData *)obj).originalData);
                NSDictionary *extra = @{@"category_name": [NSString stringWithFormat:@"%@", self.categoryID]};
                ExploreOrderedData *orderedData = cardObj.cardItems.firstObject;
                Book *book = orderedData.book;
                if (book && [TTTrackerWrapper isOnlyV3SendingEnable]) {
                } else {
                    wrapperTrackEventWithCustomKeys(@"card", @"card_show", [NSString stringWithFormat:@"%lld", cardObj.uniqueID], nil, extra);
                }
                if(book) {
                    [TTTrackerWrapper eventV3:@"show_card" params:@{@"category_name":@"novel_channel"} isDoubleSending:YES];
                }
            }
            else if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[LastRead class]]) {
                [self addLastReadTrackWithLabel:@"last_read_show"];
            }
            else if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[Comment class]]) {
            }
//            else if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[RecommendUserCardsData class]]) {
//                [TTTrackerWrapper eventV3:@"follow_card" params:@{
//                    @"action_type":@"show",
//                    @"category_name": obj.categoryID,
//                    @"source": @"list",
//                    @"is_direct" : @(1)
//                }];
//            }
//            else if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[RecommendUserLargeCardData class]]) {
//                [TTTrackerWrapper eventV3:@"vert_follow_card" params:@{
//                    @"action_type":@"show",
//                    @"category_name": obj.categoryID,
//                    @"recommend_type": @(obj.recommendUserLargeCardData.groupRecommendType),
//                    @"show_num": @(obj.recommendUserLargeCardData.userCards.count)
//                }];
//            }
//            else if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[MomentsRecommendUserData class]]) {
//                [TTTrackerWrapper eventV3:@"subscriber_behavior_card_show" params:@{
//                    @"category_name": obj.categoryID,
//                    @"card_content": @"follow",
//                    @"subv_num": @(obj.momentsRecommendUserData.userCardModels.count),
//                    @"user_id": obj.momentsRecommendUserData.friendUserModel.info.user_id ?: @""
//                }];
//            }
//            else if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[SurveyPairData class]]) {
//                if (obj.uniqueID && obj.categoryID) {
//                    SurveyPairData *data = (SurveyPairData *)(((ExploreOrderedData *)obj).originalData);
//                    if (data && !data.hideNextTime) {
//                        [TTTrackerWrapper eventV3:@"survey_pair_show" params:@{@"survey_id" : obj.uniqueID, @"category_name" : obj.categoryID}];
//                    }
//                }
//            } else if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[SurveyListData class]]) {
//                if (obj.uniqueID && obj.categoryID) {
//                    SurveyListData *data = (SurveyListData *)(((ExploreOrderedData *)obj).originalData);
//                    if (data && !data.hideNextTime) {
//                        [TTTrackerWrapper eventV3:@"survey_list_show" params:@{@"survey_id" : obj.uniqueID, @"category_name" : obj.categoryID}];
//                    }
//                }
//            } else if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[Thread class]]) {
//
//            } else if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[TTHashtagCardData class]]) {
//            } else if ([((ExploreOrderedData *)obj).originalData isKindOfClass:[RecommendRedpacketData class]]) {
//            }
            
            obj.originalData.hasShown = [NSNumber numberWithBool:YES];
            if (_isShowing && [cell isKindOfClass:[ExploreCellBase class]]) {
                ExploreCellBase *cellBase = (ExploreCellBase *)cell;
                [cellBase willDisplay];
            }
            
            /*impression统计相关*/
            if(_isNewFeedImpressionEnabled) {
                ExploreOrderedData * orderedData = (ExploreOrderedData *)obj;
                if (orderedData.managedObjectContext && orderedData.originalData.managedObjectContext && [cell isKindOfClass:[ExploreCellBase class]]) {
                    ExploreCellBase *explorecell = (ExploreCellBase *)cell;
                    SSImpressionStatus impressionStatus = (self.isDisplayView && _isShowing) ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
                    
                    [self recordGroupForExploreOrderedData:orderedData status:impressionStatus cellBase:explorecell];
                    
                    //                    SSImpressionParams *params = [[SSImpressionParams alloc] init];
                    //                    params.categoryID = self.categoryID;
                    //                    params.concernID = self.concernID;
                    //                    params.refer = self.refer;
                    //                    params.cellStyle = explorecell.cellStyle;
                    //                    params.cellSubStyle = explorecell.cellSubStyle;
                    //
                    //                    [ArticleImpressionHelper recordGroupForExploreOrderedData:orderedData status:impressionStatus params:params];
                }
            }
        }
        
        // ad show, important @yinhao
        if ([obj isKindOfClass:[ExploreOrderedData class]] && self.isDisplayView && _isShowing) {
            ExploreOrderedData * orderData = (ExploreOrderedData *)obj;
            
            void(^ad_show)(NSString *) = ^(NSString *ad_id) {
                if ([SSCommonLogic videoVisibleEnabled] &&
                    (orderData.cellFlag & ExploreOrderedDataCellFlagAutoPlay) &&
                    [cell conformsToProtocol:@protocol(TTVAutoPlayingCell)]) {
                    [[TTAdImpressionTracker sharedImpressionTracker] track:ad_id visible:cell.frame scrollView:tableView movieCell:(id<TTVAutoPlayingCell>)cell];
                } else {
                    [[TTAdImpressionTracker sharedImpressionTracker] track:ad_id visible:cell.frame scrollView:tableView];
                }
                NSMutableDictionary *extra = [NSMutableDictionary dictionary];
//                if (obj.live) {
//                    Live *live = (Live *)obj.live;
//                    [extra setValue:[NSNumber numberWithLongLong:live.uniqueID] forKey:@"ext_value"];
//                    [extra setValue:live.status forKey:@"live_status"];
//                }
                if (orderData.adExtraData) {
                    [extra addEntriesFromDictionary:orderData.adExtraData];
                }

                [[SSADEventTracker sharedManager] willShowAD:ad_id scene:TTADShowRefreshScene];
                if (_isShowWithScenesEnabled) {
                    [[SSADEventTracker sharedManager] trackEventWithOrderedData:obj label:@"show" eventName:@"embeded_ad" extra:extra duration:0 scene:TTADShowRefreshScene];
                } else {
                    [[SSADEventTracker sharedManager] trackEventWithOrderedData:obj label:@"show" eventName:@"embeded_ad" extra:extra duration:0];
                }
            };
            if (((ExploreOrderedData *)obj).ad_id) {
                ad_show(obj.ad_id);
            }
            
            Article *article = orderData.article;
            if ([article isKindOfClass:[Article class]]) {
                id<TTAdFeedModel> adModel = orderData.adModel;
                ExploreOrderedDataCellType cellType = orderData.cellType;
                if (cellType == ExploreOrderedDataCellTypeAppDownload) {
                    [[SSADEventTracker sharedManager] trackEventWithOrderedData:obj label:@"card_show" eventName:@"feed_download_ad"];
                } else if ([adModel conformsToProtocol:@protocol(TTAdFeedModel)]) {
                    NSDictionary<NSString*, NSString*> * const creativeTagMapping = @{
                                                                                      @"action"           : @"feed_call",
                                                                                      @"form"             : @"feed_form",
                                                                                      @"counsel"          : @"feed_counsel",
                                                                                      @"discount"         : @"feed_discount",
                                                                                      @"location_action"  : @"feed_call",
                                                                                      @"location_form"    : @"feed_form",
                                                                                      @"location_counsel" : @"feed_counsel",
                                                                                      @"coupon"           : @"feed_coupon",
                                                                                      @"app"              : @"feed_download_ad"
                                                                                      };
                    if ([creativeTagMapping objectForKey:adModel.type]) {
                        NSString *tag = creativeTagMapping[adModel.type];
                        [[SSADEventTracker sharedManager] trackEventWithOrderedData:obj label:@"card_show" eventName:tag];
                    }
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
//    if (/*[indexPath section] == ExploreMixedListBaseViewSectionUploadingCells ||*/ [indexPath section] == ExploreMixedListBaseViewSectionFunctionAreaCells) {
//        return;
//    }
    
    if ([indexPath section] == ExploreMixedListBaseViewSectionFHouseCells) {
        //to do


        return;
    }
    
    if (self.movieViewCellData && self.movieView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(willFinishLoadTable) object:nil];
        [self willFinishLoadTable];
    }
    
    if (indexPath.row < [self listViewMaxModelIndex]) {
        ExploreOrderedData *obj;
        if ([cell isKindOfClass:[ExploreCellBase class]]) {
            obj = [((ExploreCellBase *)cell) cellData];
        } else {
            // 加个else防守一下 :)  理论上应该不会走到这里吧。。。
            obj = [[_fetchListManager items] objectAtIndex:indexPath.row];
        }
        obj.witnessed = NO;
        
        // ad show_over, important @yinhao
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            void(^ad_show_over)(NSString *) = ^(NSString *ad_id) {
                NSString *trackInfo = [[TTAdImpressionTracker sharedImpressionTracker] endTrack:ad_id];
                NSDictionary *adExtra = [NSMutableDictionary dictionaryWithCapacity:1];
                [adExtra setValue:trackInfo forKey:@"ad_extra_data"];
                
                NSTimeInterval duration = [[SSADEventTracker sharedManager] durationForAdThisTime:ad_id];
                if (_isShowWithScenesEnabled) {
                    TTADShowScene scene = [[SSADEventTracker sharedManager] showOverSceneForAd:ad_id];
                    [[SSADEventTracker sharedManager] trackEventWithOrderedData:obj label:@"show_over" eventName:@"embeded_ad" extra:adExtra duration:duration scene:scene];
                } else {
                    [[SSADEventTracker sharedManager] trackEventWithOrderedData:obj label:@"show_over" eventName:@"embeded_ad" extra:adExtra duration:duration];
                }
            };
            if ([((ExploreOrderedData *)obj).ad_id longLongValue] != 0) {
                ad_show_over(obj.ad_id);
            }
        }
        
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            if ([cell isKindOfClass:[ExploreCellBase class]]) {
                ExploreCellBase<ExploreMovieViewCellProtocol> *cellBase = (ExploreCellBase<ExploreMovieViewCellProtocol> *)cell;
                BOOL hasMovie = NO;
                if (self.movieViewCellData) {
                    NSArray *indexPaths = [tableView indexPathsForVisibleRows];
                    for (NSIndexPath *path in indexPaths) {
                        if (path.row < [self listViewMaxModelIndex]) {
                            ExploreOrderedData *rowObj = [[_fetchListManager items] objectAtIndex:path.row];
                            
                            BOOL hasMovieView = NO;
                            if ([cellBase respondsToSelector:@selector(hasMovieView)]) {
                                hasMovieView = [cellBase hasMovieView];
                            }
                            
                            if ([cellBase respondsToSelector:@selector(movieView)]) {
                                UIView *view = [cellBase movieView];
                                if (view && ![self.movieViews containsObject:view]) {
                                    [self.movieViews addObject:view];
                                }
                            }
                            if (rowObj == self.movieViewCellData) {
                                hasMovie = YES;
                                break;
                            }
                        }
                    }
                }
                
                if (![[tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                    //滑出屏幕
                    [self oldMovieAutoOverTrack:cellBase stop:YES];
                    [self newMovieAutoOverTrack:cellBase orderData:obj stop:YES];
                }
                
                if (_isShowing) {
                    if (!hasMovie) {
                        [cellBase didEndDisplaying];
                    }
                }
                
                // impression统计
                if (_isNewFeedImpressionEnabled) {
                    ExploreOrderedData *orderedData = (ExploreOrderedData *)obj;
                    [self recordGroupForExploreOrderedData:orderedData status:SSImpressionStatusEnd cellBase:cellBase];
                }
            }
        }
        
//        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
//            if (obj.cellType == ExploreOrderedDataCellTypeSurveyList) {
//                if (obj.surveyListData.selected && obj.surveyListData.hideNextTime && !obj.surveyListData.fixed && !self.isPerformingReloadData) {
//                    obj.surveyListData.fixed = YES;
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreOriginalDataUpdateNotification
//                                                                        object:nil
//                                                                      userInfo:@{@"uniqueID":@"survey_list"}];
//                }
//
//            }
//            if (obj.cellType == ExploreOrderedDataCellTypeSurveyPair) {
//                if (obj.surveyPairData.selectedArticle && obj.surveyPairData.hideNextTime && !obj.surveyPairData.fixed && !self.isPerformingReloadData) {
//                    obj.surveyPairData.fixed = YES;
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreOriginalDataUpdateNotification
//                                                                        object:nil
//                                                                      userInfo:@{@"uniqueID":@"survey_pair"}];
//                }
//            }
//        }
    }
}

#pragma mark - impression

- (void)recordGroupForExploreOrderedData:(ExploreOrderedData *)orderedData status:(SSImpressionStatus)status cellBase:(ExploreCellBase *)cellBase
{
    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = self.categoryID;
    params.concernID = self.concernID;
    params.refer = self.refer;
    params.cellStyle = cellBase.cellStyle;
    params.cellSubStyle = cellBase.cellSubStyle;
    [ArticleImpressionHelper recordGroupForExploreOrderedData:orderedData status:status params:params];
}

#pragma mark - list util

/**
 *  加载更多,并且发送umeng
 *
 *  @param label 如果为nil，不发送
 */
- (void)loadMoreWithUmengLabel:(NSString *)label
{
    if (!_fetchListManager.isLoading && [_fetchListManager.items count] > 0) {
        [self fetchFromLocal:NO fromRemote:YES getMore:YES];
        if (!isEmptyString(label)) {
            if ([TTTrackerWrapper isOnlyV3SendingEnable] && (([label rangeOfString:@"pre_load_more"].length > 0) || ([label rangeOfString:@"load_more"].length > 0))) {
            } else {
                [self trackEventForLabel:label];
            }
            
            //log3.0
            if ([label rangeOfString:@"pre_load_more"].length > 0) {
                [self trackRefershEvent3ForLabel:@"pre_load_more"];
            } else if ([label rangeOfString:@"load_more"].length > 0) {
//                [self trackRefershEvent3ForLabel:@"load_more"];
                [self trackRefershEvent3ForLabel:@"pre_load_more"];

            }
        }
    }
    else {
        [self.listView finishPullUpWithSuccess:NO];
    }
}

- (void)reloadListView
{
    [TTFeedDislikeView dismissIfVisible];
    [self performReloadData];
    
    if (self.isFirstRefreshListAfterLaunch) {
        if (TTLaunchSystemPermOptimizationTypeMoveNote & [TTDialogDirector systemPermOptimizationType]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [TTDialogDirector setQueueEnabled:YES];
            });
        } else {
            [TTDialogDirector setQueueEnabled:YES];
        }
    }
}

- (BOOL)isVideoBusiness
{
    return self.isInVideoTab || [self.categoryID isEqualToString:kTTVideoCategoryID];
}

- (void)performReloadData
{
    _isPerformingReloadData = YES;
    if ([self isVideoBusiness] && _isShowing) {
        if (self.isPlayerOnRotateAnimation) {
            self.readyToReload = YES;
            return;
        }
    }
    if (self.movieViewCellData && self.movieView) {
        [self performSelector:@selector(willFinishLoadTable) withObject:nil afterDelay:0.1];
    }
    
    [_listView reloadData];
    
    if (_fetchListManager.tableviewOffset > 1) {
        CGPoint p = _listView.contentOffset;
        NSLog(@"------------------- 关注频道跳动");
        [_listView setContentOffset:CGPointMake(0, p.y - _fetchListManager.tableviewOffset)];
        _fetchListManager.tableviewOffset = 0;
    }
    _isPerformingReloadData = NO;
}

- (void)reloadListViewWithVideoPlaying
{
    [self reloadListViewWithVideoPlayingIsChangeOrientation:NO];
}

- (void)reloadListViewWithVideoPlayingIsChangeOrientation:(BOOL)isChangeOrientation
{
    ExploreCellBase<ExploreMovieViewCellProtocol> *videoCellPlayingMovie = nil;
    NSInteger index = NSNotFound;
    ExploreOrderedData *movieViewCellData = nil;
    if (_fetchListManager.items.count > 0) {
        for (UITableViewCell *cell in _listView.visibleCells) {
            if ([cell isKindOfClass:[ExploreCellBase class]] && [cell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)]) {
                ExploreCellBase<ExploreMovieViewCellProtocol> *videoCell = (ExploreCellBase<ExploreMovieViewCellProtocol> *)cell;
                if ([cell respondsToSelector:@selector(hasMovieView)]) {
                    if ([videoCell hasMovieView]) {
                        videoCellPlayingMovie = videoCell;
                        index = [_fetchListManager.items indexOfObject:videoCellPlayingMovie.cellData];
                        movieViewCellData = videoCell.cellData;
                        break;
                    }
                }
            }
        }
    }
    
    if (videoCellPlayingMovie && movieViewCellData != nil) {
        if ([videoCellPlayingMovie isMovieFullScreen]) {
            return;
        }
        // 分离视频view
        self.movieView = [videoCellPlayingMovie movieView];
        //self.movieViewCellIndex = index;
        self.movieViewCellData = movieViewCellData;
        // reload列表
        [self performReloadData];
        
        // scroll到之前视频cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:ExploreMixedListBaseViewSectionExploreCells];
        if (isChangeOrientation) {
            [_listView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    }
    else {
        [self reloadListView];
    }
}

- (void)attachVideoIfNeededForCell:(UITableViewCell *)cell data:(ExploreOrderedData *)obj
{
    if (obj == self.movieViewCellData && self.movieView && [cell respondsToSelector:@selector(attachMovieView:)]) {
        id<ExploreMovieViewCellProtocol> videoCell = (id<ExploreMovieViewCellProtocol>)cell;
        [videoCell attachMovieView:self.movieView];
    }
}

- (void)applicationStatusBarOrientationDidChanged
{
    if ([TTDeviceHelper isPadDevice]) {
        [self reloadListViewWithVideoPlayingIsChangeOrientation:YES];
    }
}

- (void)listViewWillEnterForground
{
    [self tryFetchTipIfNeedWithForce:NO];
    [self tryAutoReloadIfNeed];
}

- (void)listViewWillEnterBackground
{
    [self saveLeaveCurrentCategoryDate];
    [self trackAutoPlayCellEnterBackground];
}

- (void)setExternalCondtion:(NSDictionary *)externalRequestCondtion
{
    if (externalRequestCondtion && [externalRequestCondtion isKindOfClass:[NSDictionary class]]) {
        self.externalRequestCondtion = externalRequestCondtion;
    }
    else {
        self.externalRequestCondtion = nil;
    }
}

- (void)fetchFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote getMore:(BOOL)getMore
{
//    self.ttLoadingView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    self.ttLoadingView.backgroundColor = [UIColor whiteColor];
    self.ttTargetView = self.listView;
    
    if (!self.ttLoadingView && [SSCommonLogic feedLoadingInitImageEnable]) {
        self.ttLoadingView = self.animationView;
    }

    [self tt_startUpdate];
//    //有开屏广告展示的时候首页列表页初始化和广告同步进行，故此优化仅针对于无开屏广告展示且读取本地缓存的时候
//    static BOOL isFirst = YES; // 只是第一次启动时异步调用，之后同步调用，避免切换频道闪白问题
//    if (fromLocal && ![SSADManager shareInstance].adShow && [SSCommonLogic shouldUseOptimisedLaunch] /*&& isFirst*/) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self tryOptimizeFetchFromLocal:fromLocal fromRemote:fromRemote getMore:getMore];
//        });
//        isFirst = NO;
//    } else {
        [self tryOptimizeFetchFromLocal:fromLocal fromRemote:fromRemote getMore:getMore];
//    }
}

- (void)tryOptimizeFetchFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote getMore:(BOOL)getMore { 
    NSMutableDictionary * exploreMixedListConsumeTimeStamps = [NSMutableDictionary dictionary];
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListTriggerRequestTimeStampKey];
    
    //为了蓝条 拼了！-- nick
    self.listView.ttIntegratedMessageBar = self.ttErrorToastView;
    self.ttAssociatedScrollView = self.listView;
    
    [_fetchListManager reuserAllOperations];
    
    NSMutableDictionary *condition = [NSMutableDictionary dictionaryWithDictionary:_externalRequestCondtion];
    
    // 有频道ID，没有关心ID
    if (!isEmptyString(_categoryID)) {
        if (isEmptyString(_concernID)) {
            // 从频道model里取关心ID
            TTCategory *categoryModel = [TTArticleCategoryManager categoryModelByCategoryID:_categoryID];
            _concernID = categoryModel.concernID;
        }
    }else {
        _categoryID = @"";
    }
    
    if (isEmptyString(_concernID)) {
        _concernID = @""; // 加保护，确保保存ExploreOrderedData时，主键不为nil
    }
    
    [condition setValue:_categoryID forKey:kExploreFetchListConditionListUnitIDKey];
    [condition setValue:_concernID forKey:kExploreFetchListConditionListConcernIDKey];
    [condition setValue:@(_apiType) forKey:kExploreFetchListConditionApiType];
    [condition setValue:@(_refer) forKey:kExploreFetchListConditionListReferKey];
    [condition setValue:self.movieCommentVideoID forKey:kExploreFetchListConditionListMovieCommentVideoIDKey];
    [condition setValue:self.movieCommentEntireID forKey:kExploreFetchListConditionListMovieCommentEntireIDKey];
    [condition setValue:exploreMixedListConsumeTimeStamps forKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
    
    if (_delegate && [_delegate respondsToSelector:@selector(mixListViewDidStartLoad:)]) {
        [_delegate mixListViewDidStartLoad:self];
    }
    
    [condition setValue:@(_refreshFromType) forKey:kExploreFetchListConditionReloadFromTypeKey];
    if(!getMore) {
        _loadMoreCount = 0;
        self.movieCommentVideoAPIOffset = 0;
        [condition setValue:@(0) forKey:kExploreFetchListConditionVerticalVideoAPIOffsetKey];
    }else {
        [condition setValue:@(self.verticalVideoAPIOffset) forKey:kExploreFetchListConditionVerticalVideoAPIOffsetKey];
    }
    
    [condition setValue:@(self.movieCommentVideoAPIOffset) forKey:kExploreFetchListConditionListMovieCommentVideoAPIOffsetKey];
    [condition setValue:@(_loadMoreCount) forKey:kExploreFetchListConditionLoadMoreCountKey];
    
    //记录用户下拉刷新时间
    if (!getMore && fromRemote && !isEmptyString(self.primaryKey)) {
        [[NewsListLogicManager shareManager] saveHasReloadForCategoryID:self.primaryKey];
        [self hideRemoteReloadTip];
    }
    
    //远端请求数据，更新一次tip请求时间
    if (fromRemote) {
        [[NewsListLogicManager shareManager] updateLastFetchReloadTipTimeForCategory:self.primaryKey];
    }
    
    //关注频道是否有红点
    if ([self.categoryID isEqualToString:kTTFollowCategoryID]) {
        [condition setValue:[[TTCategoryBadgeNumberManager sharedManager] hasNotifyPointOfCategoryID:self.categoryID]?@(YES):@(NO) forKey:kExploreFollowCategoryHasRedPointKey];
    }
        
    //关注频道
    if ([self.categoryID isEqualToString:kTTFollowCategoryID] && (!getMore || [KitchenMgr getBOOL:kKCUGCFollowNotifyCleanWhenLoadMore]) && fromRemote) {
        [[TTCategoryBadgeNumberManager sharedManager] updateNotifyPointOfCategoryID:self.categoryID withClean:YES];
    }

    
    NSNumber *lastReadOrderIndex = nil;
    lastReadOrderIndex = [self handleLastReadBeforeRefreshIfNeeded:getMore fromRemote:fromRemote];
    
    //判断是该列表第一次请求
    //BOOL isFirstRequest = [_fetchListManager.items count] == 0 && fromRemote && !getMore;
    
    [TTFeedDislikeView dismissIfVisible];
    [TTFeedDislikeView disable];
    
    
    //对本地频道的无内容图片做特殊处理，如果开启定位了出错 提示手选城市，如果未开定位 提示开启
    if ([self.categoryID isEqualToString:kTTNewsLocalCategoryID]) {
        
        BOOL bLocEnabled = [TTLocationManager isLocationServiceEnabled];
        if (bLocEnabled) {
            self.ttViewType = TTFullScreenErrorViewTypeLocationServiceError;
        }
        else {
            self.ttViewType = TTFullScreenErrorViewTypeLocationServiceDisabled;
        }
    }
    else {
        self.ttViewType = TTFullScreenErrorViewTypeEmpty;
        
    }
    
    //统计计时
    [self trackEventStartLoad];
    
    __weak ExploreMixedListBaseView * oldweakSelf = self;
    //5.7新增，因为refreshFromType会在block使用，用于发送刷新统计事件，在这个地方先捕获，然后重置refreshFromType为默认值
    ListDataOperationReloadFromType captureRefreshFromType = self.refreshFromType;
    self.refreshFromType = ListDataOperationReloadFromTypeNone;
    
    
    if (_accountChangedNeedReadloadList) {
        fromLocal = NO;
        _accountChangedNeedReadloadList = NO;
    }
    __weak typeof(self) oldwself = self;
    
    [self userRefreshGuideHideTabbarBubbleView];
    
    int64_t startTime = [NSObject currentUnixTime];
    [_fetchListManager startExecuteWithCondition:condition
                                       fromLocal:fromLocal
                                      fromRemote:fromRemote
                                         getMore:getMore
                                    isDisplyView:_isDisplayView
                                        listType:_listType
                                    listLocation:_listLocation
                                     finishBlock:^(NSArray *increaseItems, id operationContext, NSError *error) {
                                         
                                         __strong typeof(oldwself) self = oldwself;
                                         __strong typeof(oldwself) wself = oldwself;
                                         __strong typeof(oldweakSelf) weakSelf = oldweakSelf;
                                         
                                         if (!error && fromRemote) {
                                             NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:10];
                                             [userInfo setValue:wself.categoryID forKey:@"categoryID"];
                                             [userInfo setValue:@(increaseItems.count) forKey:@"count"];
                                             [[NSNotificationCenter defaultCenter] postNotificationName:kNewsListFetchedRemoteReloadItemCountNotification object:nil userInfo:userInfo];
                                         }
                                         
                                         int64_t endTime = [NSObject currentUnixTime];
                                         double duration = [NSObject machTimeToSecs:(endTime - startTime)] * 1000;
                                         NSMutableDictionary *devLogParams = [[NSMutableDictionary alloc] init];
                                         [devLogParams setValue:@(fromLocal) forKey:@"from_local"];
                                         [devLogParams setValue:@(fromRemote) forKey:@"from_remote"];
                                         [devLogParams setValue:@(getMore) forKey:@"get_more"];
                                         [devLogParams setValue:@(self.listType) forKey:@"list_type"];
                                         [devLogParams setValue:@(self.listLocation) forKey:@"list_location"];
                                         [devLogParams setValue:@(self.isDisplayView) forKey:@"is_display"];
                                         [devLogParams setValue:@(duration) forKey:@"duration"];
                                         [devLogParams setValue:@(error.code) forKey:@"error_code"];
                                         [devLogParams setValue:error.domain forKey:@"error_domain"];
                                         [TTDebugRealMonitorManager cacheDevLogWithEventName:@"feed_refresh" params:devLogParams];
                                         
                                         
                                         static BOOL firstFetch = YES;
                                         if (firstFetch) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
//                                                 if ([SSADManager shareInstance].adShow) {
                                                 if ([TTAdSplashMediator shareInstance].adWillShow) {
                                                     [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:[NSObject currentUnixTime]] forKey:@"kTrackTime_mainList_newsAppear_withAd"];
                                                     [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:0] forKey:@"kTrackTime_mainList_newsAppear_withoutAd"];
                                                 }
                                                 else {
                                                     [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:0] forKey:@"kTrackTime_mainList_newsAppear_withAd"];
                                                     [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:[NSObject currentUnixTime]] forKey:@"kTrackTime_mainList_newsAppear_withoutAd"];
                                                 }
                                                 [TTTrackInitTime trackInitTime];
                                             });
                                         }
                                         firstFetch = NO;
                                         
                                         if (!getMore && self && self->_isShowing) {
                                             [[TTVideoAutoPlayManager sharedManager] tryAutoPlayInTableView:self.listView];
                                             [[TTVAutoPlayManager sharedManager] resetForce];
                                             [[TTVAutoPlayManager sharedManager] tryAutoPlayInTableView:self.listView];
                                         }
                                         
                                         //fix 5.3:无error时再处理置顶
                                         if (!error) {
                                             NSDictionary *result = [operationContext objectForKey:kExploreFetchListResponseRemoteDataKey];
                                             weakSelf.movieCommentVideoAPIOffset = [[result objectForKey:@"result"] tt_unsignedIntegerValueForKey:@"offset"];
                                             weakSelf.verticalVideoAPIOffset = [[result objectForKey:@"result"] tt_unsignedIntegerValueForKey:@"offset"];
                                         }
                                         
                                         BOOL isResponseFromRemote = NO;
                                         if (operationContext) {
                                             isResponseFromRemote = [[operationContext objectForKey:kExploreFetchListIsResponseFromRemoteKey] boolValue];
                                         }
                                         
                                         //获取视频订阅号开关标志信息
                                         NSDictionary *resultDict = [[operationContext objectForKey:kExploreFetchListResponseRemoteDataKey] objectForKey:@"result"];
                                         if ([[resultDict allKeys] containsObject:@"show_top_pgc_list"]) {
                                             NSNumber *showPCGList = resultDict[@"show_top_pgc_list"];
                                             if ([showPCGList isKindOfClass:[NSNumber class]]) {
                                                 [TTPGCFetchManager setShouldShowVideoPGC:[showPCGList boolValue]];
                                             }
                                         }
                                         
                                        
                                         [TTFeedDislikeView enable];
                                         
                                         NSString *cid = [[operationContext objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListConditionListUnitIDKey];
                                         
                                         NSString *concernID = [[operationContext objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListConditionListConcernIDKey];
                                         
                                         NSString *key = !isEmptyString(cid) ? cid : concernID;
                                         
                                         NSInteger showTopBubbleViewDelay = kDefaultDismissDuration;
                                         
                                         if (![key isEqualToString:weakSelf.primaryKey]) {
                                             [weakSelf tt_endUpdataData:YES error:nil tip:nil tipTouchBlock:nil];
                                             if ([SSCommonLogic feedLoadingInitImageEnable]) {
                                                 weakSelf.ttLoadingView.frame = CGRectZero;
                                             }
                                             
                                             if (getMore) {
                                                 [weakSelf.listView finishPullUpWithSuccess:NO];
                                             }
                                             else {
                                                 [weakSelf.listView finishPullDownWithSuccess:NO];
                                                 //[weakSelf resetScrollView];
                                             }
                                             
                                             return;
                                         }
                                         
                                         BOOL isLoadMore = [[operationContext objectForKey:kExploreFetchListGetMoreKey] boolValue];
                                         
                                         //频道变化
                                         if (error && [error.domain isEqualToString:kExploreFetchListErrorDomainKey] &&
                                             error.code == kExploreFetchListCategoryIDChangedCode) {
                                             
                                             [weakSelf tt_endUpdataData:YES error:nil tip:nil tipTouchBlock:nil];
                                             if ([SSCommonLogic feedLoadingInitImageEnable]) {
                                                 weakSelf.ttLoadingView.frame = CGRectZero;
                                             }
                                             [weakSelf.listView finishPullDownWithSuccess:NO];
                                             
                                             [weakSelf refreshHeaderViewShowSearchBar:NO];
                                             [weakSelf reloadListView];
                                             
                                             return ;
                                         }
                                         //请求被cancel，不做任何操作
                                         else if (error.code == NSURLErrorCancelled) {
                                             return;
                                         }
                                         
                                         if (!error) {
                                             NSArray * allItems = [operationContext objectForKey:kExploreFetchListItemsKey];
                                             BOOL isFinish = [[operationContext objectForKey:kExploreFetchListResponseFinishedkey] boolValue];
                                             
                                             BOOL hasMore = [[operationContext objectForKey:kExploreFetchListResponseHasMoreKey] boolValue] && allItems.count > 0;
                                             if (weakSelf.movieCommentVideoID) {
                                                 hasMore = YES;
                                             }
                                             if (!getMore &&
                                                 [[operationContext allKeys] containsObject:kExploreFetchListResponseHasNewKey]) {
                                                 weakSelf.shouldShowRefreshButton = [[operationContext objectForKey:kExploreFetchListResponseHasNewKey] boolValue];
                                             }
                                             
                                             //默认给hasmore 设置YES 如果是加载更多的操作 根据返回值来处理list的hasmore
                                             weakSelf.listView.hasMore = YES;
                                             if(getMore) {
                                                 weakSelf.listView.hasMore = hasMore;
                                                 
                                                 if([increaseItems count] == 0)
                                                     weakSelf.listView.hasMore = NO;
                                             } else {
                                                 weakSelf.listView.hasMore = hasMore;
                                             }
                                             
                                             if (isFinish && isResponseFromRemote) {
                                                 [weakSelf trackLoadStatusEventWithErorr:nil isLoadMore:isLoadMore];
                                             }
                                             
                                             weakSelf.suggestionWordsView.categoryID = cid;
                                             
                                             //这个字段是说明 请求是否完成，如果只从local读取则为YES， 如果有本地和远端两种请求，remote返回后 isFinish才是YES， 而原先的代码 在isFinish为NO的时候 不会reloadTable 所以在else里加一个reload。 --- nick 4.9
                                             if (isFinish) {
                                                 if (isResponseFromRemote && !isLoadMore && weakSelf.listType == ExploreOrderedDataListTypeCategory) {
                                                     
                                                     // 统计自动刷新
                                                     if (captureRefreshFromType == ListDataOperationReloadFromTypeAuto ||
                                                         (captureRefreshFromType == ListDataOperationReloadFromTypeNone && !fromRemote)) {
                                                         if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                                                             [weakSelf trackEventForLabel:[weakSelf modifyEventLabelForRefreshEvent: @"refresh_enter_auto"]];
                                                         }
                                                         //log3.0
                                                         [weakSelf trackRefershEvent3ForLabel:@"enter_auto"];
                                                     }
                                                     else if (captureRefreshFromType == ListDataOperationReloadFromTypeAutoFromBackground){
                                                         [weakSelf trackEventForLabel:[weakSelf modifyEventLabelForRefreshEvent: @"refresh_auto"]];
                                                         //log3.0
                                                         [weakSelf trackRefershEvent3ForLabel:@"auto"];
                                                     }
                                                     
                                                     // 二级频道
                                                     NSDictionary *resultDict = [[operationContext tt_dictionaryValueForKey:kExploreFetchListResponseRemoteDataKey] tt_dictionaryValueForKey:@"result"];
                                                     
                                                     NSArray *subEntranceList = [resultDict tt_arrayValueForKey:@"sub_entrance_list"];
                                                     
                                                     if (![SSCommonLogic feedSearchEntryEnable] || ![SSCommonLogic feedSearchEntrySettingsSaved]) {
                                                         if ([subEntranceList isKindOfClass:[NSArray class]] && ![cid isEqualToString:@"__all__"]) {
                                                             NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                                                             [TTSubEntranceManager setSubEntranceRefreshTimeInterval:now forCategory:cid concernID:concernID];
                                                             [TTSubEntranceManager setSubEntranceObjArray:subEntranceList forCategory:cid concernID:concernID];
                                                             [TTSubEntranceManager setSubEntranceType:SubEntranceTypeHead forCategory:cid];
                                                         }
                                                     } else {
                                                         SubEntranceType type = [resultDict tt_integerValueForKey:@"sub_entrance_style"];
                                                         if (subEntranceList) {
                                                             if (!([cid isEqualToString:@"__all__"] && type == SubEntranceTypeHead)) {
                                                                 NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                                                                 [TTSubEntranceManager setSubEntranceRefreshTimeInterval:now forCategory:cid concernID:concernID];
                                                                 [TTSubEntranceManager setSubEntranceObjArray:subEntranceList forCategory:cid concernID:concernID];
                                                             }
                                                             
                                                             if ([subEntranceList isKindOfClass:[NSArray class]] && [subEntranceList count] > 0 && type == SubEntranceTypeStick) {
                                                                 [TTSubEntranceManager setSubEntranceType:SubEntranceTypeStick forCategory:cid];
                                                                 NSArray *subEntranceObjArray = [TTSubEntranceManager subEntranceObjArrayForCategory:weakSelf.categoryID concernID:weakSelf.concernID];
                                                                 if (subEntranceObjArray && [subEntranceObjArray isKindOfClass:[NSArray class]] && subEntranceObjArray.count > 0) {
                                                                     weakSelf.frame = CGRectMake(0, 44, weakSelf.defaultRect.size.width, weakSelf.defaultRect.size.height - 44);
                                                                     weakSelf.listView.frame = CGRectMake(0, 0, weakSelf.defaultRect.size.width, weakSelf.defaultRect.size.height - 44);
                                                                     [weakSelf.suggestionWordsView refreshWithData:subEntranceObjArray animated:YES superviewIsShowing:self->_isShowing];
                                                                 } else {
                                                                     weakSelf.frame = weakSelf.defaultRect;
                                                                     weakSelf.listView.frame = weakSelf.defaultRect;
                                                                 }
                                                             } else {
                                                                 weakSelf.frame = weakSelf.defaultRect;
                                                                 weakSelf.listView.frame = weakSelf.defaultRect;
                                                                 [TTSubEntranceManager setSubEntranceType:SubEntranceTypeHead forCategory:cid];
                                                             }
                                                         } else {
                                                             if ([TTSubEntranceManager subEntranceTypeForCategory:cid] == SubEntranceTypeStick) {
                                                                 NSArray *subEntranceObjArray = [TTSubEntranceManager subEntranceObjArrayForCategory:weakSelf.categoryID concernID:weakSelf.concernID];
                                                                 if (subEntranceObjArray && [subEntranceObjArray isKindOfClass:[NSArray class]] && subEntranceObjArray.count > 0) {
                                                                     weakSelf.frame = CGRectMake(0, 44, weakSelf.defaultRect.size.width, weakSelf.defaultRect.size.height - 44);
                                                                     weakSelf.listView.frame = CGRectMake(0, 0, weakSelf.defaultRect.size.width, weakSelf.defaultRect.size.height - 44);
                                                                     [weakSelf.suggestionWordsView refreshWithData:subEntranceObjArray animated:NO superviewIsShowing:self->_isShowing];
                                                                 } else {
                                                                     weakSelf.frame = weakSelf.defaultRect;
                                                                     weakSelf.listView.frame = weakSelf.defaultRect;
                                                                 }
                                                             } else {
                                                                 weakSelf.frame = weakSelf.defaultRect;
                                                                 weakSelf.listView.frame = weakSelf.defaultRect;
                                                             }
                                                         }
                                                     }
                                                     
                                                     //本地频道
                                                     if ([cid isEqualToString:kTTNewsLocalCategoryID]) {
                                                         NSNumber *feedFlag = [resultDict objectForKey:@"feed_flag"];
                                                         if (feedFlag) {
                                                             BOOL needShow = !([feedFlag integerValue] & 0x1);
                                                             [NewsListLogicManager setNeedShowCitySelectionBar:needShow];
                                                             [weakSelf refreshHeaderViewShowSearchBar:NO];
                                                         } else {
                                                             [NewsListLogicManager setNeedShowCitySelectionBar:YES];
                                                             [weakSelf refreshHeaderViewShowSearchBar:NO];
                                                         }
                                                     }
                                                     
                                                     // 主tab所有频道请求搜索占位词，搜索条在titlebar上时
                                                     
                                                     if (weakSelf.refer == 1) {
                                                         NSString *tab = @"video";
                                                         if (self.isInVideoTab == NO){
                                                             tab = self.listLocation == ExploreOrderedDataListLocationWeitoutiao ? @"weitoutiao" : @"home";
                                                         }
                                                         if ([SSCommonLogic threeTopBarEnable] || ([SSCommonLogic threeTopBarEnable] == NO && [tab isEqualToString:@"home"])){
                                                             [TTArticleSearchManager tryFetchSearchTipIfNeedWithTabName:tab categoryID:self.categoryID];
                                                         }
                                                     }
                                                     
                                                     if (![weakSelf needShowCitySelectBar]) {
                                                         [weakSelf refreshSubEntranceBar];
                                                     }
                                                 }
                                                 
                                                 if (!isResponseFromRemote) {
                                                     if ([cid isEqualToString:kTTNewsLocalCategoryID]) {
                                                         [weakSelf refreshHeaderViewShowSearchBar:NO];
                                                     }
                                                     
                                                     if ([SSCommonLogic feedSearchEntryEnable]) {
                                                         if ([TTSubEntranceManager subEntranceTypeForCategory:cid] == SubEntranceTypeStick) {
                                                             NSArray *subEntranceObjArray = [TTSubEntranceManager subEntranceObjArrayForCategory:weakSelf.categoryID concernID:weakSelf.concernID];
                                                             if (subEntranceObjArray && [subEntranceObjArray isKindOfClass:[NSArray class]] && subEntranceObjArray.count > 0) {
                                                                 weakSelf.frame = CGRectMake(0, 44, weakSelf.defaultRect.size.width, weakSelf.defaultRect.size.height - 44);
                                                                 weakSelf.listView.frame = CGRectMake(0, 0, weakSelf.defaultRect.size.width, weakSelf.defaultRect.size.height - 44);
                                                                 [weakSelf.suggestionWordsView refreshWithData:subEntranceObjArray animated:NO superviewIsShowing:self->_isShowing];
                                                             } else {
                                                                 weakSelf.frame = weakSelf.defaultRect;
                                                                 weakSelf.listView.frame = weakSelf.defaultRect;
                                                             }
                                                         } else {
                                                             weakSelf.frame = weakSelf.defaultRect;
                                                             weakSelf.listView.frame = weakSelf.defaultRect;
                                                         }
                                                     }
                                                 }
                                                 
//                                                 //插入微头条和审核中的视频
//                                                 [weakSelf insertThreadsAndVideosToFeedIfNeededWithIsFromRemote:fromRemote];
                                                 
                                                 //插入"上次阅读到这里"cell
                                                 if (isResponseFromRemote && !isLoadMore && ([SSCommonLogic showRefreshHistoryTip] && [weakSelf isNewTab])) {
                                                     [SSCommonLogic updateRefreshHistoryTip];
                                                 }
                                                 if ([SSCommonLogic feedLastReadCellShowEnable] || ([SSCommonLogic showRefreshHistoryTip] && [SSCommonLogic feedRefreshClearAllEnable] && [weakSelf isNewTab])) {
                                                     [weakSelf insertLastReadCellAfterRefreshIfNeededWithIncreasedCount:increaseItems.count isLoadMore:getMore orderIndex:lastReadOrderIndex];
                                                 }
                                                 
                                                 if (isLoadMore && (weakSelf.listType == ExploreOrderedDataListTypeCategory)) {
                                                     [weakSelf reloadListViewWithVideoPlaying];
                                                 } else {
                                                     if (weakSelf.isLastReadRefresh) {
                                                         weakSelf.isLastReadRefresh = NO;
                                                         [weakSelf addLastReadTrackWithLabel:[weakSelf modifyEventLabelForRefreshEvent: @"refresh_last_read"]];
                                                         //log3.0
                                                         [weakSelf trackRefershEvent3ForLabel:@"last_read"];
                                                     }
                                                     
                                                     [weakSelf reloadListView];
                                                 }
                                             }
                                             else {
                                                 [weakSelf reloadListView];
                                                 
                                                 if ([SSCommonLogic feedSearchEntryEnable]) {
                                                     if ([TTSubEntranceManager subEntranceTypeForCategory:cid] == SubEntranceTypeStick) {
                                                         NSArray *subEntranceObjArray = [TTSubEntranceManager subEntranceObjArrayForCategory:weakSelf.categoryID concernID:weakSelf.concernID];
                                                         if (subEntranceObjArray && [subEntranceObjArray isKindOfClass:[NSArray class]] && subEntranceObjArray.count > 0) {
                                                             weakSelf.frame = CGRectMake(0, 44, weakSelf.defaultRect.size.width, weakSelf.defaultRect.size.height - 44);
                                                             weakSelf.listView.frame = CGRectMake(0, 0, weakSelf.defaultRect.size.width, weakSelf.defaultRect.size.height - 44);
                                                             [weakSelf.suggestionWordsView refreshWithData:subEntranceObjArray animated:NO superviewIsShowing:self->_isShowing];
                                                         } else {
                                                             weakSelf.frame = weakSelf.defaultRect;
                                                             weakSelf.listView.frame = weakSelf.defaultRect;
                                                         }
                                                     } else {
                                                         weakSelf.frame = weakSelf.defaultRect;
                                                         weakSelf.listView.frame = weakSelf.defaultRect;
                                                     }
                                                 }
                                             }
                                             
                                             if (isFinish && isResponseFromRemote) {
                                                 
                                                 [weakSelf tryPreload];
                                                 [self preloadAdVideo];
                                                 if (isLoadMore) {
                                                     weakSelf.loadMoreCount ++;
                                                 }
                                                 
                                                 //2个统计
                                                 __strong typeof(self) strongSelf = oldweakSelf;
                                                 NSArray * ary = [[[operationContext tt_dictionaryValueForKey:kExploreFetchListResponseRemoteDataKey] tt_dictionaryValueForKey:@"result"] tt_arrayValueForKey:@"data"];
                                                 [strongSelf trackEventUpdateRemoteItemsCount:[ary count]];
                                                 [strongSelf trackEventUpdateRemoteItemsCountAfterMerge:[[operationContext valueForKey:kExploreFetchListResponseMergeUniqueIncreaseCountKey] integerValue]];
                                                 
                                             }
                                             
                                             NSString * tip;
                                             NSInteger duration = 0;
                                             SSTipModel * tipModel;
                                             
                                             NSInteger updateCount = [[operationContext valueForKey:@"new_number"] intValue];
                                             updateCount = MAX(0, updateCount);
                                             if (isFinish && isResponseFromRemote && !isLoadMore) {
                                                 // 蓝条更新条数中过滤掉widget
                                                 if ([increaseItems.firstObject isKindOfClass:[ExploreOrderedData class]]) {
                                                     ExploreOrderedData *firstObj = increaseItems.firstObject;
                                                     if (firstObj.cellType == ExploreOrderedDataCellTypeWeb ||
                                                         firstObj.cellType == ExploreOrderedDataCellTypeRN ||
                                                         firstObj.cellType == ExploreOrderedDataCellTypeDynamicRN) {
                                                         updateCount = MAX(0, updateCount - 1);
                                                     }
                                                 }
                                                 
                                                 NSDictionary *remoteTipResult = [[[operationContext objectForKey:kExploreFetchListResponseRemoteDataKey] objectForKey:@"result"] objectForKey:@"tips"];
                                                 
                                                 tipModel = [[SSTipModel alloc] initWithDictionary:remoteTipResult];
                                                 NSString * msg = nil;
                                                 NSString * displayTemplate = tipModel.displayTemplate;
                                                 if (!isEmptyString(displayTemplate)) {
                                                     NSRange range = [displayTemplate rangeOfString:displayTemplate];
                                                     if (range.location != NSNotFound) {
                                                         msg = [displayTemplate stringByReplacingOccurrencesOfString:kSSTipModelDisplayTemplatePlaceholder withString:[NSString stringWithFormat:@"%ld", (long)updateCount]];
                                                     }
                                                 } else if (!isEmptyString(tipModel.displayInfo)) {
                                                     msg = tipModel.displayInfo;
                                                 }
                                                 
                                                 duration = [tipModel.displayDuration intValue];
                                                 if (isEmptyString(msg)) {
                                                     if ([increaseItems count] > 0) {
                                                         msg = [NSString stringWithFormat:@"发现%ld条更新", (long)updateCount];
                                                     }
                                                     else {
                                                         msg = NSLocalizedString(@"暂无更新，休息一会儿", nil);
                                                     }
                                                 }
                                                 
                                                 if (duration <= 0) {
                                                     duration = 2.f;
                                                 }
                                                 //处理免流逻辑
                                                 if([[TTFreeFlowTipManager sharedInstance] shouldShowPullRefreshTip]) {
                                                     msg = [NSString stringWithFormat:@"免流量中，%@",msg];
                                                 }
                                                 tip = msg;
                                                 
                                             }
                                             showTopBubbleViewDelay = duration;
                                             if (duration>10) {
                                                 duration = kTipDurationInfinite;
                                             }
                                             
                                             if(isResponseFromRemote){
                                                 [weakSelf tt_endUpdataData:!isResponseFromRemote error:nil tip:tip duration:duration tipTouchBlock:^{
                                                     [weakSelf notifyBarAction:tipModel];
                                                     
                                                 }];
                                                 
                                                 NSMutableDictionary *params = @{}.mutableCopy;
                                                 params[@"category_name"] = self.categoryID;
                                                 [tipModel sendV3TrackWithLabel:@"category_enter_bar_show" params:params];
                                                 
                                                 if ([SSCommonLogic feedLoadingInitImageEnable]) {
                                                     weakSelf.ttLoadingView.frame = CGRectZero;
                                                 }
                                             }
                                             else if ([weakSelf tt_hasValidateData]) {
                                                 // loading时没有数据不显示动画icon，恢复动画icon显示，
                                                 [weakSelf.listView.pullDownView showAnimationView];
                                                 
                                                 [weakSelf tt_endUpdataData:!isResponseFromRemote error:nil tip:tip duration:duration tipTouchBlock:^{
                                                     [weakSelf notifyBarAction:tipModel];
                                                 }];
                                                 if ([SSCommonLogic feedLoadingInitImageEnable]) {
                                                     weakSelf.ttLoadingView.frame = CGRectZero;
                                                 }
                                             }
                                             
                                             weakSelf.listView.pullUpView.hidden = ![weakSelf tt_hasValidateData];
                                             
                                             if ([SSCommonLogic feedSearchEntryEnable]) {
                                                 if ([TTSubEntranceManager subEntranceTypeForCategory:cid] == SubEntranceTypeStick) {
                                                     NSArray *subEntranceObjArray = [TTSubEntranceManager subEntranceObjArrayForCategory:self.categoryID concernID:self.concernID];
                                                     if (subEntranceObjArray && [subEntranceObjArray isKindOfClass:[NSArray class]] && subEntranceObjArray.count > 0) {
                                                         [weakSelf.superview bringSubviewToFront:weakSelf.suggestionWordsView];
                                                     } else {
                                                         [weakSelf.superview sendSubviewToBack:weakSelf.suggestionWordsView];
                                                     }
                                                 } else {
                                                     [weakSelf.superview sendSubviewToBack:weakSelf.suggestionWordsView];
                                                 }
                                             }
                                             
                                             if(isResponseFromRemote){
                                                 
                                                 if (getMore) {
                                                     [weakSelf.listView finishPullUpWithSuccess:!error];
                                                 }
                                                 else {
                                                     [weakSelf updateCustomTopOffset];
                                                     [weakSelf.listView finishPullDownWithSuccess:!error];
                                                 }
                                                 NSMutableDictionary * exploreMixedListConsumeTimeStamps = [[operationContext objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
                                                 [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime])
                                                                                      forKey:kExploreFetchListFinishRequestTimeStampKey];
                                                 [weakSelf exploreMixedListTimeConsumingMonitorWithContext:operationContext];
                                                 
                                             }
                                             
                                             if (!isResponseFromRemote && weakSelf.listView.pullDownView.state == PULL_REFRESH_STATE_INIT && weakSelf.listView.customTopOffset != 0) {
                                                 [weakSelf.listView setContentOffset:CGPointMake(0, weakSelf.listView.customTopOffset - weakSelf.listView.contentInset.top) animated:NO];
                                             }
                                             [weakSelf reportDelegateLoadFinish:isFinish isUserPull:weakSelf.listView.pullDownView.isUserPullAndRefresh isGetMore:getMore];
                                         }
                                         else {
                                             NSString * msg = nil;
                                             if(error.code == kServerUnAvailableErrorCode)
                                             {
                                                 if([weakSelf.fetchListManager items].count == 0)
                                                 {
                                                     msg = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
                                                 }
                                             }
                                             else
                                             {
                                                 msg = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
                                                 if(isEmptyString(msg)) {
                                                     msg = kNetworkConnectionTimeoutTipMessage;
                                                 }
                                             }
                                             if (!TTNetworkConnected()) {
                                                 msg = kNoNetworkTipMessage;
                                             }
                                             
                                             [weakSelf trackLoadStatusEventWithErorr:error isLoadMore:isLoadMore];
                                             
                                             if(isResponseFromRemote){
                                                 [weakSelf tt_endUpdataData:!isResponseFromRemote error:error tip:msg duration:kDefaultDismissDuration tipTouchBlock:nil];
                                                 if ([SSCommonLogic feedLoadingInitImageEnable]) {
                                                     weakSelf.ttLoadingView.frame = CGRectZero;
                                                 }
                                             }
                                             else if ([weakSelf tt_hasValidateData]) {
                                                 [weakSelf tt_endUpdataData:!isResponseFromRemote error:error tip:msg duration:kDefaultDismissDuration tipTouchBlock:nil];
                                                 if ([SSCommonLogic feedLoadingInitImageEnable]) {
                                                     weakSelf.ttLoadingView.frame = CGRectZero;
                                                 }
                                             }
                                             
                                             if(isResponseFromRemote){
                                                 
                                                 if (getMore) {
                                                     [weakSelf.listView finishPullUpWithSuccess:!error];
                                                 }
                                                 else {
                                                     [weakSelf updateCustomTopOffset];
                                                     [weakSelf.listView finishPullDownWithSuccess:!error];
                                                 }
                                                 
                                             }
                                             
                                             [weakSelf reportDelegateLoadFinish:YES isUserPull:weakSelf.listView.pullDownView.isUserPullAndRefresh isGetMore:getMore];
                                         }
                                         
                                         //此处判断是否需要获取更新提示的tip, 如果需要， 获取， 并且更新时间;如果还没到时间，开始倒计时
                                         [weakSelf tryFetchTipIfNeedWithForce:NO];
                                         
                                         //关注频道刷新后，告知提醒轮询manager
                                         if ([cid isEqualToString:kTTFollowCategoryID] && (!getMore || [KitchenMgr getBOOL:kKCUGCFollowNotifyCleanWhenLoadMore]) && fromRemote && isResponseFromRemote) {
                                             __block ExploreOrderedData * firstOrderedData = nil;
                                             [weakSelf.fetchListManager.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                 if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                                                     firstOrderedData = obj;
                                                     *stop = YES;
                                                 }
                                             }];
                                             NSTimeInterval minBehotTime =  [firstOrderedData behotTime];
                                             if (getMore && [KitchenMgr getBOOL:kKCUGCFollowNotifyCleanWhenLoadMore]) {
                                                 minBehotTime = [[NSDate date] timeIntervalSince1970];
                                             }
                                             [[TTInfiniteLoopFetchNewsListRefreshTipManager sharedManager] newsListLastHadRefreshWithCategoryID:cid
                                                                                                                                   minBehotTime:minBehotTime];
                                         }
                                         
                                         [weakSelf.fetchListManager reloadSilentFetchSettings];
                                         
                                         if (!weakSelf.silentFetchTimer && !weakSelf.isSilentFetchTimerFired) {
                                             NSTimeInterval timeInterval = [SSCommonLogic feedAutoInsertTimeInterval] / 1000.;
                                             if (timeInterval > 1) {
                                                 [weakSelf setupSilentFetchTimer];
                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                     if (weakSelf && weakSelf.silentFetchTimer && !weakSelf.isSilentFetchTimerFired) {
                                                         dispatch_resume(weakSelf.silentFetchTimer);
                                                         weakSelf.isSilentFetchTimerFired = YES;
                                                     }
                                                 });
                                             }
                                         }
                                     }];
}
#pragma mark - NotifyBar Funcs

- (void)notifyBarAction:(SSTipModel*)tipModel
{
    if (tipModel == nil) {
        return;
    }
    [[SSActionManager sharedManager] actionForModel:tipModel];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"category_name"] = self.categoryID;
    [tipModel sendV3TrackWithLabel:@"category_enter_bar_click" params:params];
}

#pragma mark - UIViewControllerErrorHandler

- (void)refreshData
{
    [[FHFeedHouseCellHelper sharedInstance]removeHouseCache];
    [self.listView triggerPullDown];
}

- (void)emptyViewBtnAction {
    
    if (![self.categoryID isEqualToString:kTTNewsLocalCategoryID]) {
        [[FHFeedHouseCellHelper sharedInstance]removeHouseCache];
        [self.listView triggerPullDown];
    }
    else {
        BOOL bLocEnabled = [TTLocationManager isLocationServiceEnabled];
        if (bLocEnabled) {
            
            [self citySelectViewClicked:nil];
        }
        else {
            [self tipOpenLocationSerivce];
        }
    }
}

- (BOOL)tt_hasValidateData {
//    if ([self uploadingCellCountInTableView:self.listView] > 0) {
//        return YES;
//    }
    if (self.fetchListManager.items.count>0) {
        if (self.fetchListManager.items.count == 1) {
            ExploreOrderedData *firstObject = self.fetchListManager.items.firstObject;
            if ([firstObject isKindOfClass:[ExploreOrderedData class]] && firstObject.cellType == ExploreOrderedDataCellTypeLastRead) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}


- (void)tipOpenLocationSerivce {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if(status == kCLAuthorizationStatusNotDetermined){
        [[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:nil];
        return;
    }
    
    if (&UIApplicationOpenSettingsURLString != NULL) {
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
        
    } else {
//        TTAuthorizeHintView *hintView =
//        [[TTAuthorizeHintView alloc]
//         initAuthorizeHintWithImageName:@"img_popup_locate"
//         title:NSLocalizedString(@"开启定位服务设置", nil)
//         message:NSLocalizedString(@"请在系统“设置”-“隐私”-“定位服务”内，开启“好多房”定位服务", nil)
//         confirmBtnTitle:@"我知道了"
//         animated:YES
//         completed:nil];
//        [hintView show];
    }
}

#pragma mark - public

- (void)pullAndRefresh
{
    //默认为none，如果是其他方式，在此方法外部重新赋值
    //self.refreshFromType = ListDataOperationReloadFromTypeNone;为了刷新统计时发送正确的refreshfromType给传过去
    [[FHFeedHouseCellHelper sharedInstance]removeHouseCache];
    [self.listView triggerPullDown];
}

- (void)scrollToBottomAndLoadmore
{
    if ([SSCommonLogic homeClickLoadmoreEnable]) {
        if ([SSCommonLogic homeClickActionTypeForCategoryID:self.categoryID] == 1) {
            [self.listView setContentOffset:CGPointMake(0, self.listView.contentSize.height - self.listView.height + 105)];
        } else if ([SSCommonLogic homeClickActionTypeForCategoryID:self.categoryID] == -1) {
            return;
        } else if ([SSCommonLogic homeClickActionTypeForCategoryID:self.categoryID] == 0) {
            self.refreshShouldLastReadUpate = YES;
            [self pullAndRefresh];
        } else {
            [self.listView setContentOffset:CGPointMake(0, self.listView.contentSize.height - self.listView.height + 105)];
        }
    } else if ([SSCommonLogic homeClickRefreshEnable]) {
        if ([SSCommonLogic homeClickActionTypeForCategoryID:self.categoryID] == 1) {
            [self.listView setContentOffset:CGPointMake(0, self.listView.contentSize.height - self.listView.height + 105)];
        } else if ([SSCommonLogic homeClickActionTypeForCategoryID:self.categoryID] == -1) {
            return;
        } else if ([SSCommonLogic homeClickActionTypeForCategoryID:self.categoryID] == 0) {
            self.refreshShouldLastReadUpate = YES;
            [self pullAndRefresh];
        } else {
            self.refreshShouldLastReadUpate = YES;
            [self pullAndRefresh];
        }
    } else if ([SSCommonLogic homeClickNoAction]) {
        if ([SSCommonLogic homeClickActionTypeForCategoryID:self.categoryID] == 1) {
            [self.listView setContentOffset:CGPointMake(0, self.listView.contentSize.height - self.listView.height + 105)];
        } else if ([SSCommonLogic homeClickActionTypeForCategoryID:self.categoryID] == -1) {
            return;
        } else if ([SSCommonLogic homeClickActionTypeForCategoryID:self.categoryID] == 0) {
            self.refreshShouldLastReadUpate = YES;
            [self pullAndRefresh];
        } else {
            return;
        }
    } else {
        self.refreshShouldLastReadUpate = YES;
        [self pullAndRefresh];
    }
}

- (void)pullAndRefreshWithLastReadUpate
{
    self.refreshShouldLastReadUpate = YES;
    self.refreshFromType = ListDataOperationReloadFromTypeLastRead;
    [self pullAndRefresh];
}

- (void)scrollToTopEnable:(BOOL)enable
{
    _listView.scrollsToTop = enable;
}

- (void)cancelAllOperation
{
    //这里先return 试一下 因为 每次滑动一开始就cancel 会导致空列表 -- nick 4.9.x
    return;
    
    //    [_fetchListManager cancelAllOperations];
    //    [self reportDelegateCancelRequest];
    //
    //    [self tt_endUpdataData];
    //
    //    [self.listView finishPullDownWithSuccess:NO];
}

- (void)scrollToTopAnimated:(BOOL)animated
{
    [self updateCustomTopOffset];
    [_listView setContentOffset:CGPointMake(0, self.listView.customTopOffset - self.listView.contentInset.top) animated:animated];
}

- (void)setListTopInset:(CGFloat)topInset BottomInset:(CGFloat)bottomInset
{
    [self setTtContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
    [self.listView setContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
    [self.listView setScrollIndicatorInsets:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
}

- (void)clearListContent
{
    [_fetchListManager resetManager];
    
    [self tt_endUpdataData];
    if ([SSCommonLogic feedLoadingInitImageEnable]) {
        self.ttLoadingView.frame = CGRectZero;
    }
    //    [self.listView finishPullDownWithSuccess:NO];
    [self resetScrollView];
    [self reloadListView];
    
}

- (void)resetScrollView
{
    TTRefreshView *refreshView = self.listView.pullDownView;
    UIScrollView *scrollView = self.listView;
    
    [refreshView.layer removeAllAnimations];
    [scrollView.layer removeAllAnimations];
    
    if ([scrollView.ttIntegratedMessageBar respondsToSelector:@selector(hideImmediately)]) {
        [scrollView.ttIntegratedMessageBar performSelector:@selector(hideImmediately) withObject:nil];
    }
    
    refreshView.state = PULL_REFRESH_STATE_INIT;
    refreshView.isUserPullAndRefresh = NO;
    
    scrollView.contentInset= self.ttContentInset;
    
    if (scrollView.customTopOffset != 0) {
        scrollView.contentOffset = CGPointMake(0, scrollView.customTopOffset - scrollView.contentInset.top);
    }
}

- (void)setNotInterestToOrderedData:(ExploreOrderedData *)orderedData
{
    if ([orderedData.originalData respondsToSelector:@selector(notInterested)]) {
        orderedData.originalData.notInterested = @(YES);
        if ([orderedData.originalData isKindOfClass:[Card class]]) {
            [(Card *)(orderedData.originalData) setAllCardItemsNotInterested];
        }
        [orderedData.originalData save];
    }
}

// 统一频道ID和关心ID
- (NSString *)primaryKey {
    return !isEmptyString(_categoryID) ? _categoryID : _concernID;
}

#pragma mark -
#pragma mark LastRead
- (NSNumber *)handleLastReadBeforeRefreshIfNeeded:(BOOL)getMore fromRemote:(BOOL)fromRemote
{
    NSString *uniqueID = [self getUniqueIDForLastRead];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
    [dict setValue:uniqueID forKey:@"uniqueID"];
    [dict setValue:self.categoryID forKey:@"categoryID"];
    [dict setValue:self.concernID forKey:@"concernID"];
    [dict setValue:@(self.listType) forKey:@"listType"];
    [dict setValue:@(self.listLocation) forKey:@"listLocation"];
    
    NSString *primaryID = [ExploreOrderedData primaryIDFromDictionary:dict];
    
    ExploreOrderedData *lastReadOrderData = [ExploreOrderedData objectForPrimaryKey:primaryID];
    
    if (lastReadOrderData) {
        if ([lastReadOrderData.originalData isKindOfClass:[LastRead class]]) {
            self.lastReadOrderData = lastReadOrderData;
            self.lastReadData = (LastRead *)lastReadOrderData.originalData;
            self.shouldShowRefreshButton = [self.lastReadData.showRefresh boolValue];
            _isLastReadInDB = YES;
            if (![SSCommonLogic shouldShowLastReadForCategoryID:self.categoryID]) {
                [ExploreItemActionManager removeOrderedData:self.lastReadOrderData];
                self.lastReadOrderData = nil;
                self.lastReadData = nil;
                _isLastReadInDB = NO;
            }
        }
    }
    else{
        self.lastReadOrderData = nil;
        self.lastReadData = nil;
        self.shouldShowRefreshButton = YES;
        _isLastReadInDB = NO;
    }
    NSNumber * orderIndex = nil;
    self.isFirstRefreshListAfterLaunch = !_fetchListManager.items.count;
    if (!self.isFirstRefreshListAfterLaunch) {
        if (!getMore ) {
            orderIndex = [self getTopCellOrderIndex];
        }
        else {
            orderIndex = [self getOrderIndexFromDB];
        }
    }
    else if (fromRemote){
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithCapacity:5];
        [queryDict setValue:self.categoryID forKey:@"categoryID"];
        [queryDict setValue:self.concernID forKey:@"concernID"];
        [queryDict setValue:@(self.listType) forKey:@"listType"];
        [queryDict setValue:@(self.listLocation) forKey:@"listLocation"];
        NSArray *localItems = [ExploreOrderedData objectsWithQuery:queryDict orderBy:@"orderIndex DESC" offset:0 limit:1];
        if (localItems.count > 0){
            ExploreOrderedData *topItem = [localItems objectAtIndex:0];
            orderIndex = @([topItem orderIndex]);
        }
    }
    else if (_isLastReadInDB) {//第一次启动，last_read插入到最底下一条
        orderIndex = [self getOrderIndexFromDB];
    }
    return orderIndex;
}

- (NSNumber *)getOrderIndexFromDB
{
    NSNumber *orderIndex = nil;
    if ([self.lastReadOrderData isKindOfClass:[ExploreOrderedData class]]) {
        orderIndex = @(self.lastReadOrderData.orderIndex);
    }
    return orderIndex;
}

- (void)insertLastReadCellAfterRefreshIfNeededWithIncreasedCount:(NSInteger)increasedCount isLoadMore:(BOOL)isLoadMore orderIndex:(NSNumber *)orderIndex
{
    NSNumber * nowOrderIndex = @([[NSDate date] timeIntervalSince1970] * 1000);
    if (isLoadMore) {
        if ((orderIndex == nil && !_isLastReadInDB && [_fetchListManager items].count > kShowOldLastReadMinThreshold) || (orderIndex && [nowOrderIndex doubleValue] - [orderIndex doubleValue] > kMaxLastReadLookupInterval && [_fetchListManager items].count > kShowOldLastReadMinThreshold)) {
            orderIndex = @([nowOrderIndex doubleValue] - kMaxLastReadLookupInterval);
            self.shouldShowRefreshButton = YES;
        }
        else if (orderIndex) {
            //避免插入orderindex再次加0.5
            orderIndex = @([orderIndex doubleValue] - kExploreMixedListBaseViewLastReadIncreaseInterval);
        }
    }
    NSDate *recordedLastReadDate = nil;
    NSDate *lastReadFirstAppearDate = nil;
    NSDate *now = [NSDate date];
    NSDate *oneDayAgo = [NSDate dateWithTimeIntervalSinceNow:- kMaxLastReadLookupInterval/1000];
    
    if ([self shouldInsertLastReadCellAfterRefreshWithIncreasedCount:increasedCount isLoadMore:isLoadMore orderIndex:orderIndex])
    {
        if (_isLastReadInDB) {
            if (isLoadMore) {
                recordedLastReadDate = self.lastReadData.lastDate;
                lastReadFirstAppearDate = self.lastReadData.refreshDate;
            }
            else{
                recordedLastReadDate = self.lastReadData.refreshDate;
                lastReadFirstAppearDate = now;
            }
        }
        else{
            if (isLoadMore) {
                recordedLastReadDate = oneDayAgo;
                lastReadFirstAppearDate = now;
            }
            else{
                recordedLastReadDate = now;
                lastReadFirstAppearDate = now;
            }
        }
        //在此处插入lastreadmodel 到items和coredata
        [self insertLastReadToTopWithOrderIndex:orderIndex lastReadDate:recordedLastReadDate refreshDate:lastReadFirstAppearDate shouldShowRefreshButton:self.shouldShowRefreshButton];
    }
    else if(_isLastReadInDB) {
        if (![self.lastReadData.showRefresh isEqualToNumber:@(self.shouldShowRefreshButton)]) {
            [self.lastReadData updateWithShowRefresh:self.shouldShowRefreshButton];
        }
        if (self.isFirstRefreshListAfterLaunch) {
            recordedLastReadDate = self.lastReadData.refreshDate;
            lastReadFirstAppearDate = now;
            [self.lastReadData updateWithLastReadDate:recordedLastReadDate refreshDate:lastReadFirstAppearDate];
        }
        
    }
}

- (BOOL)shouldInsertLastReadCellAfterRefreshWithIncreasedCount:(NSInteger)increasedCount isLoadMore:(BOOL)isLoadMore orderIndex:(NSNumber *)orderIndex
{
    if (orderIndex == nil || ![SSCommonLogic LastReadRefreshEnabled] || (self.listType != ExploreOrderedDataListTypeCategory) || ![SSCommonLogic shouldShowLastReadForCategoryID:self.primaryKey]) {
        return NO;
    }
    else {
        if ([_fetchListManager items].count > kInsertLastReadMinThreshold) {
            ExploreOrderedData *theFifthOrderData = [[_fetchListManager items] objectAtIndex:kInsertLastReadMinThreshold - 1];
            if ([orderIndex longLongValue] < theFifthOrderData.orderIndex) {
                if (isLoadMore) {
                    BOOL result = YES;
                    if (_isLastReadInDB && [[_fetchListManager items] containsObject:self.lastReadOrderData]) {
                        result = NO;
                    }
                    return result;
                }
                else{
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (NSNumber *)getTopCellOrderIndex
{
    id obj = nil;
    if ([self isCategoryWithHeadInfo] && [_fetchListManager items].count > 1) {
        obj = [[_fetchListManager items] objectAtIndex:[self topNonStickCellIndexFromIndex:1]];
    }
    else if ([_fetchListManager items].count > 0){
        obj = [[_fetchListManager items] objectAtIndex:[self topNonStickCellIndexFromIndex:0]];
    }
    return [self getModelOrderIndex:obj];
}

- (NSInteger)topNonStickCellIndexFromIndex:(NSInteger)fromIndex
{
    NSInteger topIndex = fromIndex;
    for (NSInteger idx = fromIndex; idx < [_fetchListManager items].count; idx++) {
        id obj = [[_fetchListManager items] objectAtIndex:idx];
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            ExploreOrderedData *orderData = (ExploreOrderedData *)obj;
            if (!orderData.stickStyle) {
                topIndex = idx;
                break;
            }
        }
    }
    //    NSLog(@"find topIndex before fetch is %ld", topIndex);
    return MAX(MIN(topIndex, [_fetchListManager items].count - 1), 0);
}

- (NSNumber *)getModelOrderIndex:(id)obj
{
    NSNumber *lastReadModelOrderIndex = nil;
    if ([obj isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData * orderedData = (ExploreOrderedData *)obj;
        if([orderedData respondsToSelector:@selector(orderIndex)]) {
            lastReadModelOrderIndex = @(orderedData.orderIndex);
        }
    }
    return lastReadModelOrderIndex;
}

- (NSInteger)listViewMaxModelIndex
{
    return [[_fetchListManager items] count];
}

- (void)addLastReadTrackWithLabel:(NSString *)label
{
    if ([self isNewTab]) {
        wrapperTrackEvent(@"new_tab", label);
    }
    else {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:self.categoryID forKey:@"category_id"];
        [dict setValue:self.concernID forKey:@"concern_id"];
        [dict setValue:[NSNumber numberWithInteger:self.refer] forKey:@"refer"];
        wrapperTrackEventWithCustomKeys(@"category", label, nil, nil, dict);
    }
}

- (BOOL)isNewTab
{
    //是否是推荐列表
    return [self.categoryID isEqualToString:@"__all__"];
}

- (BOOL)isCategoryWithHeadInfo
{
    //“体育”和“财经”等有浮顶信息的频道
    id obj = [[_fetchListManager items] firstObject];
    if ([obj isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)obj;
        return orderedData.cellType == ExploreOrderedDataCellTypeWeb;
    }
    return NO;
}

- (void)didSelectLastReadCell
{
    if ([SSCommonLogic feedRefreshClearAllEnable]) {
        NSString *openUrl = @"sslocal://history?stay_id=refresh_history";
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openUrl]];
        [TTTrackerWrapper eventV3:@"enter_refresh_history" params:@{@"category_name" : @"__all__"}];
    } else {
        _isLastReadRefresh = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(mixListViewDidSelectLastReadCellWillBeginRefresh:)]) {
            [self.delegate mixListViewDidSelectLastReadCellWillBeginRefresh:self];
        }
        [self pullAndRefreshWithLastReadUpate];
        if (self.delegate && [self.delegate respondsToSelector:@selector(mixListViewDidSelectLastReadCellDidBeginRefresh:)]) {
            [self.delegate mixListViewDidSelectLastReadCellDidBeginRefresh:self];
        }
        [self addLastReadTrackWithLabel:@"last_read_click"];
    }
}

#pragma mark -
#pragma mark preload

- (void)reportDelegateLoadFinish:(BOOL)finish isUserPull:(BOOL)userPull isGetMore:(BOOL)isGetMore
{
    if (_delegate && [_delegate respondsToSelector:@selector(mixListViewFinishLoad: isFinish :isUserPull:)]) {
        [_delegate mixListViewFinishLoad:self isFinish:finish isUserPull:userPull];
    }
    //通知其他模块监听者，列表加载完成
    NSDictionary *params = @{@"finish":@(finish), @"userPull":@(userPull), @"isGetMore":@(isGetMore)};
    [[TTModuleBridge sharedInstance_tt] notifyListenerForKey:@"MixedListBaseViewDidFinishLoad" object:self withParams:params complete:nil];
}

- (void)reportDelegateCancelRequest
{
    if (_delegate && [_delegate respondsToSelector:@selector(mixListViewCancelRequest:)]) {
        [_delegate mixListViewCancelRequest:self];
    }
}

- (void)tryPreload {
    [_preloadTimer invalidate];
    
    self.preloadTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                         target:self
                                                       selector:@selector(preload)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)preload {
    [self preloadMore];
    [self preloadDetail];
}

- (void)suspendPreloadDetail {
    [[NewsFetchArticleDetailManager sharedManager] suspendAllRequests];
}

- (void)preloadDetail {
    if(TTNetworkConnected() && [_fetchListManager.items count] > 0)
    {
        NSArray *visibleCells = [_listView visibleCells];
        if([visibleCells count] > 0) {
            NSMutableArray <ExploreOrderedData *> * visibleExploreOrderData = [NSMutableArray array];
            [visibleCells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[ExploreCellBase class]]
                    && [[(ExploreCellBase *)obj cellData] isKindOfClass:[ExploreOrderedData class]]) {
                    [visibleExploreOrderData addObject:[(ExploreCellBase *)obj cellData]];
                }
            }];
            
            if (visibleExploreOrderData.count > 0) {
                //多预加载屏幕下方n条数据
                NSUInteger morePreloadCount = [ExploreListHelper countForPreloadCell];
                NSUInteger lastDataIndex = [_fetchListManager.items indexOfObject:visibleExploreOrderData.lastObject];
                for (NSUInteger moreCount = 1; moreCount <= morePreloadCount; moreCount ++) {
                    if (lastDataIndex + moreCount < _fetchListManager.items.count) {
                        ExploreOrderedData * morePreloadData = [_fetchListManager.items objectAtIndex:lastDataIndex + moreCount];
                        if ([morePreloadData isKindOfClass:[ExploreOrderedData class]]) {
                            [visibleExploreOrderData addObject:morePreloadData];
                        }
                    }
                }
            }
            
            [visibleExploreOrderData enumerateObjectsUsingBlock:^(ExploreOrderedData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSUInteger itemsIndex = [_fetchListManager.items indexOfObject:obj];
                if (NSNotFound != itemsIndex) {
                    [self preloadDetailAtIndex:itemsIndex];
                }
                [[NewsFetchArticleDetailManager sharedManager] resumeAllRequests];
            }];
        }
    }
}

- (void)preloadDetailAtIndex:(NSInteger)index {
    if (index >= [_fetchListManager.items count]) {
        return;
    }
    id obj = [_fetchListManager.items objectAtIndex:index];
    
    if([obj isKindOfClass:[ExploreOrderedData class]] && [((ExploreOrderedData *)obj).originalData isKindOfClass:[Article class]]) {
        ExploreOrderedData * orderedData = (ExploreOrderedData *)obj;
        Article * article = (Article *)orderedData.originalData;
        if (article) {
            [TTAdManageInstance preloadWebRes_preloadResource:orderedData];
            
        }
        if (article && article.articleType == ArticleTypeWebContent) {//预加载wap类型详情页
            
            // 客户端处于wifi环境下，预加载类型为ArticlePreloadWebTypeOnlyWifiAndAds，代表是建站广告预加载，并且广告ID不为0
            if (TTNetworkWifiConnected() && article.preloadWeb == ArticlePreloadWebTypeOnlyWifiAndAds && !isEmptyString(orderedData.ad_id)) {
                [[TTAdSiteWebPreloadManager sharedManager] adSiteWebPreload:article listView:self];
            }
        } else if (![article isContentFetched]) {//预加载转码页
            //LOGD(@"preload: %@", article.title);
            if ([SSCommonLogic CDNBlockEnabled]) {
                [[NewsFetchArticleDetailManager sharedManager] fetchDetailForArticle:article withPriority:NSOperationQueuePriorityVeryLow forceLoadNative:NO completion:nil];
            } else {
                [[NewsFetchArticleDetailManager sharedManager] fetchDetailForArticle:article withOperationPriority:NSOperationQueuePriorityVeryLow notifyError:NO];
            }
        }
    }
    
}

- (void)preloadMore {
    if (_fetchListManager.lastFetchRiseError) {
        return;
    }
    if(!_fetchListManager.isLoading && TTNetworkConnected() &&
       _fetchListManager.loadMoreHasMore && [_fetchListManager.items count] > 0)
    {
        NSArray *visibleCells = [_listView visibleCells];
        if([visibleCells count] > 0)
        {
            __block id firstVisibleExploreCell = nil;
            [visibleCells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[ExploreCellBase class]]) {
                    firstVisibleExploreCell = obj;
                    *stop = YES;
                }
            }];
            
            if (firstVisibleExploreCell)
            {
                ExploreCellBase * cell = (ExploreCellBase *)firstVisibleExploreCell;
                id data = cell.cellData;
                if ([data isKindOfClass:[ExploreOrderedData class]]) {
                    ExploreOrderedData * orderData = (ExploreOrderedData *)data;
                    NSUInteger index = 0;
                    if (orderData) {
                        index = [[_fetchListManager items] indexOfObject:orderData];
                    }
                    NSInteger preloadMoreThreshold = kPreloadMoreThreshold;
                    if ([SSCommonLogic preloadmoreOutScreenNumber] > 0 && [SSCommonLogic preloadmoreOutScreenNumber] < 5) {
                        preloadMoreThreshold = [SSCommonLogic preloadmoreOutScreenNumber] + [visibleCells count];
                    }
                    if (index > 0 && index < [[_fetchListManager items] count] && [[_fetchListManager items] count] - index <= preloadMoreThreshold) {
                        // 统计 - preload
                        self.refreshFromType = ListDataOperationReloadFromTypePreLoadMore;
                        [self loadMoreWithUmengLabel:[self modifyEventLabelForRefreshEvent:@"pre_load_more"]];
                    }
                }
            }
        }
    }
}

- (void)preloadAdVideo
{
    if (!ttas_isAutoPlayVideoPreloadEnable()) {
        return;
    }
    NSArray *items = _fetchListManager.items;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (id obj in items) {
            if([obj isKindOfClass:[ExploreOrderedData class]] && [((ExploreOrderedData *)obj).originalData isKindOfClass:[Article class]]) {
                ExploreOrderedData *item = (ExploreOrderedData *)obj;
                if ([(ExploreOrderedData *)item couldAutoPlay] && !isEmptyString(item.article.videoID)) {
                    HandleType handler = [[TTVOwnPlayerPreloaderWrapper sharedPreloader] preloadVideoID:item.article.videoID];
                    TTAdPlayerPreloadModel *preloadModel = [[TTAdPlayerPreloadModel alloc] initWithAdId:item.adIDStr logExtra:item.logExtra handleType:handler];
                    [[TTVOwnPlayerPreloaderWrapper sharedPreloader] addAdPreloadItem:preloadModel];
                }
            }
        }
        
    });
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isFeedTipsShowStrategyEnable && self.remindView && !self.fetchListManager.isLoading) {
        if (self.remindView.type == NewsListTipsReminderViewTypeAuto) {
            if (scrollView.contentOffset.y < self.scrollViewOffsetY) {
                if (!self.remindView.isShowing && self.scrollViewOffsetY - scrollView.contentOffset.y > 100) {
                    [self.remindView show:NO];
                }
            } else {
                if (self.remindView.isShowing && scrollView.contentOffset.y - self.scrollViewOffsetY > 100) {
                    [self.remindView disappear];
                }
            }
        }
    }
    
//    [self addHouseItemHouseShowLog];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScrolling = YES;
    self.scrollViewOffsetY = scrollView.contentOffset.y;
    self.isFeedTipsShowStrategyEnable = [SSCommonLogic feedTipsShowStrategyEnable];
    
    [self suspendPreloadDetail];
    [[TTVideoAutoPlayManager sharedManager] cancelTrying];
    [[TTVAutoPlayManager sharedManager] cancelTrying];
    
  
    [TTFeedDislikeView dismissIfVisible];
    
    //按住RNCell滑动列表时需要主动调用RCTRootView的cancelTouches方法，否则松手后仍会触发点击事件
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTRNViewCancelTouchesNotification object:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.isScrolling = NO;
        [self dockHeaderViewBar];
        [self tryPreload];
        
        if ([_fetchListManager canSilentFetchItems] && scrollView.contentOffset.y > 2) {
            [self trySilentFetchIfNeeded];
        }
    }
    [[TTVideoAutoPlayManager sharedManager] tryAutoPlayInTableView:self.listView];
    [[TTVAutoPlayManager sharedManager] tryAutoPlayInTableView:self.listView];
    
    if (scrollView != self.listView) {
        
        return;
    }
    [self addHouseItemHouseShowLog];
}

-(void)addHouseItemHouseShowLog {
    
    NSArray *visibleCells = [self.listView visibleCells];
    if (visibleCells.count < 1) {
        return;
    }
    
    for (ExploreCellBase *cell in visibleCells) {
        
        if ([cell isKindOfClass:[FHFeedHouseItemCell class]]) {
            
            FHFeedHouseItemCell *houseCell = (FHFeedHouseItemCell *)cell;
            [houseCell addHouseShowLog];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isScrolling = NO;
    [self dockHeaderViewBar];
    [self tryPreload];
    
    if (self.listView && self.listView.pullDownView && self.listView.pullDownView.state != PULL_REFRESH_STATE_LOADING) {
        self.listView.pullDownView.state = PULL_REFRESH_STATE_INIT;
    }
    
    if ([_fetchListManager canSilentFetchItems] && scrollView.contentOffset.y > 2) {
        [self trySilentFetchIfNeeded];
    }
    
    if (scrollView != self.listView) {
        
        return;
    }
    
    [self addHouseItemHouseShowLog];

}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{

    [TTFeedDislikeView dismissIfVisible];
    if ([self.delegate respondsToSelector:@selector(mixListViewWillScrollToTop:)]) {
        [self.delegate mixListViewWillScrollToTop:self];
    }
    return YES;
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [[TTVideoAutoPlayManager sharedManager] clearAutoPlaying];
    [[TTVAutoPlayManager sharedManager] resetForce];
    
    _accountChangedNeedReadloadList = YES;
    
    [_fetchListManager cancelAllOperations];
    [_fetchListManager removeAllItems];
    
    [self tt_endUpdataData];
    if ([SSCommonLogic feedLoadingInitImageEnable]) {
        self.ttLoadingView.frame = CGRectZero;
    }
    [self.listView finishPullDownWithSuccess:NO];
    
    [self reloadListView];
}

#pragma mark - receive notification

- (void)connectionChanged:(NSNotification *)notification {
    if (_isDisplayView && self.ttErrorView && self.ttErrorView.hidden == NO && ![self tt_hasValidateData] && TTNetworkConnected()) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pullAndRefresh];
        });
    }
}

- (void)readModeChanged:(NSNotification*)notification
{
    [self reloadListViewWithVideoPlaying];
}

- (void)receiveCityDidChangedNotification:(NSNotification *)notification
{
    if ([_categoryID isEqualToString:kTTNewsLocalCategoryID]) {
        //本地频道变化，清掉concern_id
        _concernID = @"";
        [self dismissCityPopoverAnimated:YES];
        NSArray * array = _fetchListManager.items;
        [_fetchListManager removeAllItems];
        [self reloadListViewWithVideoPlaying];
        [ExploreLogicSetting removeOrderedDatas:array save:NO];
        [ExploreLogicSetting clearDBNewsLocalDataSave:YES];
        self.refreshShouldLastReadUpate = YES;
        [self pullAndRefresh];
        
    }
}

- (void)receiveRNCellActiveRefreshListNotification:(NSNotification *)notification
{
    if (_isDisplayView) {
        [self pullAndRefresh];
    }
}

- (void)receiveItemDeleteNotification:(NSNotification *)notification
{
    id item = [[notification userInfo] objectForKey:kExploreMixListDeleteItemKey];
    if ([item isKindOfClass:[ExploreOrderedData class]]) {
        BOOL isCategoryIDEqual = !isEmptyString(((ExploreOrderedData *)item).categoryID) && !isEmptyString(self.categoryID) && [((ExploreOrderedData *)item).categoryID isEqualToString:self.categoryID];
        BOOL isConcernIDEqual = !isEmptyString(((ExploreOrderedData *)item).concernID) && !isEmptyString(self.concernID) && [((ExploreOrderedData *)item).concernID isEqualToString:self.concernID];
        
        if (isCategoryIDEqual == NO && isConcernIDEqual == NO) {
            return;
        }
        if ([[_fetchListManager items] containsObject:item]) {
            [_fetchListManager removeItemIfExist:item];
            [self reloadListViewWithVideoPlaying];
        }
    }
}

#pragma mark --AD

- (void)removeExpireADs {
    NSArray *items = [_fetchListManager items];
    NSMutableArray *removes = [NSMutableArray arrayWithCapacity:2];
    [items enumerateObjectsUsingBlock:^(ExploreOrderedData *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ExploreOrderedData class]] ) {
            if ([obj isAdExpire]) {
                [removes addObject:obj];
            }
        }
    }];
    if (removes.count > 0) {
        void(^ removeOrderedDataBlock)(void) = ^{
            //需要先发出notification， 再删除数据库
            [removes enumerateObjectsUsingBlock:^(ExploreOrderedData * obj, NSUInteger idx, BOOL *stop) {
                ExploreOriginalData *originalData = (ExploreOriginalData *)obj.originalData;
                NSMutableDictionary * userInfo1 = [NSMutableDictionary dictionaryWithCapacity:2];
                [userInfo1 setValue:obj forKey:kExploreMixListDeleteItemKey];
                if ([originalData isKindOfClass:[Article class]]) {
                    [userInfo1 setValue:@(((Article *)originalData).uniqueID) forKey:@"uniqueID"];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListItemDeleteNotification object:nil userInfo:userInfo1];
                [_fetchListManager removeItemIfExist:obj];
            }];
            //            [[SSModelManager sharedManager] removeEntities:removes error:nil];
            
            [ExploreOrderedData removeEntities:removes];
        };
        
        if ([NSThread isMainThread]) {
            removeOrderedDataBlock();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                removeOrderedDataBlock();
            });
        }
    }
}

- (void)preloadAppStoreAd:(ExploreOrderedData* )orderData
{
    if (!(orderData && [orderData isKindOfClass:[ExploreOrderedData class]])) {
        return;
    }
    NSString* appleID = nil;
    ArticlePreloadWebType preloadWebType = ArticlePreloadWebTypeNoLoad;
    if (orderData.cellType == ExploreOrderedDataCellTypeAppDownload) {
        if (orderData.article && [orderData.article isKindOfClass:[Article class]]) {
            appleID = orderData.adModel.apple_id;
            preloadWebType = orderData.article.preloadWeb;
        }
    }
    else if (orderData.cellType == ExploreOrderedDataCellTypeArticle)
    {
        TTAdFeedModel *rawModel = orderData.raw_ad;
        if (orderData.article && [orderData.article isKindOfClass:[Article class]]) {
            if ([orderData.adModel.type isEqualToString:@"app"]) {
                appleID = orderData.adModel.apple_id;
                preloadWebType = orderData.article.preloadWeb;
            }
            else if(!isEmptyString(rawModel.apple_id)){
                appleID = rawModel.apple_id;
                preloadWebType = orderData.article.preloadWeb;
            }
        }
        
    }
    if (preloadWebType != ArticlePreloadWebTypeAppAd) {
        return;
    }
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:appleID forKey:@"apple_id"];
    [dict setValue:orderData.adModel.ad_id forKey:@"ad_id"];
    [dict setValue:orderData.adModel.log_extra forKey:@"log_extra"];
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance app_preloadAppStoreDict:dict];
}

- (void)setupDislikeTime
{
    [[TTLoginDialogStrategyManager sharedInstance] setFeedDislikeTime];
    
}

- (void)receiveNotInterestNotification:(NSNotification *)notification
{
    
    //统计dislike的点击次数，根据次数弹登录框
    [self setupDislikeTime];
    
    id item = [[notification userInfo] objectForKey:kExploreMixListNotInterestItemKey];
    //首页tab与视频tab同时存在一个相同的频道video，在video频道做dislike操作时，需要将categoryID作为参数。
    //因为dislike时，会首先把首页tab的video频道的对应数据在数据库中抹去，这样当视频tab的video频道中接收到通知时，item的数据已经被抹去,无法获得item.categoryID
    NSString *categoryID = [[notification userInfo] objectForKey:kExploreMixListCategoryIDOfNotInterestItemKey];
    NSString *concernID = [[notification userInfo] objectForKey:kExploreMixListConcernIDOfNotInterestItemKey];
    BOOL shouldSendDislike = YES;
    if ([[notification userInfo] objectForKey:kExploreMixListShouldSendDislikeKey]) {
        shouldSendDislike = [[notification userInfo] tt_boolValueForKey:kExploreMixListShouldSendDislikeKey];
    }
    
    ExploreOrderedData *orderData = nil;//被dislike的数据
    ExploreOrderedData *dislikeOrderedDataInCard = nil;
    if ([item isKindOfClass:[ExploreOrderedData class]]) {
        orderData = (ExploreOrderedData *)item;
        if ([orderData isInCard] && !isEmptyString(orderData.cardPrimaryID)) {
            //如果是卡片内的数据被dislike，orderData表示整个卡片，dislikeOrderedDataInCard暂存卡片内被dislike的数据，后面统计要用
            dislikeOrderedDataInCard = orderData;
            orderData = [ExploreOrderedData objectForPrimaryKey:orderData.cardPrimaryID];
            
        }
        BOOL isCategoryIDEqual = !isEmptyString(orderData.categoryID) && !isEmptyString(self.categoryID) && [orderData.categoryID isEqualToString:self.categoryID];
        BOOL isConcernIDEqual = !isEmptyString(orderData.concernID) && !isEmptyString(self.concernID) && [orderData.concernID isEqualToString:self.concernID];
        if (isCategoryIDEqual == NO && isConcernIDEqual == NO) {
            isCategoryIDEqual = !isEmptyString(categoryID) && !isEmptyString(self.categoryID) && [categoryID isEqualToString:self.categoryID];
            isConcernIDEqual = !isEmptyString(concernID) && !isEmptyString(self.concernID) && [concernID isEqualToString:self.concernID];
            if (isCategoryIDEqual == NO && isConcernIDEqual == NO) {
                return;
            }
        }
    }
    else {
        if (notification.object) {
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:NSStringFromClass(notification.object) forKey:@"class"];
            [[TTMonitor shareManager] trackService:@"dislike_not_work" status:1 extra:extra];
        }
        return;
    }
    
    NSInteger notInterestDataIndex = [[_fetchListManager items] indexOfObject:orderData];
    if (notInterestDataIndex == NSNotFound) {
        return;
    }
    NSInteger lastReadDataIndex = -1;
    if ([orderData respondsToSelector:@selector(nextCellType)] && [orderData respondsToSelector:@selector(preCellType)]) {
        if (orderData.nextCellType == ExploreOrderedDataCellTypeLastRead) {
            lastReadDataIndex = notInterestDataIndex + 1;
        }
        else if (orderData.preCellType == ExploreOrderedDataCellTypeLastRead) {
            lastReadDataIndex = notInterestDataIndex - 1;
        }
    }
    
    id lastReadOrderData = nil;
    if (lastReadDataIndex > 0) {
        lastReadOrderData = [[_fetchListManager items] objectAtIndex:lastReadDataIndex];
    }
    
    BOOL willDeleteLastItem = (notInterestDataIndex == [_fetchListManager items].count - 1) ? YES : NO;
    BOOL willDeleteFirstItem = (notInterestDataIndex == 0) ? YES : NO;
    BOOL topCellIsWebCell = [self isCategoryWithHeadInfo];
    BOOL willDeleteLastRead = NO;
    NSIndexPath * lastReadIndexPath = nil;
    
    /**
     *  三种情况需要删除lastReadCell
     *  1 dislike列表第一条cell，第二条是lastRead
     *  2 dislike列表第二条，第一条是webcell，第三条是lastRead
     *  3 dislike列表最后一条，倒数第二条是lastRead
     */
    if (lastReadDataIndex >= 0) {
        if( (lastReadDataIndex == 1 && willDeleteFirstItem) || (lastReadDataIndex == 2 && topCellIsWebCell && notInterestDataIndex == 1) || (lastReadDataIndex == [_fetchListManager items].count - 2 && willDeleteLastItem) ){
            [_fetchListManager removeItemForIndexIfExist:lastReadDataIndex];
            willDeleteLastRead = YES;
            lastReadIndexPath = [NSIndexPath indexPathForRow:lastReadDataIndex inSection:ExploreMixedListBaseViewSectionExploreCells];
        }
    }
    [_fetchListManager removeItemIfExist:orderData];
    
    if (_fetchListManager.items.count == 0) {
        if ([_listView numberOfSections] > ExploreMixedListBaseViewSectionExploreCells) {
            [_listView deleteSections:[NSIndexSet indexSetWithIndex:ExploreMixedListBaseViewSectionExploreCells] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:notInterestDataIndex inSection:ExploreMixedListBaseViewSectionExploreCells];
        NSMutableArray *shouldDeletedRows = [@[indexPath] mutableCopy];
        if (lastReadIndexPath != nil) {
            if (lastReadDataIndex > notInterestDataIndex) {
                [shouldDeletedRows addObject:lastReadIndexPath];
            }
            else{
                [shouldDeletedRows insertObject:lastReadIndexPath atIndex:0];
            }
        }
        
        @try {
            [_listView deleteRowsAtIndexPaths:shouldDeletedRows withRowAnimation:UITableViewRowAnimationFade];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
        /**
         *  分两种情况需要reloadCell
         *  1 将lastRead删除时，需要更新lastread和dislike的cell整体被删除后的上下两个cell
         *  2 lastRead没被删除时，需要更新dislike的cell上面的cell
         *  不reload webcell和RNCell
         */
        
        NSMutableArray *shouldReloadCellIndexPaths = [NSMutableArray arrayWithCapacity:5];
        
        NSInteger lessDataIndex = notInterestDataIndex;
        if (lastReadDataIndex >= 0 && lastReadDataIndex < notInterestDataIndex) {
            lessDataIndex = lastReadDataIndex;
        }
        
        if (lessDataIndex - 1 >= 0 && lessDataIndex - 1 < [_fetchListManager items].count) {
            ExploreOrderedData *orderData = [[_fetchListManager items] objectAtIndex:lessDataIndex - 1];
            if (!(orderData.cellType == ExploreOrderedDataCellTypeWeb ||
                  orderData.cellType == ExploreOrderedDataCellTypeRN ||
                  orderData.cellType == ExploreOrderedDataCellTypeInterestGuide ||
                  orderData.cellType == ExploreOrderedDataCellTypeDynamicRN)) {
                [shouldReloadCellIndexPaths addObject:[NSIndexPath indexPathForRow:lessDataIndex - 1 inSection:ExploreMixedListBaseViewSectionExploreCells]];
            }
        }
        if (willDeleteLastRead && lastReadDataIndex >= 0 && lessDataIndex >= 0 && lessDataIndex < [_fetchListManager items].count) {
            ExploreOrderedData *orderData = [[_fetchListManager items] objectAtIndex:lessDataIndex];
            if (!(orderData.cellType == ExploreOrderedDataCellTypeWeb ||
                  orderData.cellType == ExploreOrderedDataCellTypeRN ||
                  orderData.cellType == ExploreOrderedDataCellTypeInterestGuide ||
                  orderData.cellType == ExploreOrderedDataCellTypeDynamicRN)) {
                [shouldReloadCellIndexPaths addObject:[NSIndexPath indexPathForRow:lessDataIndex inSection:ExploreMixedListBaseViewSectionExploreCells]];
            }
        }
        if (shouldReloadCellIndexPaths.count > 0) {
            [_listView reloadRowsAtIndexPaths:shouldReloadCellIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    
    ExploreOrderedData *lastRead = nil;
    if ((lastReadDataIndex == 1 || lastReadDataIndex == 2) && willDeleteLastRead && [lastReadOrderData isKindOfClass:[ExploreOrderedData class]]) {//将上次看到这model从coredata中移除
        lastRead = (ExploreOrderedData *)lastReadOrderData;
        if ([lastRead.originalData isKindOfClass:[LastRead class]]) {
            [ExploreItemActionManager removeOrderedData:lastReadOrderData];
        }
    }
    
    NSString * title = nil;
    
    if ([TTAccountManager isLogin]) {
        title = kNotInterestTipUserLogined;
    } else {
        title = kNotInterestTipUserUnLogined;
    }
    
    NSNumber *hideTip = [[notification userInfo] objectForKey:kExploreMixListNotDisplayTipKey];
    if ([hideTip isKindOfClass:[NSNumber class]] && [hideTip boolValue]) {
        title = nil;
    }
    
    BOOL isCloseAction = NO;
    NSString *action = [[notification userInfo] tt_stringValueForKey:@"action"];
    if ([action isEqualToString:@"close"]) {
        isCloseAction = YES;
    }
    
    if ([orderData isKindOfClass:[ExploreOrderedData class]]) {
        if (dislikeOrderedDataInCard && [dislikeOrderedDataInCard isKindOfClass:[ExploreOrderedData class]]){//dislike卡片内的数据时，统计仍然发卡片内的数据的统计
            self.notInterestingData = dislikeOrderedDataInCard;
        } else {
            self.notInterestingData = orderData;
        }
        
        if (self.notInterestingData.originalData && self.notInterestingData.originalData.uniqueID != 0) {
            //added5.2：dislike后设置originalData的notInterested
            if (!isCloseAction) {
                [self setNotInterestToOrderedData:self.notInterestingData];
            }
            
            NSArray *filterWords = [[notification userInfo] objectForKey:kExploreMixListNotInterestWordsKey];
            
            NSString *shortVideoID = nil;
            if ([self.notInterestingData.originalData isKindOfClass:[TSVShortVideoOriginalData class]]) {
                TSVShortVideoOriginalData *shortVideoOriginalData = self.notInterestingData.shortVideoOriginalData;
                shortVideoID = shortVideoOriginalData.shortVideo.itemID;
            }
            
            NSMutableDictionary *adExtra = [[NSMutableDictionary alloc] init];
            
            if (self.notInterestingData.cellType == ExploreOrderedDataCellTypeAppDownload) {
                [adExtra setValue:self.notInterestingData.originalData.hasRead forKey:@"clicked"];
            }
            
            NSNumber *ad_id = isEmptyString(self.notInterestingData.ad_id)? nil : @(self.notInterestingData.ad_id.longLongValue);
            [adExtra setValue:self.notInterestingData.log_extra forKey:@"log_extra"];
            
            NSString *widgetID = nil;
            if ([self.notInterestingData.originalData isKindOfClass:[WapData class]]) {
                WapData *wapData = self.notInterestingData.wapData;
                widgetID = [@(wapData.uniqueID) stringValue];
            }
            
//            NSString *threadID = nil;
//            if ([self.notInterestingData.originalData isKindOfClass:[Thread class]]) {
//                Thread *thread = self.notInterestingData.thread;
//                threadID = [@(thread.uniqueID) stringValue];
//            }
            
            NSString *cardID = nil;
            if ([self.notInterestingData.originalData isKindOfClass:[Card class]]) {
                Card *card = self.notInterestingData.card;
                cardID = [@(card.uniqueID) stringValue];
                if (!isCloseAction && shouldSendDislike) {
                    [self.itemActionManager startSendDislikeActionType:DetailActionTypeNewVersionDislike groupModel:nil filterWords:filterWords cardID:cardID actionExtra:card.actionExtra adID:nil adExtra:nil widgetID:nil threadID:nil finishBlock:nil];
                }
            }
            else {
                TTGroupModel *groupModel = [[TTGroupModel alloc] init];
                NSString *groupId = [NSString stringWithFormat:@"%lld", self.notInterestingData.originalData.uniqueID];
                if ([self.notInterestingData.article respondsToSelector:@selector(itemID)]) {
                    groupModel = [[TTGroupModel alloc] initWithGroupID:groupId itemID:self.notInterestingData.article.itemID impressionID:nil aggrType:[self.notInterestingData.article.aggrType integerValue]];
                }
                else if ([self.notInterestingData.originalData isKindOfClass:[TSVShortVideoOriginalData class]]) {
                    groupModel = [[TTGroupModel alloc] initWithGroupID:groupId itemID:shortVideoID impressionID:nil aggrType:0];
                }
                else {
                    groupModel = [[TTGroupModel alloc] initWithGroupID:groupId];
                }
                
                if (!isCloseAction && shouldSendDislike) {
                    TTDislikeSourceType sourceType;
                    if ([[notification userInfo] tt_intValueForKey:@"dislike_source"] == 0) {
                        sourceType = TTDislikeSourceTypeFeed;
                    }
                    else {
                        sourceType = TTDislikeSourceTypeDetail;
                    }
                    [self.itemActionManager startSendDislikeActionType:DetailActionTypeNewVersionDislike source:sourceType groupModel:groupModel filterWords:filterWords cardID:nil actionExtra:self.notInterestingData.actionExtra adID:ad_id adExtra:adExtra widgetID:widgetID threadID:nil finishBlock:nil];
                }
            }
            
            [ExploreItemActionManager removeOrderedData:self.notInterestingData];
        }
        self.notInterestingData = nil;
        
        [self tt_endUpdataData:NO error:nil tip:title duration:kDefaultDismissDuration tipTouchBlock:nil];
        if ([SSCommonLogic feedLoadingInitImageEnable]) {
            self.ttLoadingView.frame = CGRectZero;
        }
    }
    
}

- (void)receivePublishCommentWithZZNotification:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    BOOL isZZ = [[dict objectForKey:@"is_zz"] boolValue];
    if (isZZ) {
        //如果是头条号作者推荐给粉丝的评论，更新article的zzcomments
        NSString *commentText = [dict stringValueForKey:@"text" defaultValue:nil];
        NSString *commentID = [dict stringValueForKey:@"comment_id" defaultValue:nil];
        NSString *groupID = [dict stringValueForKey:@"group_id" defaultValue:nil];
        NSInteger index = NSNotFound;
        Article *article = nil;
        for (id item in _fetchListManager.items) {
            if ([item isKindOfClass:[ExploreOrderedData class]]) {
                ExploreOrderedData *orderedData = item;
                if ([orderedData.article.groupModel.groupID isEqualToString:groupID]) {
                    index = [_fetchListManager.items indexOfObject:item];
                    article = orderedData.article;
                    break;
                }
            }
        }
        
        if (index != NSNotFound && article) {
            NSMutableDictionary *zzcomment = [NSMutableDictionary dictionary];
            NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];
            PGCAccount *account = [[PGCAccountManager shareManager] currentLoginPGCAccount];
            [mediaInfo setValue:account.screenName forKey:@"name"];
            [mediaInfo setValue:account.mediaID forKey:@"media_id"];
            [zzcomment setValue:mediaInfo forKey:@"media_info"];
            [zzcomment setValue:commentText forKey:@"text"];
            [zzcomment setValue:commentID forKey:@"comment_id"];
            
            NSMutableArray *orizzcomments = [article.zzComments mutableCopy];
            if (orizzcomments.count) {
                [orizzcomments insertObject:zzcomment atIndex:0];
            }
            else {
                if (!orizzcomments) {
                    orizzcomments = [NSMutableArray array];
                }
                [orizzcomments addObject:zzcomment];
            }
            article.zzComments = [orizzcomments copy];
            
            //reload cell并持久化数据
            [self reloadListViewWithVideoPlaying];
        }
    }
}

- (void)receiveDeleteZZCommentNotification:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    NSString *commentID = [dict stringValueForKey:@"comment_id" defaultValue:nil];
    NSString *groupID = [dict stringValueForKey:@"group_id" defaultValue:nil];
    NSInteger index = NSNotFound;
    Article *article = nil;
    for (id item in _fetchListManager.items) {
        if ([item isKindOfClass:[ExploreOrderedData class]]) {
            ExploreOrderedData *orderedData = item;
            if ([orderedData.article.groupModel.groupID isEqualToString:groupID]) {
                index = [_fetchListManager.items indexOfObject:item];
                article = orderedData.article;
                break;
            }
        }
    }
    if (index != NSNotFound && article) {
        NSInteger idx = NSNotFound;
        for (NSDictionary * zzInfo in article.zzComments) {
            if ([[zzInfo stringValueForKey:@"comment_id" defaultValue:nil] isEqualToString:commentID]) {
                idx = [article.zzComments indexOfObject:zzInfo];
                break;
            }
        }
        if (idx != NSNotFound) {
            NSMutableArray *orizzcomments = [article.zzComments mutableCopy];
            if (idx < orizzcomments.count) {
                [orizzcomments removeObjectAtIndex:idx];
                article.zzComments = [orizzcomments copy];
                
                [self reloadListViewWithVideoPlaying];
            }
        }
    }
}

-(void)appDidBeComeactive:(NSNotification *)notify{
    [self resumeTrackAdCellsInVisibleCells];
    self.isInBackground = NO;
    
    if (self.remindView) {
        self.remindView.isInBackground = NO;
        if (_isShowing) {
            [self.remindView show:YES];
        }
    }
}

-(void)appDidEnterBackground:(NSNotification *)notify{
    [self suspendTrackAdCellsInVisibleCells];
    self.isInBackground = YES;
    
    if (self.remindView) {
        self.remindView.isInBackground = YES;
    }
}

- (void)fontChanged:(NSNotification *)notification
{
    [self reloadListViewWithVideoPlaying];
}

- (void)receiveCoreDataCacheClearedNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_accountChangedNeedReadloadList) {
            self.refreshShouldLastReadUpate = YES;
            [self pullAndRefresh];
        }
    });
}

- (void)clearCacheNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self clearListContent];
        if (_isDisplayView) {
            [self pullAndRefresh];
        }
    });
}

- (void)articleUpdated:(NSNotification *)notification {
    NSString * groupId = [[notification userInfo] objectForKey:@"uniqueID"];
    if (isEmptyString(groupId)) {
        return;
    }
    
    [self.fetchListManager.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            ExploreOrderedData *orderedData = (ExploreOrderedData *)obj;
            
            if (!orderedData.managedObjectContext ||
                !orderedData.originalData.managedObjectContext ||
                [[@(orderedData.originalData.uniqueID) stringValue] isEqualToString:groupId]) {
                [orderedData clearCachedCellType];
                [orderedData clearCacheHeight];
                [self reloadListViewWithVideoPlaying];
                *stop = YES;
            }
        }
    }];
}

- (void)webCellUpdated:(NSNotification *)notification {
    ExploreOrderedData *orderedData = [[notification userInfo] objectForKey:@"orderedData"];
    if (orderedData.managedObjectContext &&
        orderedData.originalData.managedObjectContext) {
        if (![orderedData.categoryID isEqualToString:self.categoryID]) {
            return;
        }
        
        NSInteger webDataIndex = [[_fetchListManager items] indexOfObject:orderedData];
        if (webDataIndex == NSNotFound) {
            return;
        }
        
        [self performReloadData];
    }
}

- (void)originalDataUpdate:(NSNotification *)notification {
    NSString * groupId = [[notification userInfo] objectForKey:@"uniqueID"];
    if (isEmptyString(groupId)) {
        return;
    }
    
    [self.fetchListManager.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            ExploreOrderedData *orderedData = (ExploreOrderedData *)obj;
            
            if (!orderedData.managedObjectContext ||
                !orderedData.originalData.managedObjectContext ||
                [[@(orderedData.originalData.uniqueID) stringValue] isEqualToString:groupId]) {
                [orderedData clearCachedCellType];
                [orderedData clearCacheHeight];
                [self reloadListViewWithVideoPlaying];
                *stop = YES;
            } else {
//                if (orderedData.surveyListData && [groupId isEqualToString:@"survey_list_reload"]) {
//                    [self reloadListViewWithVideoPlaying];
//                    *stop = YES;
//                }
//
//                if (orderedData.surveyPairData && [groupId isEqualToString:@"survey_pair_reload"]) {
//                    [self reloadListViewWithVideoPlaying];
//                    *stop = YES;
//                }
                
//                if (orderedData.surveyListData && [groupId isEqualToString:@"survey_list"]) {
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [self reloadListViewWithVideoPlaying];
//                        CGPoint p = _listView.contentOffset;
//                        [_listView setContentOffset:CGPointMake(0, p.y - orderedData.surveyListData.height)];
//                    });
//                    *stop = YES;
//                }
//
//                if (orderedData.surveyPairData && [groupId isEqualToString:@"survey_pair"]) {
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [self reloadListViewWithVideoPlaying];
//                        CGPoint p = _listView.contentOffset;
//                        [_listView setContentOffset:CGPointMake(0, p.y - orderedData.surveyPairData.height)];
//                    });
//                    *stop = YES;
//                }
            }
        }
    }];
}

- (void)recommendChannelAutoUpdate:(NSNotification *)notification {
    if ([self isNewTab]) {
        [self pullAndRefresh];
    }
}

#pragma mark -- auto reload

- (void)tryAutoReloadIfNeed
{
    BOOL shouldReloadAfterEnterForground = [self shouldReloadBackAfterLeaveCurrentCategory];
    
    if(([[NewsListLogicManager shareManager] shouldAutoReloadFromRemoteForCategory:self.categoryID] && [_fetchListManager.items count] > 0) || shouldReloadAfterEnterForground) {
        self.refreshShouldLastReadUpate = YES;
        self.refreshFromType = ListDataOperationReloadFromTypeAutoFromBackground;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixedListRefreshTypeNotification object:self userInfo:@{@"refresh_reason" : @(ExploreMixedListRefreshTypeAutoRefresh)}];
        
        [self pullAndRefresh];
    }
}

- (void)saveLeaveCurrentCategoryDate
{
    //离开时触发
    //关注频道多存一份，给红点逻辑使用
    if ([self.primaryKey isEqualToString:kTTFollowCategoryID]) {
        [NewsListLogicManager saveDisappearDateForFollowCategory];
    }


    NSTimeInterval refreshInterval = [SSCommonLogic getAutoRefreshIntervalForCategoryID:self.primaryKey];
    if (!_isClickCellLeaveList && refreshInterval > 0){
        [NewsListLogicManager saveDisappearDateForCategoryID:self.primaryKey];
    }
}

- (BOOL)shouldReloadBackAfterLeaveCurrentCategory
{
    BOOL shouldReload = NO;
    NSTimeInterval interval = [SSCommonLogic getAutoRefreshIntervalForCategoryID:self.primaryKey];
    if (!isEmptyString(self.primaryKey) && interval > 0) {
        NSTimeInterval timeInterval = [NewsListLogicManager listDisappearIntercalForCategoryID:self.primaryKey];
        if (timeInterval > interval) {
            shouldReload = YES;
        }
    }
    return shouldReload;
}

#pragma mark -- auto tip
- (TTExploreMixedListUpdateTipType)tipRemoteType
{
    return [NewsListLogicManager tipListUpdateUseTabbarOfCategoryID:self.primaryKey
                                                       listLocation:_listLocation];
}

- (BOOL)needShowRemoteAutoTip
{
    return _listType == ExploreOrderedDataListTypeCategory;
}

- (void)tryFetchTipIfNeedWithForce:(BOOL)force {
    // 启动首次请求时读取预加载数据，此时展示红点；否则走原有逻辑
    BOOL canShow = [TTFeedPreloadTask preloadInvalid] ? _isShowing : YES;
    if (_isDisplayView && canShow && [self needShowRemoteAutoTip] && TTExploreMixedListUpdateTipTypeNone != [self tipRemoteType]) {
        if (force || [[NewsListLogicManager shareManager] shouldFetchReloadTipForCategory:self.primaryKey]) {
            [self fetchRemoteReloadTip];
        }
        else {
            [self fetchRemoteReloadTipLater];
        }
    }
}

- (void)fetchRemoteReloadTip {
    if ([self.categoryID isEqualToString:kTTWeitoutiaoCategoryID] && self.listLocation == ExploreOrderedDataListLocationWeitoutiao) {
        NSArray * items = nil;
        //列表是处于第三个tab的微头条
        if ([_fetchListManager.items count] > 0) {
            //列表有数据，使用列表中的数据
            items = _fetchListManager.items;
        }else {
            if (TTExploreMixedListUpdateTipTypeTabbarRedPoint == [self tipRemoteType]) {
                //红点展示，列表中无数据，查数据库
                NSMutableDictionary * queryDict = @{}.mutableCopy;
                if (self.listType == ExploreOrderedDataListTypeCategory) {
                    [queryDict setValue:self.categoryID forKey:@"categoryID"];
                    [queryDict setValue:self.concernID forKey:@"concernID"];
                }
                [queryDict setValue:@(self.listType) forKey:@"listType"];
                [queryDict setValue:@(self.listLocation) forKey:@"listLocation"];
                items = [ExploreOrderedData objectsWithQuery:queryDict orderBy:@"orderIndex DESC" offset:0 limit:1];
            }else {
                //蓝条显示，列表中无数据，返回（避免出现用户进入微头条，列表无内容，但是显示蓝条的怪异现象）
                return;
            }
        }
        __block ExploreOrderedData * orderedData = nil;
        [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                orderedData = obj;
                *stop = YES;
            }
        }];
        NSTimeInterval minBehotTime = 0;
        if (orderedData) {
            minBehotTime = [orderedData behotTime];
        }else {
            //如果一条数据都没有，使用五天前的behot time
            minBehotTime = ([[NSDate date] timeIntervalSinceNow] - 5.f * 24.f * 60.f * 60.f)*1000;
        }
        [[NewsListLogicManager shareManager] fetchReloadTipWithMinBehotTime:minBehotTime categoryID:self.primaryKey count:ListDataDefaultRemoteNormalLoadCount];
    }else if ([_fetchListManager.items count] > 0) {
        __block ExploreOrderedData * orderedData = nil;
        [_fetchListManager.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                orderedData = obj;
                *stop = YES;
            }
        }];
        NSTimeInterval minBehotTime =  [orderedData behotTime];
        [[NewsListLogicManager shareManager] fetchReloadTipWithMinBehotTime:minBehotTime categoryID:self.primaryKey count:ListDataDefaultRemoteNormalLoadCount];
    }
}
- (void)fetchRemoteReloadTipLater {
    [[NewsListLogicManager shareManager] beginFetchRemoteReloadTipCountDownForCategoryID:self.primaryKey];
}

- (void)receiveFetchRemoteReloadTipNotification:(NSNotification *)notification {
    NSString * cID = [[notification userInfo] objectForKey:@"categoryID"];
    if ([cID isEqualToString:self.primaryKey]) {
        [self fetchRemoteReloadTip];
    }
}

- (void)receiveFirstRefreshTipNotification:(NSNotification *)notification {
    //不是当前正在展示的列表页则忽略 或者 如果是第三个tab的微头条也忽略
    if (!_isDisplayView || ([self.categoryID isEqualToString:kTTWeitoutiaoCategoryID] && self.listLocation == ExploreOrderedDataListLocationWeitoutiao))
        return;
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval delaySeconds = [userInfo tt_doubleValueForKey:@"delaySceonds"];
    if (delaySeconds < 0) {
        delaySeconds = 0;
    }
    
    NSString *primaryKey = self.primaryKey;
    
    if ([_fetchListManager.items count] > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([primaryKey isEqualToString:self.primaryKey] && _isDisplayView) {
                [self fetchRemoteReloadTip];
            } else {
                NSDictionary *userInfo = @{@"delaySceonds":@(0)};
                [[NSNotificationCenter defaultCenter] postNotificationName:kFirstRefreshTipsSettingEnabledNotification object:nil userInfo:userInfo];
            }
        });
    } else {
        WeakSelf;
        [self.KVOController observe:self.fetchListManager keyPath:@"isLoading" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            StrongSelf;
            if (((NSNumber *)change[NSKeyValueChangeNewKey]).boolValue == NO && [_fetchListManager.items count] > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([primaryKey isEqualToString:self.primaryKey] && _isDisplayView) {
                        [self fetchRemoteReloadTip];
                    } else {
                        NSDictionary *userInfo = @{@"delaySceonds":@(0)};
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFirstRefreshTipsSettingEnabledNotification object:nil userInfo:userInfo];
                    }
                    [self.KVOController unobserve:self.fetchListManager];
                });
            }
        }];
    }
}

- (void)receiveShowRemoteReloadTipNotification:(NSNotification *)notification {
    NSString * cID = [[notification userInfo] objectForKey:@"categoryID"];
    
    if ([cID isEqualToString:self.primaryKey]) {
        NSString * tipInfoString = [[notification userInfo] objectForKey:@"tip"];
        NSUInteger count = [[[notification userInfo] objectForKey:@"count"] intValue];
        NSUInteger style = [[[notification userInfo] objectForKey:@"style"] intValue];
        BOOL useDotStyle = (style == 1);
        if ([self.categoryID isEqualToString:kTTWeitoutiaoCategoryID]) {
            useDotStyle = YES;
        }
        
        switch ([self tipRemoteType]) {
            case TTExploreMixedListUpdateTipTypeTabbarRedPoint: {
                WeakSelf;
                if (_isDisplayView && _isShowing) {
                    if (_isFeedTipsShowStrategyEnable && self.remindView.enabled && count > 0 && tipInfoString.length > 0) {
                        if (self.remindView.type == NewsListTipsReminderViewTypeShowOnce) {
                            self.remindView.disappearActionBlock = ^(BOOL finished){
                                StrongSelf;
                                if (count > 0) {
                                    [self notifyTipCount:count useDotStyle:useDotStyle withTabTag:[TTTabBarProvider currentSelectedTabTag]];
                                } else {
                                    [self clearTipCount];
                                }
                            };
                        }
                    } else {
                        if (count > 0) {
                            [self notifyTipCount:count useDotStyle:useDotStyle forTag:[TTTabBarProvider currentSelectedTabTag]];
                        }else {
                            [self clearTipCount];
                        }
                    }
                }
                
                [[NewsListLogicManager shareManager] updateLastFetchReloadTipTimeForCategory:self.primaryKey];
                [self fetchRemoteReloadTipLater];
            }
                break;
            case TTExploreMixedListUpdateTipTypeBlueBar: {
                if (isEmptyString(tipInfoString)) {
                    [self hideRemoteReloadTip];
                }else {
                    [self showRemoteReloadTip:tipInfoString];
                }
                [[NewsListLogicManager shareManager] updateLastFetchReloadTipTimeForCategory:self.primaryKey];
                [self fetchRemoteReloadTipLater];
            }
                break;
            default:
                break;
        }
    }
}

- (void)showRemoteReloadTip:(NSString *)tipString {
    
    __weak __typeof__(self) wself = self;
    
    [self tt_endUpdataData:NO error:nil tip:tipString duration: [NewsListLogicManager shareManager].listTipDisplayInterval tipTouchBlock:^{
        [wself showRemoteReloadHasMessageNotifyBarViewClicked];
    }];
    if ([SSCommonLogic feedLoadingInitImageEnable]) {
        self.ttLoadingView.frame = CGRectZero;
    }
}

- (void)showRemoteReloadHasMessageNotifyBarViewClicked {
    [self hideRemoteReloadTip];
    
    self.refreshShouldLastReadUpate = YES;
    self.refreshFromType = ListDataOperationReloadFromTypeTip;
    [self pullAndRefresh];
    
    
    [self trackEventForLabel:@"tip_refresh"];
    
    NSMutableDictionary * tipRefreshTrackerDic = [NSMutableDictionary dictionaryWithCapacity:10];
    [tipRefreshTrackerDic setValue:@"umeng" forKey:@"category"];
    [tipRefreshTrackerDic setValue:self.categoryID forKey:@"category_id"];
    [tipRefreshTrackerDic setValue:self.concernID forKey:@"concern_id"];
    [tipRefreshTrackerDic setValue:@(self.refer) forKey:@"refer"];
    if ([self.categoryID isEqualToString:kTTMainCategoryID]) {
        [tipRefreshTrackerDic setValue:@"new_tab" forKey:@"tag"];
        [tipRefreshTrackerDic setValue:@"tip_refresh" forKey:@"label"];
        [TTTrackerWrapper eventData:tipRefreshTrackerDic];
    }
    else {
        if (!isEmptyString(self.categoryID)) {
            [tipRefreshTrackerDic setValue:@"category" forKey:@"tag"];
            [tipRefreshTrackerDic setValue:[NSString stringWithFormat:@"tip_refresh_%@", self.categoryID] forKey:@"label"];
            [TTTrackerWrapper eventData:tipRefreshTrackerDic];
        }
    }
    wrapperTrackEvent(@"category", @"refresh_tip_all");
}

- (void)hideRemoteReloadTip {
    switch ([self tipRemoteType]) {
        case TTExploreMixedListUpdateTipTypeTabbarRedPoint: {
            [self clearTipCount];
        }
            break;
        case TTExploreMixedListUpdateTipTypeBlueBar: {
            [[NewsListLogicManager shareManager] updateLastFetchReloadTipTimeForCategory:_categoryID];
        }
            break;
        default:
            break;
    }
}
/**
 *  提示更新数，发送给tabbar
 *
 *  @param count    更新的数字
 *  @param dotStyle YES用红点，NO 用数字
 */
- (void)notifyTipCount:(NSInteger)count useDotStyle:(BOOL)dotStyle forTag:(NSString *)tag
{
    if (isEmptyString(tag)) {
        return;
    }
    
    if (![[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey] && (![[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabFollowTabKey] || [TTTabBarProvider isFollowTabOnTabBar] || [TTTabBarProvider isHTSTabOnTabBar])) {
        return;
    }
    
    if (count > 0) {
        if (dotStyle) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeExploreTabBarBadgeNumberNotification object:nil userInfo:@{kExploreTabBarItemIndentifierKey:tag, kExploreTabBarDisplayRedPointKey:@(YES)}];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeExploreTabBarBadgeNumberNotification object:nil userInfo:@{kExploreTabBarItemIndentifierKey:tag, kExploreTabBarBadgeNumberKey:@(count)}];
        }
    }
}

- (void)notifyTipCount:(NSInteger)count useDotStyle:(BOOL)dotStyle withTabTag:(NSString *)curTag
{
    if (![curTag isEqualToString:[TTTabBarProvider currentSelectedTabTag]]) {
        return;
    }
    
          [self notifyTipCount:count useDotStyle:dotStyle forTag:curTag];
}

- (void)clearTipCount {
    NSString *tag = [TTTabBarProvider currentSelectedTabTag];
    
    if (![[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey] && ([[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabFollowTabKey] || [TTTabBarProvider isFollowTabOnTabBar])) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeExploreTabBarBadgeNumberNotification object:nil userInfo:@{kExploreTabBarItemIndentifierKey:tag, kExploreTabBarBadgeNumberKey:@(0)}];
}

#pragma mark - DisplayMessage

- (void)displayMessage:(NSString*)msg withImage:(UIImage*)image {
    [self displayMessage:msg withImage:image duration:.5f];
}

- (void)displayMessage:(NSString*)msg withImage:(UIImage*)image duration:(float)duration {
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:image autoDismiss:YES dismissHandler:nil];
}

#pragma mark -- SSImpressionProtocol

- (void)needRerecordImpressions {
    
    if ([_fetchListManager.items count] == 0) {
        return;
    }
    
    for (UITableViewCell * cell in [_listView visibleCells]) {
        if ([cell isKindOfClass:[ExploreCellBase class]]) {
            ExploreCellBase * cellBase = (ExploreCellBase *)cell;
            if ([cellBase.cellData isKindOfClass:[ExploreOrderedData class]]) {
                ExploreOrderedData * orderedData = (ExploreOrderedData *)cellBase.cellData;
                SSImpressionStatus status = (self.isDisplayView && _isShowing) ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
                [self recordGroupForExploreOrderedData:orderedData status:status cellBase:cellBase];
            }
        }
    }
}

// cell的model变动时，列表需要刷新cell显示
- (void)reloadVisibleCellsIfNeeded {
    NSArray *visibleCells = [_listView visibleCells];
    for (id obj in visibleCells) {
        if ([obj isKindOfClass:[ExploreCellBase class]]) {
            ExploreCellBase * cellBase = (ExploreCellBase *)obj;
            if ([cellBase shouldRefesh]) {
                [self reloadListViewWithVideoPlaying];
                break;
            }
        }
    }
}

- (void)subscribeStatusChangedNotification:(NSNotification*)notification {
    ExploreEntry * item = [notification.userInfo objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    
    [self.fetchListManager.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            ExploreOrderedData *orderedData = (ExploreOrderedData *)obj;
            
            if (orderedData.managedObjectContext) {
                Article *article = orderedData.article;
                NSString *mediaId = [article.mediaInfo tt_stringValueForKey:@"media_id"];
                if ([mediaId isEqualToString:item.entryID]) {
                    article.isSubscribe = item.subscribed;
                    [article save];
                }
            }
        }
    }];
}

#pragma mark - Utils
- (void)trackAutoPlayCellEnterBackground
{
    for (ExploreCellBase *cell in [_listView visibleCells]) {
        if (![cell isKindOfClass:[ExploreCellBase class]]) {
            continue;
        }
        NSIndexPath *indexPath = [_listView indexPathForCell:cell];
        if (indexPath.row >= [_fetchListManager items].count) {
            continue;
        }
        ExploreOrderedData *obj = [[_fetchListManager items] objectAtIndex:indexPath.row];
        if (![obj isKindOfClass:[ExploreOrderedData class]]) {
            continue;
        }
        if ([cell isKindOfClass:[ExploreCellBase class]]) {
            [self oldMovieAutoOverTrack:cell stop:NO];
            [self newMovieAutoOverTrack:cell orderData:obj stop:NO];
        }
    }
}

- (void)userRefreshGuideHideTabbarBubbleView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFeedUserRefreshGuideHideTabbarBubbleViewNotification" object:nil userInfo:nil];
}



#pragma mark -- TTRefreshViewDelegate代理

- (void)refreshViewWillStartDrag:(UIView *)refreshView{
    
}

-(void)refreshViewDidScroll:(UIView *)refreshView WithScrollOffset:(CGFloat)offset{
    
}

-(void)refreshViewDidEndDrag:(UIView *)refreshView{
    
}

-(void)refreshViewWillChangePullDirection:(TTRefreshView *)refreshView changedPullDirection:(PullMoveDirectionType)pullDirection{
    
    if (pullDirection == Pull_MoveDirectionDown) {
        if (refreshView && [refreshView isKindOfClass:[TTRefreshView class]]) {
            
            id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
            if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(refresh_configureAnimateViewWithChannelId:WithRefreshView:WithRefreshAnimateView:)]) {
                [adManagerInstance refresh_configureAnimateViewWithChannelId:self.categoryID WithRefreshView:(TTRefreshView *)refreshView WithRefreshAnimateView:self.adRefreshAnimationView];
            }
            
        }
    }
}

//- (void)convertPicViewInfoForContext:(TTFeedCellSelectContext *)context fromCell:(ExploreCellBase *)cell
//{
//    CGRect picViewFrame = CGRectZero;
//    TTArticlePicViewStyle picViewStyle = TTArticlePicViewStyleNone;
//    TTArticlePicView *picView = nil;
//    ExploreCellViewBase *cellView = cell.cellView;
//    if ([cellView isKindOfClass:[ExploreArticleCellView class]]) {
//        picView = ((ExploreArticleCellView *)cellView).picView;
//    }
//    else if ([cellView isKindOfClass:[TTLayOutCellViewBase class]]) {
//        picView = ((TTLayOutCellViewBase *)cellView).picView;
//    }
//    if (picView && picView.superview) {
//        picViewFrame = [picView convertRect:picView.bounds toView:cell.cellView];
//        picViewStyle = picView.style;
//    }
//    context.picViewFrame = picViewFrame;
//    context.picViewStyle = picViewStyle;
//    context.targetView = cell.cellView;
//}

#pragma mark - TTRefreshViewDelegate

- (void)refreshViewDidMessageBarResetContentInset {
    [TTFeedDislikeView dismissIfVisible];
    if (_isShowing && self.fetchListManager.items > 0 && !self.listView.isDragging && !self.listView.isTracking && !self.listView.isDecelerating) {
        [self showDislikeButtonTip];
    }
}

//不感兴趣功能引导
- (void)showDislikeButtonTip {
    if (![TTFeedGuideView isFeedGuideTypeEnabled:TTFeedGuideTypeDislike]) {
        return;
    }
    
    NSString *tipKey = @"kFeedGuideTip";
    BOOL dislikeButtonTip = [[NSUserDefaults standardUserDefaults] boolForKey:tipKey];
    if (dislikeButtonTip) {
        return;
    }
    
    if ([TTAdSplashMediator shareInstance].isAdShowing) {
        return;
    }
    
    __block UIButton *dislikeButton = nil;
    
    [self.listView.visibleCells enumerateObjectsUsingBlock:^(__kindof ExploreCellBase * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell isKindOfClass:[ExploreCellBase class]]) {
            // 排除置顶cell
            ExploreOrderedData *item = cell.cellData;
            if ([item isKindOfClass:[ExploreOrderedData class]] && item.stickStyle != 0) {
                return;
            }
            
            ExploreArticleCellView *cellView = (ExploreArticleCellView *)cell.cellView;
            if ([cellView respondsToSelector:@selector(unInterestedButton)]) {
                dislikeButton = [cellView unInterestedButton];
                if (dislikeButton || idx > 1) {
                    *stop = YES;
                }
            }
        }
    }];
    
    if (dislikeButton && dislikeButton.frame.origin.x > 0 && dislikeButton.frame.origin.y > 0) {
        // 确保提示完整显示
        CGRect rect = [dislikeButton convertRect:dislikeButton.bounds toView:self];
        if (rect.origin.y < 30) {
            return;
        }
        
        rect = [dislikeButton convertRect:dislikeButton.bounds toView:self.window];
        if (rect.origin.y < 0 || rect.origin.y > self.window.height - 80) {
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:tipKey];
        
        [Answers logCustomEventWithName:@"TTFeedGuideView" customAttributes:@{@"type":@"dislike"}];
        
        TTFeedGuideView<TTGuideProtocol> *feedGuideItem = [[TTFeedGuideView alloc] initWithFrame:self.window.bounds];
        
        TTFeedGuideTipModel *tipModel = [TTFeedGuideTipModel new];
        tipModel.targetRect = rect;
        tipModel.tip = [TTFeedGuideView textForType:TTFeedGuideTypeDislike];
        tipModel.arrowPoint = CGPointMake(dislikeButton.width/2, dislikeButton.height/2 + 15 + 9);
        tipModel.arrowDirection = TTBubbleViewArrowUp;
        tipModel.radius = 15;
        [feedGuideItem addGuideItem:tipModel];
        
        [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:feedGuideItem withContext:self.window];
        
        self.feedGuideView = feedGuideItem;
    }
}

@end



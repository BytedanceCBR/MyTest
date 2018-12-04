//
//  TTVFeedListViewController.m
//  Article
//
//  Created by panxiang on 2017/3/27.
//
//

#import "TTVFeedListViewController.h"
#import "TTVFeedListViewController+Track.h"
#import "TTVFeedListViewController+HeaderView.h"
#import "TTVFeedListViewControllerPrivate.h"
#import "TTVideoFeedListServiceMessage.h"
#import "UIViewController+RefreshEvent.h"
#import "TTVFeedListVideoCellHeader.h"
#import "TTVFeedCellActionMessage.h"
#import "NewsBaseDelegate.h"
#import "TTVideoFeedListParameter.h"
#import "TTVFeedListViewModel.h"
#import "TTVFeedPlayMovie.h"
#import "TTVFeedListVideoCellHeader.h"
#import "PBModelCategory.h"
#import "PBModelHeader.h"
#import "TTMessageCenter.h"
#import "TTVideoFeedListService.h"
#import "TTVideoDislikeMessage.h"
#import "TTAccountManager.h"
#import "NewsListLogicManager.h"
#import "ArticleListNotifyBarView.h"
#import "NetworkUtilities.h"
#import "NewsDetailConstant.h"
#import "TTVideoCategoryManager.h"
#import "ExploreMixListDefine.h"
#import "NewsDetailLogicManager.h"
#import "NewsFetchArticleDetailManager.h"
#import "ArticleCityViewController.h"
#import "ExploreLogicSetting.h"
#import "TTIndicatorView.h"
#import "SSTipModel.h"
#import "TTReachability.h"
#import "SSADEventTracker.h"
#import "SSURLTracker.h"
#import "SSImpressionManager.h"
#import "ArticleImpressionHelper.h"
#import "TTFeedDislikeView.h"
#import "TTVFeedItem+ComputedProperties.h"
#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "TTSubEntranceManager.h"
#import "SSActionManager.h"
#import "TTPGCFetchManager.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTLocationManager.h"
#import "PGCAccountManager.h"
#import "NSDictionary+TTAdditions.h"
#import "TTNavigationController.h"
#import "TTAuthorizeHintView.h"
#import "NSObject+MultiDelegates.h"
#import "TTStringHelper.h"
#import "NSObject+TTAdditions.h"
#import "UIImage+TTThemeExtension.h"
#import "SSJSBridgeWebViewDelegate.h"
#import "NSObject+FBKVOController.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTAdImpressionTracker.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "ExploreItemActionManager.h"
#import "ArticleUpdateManager.h"
#import "ExploreEntryManager.h"
#import "DetailActionRequestManager.h"
#import "TTArticleTabBarController.h"
#import "UIViewController+TTVFetchedResultsTableDataSourceAndDelegate.h"
#import "TTVFetchedResultsTableDataSourceProtocol.h"
#import "TTVideoUserInfoService.h"
#import "TTVideoArticleService.h"
#import "TTVideoArticleServiceMessage.h"
#import "TTVFeedListNotificationCenter.h"
#import "TTVLastReadItem.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+Extension.h"
#import "TTVFeedListWebItem.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellEndDisplayContext.h"
#import "TTVFeedCellSelectContext.h"
#import "NSArray+BlocksKit.h"
#import "ExploreListHelper.h"
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "Article+TTVArticleProtocolSupport.h"
#import <libextobjc/extobjc.h>
#import "SSWebViewUtil.h"
#import "TTVFeedCellForRowContext.h"
#import "TTVFeedUserOpViewSyncMessage.h"
#import "TTVFeedCellAction.h"
#import "TTVPreloadDetailManager.h"
//#import "SSADManager.h"
#import "TTAdSplashMediator.h"
#import "ListDataHeader.h"
#import "TTFeedDislikeView.h"
#import "TTVPlayVideo.h"
#import "TTVAutoPlayManager.h"
#import "TTArticleSearchManager.h"
#import "JSONAdditions.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTRelevantDurationTracker.h"
#import "TTVFeedListVideoBottomContainerView.h"
#import "TTTabBarManager.h"
#import "TTFreeFlowTipManager.h"
#import "TTADEventTrackerEntity.h"

extern BOOL ttvs_threeTopBarEnable(void);
extern BOOL ttsettings_getAutoRefreshIntervalForCategoryID(NSString *categoryID);

@interface TTVFeedListViewController()
<SSImpressionProtocol,
UIViewControllerErrorHandler,
YSWebViewDelegate,
TTVFetchedResultsTableDataSourceProtocol ,
TTVideoFeedListServiceMessage,
TLIndexPathControllerDelegate ,
TTVideoDislikeMessage,
TTVFeedCellActionMessage,
TTVideoFeedListServiceMessage,
TTVideoArticleServiceMessage,
NewsFetchArticleDetailManagerDelegate,
TTVFeedUserOpViewSyncMessage,
TTVPreloadDetailManagerDelegate,
TTAccountMulticastProtocol,
TTRefreshViewDelegate>
{

    /**
     *  收到账户变更信息后，需要刷新列表，默认是NO
     */
    BOOL _accountChangedNeedReadloadList;
    BOOL _isShowing;
    BOOL _isShowWithScenesEnabled;
}
@property(nonatomic, retain)TTVFeedListViewModel *listVideoModel;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, assign)NSUInteger refer;
@property(nonatomic, retain)ExploreItemActionManager *itemActionManager;
@property(nonatomic, assign)BOOL isCurrentDisplayView;//是否是当前正在显示的View
@property(nonatomic, retain)TTCategory *currentCategory;
@property(nonatomic, strong)TTVPreloadDetailManager *preloadDetail;
@property (nonatomic, strong) TTVFeedListNotificationCenter *notifyCenter;
// 在预加载广告时，将delegate对象传出去，为了之后delegate方法调用
@property (nonatomic, strong) SSJSBridgeWebViewDelegate *transformDelegate;


@property(nonatomic, assign) BOOL isLastReadRefresh;

//是否是app启动后首次获取列表
@property(nonatomic, assign)BOOL isFirstRefreshListAfterLaunch;
/**
 *  用于保存上次看到这的数据.
 *  上次看到这消失后，该字段变为nil
 *  上次看到这出现后，临时保存
 */
@property(nonatomic, assign)BOOL shouldShowRefreshButton;   //当前出现的lastRead是否显示刷新按钮

// 网络切换时，分离cell中的movieView
@property(nonatomic, strong)UIView *movieView;

//记录是否是从列表页点击cell离开列表
@property(nonatomic, assign)BOOL isClickCellLeaveList;

@property(nonatomic, assign) BOOL refreshButtonShowWhenScrollUpward;//是否在上滑时，上次看到这cell消失
@property (nonatomic, strong) TTVFeedListItem *movieViewCellData;

@property (nonatomic, strong) NSMapTable<TTVFeedListItem *, NSNumber *> *toBeUpdatedListItemMapTable;
@property(nonatomic, strong) NSMutableArray *movieViews;
@property(nonatomic, assign) BOOL isPlayerOnRotateAnimation;
@property(nonatomic, assign) BOOL readyToReload;

@property(nonatomic, strong) UIView *adRefreshAnimationView;
@property(nonatomic, assign) BOOL isCustomAnimationForcell;

@end

@implementation TTVFeedListViewController
@synthesize indexPathController = _indexPathController;
- (void)addTableView
{
    self.tableView = [[SSThemedTableView alloc] initWithFrame:CGRectMake(0,64, self.view.bounds.size.width, self.view.bounds.size.height - 64) style:UITableViewStylePlain];
    self.tableView.frame = self.view.bounds;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    [self.view addSubview:self.tableView];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
    }

    CGFloat topPadding = 0;
    CGFloat bottomPadding = 44;

    if ([TTDeviceHelper isPadDevice]) {
        topPadding = 64 + 44;
    }
    [self setListTopInset:topPadding BottomInset:bottomPadding];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.protocolInterceptor = [[TTVTableViewProtocolInterceptor alloc] init];
    self.fetchedResultsTableDataSource = [[TTVFetchedResultsTableDataSourceAndDelegate alloc] init];
    self.protocolInterceptor.middleMan = self;
    self.protocolInterceptor.receiver = self.fetchedResultsTableDataSource;
    self.indexPathController = [[TLIndexPathController alloc] init];
    self.indexPathController.delegate = self;
    @weakify(self);
    self.indexPathController.modificationComparatorBlock = ^BOOL(TTVFeedListItem *item1, TTVFeedListItem *item2) {
        @strongify(self);
        if ([item1 isKindOfClass:[TTVFeedListItem class]] && [item2 isKindOfClass:[TTVFeedListItem class]] && [item1 isEqual:item2]) {
            if ([self.toBeUpdatedListItemMapTable objectForKey:item1]) {
                TTVFeedListCellSeparatorStyle oldCellSeparatorStyle = [[self.toBeUpdatedListItemMapTable objectForKey:item1] integerValue];
                return oldCellSeparatorStyle != item1.cellSeparatorStyle;
            } else {
                return NO;
            }
        } else {
            return ![item1 isEqual:item2];
        }
    };
    self.fetchedResultsTableDataSource.item_configCell = ^(TTVTableViewItem *item, TTVTableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        if ([item isKindOfClass:[TTVFeedListItem class]]) {
            [((TTVFeedListItem *)item).cellAction cellForRowItem:(TTVFeedListItem *)item context:[self forRowContext]];
            ((TTVFeedListItem *)item).comefrom = TTVFromOptionMemory;

        }
    };
    self.tableView.dataSource = self.protocolInterceptor;
    self.tableView.delegate = self.protocolInterceptor;
    self.tableView.needPullRefresh = NO;
}

- (TTVFeedCellForRowContext *)forRowContext
{
    TTVFeedCellForRowContext *context = [[TTVFeedCellForRowContext alloc] init];
    context.isDisplayView = self.isDisplayView;
    return context;
}

- (void)setIndexPathController:(TLIndexPathController *)indexPathController
{
    _indexPathController = indexPathController;
    self.fetchedResultsTableDataSource.indexPathController = indexPathController;
}

- (TTVideoFeedListParameter *)parameter
{
    TTVideoFeedListParameter *parameter = [[TTVideoFeedListParameter alloc] init];
    parameter.categoryID = isEmptyString(self.categoryID) ? @"" : self.categoryID;
    parameter.reloadType = _reloadFromType;
    parameter.refer = @(1);
    parameter.getRomote = YES;
    return parameter;
}

- (TTVideoFeedListParameter *)moreParameter
{
    TTVideoFeedListParameter *parameter = [[TTVideoFeedListParameter alloc] init];
    parameter.categoryID = isEmptyString(self.categoryID) ? @"" : self.categoryID;
    parameter.reloadType = _reloadFromType;
    parameter.refer = @(1);
    parameter.getRomote = YES;
    return parameter;
}

- (void)tt_cellAction:(NSUInteger)action object:(id)object callbackBlock:(TTCellActionCallback)callbackBlock
{

}

- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    UNREGISTER_MESSAGE(TTVideoDislikeMessage, self);
    UNREGISTER_MESSAGE(TTVFeedCellActionMessage, self);
    UNREGISTER_MESSAGE(TTVideoArticleServiceMessage, self);
    UNREGISTER_MESSAGE(TTVFeedUserOpViewSyncMessage, self);

    [self removeDelegates];
    [self.listVideoModel cancelRequest];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isDisplayView = YES;
        _refer = 1;//默认是频道主页
        _isClickCellLeaveList = NO;
        REGISTER_MESSAGE(TTVideoDislikeMessage, self);
        REGISTER_MESSAGE(TTVFeedCellActionMessage, self);
        REGISTER_MESSAGE(TTVideoArticleServiceMessage, self);
        REGISTER_MESSAGE(TTVFeedUserOpViewSyncMessage, self);

        self.notifyCenter = [TTVFeedListNotificationCenter new];
        [self.notifyCenter registerNotificationsWithTarget:self];
        [TTAccount addMulticastDelegate:self];
        _listVideoModel = [[TTVFeedListViewModel alloc] init];
        self.isVideoTabCategory = YES;

        _toBeUpdatedListItemMapTable = [NSMapTable weakToStrongObjectsMapTable];

        [self willAppear];

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

//        [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            [self reloadListViewWithVideoPlaying];
//        }];
    }
    return self;
}

- (void)setIsVideoTabCategory:(BOOL)isVideoTabCategory
{
    _isVideoTabCategory = isVideoTabCategory;
    self.listVideoModel.isVideoTabCategory = isVideoTabCategory;
}

- (void)prepareForReuse
{
    self.isClickCellLeaveList = NO;
    [self.listVideoModel reset];
    self.listVideoModel = [[TTVFeedListViewModel alloc] init];
    self.listVideoModel.isVideoTabCategory = self.isVideoTabCategory;
    self.toBeUpdatedListItemMapTable = [NSMapTable weakToStrongObjectsMapTable];
//    [self willAppear];
    [self creatrePreloadManager];
    [self resetScrollView];
    [self reloadListView];
}

- (void)resetScrollView
{
    TTRefreshView *refreshView = self.tableView.pullDownView;
    UIScrollView *scrollView = self.tableView;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.view.backgroundColor = [UIColor whiteColor];

    [self addTableView];
    [self addPullDownRefreshView];
    self.view.ttErrorToastView = [ArticleListNotifyBarView addErrorToastViewWithTop:self.ttContentInset.top width:CGRectGetWidth(self.view.frame) height:CGRectGetHeight(self.view.frame)];
    [[SSImpressionManager shareInstance] addRegist:self];
    [self themeChanged:nil];
    [self creatrePreloadManager];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[TTRelevantDurationTracker sharedTracker] sendRelevantDuration];
}

- (void)creatrePreloadManager
{
    self.preloadDetail = [[TTVPreloadDetailManager alloc] initWithModel:self.listVideoModel];
    self.preloadDetail.delegate = self;
    self.preloadDetail.tableView = self.tableView;
    self.preloadDetail.superView = self.view;
}

- (void)addPullDownRefreshView
{
    //nick add for new refresh util
    self.tableView.hasMore = NO;

    BOOL isNewPullRefreshEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"new_pull_refresh" defaultValue:@NO freeze:YES] boolValue];
    NSString *loadingText = isNewPullRefreshEnabled ? nil : @"推荐中";
    @weakify(self);
    [self.tableView addPullDownWithInitText:@"下拉推荐"
                              pullText:@"松开推荐"
                           loadingText:loadingText
                            noMoreText:@"暂无新数据"
                              timeText:nil
                           lastTimeKey:nil
                         actionHandler:^{
                             @strongify(self);
                             if (self.tableView.pullDownView.isUserPullAndRefresh) {
                                 [self trackEventForLabel:[self modifyEventLabelForRefreshEvent:@"refresh_pull"]];
                                 self.reloadFromType = TTReloadTypePull;

                                 [self userRefreshGuideHideTopBubbleView];
                             }
                             [self fetchFromLocal:![self tt_hasValidateData] fromRemote:YES getMore:NO];

                         }];
    CGFloat barH = isNewPullRefreshEnabled ? 40.0 : 32.0;
    self.view.ttMessagebarHeight = barH;
    if (isNewPullRefreshEnabled) {
        self.tableView.pullDownView.pullRefreshLoadingHeight = barH;
        self.tableView.pullDownView.messagebarHeight = barH;
    }

    [self.tableView tt_addDefaultPullUpLoadMoreWithHandler:^{
        @strongify(self);
        self.reloadFromType = TTReloadTypeLoadMore;
        [self loadMoreWithUmengLabel:[self modifyEventLabelForRefreshEvent:@"load_more"] isPreload:NO];
    }];
    [self.KVOController unobserve:self.tableView.pullDownView];
    [self.KVOController observe:self.tableView.pullDownView keyPath:@keypath(self.tableView.pullDownView,  state) options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        @strongify(self);
        if (self.tableView.pullDownView.state == PULL_REFRESH_STATE_LOADING) {
            [self didFinishLoadTable];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:self.categoryID forKey:@"category_id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kTTRefreshViewBeginRefresh" object:nil userInfo:dic];
        }
    }];

}

- (void)tableView:(UITableView *)tableView deleteRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)removeDelegates
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [self.listVideoModel reset];
    [[SSImpressionManager shareInstance] removeRegist:self];

    self.delegate = nil;
}

- (void)setIsDisplayView:(BOOL)isDisplayView
{
    if (isDisplayView == _isDisplayView) {
        return;
    }
    _isDisplayView = isDisplayView;

    if (!_isDisplayView) {
        for (TTVFeedListVideoCell * cell in  [self.tableView visibleCells]) {
            if ([cell isKindOfClass:[TTVFeedListVideoCell class]]) {
                [cell cellInListWillDisappear:TTCellDisappearTypeChangeCategory];
            }
        }
    }
}

- (void)setCategoryID:(NSString *)categoryID
{
    if (!isEmptyString(categoryID) && !isEmptyString(_categoryID) && [_categoryID isEqualToString:categoryID]) {
        return;
    }

    NSString * originalCID = [_categoryID copy];
    _categoryID = categoryID;

    if (![originalCID isEqualToString:_categoryID]) {
        [self clearListContent];
        [self reportDelegateCancelRequest];
    }
    [self setADRefreshView];
}

- (void)setADRefreshView{
    if (!self.adRefreshAnimationView) {

        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];

        if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(refresh_createAnimateViewWithFrame:WithLoadingText:WithPullLoadingHeight:)]) {
            self.adRefreshAnimationView = [adManagerInstance refresh_createAnimateViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.pullDownView.frame),CGRectGetHeight(self.tableView.pullDownView.frame)) WithLoadingText:self.tableView.pullDownView.refreshLoadingText WithPullLoadingHeight:self.tableView.pullDownView.pullRefreshLoadingHeight];
        }
    }

    self.tableView.pullDownView.delegate = self;

}

- (CGRect)frameForListView
{
    return self.view.bounds;
}

- (void)refreshFeedListForCategory:(TTCategory *)category isDisplayView:(BOOL)display fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadFromType:(TTReloadType)fromType getRemoteWhenLocalEmpty:(BOOL)getRemoteWhenLocalEmpty
{
    [self removeExpireADs];
    NSString * previousCategoryID = self.categoryID;
    self.currentCategory = category;
    self.isCurrentDisplayView = display;

    BOOL categoryNotChange = !isEmptyString(previousCategoryID) &&
    !isEmptyString(self.currentCategory.categoryID) &&
    [previousCategoryID isEqualToString:self.currentCategory.categoryID];

    self.isDisplayView = display;
    self.reloadFromType = fromType;
    self.categoryID = category.categoryID;

    if (!(fromLocal && !fromRemote && categoryNotChange && self.listVideoModel.dataArr.count != 0)) {

        if (fromRemote) {
            [self.listVideoModel cancelRequest];

            if (self.listVideoModel.dataArr.count != 0) {
                [self.tableView triggerPullDown];
            }
            else {
                [self setListHeader:nil];
                [self.tableView triggerPullDownAndHideAnimationView];
            }

        }
        else {
            [self fetchFromLocal:fromLocal fromRemote:fromRemote getMore:NO isPreload:NO getRemoteWhenLocalEmpty:getRemoteWhenLocalEmpty];
        }
    }

    if (![previousCategoryID isEqualToString:self.currentCategory.categoryID]) {
        [self scrollToTopAnimated:NO];
    }

    if (display) {
        [self trackEventForLabel:@"enter"];
    }
}

- (void)clickCategorySelectorViewWithCategory:(TTCategory *)category hasTip:(BOOL)hasTip
{
    NSString *event = @"category";
    NSString *label = nil;
    NSString *methodName = nil;
    if(hasTip){
        self.reloadFromType = TTReloadTypeClickCategoryWithTip;
        label = @"refresh_click_tip";
        methodName = @"click_tip";
    }
    else{
        self.reloadFromType = TTReloadTypeClickCategory;
        label = @"refresh_click";
        methodName = @"click";
    }
    label = [self modifyEventLabelForRefreshEvent:label categoryModel:category];

    wrapperTrackEvent(event, label);
}

- (void)clickVideoTabbarWithCategory:(TTCategory *)category hasTip:(BOOL)hasTip
{
    NSString *label = nil;

    NSString *event = @"category";
    NSString *methodName = nil;
    if(hasTip){
        self.reloadFromType = TTReloadTypeTip;
        label = @"tab_refresh_tip";
        methodName = @"tab_tip";
    }
    else{
        self.reloadFromType = TTReloadTypeTab;
        label = @"tab_refresh";
        methodName = @"tab";
    }
    label = [self modifyEventLabelForRefreshEvent:label categoryModel:category];

    wrapperTrackEvent(event, label);

}

- (void)didAppear
{
    _isShowing = YES;
}

- (void)willAppear
{
    _isShowing = YES;
    BOOL shouldUseOptimisedLaunch = [[[TTSettingsManager sharedManager] settingForKey:@"should_optimize_launch" defaultValue:@YES freeze:NO] boolValue];
    if (!self.categoryID && shouldUseOptimisedLaunch) {
        return;
    }
    [[SSImpressionManager shareInstance] enterGroupViewForCategoryID:self.categoryID concernID:nil refer:self.refer];

    [self resumeTrackAdCellsInVisibleCells];

    //唤醒后刷新
    if ([self shouldReloadBackAfterLeaveCurrentCategory] && [self.listVideoModel dataArr].count > 0) {
        self.refreshShouldLastReadUpate = YES;
        self.reloadFromType = TTReloadTypeAuto;
        [self pullAndRefresh];
    }

    for (TTVFeedListVideoCell * cell in  [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[TTVFeedListVideoCell class]]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            if (indexPath.row < self.listVideoModel.dataArr.count) {
                TTVTableViewItem *obj = [self.listVideoModel.dataArr objectAtIndex:indexPath.row];
                if ([obj isKindOfClass:[TTVFeedListItem class]]) {
                    if ([cell isKindOfClass:[TTVFeedListVideoCell class]]) {
                        [cell viewWillAppear];
                    }
                }
            }
        }
    }

    if ([[TTVAutoPlayManager sharedManager] cachedAutoPlayingCellInView:self.tableView]) {
        [[TTVAutoPlayManager sharedManager] continuePlayCachedMovie];
    }
    [[TTAdImpressionTracker sharedImpressionTracker] startTrackForce];
}

- (NSDictionary *)adExtraDataWithItem:(TTVFeedListItem *)item {
    NSMutableDictionary *extraData = [NSMutableDictionary dictionary];
    NSMutableDictionary *status = [NSMutableDictionary dictionary];
    if ([item isKindOfClass:[TTVFeedListItem class]]) {
        if (item.comefrom == TTVFromOptionPullUp ) {
            status[@"source"] = @2;
            status[@"first_in_cache"] = @(item.isFirstCached ? 1 : 0);
        } else if (item.comefrom == TTVFromOptionPullDown ) {
            status[@"source"] = @0;
            status[@"first_in_cache"] = @(1);
        } else {
            status[@"source"] = @1;
            status[@"first_in_cache"] = @0;
        }
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:status options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        extraData[@"ad_extra_data"] = json;
        return extraData;
    }
    return nil;
}


- (void)trackAdCellsInVisibleCellsIsSuspend:(BOOL)suspend
{
    if (!self.tableView) {
        return;
    }
    if (!_isShowing) {
        return;
    }
    TTExploreMainViewController *mainListView = [(NewsBaseDelegate *)[[UIApplication sharedApplication] delegate] exploreMainViewController];

    if (!suspend) {
        [[TTAdImpressionTracker sharedImpressionTracker] reset:self.tableView];
    }
    
    for (UITableViewCell * cell in  [self.tableView visibleCells]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            TTVFeedListItem *obj = nil;
            if (indexPath.row < self.listVideoModel.dataArr.count) {
                obj = (TTVFeedListItem *)[self.listVideoModel.dataArr objectAtIndex:indexPath.row];
            }
            if ([obj isKindOfClass:[TTVFeedListItem class]] && !isEmptyString(obj.originData.adID)) {
                NSNumber *adid = @(obj.originData.adID.longLongValue);
                NSString *adIDString = [NSString stringWithFormat:@"%@", adid];

                if (adid.doubleValue > 0) {
                    if (suspend) {
                        NSString *trackInfo = [[TTAdImpressionTracker sharedImpressionTracker] endTrack:adIDString];
                        NSDictionary *adExtra = [NSMutableDictionary dictionaryWithCapacity:1];
                        [adExtra setValue:trackInfo forKey:@"ad_extra_data"];
                        NSTimeInterval duration = [[SSADEventTracker sharedManager] durationForAdThisTime:adIDString];
                        TTVFeedItem *item = obj.originData;
                        [[SSADEventTracker sharedManager] trackEventWithEntity:[TTADEventTrackerEntity entityWithData:item] label:@"show_over" eventName:@"embeded_ad" extra:adExtra duration:duration];
                    }
                    else{

                        TTADShowScene scene = mainListView.isChangeChannel ? TTADShowChangechannelScene : TTADShowReturnScene;
                        [[SSADEventTracker sharedManager] willShowAD:adIDString scene:scene];
                        TTVFeedItem *item = obj.originData;

                        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                        if ([self adExtraDataWithItem:obj]) {
                            [extra addEntriesFromDictionary:[self adExtraDataWithItem:obj]];
                        }

                        TTADEventTrackerEntity *entity = [TTADEventTrackerEntity entityWithData:item];
                        entity.showScene = scene;
                        [[SSADEventTracker sharedManager] trackEventWithEntity:entity label:@"show" eventName:@"embeded_ad" extra:extra duration:0];
                        if ([SSCommonLogic videoVisibleEnabled] && [cell conformsToProtocol:@protocol(TTVAutoPlayingCell)]) {
                            [[TTAdImpressionTracker sharedImpressionTracker] track:adIDString visible:cell.frame scrollView:self.tableView movieCell:(id<TTVAutoPlayingCell>)cell];
                        } else {
                            [[TTAdImpressionTracker sharedImpressionTracker] track:adIDString visible:cell.frame scrollView:self.tableView];
                        }
                    }
                }
            }
    }

    if (!suspend && mainListView.isChangeChannel) {
        mainListView.isChangeChannel = NO;
    }
}

- (void)resumeTrackAdCellsInVisibleCells{
    [self trackAdCellsInVisibleCellsIsSuspend:NO];
    [[TTAdImpressionTracker sharedImpressionTracker] startTrackForce];
}

-(void)suspendTrackAdCellsInVisibleCells{
    [self trackAdCellsInVisibleCellsIsSuspend:YES];
}

- (void)willDisappear
{
    [TTFeedDislikeView dismissIfVisible];

    [[SSImpressionManager shareInstance] leaveGroupViewForCategoryID:self.categoryID concernID:nil refer:self.refer];
    [self suspendTrackAdCellsInVisibleCells];
    _isShowing = NO;
    for (TTVFeedListVideoCell * cell in  [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[TTVFeedListVideoCell class]]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            TTVFeedListItem *obj = nil;
            if (indexPath.row < self.listVideoModel.dataArr.count) {
                obj = (TTVFeedListItem *)[self.listVideoModel.dataArr objectAtIndex:indexPath.row];
            }
            if ([obj isKindOfClass:[TTVFeedListItem class]]) {
                [self newMovieAutoOverTrack:cell feedItem:obj.originData];
                [cell cellInListWillDisappear:self.navigationController.presentedViewController ? TTCellDisappearTypePresentedViewController : TTCellDisappearTypeGoDetail];
            }
        }
    }

    [self saveLeaveCurrentCategoryDate];

    if (_isClickCellLeaveList){
        _isClickCellLeaveList = NO;
    }
}

- (void)newMovieAutoOverTrack:(TTVFeedListCell *)cellBase feedItem:(TTVFeedItem *)feedItem
{
    if (![feedItem isKindOfClass:[TTVFeedItem class]]) {
        return;
    }
    if ([[TTVAutoPlayManager sharedManager] IsCurrentAutoPlayingWithUniqueId:[NSString stringWithFormat:@"%lld",feedItem.uniqueID]]) {
        //自动播放时，禁止出小窗
        if ([cellBase conformsToProtocol:@protocol(TTVAutoPlayingCell)] && [cellBase respondsToSelector:@selector(ttv_movieView)]) {
            UITableViewCell <TTVAutoPlayingCell> *movieCell = (UITableViewCell <TTVAutoPlayingCell> *)cellBase;
            if ([[movieCell ttv_movieView] isKindOfClass:[TTVPlayVideo class]]) {
                [[TTVAutoPlayManager sharedManager] trackForFeedAutoOver:[TTVAutoPlayModel  modelWithArticle:feedItem category:self.categoryID] movieView:[movieCell ttv_movieView]];
            }
        }
    }
}

- (void)didDisappear
{

}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
//    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = self.view.backgroundColor;
}

- (NSString *)screenName{
    if (!isEmptyString(self.categoryID)) {
        return [NSString stringWithFormat:@"channel_%@",self.categoryID];
    }
    return @"channel_unknown";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString * screenName = [self screenName];

    if (indexPath.row >= [self listViewMaxModelIndex]) {
        //load more
        self.reloadFromType = TTReloadTypeLoadMore;
        [self loadMoreWithUmengLabel:[self modifyEventLabelForRefreshEvent: @"load_more"] isPreload:NO];
    }
    else {
        _isClickCellLeaveList = YES;
        TTVFeedListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[TTVFeedListCell class]]) {
            [[TTRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];

            if (!isEmptyString(cell.item.originData.article.rawAdDataString)) {
                Article *convertedArticle = [cell.item.originData ttv_convertedArticle];
                ExploreOrderedData *orderedData = [[ExploreOrderedData alloc] initWithArticle:convertedArticle];
                orderedData.raw_ad_data = [cell.item.originData.article.rawAdDataString tt_JSONValue];
                if ([TTAdManageInstance canvas_showCanvasView:orderedData cell:cell]) {
                    TTADEventTrackerEntity *entity = [TTADEventTrackerEntity entityWithData:cell.item.originData];
                    [[SSADEventTracker sharedManager] trackEventWithEntity:entity label:@"click" eventName:@"embeded_ad"];
                    return;
                }
            }

            TTVFeedCellSelectContext *context = [[TTVFeedCellSelectContext alloc] init];
            context.screenName = screenName;
            context.refer = self.refer;
            context.categoryId = self.categoryID;
            context.feedListViewController = self;

            TTVFeedListItem *item = (TTVFeedListItem *)[self.indexPathController.dataModel itemAtIndexPath:indexPath];
            if ([item isKindOfClass:[TTVFeedListItem class]]) {
                [((TTVFeedListItem *)item).cellAction didSelectItem:(TTVFeedListItem *)item context:context];
            }

        } else if ([cell isKindOfClass:[TTVLastReadCell class]]) {
            [self didSelectLastReadCell];
        }
    }


}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.isCustomAnimationForcell) {
        if (![tableView.visibleCells containsObject:cell]) {
            [UIView performWithoutAnimation:^{
                cell.transform = CGAffineTransformMakeTranslation(0, 223);
            }];
            [UIView animateWithDuration:0.25f animations:^{
                cell.transform = CGAffineTransformIdentity;
            }];
        }
    }

    TTVFeedListItem *item = (TTVFeedListItem *)[self.indexPathController.dataModel itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[TTVLastReadItem class]]) {
        [self addLastReadTrackWithLabel:@"last_read_show"];
        return;
    }
    if (![item isKindOfClass:[TTVFeedListItem class]]) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(willFinishLoadTable) object:nil];
    [self willFinishLoadTable];

    item.originData.article.extend.hasShown = YES;
    TTVFeedCellWillDisplayContext *context = [[TTVFeedCellWillDisplayContext alloc] init];
    context.isDisplayView = YES;
    [item.cellAction willDisplayItem:item context:context];

    TTVVideoArticle *article = item.originData.article;
    NSString *adID = item.originData.adID;
    NSString *uniqueID = item.originData.uniqueID > 0 ? @(item.originData.uniqueID).stringValue : @"";
    NSString *itemID = article.itemId > 0 ? @(article.itemId).stringValue : @"";

    NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
    if ([adID longLongValue] > 0) {
        [eventContext setValue:@"ad_cell" forKey:@"cell_type"];
        [eventContext setValue:uniqueID forKey:@"group_id"];
        [eventContext setValue:itemID forKey:@"item_id"];
        [eventContext setValue:adID forKey:@"ad_id"];
    }

    [self attachVideoIfNeededForCell:cell data:item];

    /*impression统计相关*/
    SSImpressionStatus impressionStatus = (self.isDisplayView && _isShowing) ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
    [self recordGroupWithItem:item status:impressionStatus];
}

- (void)recordGroupWithItem:(TTVFeedListItem *)item status:(SSImpressionStatus)status
{
    TTVVideoArticle *article = item.originData.article;
    NSString *uniqueID = item.originData.uniqueID > 0 ? @(item.originData.uniqueID).stringValue : @"";
    NSString *adID = item.originData.adID;
    NSString *itemID = article.itemId > 0 ? @(article.itemId).stringValue : @"";

    /*impression统计相关*/

    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = self.categoryID;
    params.refer = self.refer;
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:uniqueID itemID:itemID impressionID:nil aggrType:item.article.aggrType];
    [ArticleImpressionHelper recordGroupWithUniqueID:@(item.originData.uniqueID).stringValue adID:adID groupModel:groupModel status:status params:params];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(willFinishLoadTable) object:nil];
    [self willFinishLoadTable];

    //dislike cell时，此时cell被reload，而reload cell会多创建一个cell，当前的cell会被保留，作为下一次cell复用。所以，当前cell的item此时并不在self.listVideoModel.dataArr中
    if (indexPath.row < [self listViewMaxModelIndex]) {

        if ([cell isKindOfClass:[TTVLastReadCell class]]) {

            if (cell.top < tableView.contentOffset.y) {

                self.refreshButtonShowWhenScrollUpward = YES;
            } else{

                self.refreshButtonShowWhenScrollUpward = NO;
            }
        }
        else if([cell isKindOfClass:[TTVFeedListCell class]]) {
            TTVFeedListCell *cellBase = (TTVFeedListCell *)cell;
            BOOL hasMovie = NO;
            NSArray *indexPaths = [tableView indexPathsForVisibleRows];
            for (NSIndexPath *path in indexPaths) {
                if (path.row < [self listViewMaxModelIndex]) {
                    TTVFeedListItem *rowObj = (TTVFeedListItem *)[self.listVideoModel.dataArr objectAtIndex:path.row];

                    BOOL hasMovieView = NO;
                    if ([cellBase respondsToSelector:@selector(cell_hasMovieView)]) {
                        hasMovieView = [cellBase cell_hasMovieView];
                    }

                    if ([cellBase respondsToSelector:@selector(cell_movieView)]) {
                        UIView *view = [cellBase cell_movieView];
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

            if (_isShowing) {
                if (!hasMovie) {
                    TTVFeedCellEndDisplayContext *context = [[TTVFeedCellEndDisplayContext alloc] init];
                    [cellBase.item.cellAction endDisplayCell:cellBase context:context];
                }
            }

            if ([cell isKindOfClass:[TTVFeedListCell class]]) {
                // impression统计
                if ([cell isKindOfClass:[TTVFeedListCell class]] && ((TTVFeedListCell *)cell).item.cell == cell) {
                    if ([[TTVAutoPlayManager sharedManager].model.uniqueID isEqualToString:[NSString stringWithFormat:@"%lld",cellBase.item.originData.uniqueID]]) {
                        [[TTVAutoPlayManager sharedManager] resetForce];
                    }
                }
                if ([cell isKindOfClass:[TTVFeedListCell class]])
                {
                    [self newMovieAutoOverTrack:(TTVFeedListCell *)cell feedItem:cellBase.item.originData];
                }
                [self recordGroupWithItem:cellBase.item status:SSImpressionStatusEnd];
            }
        }
    }

}

- (NSInteger)listViewMaxModelIndex
{
    return [self.listVideoModel.dataArr count];
}

#pragma mark - list util

/**
 *  加载更多,并且发送umeng
 *
 *  @param label 如果为nil，不发送
 */
- (void)loadMoreWithUmengLabel:(NSString *)label isPreload:(BOOL)isPreload
{
    if (!self.listVideoModel.isLoading && [self.listVideoModel.dataArr count] > 0) {
        [self fetchFromLocal:NO fromRemote:YES getMore:YES isPreload:isPreload getRemoteWhenLocalEmpty:NO];
        if (!isEmptyString(label)) {
            [self trackEventForLabel:label];
        }
    }
    else {

        [self.tableView finishPullUpWithSuccess:NO];

    }
}

#pragma mark TLIndexPathController delegate


- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    for (TTVTableViewItem *item in updates.updatedDataModel.items) {
        if ([item isKindOfClass:[TTVFeedListItem class]]) {
            TTVFeedListItem *itemA = (TTVFeedListItem *)item;
            [_toBeUpdatedListItemMapTable setObject:@(itemA.cellSeparatorStyle) forKey:itemA];
        }
    }
    if (updates.oldDataModel.items.count == 0 || updates.updatedDataModel.items.count == 0) {
        [self.tableView reloadData];
    } else {
        [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationNone completion:nil];
    }
}

- (void)reloadListView
{
    [TTFeedDislikeView dismissIfVisible];
    self.indexPathController.dataModel = [[TLIndexPathDataModel alloc] initWithItems:self.listVideoModel.dataArr];
    [self performReloadData];
}

- (void)willFinishLoadTable
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didFinishLoadTable) object:nil];
    [self performSelector:@selector(didFinishLoadTable) withObject:nil afterDelay:0.1];
}

- (void)performReloadData
{
    if (_isShowing) {
        if (self.isPlayerOnRotateAnimation) {
            self.readyToReload = YES;
            return;
        }
    }
    [self performSelector:@selector(willFinishLoadTable) withObject:nil afterDelay:0.1];
//    [_tableView reloadData];
}

- (NSArray *)intersectArray:(NSArray *)firstArray withArray:(NSArray *)secondArray
{
    NSMutableSet *set1 = [NSMutableSet setWithArray: firstArray];
    NSSet *set2 = [NSSet setWithArray: secondArray];
    [set1 intersectSet: set2];
    return [set1 allObjects];
}

- (void)reloadListViewModifiedItems:(NSArray *)modifiedItems withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(BOOL))completion
{
    TTVFeedListVideoCell *videoCellPlayingMovie = nil;
    NSIndexPath *destIndexPath = nil;
    TTVFeedListItem *movieViewCellData = nil;
    __block UIView *movieView = nil;

    [CATransaction begin];
    if (modifiedItems.count > 0) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (id item in modifiedItems) {
            NSIndexPath *indexPath = [self.indexPathController.dataModel indexPathForItem:item];
            if (indexPath) {
                [indexPaths addObject:indexPath];
            }
        }
        NSArray *visibleModifiedIndexPaths = [self intersectArray:self.tableView.indexPathsForVisibleRows withArray:indexPaths];
        for (NSIndexPath *indexPath in visibleModifiedIndexPaths) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[TTVFeedListVideoCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                TTVFeedListVideoCell<TTVFeedPlayMovie> *videoCell = (TTVFeedListVideoCell<TTVFeedPlayMovie> *)cell;

                if ([cell respondsToSelector:@selector(cell_isPlayingMovie)]) {
                    if ([videoCell cell_isPlayingMovie]) {
                        videoCellPlayingMovie = videoCell;
                        destIndexPath = indexPath;
                        movieViewCellData = videoCell.item;
                        break;
                    }
                }
            }
        }
        if (videoCellPlayingMovie) {
            if ([videoCellPlayingMovie cell_isMovieFullScreen]) {
                return;
            }
            // 分离视频view
            movieView = [videoCellPlayingMovie cell_detachMovieView];
            self.movieView = movieView;
            self.movieViewCellData = movieViewCellData;
        }
        [self.tableView reloadRowsAtIndexPaths:visibleModifiedIndexPaths withRowAnimation:animation];
    }
    @weakify(self);
    [CATransaction setCompletionBlock:^{
        @strongify(self);
        if (destIndexPath) {
            TTVFeedListVideoCell *cell = [self.tableView cellForRowAtIndexPath:destIndexPath];
            [cell cell_attachMovieView:movieView];
        }
        completion ? completion(YES) : nil;
    }];
    [CATransaction commit];
}

- (void)reloadListViewWithVideoPlaying
{
    [self reloadListViewWithVideoPlayingIsChangeOrientation:NO];
}

- (void)reloadListViewWithVideoPlayingIsChangeOrientation:(BOOL)isChangeOrientation
{
    TTVFeedListCell<TTVFeedPlayMovie> *videoCellPlayingMovie = nil;
    NSInteger index = NSNotFound;
    id movieViewCellData = nil;
    self.movieView = nil;

    if (self.listVideoModel.dataArr.count > 0) {
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:[TTVFeedListCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                TTVFeedListCell<TTVFeedPlayMovie> *videoCell = (TTVFeedListCell<TTVFeedPlayMovie> *)cell;

                if ([cell respondsToSelector:@selector(cell_hasMovieView)]) {
                    if ([videoCell cell_hasMovieView]) {
                        videoCellPlayingMovie = videoCell;
                        index = [self.listVideoModel.dataArr indexOfObject:videoCell.item];
                        movieViewCellData = videoCell.item;
                        break;
                    }

                }
            }
        }
    }

    if (videoCellPlayingMovie && movieViewCellData != nil && index != NSNotFound) {
        if ([videoCellPlayingMovie cell_isMovieFullScreen]) {
            return;
        }
        // 分离视频view
        self.movieView = [videoCellPlayingMovie cell_movieView];
        self.movieViewCellData = movieViewCellData;
        // reload列表
        [self reloadListView];

        // scroll到之前视频cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];

        if (isChangeOrientation) {
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }

    }
    else {
        [self reloadListView];
    }

}

- (void)didFinishLoadTable
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    NSArray *cells = [_tableView visibleCells];
    NSMutableArray *visibleCells = [NSMutableArray arrayWithCapacity:cells.count];
    for (TTVFeedListCell<TTVFeedPlayMovie> *cellBase in cells) {
        if ([cellBase respondsToSelector:@selector(cell_movieView)]) {
            UIView *view = [cellBase cell_movieView];
            if (view) {
                [visibleCells addObject:view];
            }
        }
    }

    for (UIView *view in self.movieViews) {
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

- (void)attachVideoIfNeededForCell:(UITableViewCell *)cell data:(id)obj
{
    if (obj == self.movieViewCellData && self.movieView && [cell respondsToSelector:@selector(cell_attachMovieView:)]) {
        id<TTVFeedPlayMovie> videoCell = (id<TTVFeedPlayMovie>)cell;
        [videoCell cell_attachMovieView:self.movieView];
    }
}

- (void)attachVideoIfNeededForCellWithUniqueID:(NSString *)uniqueID playingVideo:(TTVPlayVideo *)playingVideo
{
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[TTVFeedListCell class]]) {
            TTVFeedListCell *feedListCell = (TTVFeedListCell *)cell;
            TTVFeedListItem *feedListItem = feedListCell.item;
            if ([feedListItem.originData.uniqueIDStr isEqualToString:uniqueID]) {
                [feedListCell cell_attachMovieView:playingVideo];
                break;
            }
        }
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
    [self tryFetchTipIfNeed];
    [self tryAutoReloadIfNeed];
}

- (void)listViewWillEnterBackground
{
    [self saveLeaveCurrentCategoryDate];
    [self trackAutoPlayCellEnterBackground];
}

- (void)fetchFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote getMore:(BOOL)getMore
{
    [self fetchFromLocal:fromLocal fromRemote:fromRemote getMore:getMore isPreload:NO getRemoteWhenLocalEmpty:NO];
}

- (void)fetchFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote getMore:(BOOL)getMore isPreload:(BOOL)isPreload getRemoteWhenLocalEmpty:(BOOL)getRemoteWhenLocalEmpty
{
    self.ttLoadingView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    self.ttTargetView = self.tableView;
    if (!isPreload) {
        [self tt_startUpdate];
    }
    //有开屏广告展示的时候首页列表页初始化和广告同步进行，故此优化仅针对于无开屏广告展示且读取本地缓存的时候
    BOOL shouldUseOptimisedLaunch = [[[TTSettingsManager sharedManager] settingForKey:@"should_optimize_launch" defaultValue:@YES freeze:NO] boolValue];
//    if (fromLocal && ![SSADManager shareInstance].adShow && shouldUseOptimisedLaunch) {
    if (fromLocal && ![TTAdSplashMediator shareInstance].adWillShow && shouldUseOptimisedLaunch) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tryOptimizeFetchFromLocal:fromLocal fromRemote:fromRemote getMore:getMore getRemoteWhenLocalEmpty:getRemoteWhenLocalEmpty];
        });
    } else {
        [self tryOptimizeFetchFromLocal:fromLocal fromRemote:fromRemote getMore:getMore getRemoteWhenLocalEmpty:getRemoteWhenLocalEmpty];
    }
}

- (void)tryOptimizeFetchFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote getMore:(BOOL)getMore getRemoteWhenLocalEmpty:(BOOL)getRemoteWhenLocalEmpty {

    if (ttvs_threeTopBarEnable() && fromRemote && !getMore){
        [TTArticleSearchManager tryFetchSearchTipIfNeedWithTabName:@"video" categoryID:self.categoryID];
    }

    NSMutableDictionary * exploreMixedListConsumeTimeStamps = [NSMutableDictionary dictionary];
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListTriggerRequestTimeStampKey];

    //为了蓝条 拼了！-- nick
    self.tableView.ttIntegratedMessageBar = self.ttErrorToastView;
    self.view.ttAssociatedScrollView = self.tableView;

    // 有频道ID，没有关心ID
    if (isEmptyString(_categoryID)) {
        _categoryID = @"";
    }

//    if (_delegate && [_delegate respondsToSelector:@selector(mixListViewDidStartLoad:)]) {
//        [_delegate mixListViewDidStartLoad:self];
//    }

    //记录用户下拉刷新时间
    if (!getMore && fromRemote && !isEmptyString(self.localCacheKey)) {
        [[NewsListLogicManager shareManager] saveHasReloadForCategoryID:self.localCacheKey];
        [self hideRemoteReloadTip];
    }

    //远端请求数据，更新一次tip请求时间
    if (fromRemote) {
        [[NewsListLogicManager shareManager] updateLastFetchReloadTipTimeForCategory:self.localCacheKey];
    }

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

    if (_accountChangedNeedReadloadList) {
        fromLocal = NO;
        _accountChangedNeedReadloadList = NO;
    }

    [self userRefreshGuideHideTabbarBubbleView];

    if (getMore) {
        @weakify(self);
        [self.listVideoModel loadMoreWithParameters:[self moreParameter] completeBlock:^{
            @strongify(self);
            if (self.listVideoModel.error) {
                [self fetchListError:self.listVideoModel.error isGetMore:YES];
            }
            else{
                [self fetchListSuccessIsGetMore:YES];
            }
        }];
        //log3.0
        [self trackRefreshIfneed];
    }
    else
    {
        TTVideoFeedListParameter *parameter = [self parameter];
        parameter.getRomote = fromRemote;
        parameter.getLocal = fromLocal;
        parameter.getRemoteWhenLocalEmpty = getRemoteWhenLocalEmpty;
        @weakify(self);
        [self.listVideoModel loadDataWithParameters:parameter completeBlock:^{
            @strongify(self);
            if (self.listVideoModel.error) {
                if (self.listVideoModel.error.code == -999) {//cancel
                    return ;
                }
                [self fetchListError:self.listVideoModel.error isGetMore:NO];
            }
            else{
                if (self.listVideoModel.hasNew) {
                    self.shouldShowRefreshButton = self.listVideoModel.hasNew;
                }
                [self fetchListSuccessIsGetMore:NO];
            }
        }];
        //log3.0
        [self trackRefreshIfneed];
    }

}

- (void)fetchListError:(NSError *)error isGetMore:(BOOL)getMore
{
    BOOL isFromRemote = self.listVideoModel.isFromRemote;

    //频道变化
    if (error && [error.domain isEqualToString:kExploreFetchListErrorDomainKey] &&
        error.code == kExploreFetchListCategoryIDChangedCode) {

        [self tt_endUpdataData:YES error:nil tip:nil tipTouchBlock:nil];
        [self.tableView finishPullDownWithSuccess:NO];

        [self reloadListViewWithVideoPlaying];

        return ;
    }

    NSString * msg = nil;
    if(error.code == kServerUnAvailableErrorCode)
    {
        if(self.listVideoModel.dataArr.count == 0)
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

    [self trackLoadStatusEventWithErorr:error isLoadMore:getMore];
    //refresh_status log3.0
    [self trackRefreshStatusWithErorr:error isLoadMore:getMore];

    if(isFromRemote){
        [self tt_endUpdataData:!isFromRemote error:error tip:msg duration:kDefaultDismissDuration tipTouchBlock:nil];
        if (getMore) {
            [self.tableView finishPullUpWithSuccess:!error];
        }
        else {
            [self updateCustomTopOffset];
            [self.tableView finishPullDownWithSuccess:!error];
        }

    }
    else if ([self tt_hasValidateData]) {
        [self tt_endUpdataData:!isFromRemote error:error tip:msg duration:kDefaultDismissDuration tipTouchBlock:nil];

    }
    [self reportDelegateLoadFinish:YES isUserPull:self.tableView.pullDownView.isUserPullAndRefresh isGetMore:getMore];
}

- (void)showTopPGCList
{
//    //获取视频订阅号开关标志信息
//    NSDictionary *resultDict = [[operationContext objectForKey:kExploreFetchListResponseRemoteDataKey] objectForKey:@"result"];
//    if ([[resultDict allKeys] containsObject:@"show_top_pgc_list"]) {
//        NSNumber *showPCGList = resultDict[@"show_top_pgc_list"];
//        if ([showPCGList isKindOfClass:[NSNumber class]]) {
//            [TTPGCFetchManager setShouldShowVideoPGC:[showPCGList boolValue]];
//        }
//    }
}

- (void)beforeReloadTableView
{
    [self showTopPGCList];
    [TTFeedDislikeView enable];
}

- (void)fetchListSuccessIsGetMore:(BOOL)getMore
{

    [self beforeReloadTableView];

    if (![self checkSameCategoryIsGetMore:getMore]) {
        return;
    }
    BOOL isFromRemote = self.listVideoModel.isFromRemote;

    BOOL hasMore = self.listVideoModel.hasMore;
    //默认给hasmore 设置YES 如果是加载更多的操作 根据返回值来处理list的hasmore
    self.tableView.hasMore = YES;
    if(getMore) {
        self.tableView.hasMore = hasMore;
        if(self.listVideoModel.increaseNumber == 0){
            self.tableView.hasMore = NO;
        }
    }
    //这个字段是说明 请求是否完成，如果只从local读取则为YES， 如果有本地和远端两种请求，remote返回后 isFinish才是YES， 而原先的代码 在isFinish为NO的时候 不会reloadTable 所以在else里加一个reload。 --- nick 4.9
    if (isFromRemote)
    {
        [self refreshTrackerIsFromRemote:isFromRemote getMore:getMore];
        //插入"上次阅读到这里"cell
        //            NSNumber *lastReadOrderIndex = nil;
        //            lastReadOrderIndex = [self handleLastReadBeforeRefreshIfNeeded:getMore fromRemote:isFromRemote];
        //            [self insertLastReadCellAfterRefreshIfNeededWithIncreasedCount:self.listVideoModel.increaseNumber isLoadMore:getMore orderIndex:lastReadOrderIndex];

        if (getMore) {
            [self reloadListViewWithVideoPlaying];
        } else {
            if (self.isLastReadRefresh) {
                self.isLastReadRefresh = NO;
                [self addLastReadTrackWithLabel:[self modifyEventLabelForRefreshEvent: @"refresh_last_read"]];
            }

            [self reloadListViewWithVideoPlaying];
        }
    }
    else
    {
        [self reloadListViewWithVideoPlaying];
    }

    if (isFromRemote) {
        [self.preloadDetail tryPreload];

        //2个统计
        [self trackEventUpdateRemoteItemsCount:[self.listVideoModel.netData.dataArray count]];
        [self trackEventUpdateRemoteItemsCountAfterMerge:self.listVideoModel.increaseNumber];

        [self trackLoadStatusEventWithErorr:nil isLoadMore:getMore];
    }
    //refresh_status log3.0
    [self trackRefreshStatusWithErorr:nil isLoadMore:getMore];

    [self showNewTipsWithIsLoadMore:getMore isFromRemote:isFromRemote];
    self.tableView.pullUpView.hidden = ![self tt_hasValidateData];
    if(isFromRemote){

        if (getMore) {
            [self.tableView finishPullUpWithSuccess:YES];
        }
        else {
            [self updateCustomTopOffset];
            [self.tableView finishPullDownWithSuccess:YES];
        }
        //            [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime])
        //                                                 forKey:kExploreFetchListFinishRequestTimeStampKey];
        //            [self exploreMixedListTimeConsumingMonitorWithContext:operationContext];

    }

    if (!getMore && _isShowing) {
        [[TTVAutoPlayManager sharedManager] tryAutoPlayInTableView:self.tableView];
    }

    if (!isFromRemote && self.tableView.pullDownView.state == PULL_REFRESH_STATE_INIT && self.tableView.customTopOffset != 0) {
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.customTopOffset - self.tableView.contentInset.top) animated:NO];
    }
    [self reportDelegateLoadFinish:isFromRemote isUserPull:self.tableView.pullDownView.isUserPullAndRefresh isGetMore:getMore];

    [self rebackTracker];

}

- (void)refreshTrackerIsFromRemote:(BOOL)isFromRemote getMore:(BOOL)getMore
{
    if (isFromRemote && !getMore) {
        // 统计自动刷新
        if (self.reloadFromType == TTReloadTypeAuto) {
            [self trackEventForLabel:[self modifyEventLabelForRefreshEvent: @"refresh_enter_auto"]];
        }
        else if (self.reloadFromType == TTReloadTypeAutoFromBackground){
            [self trackEventForLabel:[self modifyEventLabelForRefreshEvent: @"refresh_auto"]];
        }
    }
}

- (BOOL)checkSameCategoryIsGetMore:(BOOL)getMore
{
    if (![self.listVideoModel.categoryID isEqualToString:self.categoryID]) {
        [self tt_endUpdataData:YES error:nil tip:nil tipTouchBlock:nil];

        if (getMore) {
            [self.tableView finishPullUpWithSuccess:NO];
        }
        else {
            [self.tableView finishPullDownWithSuccess:NO];
        }

        return NO ;
    }
    return YES;
}

- (void)rebackTracker
{
//        // 回流统计
//        NSArray * ignoredRebackItemIDs = [operationContext valueForKey:kExploreFetchListIgnoredRebackItemIDs];
//        if ([ignoredRebackItemIDs isKindOfClass:[NSArray class]] && [ignoredRebackItemIDs count] > 0) {
//            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
//            [dict setValue:@"umeng" forKey:@"category"];
//            [dict setValue:@"recommend_feed" forKey:@"tag"];
//            [dict setValue:@"reback_dup" forKey:@"label"];
//            [dict setValue:@{@"gids" : ignoredRebackItemIDs} forKey:@"extra"];
//
//            [TTTrackerWrapper eventData:dict];
//        }
}

- (void)showNewTipsWithIsLoadMore:(BOOL)isLoadMore isFromRemote:(BOOL)isFromRemote
{
    NSInteger showTopBubbleViewDelay = kDefaultDismissDuration;

    NSString * tip;
    NSInteger duration = 0;
    SSTipModel * tipModel;

    NSInteger updateCount = MAX(0, self.listVideoModel.increaseNumber);
    if (isFromRemote && !isLoadMore) {
        TTVRefreshTips *refreshTips = self.listVideoModel.netData.tips;
        tipModel = [[SSTipModel alloc] initWithTips:refreshTips];
        NSString * msg = nil;
        NSString * displayTemplate = tipModel.displayTemplate;
        if (!isEmptyString(displayTemplate)) {
            NSRange range = [displayTemplate rangeOfString:displayTemplate];
            if (range.location != NSNotFound) {
                if (updateCount > 0) {
                    msg = [displayTemplate stringByReplacingOccurrencesOfString:kSSTipModelDisplayTemplatePlaceholder withString:[NSString stringWithFormat:@"%ld", (long)updateCount]];
                } else {
                    msg = NSLocalizedString(@"暂无更新，休息一会儿", nil);
                }
            }
        } else if (!isEmptyString(tipModel.displayInfo)) {
            msg = tipModel.displayInfo;
        }

        duration = [tipModel.displayDuration intValue];
        if (isEmptyString(msg)) {
            if (self.listVideoModel.increaseNumber) {
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

    if(isFromRemote){
        @weakify(self);
        [self tt_endUpdataData:!isFromRemote error:nil tip:tip duration:duration tipTouchBlock:^{
            @strongify(self);
            [self notifyBarAction:tipModel];
        }];
    }
    else if ([self tt_hasValidateData]) {
        // loading时没有数据不显示动画icon，恢复动画icon显示，
        [self.tableView.pullDownView showAnimationView];

        @weakify(self);
        [self tt_endUpdataData:!isFromRemote error:nil tip:tip duration:duration tipTouchBlock:^{
            @strongify(self);
            [self notifyBarAction:tipModel];
        }];
    }
}

#pragma mark - NotifyBar Funcs

- (void)notifyBarAction:(SSTipModel*)tipModel
{
    [[SSActionManager sharedManager] actionForModel:tipModel];
}

#pragma mark - UIViewControllerErrorHandler

- (void)refreshData
{
    [self.tableView triggerPullDown];
}

- (BOOL)tt_hasValidateData {
    if (self.listVideoModel.dataArr.count>0) {
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
    //self.reloadFromType = TTReloadTypeNone;为了刷新统计时发送正确的reloadFromType给传过去
    [self.tableView triggerPullDown];
}

- (void)pullAndRefreshWithLastReadUpate
{
    self.refreshShouldLastReadUpate = YES;
    self.reloadFromType = TTReloadTypeLastRead;
    [self pullAndRefresh];
}

- (void)scrollToTopEnable:(BOOL)enable
{
    self.tableView.scrollsToTop = enable;
}

- (void)scrollToTopAnimated:(BOOL)animated
{
    [self updateCustomTopOffset];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.customTopOffset - self.tableView.contentInset.top) animated:animated];
}

- (void)setListTopInset:(CGFloat)topInset BottomInset:(CGFloat)bottomInset
{
    [self setTtContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
    [self.tableView setContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
}

- (void)clearListContent
{
    [self.listVideoModel reset];
    [self tt_endUpdataData];
//    [self.tableView finishPullDownWithSuccess:NO];
    self.indexPathController.dataModel = nil;
    [self resetScrollView];
    [self reloadListView];
}

// 统一频道ID和关心ID
- (NSString *)primaryKey {
    return _categoryID;
}

// userDefault中的key，因为第一个tab中的视频是video，而第二个tab中的推荐也是video
- (NSString *)localCacheKey {
    return self.isVideoTabCategory ? [NSString stringWithFormat:@"tab1_%@", self.categoryID]  : [NSString stringWithFormat:@"tab0_%@", self.categoryID];
}

#pragma mark -
#pragma mark LastRead

- (void)addLastReadTrackWithLabel:(NSString *)label
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.categoryID forKey:@"category_id"];
    [dict setValue:[NSNumber numberWithInteger:self.refer] forKey:@"refer"];
    wrapperTrackEventWithCustomKeys(@"category", label, nil, nil, dict);
}

- (BOOL)isCategoryWithHeadInfo
{
    //“体育”和“财经”等有浮顶信息的频道
    return [[self.listVideoModel.dataArr firstObject] isKindOfClass:[TTVFeedListWebItem class]];
}

- (void)didSelectLastReadCell
{
    _isLastReadRefresh = YES;
    [self pullAndRefreshWithLastReadUpate];
    [self addLastReadTrackWithLabel:@"last_read_click"];
}

#pragma mark -
#pragma mark preload

- (void)reportDelegateLoadFinish:(BOOL)finish isUserPull:(BOOL)userPull isGetMore:(BOOL)isGetMore
{
    if ([_delegate respondsToSelector:@selector(feedDidFinishLoadIsFinish:isUserPull:)]) {
        [_delegate feedDidFinishLoadIsFinish:finish isUserPull:userPull];
    }
}

- (void)reportDelegateCancelRequest
{
    if (_delegate && [_delegate respondsToSelector:@selector(feedRequestDidCancelRequest)]) {
        [_delegate feedRequestDidCancelRequest];
    }
}


#pragma mark - UIScrollViewDelegate Methods


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isCustomAnimationForcell = NO;
    [self.preloadDetail suspendPreloadDetail];
    [[TTVAutoPlayManager sharedManager] cancelTrying];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self dockHeaderViewBar];
        [self.preloadDetail tryPreload];
    }
    [[TTVAutoPlayManager sharedManager] tryAutoPlayInTableView:self.tableView];
    [self invalidMovieViewOfFirstCellIfNeeded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self dockHeaderViewBar];
    [self.preloadDetail tryPreload];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [TTFeedDislikeView dismissIfVisible];
    if ([self.delegate respondsToSelector:@selector(feedViewDidWillScrollToTop)]) {
        [self.delegate feedViewDidWillScrollToTop];
    }
    return YES;
}

- (NSInteger)lastReadDataIndexWithNotInterestDataIndex:(NSInteger)notInterestDataIndex
{
    NSInteger lastReadDataIndex = -1;
    NSInteger next = notInterestDataIndex + 1;
    NSInteger pre = notInterestDataIndex - 1;
    if (self.listVideoModel.dataArr.count > next) {//下一个cell是 LastReadCell
        TTVTableViewItem *item = (TTVTableViewItem *)[self.listVideoModel.dataArr objectAtIndex:next];
        if ([item isKindOfClass:[TTVLastReadItem class]]) {
            lastReadDataIndex = next;
        }
    }
    if (lastReadDataIndex == -1) {
        if (self.listVideoModel.dataArr.count > pre && pre >= 0){
            TTVTableViewItem *item = (TTVTableViewItem *)[self.listVideoModel.dataArr objectAtIndex:pre];
            if ([item isKindOfClass:[TTVLastReadItem class]]) {
                lastReadDataIndex = pre;
            }
        }
    }
    return lastReadDataIndex;
}

- (void)invalidMovieViewOfFirstCellIfNeeded{
    UITableViewCell *firstCell = self.tableView.visibleCells.firstObject;
    if ([firstCell isKindOfClass:[TTVFeedListVideoCell class]] && [firstCell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
        TTVFeedListVideoCell<TTVFeedPlayMovie> *videoCell = (TTVFeedListVideoCell<TTVFeedPlayMovie> *)firstCell;

        if ([firstCell respondsToSelector:@selector(cell_isPlayingMovie)]) {
            if ([videoCell cell_hasMovieView]) {
                CGRect movieFrameInSuSuperView = [self.tableView.superview convertRect:videoCell.topMovieContainerView.frame fromView:videoCell];
                CGRect bottomFrameInSuSuperView = [self.tableView.superview convertRect:videoCell.bottomContainerView.frame fromView:videoCell];

                CGFloat tablViewTop = self.tableView.top;
                CGFloat movieViewBottom = movieFrameInSuSuperView.size.height + movieFrameInSuSuperView.origin.y + bottomFrameInSuSuperView.size.height;
                if (movieViewBottom < tablViewTop) {
                    [videoCell cell_detachMovieView];
                }

            }
        }
    }

}

#pragma mark - TTVFeedUserOpViewSyncMessage
//
//- (void)ttv_message_feedListItemChanged:(TTVFeedListItem *)feedListItem
//{
//    feedListItem.originData.savedConvertedArticle = nil;
//    if (feedListItem.cell == nil) {
//        return;
//    }
//    if (feedListItem) {
//        [self reloadListViewModifiedItems:@[feedListItem] withRowAnimation:UITableViewRowAnimationNone completion:nil];
//    }
//}

- (void)ttv_message_feedListItemExpendOrCollapseRecommendView:(TTVFeedListItem *)feedListItem isExpend:(BOOL) isExpend{
    if ([self.listVideoModel.dataArr containsObject:feedListItem]) {
        self.isCustomAnimationForcell = !isExpend;
    }else{
        self.isCustomAnimationForcell = NO;
    }
}

#pragma mark - TTVideoDislikeMessage

- (void)message_dislikeWithCellEntity:(TTVFeedListItem *)cellEntity hideTip:(BOOL)hideTip
{
    [self message_dislikeWithCellEntity:cellEntity hideTip:hideTip filterWords:nil dislikeAnchorFrame:CGRectZero dislikeSource:TTDislikeSourceTypeFeed];
}

#pragma mark - TTVFeedCellActionMessage

- (void)message_dislikeWithCellEntity:(TTVFeedListItem *)cellEntity filterWords:(NSArray *)filterWords dislikeAnchorFrame:(CGRect)dislikeAnchorFrame dislikeSource:(TTDislikeSourceType)dislikeSourceType
{
    [self message_dislikeWithCellEntity:cellEntity hideTip:NO filterWords:filterWords dislikeAnchorFrame:dislikeAnchorFrame dislikeSource:dislikeSourceType];
}

- (void)message_dislikeWithCellEntity:(TTVFeedListItem *)cellEntity  hideTip:(BOOL)hideTip filterWords:(NSArray *)filterWords dislikeAnchorFrame:(CGRect)dislikeAnchorFrame dislikeSource:(TTDislikeSourceType)dislikeSourceType
{
    if (![cellEntity isKindOfClass:[TTVFeedListItem class]]) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:NSStringFromClass([TTVFeedItem class]) forKey:@"class"];
        [[TTMonitor shareManager] trackService:@"dislike_not_work" status:1 extra:extra];
        return;
    }
    //首页tab与视频tab同时存在一个相同的频道video，在video频道做dislike操作时，需要将categoryID作为参数。
    //因为dislike时，会首先把首页tab的video频道的对应数据在数据库中抹去，这样当视频tab的video频道中接收到通知时，item的数据已经被抹去,无法获得item.categoryID
    TTVFeedListItem *item = cellEntity;
    NSInteger notInterestDataIndex = [self.listVideoModel.dataArr indexOfObject:item];
    if (notInterestDataIndex == NSNotFound) {
        return;
    }
    NSInteger lastReadDataIndex = [self lastReadDataIndexWithNotInterestDataIndex:notInterestDataIndex];

    TTVLastReadItem *lastReadOrderData = nil;
    if (lastReadDataIndex > 0) {
        TTVTableViewItem *item = [self.listVideoModel.dataArr objectAtIndex:lastReadDataIndex];
        if ([item isKindOfClass:[TTVLastReadItem class]]) {
            lastReadOrderData = (TTVLastReadItem *)item;
        }
    }

    self.indexPathController.ignoreDataModelChanges = YES;
    @onExit {
        self.indexPathController.ignoreDataModelChanges = NO;
    };

    BOOL willDeleteLastItem = (notInterestDataIndex == self.listVideoModel.dataArr.count - 1) ? YES : NO;
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
    NSMutableArray *shouldDeletedRows = [[NSMutableArray alloc] init];
    if (lastReadDataIndex >= 0) {
        if( (lastReadDataIndex == 1 && willDeleteFirstItem) || (lastReadDataIndex == 2 && topCellIsWebCell && notInterestDataIndex == 1) || (lastReadDataIndex == self.listVideoModel.dataArr.count - 2 && willDeleteLastItem) ){
            if (lastReadDataIndex < self.listVideoModel.dataArr.count) {
                [self.listVideoModel removeItemIfExist:lastReadOrderData];
            }
            willDeleteLastRead = YES;
            lastReadIndexPath = [NSIndexPath indexPathForRow:lastReadDataIndex inSection:0];
            if (lastReadIndexPath) {
                [shouldDeletedRows addObject:lastReadIndexPath];
            }
        }
    }
    [self.listVideoModel removeItemIfExist:item];
    self.indexPathController.dataModel = [[TLIndexPathDataModel alloc] initWithItems:self.listVideoModel.dataArr];


    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:notInterestDataIndex inSection:0];
        if (lastReadIndexPath != nil && lastReadDataIndex > notInterestDataIndex) {
            [shouldDeletedRows insertObject:indexPath atIndex:0];
        } else {
            [shouldDeletedRows addObject:indexPath];
        }
        [self.tableView deleteRowsAtIndexPaths:shouldDeletedRows withRowAnimation:UITableViewRowAnimationFade];


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

        if (lessDataIndex - 1 >= 0 && lessDataIndex - 1 < self.listVideoModel.dataArr.count) {
            TTVFeedListItem *orderData = (TTVFeedListItem *)[self.listVideoModel.dataArr objectAtIndex:lessDataIndex - 1];
            if (!([orderData.cell isKindOfClass:[TTVFeedListWebCell class]])) {
                [shouldReloadCellIndexPaths addObject:[NSIndexPath indexPathForRow:lessDataIndex - 1 inSection:0]];
            }
        }
        if (willDeleteLastRead && lastReadDataIndex >= 0 && lessDataIndex >= 0 && lessDataIndex < self.listVideoModel.dataArr.count) {
            TTVFeedListItem *orderData = (TTVFeedListItem *)[self.listVideoModel.dataArr objectAtIndex:lessDataIndex];
            if (![orderData.cell isKindOfClass:[TTVFeedListWebCell class]]) {
                [shouldReloadCellIndexPaths addObject:[NSIndexPath indexPathForRow:lessDataIndex inSection:0]];
            }
        }
        if (shouldReloadCellIndexPaths.count > 0) {
            [self.tableView reloadRowsAtIndexPaths:shouldReloadCellIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
    }

    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }

    TTVFeedListItem *notInterestingData = item;

    if (!isEmptyString(notInterestingData.originData.uniqueIDStr)) {
        NSMutableDictionary *adExtra = [[NSMutableDictionary alloc] init];

        if (notInterestingData.originData.cellType == TTVideoCellTypeAppDownload) {
            [adExtra setValue:@(notInterestingData.hasRead) forKey:@"clicked"];
        }

        if (notInterestingData.originData.logExtra) {
            [adExtra setValue:notInterestingData.originData.logExtra forKey:@"log_extra"];
        }
        else {
            [adExtra setValue:@"" forKey:@"log_extra"];
        }

        NSString *adID = notInterestingData.originData.adID;
        if (!isEmptyString(adID)) {
            if (!CGRectEqualToRect(dislikeAnchorFrame, CGRectZero)) {
                [adExtra setValue:@(CGRectGetMinX(dislikeAnchorFrame)) forKey:@"lu_x"];
                [adExtra setValue:@(CGRectGetMinY(dislikeAnchorFrame)) forKey:@"lu_y"];
                [adExtra setValue:@(CGRectGetMaxX(dislikeAnchorFrame)) forKey:@"rd_x"];
                [adExtra setValue:@(CGRectGetMaxY(dislikeAnchorFrame)) forKey:@"rd_y"];
            }
        }

        TTGroupModel *groupModel = [[TTGroupModel alloc] init];
        NSString *groupId = notInterestingData.originData.uniqueIDStr;
        NSString *itemId = @(notInterestingData.originData.article.itemId).stringValue;
        NSNumber *aggrType = @(notInterestingData.originData.article.aggrType);
        if ([notInterestingData.article respondsToSelector:@selector(itemID)]) {
            groupModel = [[TTGroupModel alloc] initWithGroupID:groupId itemID:itemId impressionID:nil aggrType:[aggrType integerValue]];
        } else {
            groupModel = [[TTGroupModel alloc] initWithGroupID:groupId];
        }

        [self.itemActionManager startSendDislikeActionType:DetailActionTypeNewVersionDislike source:dislikeSourceType groupModel:groupModel filterWords:filterWords cardID:nil actionExtra:notInterestingData.originData.article.actionExtra adID:@(adID.longLongValue) adExtra:adExtra widgetID:nil threadID:nil finishBlock:nil];
    }

    NSString *title = [TTAccountManager isLogin] ? kNotInterestTipUserLogined : kNotInterestTipUserUnLogined;
    if (hideTip) {
        title = nil;
    }
    [self tt_endUpdataData:NO error:nil tip:title duration:kDefaultDismissDuration tipTouchBlock:nil];

}

//即时下架文章和广告,待测试
- (void)message_deleteItemsOnRealTime:(NSArray<TTVFeedItem *> *)items
{
    NSMutableArray <TTVFeedListItem *> *array = [NSMutableArray array];
    for (TTVFeedListItem *item in self.listVideoModel.dataArr) {
        if (![item isKindOfClass:[TTVFeedListItem class]]) {
            continue;
        }
        for (TTVFeedItem *feedItem in items) {
            if ([[item.originData uniqueIDStr] isEqualToString:[feedItem uniqueIDStr]]) {
                [array addObject:item];
            }
        }
    }
    [self.listVideoModel.dataArr removeObjectsInArray:array];
    self.indexPathController.dataModel = [[TLIndexPathDataModel alloc] initWithItems:self.listVideoModel.dataArr];
}

- (void)removeExpireADs {
    [self.listVideoModel removeExpireADs];
}

#pragma mark -- preload
- (void)onPreloadDetail
{

}

- (void)onPreloadMore
{
    // 统计 - preload
    self.reloadFromType = TTReloadTypePreLoadMore;
    [self loadMoreWithUmengLabel:[self modifyEventLabelForRefreshEvent:@"pre_load_more"] isPreload:YES];
}

#pragma mark -- auto reload

- (void)tryAutoReloadIfNeed
{
    BOOL shouldReloadAfterEnterForground = [self shouldReloadBackAfterLeaveCurrentCategory];

    if(([[NewsListLogicManager shareManager] shouldAutoReloadFromRemoteForCategory:self.localCacheKey] && [self.listVideoModel.dataArr count] > 0) || shouldReloadAfterEnterForground) {
        self.refreshShouldLastReadUpate = YES;
        self.reloadFromType = TTReloadTypeAutoFromBackground;
        [self pullAndRefresh];
    }
}

- (void)saveLeaveCurrentCategoryDate
{
    //离开时触发
    NSTimeInterval refreshInterval = ttsettings_getAutoRefreshIntervalForCategoryID(self.primaryKey);
    if (!_isClickCellLeaveList && refreshInterval > 0){
        [NewsListLogicManager saveDisappearDateForCategoryID:self.localCacheKey];
    }
}

- (BOOL)shouldReloadBackAfterLeaveCurrentCategory
{
    BOOL shouldReload = NO;
    NSTimeInterval interval = ttsettings_getAutoRefreshIntervalForCategoryID(self.primaryKey);
    if (!isEmptyString(self.primaryKey) && interval > 0) {
        NSTimeInterval timeInterval = [NewsListLogicManager listDisappearIntercalForCategoryID:self.localCacheKey];
        if (timeInterval > interval) {
            shouldReload = YES;
        }
    }
    return shouldReload;
}

#pragma mark -- auto tip
///返回YES，tabbar显示， 返回NO，显示蓝条 西瓜视频tab不显示红点或者数字
- (BOOL)tipRemoteUseTabbar
{
//    BOOL useTabbar = [NewsListLogicManager tipListUpdateUseTabbarOfCategoryID:self.primaryKey listLocation:ExploreOrderedDataListLocationCategory];
//    return useTabbar;
    return NO;
}

- (void)tryFetchTipIfNeed {
    if (_isDisplayView) {
        if ([[NewsListLogicManager shareManager] shouldFetchReloadTipForCategory:self.localCacheKey]) {
            [self fetchRemoteReloadTip];
        }
        else {
            [self fetchRemoteReloadTipLater];
        }
    }
}

- (void)fetchRemoteReloadTip {

    if ([self.listVideoModel.dataArr count] > 0) {
        __block TTVFeedItem * orderedData = nil;
        [self.listVideoModel.dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[TTVFeedListItem class]]) {
                orderedData = ((TTVFeedListItem *)obj).originData;
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

- (void)showRemoteReloadTip:(NSString *)tipString {

    @weakify(self);
    [self tt_endUpdataData:NO error:nil tip:tipString duration: [NewsListLogicManager shareManager].listTipDisplayInterval tipTouchBlock:^{
        @strongify(self);
        [self showRemoteReloadHasMessageNotifyBarViewClicked];
    }];

}

- (void)showRemoteReloadHasMessageNotifyBarViewClicked {
    [self hideRemoteReloadTip];

    self.refreshShouldLastReadUpate = YES;
    self.reloadFromType = TTReloadTypeTip;
    [self pullAndRefresh];


    [self trackEventForLabel:@"tip_refresh"];

    NSMutableDictionary * tipRefreshTrackerDic = [NSMutableDictionary dictionaryWithCapacity:10];
    [tipRefreshTrackerDic setValue:@"umeng" forKey:@"category"];
    [tipRefreshTrackerDic setValue:self.categoryID forKey:@"category_id"];
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
    if ([self tipRemoteUseTabbar]) {
        [self clearTipCount];
    }
    else {
        [[NewsListLogicManager shareManager] updateLastFetchReloadTipTimeForCategory:self.localCacheKey];
    }
}
/**
 *  提示更新数，发送给tabbar
 *
 *  @param count    更新的数字
 *  @param dotStyle YES用红点，NO 用数字
 */
- (void)notifyTipCount:(NSInteger)count useDotStyle:(BOOL)dotStyle
{
    if (count > 0) {
        if (dotStyle) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeExploreTabBarBadgeNumberNotification object:nil userInfo:@{kExploreTabBarItemIndentifierKey:kTTTabVideoTabKey, kExploreTabBarDisplayRedPointKey:@(YES)}];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeExploreTabBarBadgeNumberNotification object:nil userInfo:@{kExploreTabBarItemIndentifierKey:kTTTabVideoTabKey, kExploreTabBarBadgeNumberKey:@(count)}];
        }
    }
}

- (void)clearTipCount {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeExploreTabBarBadgeNumberNotification object:nil userInfo:@{kExploreTabBarItemIndentifierKey:kTTTabVideoTabKey, kExploreTabBarBadgeNumberKey:@(0)}];
}

#pragma mark - DisplayMessage

- (void)displayMessage:(NSString*)msg withImage:(UIImage*)image {
    [self displayMessage:msg withImage:image duration:.5f];
}

- (void)displayMessage:(NSString*)msg withImage:(UIImage*)image duration:(float)duration {
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:image autoDismiss:YES dismissHandler:nil];
}

#pragma mark -- go detail label

- (NewsGoDetailFromSource)goDetailFromSouce
{
    return NewsGoDetailFromSourceCategory;
}

#pragma mark -- SSImpressionProtocol

- (void)needRerecordImpressions {

    if ([self.listVideoModel.dataArr count] == 0) {
        return;
    }

    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.refer = self.refer;

    for (TTVFeedListVideoCell * cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[TTVFeedListVideoCell class]]) {
            TTVFeedListItem *entity = cell.item;
            if ([entity isKindOfClass:[TTVFeedListItem class]]) {
                if (self.isDisplayView && _isShowing) {
                    [self recordGroupWithItem:entity status:SSImpressionStatusRecording];
                }
                else {
                    [self recordGroupWithItem:entity status:SSImpressionStatusSuspend];
                }
            }
        }
    }
}

#warning 暂时用于对比 测试通过后可删除
- (void)subscribeStatusChangedNotification:(NSNotification*)notification {
    ExploreEntry * item = [notification.userInfo objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];

    [self.listVideoModel.dataArr enumerateObjectsUsingBlock:^(TTVTableViewItem *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[TTVFeedListItem class]]) {
            TTVFeedListItem *videoFeedItem = (TTVFeedListItem *)obj;
            TTVVideoArticle *article = videoFeedItem.article;
            NSString *mediaId = article.userId;
#warning media_id ?
//            NSString *mediaId = [article.mediaInfo tt_stringValueForKey:@"media_id"];
//            if ([mediaId isEqualToString:item.entryID]) {
//                article.isSubscribe = item.subscribed;
//                [article save];
//            }

        }
    }];
}

#pragma mark - YSWebViewDelegate
// 预加载广告页
- (BOOL)webView:(nullable YSWebView *)webView shouldStartLoadWithRequest:(nullable NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType {
    // 保证预加载广告页能正常加载
    return YES;
}

- (void)webViewDidFinishLoad:(YSWebView *)webView {
    // 加载完成后，将is_hidden_web_view置为NO
}

#pragma mark - Utils

- (NSInteger)indexInTabbarController {
    UIWindow * mainWindow = [[UIApplication sharedApplication].delegate window];
    if (![mainWindow.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
        return NSNotFound;
    }
    TTArticleTabBarController * tabBarController = (TTArticleTabBarController *)mainWindow.rootViewController;
    UINavigationController * topNavViewController = [TTUIResponderHelper topNavigationControllerFor: self];
    UIViewController * topViewController = self.view.viewController;
    while(topViewController.parentViewController && ![topViewController.parentViewController isKindOfClass:[UINavigationController class]]) {
        topViewController = topViewController.parentViewController;
    }
    if (!topViewController) {
        return NSNotFound;
    }
    if (![topNavViewController.viewControllers containsObject:topViewController] || self.refer != 1) {
        return NSNotFound;
    }
    return [tabBarController.viewControllers indexOfObject:topNavViewController];
}

- (void)trackAutoPlayCellEnterBackground
{
    for (TTVFeedListCell *cell in [_tableView visibleCells]) {
        if (![cell isKindOfClass:[TTVFeedListCell class]]) {
            continue;
        }
        if ([cell.item.originData isKindOfClass:[TTVFeedItem class]]) {
            [self newMovieAutoOverTrack:cell feedItem:cell.item.originData];
        }
    }
}

/*5.7新增，新用户刷新引导相关通知*/
//用户下拉刷新的时候应该隐藏顶部浮层
- (void)userRefreshGuideHideTopBubbleView{
//    [[NSNotificationCenter defaultCenter] postNotificationName:kFeedUserRefreshGuideHideTopBubbleViewNotification object:nil userInfo:nil];
}

//用户刷新的时候需要隐藏掉底部的浮层
- (void)userRefreshGuideHideTabbarBubbleView{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFeedUserRefreshGuideHideTabbarBubbleViewNotification" object:nil userInfo:nil];
}

//刷新获取了数据以后
- (void)userRefreshGuideShowTopBubbleViewWithDelay:(NSInteger)delay{
//    if(delay < 0){
//        delay = kDefaultDismissDuration;
//    }
//    else if(delay >= 10){
//        delay = 10;
//    }
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kFeedUserRefreshGuideShowTopBubbleViewNotification object:nil userInfo:nil];
//    });
}

#pragma mark - TTVideoFeedListServiceMessage

- (void)message_updateCommentCount:(NSNumber *)commentCount groupId:(NSString *)groupId {

    if (isEmptyString(groupId)) {

        return ;
    }

    [self.listVideoModel.dataArr enumerateObjectsUsingBlock:^(TTVTableViewItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if ([obj isKindOfClass:[TTVFeedListItem class]]) {

            TTVFeedListItem *item = (TTVFeedListItem *)obj;

            if ([@([item article].groupId).stringValue isEqualToString: groupId]) {

                TTVVideoArticle *article = [item article];
                article.commentCount = commentCount.longLongValue;

                [self reloadListViewWithVideoPlaying];

                *stop = YES;
            }
        }

    }];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self accountChanged];
}

#pragma mark - TTVFeedListNotificationCenterDelegate
- (NSArray *)feedListNotificationCenterGetDataArray:(TTVFeedListNotificationCenter *)center {

    return self.listVideoModel.dataArr;
}

- (void)feedListNotificationCenterClearCache:(TTVFeedListNotificationCenter *)center {

    [self clearCache];
}

- (void)feedListNotificationCenterReadModeChanged:(TTVFeedListNotificationCenter *)center {
    [self reloadListViewWithVideoPlaying];
}

- (void)feedListNotificationCenterConnectionChanged:(TTVFeedListNotificationCenter *)center {

    [self connectionChanged];
}

- (void)feedListNotificationCenterFontChanged:(TTVFeedListNotificationCenter *)center {

    [self reloadListViewWithVideoPlaying];
}

- (void)feedListNotificationCenter:(TTVFeedListNotificationCenter *)center receiveShowRemoteReloadTipInfo:(NSDictionary *)info {

    [self receiveShowRemoteReloadTipWithInfo:info];
}

- (void)feedListNotificationCenter:(TTVFeedListNotificationCenter *)center receiveFetchRemoteReloadTipInfo:(NSDictionary *)info {

    [self receiveFetchRemoteReloadTipWithInfo:info];
}

- (void)feedListNotificationCenter:(TTVFeedListNotificationCenter *)center receiveFirstRefreshTipInfo:(NSDictionary *)info {

    [self receiveFirstRefreshTipWithInfo:info];
}

- (void)feedListNotificationCenter:(TTVFeedListNotificationCenter *)center deleteVideoInfo:(NSDictionary *)info {
    int64_t groupID = [info tt_longlongValueForKey:@"uniqueID"];
    if (groupID != 0) {
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", groupID];
        for (TTVFeedListItem *item in self.listVideoModel.dataArr) {
            if (![item isKindOfClass:[TTVFeedListItem class]]) {
                continue;
            }
            if ([[item.originData uniqueIDStr] isEqualToString:uniqueID]) {
                [self.listVideoModel removeItemIfExist:item];
                break;
            }
        }
        self.indexPathController.dataModel = [[TLIndexPathDataModel alloc] initWithItems:self.listVideoModel.dataArr];
    }
}

- (void)feedListNotificationCenterAppDidBeComeactive:(TTVFeedListNotificationCenter *)center {

    [self resumeTrackAdCellsInVisibleCells];
}

- (void)feedListNotificationCenterAppDidEnterBackground:(TTVFeedListNotificationCenter *)center {

    [self suspendTrackAdCellsInVisibleCells];
}

- (void)feedListNotificationCenterWebCellDidUpdate:(TTVFeedListNotificationCenter *)center relatedWebItem:(TTVFeedListWebItem *)webItem{
    NSIndexPath *indexPath = [self.indexPathController.dataModel indexPathForItem:webItem];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)feedListNotificationCenterExitFullScreen:(TTVFeedListNotificationCenter *)center {
    [self reloadListViewWithVideoPlaying];
}

- (void)clearCache
{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self clearListContent];
        if (self.isDisplayView) {
            [self pullAndRefresh];
        }
    });
}

- (void)accountChanged
{
    [[TTVAutoPlayManager sharedManager] resetForce];

    _accountChangedNeedReadloadList = YES;

    [self.listVideoModel cancelRequest];
    [self.listVideoModel removeAllItemsOnAccountChanged];

    [self tt_endUpdataData];
    [self.tableView finishPullDownWithSuccess:NO];

    [self reloadListView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pullAndRefresh];
    });
}

- (void)connectionChanged {
    if (_isDisplayView && self.ttErrorView && self.ttErrorView.hidden == NO && ![self tt_hasValidateData] && TTNetworkConnected()) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pullAndRefresh];
        });
    }
}

- (void)receiveShowRemoteReloadTipWithInfo:(NSDictionary *)info {

    if (![info isKindOfClass:[NSDictionary class]]) {

        return ;
    }

    NSString * cID = [info objectForKey:@"categoryID"];

    if ([cID isEqualToString:self.primaryKey]) {
        NSString * tipInfoString = [info objectForKey:@"tip"];
        NSUInteger count = [[info objectForKey:@"count"] intValue];
        NSUInteger style = [[info objectForKey:@"style"] intValue];
        BOOL useDotStyle = (style == 1);
        if ([self tipRemoteUseTabbar]) {
            if (count > 0) {
                [self notifyTipCount:count useDotStyle:useDotStyle];
            }
            else {
                [self clearTipCount];
            }
        }
        else {
            if (isEmptyString(tipInfoString)) {
                [self hideRemoteReloadTip];
            }
            else {
                [self showRemoteReloadTip:tipInfoString];
            }
        }
        [[NewsListLogicManager shareManager] updateLastFetchReloadTipTimeForCategory:self.localCacheKey];
        [self fetchRemoteReloadTipLater];
    }
}

- (void)receiveFetchRemoteReloadTipWithInfo:(NSDictionary *)info {
    if (![info isKindOfClass:[NSDictionary class]]) {

        return ;
    }

    NSString * cID = [info objectForKey:@"categoryID"];
    if ([cID isEqualToString:self.primaryKey]) {
        [self fetchRemoteReloadTip];
    }
}

- (void)receiveFirstRefreshTipWithInfo:(NSDictionary *)info {

    if (![info isKindOfClass:[NSDictionary class]]) {
        return ;
    }
    //不是当前正在展示的列表页则忽略 或者 如果是第三个tab的头条圈也忽略
    if (!_isDisplayView){
        return;
    }

    NSDictionary *userInfo = info;
    NSTimeInterval delaySeconds = [userInfo tt_doubleValueForKey:@"delaySceonds"];
    if (delaySeconds < 0) {
        delaySeconds = 0;
    }

    NSString *primaryKey = self.primaryKey;

    if ([self.listVideoModel.dataArr count] > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([primaryKey isEqualToString:self.primaryKey] && _isDisplayView) {
                [self fetchRemoteReloadTip];
            } else {
                NSDictionary *userInfo = @{@"delaySceonds":@(0)};
                [[NSNotificationCenter defaultCenter] postNotificationName:kFirstRefreshTipsSettingEnabledNotification object:nil userInfo:userInfo];
            }
        });
    } else {
        @weakify(self);
        [self.KVOController observe:self.listVideoModel keyPath:@"isLoading" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            @strongify(self);
            if (((NSNumber *)change[NSKeyValueChangeNewKey]).boolValue == NO && [self.listVideoModel.dataArr count] > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([primaryKey isEqualToString:self.primaryKey] && self.isDisplayView) {
                        [self fetchRemoteReloadTip];
                    } else {
                        NSDictionary *userInfo = @{@"delaySceonds":@(0)};
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFirstRefreshTipsSettingEnabledNotification object:nil userInfo:userInfo];
                    }
                    [self.KVOController unobserve:self.listVideoModel];
                });
            }
        }];
    }
}

- (void)setReloadFromType:(TTReloadType)reloadFromType{
    _reloadFromType = reloadFromType;
}

- (NSString *)refreshTrackV3Name{
    NSString *methodName = @"refresh_unkown";
    switch (self.reloadFromType) {
        case TTReloadTypeTab:
            methodName = @"tab";
            break;
        case TTReloadTypeAuto:
            methodName = @"enter_auto";
            break;
        case TTReloadTypeClickCategory:
            methodName = @"click";
            break;
        case TTReloadTypePull:
            methodName = @"pull";
            break;
        case TTReloadTypeLoadMore:
            methodName = @"load_more";
            break;
        case TTReloadTypeTabWithTip:
            methodName = @"tab_tip";
            break;
        case TTReloadTypeAutoFromBackground:
            methodName = @"auto";
            break;
        case TTReloadTypeClickCategoryWithTip:
            methodName = @"click_auto";
            break;
        case TTReloadTypeLastRead:
            methodName = @"last_read";
            break;
        case TTReloadTypePreLoadMore:
            methodName = @"pre_load_more";
            break;
        case TTReloadTypeNone:
            methodName = nil;
            break;
        case TTReloadTypeTip:
            methodName = @"tip";
            break;
        default:
            break;
    }
    return methodName;
}

- (void)trackRefreshIfneed{
    NSString *methodName = [self refreshTrackV3Name];
    if (!isEmptyString(methodName)) {
        [self trackRefreshV3ForCategory:self.categoryID refreshMethod:methodName];
    }
}

- (void)trackRefreshStatusWithErorr:(NSError *)error isLoadMore:(BOOL)isGetMore{
    NSString *methodName = [self refreshTrackV3Name];
    if (!isEmptyString(methodName)) {
        [self trackRefreshV3ForCategory:self.categoryID refreshMethod:methodName erorr:error isLoadMore:isGetMore];
    }
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

@end



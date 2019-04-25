//
//  TTWaterfallCollectionView.m
//  Article
//
//  Created by Chen Hong on 2016/11/9.
//
//

#import "TTWaterfallCollectionView.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "TTWaterfallCollectionViewCell.h"
#import "TTHuoShanTalentBannerCell.h"
#import "ExploreFetchListManager.h"
#import "SSImpressionManager.h"
#import "NetworkUtilities.h"
#import "NewsListLogicManager.h"
#import "SSTipModel.h"
#import "SSActionManager.h"
#import "Article.h"
#import "HuoShanTalentBanner.h"
#import "ArticleListNotifyBarView.h"
#import "ArticleImpressionHelper.h"
#import "TTRoute.h"
#import "ExploreMixListDefine.h"
#import "ExploreItemActionManager.h"
#import "DetailActionRequestManager.h"
#import "TTIndicatorView.h"
#import "TTThemedAlertController.h"
#import <TTAccountBusiness.h>
#import "ExploreMixedListBaseView+TrackEvent.h"
#import "ExploreListHelper.h"
#import "TTNetworkMonitorTransaction.h"
#import "SSCommon+UIApplication.h"
#import "TTUIResponderHelper.h"

#define kDefaultDismissDuration 2.0f
#define kColumnSpacing 5
#define kInteritemSpacing 5

static NSString *const kCellIdentifier = @"cell";
static NSString *const kBannerCellIdentifier = @"banner";
static BOOL huoShanShowConnectionAlertCount = YES;

@interface TTWaterfallCollectionView () <UICollectionViewDataSource,
CHTCollectionViewDelegateWaterfallLayout,
SSImpressionProtocol,
UIViewControllerErrorHandler>

@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)ExploreFetchListManager *fetchListManager;

@property(nonatomic, strong)NSString * categoryID;  // 频道ID
@property(nonatomic, strong)NSString * concernID;   // 关心ID
@property(nonatomic) BOOL isShowing;
@property(nonatomic) BOOL isDisplayView;

//本次stream刷新方式
@property(nonatomic, assign)ListDataOperationReloadFromType refreshFromType;

@property(nonatomic, strong)NSTimer *preloadTimer;

@property(nonatomic, retain)ExploreItemActionManager * itemActionManager;

@end

@implementation TTWaterfallCollectionView

- (id)initWithFrame:(CGRect)frame topInset:(CGFloat)topinset bottomInset:(CGFloat)bottomInset {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        
        [self addSubview:self.collectionView];
        
        self.ttErrorToastView = [ArticleListNotifyBarView addErrorToastViewWithTop:self.ttContentInset.top width:self.width];
        
        //[self.collectionView setContentInset:UIEdgeInsetsMake(topinset, 0, bottomInset, 0)];
        
        self.fetchListManager = [[ExploreFetchListManager alloc] init];
        
        [self addPullDownRefreshView];
        
        [[SSImpressionManager shareInstance] addRegist:self];
        
        [self reloadThemeUI];
    
        [self setContentTopInset:topinset bottomInset:bottomInset];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotInterestNotification:) name:@"HTSTabVideoDislikeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVideoDeleteNotification:) name:@"HTSTabVideoDeleteNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveItemDeleteNotification:) name:kExploreMixListItemDeleteNotification object:nil];
    }
    return self;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        layout.columnCount = 2;
        layout.minimumColumnSpacing = kColumnSpacing;
        layout.minimumInteritemSpacing = kInteritemSpacing;
        layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        _collectionView.alwaysBounceVertical = YES;
        
        [_collectionView registerClass:[TTWaterfallCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
        [_collectionView registerClass:[TTHuoShanTalentBannerCell class] forCellWithReuseIdentifier:kBannerCellIdentifier];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }
    return _collectionView;
}

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGRect)frameForCollectionView {
    CGRect rect = self.bounds;
    //rect.size.height -= self.bottomInset;
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
        return CGRectInset(rect, padding, 0);
    }
    return rect;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = [self frameForCollectionView];
}

- (void)willAppear {
    [super willAppear];
    if (self.isDisplayView) {
        [self beginListImpression];
    }
    self.isShowing = YES;
}

- (void)willDisappear {
    [super willDisappear];
    if (self.isDisplayView) {
        [self endListImpression];
    }
    self.isShowing = NO;
}

- (void)removeDelegates {
    [_fetchListManager resetManager];
    [[SSImpressionManager shareInstance] removeRegist:self];
    [_preloadTimer invalidate];
    _preloadTimer = nil;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    self.collectionView.backgroundColor = self.backgroundColor;
}

- (void)pullAndRefresh {
    [_collectionView triggerPullDown];
}

- (void)scrollToTopEnable:(BOOL)enable {
    _collectionView.scrollsToTop = enable;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchListManager.items.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.fetchListManager.items.count) {
        ExploreOrderedData *orderedData = self.fetchListManager.items[indexPath.row];
        if ([orderedData isKindOfClass:[ExploreOrderedData class]]) {
            if (orderedData.article) {
                TTWaterfallCollectionViewCell *cell = (TTWaterfallCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
                
                if (cell.cellData) {
                    [self endCellImpression:cell.cellData];
                }
                [cell refreshWithData:orderedData];
                [self beginCellImpression:cell.cellData];
                return cell;
            }
            else if (orderedData.huoShanTalentBanner) {
                TTHuoShanTalentBannerCell *cell = (TTHuoShanTalentBannerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kBannerCellIdentifier forIndexPath:indexPath];
                
                if (cell.cellData) {
                    [self endCellImpression:cell.cellData];
                }
                [cell refreshWithData:orderedData];
                [self beginCellImpression:cell.cellData];
                return cell;
            }
        }
    }
    
    NSAssert(NO, @"UICollectionCell must not be nil");
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row > _fetchListManager.items.count) {
        return;
    }
    
    id obj = [[_fetchListManager items] objectAtIndex:indexPath.row];
    if (![obj isKindOfClass:[ExploreOrderedData class]]) {
        return;
    }
    
    ExploreOrderedData *orderedData = (ExploreOrderedData *)obj;
    
    if ([orderedData.originalData isKindOfClass:[Article class]]) {
        [self didSelectCellWithOrderedData:orderedData];
    }
    else if ([orderedData.originalData isKindOfClass:[HuoShanTalentBanner class]]) {
        HuoShanTalentBanner *banner = (HuoShanTalentBanner *)(orderedData.originalData);
        
        if (!isEmptyString(banner.schemaUrl)) {
            wrapperTrackEvent(@"go_detail", @"click_got_talent_banner");
            NSURL *url = [TTStringHelper URLWithURLString:banner.schemaUrl];
            
            if ([[TTRoute sharedRoute] canOpenURL:url]) {
                [[TTRoute sharedRoute] openURLByPushViewController:url];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.fetchListManager.items.count) {
        ExploreOrderedData *orderedData = self.fetchListManager.items[indexPath.row];
        if ([orderedData isKindOfClass:[ExploreOrderedData class]]) {
            TTImageInfosModel *imageModel = nil;
            CGFloat imageHeight = 0.f;
            CGFloat imageWidth = (collectionView.width - kColumnSpacing) / 2;
            CGFloat infoBarHeight = 0.f;
            
            if ([orderedData.originalData isKindOfClass:[Article class]]) {
                imageModel = orderedData.listLargeImageModel;
                infoBarHeight = [TTWaterfallCollectionViewCell infoBarHeight];
            }
            else if ([orderedData.originalData isKindOfClass:[HuoShanTalentBanner class]]) {
                HuoShanTalentBanner *banner = (HuoShanTalentBanner *)(orderedData.originalData);
                imageModel = banner.coverImageModel;
            }
            
            if (!imageModel) {
                return CGSizeMake(imageWidth, 100);
            }
            
            if (imageModel && imageModel.width > 0) {
                imageHeight = (imageWidth * imageModel.height) / imageModel.width;
            }
            
            return CGSizeMake(imageWidth, ceilf(imageHeight) + infoBarHeight);
        }
    }
    return CGSizeMake((collectionView.width - kColumnSpacing) / 2, 100);
}

#pragma mark -

- (void)refreshListViewForCategory:(TTCategory *)category isDisplayView:(BOOL)display fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadFromType:(ListDataOperationReloadFromType)fromType
{
    NSString *previousCategoryID = self.currentCategory.categoryID;
    
    [super refreshListViewForCategory:category isDisplayView:display fromLocal:fromLocal fromRemote:fromRemote reloadFromType:fromType];
    
    BOOL categoryNotChange = !isEmptyString(previousCategoryID) && !isEmptyString(self.currentCategory.categoryID) && [previousCategoryID isEqualToString:self.currentCategory.categoryID];
    
//    if (fromRemote) {
//        [self.fetchListManager cancelAllOperations];
//        [_collectionView triggerPullDown];
//    } else  {
//        [self fetchFromLocal:YES fromRemote:NO getMore:NO];
//    }
    self.categoryID = self.currentCategory.categoryID;
    self.concernID = self.currentCategory.concernID;
    self.isDisplayView = display;
    
    if (!(fromLocal && !fromRemote && categoryNotChange && self.fetchListManager.items.count != 0)) {
        if (fromRemote) {
            [self.fetchListManager cancelAllOperations];
            [_collectionView triggerPullDown];
        }
        else {
            [self fetchFromLocal:fromLocal fromRemote:fromRemote getMore:NO];
        }
    }
    
    if (!categoryNotChange) {
        [self scrollToTopAnimated:NO];
    }
}

- (void)refreshDisplayView:(BOOL)display {
    [super refreshDisplayView:display];
    self.isDisplayView = display;
}

- (void)scrollToTopAnimated:(BOOL)animated
{
    [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.customTopOffset - self.collectionView.contentInset.top) animated:animated];
}

- (void)setContentTopInset:(CGFloat)topInset bottomInset:(CGFloat)bottomInset
{
    [self setTtContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
    [self.collectionView setContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
    [self.collectionView setScrollIndicatorInsets:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
}

- (void)addPullDownRefreshView {
    __weak typeof(self) wself = self;
    
    NSString *loadingText = [SSCommonLogic isNewPullRefreshEnabled] ? nil : @"推荐中";
    
    [self.collectionView addPullDownWithInitText:@"下拉推荐"
                                        pullText:@"松开推荐"
                                     loadingText:loadingText
                                      noMoreText:@"暂无新数据"
                                        timeText:nil
                                     lastTimeKey:nil
                                   actionHandler:^{
                                       // 频道下拉刷新统计
                                       if (wself.collectionView.pullDownView.isUserPullAndRefresh) {
                                           [wself trackPullDownEventForLabel:@"refresh_pull"];
                                           wself.refreshFromType = ListDataOperationReloadFromTypePull;
                                       }
                                       
                                       [wself fetchFromLocal:![wself tt_hasValidateData] fromRemote:YES getMore:NO];
                                   }];
    
    CGFloat barH = [ArticleListNotifyBarView barHeight];
    self.ttMessagebarHeight = barH;
    //_listView.ttMessagebarHeight = barH;
    if ([SSCommonLogic isNewPullRefreshEnabled]) {
        self.collectionView.pullDownView.pullRefreshLoadingHeight = barH;
        self.collectionView.pullDownView.messagebarHeight = barH;
    }
    
    [self.collectionView tt_addDefaultPullUpLoadMoreWithHandler:^{
        __strong typeof(self) sself = wself;
        sself.refreshFromType = ListDataOperationReloadFromTypeLoadMore;
        [sself loadMoreWithUmengLabel:[NSString stringWithFormat:@"load_more_%@", sself.categoryID]];
    }];
    
    if ([self.collectionView.pullDownView respondsToSelector:@selector(titleLabel)]) {
        UILabel *titleLabel = [self.collectionView.pullDownView performSelector:@selector(titleLabel)];
        titleLabel.contentMode = UIViewContentModeCenter;
    }
}

- (void)fetchFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote getMore:(BOOL)getMore
{
    self.ttLoadingView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    self.ttTargetView = self.collectionView;
    [self tt_startUpdate];
    
    self.collectionView.ttIntegratedMessageBar = self.ttErrorToastView;
    self.ttAssociatedScrollView = self.collectionView;
    
    [_fetchListManager reuserAllOperations];
    
    NSMutableDictionary *condition = [NSMutableDictionary dictionary];
    [condition setValue:self.currentCategory.categoryID forKey:kExploreFetchListConditionListUnitIDKey];
    [condition setValue:@(_refreshFromType) forKey:kExploreFetchListConditionReloadFromTypeKey];
    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(mixListViewDidStartLoad:)]) {
//        [self.delegate mixListViewDidStartLoad:self];
//    }
    
    //记录用户下拉刷新时间
    if (!getMore && fromRemote && !isEmptyString(self.primaryKey)) {
        [[NewsListLogicManager shareManager] saveHasReloadForCategoryID:self.primaryKey];
        //[self hideRemoteReloadTip];
    }
    
    //远端请求数据，更新一次tip请求时间
    if (fromRemote) {
        [[NewsListLogicManager shareManager] updateLastFetchReloadTipTimeForCategory:self.primaryKey];
    }
    
    //判断是该列表第一次请求
//    BOOL isFirstRequest = [_fetchListManager.items count] == 0 && fromRemote && !getMore;
    
    self.ttViewType = TTFullScreenErrorViewTypeEmpty;
    
    //在fetch block中使用下面变量（block会捕获），防止mixed list base view复用时候categoryID和concernID变化了
    NSString *captureCategoryID = self.currentCategory.categoryID;
    
    
    //5.7新增，因为refreshFromType会在block使用，用于发送刷新统计事件，在这个地方先捕获，然后重置refreshFromType为默认值
    ListDataOperationReloadFromType captureRefreshFromType = self.refreshFromType;
    self.refreshFromType = ListDataOperationReloadFromTypeNone;
    
    WeakSelf;
    
    [_fetchListManager startExecuteWithCondition:condition
                                       fromLocal:fromLocal
                                      fromRemote:fromRemote
                                         getMore:getMore
                                    isDisplyView:self.isCurrentDisplayView
                                        listType:ExploreOrderedDataListTypeCategory
                                    listLocation:ExploreOrderedDataListLocationCategory
                                     finishBlock:^(NSArray *increaseItems, NSDictionary *operationContext, NSError *error) {
                                         StrongSelf;
                                         
                                         NSString *cid = [(NSDictionary *)[operationContext objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListConditionListUnitIDKey];
                                         
                                         NSString *concernID = [(NSDictionary *)[operationContext objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListConditionListConcernIDKey];
                                         
                                         NSArray * allItems = [operationContext objectForKey:kExploreFetchListItemsKey];
                                         
                                         BOOL isFromRemote = [[operationContext objectForKey:kExploreFetchListFromRemoteKey] boolValue];
                                         
                                         BOOL isResponseFromRemote = [[operationContext objectForKey:kExploreFetchListIsResponseFromRemoteKey] boolValue];
                                         
                                         BOOL isFinish = [[operationContext objectForKey:kExploreFetchListResponseFinishedkey] boolValue];
                                         
                                         BOOL hasMore = [[operationContext objectForKey:kExploreFetchListResponseHasMoreKey] boolValue] && allItems.count > 0;
                                         
                                         NSString *key = !isEmptyString(cid) ? cid : concernID;
                                         
                                         if (![key isEqualToString:self.primaryKey]) {
                                             [self tt_endUpdataData:YES error:nil tip:nil tipTouchBlock:nil];
                                             
                                             if (getMore) {
                                                 [self.collectionView finishPullUpWithSuccess:NO];
                                             }
                                             else {
                                                 [self.collectionView finishPullDownWithSuccess:NO];
                                             }
                                             
                                             return;
                                         }
                                         
                                         BOOL isLoadMore = [[operationContext objectForKey:kExploreFetchListGetMoreKey] boolValue];
                                         
                                         //频道变化
                                         if (error && [error.domain isEqualToString:kExploreFetchListErrorDomainKey] &&
                                             error.code == kExploreFetchListCategoryIDChangedCode) {
                                             
                                             [self tt_endUpdataData:YES error:nil tip:nil tipTouchBlock:nil];
                                             [self.collectionView finishPullDownWithSuccess:NO];
                                             
                                             [self reloadListView];
                                             
                                             return ;
                                         }
                                         
                                         if (!error) {
                                             //默认给hasmore 设置YES 如果是加载更多的操作 根据返回值来处理list的hasmore
                                             self.collectionView.hasMore = YES;
                                             
                                             if (getMore) {
                                                 if([increaseItems count] == 0) {
                                                     self.collectionView.hasMore = NO;
                                                 } else {
                                                     self.collectionView.hasMore = hasMore;
                                                 }
                                             } else {
                                                 self.collectionView.hasMore = hasMore;
                                             }
                                             
                                             [self reloadListView];
                                             
                                             NSString * tip;
                                             NSInteger duration = 0;
                                             SSTipModel * tipModel;
                                             
                                             if (isFinish && isFromRemote && !isLoadMore) {
                                                 
                                                 // 统计自动刷新
                                                 if (captureRefreshFromType == ListDataOperationReloadFromTypeAuto) {
                                                     NSString *label = [NSString stringWithFormat:@"refresh_enter_auto_%@", captureCategoryID];
                                                     wrapperTrackEvent(@"category", label);
                                                 }
                                                 
                                                 NSDictionary *remoteTipResult = [(NSDictionary *)[(NSDictionary *)[operationContext objectForKey:kExploreFetchListResponseRemoteDataKey] objectForKey:@"result"] objectForKey:@"tips"];
                                                 
                                                 tipModel = [[SSTipModel alloc] initWithDictionary:remoteTipResult];
                                                 NSString * msg = nil;
                                                 duration = [tipModel.displayDuration intValue];
                                                 
                                                 if ([increaseItems count] > 0) {
                                                     msg = NSLocalizedString(@"刷新成功", nil);
                                                 }
                                                 else {
                                                     msg = NSLocalizedString(@"暂无更新，休息一会儿", nil);
                                                 }
                                             
                                                 if (duration <= 0) {
                                                     duration = 2.f;
                                                 }
                                                 tip = msg;
                                             }
                                             
                                             if (isResponseFromRemote) {
                                                 [self tt_endUpdataData:NO error:nil tip:tip duration:duration tipTouchBlock:nil];
                                                 
                                                 if (getMore) {
                                                     [self.collectionView finishPullUpWithSuccess:!error];
                                                 }
                                                 else {
                                                     [self.collectionView finishPullDownWithSuccess:!error];
                                                 }
                                             }
                                             else if ([self tt_hasValidateData]) {
                                                 // loading时没有数据不显示动画icon，恢复动画icon显示，
                                                 [self.collectionView.pullDownView showAnimationView];

                                                 [self tt_endUpdataData];
                                                 //[self.collectionView finishPullDownWithSuccess:YES];
                                             }
//                                             else {
//                                                 [self tt_endUpdataData];
//                                             }
                                             
                                             self.collectionView.pullUpView.hidden = ![self tt_hasValidateData];
                                         }
                                         else {
                                             NSString * msg = nil;
                                             if(error.code == kServerUnAvailableErrorCode)
                                             {
                                                 if([self.fetchListManager items].count == 0)
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
                                             
                                             [self trackLoadStatusEventWithErorr:error isLoadMore:isLoadMore];
                                             
                                             if(isResponseFromRemote){
                                                 [self tt_endUpdataData:NO error:error tip:msg duration:kDefaultDismissDuration tipTouchBlock:nil];
                                                 if (getMore) {
                                                     [self.collectionView finishPullUpWithSuccess:NO];
                                                 }
                                                 else {
                                                     [self.collectionView finishPullDownWithSuccess:NO];
                                                 }
                                             }
                                             else if ([self tt_hasValidateData]) {
                                                 [self tt_endUpdataData:YES error:error tip:msg duration:kDefaultDismissDuration tipTouchBlock:nil];
                                             }
                                         }
                                         //此处判断是否需要获取更新提示的tip, 如果需要， 获取， 并且更新时间;如果还没到时间，开始倒计时
//                                         [weakSelf tryFetchTipIfNeed];
                                         
                                         [self reportDelegateLoadFinish:isFinish isUserPull:self.collectionView.pullDownView.isUserPullAndRefresh isGetMore:getMore];
                                     }];
}

- (void)reportDelegateLoadFinish:(BOOL)finish isUserPull:(BOOL)userPull isGetMore:(BOOL)isGetMore
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStopLoading:)]) {
        [self.delegate listViewStopLoading:self];
    }
}

- (void)reportDelegateCancelRequest
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStopLoading:)]) {
        [self.delegate listViewStopLoading:self];
    }
}

- (NSString *)primaryKey {
    return self.currentCategory.categoryID;
}

#pragma mark - UIViewControllerErrorHandler

- (void)refreshData {
    [self.collectionView triggerPullDown];
}

- (void)emptyViewBtnAction {
    [self.collectionView triggerPullDown];
}

- (BOOL)tt_hasValidateData {
    if (self.fetchListManager.items.count > 0) {
        return YES;
    }
    return NO;
}

- (void)loadMoreWithUmengLabel:(NSString *)label
{
    if (!_fetchListManager.isLoading && [_fetchListManager.items count] > 0) {
        if (TTNetworkConnected()) {
            [self fetchFromLocal:NO fromRemote:YES getMore:YES];
            if (!isEmptyString(label)) {
                [ExploreListHelper trackEventForLabel:label listType:ExploreOrderedDataListTypeCategory categoryID:self.categoryID concernID:self.concernID refer:1];
            }
        } else {
            [self fetchFromLocal:NO fromRemote:YES getMore:YES];
            [self trackLoadStatusEventForLabel:@"no_connections" isLoadMore:YES status:0];
        }
    }
    else {
        [self.collectionView finishPullUpWithSuccess:NO];
    }
}


- (void)reloadListView
{
    [self.collectionView reloadData];
}

#pragma mark - SSImpressionProtocol

- (void)needRerecordImpressions
{
    if (self.fetchListManager.items.count == 0) {
        return;
    }
    
    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = self.categoryID;
    params.concernID = self.concernID;
    params.refer = 1;
    
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        if ([cell isKindOfClass:[TTWaterfallCollectionViewCell class]]) {
            TTWaterfallCollectionViewCell * cellBase = (TTWaterfallCollectionViewCell *)cell;
            if ([cellBase.cellData isKindOfClass:[ExploreOrderedData class]]) {
                ExploreOrderedData * orderedData = (ExploreOrderedData *)cellBase.cellData;
                
                if (self.isDisplayView && _isShowing) {
                    [ArticleImpressionHelper recordHuoShanTalentForExploreOrderedData:orderedData status:SSImpressionStatusRecording params:params];
                }
                else {
                    [ArticleImpressionHelper recordHuoShanTalentForExploreOrderedData:orderedData status:SSImpressionStatusSuspend params:params];
                }
            }
        }
    }
}

- (void)endCellImpression:(ExploreOrderedData *)cellData {
    if ([cellData isKindOfClass:[ExploreOrderedData class]]) {
        SSImpressionParams *params = [[SSImpressionParams alloc] init];
        params.categoryID = self.categoryID;
        params.concernID = self.concernID;
        params.refer = 1;
        [ArticleImpressionHelper recordHuoShanTalentForExploreOrderedData:cellData status:SSImpressionStatusEnd params:params];
    }
}

- (void)beginCellImpression:(ExploreOrderedData *)cellData {
    SSImpressionStatus impressionStatus = (self.isDisplayView && _isShowing) ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = self.categoryID;
    params.concernID = self.concernID;
    params.refer = 1;
    [ArticleImpressionHelper recordHuoShanTalentForExploreOrderedData:cellData status:impressionStatus params:params];
}

- (void)endListImpression {
    [[SSImpressionManager shareInstance] leaveWithListKey:self.categoryID listType:SSImpressionGroupTypeHuoshanTalentList];
}

- (void)beginListImpression {
    [[SSImpressionManager shareInstance] enterWithListKey:self.categoryID listType:SSImpressionGroupTypeHuoshanTalentList];
}

- (void)setCategoryID:(NSString *)categoryID
{
    if (!isEmptyString(categoryID) && !isEmptyString(_categoryID) && [_categoryID isEqualToString:categoryID]) {
        return;
    }
    
    NSString * originalCID = [_categoryID copy];
    _categoryID = categoryID;
    
    //记录impression, 切换列表的时候，记录
    if (self.isDisplayView) {
        [self beginListImpression];
    }
    else {
        [self endListImpression];
    }
    
    if (![originalCID isEqualToString:_categoryID]) {
        [self clearListContent];
        [self reportDelegateCancelRequest];
    }
}

- (void)clearListContent
{
    [_fetchListManager resetManager];
    
    [self tt_endUpdataData];
    [self.collectionView finishPullDownWithSuccess:NO];
    [self reloadListView];
}

- (void)tryPreload {
    [_preloadTimer invalidate];
    
    self.preloadTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                         target:self
                                                       selector:@selector(preloadMore)
                                                       userInfo:nil
                                                        repeats:NO];
}

#pragma mark - 预加载更多

- (void)preloadMore {
    if (_fetchListManager.lastFetchRiseError) {
        return;
    }
    
    if(!_fetchListManager.isLoading && TTNetworkConnected() &&
       _fetchListManager.loadMoreHasMore && [_fetchListManager.items count] > 0)
    {
        NSArray *visibleCells = [self.collectionView visibleCells];
        if ([visibleCells count] > 0)
        {
            id obj = visibleCells.lastObject;
            if ([obj isKindOfClass:[TTWaterfallCollectionViewCell class]])
            {
                TTWaterfallCollectionViewCell * cell = (TTWaterfallCollectionViewCell *)obj;
                id data = cell.cellData;
                if ([data isKindOfClass:[ExploreOrderedData class]]) {
                    ExploreOrderedData * orderData = (ExploreOrderedData *)data;
                    NSUInteger index = 0;
                    if (orderData) {
                        index = [[_fetchListManager items] indexOfObject:orderData];
                    }
                    if (index > 0 && index < [[_fetchListManager items] count] && [[_fetchListManager items] count] - index <= 4) {
                        // 统计 - preload
                        self.refreshFromType = ListDataOperationReloadFromTypePreLoadMore;
                        NSString *label = [NSString stringWithFormat:@"pre_load_more_%@", self.categoryID];
                        [self loadMoreWithUmengLabel:label];
                    }
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self tryPreload];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self tryPreload];
}

#pragma mark - 不感兴趣
- (void)notInterestAction:(ExploreOrderedData *)orderedData {
    id item = orderedData;
    
    NSInteger notInterestDataIndex = [[_fetchListManager items] indexOfObject:item];
    if (notInterestDataIndex == NSNotFound) {
        return;
    }
    
    [_fetchListManager removeItemIfExist:item];
    
    [self.collectionView reloadData];
    
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    
    if ([item isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *notInterestingData = (ExploreOrderedData *)item;
        
        if (notInterestingData.originalData && notInterestingData.originalData.uniqueID != 0) {
            //added5.2：dislike后设置originalData的notInterested
            [self setNotInterestToOrderedData:notInterestingData];
            
            NSMutableDictionary *adExtra = [[NSMutableDictionary alloc] init];
            
            if (notInterestingData.logExtra) {
                [adExtra setValue: notInterestingData.logExtra forKey:@"log_extra"];
            }
            else {
                [adExtra setValue: @"" forKey:@"log_extra"];
            }
            
            NSNumber *adID = [notInterestingData.adID longLongValue] > 0 ? notInterestingData.adID : nil;
            
            if ([notInterestingData.originalData isKindOfClass:[Article class]]) {
                TTGroupModel *groupModel = [[TTGroupModel alloc] init];
                NSString *groupId = [NSString stringWithFormat:@"%lld", notInterestingData.originalData.uniqueID];
                if ([notInterestingData.article respondsToSelector:@selector(itemID)]) {
                    groupModel = [[TTGroupModel alloc] initWithGroupID:groupId itemID:notInterestingData.article.itemID impressionID:nil aggrType:[notInterestingData.article.aggrType integerValue]];
                } else {
                    groupModel = [[TTGroupModel alloc] initWithGroupID:groupId];
                }
                
                TTDislikeSourceType sourceType;
//                if ([[notification userInfo] tt_intValueForKey:@"dislike_source"] == 0) {
//                    sourceType = TTDislikeSourceTypeFeed;
//                }
//                else {
                    sourceType = TTDislikeSourceTypeDetail;
//                }
                [self.itemActionManager startSendDislikeActionType:DetailActionTypeNewVersionDislike source:sourceType groupModel:groupModel filterWords:nil cardID:nil actionExtra:notInterestingData.actionExtra adID:adID adExtra:adExtra widgetID:nil threadID:nil finishBlock:nil];
            }
            
            [ExploreItemActionManager removeOrderedData:notInterestingData];
        }
    }
}

- (void)receiveNotInterestNotification:(NSNotification *)notification
{
    // 根据videoID查询orderedData
    NSString *videoID = [[notification userInfo] tt_stringValueForKey:@"video_id"];
    if (isEmptyString(videoID)) {
        return;
    }
    
    NSArray *mixedDatas = [self getOrderedDataArrayFromVideoID:videoID];
    
    [mixedDatas enumerateObjectsUsingBlock:^(ExploreOrderedData *orderedData, NSUInteger idx, BOOL *stop) {
        if([orderedData isKindOfClass:[ExploreOrderedData class]] && [orderedData.originalData isKindOfClass:[Article class]]) {
            Article *article = orderedData.article;
            if (article.uniqueID == [videoID longLongValue]) {
                [self notInterestAction:orderedData];
            }
        }
    }];
}

- (void)setNotInterestToOrderedData:(ExploreOrderedData *)orderedData {
    if ([orderedData.originalData respondsToSelector:@selector(notInterested)]) {
        orderedData.originalData.notInterested = @(YES);
        [orderedData.originalData save];
    }
}

- (NSArray *)getOrderedDataArrayFromVideoID:(NSString *)videoID {
    if (!isEmptyString(videoID)) {
        NSArray *mixedDatas = [ExploreOrderedData objectsWithQuery:@{@"uniqueID":videoID}];
        return mixedDatas;
    }
    return nil;
}

#pragma mark - 文章下架

- (void)receiveItemDeleteNotification:(NSNotification *)notification {
    id item = [[notification userInfo] objectForKey:kExploreMixListDeleteItemKey];
    if ([item isKindOfClass:[ExploreOrderedData class]]) {
        BOOL isCategoryIDEqual = !isEmptyString(((ExploreOrderedData *)item).categoryID) && !isEmptyString(self.categoryID) && [((ExploreOrderedData *)item).categoryID isEqualToString:self.categoryID];
        BOOL isConcernIDEqual = !isEmptyString(((ExploreOrderedData *)item).concernID) && !isEmptyString(self.concernID) && [((ExploreOrderedData *)item).concernID isEqualToString:self.concernID];
        
        if (isCategoryIDEqual == NO && isConcernIDEqual == NO) {
            return;
        }
        if ([[_fetchListManager items] containsObject:item]) {
            [_fetchListManager removeItemIfExist:item];
            [self reloadListView];
        }
    }
}

- (void)receiveVideoDeleteNotification:(NSNotification *)notification {
    // 根据videoID查询orderedData
    NSString *videoID = [[notification userInfo] tt_stringValueForKey:@"video_id"];
    if (isEmptyString(videoID)) {
        return;
    }
    
    NSArray *mixedDatas = [self getOrderedDataArrayFromVideoID:videoID];
    
    [mixedDatas enumerateObjectsUsingBlock:^(ExploreOrderedData * obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        [userInfo setValue:obj forKey:kExploreMixListDeleteItemKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListItemDeleteNotification object:self userInfo:userInfo];
    }];

    [ExploreOrderedData removeEntities:mixedDatas];
}

#pragma mark - cell点击跳转

- (void)didSelectCellWithOrderedData:(ExploreOrderedData *)orderedData {
    if (TTNetworkConnected()) {
        if (TTNetworkWifiConnected() || !huoShanShowConnectionAlertCount) {
            [self openArticleByOrderedData:orderedData];
        }
        else {
            if (huoShanShowConnectionAlertCount) {
                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"您当前正在使用移动网络，继续播放将消耗流量", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
                [alert addActionWithTitle:NSLocalizedString(@"停止播放", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                    
                }];
                [alert addActionWithTitle:NSLocalizedString(@"继续播放", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                    huoShanShowConnectionAlertCount = NO;
                    [self openArticleByOrderedData:orderedData];
                }];
                [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
            }
        }
    }
    else {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    }
}

- (void)openArticleByOrderedData:(ExploreOrderedData *)orderedData {
    BOOL canOpenURL = NO;
    
    if (!isEmptyString(orderedData.openURL)) {
        NSURL *url = [TTStringHelper URLWithURLString:orderedData.openURL];
        
        NSString *gid = orderedData.uniqueID;

        NSMutableDictionary *extraInfo = [NSMutableDictionary dictionary];
        [extraInfo setValue:[TTAccountManager userID] forKey:@"uid"];
        
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            canOpenURL = YES;
            [[TTRoute sharedRoute] openURLByPushViewController:url];
            
            wrapperTrackEventWithCustomKeys(@"go_detail", @"click_got_talent_video", gid, nil, extraInfo);
        }
        else if ([[UIApplication sharedApplication] canOpenURL:url]) {
            canOpenURL = YES;
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

#pragma mark - copy from mixedListBaseView

- (void)trackLoadStatusEventWithErorr:(NSError *)error isLoadMore:(BOOL)isLoadMore
{
    NSString *label;
    NSInteger status = 0;
    if (!error) {
        label = @"done";
    } else {
        label = @"unknown_error";
        
        if (!TTNetworkConnected()) {
            label = @"no_connections";
        }
        else if (error.code == kInvalidDataFormatErrorCode) {
            label = @"api_error";
        }
        else if (error.code == kServerUnAvailableErrorCode) {
            label = @"service_unavailable";
        }
        else if (error.code == kInvalidSeverStatusErrorCode) {
            label = @"server_error";
        } else {
            NSError *underlyingError = [error userInfo][NSUnderlyingErrorKey];
            if (underlyingError)
            {
                status = [TTNetworkMonitorTransaction statusCodeForNSUnderlyingError:underlyingError];
                if (status == 2) {
                    //ConnectTimeoutException
                    label = @"connect_timeout";
                } else if (status == 3) {
                    label = @"network_timeout";
                } else {
                    label = @"network_error";
                }
            }
        }
    }
    
    [self trackLoadStatusEventForLabel:label isLoadMore:isLoadMore status:status];
}

- (void)trackLoadStatusEventForLabel:(NSString *)label isLoadMore:(BOOL)isLoadMore status:(NSInteger)status {
    if (isEmptyString(label)) {
        return;
    }
    
    NSString *channelLabel = [self.categoryID isEqualToString:kTTMainCategoryID] ? @"newtab" : @"category";
    NSString *trackLabel = [NSString stringWithFormat:@"%@_%@_%@", channelLabel, (isLoadMore?@"load_more":@"refresh"), label];
    wrapperTrackEvent(@"load_status", trackLabel);
    
}



@end

//
//  ExploreMixedListView.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-5.
//
//

#import "ExploreMixedListView.h"
//#import "TTCategoryStayTrackManager.h"
#import "TTArticleCategoryManager.h"
#import "UIScrollView+Refresh.h"
#import "ExploreMixedListBaseView+TrackEvent.h"
#import "ExploreMixedListBaseView+HeaderView.h"
//#import "ExploreMixedListBaseView+UploadingCell.h"
#import "TTArticleCategoryManager.h"
#import "UIView+Refresh_ErrorHandler.h"

/**
 *  用于umeng发送逻辑， 记录是否进入过推荐列表
 */
BOOL _umengFlagFirstEnterNewsCategory;

@interface ExploreMixedListView()
{
}

@end

@implementation ExploreMixedListView

- (void)dealloc
{
    [_listView removeDelegates];
}

- (instancetype)initWithFrame:(CGRect)frame
                     topInset:(CGFloat)inset
                  bottomInset:(CGFloat)bottomInset
                     listType:(ExploreOrderedDataListType)type
                 listLocation:(ExploreOrderedDataListLocation)listLocation
                      fromTab:(TTCategoryModelTopType)tabType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.listView = [[ExploreMixedListBaseView alloc] initWithFrame:self.bounds
                                                               listType:type
                                                           listLocation:listLocation];
//        [self.listView initializeUploadingCells];
        self.listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self setTopInset:inset bottomInset:bottomInset];
        
        [self.listView setExternalCondtion:@{kExploreFetchListConditionListFromTabKey : @(tabType)}];
        
        [self addSubview:_listView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                     topInset:(CGFloat)inset
                  bottomInset:(CGFloat)bottomInset
                     listType:(ExploreOrderedDataListType)type
                 listLocation:(ExploreOrderedDataListLocation)listLocation
{
    return [self initWithFrame:frame
                      topInset:inset
                   bottomInset:bottomInset
                      listType:type
                  listLocation:listLocation
                       fromTab:TTCategoryModelTopTypeNews];
}

- (instancetype)initWithFrame:(CGRect)frame topInset:(CGFloat)inset bottomInset:(CGFloat)bottomInset
{
    return [self initWithFrame:frame
                      topInset:inset
                   bottomInset:bottomInset
                      listType:ExploreOrderedDataListTypeCategory
                  listLocation:ExploreOrderedDataListLocationCategory];
}

#pragma mark - protected

- (void)setTabType:(TTCategoryModelTopType)tabType
{
    if (_tabType != tabType) {
        _tabType = tabType;
        [self.listView setExternalCondtion:@{kExploreFetchListConditionListFromTabKey : @(tabType)}];
    }
}

- (void)setTopInset:(CGFloat)topInset bottomInset:(CGFloat)bottomInset
{
    [self.listView setListTopInset:topInset BottomInset:bottomInset];
}

- (void)refreshListViewForCategory:(TTCategory *)category isDisplayView:(BOOL)display fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadFromType:(ListDataOperationReloadFromType)fromType
{
    if ([SSCommonLogic feedLoadingInitImageEnable]) {
        _listView.animationView.hidden = NO;
    }
    
    [self.listView removeExpireADs];
    [super refreshListViewForCategory:category isDisplayView:display fromLocal:fromLocal fromRemote:fromRemote reloadFromType:fromType];
    
    NSString * previousCategoryID = _listView.categoryID;
    
    BOOL categoryNotChange = !isEmptyString(_listView.categoryID) &&
                            !isEmptyString(self.currentCategory.categoryID) &&
                            [_listView.categoryID isEqualToString:self.currentCategory.categoryID];
    _listView.categoryID = self.currentCategory.categoryID;
    _listView.concernID = self.currentCategory.concernID;
    _listView.isDisplayView = display;
    _listView.refreshFromType = fromType;
    [_listView refreshHeaderViewShowSearchBar:fromLocal];
    
//    if (display) {
//        [_listView clearFirstTabBarTipIfNeed];
//    }
    
    BOOL empty = [[_listView.fetchListManager items] count] == 0;
    
    // 只有LastRead的情况也认为没有数据
    if (!empty && [[_listView.fetchListManager items] count] == 1) {
        ExploreOrderedData *orderedData = _listView.fetchListManager.items.firstObject;
        if ([orderedData isKindOfClass:[ExploreOrderedData class]] && orderedData.cellType == ExploreOrderedDataCellTypeLastRead) {
            empty = YES;
        }
    }
    
    if (!(fromLocal && !fromRemote && categoryNotChange && !empty)) {

        if (fromRemote) {
            if (_listView.fetchListManager.isLoading) {
                [_listView.listView finishPullDownWithSuccess:NO];
            }
            
            [_listView.fetchListManager cancelAllOperations];
            
            if (!empty) {
                [_listView.listView triggerPullDown];
            }
            else {
                [_listView setListHeader:nil];
                [_listView.listView triggerPullDownAndHideAnimationView];
            }
        }
        else {
            if (!_listView.fetchListManager.isLoading) {
                [_listView fetchFromLocal:fromLocal fromRemote:fromRemote getMore:NO];
            }
        }
    }
    
    if (![previousCategoryID isEqualToString:self.currentCategory.categoryID]) {
        [_listView scrollToTopAnimated:NO];
    }
    
    //记录频道停留时常
//    if (self.isCurrentDisplayView) {
//        
//        /**
//         *  视频tab中推荐频道的驻留时长埋点，由 tag:stay_category label:video 改为 tag:stay_category label:subv_recommend
//         */
//        NSString *categoryID = self.currentCategory.categoryID;
//        if (self.listView.isInVideoTab && [categoryID isEqualToString:kVideoCategoryID]) {
//            categoryID = @"subv_recommend";
//        }
//        
//        [[TTCategoryStayTrackManager shareManager] startTrackForCategoryID:categoryID concernID:self.currentCategory.concernID enterType:self.enterType];
//    }
    
    if ([category.categoryID isEqualToString:kTTMainCategoryID] && display && !_umengFlagFirstEnterNewsCategory) {
        _umengFlagFirstEnterNewsCategory = YES;
        [_listView trackEventForLabel:@"enter_launch"];
    }
    if (display) {
        [_listView trackEventForLabel:@"enter"];
    }
}

- (void)refreshDisplayView:(BOOL)display {
    [super refreshDisplayView:display];
    _listView.isDisplayView = display;
    
//    if (display) {
//        if ([[_listView.fetchListManager items] count] == 0) {
//            [_listView setListHeader:nil];
//            [_listView.listView triggerPullDownAndHideAnimationView];
//        }
//    }
}

- (void)willAppear
{
    [super willAppear];
    
    NSString * parsedEntype;
    NSString * direction;
    NSString * enterType = self.enterType;
    if (enterType) {
        if ([enterType isEqualToString:@"click"]) {
            parsedEntype = enterType;
        }
        if ([enterType rangeOfString:@"flip"].location!=NSNotFound) {
            NSArray * components = [enterType componentsSeparatedByString:@"_"];
            if (components && components.count==2) {
                parsedEntype =@"click";
                direction = components[1];
            }
        }
    }

    [_listView willAppear];
}

- (void)willDisappear
{
    [super willDisappear];
    [_listView willDisappear];
}

- (void)didAppear
{
    [super didAppear];
    [_listView didAppear];
}

- (void)didDisappear
{
    [super didDisappear];
    [_listView didDisappear];
}

- (void)pullAndRefresh
{
    if ([_listView respondsToSelector:@selector(refreshShouldLastReadUpate)]) {
        _listView.refreshShouldLastReadUpate = YES;
    }
    [_listView pullAndRefresh];
}

- (void)scrollToBottomAndLoadmore
{
    [_listView scrollToBottomAndLoadmore];
}

- (void)refresh
{
    
}

- (void)scrollToTopEnable:(BOOL)enable
{
    [_listView scrollToTopEnable:enable];
}

- (void)cacheCleared:(NSNotification*)notification
{
    
}

- (void)cancelAllOperation
{
    [_listView cancelAllOperation];
}

- (void)listViewWillEnterForground
{
    [_listView listViewWillEnterForground];
}

- (void)listViewWillEnterBackground
{
    [_listView listViewWillEnterBackground];
}

- (BOOL)needClearRecommendTabBadge{
    return self.listView.listType == ExploreOrderedDataListTypeCategory;
}

@end

//
//  TTHTSWaterfallCollectionView.m
//  Article
//
//  Created by 王双华 on 2017/4/12.
//
//

#import "TTHTSWaterfallCollectionView.h"
#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "TTHTSWaterfallCollectionViewCell.h"
#import "SSImpressionManager.h"
#import "NetworkUtilities.h"
#import "SSTipModel.h"
#import "TSVShortVideoOriginalData.h"
#import "ArticleListNotifyBarView.h"
#import "ArticleImpressionHelper.h"
#import "TTRoute.h"
#import "ExploreMixListDefine.h"
#import "ExploreItemActionManager.h"
#import "TTRoute.h"
#import <HTSVideoPlay/HTSVideoPageParamHeader.h>
#import <TTUIWidget/TTNavigationController.h>
#import <TTBaseLib/TTURLUtils.h>
#import <ReactiveObjC.h>

#import "TTFeedDislikeView.h"
#import "TSVTransitionAnimationManager.h"
#import "TSVShortVideoFeedFetchManager.h"
#import "TSVShortVideoListFetchManager.h"
#import "TSVShortVideoDetailExitManager.h"
#import "NSObject+FBKVOController.h"
#import "TTAccountManager.h"
#import "ExploreListHelper.h"
#import "AWEVideoConstants.h"
#import <TTSettingsManager.h>
#import "IESVideoPlayer.h"
#import "AWEVideoConstants.h"
#import <TSVPrefetchVideoManager.h>
#import "TTHTSVideoConfiguration.h"
#import "TTHTSVideoConfiguration.h"
#import "TTMonitor.h"
#import "TSVRecUserCardCollectionViewCell.h"
#import "TSVRecUserCardCollectionViewCellViewModel.h"
#import "TSVRecUserCardOriginalData.h"
#import "TSVTabTipManager.h"
#import "TTRelevantDurationTracker.h"
#import "TSVListAutoRefreshRecorder.h"
//#import "TSVPublishManager.h"
#import "TSVFeedPublishCollectionViewCell.h"
#import "TTArticleTabBarController.h"
#import "TSVFeedPublishCollectionViewCellViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTUGCPostCenterProtocol.h"
#import "TSVPublishStatusOriginalData.h"
#import "TSVShortVideoPostTaskProtocol.h"
#import "ExploreMixListDefine.h"
//#import "TSVStoryOriginalData.h"
//#import "TSVStoryCollectionViewCell.h"
//#import "TSVStoryViewModel.h"
#import "TSVChannelDecoupledConfig.h"
#import "TSVShortVideoDecoupledFetchManager.h"

#import "TSVActivityEntranceOriginalData.h"
#import "TSVActivityEntranceCollectionViewCell.h"
#import "TSVActivityEntranceCollectionViewCellViewModel.h"

#import "TSVActivityBannerOriginalData.h"
#import "TSVActivityBannerCollectionViewCell.h"
#import "TSVActivityBannerCollectionViewCellViewModel.h"
#import "AWEVideoDetailTracker.h"
#import "TSVCategory.h"
//#import "TSVStoryContainerView.h"
#import "TSVMonitorManager.h"
#import "Bubble-Swift.h"

#define kDefaultDismissDuration 2.0f
#define kColumnSpacing 1
#define kInteritemSpacing 1

@interface TTHTSWaterfallCollectionView ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
SSImpressionProtocol,
UIViewControllerErrorHandler,
TTAccountMulticastProtocol
>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSString *categoryID;  // 频道ID
@property (nonatomic, strong) NSString *concernID;   // 关心ID
@property (nonatomic) BOOL isShowing;
@property (nonatomic) BOOL isDisplayView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) NSInteger autoScrollCount;
@property (nonatomic, assign) BOOL autoScrollTimerStarted;
@property (nonatomic, assign) CGFloat collectionBottomInset;

//本次stream刷新方式
@property (nonatomic, assign) ListDataOperationReloadFromType refreshFromType;

@property (nonatomic, strong) NSTimer *preloadTimer;
@property (nonatomic, strong) RACDisposable *prefetchVideoDisposable;

@property (nonatomic, retain) ExploreItemActionManager *itemActionManager;

@property (nonatomic, copy) NSString *listEntrance;

//@property (nonatomic, strong) TSVPublishManager *publishManager;

@property (nonatomic, strong) id<TSVShortVideoDataFetchManagerProtocol> drawFetchManager; // draw data source
@property (nonatomic, strong) TSVShortVideoFeedFetchManager *feedFetchManager;  // feed data source

@property (nonatomic, strong) NSMutableDictionary *traceIdDict;  // feed data source

@end

@implementation TTHTSWaterfallCollectionView

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    [self removeDelegates];
    [TTAccount removeMulticastDelegate:self];
    [_prefetchVideoDisposable dispose];
}

- (instancetype)initWithFrame:(CGRect)frame topInset:(CGFloat)topinset bottomInset:(CGFloat)bottomInset {
    self = [super initWithFrame:frame];
    if (self) {
//        self.publishManager = [TSVPublishManager sharedManager];
        
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];

        [self addSubview:self.collectionView];

        self.ttErrorToastView = [ArticleListNotifyBarView addErrorToastViewWithTop:self.ttContentInset.top width:self.width height:[SSCommonLogic articleNotifyBarHeight]];

        //[self.collectionView setContentInset:UIEdgeInsetsMake(topinset, 0, bottomInset, 0)];

        TSVShortVideoFeedFetchManager *feedFetchManager = [[TSVShortVideoFeedFetchManager alloc] init];
        self.feedFetchManager = feedFetchManager;
        
        NSMutableSet *set = [[NSMutableSet alloc] init];
        [set addObject:[TSVRecUserCardOriginalData class]];
        [set addObject:[TSVActivityBannerOriginalData class]];
//        [set addObject:[TSVStoryOriginalData class]];
        [self.feedFetchManager registerSpecialOriginalDataClass:[set copy]];

        [self addPullDownRefreshView];
        
        self.traceIdDict = [NSMutableDictionary dictionary];

        [[SSImpressionManager shareInstance] addRegist:self];

        [self reloadThemeUI];

        [self setContentTopInset:topinset bottomInset:bottomInset];
        
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"TSVShortVideoDeleteCellNotification" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable notification) {
            @strongify(self);
            [self deleteOrderedDataIfNeed];
        }];
        
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"SettingViewClearCachdNotification" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable notification) {
            @strongify(self);
            [self clearCacheNotification:notification];
        }];
        
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kExploreMixListItemDeleteNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable notification) {
            @strongify(self);
            [self receiveItemDeleteNotification:notification];
        }];
        
//        [self.KVOController observe:self.publishManager keyPath:@"shortVideoTabPublishOrderedDataArray" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial block:^(id observer, id object, NSDictionary *change) {
//            @strongify(self);
//            if (![self isMainTabRecCategory]) {
//                return;
//            }
//
//            NSArray* kvoNew = change[NSKeyValueChangeNewKey];
//            NSArray* kvoOld = change[NSKeyValueChangeOldKey];
//            if ((kvoNew == nil || [kvoNew isKindOfClass:[NSArray class]])
//                || (kvoOld == nil || [kvoOld isKindOfClass:[NSArray class]])) {
//                if (kvoOld.count == 0 && kvoNew.count == 0) {
//                    return;
//                }
//            }
//            NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
//            switch (changeKind) {
//                case NSKeyValueChangeSetting:
//                {
//                    //do nothing
//                }
//                    break;
//                case NSKeyValueChangeInsertion:
//                {
//                    ///处理开始上传时，插入cell
//                    ExploreOrderedData *newOrderedData = [kvoNew firstObject];
//                    if ([newOrderedData.tsvPublishStatusOriginalData.concernID isEqualToString:kTTShortVideoConcernID]) {
//                        newOrderedData.itemIndex = [[NSDate date] timeIntervalSince1970] * kFeedItemIndexUnixTimeMultiplyPara;
//                        [self adjustItemOrderWithInsertOrderedData:newOrderedData];
//                    }
//                }
//                    break;
//                case NSKeyValueChangeRemoval:
//                {
//                    ///处理上传失败后，点删除按钮后移除上传状态cell，不处理小视频model
//                    ExploreOrderedData *oldOrderedData = [kvoOld firstObject];
//                    if (oldOrderedData.tsvPublishStatusOriginalData) {
//                        [self adjustItemOrderWithDeleteItems:@[oldOrderedData]];
//                    }
//                }
//                    break;
//                case NSKeyValueChangeReplacement:
//                {
//                    ///处理上传成功后，用发布的小视频cell替换上传状态cell
//                    ExploreOrderedData *oldOrderedData = [kvoOld firstObject];
//                    ExploreOrderedData *newOrderedData = [kvoNew firstObject];
//                    NSInteger reloadIndex = [self.feedFetchManager.items indexOfObject:oldOrderedData];
//                    if (newOrderedData.shortVideoOriginalData && reloadIndex < self.feedFetchManager.items.count) {
//                        [self.feedFetchManager replaceObjectAtIndex:reloadIndex withObject:newOrderedData];
//
//                        if (reloadIndex != NSNotFound) {
//                            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:reloadIndex inSection:0]]];
//                        }
//                        [self.publishManager deleteDisplayedDatas:@[newOrderedData]];
//
//                    }
//                }
//                    break;
//                default:
//                    break;
//            }
//        }];

        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = kColumnSpacing;
        layout.minimumInteritemSpacing = kInteritemSpacing;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        _collectionView.alwaysBounceVertical = YES;

        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        
        [_collectionView registerClass:[TTHTSWaterfallCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TTHTSWaterfallCollectionViewCell class])];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        [_collectionView registerClass:[TSVRecUserCardCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TSVRecUserCardCollectionViewCell class])];
        [_collectionView registerClass:[TSVActivityEntranceCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TSVActivityEntranceCollectionViewCell class])];
        [_collectionView registerClass:[TSVActivityBannerCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TSVActivityBannerCollectionViewCell class])];
        [_collectionView registerClass:[TSVFeedPublishCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TSVFeedPublishCollectionViewCell class])];
//        [_collectionView registerClass:[TSVStoryCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TSVStoryCollectionViewCell class])];
    }
    return _collectionView;
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
    self.isShowing = YES;
    if (self.isDisplayView) {
        [self deleteOrderedDataIfNeed];
        [self beginListImpression];
        [self trackCellsInVisibleCells];
    }
    for (NSIndexPath* indexPath in self.collectionView.indexPathsForVisibleItems) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        if ([cell respondsToSelector:@selector(willDisplay)]) {
            [cell performSelector:@selector(willDisplay)];
        }
    }
}

- (void)didAppear
{
    [super didAppear];

    [[TTRelevantDurationTracker sharedTracker] sendRelevantDuration];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];

    if (!self.window) {
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @weakify(self);
        [[[RACObserve(self, feedFetchManager.isLoadingRequest) filter:^BOOL(id  _Nullable value) {
            return ![value boolValue];
        }]
          take:1]
         subscribeNext:^(id  _Nullable x) {
             @strongify(self);
             if (!self.autoScrollTimerStarted) {
                 [self beginAutoScrollTimer];
             }
         }];
    });
}

- (void)willDisappear {
    [super willDisappear];

    [TTFeedDislikeView dismissIfVisible];

    if (self.isDisplayView) {
        [self endListImpression];
    }
    self.isShowing = NO;

    for (NSIndexPath* indexPath in self.collectionView.indexPathsForVisibleItems) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        if ([cell respondsToSelector:@selector(didEndDisplaying)]) {
            [cell performSelector:@selector(didEndDisplaying)];
        }
    }
}

- (void)removeDelegates {
    [[SSImpressionManager shareInstance] removeRegist:self];
    [_preloadTimer invalidate];
    _preloadTimer = nil;
    [self.feedFetchManager resetManager];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];

    self.collectionView.backgroundColor = self.backgroundColor;
}

- (void)pullAndRefresh {
    [_collectionView triggerPullDown];
}

- (void)scrollToTopEnable:(BOOL)enable {
    _collectionView.scrollsToTop = enable;
}

- (void)listViewWillEnterForground
{
    if (self.isDisplayView && _isShowing){
        [self tryAutoReloadIfNeed];
        [self trackCellsInVisibleCells];
    }
}

- (void)tryAutoReloadIfNeed
{
    if ([TSVListAutoRefreshRecorder shouldAutoRefreshForCategory:self.currentCategory]) {
        self.refreshFromType = ListDataOperationReloadFromTypeAutoFromBackground;
        [self pullAndRefresh];
    }
}

#pragma mark --  notification
- (void)clearCacheNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self clearListContent];
        if (_isDisplayView) {
            self.refreshFromType = ListDataOperationReloadFromTypeAuto;
            [self pullAndRefresh];
        }
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.feedFetchManager.items.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.feedFetchManager.items.count) {
        ExploreOrderedData *orderedData = self.feedFetchManager.items[indexPath.row];
        if ([orderedData isKindOfClass:[ExploreOrderedData class]]) {
            if (orderedData.shortVideoOriginalData) {
                TTHTSWaterfallCollectionViewCell *cell = (TTHTSWaterfallCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TTHTSWaterfallCollectionViewCell class]) forIndexPath:indexPath];
                @weakify(self);
                cell.dislikeBlock = ^{
                    @strongify(self);
                    [self notInterestAction:orderedData];
                };
                if (cell.cellData) {
                    [self endCellImpression:cell.cellData];
                }
                cell.listEntrance = _listEntrance;
                [cell refreshWithData:orderedData];
                [self beginCellImpression:cell.cellData];
                [self eventV3ShortVideoShowWithOrderData:cell.cellData];

                return cell;
            } else if (orderedData.tsvRecUserCardOriginalData) {
                orderedData.tsvRecUserCardOriginalData.cardModel.listEntrance = self.listEntrance;
                orderedData.tsvRecUserCardOriginalData.cardModel.enterFrom = @"click_category";
                orderedData.tsvRecUserCardOriginalData.cardModel.categoryName = self.categoryID;
                NSAssert(self.categoryID, @"self.categoryID should not be nil");
                TSVRecUserCardCollectionViewCell *cell = (TSVRecUserCardCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TSVRecUserCardCollectionViewCell class]) forIndexPath:indexPath];
                @weakify(self);
                cell.dislikeBlock = ^{
                    @strongify(self)
                    [self notInterestAction:orderedData];
                };
                if (cell.cellData) {
                    [self endCellImpression:cell.cellData];
                }
                [cell refreshWithData:orderedData];
                [self beginCellImpression:orderedData];
                return cell;
            } else if (orderedData.tsvActivityEntranceOriginalData) {
                TSVActivityEntranceCollectionViewCellViewModel *viewModel = [[TSVActivityEntranceCollectionViewCellViewModel alloc] initWithModel:orderedData.tsvActivityEntranceOriginalData.model];
                TSVActivityEntranceCollectionViewCell *cell = (TSVActivityEntranceCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TSVActivityEntranceCollectionViewCell class]) forIndexPath:indexPath];
                if (cell.cellData) {
                    [self endCellImpression:cell.cellData];
                }
                cell.viewModel = viewModel;
                cell.cellData = orderedData;
                [self beginCellImpression:orderedData];
                return cell;
            } else if (orderedData.tsvActivityBannerOriginalData) {
                TSVActivityBannerCollectionViewCellViewModel *viewModel = [[TSVActivityBannerCollectionViewCellViewModel alloc] initWithModel:orderedData.tsvActivityBannerOriginalData.model];
                TSVActivityBannerCollectionViewCell *cell = (TSVActivityBannerCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TSVActivityBannerCollectionViewCell class]) forIndexPath:indexPath];
                if (cell.cellData) {
                    [self endCellImpression:cell.cellData];
                }
                cell.viewModel = viewModel;
                cell.cellData = orderedData;
                [self beginCellImpression:orderedData];
                return cell;
            } else if (orderedData.tsvPublishStatusOriginalData) {
                TSVFeedPublishCollectionViewCellViewModel *viewModel = [[TSVFeedPublishCollectionViewCellViewModel alloc] initWithModel:orderedData.tsvPublishStatusOriginalData];
                TSVFeedPublishCollectionViewCell *cell = (TSVFeedPublishCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TSVFeedPublishCollectionViewCell class]) forIndexPath:indexPath];
                cell.viewModel = viewModel;
                return cell;
            }
//            else if (orderedData.tsvStoryOriginalData) {
//                TSVStoryCollectionViewCell *cell = (TSVStoryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TSVStoryCollectionViewCell class]) forIndexPath:indexPath];
//
//                if (cell.cellData) {
//                    [self endCellImpression:cell.cellData];
//                }
//
//                TSVStoryViewModel *viewModel = [[TSVStoryViewModel alloc] initWithModel:orderedData.tsvStoryOriginalData.storyModel listEntrance:@"main_tab"];
//                viewModel.orderedData = orderedData;
//                viewModel.categoryName = self.categoryID;
//                [cell refreshWithViewModel:viewModel];
//
//                [self beginCellImpression:orderedData];
//                return cell;
//            }
        }
    }

    NSAssert(NO, @"UICollectionCell must not be nil");
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(willDisplay)]) {
        [cell performSelector:@selector(willDisplay)];
    }
    
//    if ([cell isKindOfClass:[TSVStoryCollectionViewCell class]]) {
//        [(TSVStoryCollectionViewCell *)cell trackShowEvent];
//    }
}

- (void)beginAutoScrollTimer
{
    if (![self isMainTabRecCategory]) {
        return;
    }
    self.autoScrollTimerStarted = YES;

    NSDictionary *configDict = [[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_list_auto_scroll"
                                                                   defaultValue:@{
                                                                                  @"wait_duration": @3,
                                                                                  @"max_count": @0,
                                                                                  } freeze:YES];

    if (self.autoScrollCount >= [configDict[@"max_count"] integerValue]) {
        return;
    }
    self.autoScrollCount++;

    // 加了好多触发条件，有些是多余的，UIKit 好多东西无法理解，多写了一些
    RACSignal *operationSignal = [RACSignal merge:@[
                                                     [self.collectionView rac_signalForSelector:@selector(hitTest:withEvent:)],
                                                     [self rac_signalForSelector:@selector(collectionView:didSelectItemAtIndexPath:)],
//                                                     [self.collectionView rac_signalForSelector:@selector(touchesBegan:withEvent:)],
                                                     [[NSNotificationCenter defaultCenter] rac_addObserverForName:TTArticleTabBarControllerChangeSelectedIndexNotification object:nil],
                                                     [[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillResignActiveNotification object:nil],
//                                                     [[[UIApplication sharedApplication] keyWindow] rac_signalForSelector:@selector(touchesBegan:withEvent:)],
                                                     [[[UIApplication sharedApplication] keyWindow] rac_signalForSelector:@selector(hitTest:withEvent:)],
                                                     ]];
    @weakify(self);
    [[[[RACSignal return:nil]
       delay:[configDict[@"wait_duration"] floatValue]]
      takeUntil:operationSignal]
     subscribeNext:^(id  _Nullable x) {
         @strongify(self);
         NSIndexPath *maxIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
         for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
             NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
             if ([indexPath compare:maxIndexPath] == NSOrderedDescending) {
                 maxIndexPath = indexPath;
             }
         }
         UICollectionViewCell *lastVisibleCell = [self.collectionView cellForItemAtIndexPath:maxIndexPath];
         CGRect cellRect = [lastVisibleCell convertRect:lastVisibleCell.bounds toView:self.collectionView];
         // self.collectionView.contentInset 的值是错的，跟 TTRefresh 有关
         CGRect visibleRect = UIEdgeInsetsInsetRect(self.collectionView.bounds, UIEdgeInsetsMake(0, 0, self.collectionBottomInset, 0));
         CGRect overlapRect = CGRectIntersection(cellRect, visibleRect);
         BOOL skipLastCell = (overlapRect.size.width * overlapRect.size.height) / (cellRect.size.width * cellRect.size.height) > 0.7;
         NSIndexPath *scrollDestinationIndexPath;
         if (skipLastCell &&
             (maxIndexPath.item + 1 < [self.collectionView numberOfItemsInSection:maxIndexPath.section])) {
             scrollDestinationIndexPath = [NSIndexPath indexPathForItem:maxIndexPath.item + 1
                                                              inSection:maxIndexPath.section];

         } else {
             scrollDestinationIndexPath = maxIndexPath;
         }
         [self.collectionView scrollToItemAtIndexPath:scrollDestinationIndexPath
                                     atScrollPosition:UICollectionViewScrollPositionTop
                                             animated:YES];

         NSMutableDictionary *params = [NSMutableDictionary dictionary];
         [params setValue:self.categoryID forKey:@"category_name"];
         [params setValue:@"click_category" forKey:@"enter_from"];
         [params setValue:self.listEntrance forKey:@"list_entrance"];
         [TTTrackerWrapper eventV3:@"auto_load_more" params:params];

         [self tryPreload];

         [self beginAutoScrollTimer];
     }];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(didEndDisplaying)]) {
        [cell performSelector:@selector(didEndDisplaying)];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

    if (indexPath.row > self.feedFetchManager.items.count) {
        return;
    }

    ExploreOrderedData *orderedData = self.feedFetchManager.items[indexPath.row];
    if (![orderedData isKindOfClass:[ExploreOrderedData class]]) {
        return;
    }

    self.selectedIndexPath = indexPath;

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.categoryID forKey:@"category_name"];
    [params setValue:@"click_category" forKey:@"enter_from"];
    [params setValue:self.listEntrance forKey:@"list_entrance"];

    if (orderedData.shortVideoOriginalData) {
        [[TTRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
        [self enterDetailByOrderedData:orderedData offset:indexPath.row];
    } else if (orderedData.tsvActivityEntranceOriginalData) {
        [params setValue:orderedData.tsvActivityEntranceOriginalData.model.forumID forKey:@"forum_id"];
        [params setValue:@"shortvideo_list_cell" forKey:@"from_page"];
        NSURL *url = [TTStringHelper URLWithURLString:orderedData.tsvActivityEntranceOriginalData.model.openURL];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict([params copy])];
    } else if (orderedData.tsvActivityBannerOriginalData) {
        [params setValue:orderedData.tsvActivityBannerOriginalData.model.forumID forKey:@"forum_id"];
        [params setValue:@"shortvideo_list_top_banner" forKey:@"from_page"];
        NSURL *url = [TTStringHelper URLWithURLString:orderedData.tsvActivityBannerOriginalData.model.openURL];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict([params copy])];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.feedFetchManager.items.count) {
        ExploreOrderedData *orderedData = self.feedFetchManager.items[indexPath.row];
        if ([orderedData isKindOfClass:[ExploreOrderedData class]]) {
            CGFloat imageHeight = 0.f;
            if (orderedData.shortVideoOriginalData ||
                orderedData.tsvActivityEntranceOriginalData ||
                orderedData.tsvPublishStatusOriginalData) {
                return [self itemSizeForShortVideo];
            } else if (orderedData.tsvRecUserCardOriginalData) {
                return CGSizeMake(collectionView.width, 225);
            } else if (orderedData.tsvActivityBannerOriginalData) {
                CGFloat imageOriginalWidth = orderedData.tsvActivityBannerOriginalData.model.coverImageModel.width;
                CGFloat imageOriginalHeight = orderedData.tsvActivityBannerOriginalData.model.coverImageModel.height;
                if (imageOriginalWidth > 0) {
                    imageHeight = collectionView.width * imageOriginalHeight / imageOriginalWidth;
                } else {
                    NSAssert(NO, @"imageOriginalWidth 必须大于0");
                }
                return CGSizeMake(collectionView.width, round(imageHeight));
            }
//            else if (orderedData.tsvStoryOriginalData) {
//                return CGSizeMake(collectionView.width, [TSVStoryContainerView heightForModel:orderedData.tsvStoryOriginalData.storyModel]);
//            }
        }
    }
    NSAssert(NO, @"not support this kind of data");
    return CGSizeMake((collectionView.width - kColumnSpacing) / 2, 100);
}

- (CGSize)itemSizeForShortVideo
{
    CGFloat imageWidth = (self.collectionView.width - kColumnSpacing) / 2;
    
    return CGSizeMake(imageWidth, round(imageWidth * 1.61));
}

#pragma mark -

//  不要调用该方法，需要传入listEntrance ！
- (void)refreshListViewForCategory:(TTCategory *)category isDisplayView:(BOOL)display fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadFromType:(ListDataOperationReloadFromType)fromType
{
    NSAssert(NO, @"this method is deprecated in tsv-related classes, listEntrance should be specified");
    //  保护一下
    NSString *listEntrance = nil;
    if ([category isKindOfClass:[TSVCategory class]]) {
        listEntrance = @"main_tab";
    }
    
    [self refreshListViewForCategory:category isDisplayView:display fromLocal:fromLocal fromRemote:fromRemote reloadFromType:fromType listEntrance:listEntrance];
}

- (void)refreshListViewForCategory:(TTCategory *)category isDisplayView:(BOOL)display fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadFromType:(ListDataOperationReloadFromType)fromType listEntrance:(NSString *)listEntrance
{
    NSString *previousCategoryID = self.currentCategory.categoryID;
    
    [super refreshListViewForCategory:category isDisplayView:display fromLocal:fromLocal fromRemote:fromRemote reloadFromType:fromType];

    self.refreshFromType = fromType;

    BOOL categoryNotChange = !isEmptyString(previousCategoryID) && !isEmptyString(self.currentCategory.categoryID) && [previousCategoryID isEqualToString:self.currentCategory.categoryID];

    self.categoryID = self.currentCategory.categoryID;
    self.concernID = self.currentCategory.concernID;
    self.isDisplayView = display;

    self.listEntrance = listEntrance;
    self.feedFetchManager.categoryID = self.currentCategory.categoryID;
    /*
     如果是：
     1、不需要从本地取数据
     2、需要从远端取数据
     3、频道发生改变
     4、当前无数据
     满足一个条件时
     */
    if (!fromLocal || fromRemote || !categoryNotChange || self.feedFetchManager.items.count <= 0) {
        if (fromRemote) {
            [self.feedFetchManager cancelAllOperations];
            [_collectionView triggerPullDown];
        } else {
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
    self.collectionBottomInset = bottomInset;
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
                                           wself.refreshFromType = ListDataOperationReloadFromTypePull;
                                       }

                                       [wself fetchFromLocal:![wself tt_hasValidateData] fromRemote:YES getMore:NO];
                                   }];

    CGFloat barH = [SSCommonLogic articleNotifyBarHeight];
    self.ttMessagebarHeight = barH;
    //_listView.ttMessagebarHeight = barH;
    if ([SSCommonLogic isNewPullRefreshEnabled]) {
        self.collectionView.pullDownView.pullRefreshLoadingHeight = barH;
        self.collectionView.pullDownView.messagebarHeight = barH;
    }

    [self.collectionView tt_addDefaultPullUpLoadMoreWithHandler:^{
        __strong typeof(self) sself = wself;
        sself.refreshFromType = ListDataOperationReloadFromTypeLoadMore;
        [sself loadMore];
    }];

    if ([self.collectionView.pullDownView respondsToSelector:@selector(titleLabel)]) {
        UILabel *titleLabel = [self.collectionView.pullDownView performSelector:@selector(titleLabel)];
        titleLabel.contentMode = UIViewContentModeCenter;
    }
}

- (void)fetchFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote getMore:(BOOL)getMore
{
    [self fetchFromLocal:fromLocal fromRemote:fromRemote getMore:getMore finishBlock:nil];
}

- (void)fetchFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote getMore:(BOOL)getMore finishBlock:(TTFetchListFinishBlock)finishBlock
{
    if (fromRemote) {
        if (getMore && self.refreshFromType == ListDataOperationReloadFromTypeLoadMore) {
            [self eventFHForLoadMore];
        }else {
            [self eventV3ForRefresh];
        }
    }

    self.ttLoadingView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    self.ttTargetView = self.collectionView;
    [self tt_startUpdate];

    self.collectionView.ttIntegratedMessageBar = self.ttErrorToastView;
    self.ttAssociatedScrollView = self.collectionView;

    [self.feedFetchManager reuserAllOperations];

    NSMutableDictionary *condition = [NSMutableDictionary dictionary];

    [condition setValue:self.listEntrance forKey:kExploreFetchListConditionListShortVideoListEntranceKey];
    [condition setValue:self.currentCategory.categoryID forKey:kExploreFetchListConditionListUnitIDKey];
    [condition setValue:@(_refreshFromType) forKey:kExploreFetchListConditionReloadFromTypeKey];

    //远端请求数据，更新一次tip请求时间
    if (fromRemote) {
        [TSVListAutoRefreshRecorder saveLastTimeRefreshForCategory:self.currentCategory];

        if ([[TSVTabTipManager sharedManager] shouldAutoReloadFromRemoteForCategory:self.currentCategory.categoryID listEntrance:self.listEntrance]) {
            [condition setValue:[[TSVTabTipManager sharedManager] extraCategoryListRequestParameters] forKey:kExploreFetchListExtraGetParametersKey];
        }

        if ([self.listEntrance isEqualToString:@"main_tab"]) {
            [[TSVTabTipManager sharedManager] clearRedDot];
        }
    }

    self.ttViewType = TTFullScreenErrorViewTypeEmpty;

    NSTimeInterval refreshStartTime = [[NSDate date] timeIntervalSince1970];
    NSString *refreshTypeStr = [[ExploreListHelper class] refreshTypeStrForReloadFromType:self.refreshFromType];

    self.refreshFromType = ListDataOperationReloadFromTypeNone;


    [TTFeedDislikeView dismissIfVisible];

    [TTFeedDislikeView disable];

    NSMutableDictionary * exploreMixedListConsumeTimeStamps = [NSMutableDictionary dictionary];
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListTriggerRequestTimeStampKey];
    [condition setValue:exploreMixedListConsumeTimeStamps forKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];

    WeakSelf;

    [self.feedFetchManager startExecuteWithCondition:condition
                                       fromLocal:fromLocal
                                      fromRemote:fromRemote
                                         getMore:getMore
                                    isDisplyView:self.isCurrentDisplayView
                                        listType:ExploreOrderedDataListTypeCategory
                                    listLocation:ExploreOrderedDataListLocationCategory
                                     finishBlock:^(NSArray *increaseItems, NSDictionary *operationContext, NSError *error) {
                                         StrongSelf;
                                         
                                         [self monitorCategoryListNetworkStatusWithOperationContext:operationContext error:error];
                                         
                                         [TTFeedDislikeView enable];

                                         NSString *cid = [(NSDictionary *)[operationContext objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListConditionListUnitIDKey];

                                         NSString *concernID = [(NSDictionary *)[operationContext objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListConditionListConcernIDKey];

                                         NSArray * allItems = [operationContext objectForKey:kExploreFetchListItemsKey];

                                         BOOL isFromRemote = [[operationContext objectForKey:kExploreFetchListFromRemoteKey] boolValue];

                                         BOOL isResponseFromRemote = [[operationContext objectForKey:kExploreFetchListIsResponseFromRemoteKey] boolValue];

                                         BOOL isFinish = [[operationContext objectForKey:kExploreFetchListResponseFinishedkey] boolValue];

                                         BOOL hasMore = [[operationContext objectForKey:kExploreFetchListResponseHasMoreKey] boolValue] && allItems.count > 0;

                                         BOOL isLoadMore = [[operationContext objectForKey:kExploreFetchListGetMoreKey] boolValue];

                                         NSString *key = !isEmptyString(cid) ? cid : concernID;

                                         if (![key isEqualToString:self.currentCategory.categoryID]) {
                                             [self tt_endUpdataData:YES error:nil tip:nil tipTouchBlock:nil];

                                             if (getMore) {
                                                 [self.collectionView finishPullUpWithSuccess:NO];
                                             } else {
                                                 [self.collectionView finishPullDownWithSuccess:NO];
                                             }
                                         } else if (error && [error.domain isEqualToString:kExploreFetchListErrorDomainKey] &&
                                             error.code == kExploreFetchListCategoryIDChangedCode) {
                                             //频道变化

                                             [self tt_endUpdataData:YES error:nil tip:nil tipTouchBlock:nil];
                                             [self.collectionView finishPullDownWithSuccess:NO];

                                             [self reloadListView];

                                         } else if (error.code == NSURLErrorCancelled) {
                                             //请求被cancel，不做任何操作
                                         } else if (!error) {

                                             self.collectionView.hasMore = hasMore;
                                             ///将发布中或已发布的小视频插入到列表
                                             [self.feedFetchManager updateListModels];
                                             [self.feedFetchManager adjustTSVItemsOrder];
//                                             [self insertPublishManagerOrderedDataArray];
                                             
                                             if (getMore) {
                                                 [self insertCellAtTheTail];
                                             } else {
                                                 [self reloadListView];
                                             }

                                             NSString * tip;
                                             NSInteger duration = 0;
                                             SSTipModel * tipModel;

                                             if (isFinish && isFromRemote && !isLoadMore) {
                                                 NSMutableDictionary *params = [NSMutableDictionary dictionary];
                                                 [params setValue:_categoryID forKey:@"category_name"];
                                                 [params setValue:refreshTypeStr forKey:@"refresh_type"];
                                                 NSTimeInterval refreshEndTime = [[NSDate date] timeIntervalSince1970];
                                                 CGFloat refreshDuration = ceilf((refreshEndTime - refreshStartTime) * 1000);
                                                 [params setValue:@(refreshDuration) forKey:@"duration"];
                                                 [TTTrackerWrapper eventV3:@"channel_fetch" params:params];

                                                 NSDictionary *remoteTipResult = [(NSDictionary *)[(NSDictionary *)[operationContext objectForKey:kExploreFetchListResponseRemoteDataKey] objectForKey:@"result"] objectForKey:@"tips"];

                                                 tipModel = [[SSTipModel alloc] initWithDictionary:remoteTipResult];
                                                 NSString * msg = nil;
                                                 duration = [tipModel.displayDuration intValue];

                                                 NSInteger updateCount = [[operationContext valueForKey:@"new_number"] intValue];
                                                 updateCount = MAX(0, updateCount);
                                                 NSString * displayTemplate = tipModel.displayTemplate;
                                                 if (!isEmptyString(displayTemplate)) {
                                                     NSRange range = [displayTemplate rangeOfString:displayTemplate];
                                                     if (range.location != NSNotFound) {
                                                         msg = [displayTemplate stringByReplacingOccurrencesOfString:kSSTipModelDisplayTemplatePlaceholder withString:[NSString stringWithFormat:@"%ld", (long)updateCount]];
                                                     }
                                                 } else if (!isEmptyString(tipModel.displayInfo)) {
                                                     msg = tipModel.displayInfo;
                                                 }
                                                 if (isEmptyString(msg)) {
                                                     if ([increaseItems count] > 0) {
                                                         msg = [NSString stringWithFormat:@"发现%ld条更新", (long)updateCount];
                                                     } else {
                                                         msg = NSLocalizedString(@"暂无更新，休息一会儿", nil);
                                                     }
                                                 }

                                                 if (duration <= 0) {
                                                     duration = 2.f;
                                                 }
                                                 tip = msg;
                                             }

                                             if (isResponseFromRemote) {
                                                 if (![[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_refresh_tip" defaultValue:@1 freeze:NO] boolValue]) {
                                                     tip = nil;
                                                 }
                                                 [self tt_endUpdataData:NO error:nil tip:tip duration:duration tipTouchBlock:nil];

                                                 if (getMore) {
                                                     [self.collectionView finishPullUpWithSuccess:!error];
                                                 } else {
                                                     [self.collectionView finishPullDownWithSuccess:!error];
                                                 }
                                             } else if ([self tt_hasValidateData]) {
                                                 // loading时没有数据不显示动画icon，恢复动画icon显示，
                                                 [self.collectionView.pullDownView showAnimationView];

                                                 [self tt_endUpdataData];
                                                 //[self.collectionView finishPullDownWithSuccess:YES];
                                             }

                                             self.collectionView.pullUpView.hidden = ![self tt_hasValidateData];
                                             [self reportDelegateLoadFinish:isFinish isUserPull:self.collectionView.pullDownView.isUserPullAndRefresh isGetMore:getMore];
                                         } else {
                                             NSString * msg = nil;
                                             if (error.code == kServerUnAvailableErrorCode) {
                                                 if(self.feedFetchManager.items.count <= 0) {
                                                     msg = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
                                                 }
                                             } else {
                                                 msg = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
                                                 if(isEmptyString(msg)) {
                                                     msg = kNetworkConnectionTimeoutTipMessage;
                                                 }
                                             }
                                             if (!TTNetworkConnected()) {
                                                 msg = kNoNetworkTipMessage;
                                             }

                                             if (isResponseFromRemote) {
                                                 [self tt_endUpdataData:NO error:error tip:msg duration:kDefaultDismissDuration tipTouchBlock:nil];
                                                 if (getMore) {
                                                     [self.collectionView finishPullUpWithSuccess:NO];
                                                 } else {
                                                     [self.collectionView finishPullDownWithSuccess:NO];
                                                 }
                                             } else if ([self tt_hasValidateData]) {
                                                 [self tt_endUpdataData:YES error:error tip:msg duration:kDefaultDismissDuration tipTouchBlock:nil];
                                             }
                                             [self reportDelegateLoadFinish:isFinish isUserPull:self.collectionView.pullDownView.isUserPullAndRefresh isGetMore:getMore];
                                         }

                                         if (isResponseFromRemote) {
                                             [[TSVMonitorManager sharedManager] trackCategoryResponseWithCategoryID:self.currentCategory.categoryID listEntrance:self.listEntrance count:[increaseItems count] error:error];
                                         }
                                         
                                         if (finishBlock) {
                                             finishBlock([increaseItems count],error);
                                         }
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

#pragma mark - UIViewControllerErrorHandler

- (void)refreshData {
    [self.collectionView triggerPullDown];
}

- (void)emptyViewBtnAction {
    [self.collectionView triggerPullDown];
}

- (BOOL)tt_hasValidateData {
    if (self.feedFetchManager.items.count > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - loadmore

- (void)loadMore
{
    [self loadMoreWithFinishBlock:nil];
}

- (void)loadMoreWithFinishBlock:(TTFetchListFinishBlock)finishBlock
{
    if (!self.feedFetchManager.isLoadingRequest && self.feedFetchManager.items.count > 0) {
        [self fetchFromLocal:NO fromRemote:YES getMore:YES finishBlock:finishBlock];
    }
    else {
        [self.collectionView finishPullUpWithSuccess:NO];
        if (finishBlock) {
            finishBlock(0,nil);
        }
    }
}

- (void)reloadListView
{

    [TTFeedDislikeView dismissIfVisible];

    [self.collectionView reloadData];

    [self startPrefetchVideo];
}

- (void)insertCellAtTheTail
{
    [TTFeedDislikeView dismissIfVisible];
    WeakSelf;
    [self.collectionView performBatchUpdates:^{
        StrongSelf;
        NSInteger oldItemCount = [self.collectionView numberOfItemsInSection:0];
        NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
        for (NSInteger index = oldItemCount; index < self.feedFetchManager.items.count; index++) {
            [indexPathArray addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }
        [self.collectionView insertItemsAtIndexPaths:indexPathArray];
    } completion:nil];
}

#pragma mark - SSImpressionProtocol

- (void)needRerecordImpressions
{
    [self processVisibleCellsImpress];
}

- (void)processVisibleCellsImpress
{
    if (self.feedFetchManager.items.count <= 0) {
        return;
    }

    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = self.categoryID;
    params.concernID = self.concernID;
    params.refer = 1;

    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        if ([cell respondsToSelector:@selector(cellData)]) {
            id cellData = [cell performSelector:@selector(cellData)];
            if ([cellData isKindOfClass:[ExploreOrderedData class]]) {
                ExploreOrderedData * orderedData = (ExploreOrderedData *)cellData;

                if (self.isDisplayView && _isShowing) {
                    [ArticleImpressionHelper recordShortVideoForExploreOrderedData:orderedData status:SSImpressionStatusRecording params:params];
                }
                else {
                    [ArticleImpressionHelper recordShortVideoForExploreOrderedData:orderedData status:SSImpressionStatusSuspend params:params];
                }
            }
        }
    }
}

- (void)endCellImpression:(ExploreOrderedData *)cellData {
    if (_isShowing && [cellData isKindOfClass:[ExploreOrderedData class]]) {
        SSImpressionParams *params = [[SSImpressionParams alloc] init];
        params.categoryID = self.categoryID;
        params.concernID = self.concernID;
        params.refer = 1;
        [ArticleImpressionHelper recordShortVideoForExploreOrderedData:cellData status:SSImpressionStatusEnd params:params];
    }
}

- (void)beginCellImpression:(ExploreOrderedData *)cellData {
    if (_isShowing && [cellData isKindOfClass:[ExploreOrderedData class]]) {
        SSImpressionStatus impressionStatus = (self.isDisplayView && _isShowing) ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
        SSImpressionParams *params = [[SSImpressionParams alloc] init];
        params.categoryID = self.categoryID;
        params.concernID = self.concernID;
        params.refer = 1;
        [ArticleImpressionHelper recordShortVideoForExploreOrderedData:cellData status:impressionStatus params:params];
    }
}

- (void)endListImpression {
    [[SSImpressionManager shareInstance] leaveWithListKey:self.categoryID listType:SSImpressionGroupTypeHuoshanVideoList];
}

- (void)beginListImpression {
    [self processVisibleCellsImpress];
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
    [self.feedFetchManager resetManager];
    [self.feedFetchManager updateListModels];

    [self tt_endUpdataData];
    [self.collectionView finishPullDownWithSuccess:NO];
    [self reloadListView];
    [self resetScrollView];
}

- (void)resetScrollView
{
    TTRefreshView *refreshView = self.collectionView.pullDownView;
    UIScrollView *scrollView = self.collectionView;

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
    if (self.feedFetchManager.lastFetchRiseError) {
        return;
    }

    if (!self.feedFetchManager.isLoadingRequest && TTNetworkConnected() && self.feedFetchManager.hasMoreToLoad && self.feedFetchManager.items.count > 0) {
        CGFloat remainingContentHeight = self.collectionView.contentSize.height - (self.collectionView.contentOffset.y + self.collectionView.height);
        CGFloat itemHeight = [self itemSizeForShortVideo].height;
        
        if (remainingContentHeight <= 2 * itemHeight) {
            // 统计 - preload
            self.refreshFromType = ListDataOperationReloadFromTypePreLoadMore;
            [self loadMore];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    [TTFeedDislikeView dismissIfVisible];
    [self cancelPrefetchVideo];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self tryPreload];
        [self startPrefetchVideo];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self tryPreload];
    [self startPrefetchVideo];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [TTFeedDislikeView dismissIfVisible];
    [self cancelPrefetchVideo];
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self startPrefetchVideo];
}

- (void)receiveItemDeleteNotification:(NSNotification *)notification
{
    ExploreOrderedData *item = [[notification userInfo] objectForKey:kExploreMixListDeleteItemKey];
    item.shortVideoOriginalData.shortVideo.shouldDelete = YES;
}

#pragma mark - 不感兴趣
- (void)deleteOrderedDataIfNeed
{
    WeakSelf;
    [self.feedFetchManager deleteOrderedDataIfNeedWithComplete:^(NSArray * _Nullable shouldDeleteDataArray, BOOL hasNotInterestedData) {
        StrongSelf;
        if (shouldDeleteDataArray.count > 0) {
            /// dislike需要出蓝条提醒
            if (hasNotInterestedData) {
                NSString * title = nil;
                if ([TTAccountManager isLogin]) {
                    title = kNotInterestTipUserLogined;
                } else {
                    title = kNotInterestTipUserUnLogined;
                }
                [self tt_endUpdataData:NO error:nil tip:title duration:kDefaultDismissDuration tipTouchBlock:nil];
            } else {
                [self tt_endUpdataData];
            }
            [self adjustItemOrderWithDeleteItems:shouldDeleteDataArray];
            for (ExploreOrderedData *data in shouldDeleteDataArray) {
                /// 从数据库删除
                [ExploreItemActionManager removeOrderedData:data];
            }
        }
    }];
}

- (void)notInterestAction:(ExploreOrderedData *)orderedData {
    id item = orderedData;

    NSUInteger notInterestDataIndex = [self.feedFetchManager.items indexOfObject:orderedData];
    if (notInterestDataIndex == NSNotFound) {
        return;
    }

    [self adjustItemOrderWithDeleteItems:@[item]];

    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }

    if ([item isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *notInterestingData = (ExploreOrderedData *)item;

        if (notInterestingData.originalData && notInterestingData.originalData.uniqueID != 0) {
            //added5.2：dislike后设置originalData的notInterested

            if (!notInterestingData.originalData.notInterested) {
                TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:orderedData.uniqueID itemID:orderedData.shortVideoOriginalData.shortVideo.itemID impressionID:nil aggrType:1];
                [self.itemActionManager startSendDislikeActionType:DetailActionTypeNewVersionDislike source:TTDislikeSourceTypeFeed groupModel:groupModel filterWords:nil cardID:nil actionExtra:notInterestingData.actionExtra adID:nil adExtra:nil widgetID:nil threadID:nil finishBlock:nil];
            }
            [self setNotInterestToOrderedData:notInterestingData];

            [ExploreItemActionManager removeOrderedData:notInterestingData];
        }
    }

    NSString * title = nil;

    if ([TTAccountManager isLogin]) {
        title = kNotInterestTipUserLogined;
    } else {
        title = kNotInterestTipUserUnLogined;
    }

    [self tt_endUpdataData:NO error:nil tip:title duration:kDefaultDismissDuration tipTouchBlock:nil];
}

- (void)setNotInterestToOrderedData:(ExploreOrderedData *)orderedData {
    if ([orderedData.originalData respondsToSelector:@selector(notInterested)]) {
        orderedData.originalData.notInterested = @(YES);
        [orderedData.originalData save];
    }
}

- (void)adjustItemOrderWithDeleteItems:(NSArray *)deleteItems
{
    @weakify(self);
    [self.feedFetchManager adjustTSVItemsOrderWithDeleteItems:deleteItems finishBlock:^(NSArray *deleteArray, NSArray *insertArray) {
        @strongify(self);
        [self.collectionView performBatchUpdates:^{
            @strongify(self);
            [self collectionViewPerformBatchUpdateWithDeleteArray:deleteArray insertArray:insertArray];
        } completion:nil];
    }];
}

- (void)adjustItemOrderWithInsertOrderedData:(ExploreOrderedData *)orderedData
{
    @weakify(self);
    [self scrollToTopAnimated:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.feedFetchManager adjustTSVItemsOrderWithInsertItems:@[orderedData] atIndex:0 finishBlock:^(NSArray * _Nullable deleteArray, NSArray * _Nullable insertArray) {
            [self.collectionView performBatchUpdates:^{
                @strongify(self);
                [self collectionViewPerformBatchUpdateWithDeleteArray:deleteArray insertArray:insertArray];
            } completion:nil];
        }];
    });
    
}

- (void)collectionViewPerformBatchUpdateWithDeleteArray:(NSArray *)deleteArray insertArray:(NSArray *)insertArray
{
    NSMutableSet *deleteIndexPathSet = [NSMutableSet setWithCapacity:[deleteArray count]];
    NSMutableSet *insertIndexPathSet = [NSMutableSet setWithCapacity:[insertArray count]];
    for (NSNumber *indexNumber in deleteArray) {
        [deleteIndexPathSet addObject:[NSIndexPath indexPathForItem:[indexNumber integerValue] inSection:0]];
    }
    for (NSNumber *indexNumber in insertArray) {
        [insertIndexPathSet addObject:[NSIndexPath indexPathForItem:[indexNumber integerValue] inSection:0]];
    }
    [self.collectionView deleteItemsAtIndexPaths:[deleteIndexPathSet allObjects]];
    [self.collectionView insertItemsAtIndexPaths:[insertIndexPathSet allObjects]];
}

#pragma mark - cell点击跳转

- (void)enterDetailByOrderedData:(ExploreOrderedData *)orderedData offset:(NSUInteger)offsetIndex {
   if (!isEmptyString(orderedData.shortVideoOriginalData.shortVideo.detailSchema)) {
        NSURL *url = [TTStringHelper URLWithURLString:orderedData.shortVideoOriginalData.shortVideo.detailSchema];

        if ([[TTRoute sharedRoute] canOpenURL:url]) {

            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];

            WeakSelf;
            TSVShortVideoDetailExitManager *exitManager = [[TSVShortVideoDetailExitManager alloc] initWithUpdateBlock:^CGRect{
                StrongSelf;
                CGRect imageFrame = [self selectedCellFrame];
                imageFrame.origin = CGPointZero;
                return imageFrame;
            } updateTargetViewBlock:^UIView *{
                StrongSelf;
                return [self selectedCollectionViewCell];
            }];

            id<TSVShortVideoDataFetchManagerProtocol> drawFetchManager;
            
            if ([TSVChannelDecoupledConfig strategy] == TSVChannelDecoupledStrategyDisabled) {
                drawFetchManager = [[TSVShortVideoListFetchManager alloc] initWithListManager:self.feedFetchManager.listManager listEntrance:_listEntrance item:orderedData loadMoreBlock:^(TTFetchListFinishBlock finishBlock, BOOL isAuto) {
                    StrongSelf;
                    if (isAuto) {
                        self.refreshFromType = ListDataOperationReloadFromTypePreLoadMoreDraw;
                    } else {
                        self.refreshFromType = ListDataOperationReloadFromTypeLoadMoreDraw;
                    }
                    [self loadMoreWithFinishBlock:finishBlock];
                }];
                
                [[RACObserve(drawFetchManager, detailCellCurrentItem) skip:1] subscribeNext:^(ExploreOrderedData *detailCellCurrentItem) {
                    StrongSelf;
                    NSUInteger listCellCurrentIndex = [self.feedFetchManager.items indexOfObject:detailCellCurrentItem];
                    if (listCellCurrentIndex == NSNotFound) {
                        return; // 保留前一个状态
                    }
                    NSIndexPath *exitIndexPath = [NSIndexPath indexPathForItem:listCellCurrentIndex inSection:0];
                    [self.collectionView scrollToItemAtIndexPath:exitIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                    self.selectedIndexPath = exitIndexPath;
                }];
            } else {
                drawFetchManager = [self decoupledFetchManagerWithClickIndex:offsetIndex];
                
                [[RACObserve(drawFetchManager, listCellCurrentIndex) skip:1] subscribeNext:^(NSNumber *listCellCurrentIndex) {
                    StrongSelf;

                    if (listCellCurrentIndex.integerValue == NSNotFound) {
                        self.selectedIndexPath = nil;
                        return;
                    }

                    NSIndexPath *exitIndexPath = [NSIndexPath indexPathForItem:[listCellCurrentIndex integerValue] inSection:0];
                    
                    [self.collectionView scrollToItemAtIndexPath:exitIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                    
                    self.selectedIndexPath = exitIndexPath;
                }];
            }
             self.drawFetchManager = drawFetchManager;
            
            [info setValue:exitManager forKey:HTSVideoDetailExitManager];

            [info setValue:drawFetchManager forKey:HTSVideoListFetchManager];
            
            NSUInteger listCellCurrentIndex = [self.feedFetchManager.items indexOfObject:orderedData];
            self.selectedIndexPath = [NSIndexPath indexPathForItem:listCellCurrentIndex inSection:0];
            [TSVTransitionAnimationManager sharedManager].listSelectedCellFrame = [self selectedCellFrame];
            //自定义push方式打开火山详情页
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(info) pushHandler:^(UINavigationController *nav, TTRouteObject *routeObj) {
                if ([nav isKindOfClass:[TTNavigationController class]] &&
                    [routeObj.instance isKindOfClass:[UIViewController class]]) {
                    [(TTNavigationController *)nav pushViewControllerByTransitioningAnimation:((UIViewController *)routeObj.instance) animated:YES];
                }
            }];
        }
    }
}

- (UICollectionViewCell *)selectedCollectionViewCell
{
    NSIndexPath *indexPath = self.selectedIndexPath;
    
    if (!indexPath) {
        return nil;
    }
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
   
    return cell;
}

- (CGRect)selectedCellFrame
{
    UICollectionViewCell *cell = [self selectedCollectionViewCell];
    if (cell) {
        CGRect frame = [cell convertRect:cell.bounds toView:nil];
        return frame;
    }
    return CGRectZero;
}

- (void)trackCellsInVisibleCells
{
    if (self.feedFetchManager.items.count > 0) {
        for (UICollectionViewCell *cell in [_collectionView visibleCells]) {
            if ([cell isKindOfClass:[TTHTSWaterfallCollectionViewCell class]]) {
                NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
                ExploreOrderedData *obj = self.feedFetchManager.items[indexPath.row];
                if ([obj isKindOfClass:[ExploreOrderedData class]] && [((TTHTSWaterfallCollectionViewCell *)cell).cellData.uniqueID isEqualToString:obj.uniqueID]) {
                    [self eventV3ShortVideoShowWithOrderData:obj];
                }
            }
//            else if ([cell isKindOfClass:[TSVStoryCollectionViewCell class]]) {
//                [(TSVStoryCollectionViewCell *)cell trackShowEvent];
//            }
        }
    }
}

- (void)eventV3ShortVideoShowWithOrderData:(ExploreOrderedData *)data
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:data.categoryID forKey:@"category_name"];
    [params setValue:@"click_category" forKey:@"enter_from"];
    [params setValue:@"video_feed" forKey:@"source"];
    [params setValue:@(data.shortVideoOriginalData.shortVideo.author.isFollowing) forKey:@"is_follow"];
    [params setValue:@(data.shortVideoOriginalData.shortVideo.author.isFriend) forKey:@"is_friend"];
    [AWEVideoDetailTracker trackEvent:@"huoshan_video_show" model:data.shortVideoOriginalData.shortVideo commonParameter:[params copy] extraParameter:nil];
    
    if (![self.traceIdDict[data.shortVideoOriginalData.shortVideo.itemID] isEqualToString:@""]) {
        
        [self sendFTraceClientShow:data];
        
        [self.traceIdDict setValue:@"" forKey:data.shortVideoOriginalData.shortVideo.itemID];
    }
}

- (void)sendFTraceClientShow:(ExploreOrderedData *)dictTraceData
{
    NSMutableDictionary *traceParams = [NSMutableDictionary dictionary];
    
    [traceParams setValue:@"house_app2c_v2" forKey:@"event_type"];
    
    [traceParams setValue:dictTraceData.shortVideoOriginalData.shortVideo.itemID forKey:@"item_id"];
    [traceParams setValue:@"click_category" forKey:@"enter_from"];
    [traceParams setValue:dictTraceData.shortVideoOriginalData.shortVideo.groupID forKey:@"group_id"];
    [traceParams setValue:dictTraceData.shortVideoOriginalData.shortVideo.logPb[@"impr_id"] forKey:@"impr_id"];
    [traceParams setValue:dictTraceData.shortVideoOriginalData.shortVideo.logPb forKey:@"log_pb"];
    [traceParams setValue:dictTraceData.categoryID forKey:@"category_name"];
    [traceParams setValue:dictTraceData.shortVideoOriginalData.shortVideo.groupSource forKey:@"group_source"];
    [traceParams setValue:@(dictTraceData.cellType) ? : @"be_null" forKey:@"cell_type"];

    [TTTracker eventV3:@"client_show" params:traceParams];
}

- (void)eventV3ForRefresh
{
    if (self.refreshFromType != ListDataOperationReloadFromTypeLoadMore && self.refreshFromType != ListDataOperationReloadFromTypePull && self.refreshFromType != ListDataOperationReloadFromTypeClickCategory && self.refreshFromType != ListDataOperationReloadFromTypeClickCategoryWithTip && self.refreshFromType != ListDataOperationReloadFromTypeAuto) {
        
        return;
    }
    NSString *refreshType = [[ExploreListHelper class] refreshTypeStrForReloadFromType:self.refreshFromType];
    if (!isEmptyString(refreshType)) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:self.categoryID forKey:@"category_name"];
        [params setValue:refreshType forKey:@"refresh_type"];
        [params setValue:[TTCategoryStayTrackManager shareManager].enterType forKey:@"enter_type"];

        [[EnvContext shared].tracer writeEvent:@"category_refresh" params:params];

    }

}

- (void)eventFHForLoadMore {

    NSString *refreshType = [[ExploreListHelper class] refreshTypeStrForReloadFromType:self.refreshFromType];
    if (!isEmptyString(refreshType)) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:self.categoryID forKey:@"category_name"];
        [params setValue:refreshType forKey:@"refresh_type"];
        [params setValue:[TTCategoryStayTrackManager shareManager].enterType forKey:@"enter_type"];
        
        [[EnvContext shared].tracer writeEvent:@"category_refresh" params:params];

    }
    
}


#pragma mark - 列表页视频预加载
- (void)startPrefetchVideo
{
    if (![TSVPrefetchVideoManager isPrefetchEnabled]) {
        return;
    }
    
    [self.prefetchVideoDisposable dispose];
    @weakify(self);
    self.prefetchVideoDisposable = [[[[RACSignal return:nil]
                                            delay:0.3f]
                                        deliverOn:[RACScheduler mainThreadScheduler]]
                                    subscribeNext:^(id  _Nullable x) {
                                        @strongify(self);
                                        [self prefetchVideo];
                                    }];
}

- (void)prefetchVideo
{
    NSArray<NSIndexPath *> *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        if (indexPath.item >= self.feedFetchManager.items.count) {
            continue;
        }
        
        id data = self.feedFetchManager.items[indexPath.item];
        
        if (![data isKindOfClass:[ExploreOrderedData class]]) {
            continue;
        }
        
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        
        [TSVPrefetchVideoManager startPrefetchShortVideo:orderedData.shortVideoOriginalData.shortVideo group:TSVVideoPrefetchShortVideoTabGroup];
    }
}

- (void)cancelPrefetchVideo
{
    [self.prefetchVideoDisposable dispose];

    [TSVPrefetchVideoManager cancelPrefetchShortVideoForGroup:TSVVideoPrefetchShortVideoTabGroup];
}

//#pragma mark - 插入发布状态中和已发布成功未展示出来小视频
//- (void)insertPublishManagerOrderedDataArray
//{
//    if ([self isMainTabRecCategory]) {
//        NSInteger index = 1;
//        NSMutableArray *needInsertArray = [NSMutableArray array];
//        NSMutableArray *needDeleteArray = [NSMutableArray array];
//        uint64_t time = [[NSDate date] timeIntervalSince1970] * kFeedItemIndexUnixTimeMultiplyPara;
//        for (ExploreOrderedData *newOrderedData in self.publishManager.shortVideoTabPublishOrderedDataArray) {
//            if (![self.feedFetchManager.items containsObject:newOrderedData]) {
//                if (newOrderedData.shortVideoOriginalData && [newOrderedData.categoryID isEqualToString:kTTUGCVideoCategoryID]) {
//                    //加1为了小视频列表的排序，后加入的排上面
//                    newOrderedData.itemIndex = time + index;
//                    [needInsertArray addObject:newOrderedData];
//                    //小视频的orderIndex要存下来，再切换频道时就能从数据库里读了
//                    [newOrderedData save];
//                    //publishManager里的小视频的orderedData就需要删了，避免重复插入
//                    [needDeleteArray addObject:newOrderedData];
//                } else if (newOrderedData.tsvPublishStatusOriginalData && [newOrderedData.tsvPublishStatusOriginalData.concernID isEqualToString:kTTShortVideoConcernID]) {
//                    //加1为了小视频列表的排序，后加入的排上面
//                    newOrderedData.itemIndex = time + index;
//                    [needInsertArray addObject:newOrderedData];
//                }
//                index ++;
//            }
//        }
//        [self.publishManager deleteDisplayedDatas:needDeleteArray];
//        if (needInsertArray.count > 0) {
//            [self.feedFetchManager adjustTSVItemsOrderWithInsertItems:needInsertArray atIndex:0 finishBlock:nil];
//        }
//    }
//}

#pragma mark - monitor
- (void)monitorCategoryListNetworkStatusWithOperationContext:(NSDictionary *)context error:(NSError *)error
{
    BOOL isResponseFromRemote = [[context objectForKey:kExploreFetchListIsResponseFromRemoteKey] boolValue];

    if (!isResponseFromRemote) {
        return;
    }

    NSDictionary *exploreMixedListConsumeTimeStamps = [[context objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];

    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithCapacity:3];

    // 总耗时
    int64_t start = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListTriggerRequestTimeStampKey] longLongValue];
    int64_t totalDuration = [NSObject machTimeToSecs:[NSObject currentUnixTime] - start] * 1000;
    [mutDict setValue:@(totalDuration) forKey:@"total"];

    // 网络请求的耗时
    int64_t remoteRequestBegin = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListRemoteRequestBeginTimeStampKey] longLongValue];
    int64_t remoteRequestEnd = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListGetRemoteDataOperationEndTimeStampKey] longLongValue];
    int64_t networkDuration = [NSObject machTimeToSecs:remoteRequestEnd - remoteRequestBegin] * 1000;
    [mutDict setValue:@(networkDuration) forKey:@"network"];

    if (!error) {
        [mutDict setValue:@(0) forKey:@"status"];
    } else {
        [mutDict setValue:@(1) forKey:@"status"];
        [mutDict setValue:@(error.code) forKey:@"err_code"];
    }

    [[TTMonitor shareManager] trackService:@"tsv_network_categorylist" value:[mutDict copy] extra:nil];
}

#pragma mark - 解耦

- (TSVShortVideoDecoupledFetchManager *)decoupledFetchManagerWithClickIndex:(NSInteger)clickIndex
{
    NSInteger maxIndex;
    
    maxIndex = clickIndex + [TSVChannelDecoupledConfig numberOfExtraItemsTakenToDetailPage];
    
    NSMutableArray<TTShortVideoModel *> *mutArr = [NSMutableArray array];
    
    for (NSInteger index = clickIndex; index <= maxIndex; index++) {
        if (index < self.feedFetchManager.items.count) {
            ExploreOrderedData *orderedData = self.feedFetchManager.items[index];
            
            if ([orderedData isKindOfClass:[ExploreOrderedData class]] && orderedData.shortVideoOriginalData.shortVideo) {
                TTShortVideoModel *model = orderedData.shortVideoOriginalData.shortVideo;
                model.listIndex = @(index);
                model.listEntrance = self.listEntrance;
                model.categoryName = self.categoryID;
                model.enterFrom = @"click_category";
                
                [mutArr addObject:model];
            }
        }
    }
    
    return [[TSVShortVideoDecoupledFetchManager alloc] initWithItems:[mutArr copy]
                                                   requestCategoryID:[NSString stringWithFormat:@"%@_detail_draw", self.categoryID]
                                                  trackingCategoryID:self.categoryID
                                                        listEntrance:self.listEntrance];
}

#pragma mark -- helper
- (BOOL)isMainTabRecCategory
{
    if ([self.currentCategory.categoryID isEqualToString:kTTUGCVideoCategoryID] && [self.listEntrance isEqualToString:@"main_tab"]) {
        //底小视频tab推荐频道
        return YES;
    } else {
        return NO;
    }
}

@end

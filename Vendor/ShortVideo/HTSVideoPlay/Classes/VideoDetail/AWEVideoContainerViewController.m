//
//  AWEVideoContainerViewController.m
//  Pods
//
//  Created by Zuyang Kou on 18/06/2017.
//
//

#import "AWEVideoContainerViewController.h"
#import "AWEVideoPlayView.h"
#import "EXTKeyPathCoding.h"
#import "BTDNetworkUtilities.h"
#import "TTNavigationController.h"
#import "AWEVideoLoadingCollectionViewCell.h"
#import "TTIndicatorView.h"
#import "TTThemedAlertController.h"
#import "EXTScope.h"
#import "AWEVideoDetailFirstUsePromptViewController.h"
#import "extobjc.h"
#import "AWEVideoPlayTrackerBridge.h"
#import <SSImpressionManager.h>
#import "AWEVideoDetailScrollConfig.h"
#import "TTFlowStatisticsManager+Helper.h"
#import "TSVVideoDetailControlOverlayUITypeConfig.h"
#import "TTImageInfosModel.h"
#import "SDWebImagePrefetcher.h"
#import "AWEVideoDetailFirstFrameConfig.h"
#import "TSVVideoDetailPromptManager.h"
#import "AWEVideoDetailSecondUsePromptViewController.h"
#import "TSVSlideUpPromptViewController.h"
#import "TSVSlideLeftEnterProfilePromptViewController.h"
//#import "TSVProfileConfig.h"
#import "TSVDetailViewModel.h"
#import "TSVMonitorManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTRelevantDurationTracker.h"
#import "AWEVideoDetailControlOverlayViewController.h"
#import "TSVPrefetchImageManager.h"
//#import "TSVNewControlOverlayViewController.h"
#import "TSVPrefetchVideoManager.h"
#import "TTSettingsManager.h"
#import "TTFFantasyTracker.h"
#import "FHFeedUGCCellModel.h"
// TTAd
#import "AWEVideoContainerAdCollectionViewCell.h"
#import "AWEVideoDetailControlAdOverlayViewController.h"
#import "TTShortVideoModel+TTAdFactory.h"
#import "ToastManager.h"
#import "FHShortVideoTracerUtil.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHUGCShortVideoFullScreenCell.h"
#import "FHShortVideoPerLoaderManager.h"

@interface AWEVideoContainerCollectionView : UICollectionView
@end

@implementation AWEVideoContainerCollectionView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self];
        switch ([AWEVideoDetailScrollConfig direction]) {
            case AWEVideoDetailScrollDirectionHorizontal: {
                // scroll view 在最左边的时候允许右滑返回
                CGFloat threshold = CGRectGetWidth(self.frame);
                if (velocity.x > 0 && self.contentOffset.x == 0 && [gestureRecognizer locationInView:self].x < threshold) {
                    return NO;
                }
            }
                break;
            case AWEVideoDetailScrollDirectionVertical: {
                // scroll view 在最上面的时候允许下拉关闭
                CGFloat threshold = CGRectGetHeight(self.frame);
                if (velocity.y > 0 && self.contentOffset.y == 0 && [gestureRecognizer locationInView:self].y < threshold) {
                    return NO;
                }
            }
                break;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

@end

@interface AWEVideoContainerViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate, SSImpressionProtocol>

@property (nonatomic, strong) AWEVideoContainerCollectionView *collectionView;
@property (nonatomic, assign) BOOL firstPageShown;  //用于区分发 go_detail 还是 go_detail_draw
@property (nonatomic, strong) FHShortVideoTracerUtil *tracker;
@property (nullable, nonatomic, copy) NSIndexPath *currentIndexPath;
@property (nonatomic, assign) BOOL loadingCellOnScreen;
@property (nonatomic, assign) BOOL needsLoadingCell;
@property (nonatomic, assign) BOOL showingNoMoreVideoIndicator;
@property (nonatomic, assign) BOOL scrollViewExceeedsBoundary;
@property (nonatomic, assign) BOOL preventVideoPlay;
@property (nonatomic, assign) NSInteger initialItemIndex;
@property (nullable, nonatomic, strong) FHUGCShortVideoFullScreenCell *currentVideoCell;
@property (nonatomic, strong) NSMutableArray *feedClientShowCache;

@end

@implementation AWEVideoContainerViewController

static NSString *videoCellReuseIdentifier = @"AWEVideoContainerCollectionViewCell";
static NSString *loadingCellReuseIdentifier = @"AWEVideoLoadingCollectionViewCell";
static NSString *adVideoCellReuseIdentifier = @"AWEVideoContainerAdCollectionViewCell";

const static CGFloat kAWEVideoContainerSpacing = 2;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidAppear:) name:@"SKStoreProductViewDidAppearKey" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:@"SKStoreProductViewDidDisappearKey" object:nil];
        [[SSImpressionManager shareInstance] addRegist:self];
        self.tracker = [[FHShortVideoTracerUtil alloc] init];
        self.feedClientShowCache = [[NSMutableArray alloc]init];
    }

    return self;
}

- (void)dealloc
{
    [[SSImpressionManager shareInstance] removeRegist:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

- (void)applicationWillEnterBackground:(id)object
{
    if (self.viewLoaded && [self.view window]) {
        [self.currentVideoCell pause];
        [self sendStayPageTracking];
    }
}
- (void)applicationWillResignActive:(id)object
{
    if (self.viewLoaded && [self.view window]) {
        [self.currentVideoCell pause];
        [self sendStayPageTracking];
    }
}

- (void)applicationDidBecomeActive:(id)object
{
    if (self.viewLoaded && [self.view window] && !self.preventVideoPlay) {
        [self.currentVideoCell play];
        [self.tracker flushStayPageTime];
    }
}

- (void)skStoreViewDidAppear:(NSNotification *)notification
{
    if (self.viewLoaded && [self.view window]) {
        [self.currentVideoCell pause];
        [self sendStayPageTracking];
        self.preventVideoPlay = YES;
    }
}

- (void)skStoreViewDidDisappear:(NSNotification *)notification
{
    if (self.viewLoaded && [self.view window]) {
        [self.currentVideoCell play];
        [self.tracker flushStayPageTime];
        self.preventVideoPlay = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        switch ([AWEVideoDetailScrollConfig direction]) {
            case AWEVideoDetailScrollDirectionHorizontal:
                layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
                break;
            case AWEVideoDetailScrollDirectionVertical:
                layout.scrollDirection = UICollectionViewScrollDirectionVertical;
                break;
        }
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        CGRect collectionFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        AWEVideoContainerCollectionView *view = [[AWEVideoContainerCollectionView alloc] initWithFrame:collectionFrame collectionViewLayout:layout];
        CGRect frame = collectionFrame;
        switch ([AWEVideoDetailScrollConfig direction]) {
            case AWEVideoDetailScrollDirectionHorizontal:
                view.alwaysBounceHorizontal = self.dataFetchManager.shouldShowNoMoreVideoToast;
                frame.size.width += kAWEVideoContainerSpacing;
                break;
            case AWEVideoDetailScrollDirectionVertical:
                view.alwaysBounceVertical = self.dataFetchManager.shouldShowNoMoreVideoToast;
                frame.size.height += kAWEVideoContainerSpacing;
                break;
        }
        
        if (@available(iOS 11.0, *)) {
             [view setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }

        view.frame = frame;
        view.dataSource = self;
        view.delegate = self;
        view.showsHorizontalScrollIndicator = NO;
        view.showsVerticalScrollIndicator = NO;
        view.pagingEnabled = YES;
        view.scrollsToTop = NO;
        view.backgroundColor = [UIColor clearColor];
        [view registerClass:[FHUGCShortVideoFullScreenCell class] forCellWithReuseIdentifier:videoCellReuseIdentifier];
        [view registerClass:[AWEVideoLoadingCollectionViewCell class] forCellWithReuseIdentifier:loadingCellReuseIdentifier];
        [view registerClass:[AWEVideoContainerAdCollectionViewCell class] forCellWithReuseIdentifier:adVideoCellReuseIdentifier];
        view;
    });
    [self.view addSubview:self.collectionView];
    
    @weakify(self);
    RAC(self, needsLoadingCell) = RACObserve(self, dataFetchManager.hasMoreToLoad);
    [[[RACObserve(self, needsLoadingCell) combinePreviousWithStart:nil reduce:^id(id previous, id current) {
        return RACTuplePack(previous, current);
    }]
      skip:1]
     subscribeNext:^(RACTuple *tuple) {
         BOOL oldNeedsLoadingCell = [tuple.first boolValue];
         [UIView performWithoutAnimation:^{
             @strongify(self);
             if (self.needsLoadingCell && !oldNeedsLoadingCell) {
                 [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:1]];
             } else if (!self.needsLoadingCell && oldNeedsLoadingCell) {
                 [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:1]];
             }
         }];
     }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL scrollViewExceedsBoundary;
    CGFloat velocity;
    switch ([AWEVideoDetailScrollConfig direction]) {
        case AWEVideoDetailScrollDirectionHorizontal:
            scrollViewExceedsBoundary = self.collectionView.bounds.size.width + self.collectionView.contentOffset.x > self.collectionView.contentSize.width;
            velocity = [scrollView.panGestureRecognizer velocityInView:scrollView].x;
            break;
        case AWEVideoDetailScrollDirectionVertical:
            scrollViewExceedsBoundary = self.collectionView.bounds.size.height + self.collectionView.contentOffset.y > self.collectionView.contentSize.height;
            velocity = [scrollView.panGestureRecognizer velocityInView:scrollView].y;
            break;
    }

    if (!self.scrollViewExceeedsBoundary && scrollViewExceedsBoundary) {
        if (velocity < 0 &&
            !self.showingNoMoreVideoIndicator &&
            !self.needsLoadingCell &&
            self.dataFetchManager.shouldShowNoMoreVideoToast) {
            self.showingNoMoreVideoIndicator = YES;
            @weakify(self);
        }
    }

    self.scrollViewExceeedsBoundary = scrollViewExceedsBoundary;
    
    [self.detailPromptManager hidePrompt];
    if (self.didScroll) {
        self.didScroll();
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([self.dataFetchManager numberOfShortVideoItems]) {
        if (([self.dataFetchManager numberOfShortVideoItems] > self.dataFetchManager.currentIndex + 1) ||
            self.dataFetchManager.hasMoreToLoad) {
            self.initialItemIndex = self.dataFetchManager.currentIndex;
        } else {
            self.initialItemIndex = 0;
        }

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.dataFetchManager.currentIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionTop | UICollectionViewScrollPositionLeft
                                            animated:NO];
        
    }

    [self.currentVideoCell play];
    [self.currentVideoCell.overlayViewController beginTimers];
    [self beginFirstImpression];
    [self.tracker flushStayPageTime];
}

- (void)refresh
{
    // 动画可能导致 loading cell 一闪而过
    [UIView performWithoutAnimation:^{
        [self.collectionView performBatchUpdates:^{
            NSInteger oldItemCount = [self.collectionView numberOfItemsInSection:0];
            if (oldItemCount < self.dataFetchManager.numberOfShortVideoItems) {
                NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                for (NSInteger index = oldItemCount; index < self.dataFetchManager.numberOfShortVideoItems; index++) {
                    [indexPathArray addObject:[NSIndexPath indexPathForItem:index inSection:0]];
                }
                [self.collectionView insertItemsAtIndexPaths:indexPathArray];
            } else if (oldItemCount > self.dataFetchManager.numberOfShortVideoItems) {
                // 处理列表页刷新之后视频数量减少的现象，这种情况下只保证数量正确，内容都会发生变化
                NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                for (NSInteger index = self.dataFetchManager.numberOfShortVideoItems; index < oldItemCount; index++) {
                    [indexPathArray addObject:[NSIndexPath indexPathForItem:index inSection:0]];
                }
                [self.collectionView deleteItemsAtIndexPaths:indexPathArray];
            }
        } completion:nil];
    }];

    [self updateLoadingCellOnScreen];
    
    [self playCurrentVideoIfAllowed];
}

- (void)refreshCurrentModel
{
    self.currentVideoCell = nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
         bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    CGSize size = self.view.bounds.size;
    switch ([AWEVideoDetailScrollConfig direction]) {
        case AWEVideoDetailScrollDirectionHorizontal:
            size.width += kAWEVideoContainerSpacing;
            break;
        case AWEVideoDetailScrollDirectionVertical:
            size.height += kAWEVideoContainerSpacing;
            break;
    }

    return size;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.needsLoadingCell) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.dataFetchManager numberOfShortVideoItems];
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        FHFeedUGCCellModel *model = [self.dataFetchManager itemAtIndex:indexPath.row];
        FHUGCShortVideoFullScreenCell *cell = nil;
//        AWEVideoContainerCollectionViewCell
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:videoCellReuseIdentifier forIndexPath:indexPath];
            if (!cell.overlayViewController) {
                UIViewController<TSVControlOverlayViewController> *viewController;
//                if ([TSVVideoDetailControlOverlayUITypeConfig overlayUIType] > 1) {
//                    viewController = [[TSVNewControlOverlayViewController alloc] init];
//                } else {
                    viewController = [[AWEVideoDetailControlOverlayViewController alloc] init];
//                }
                cell.overlayViewController = viewController;
                if (self.configureOverlayViewController) {
                    self.configureOverlayViewController(cell.overlayViewController);
                }
                [self addChildViewController:cell.overlayViewController];
                [cell.contentView addSubview:cell.overlayViewController.view];
                cell.overlayViewController.view.frame = self.collectionView.bounds;
                [cell.overlayViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(cell.contentView);
                }];
                [cell.overlayViewController didMoveToParentViewController:self];
            }
//        cell.overlayViewController.playerStateStore = cell.playerView.player.controlView.playerStateStore;

        cell.overlayViewController.viewModel.model = [self.dataFetchManager itemAtIndex:indexPath.item];

        [cell setNeedsLayout];
        cell.commonTrackingParameter = self.commonTrackingParameter;
        [cell updateWithModel:[self.dataFetchManager itemAtIndex:indexPath.item]];
//        [cell updateWithModel:[self.dataFetchManager itemAtIndex:indexPath.item] usingFirstFrameCover:YES];
//        cell.spacingMargin = kAWEVideoContainerSpacing;
      
        BOOL forward = !self.currentIndexPath || self.currentIndexPath.item < indexPath.item;
        
        @weakify(self);
        cell.videoDidStartPlay = ^{
            @strongify(self);
            [TSVPrefetchImageManager prefetchDetailImageWithDataFetchManager:self.dataFetchManager forward:forward];
            // 预加载视频
//            [TSVPrefetchVideoManager startPrefetchShortVideoInDetailWithDataFetchManager:self.dataFetchManager];
            [FHShortVideoPerLoaderManager startPrefetchShortVideoInDetailWithDataFetchManager:self.dataFetchManager];
        };
   
        cell.videoDidPlayOneLoop = ^{
            @strongify(self);
            self.detailPromptManager.dataFetchManager = self.dataFetchManager;
            self.detailPromptManager.containerViewController = self.parentViewController;
            self.detailPromptManager.scrollView = self.collectionView;
            self.detailPromptManager.commonTrackingParameter = self.commonTrackingParameter;
            [self.detailPromptManager videoDidPlayOneLoop];
        };

        return cell;
    } else {
        AWEVideoLoadingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:loadingCellReuseIdentifier forIndexPath:indexPath];
        cell.dataFetchManager = self.dataFetchManager;
        @weakify(self);
        cell.retryBlock = ^{
            @strongify(self);
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            if (self.commonTrackingParameter[@"enter_from"]) {
                [params setValue:self.commonTrackingParameter[@"enter_from"] forKey:@"enter_from"];
            }
            if (self.commonTrackingParameter[@"category_name"]) {
                [params setValue:self.commonTrackingParameter[@"category_name"] forKey:@"category_name"];
            }
            if ([self.dataFetchManager numberOfShortVideoItems]) {
                FHFeedUGCCellModel *videoDetail = [self.dataFetchManager itemAtIndex:[self.dataFetchManager numberOfShortVideoItems] - 1];//取最后一个
//                [params setValue:videoDetail.listEntrance forKey:@"list_entrance"];
                [params setValue:videoDetail.groupId forKey:@"from_group_id"];
                [params setValue:videoDetail.groupSource forKey:@"from_group_source"];
                if (videoDetail.categoryId) {
                    [params setValue:videoDetail.categoryId forKey:@"category_name"];
                }
                if (videoDetail.enterFrom) {
                    [params setValue:videoDetail.enterFrom forKey:@"enter_from"];
                }
            }
            [AWEVideoPlayTrackerBridge trackEvent : @"video_draw_retry"
                                           params : params];
            
            self.loadMoreBlock(NO);
        };
        cell.closeButtonDidClick = self.wantToClosePage;

        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(FHUGCShortVideoFullScreenCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell) {
        [cell readyToPlay];
    }
    
    if (!self.currentVideoCell.playerView && (indexPath.section == 0 && indexPath.item == self.dataFetchManager.currentIndex)) {
        self.currentVideoCell = cell;
        self.currentIndexPath = indexPath;
        [self beginFirstImpression];
        [self alertCeullarPlayWithCompletion:^(BOOL continuePlaying) {
            if (continuePlaying) {
                [self showPromotionIfNecessaryWithIndex:indexPath.item];
                // 首次进入的播放
                self.dataFetchManager.currentIndex = indexPath.row;
                [self.currentVideoCell readyToPlay];
                [self.currentVideoCell play];
                [self.currentVideoCell.overlayViewController beginTimers];
                [self didSwitchToCell:self.currentVideoCell];
            } else {
                if (self.wantToClosePage) {
                    self.wantToClosePage();
                }
            }
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(FHUGCShortVideoFullScreenCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (cell) {
        [self sendVideoOverTracking];
        [cell stop];
        [cell reset];
//        [cell resetPlayerModel];

        if (cell.overlayViewController) {
            [cell.overlayViewController stopTimers];
            [cell.overlayViewController.miniSlider setWatchedProgress:0];
            [cell.overlayViewController.miniSlider setCacheProgress:0];
        }

        NSLog(@"666");
    }
}

- (void)showPromotionIfNecessaryWithIndex:(NSInteger)index
{
    /*
     上滑手势引导,引导出浮层（评论浮层／作品浮层）
     左滑手势引导，引导进个人主页
     左右／上下 滑动手势引导，引导切换视频
     引导之间互斥
     */
    TSVShortVideoListEntrance entrance = TSVShortVideoListEntranceOther;
//    if ([self.dataFetchManager respondsToSelector:@selector(entrance)]) {
//        entrance = self.dataFetchManager.entrance;
//    }
    if ([TSVSlideUpPromptViewController needSlideUpPromotion]) {
        //观看第n个视频时
        [TSVSlideUpPromptViewController showSlideUpPromotionIfNeededInViewController:self.parentViewController];
    } else if ([TSVSlideLeftEnterProfilePromptViewController needSlideLeftPromotion] && entrance != TSVShortVideoListEntranceProfile) {
        //不是从个人主页进的详情页，观看第n个视频出引导
        [TSVSlideLeftEnterProfilePromptViewController showSlideLeftPromotionIfNeededInViewController:self.parentViewController];
    } else {
        //展示 左右滑动/上下滑动引导
        [self showSwipePromotionIfNecessaryWithIndex:index];
    }
}

- (void)showSwipePromotionIfNecessaryWithIndex:(NSInteger)index
{
    if ([self.dataFetchManager numberOfShortVideoItems] <= 1 && !self.dataFetchManager.hasMoreToLoad) {
        return;
    }

    AWEPromotionDiretion direction;
    if (index == self.initialItemIndex) {
        switch ([AWEVideoDetailScrollConfig direction]) {
            case AWEVideoDetailScrollDirectionHorizontal:
                direction = AWEPromotionDiretionLeft;
                break;
            case AWEVideoDetailScrollDirectionVertical:
                direction = AWEPromotionDiretionUpVideoSwitch;
                break;
        }
    } else {
        return;
    }
    TSVShortVideoListEntrance entrance = TSVShortVideoListEntranceOther;
    AWEPromotionCategory category;
    switch (entrance) {
        case TSVShortVideoListEntranceOther:
            category = AWEPromotionCategoryDefault;
            break;
        case TSVShortVideoListEntranceFeedCard:
            category = AWEPromotionCategoryA;
            break;
        default:
            category = AWEPromotionCategoryDefault;
            break;
    }

    [AWEVideoDetailFirstUsePromptViewController showPromotionIfNeededWithDirection:direction
                                                                             category:category
                                                                     inViewController:self.parentViewController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.currentVideoCell pause];
    [self endLastImpression];
    [self sendStayPageTracking];
}

- (void)videoOverTracer {
    [self sendVideoOverTracking];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        [TSVPrefetchVideoManager cancelPrefetchShortVideoInDetail];
    }
}

- (NSInteger)currentItemIndex
{
    NSInteger itemIndex;
    switch ([AWEVideoDetailScrollConfig direction]) {
        case AWEVideoDetailScrollDirectionHorizontal:
            itemIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
            break;
        case AWEVideoDetailScrollDirectionVertical:
            itemIndex = self.collectionView.contentOffset.y / self.collectionView.frame.size.height;
            break;
    }

    return itemIndex;
}

- (BOOL)canPullToClose
{
    switch ([AWEVideoDetailScrollConfig direction]) {
        case AWEVideoDetailScrollDirectionHorizontal:
            return YES;
            break;
        case AWEVideoDetailScrollDirectionVertical:
            return ABS(self.collectionView.contentOffset.y) < 1e-6;
            break;
    }
}

- (void)didSwitchToCell:(FHUGCShortVideoFullScreenCell *)cell
{
    
    NSParameterAssert(cell);
    self.detailPromptManager.dataFetchManager = self.dataFetchManager;
    self.detailPromptManager.containerViewController = self;
    self.detailPromptManager.scrollView = self.collectionView;
    self.detailPromptManager.commonTrackingParameter = self.commonTrackingParameter;
    [self.detailPromptManager videoDidPlayWithSwipe:self.firstPageShown];

    // 取消上一个视频的预加载
    [TSVPrefetchVideoManager cancelPrefetchShortVideoInDetail];

    [TTFFantasyTracker sharedInstance].lastGid = cell.cellModel.groupId;

    [self sendGoDetailAndVideoPlayWithCell:cell];
    [self sendFeedClientShowAndVideoPlayWithCell:cell];
    [[TSVMonitorManager sharedManager] recordCurrentMemoryUsage];
}

- (void)sendFeedClientShowAndVideoPlayWithCell:(FHUGCShortVideoFullScreenCell *)cell {
    NSString *groupId = cell.cellModel.groupId;
    if (groupId && ![self.feedClientShowCache containsObject:groupId]) {
        [self.feedClientShowCache addObject:groupId];
        NSInteger rank = [cell.cellModel.tracerDic btd_integerValueForKey:@"rank" default:0];
        [FHShortVideoTracerUtil feedClientShowWithmodel:cell.cellModel eventIndex:rank];
    };
}

- (void)sendGoDetailAndVideoPlayWithCell:(FHUGCShortVideoFullScreenCell *)cell
{
    NSParameterAssert(cell);
    NSInteger rank = [cell.cellModel.tracerDic btd_integerValueForKey:@"rank" default:0];
    [FHShortVideoTracerUtil videoPlayOrPauseWithName:@"video_play" eventModel:cell.cellModel eventIndex:rank];
    [FHShortVideoTracerUtil goDetailWithModel:cell.cellModel eventIndex:self.initialItemIndex];
    [self.tracker flushStayPageTime];
    cell.cellModel.videoAction.playCount = [NSString stringWithFormat:@"%ld",[cell.cellModel.videoAction.playCount intValue]+ 1];
//    [self sendStayPageTracking];
}

- (void)sendVideoOverTracking
{
    if (!self.currentVideoCell) {
        // 加载页退出
        return;
    }

    NSTimeInterval totalPlayTime = self.currentVideoCell.playerView.player.playerStateStore.state.currentPlaybackTime;
    
    if (totalPlayTime <= 0  ){
        return;
    }
    NSString *duration = [NSString stringWithFormat:@"%.0f", totalPlayTime * 1000];
   NSInteger rank = [self.currentVideoCell.cellModel.tracerDic btd_integerValueForKey:@"rank" default:0];
    [FHShortVideoTracerUtil videoOverWithModel:self.currentVideoCell.cellModel eventIndex:rank forStayTime:duration];
}

- (void)sendStayPageTracking
{
    if (!self.currentVideoCell) {
        // 加载页退出
        return;
    }

    NSString *eventName = self.firstPageShown ? @"stay_page_draw" : @"stay_page";
    NSString *stayTime = [NSString stringWithFormat:@"%.0f", [self.tracker timeIntervalForStayPage] * 1000];
    NSMutableDictionary *paramters = @{}.mutableCopy;
//    paramters[@"user_id"] = self.currentVideoCell.videoDetail.author.userID;
    paramters[@"stay_time"] = stayTime;
//
//
//    [AWEVideoDetailTracker trackEvent:eventName
//                                model:self.currentVideoCell.videoDetail
//                      commonParameter:self.commonTrackingParameter
//                       extraParameter:paramters];
    NSInteger rank = [self.currentVideoCell.cellModel.tracerDic btd_integerValueForKey:@"rank" default:0];
    [FHShortVideoTracerUtil stayPageWithModel:self.currentVideoCell.cellModel eventIndex:rank forStayTime:stayTime];
    FHFeedUGCCellModel *video = self.currentVideoCell.cellModel;
    NSString *enterFrom = video.enterFrom ?: self.commonTrackingParameter[@"enter_from"];
    NSString *categoryName = video.categoryId ?: self.commonTrackingParameter[@"category_name"];
    if(video.groupId.length > 0){
        [[TTRelevantDurationTracker sharedTracker] appendRelevantDurationWithGroupID:video.groupId
                                                                          itemID:video.groupId
                                                                       enterFrom:enterFrom
                                                                    categoryName:categoryName
                                                                        stayTime:[self.tracker timeIntervalForStayPage] * 1000
                                                                           logPb:video.logPb];
    } 
}

#pragma mark -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger itemIndex = [self currentItemIndex];
    if (itemIndex != self.currentIndexPath.item && ![[NSUserDefaults standardUserDefaults] objectForKey:@"AWEVideoDetailDidScroll"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@1 forKey:@"AWEVideoDetailDidScroll"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self processImpression];

    [self refresh];     //FIXME: 感觉有点夸张了
    
    if (itemIndex < [self.dataFetchManager numberOfShortVideoItems]) {
        [self playCurrentVideoIfAllowed];
    } else {
        if (self.currentVideoCell) {
            [self sendStayPageTracking];
            [self sendVideoOverTracking];
            self.currentVideoCell = nil;
            self.currentIndexPath = nil;
        }
        self.loadMoreBlock(YES);
    }

    [self updateLoadingCellOnScreen];
}

#pragma mark - Impression

- (void)processImpression
{
#if !DEBUG
    @try {
#endif
        NSInteger itemIndex = [self currentItemIndex];
        TTShortVideoModel *oldVideoDetail = self.currentVideoCell.cellModel;
        if (itemIndex >= [self.dataFetchManager numberOfShortVideoItems]) {
            [self sendImpressionWithVideoDetail:oldVideoDetail status:SSImpressionStatusEnd];
        } else {
            TTShortVideoModel *newVideoDetail = [self.dataFetchManager itemAtIndex:itemIndex];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
            if (![newIndexPath isEqual:self.currentIndexPath]) {
                if (oldVideoDetail) {
                    [self sendImpressionWithVideoDetail:oldVideoDetail status:SSImpressionStatusEnd];
                }
                [self sendImpressionWithVideoDetail:newVideoDetail status:SSImpressionStatusRecording];
            }
        }
#if !DEBUG
    } @catch (NSException *exception) {
        ;
    } @finally {
        ;
    }
#endif
}

- (void)beginFirstImpression
{
    /* 两个时机会有效地调用这个方法，一个是第一次进来在 cellForItemAtIndexPath 里面，一个是在其他页面回到详情页时在 -viewWillAppear: 中。
     * 有一次无效的调用是在第一次进来的 -viewWillAppear: 中，这个时候 videoDetail 会为 nil，这也是在 cellForItemAtIndexPath 调用的原因
     */
    
    TTShortVideoModel *videoDetail = self.currentVideoCell.cellModel;
    if (videoDetail) {
        [self sendImpressionWithVideoDetail:videoDetail status:SSImpressionStatusRecording];
    }
}

- (void)endLastImpression
{
    TTShortVideoModel *videoDetail = self.currentVideoCell.cellModel;
    //NSAssert(videoDetail, @"videoDetail should exist, otherwise we will lose impression");
    if (videoDetail) {
        [self sendImpressionWithVideoDetail:videoDetail status:SSImpressionStatusEnd];
    }

}

- (void)sendImpressionWithVideoDetail:(FHFeedUGCCellModel *)videoDetail status:(SSImpressionStatus)status
{
    NSString *currentCategoryName = videoDetail.categoryId ?: self.commonTrackingParameter[@"category_name"];
    if (![currentCategoryName isEqualToString:@"f_hotsoon_video"]) {
        // 目前只在小视频列表页进入的情况下发 impression
        return;
    }

    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = currentCategoryName;
    params.refer = 1;
    NSDictionary *userInfo = @{
                               @"extra": @{
                                       @"refer": @(params.refer)
                                       },
                               @"params": params,
                               };
    [[SSImpressionManager shareInstance] recordWithListKey:params.categoryID
                                                  listType:SSImpressionGroupTypeHuoshanVideoList
                                                    itemID:videoDetail.groupId
                                                 modelType:SSImpressionModelTypeUGCVideo
                                                      adID:@""
                                                    status:status
                                                  userInfo:userInfo];

}

- (void)needRerecordImpressions
{
    FHFeedUGCCellModel *videoDetail = self.currentVideoCell.cellModel;
    if (videoDetail) {
        [self sendImpressionWithVideoDetail:videoDetail status:SSImpressionStatusRecording];
    }
}


#pragma mark -

- (void)updateLoadingCellOnScreen
{
    NSInteger itemIndex = [self currentItemIndex];
    self.loadingCellOnScreen = itemIndex >= [self.dataFetchManager numberOfShortVideoItems];
}

- (void)playCurrentVideoIfAllowed
{
    [self alertCeullarPlayWithCompletion:^(BOOL continuePlaying) {
        if (!continuePlaying) {
            if (self.wantToClosePage) {
                self.wantToClosePage();
            }
        } else {
            NSInteger itemIndex = [self currentItemIndex];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
            FHUGCShortVideoFullScreenCell *cell = (FHUGCShortVideoFullScreenCell *)[self.collectionView cellForItemAtIndexPath:newIndexPath];

            if ([cell isKindOfClass:[FHUGCShortVideoFullScreenCell class]] ||
                [cell isKindOfClass:[AWEVideoContainerAdCollectionViewCell class]]) {
                if (![newIndexPath isEqual:self.currentIndexPath]) {
                    // 左右划的播放
                    [self showPromotionIfNecessaryWithIndex:itemIndex];
                    [self sendStayPageTracking];
                    self.firstPageShown = YES;
                    [self refreshCurrentModel];
                    self.dataFetchManager.currentIndex = itemIndex;
                    self.currentVideoCell = cell;
                    self.currentIndexPath = newIndexPath;
                    [self.currentVideoCell readyToPlay];
                    [self.currentVideoCell play];
                    [self.currentVideoCell.overlayViewController beginTimers];
                    [self didSwitchToCell:self.currentVideoCell];
                }else  {
                    if (self.currentVideoCell && !self.currentVideoCell.videoIsPause) {
                        [self.currentVideoCell play];
                    }
                }
            } else {
//                [self.currentVideoCell.videoPlayView stop];
                [self sendVideoOverTracking];
                [self sendStayPageTracking];
                self.currentVideoCell = nil;
                self.currentIndexPath = nil;
                self.firstPageShown = YES;
            }
        }
    }];
}

- (void)alertCeullarPlayWithCompletion:(void (^_Nonnull)(BOOL continuePlaying))completion
{
    BOOL isFreeFlow = [[TTFlowStatisticsManager sharedInstance] hts_isFreeFlow];

    if (!isFreeFlow && self.needCellularAlert && BTDNetworkConnected() && !BTDNetworkWifiConnected()) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ToastManager manager] showToast:@"当前处在非WiFi环境，注意流量消耗哦！"];
        });
    }
    
    !completion ?: completion(YES);
}

- (void)playCurrentVideo
{
        [self.currentVideoCell.playerView.player sendAction:TTVPlayerEventTypePlayerBeginPlay payload:nil];
}

- (void)pauseCurrentVideo
{
//    if ([self.currentVideoCell.playerView isPlaying]) {
         [self.currentVideoCell.playerView.player sendAction:TTVPlayerEventTypePlayerPause payload:nil];
//    }
}

- (UIView *)exitScreenshotView
{
//    if (!self.currentVideoCell.videoPlayView) {
//        return self.view;
//    }
//    return self.currentVideoCell.videoPlayView;
}

@end

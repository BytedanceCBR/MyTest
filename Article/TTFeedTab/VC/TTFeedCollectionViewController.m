//
//  TTFeedCollectionViewController.m
//  Article
//
//  Created by Chen Hong on 2017/3/28.
//
//

#import "TTFeedCollectionViewController.h"
#import "TTFeedCollectionCellService.h"
#import "TTFeedCollectionCellDefaultHelper.h"
#import "TTArticleCategoryManager.h"
//#import "NewsListLogicManager.h"
//#import "TTFeedMixedListService.h"
//#import "TTFeedDataDefaultConsumer.h"
#import "ExploreCellHelper.h"
#import "TTFeedRefreshView.h"
#import "ArticleCategoryManagerView.h"
#import "TTLocationManager.h"

#import "TTCategoryStayTrackManager.h"
#import "ExploreMovieView.h"
#import "ExploreSubscribeDataListManager.h"
#import "TTAuthorizeManager.h"
#import "TTCategoryBadgeNumberManager.h"
#import "TTIndicatorView.h"
//#import "TTForumPostThreadStatusViewModel.h"
#import "TTSettingsManager.h"
#import "TTRelevantDurationTracker.h"
#import <TTMonitor.h>
#import "Bubble-Swift.h"

@interface MyCollectionView : UICollectionView

@end

@implementation MyCollectionView

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    [super setContentOffset:contentOffset
                   animated:animated];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (CGPoint)contentOffset {
    return [super contentOffset];
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
}

@end

@interface TTFeedCollectionViewController ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate,
TTFeedCollectionCellDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, copy, readwrite) NSString *name;
@property(nonatomic) NSInteger targetIndex; //目标切换频道
@property(nonatomic, readwrite) NSInteger currentIndex;//当前频道索引
@property(nonatomic) BOOL userDrag; //用户滑动切换频道
@property(nonatomic) BOOL userClick; //用户点击频道栏切换频道
@property(nonatomic) BOOL isDisplay; //是否正在显示
@property(nonatomic) BOOL firstLoad; //首次加载

@property(nonatomic) CGFloat topInset;
@property(nonatomic) CGFloat bottomInset;

@property(nonatomic, strong) TTFeedRefreshView *refreshView; //iPad 上的刷新按钮
@property(nonatomic, copy) NSString *lastCategoryID; //记录当前显示的频道ID
@property(nonatomic, assign) BOOL isAutoLocateUserLastSelectCategory; //是否是自动定位到用户上次选择的频道

@end

@implementation TTFeedCollectionViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithName:(NSString *)name topInset:(CGFloat)topInset bottomInset:(CGFloat)bottomInset
{
    self = [super init];
    if (self) {
        self.name = name;
        self.topInset = topInset;
        self.bottomInset = bottomInset;
        self.firstLoad = YES;
        
//        [[TTFeedMixedListService sharedInstance] setDefaultConsumer:[[TTFeedDataDefaultConsumer alloc] init]];
        //注册混排列表cell
//        [ExploreCellHelper registerCellBridge];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];

    // 刷新按钮
    [self.view addSubview:self.refreshView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshButtonSettingEnabledNotification:) name:kFeedRefreshButtonSettingEnabledNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
//    [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@", change);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self adjustToolViewsAppearance];
    
    if (!_firstLoad) {
        [self.currentCollectionPageCell willAppear];
    }
    
    self.isDisplay = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.currentCollectionPageCell willDisappear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UICollectionViewCell<TTFeedCollectionCell> *cell = self.currentCollectionPageCell;
    
    // 首次加载时在 VC 的 viewWillAppear 里获取当前 cell 返回空，所以做特殊处理放到 viewDidAppear 里
    if (_firstLoad) {
        [cell willAppear];
    }
    
    [self enterCategory:self.currentCategory isFlip:NO];
    [cell didAppear];
    
    // 记录切换频道前的频道id
    self.lastCategoryID = self.currentCategory.categoryID;
     
    // 首次加载时频道是默认选择的，不是通过滑动或点击，走不到 scrollViewDidEndDecelerating:方法，所以做特殊处理
    if (_firstLoad) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell refreshIfNeeded];
        });
        _firstLoad = NO;
    }
    
    [[TTLocationManager sharedManager] processLocationCommandIfNeeded];
    // 返回feed发送关联时长
    [[TTRelevantDurationTracker sharedTracker] sendRelevantDuration];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self leaveCategory:self.currentCategory];
    [self.currentCollectionPageCell didDisappear];
    
    self.isDisplay = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        [self relayoutPages];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeInset = self.view.safeAreaInsets;
        if (safeInset.top > self.topInset){
            self.topInset = safeInset.top;
            self.bottomInset = safeInset.bottom;
        }
    }

    [_refreshView resetFrameWithSuperviewFrame:self.view.frame bottomInset:_bottomInset];
//    self.collectionView.frame = CGRectMake(0, self.topInset, self.view.width, self.view.height - self.topInset);
}

- (void)themeChanged:(NSNotification*)notification {
    if (_collectionView) {
        _collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pageCategories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTFeedCollectionCell *cell = nil;
    
    if (indexPath.item < self.pageCategories.count) {
        TTCategory *category = self.pageCategories[indexPath.item];
        Class<TTFeedCollectionCell> cellClass = [[TTFeedCollectionCellService sharedInstance] cellClassFromFeedCategory:category];
        
        if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue]) {
            // 启动优化：不加载推荐左侧固定频道数据
            if (self.firstLoad && indexPath.item < self.currentIndex) {
                return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TTFeedCollectionCell class]) forIndexPath:indexPath];
            }
        }
        
        NSString *reuseIdentifier = NSStringFromClass(cellClass);
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        cell.delegate = self;
        
        if ([cell respondsToSelector:@selector(setSourceViewController:)]) {
            [cell setSourceViewController:self];
        }
        if ([cell respondsToSelector:@selector(setupCellModel:isDisplay:)]) {
            [cell setupCellModel:category isDisplay:(_currentIndex == indexPath.item)];
        } 
        
        if (_currentIndex == indexPath.item && self.isDisplay) {
    //        LOGD(@"~~~cellForROW appear %@", category.categoryID);
    //        if ([cell respondsToSelector:@selector(willAppear)]) {
    //            [cell willAppear];
    //        }
    //        
    //        [self enterCategory:category];
    //        
    //        if ([cell respondsToSelector:@selector(didAppear)]) {
    //            [cell didAppear];
    //        }
            
            [self adjustToolViewsAppearance:cell];
        }
    }
    return cell != nil ? cell : [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TTFeedCollectionCell class]) forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 只处理点击切换或拖动切换频道的情况
    if ((_userDrag && ![self.lastCategoryID isEqualToString:self.currentCategory.categoryID]) || _userClick) {
        if ([[cell class] conformsToProtocol:@protocol(TTFeedCollectionCell)]) {
            id<TTFeedCollectionCell> collectionCell = (id<TTFeedCollectionCell>)cell;
        
            if ([collectionCell respondsToSelector:@selector(willDisappear)]) {
                [collectionCell willDisappear];
            }
            
            TTCategory *category = [self categoryAtIndex:indexPath.item];
            [self leaveCategory:category];
            
            if ([collectionCell respondsToSelector:@selector(didDisappear)]) {
                [collectionCell didDisappear];
            }
        }
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _userDrag = YES;
    
    if ([self.delegate respondsToSelector:@selector(ttFeedCollectionViewControllerWillBeginDragging:)]) {
        [self.delegate ttFeedCollectionViewControllerWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.targetIndex = (*targetContentOffset).x / self.collectionView.frame.size.width;
    
    if ([self.delegate respondsToSelector:@selector(ttFeedCollectionViewController:willScrollToIndex:)]) {
        [self.delegate ttFeedCollectionViewController:self willScrollToIndex:self.targetIndex];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.currentIndex < 0 || self.currentIndex >= self.pageCategories.count) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(ttFeedCollectionViewController:scrollFromIndex:toIndex:completePercent:)]) {
        
        CGFloat percent = [self scrollPercent:scrollView];
        
        NSInteger fromIndex = self.currentIndex;
        if (percent >= 0.5) {
            fromIndex = self.currentIndex + 1;
            percent -= 1;
        } else if (percent <= -0.5) {
            fromIndex = self.currentIndex - 1;
            percent += 1;
        }
        
        if (fromIndex >= 0 && fromIndex < self.pageCategories.count) {
            _currentIndex = fromIndex;
        }
        
        NSInteger toIndex = percent > 0 ? fromIndex + 1 : fromIndex - 1;
        
        [self.delegate ttFeedCollectionViewController:self scrollFromIndex:fromIndex toIndex:toIndex completePercent:percent];
        
        [self adjustToolViewsWhenListCellMovedFromIndex:fromIndex toIndex:toIndex percent:percent];
    }
}

- (void)currentPageCellAppear:(BOOL)flip
{
    id<TTFeedCollectionCell> cell = [self pageCellAtIndex:_currentIndex];
    
    if ([cell respondsToSelector:@selector(willAppear)]) {
        [cell willAppear];
    }
    
    [self enterCategory:self.currentCategory isFlip:flip];
    
    if ([cell respondsToSelector:@selector(didAppear)]) {
        [cell didAppear];
    }
    
    [cell refreshIfNeeded];
    
    // 切换频道时停止视频播放
    [ExploreMovieView removeAllExploreMovieView];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    BOOL userDrag = _userDrag;
    
    TTCategory *category = self.currentCategory;
    
    if (!category) {
        _userDrag = NO;
        _userClick = NO;
        return;
    }
    
    if ((userDrag && ![self.lastCategoryID isEqualToString:category.categoryID]) || _userClick) {
        if ([self.delegate respondsToSelector:@selector(ttFeedCollectionViewController:didScrollToIndex:)]) {
            [self.delegate ttFeedCollectionViewController:self didScrollToIndex:self.currentIndex];
        }

        LOGD(@"~~~didEndDecelerating appear %@", self.pageCategories[_currentIndex].categoryID);
        [self currentPageCellAppear:userDrag];
        
        if (![self.lastCategoryID isEqualToString:category.categoryID]) {
            
            if (NO == self.isAutoLocateUserLastSelectCategory) {
                if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                    // 统计 - 进入推荐列表
                    if ([category.categoryID isEqualToString:kTTMainCategoryID]) {
                        wrapperTrackEvent(@"new_tab", userDrag ? @"enter_flip" : @"enter_click");
                    }
                    // 进非推荐列表
                    else {
                        NSString *label = [NSString stringWithFormat:@"%@_%@", userDrag ? @"enter_flip" : @"enter_click", category.categoryID];
                        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
                        [extraDict setValue:category.concernID forKey:@"concern_id"];
                        [extraDict setValue:@(1) forKey:@"refer"];
                        wrapperTrackEventWithCustomKeys(@"category", label, nil, nil, extraDict);
                    }
                }
            }
            
            //log3.0
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
            [dict setValue:category.categoryID forKey:@"category_name"];
            [dict setValue:@"house_app2c_v2" forKey:@"event_type"];
            [dict setValue:userDrag?@"flip":@"click" forKey:@"enter_type"];
            [TTTracker eventV3:@"enter_category" params:dict isDoubleSending:NO];
            
            if ([category.categoryID isEqualToString:@"f_find_house"])
            {
                [dict setValue:@"maintab_list" forKey:@"element_from"];
                [dict setValue:@"maintab" forKey:@"enter_from"];
                
                NSDictionary *homeParams = [[EnvContext shared] homePageParamsMap];
                
                NSString * searchId = homeParams[@"origin_search_id"];
                NSString * categoryName = homeParams[@"origin_from"];

                [dict setValue:categoryName forKey:@"origin_from"];
                [dict setValue:searchId forKey:@"search_id"];
                [dict setValue:searchId forKey:@"origin_search_id"];
                [dict setValue:categoryName forKey:@"category_name"];

                [TTTracker eventV3:@"enter_category" params:dict isDoubleSending:NO];
            }
//            NSDictionary *dict =  [[EnvContext shared] homePageParams].paramsGetter([:])
            
            // 统计 - 进入订阅列表
            if ([category.categoryID isEqualToString:kTTSubscribeCategoryID]) {
                NSString *label = nil;
                BOOL hasTip = [ExploreSubscribeDataListManager shareManager].hasNewUpdatesIndicator;
                
                if (userDrag) {
                    if (hasTip) {
                        label = @"enter_flip_tip";
                    } else {
                        label = @"enter_flip";
                    }
                } else {
                    if (hasTip) {
                        label = @"enter_click_tip";
                    } else {
                        label = @"enter_click";
                    }
                }
                
                wrapperTrackEvent(@"subscription", label);
            }
            else if ([category.categoryID isEqualToString:kTTNewsLocalCategoryID]) {
                [[TTAuthorizeManager sharedManager].locationObj showAlertAtLocalCategory:^{} authCompleteBlock:^(TTAuthorizeLocationArrayParamBlock arrayParamBlock) {
                   [[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:arrayParamBlock];
                } sysAuthFlag:0];
            }
        }
        
        // 统计 - 进入关注列表
        if ([category.categoryID isEqualToString:kTTFollowCategoryID]) {
            
            BOOL withNumber = [[TTCategoryBadgeNumberManager sharedManager] badgeNumberOfCategoryID:kTTFollowCategoryID] > 0;
            BOOL withRedDot = [[TTCategoryBadgeNumberManager sharedManager] hasNotifyPointOfCategoryID:kTTFollowCategoryID];
            
            NSString * actionType = nil;
//            if ([TTForumPostThreadStatusViewModel sharedInstance_tt].isEnterFollowPageFromPostNotification) {
//                actionType = @"after_post_auto";
//                [TTForumPostThreadStatusViewModel sharedInstance_tt].isEnterFollowPageFromPostNotification = NO;
//
//                [TTTrackerWrapper eventV3:@"enter_follow_channel"
//                                   params:@{@"action_type":actionType, @"with_number":@(withNumber), @"with_red_dot":@(withRedDot), @"category_name":category.categoryID, @"from":@"top_channel"}];
//            }
//            else {
                if (userDrag) {
                    actionType = @"flip";
                }else {
                    actionType = @"click";
                }
                
                [TTTrackerWrapper eventV3:@"enter_follow_channel"
                                   params:@{@"action_type":actionType, @"with_number":@(withNumber), @"with_red_dot":@(withRedDot), @"category_name":category.categoryID}];
//            }
        }
        
        [self adjustToolViewsAppearance];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //collection view的didEndDisplayingCell方法和scrollViewDidEndDecelerating方法的调用先后循序是不确定的（和手势速度有关）
        //dispatch到下个runloop，确保lastCategoryID、userDrag和userClick的修改是在collection view的didEndDisplayingCell方法调用之后
        //保证了didEndDisplayingCell使用到lastCategoryID、userDrag和userClick的时候，是正确的值，保证了didEndDisplayingCell中cell的
        //willDisappear和didDisappear能够正确调用
        self.lastCategoryID = category.categoryID;
        _userDrag = NO;
        _userClick = NO;
    });
    
    if (self.isAutoLocateUserLastSelectCategory) {
        self.isAutoLocateUserLastSelectCategory = NO;
    }
}

#pragma mark -

- (CGFloat)scrollPercent:(UIScrollView *)scrollView
{
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
    
    CGSize pageSize = self.collectionView.frame.size;
    CGFloat percent = 0.0f;
    
    if (pageSize.width > 0) {
        percent = (scrollView.contentOffset.x - attributes.frame.origin.x) / pageSize.width;
    }
    return percent;
}

- (void)relayoutPages
{
    _collectionView.frame = CGRectMake(0, self.topInset, self.view.width, self.view.height - self.topInset);

    [self.collectionView.collectionViewLayout invalidateLayout];
    
    if (self.pageCategories.count > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (UICollectionViewCell<TTFeedCollectionCell> *)currentCollectionPageCell
{
    return (UICollectionViewCell<TTFeedCollectionCell> *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
}

- (UICollectionViewCell<TTFeedCollectionCell> *)pageCellAtIndex:(NSInteger)index
{
    return (UICollectionViewCell<TTFeedCollectionCell> *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

#pragma mark - Accessors

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        CGRect frame = CGRectMake(0, self.topInset, self.view.width, self.view.height - self.topInset);
        _collectionView = [[MyCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        //if ([_collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            //_collectionView.prefetchingEnabled = NO; // 打开prefetching时，cellForRow方法不是每次都会调用，导致willAppear生命周期方法逻辑不好实现，另外由于cellWillDisplay方法不支持iOS7，所以willAppear写在了cellForRow方法中
        //}
        
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        _collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        
        // 设置默认CellHelper类
        [[TTFeedCollectionCellService sharedInstance] setDefaultFeedCollectionCellHelperClass:[TTFeedCollectionCellDefaultHelper class]];
        
        // Register cell classes
        [[TTFeedCollectionCellService sharedInstance] enumerateCellClassUsingBlock:^(Class<TTFeedCollectionCell>  _Nonnull __unsafe_unretained cellClass) {
            if ([(Class)cellClass isSubclassOfClass:[UICollectionViewCell class]]) {
                [_collectionView registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
            }
        }];
        
        [_collectionView registerClass:[TTFeedCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([TTFeedCollectionCell class])];
        
        [self.view addSubview:_collectionView];
        
        [self.view bringSubviewToFront:self.refreshView];
        
//        _collectionView.frame = CGRectMake(0, self.topInset, self.view.width, self.view.height - self.topInset);
        //解决视频列表横屏播放，返回偏移问题
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(self.topInset - self.view.frame.origin.y);
            make.left.right.bottom.equalTo(self.view);
        }];

    }
    return _collectionView;
}

- (void)setPageCategories:(NSArray *)pageCategories
{
    BOOL needReload = NO;
    BOOL isFirstSet = _pageCategories == nil?YES:NO;
    TTCategory *originalCategory = (TTCategory *)[self currentCategory];
    
    if (!_pageCategories && pageCategories.count > 0) {
        needReload = YES;
    }
    else {
        if (_pageCategories.count != pageCategories.count) {
            needReload = YES;
        }
        else {
            for (int i=0; i<pageCategories.count; ++i) {
                if (![_pageCategories[i] isEqual:pageCategories[i]]) {
                    needReload = YES;
                    break;
                }
            }
        }
    }
    
    _pageCategories = [pageCategories copy];
    
    if (needReload) {
        NSUInteger index = 0;
//        if ([NewsListLogicManager needShowFixationCategory]) {
//            index = 1;
//        }
        
        TTCategory * changedToCategory = [[TTArticleCategoryManager sharedManager] lastAddedCategory];
        if (!changedToCategory && originalCategory) {
            changedToCategory = originalCategory;
        }
        
        NSString *startCategory = nil;
        if (changedToCategory) {
            index = [_pageCategories indexOfObject:changedToCategory];
            if (index != NSNotFound) {
                index = MAX(0, index);
                index = MIN(index, [_pageCategories count] - 1);
            } else {
                if (_currentIndex >= _pageCategories.count) {
                    _currentIndex = _pageCategories.count - 1;
                }
                index = _currentIndex;
            }
        }else if (isFirstSet) {
            index = MAX(0, [TTArticleCategoryManager sharedManager].preFixedCategories.count);
            index = MIN(index, [_pageCategories count] - 1);
            
//            NSInteger type = [SSCommonLogic firstCategoryStyle];
//            if (type == 1) {
//                startCategory = [[NSUserDefaults standardUserDefaults] valueForKey:@"kLastSelectCategory"];
//                if (!startCategory) {
//                    startCategory = kNIHFindHouseCategoryID;
//                }
//            }
//            if (type == 2) {
//                startCategory = [SSCommonLogic feedStartCategory];
//                if (!startCategory) {
//                    startCategory = kNIHFindHouseCategoryID;
//                }
//            }
            
            // add by zjing 默认展示找房频道
            startCategory = [SSCommonLogic feedStartCategory];
            if (!startCategory) {
                startCategory = kNIHFindHouseCategoryID;
            }
            
            if (startCategory) {
                for (int i = 0; i < _pageCategories.count; ++i) {
                    TTCategory *cat = [_pageCategories objectAtIndex:i];
                    if ([cat.categoryID isEqualToString:startCategory]) {
                        index = i;
                    }
                }
            }
        }

        [TTArticleCategoryManager sharedManager].lastAddedCategory = nil;
        [self.collectionView reloadData];
        self.isAutoLocateUserLastSelectCategory = _currentIndex != index;
        [self setCurrentIndex:index scrollToPositionAnimated:NO];
    }
}

- (TTCategory *)currentCategory {
    if (_currentIndex < _pageCategories.count) {
        return _pageCategories[_currentIndex];
    }
    return nil;
}
                         
- (TTCategory *)categoryAtIndex:(NSInteger)index
{
    if (index >= 0 && index < _pageCategories.count) {
        return _pageCategories[index];
    }
    return nil;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if (_currentIndex != currentIndex) {
       self.userClick = YES;
        
        _currentIndex = currentIndex;
        
        [self.collectionView layoutIfNeeded];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
        
        if (indexPath) {
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            // disable UIView显示动画无效
//            [UIView setAnimationsEnabled:NO];
//            [self.collectionView performBatchUpdates:^{
//                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
//            } completion:^(BOOL finished) {
//                [UIView setAnimationsEnabled:YES];
//            }];
            
            // disable CALayer隐式动画有效，但可能有其他影响
//            [CATransaction begin];
//            [CATransaction setDisableActions:YES];
//            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
//            [CATransaction commit];
            
            // reloadData只刷新当前可见item，和reloadItemsAtIndexPaths作用一致，采用此方法
            [self.collectionView reloadData];
        }
        
        if (self.collectionView.size.width > 0) {
            NSInteger realIndex = self.collectionView.contentOffset.x / self.collectionView.size.width;
            NSInteger status = realIndex == currentIndex ? 0 : 1;
            [[TTMonitor shareManager] trackService:@"feed_collection_view_scroll_to_item"
                                            status:status
                                             extra:@{@"real_index":@(realIndex), @"current_index":@(currentIndex)}];
        }
        
        // 直接在当前runloop执行时目标cell为nil，所以加个延迟
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 主动调用scrollView的delegate方法，用于加统计
            [self scrollViewDidEndDecelerating:self.collectionView];
        });
        
        // 切换频道时停止视频播放
        [ExploreMovieView removeAllExploreMovieView];
    }
}

- (void)setCurrentIndex:(NSInteger)index scrollToPositionAnimated:(BOOL)animated
{
    [self setCurrentIndex:index];
}

#pragma mark - 频道驻留时长统计

- (void)enterCategory:(TTCategory *)category isFlip:(BOOL)flip {
    if (category) {
        NSString *enterType = flip ? @"flip" : @"click";
        [[TTCategoryStayTrackManager shareManager] startTrackForCategoryID:category.categoryID concernID:category.concernID enterType:enterType];
    }
}

- (void)leaveCategory:(TTCategory *)category {
    if (category) {
        [[TTCategoryStayTrackManager shareManager] endTrackCategory:category.categoryID];
    }
}

#pragma mark - TTFeedCollectionCellDelegate

- (void)ttFeedCollectionCellStartLoading:(id<TTFeedCollectionCell>)feedCollectionCell
{
    if ([self.delegate respondsToSelector:@selector(ttFeedCollectionViewControllerDidStartLoading:)]) {
        [self.delegate ttFeedCollectionViewControllerDidStartLoading:self];
    }
    
    if (!_refreshView.hidden && ([feedCollectionCell.categoryModel.categoryID isEqualToString:self.currentCategory.categoryID]) &&
        [self shouldAnimateRefreshViewWithScrollViewCel:feedCollectionCell]) {
        [_refreshView startLoading];
    }
}

- (void)ttFeedCollectionCellStopLoading:(id<TTFeedCollectionCell>)feedCollectionCell isPullDownRefresh:(BOOL)isPullDownRefresh
{
    if ([self.delegate respondsToSelector:@selector(ttFeedCollectionViewControllerDidFinishLoading:isUserPull:)]) {
        [self.delegate ttFeedCollectionViewControllerDidFinishLoading:self isUserPull:isPullDownRefresh];
    }
    
    if (!_refreshView.hidden && ([feedCollectionCell.categoryModel.categoryID isEqualToString:self.currentCategory.categoryID]) &&
        [self shouldAnimateRefreshViewWithScrollViewCel:feedCollectionCell]) {
        [_refreshView endLoading];
    }
}
#pragma mark -
- (TTFeedRefreshView *)refreshView
{
    if (!_refreshView) {
        _refreshView = [[TTFeedRefreshView alloc] init];
        [_refreshView.arrowBtn addTarget:self action:@selector(refreshButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshView;
}

#pragma mark - Feed Refresh View

- (void)refreshButtonPressed:(UIButton *)button
{
    [self.currentCollectionPageCell refreshDataWithType:ListDataOperationReloadFromTypeNone];
    
    NSString *currCategoryID = self.currentCategory.categoryID;
    if ([TTDeviceHelper isPadDevice]) {
        wrapperTrackEvent(@"refresh", [NSString stringWithFormat:@"category_%@", currCategoryID]);
    } else {
        if ([currCategoryID isEqualToString:kTTMainCategoryID]) {
            wrapperTrackEvent(@"new_tab", @"new_button_refresh"); // 推荐频道
        } else {
            wrapperTrackEvent(@"category", @"new_button_refresh");
        }
    }
}

- (void)handleRefreshButtonSettingEnabledNotification:(NSNotification *)notification
{
    [self.refreshView endLoading];
    [self adjustToolViewsAppearance];
}

- (void)adjustToolViewsAppearance
{
    [self adjustToolViewsAppearance:nil];
}

- (void)adjustToolViewsAppearance:(id<TTFeedCollectionCell>)feedCollectionCelll
{
    //refresh view
    self.refreshView.hidden = !([SSCommonLogic refreshButtonSettingEnabled] && [SSCommonLogic showRefreshButton]);
    
    if (!_refreshView.hidden) {
        if (!feedCollectionCelll) feedCollectionCelll = self.currentCollectionPageCell;
        
        // 订阅列表为空时不显示refreshView，添加订阅后返回订阅列表，需要及时显示refreshView
        if ([feedCollectionCelll shouldHideRefreshView]) {
            self.refreshView.alpha = 0.0f;
        } else {
            self.refreshView.alpha = self.refreshView.originAlpha;
        }
    }
    
}

- (BOOL)subscribeListIsEmpty
{
    return [self.currentCollectionPageCell IsEmptySubscribeList];
}

- (void)adjustToolViewsWhenListCellMovedFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex percent:(CGFloat)percent
{
    if (_refreshView.hidden || fromIndex >= [_pageCategories count] ||
        toIndex >= [_pageCategories count]) {
        return;
    }
    
    TTFeedListDataType fromListDataType = [(TTCategory *)[_pageCategories objectAtIndex:fromIndex] listDataType];
    TTFeedListDataType toListDataType = [(TTCategory *)[_pageCategories objectAtIndex:toIndex] listDataType];
    
    CGFloat realPercent = percent;
    TTFeedListDataType targetListDataType = TTFeedListDataTypeWeb;
    
    if ([self subscribeListIsEmpty]) {
        
        targetListDataType = TTFeedListDataTypeSubscribeEntry;
        
        if (TTFeedListDataTypeSubscribeEntry == fromListDataType) {
            realPercent = percent / 0.5;
        } else if (TTFeedListDataTypeSubscribeEntry == toListDataType) {
            realPercent = (percent - 0.5) / 0.5;
        }
    }
    
    // NSLog(@"percent : %@, realPersont : %@", @(percent), @(realPercent));
    
    if (targetListDataType != fromListDataType && targetListDataType != toListDataType) {
        _refreshView.alpha = _refreshView.originAlpha;
    } else if (targetListDataType != fromListDataType && targetListDataType == toListDataType) {
        _refreshView.alpha = (1 - realPercent) * _refreshView.originAlpha;
    } else if (targetListDataType == fromListDataType && targetListDataType != toListDataType) {
        _refreshView.alpha = realPercent * _refreshView.originAlpha;
    } else {
        _refreshView.alpha = 0;
    }
}

- (BOOL)shouldAnimateRefreshViewWithScrollViewCel:(id<TTFeedCollectionCell>)feedCollectionCelll
{
    BOOL result = [feedCollectionCelll shouldAnimateRefreshView];
    return result;
}

@end

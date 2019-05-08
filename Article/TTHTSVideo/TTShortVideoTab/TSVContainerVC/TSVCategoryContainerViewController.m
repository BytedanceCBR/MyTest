//
//  TSVCategoryContainerViewController.m
//  Article
//
//  Created by 王双华 on 2017/7/27.
//
//

#import "TSVCategoryContainerViewController.h"
#import "TTFeedCollectionHTSListCell.h"
#import "UIColor+TTThemeExtension.h"
#import "TTCategory.h"
#import "TTShortVideoStayTrackManager.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TSVPushLaunchManager.h"
#import <TSVEnterTabAutoRefreshConfig.h>

@interface TSVCategoryContainerViewController ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, copy, readwrite) NSString *name;
@property(nonatomic) NSInteger targetIndex; //目标切换频道
@property(nonatomic) NSInteger currentIndex;//当前频道索引
@property(nonatomic) BOOL userDrag; //用户滑动切换频道
@property(nonatomic) BOOL userClick; //用户点击频道栏切换频道
@property(nonatomic) BOOL isDisplay; //是否正在显示
@property(nonatomic) BOOL firstLoad; //首次加载

@property(nonatomic, strong) TTCategory *lastCategory; //记录当前显示的频道

@end

@implementation TSVCategoryContainerViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.firstLoad = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    self.lastCategory = self.currentCategory;
    
    // 首次加载时频道是默认选择的，不是通过滑动或点击，走不到 scrollViewDidEndDecelerating:方法，所以做特殊处理
    if (_firstLoad) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_tab_launch_auto_refresh_enable" defaultValue:@0 freeze:YES] boolValue] || [[TSVPushLaunchManager sharedManager] shouldAutoRefresh] || [TSVEnterTabAutoRefreshConfig shouldAutoRefreshWhenEnterTab]) {
                [[TSVPushLaunchManager sharedManager] setShouldAutoRefresh:NO];
                [cell refreshDataWithType:ListDataOperationReloadFromTypeAuto];
            } else {
                [cell refreshIfNeeded];
            }
        });
        _firstLoad = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self leaveCategory:self.currentCategory];
    [self.currentCollectionPageCell didDisappear];
    
    self.isDisplay = NO;
}

- (void)themeChanged:(NSNotification*)notification {
    if (_collectionView) {
        _collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self leaveCategory:self.currentCategory];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self enterCategory:self.currentCategory isFlip:NO];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pageCategories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTCategory *category = self.pageCategories[indexPath.item];
    
    NSString *reuseIdentifier = NSStringFromClass([TTFeedCollectionHTSListCell class]);
    TTFeedCollectionHTSListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(setupCellModel:isDisplay:)]) {
        [cell setupCellModel:category isDisplay:(_currentIndex == indexPath.item)];
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
    if ((_userDrag && ![self.lastCategory isEqual:self.currentCategory]) || _userClick) {
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
    
    if ([self.delegate respondsToSelector:@selector(tsvCategoryContainerViewControllerWillBeginDragging:)]) {
        [self.delegate tsvCategoryContainerViewControllerWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.targetIndex = (*targetContentOffset).x / self.collectionView.frame.size.width;
    
    if ([self.delegate respondsToSelector:@selector(tsvCategoryContainerViewController:willScrollToIndex:)]) {
        [self.delegate tsvCategoryContainerViewController:self willScrollToIndex:self.targetIndex];
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
    if ([self.delegate respondsToSelector:@selector(tsvCategoryContainerViewController:scrollFromIndex:toIndex:completePercent:)]) {
        
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
        
        [self.delegate tsvCategoryContainerViewController:self scrollFromIndex:fromIndex toIndex:toIndex completePercent:percent];
        
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
    
    if ((userDrag && ![self.lastCategory isEqual:category]) || _userClick) {
        if ([self.delegate respondsToSelector:@selector(tsvCategoryContainerViewController:didScrollToIndex:)]) {
            [self.delegate tsvCategoryContainerViewController:self didScrollToIndex:self.currentIndex];
        }
        
        LOGD(@"~~~didEndDecelerating appear %@", self.pageCategories[_currentIndex].categoryID);
        [self currentPageCellAppear:userDrag];
        
        if (![self.lastCategory isEqual:category]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
            [dict setValue:category.categoryID forKey:@"category_name"];
            [dict setValue:userDrag?@"flip":@"click" forKey:@"enter_type"];
            [dict setValue:@"click_category" forKey:@"enter_from"];
            [dict setValue:@"main_tab" forKey:@"list_entrance"];
            [dict setValue:@100380 forKey:@"demand_id"];
            [TTTrackerWrapper eventV3:@"enter_category" params:dict];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //collection view的didEndDisplayingCell方法和scrollViewDidEndDecelerating方法的调用先后循序是不确定的（和手势速度有关）
        //dispatch到下个runloop，确保lastCategory、userDrag和userClick的修改是在collection view的didEndDisplayingCell方法调用之后
        //保证了didEndDisplayingCell使用到lastCategory、userDrag和userClick的时候，是正确的值，保证了didEndDisplayingCell中cell的
        //willDisappear和didDisappear能够正确调用
        self.lastCategory = category;
        _userDrag = NO;
        _userClick = NO;
    });
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
        
        CGRect frame = CGRectMake(0, 0, self.view.width, self.view.height);
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
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
        
        [_collectionView registerClass:[TTFeedCollectionHTSListCell class] forCellWithReuseIdentifier:NSStringFromClass([TTFeedCollectionHTSListCell class])];
        
        [self.view addSubview:_collectionView];
        
        //        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.equalTo(self.view).offset(self.topInset - self.view.frame.origin.y);
        //            make.left.right.bottom.equalTo(self.view);
        //        }];
        
        _collectionView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    }
    return _collectionView;
}

- (void)setPageCategories:(NSArray *)pageCategories
{
    _pageCategories = [pageCategories copy];
    [self.collectionView reloadData];
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

- (void)setCurrentIndex:(NSInteger)currentIndex scrollToPositionAnimated:(BOOL)animated
{
    if (_currentIndex != currentIndex) {
        self.userClick = YES;
        
        _currentIndex = currentIndex;
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
        
        // 直接在当前runloop执行时目标cell为nil，所以加个延迟
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 主动调用scrollView的delegate方法，用于加统计
            [self scrollViewDidEndDecelerating:self.collectionView];
        });
    }
}

#pragma mark - 频道驻留时长统计

- (void)enterCategory:(TTCategory *)category isFlip:(BOOL)flip {
    if (category) {
        NSString *enterType = flip ? @"flip" : @"click";
        [[TTShortVideoStayTrackManager shareManager] startTrackForCategory:category enterType:enterType];
    }
}

- (void)leaveCategory:(TTCategory *)category {
    if (category) {
        [[TTShortVideoStayTrackManager shareManager] endTrackForCategory:category];
    }
}

@end


//
//  TTCollectionPageViewController.m
//  Article
//
//  Created by 刘廷勇 on 15/8/28.
//
//

#import "TTCollectionPageViewController.h"
#import "SSThemed.h"
#import "TTCategory.h"
#import "TTDeviceHelper.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

#pragma mark -
#pragma mark - TTCollectionPageViewController

@interface TTCollectionPageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger targetIndex;
@property (nonatomic, strong) SSThemedView *backgroundView;
@property (nonatomic, assign, readwrite) TTCategoryModelTopType tabType;
@property (nonatomic, readwrite) NSInteger currentPage;
@property (nonatomic, strong) NSArray *cellClassStringArray;

@property(nonatomic) BOOL userDrag; //用户滑动切换频道
@property(nonatomic) BOOL userClick; //用户点击频道栏切换频道
@property(nonatomic, copy) NSString *lastCategoryID; //记录当前显示的频道ID
@property(nonatomic) BOOL firstLoad; //首次加载
@property (nonatomic, strong) RACDisposable *refreshDisposable;

@end

@implementation TTCollectionPageViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithTabType:(TTCategoryModelTopType)tabType cellClass:(NSString *)classString
{
    NSAssert(classString != nil, @"classString must not be nil");
    self = [self initWithTopInset:0 bottomInset:0 fromTab:tabType cellClassArray:@[classString]];
    return self;
}

- (instancetype)initWithTabType:(TTCategoryModelTopType)tabType cellClassStringArray:(NSArray *)cellClassStringArray
{
    self = [self initWithTopInset:0 bottomInset:0 fromTab:tabType cellClassArray:cellClassStringArray];
    return self;
}

- (instancetype)initWithTopInset:(CGFloat)topInset bottomInset:(CGFloat)bottomInset fromTab:(TTCategoryModelTopType)tabType cellClassArray:(NSArray *)cellClassStringArray
{
    self = [super init];
    if (self) {
        self.topInset = topInset;
        self.bottomInset = bottomInset;
        self.tabType = tabType;
        self.cellClassStringArray = cellClassStringArray;
        self.firstLoad = YES;
        
        @weakify(self);
        self.getCellClassStringForIndexPath = ^NSString *(NSIndexPath *indexPath) {
            @strongify(self);
            return self.cellClassStringArray.firstObject;
        };
    }
    return self;
}

- (TTCategory *)currentCategory {
    if (_currentPage < _pageCategories.count) {
        return _pageCategories[_currentPage];
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.backgroundView];
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self enterCategory];
    
    // 记录切换频道前的频道id
    self.lastCategoryID = self.currentCategory.categoryID;
    // 首次加载时频道是默认选择的，不是通过滑动或点击，走不到 scrollViewDidEndDecelerating:方法，所以做特殊处理
    if (_firstLoad) {
        [self.refreshDisposable dispose];
        @weakify(self);
        self.refreshDisposable = [[[[RACObserve(self, pageCategories) ignore:nil] take:1] delay:0.01] subscribeNext:^(id x) {
            @strongify(self);
            UICollectionViewCell<TTCollectionCell> *cell = self.currentCollectionPageCell;
            // 首次加载时在 VC 的 viewWillAppear 里获取当前 cell 返回空，所以做特殊处理放到 viewDidAppear 里
            [cell willAppear];
            [cell didAppear];
            [cell refreshIfNeeded];
        }];
        _firstLoad = NO;
    } else {
        UICollectionViewCell<TTCollectionCell> *cell = self.currentCollectionPageCell;
        [cell didAppear];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self leaveCategory:self.currentCollectionPageCell];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadPages];
    });
}
    
- (UICollectionViewCell<TTCollectionCell> *)pageCellAtIndex:(NSInteger)index
{
    return (UICollectionViewCell<TTCollectionCell> *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pageCategories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = self.getCellClassStringForIndexPath(indexPath);
    UICollectionViewCell<TTCollectionCell> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    if ([cell respondsToSelector:@selector(setSourceViewController:)]) {
        cell.sourceViewController = self;
    }
    
    if ([cell respondsToSelector:@selector(setupCellModel:isDisplay:)]) {
        [cell setupCellModel:self.pageCategories[indexPath.item] isDisplay:(self.currentPage == indexPath.item)];
    }
    
    return cell!=nil ? cell : [[UICollectionViewCell alloc] init];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 只处理点击切换或拖动切换频道的情况
    if ((_userDrag && ![self.lastCategoryID isEqualToString:self.currentCategory.categoryID]) || _userClick) {
        if ([[cell class] conformsToProtocol:@protocol(TTCollectionCell)]) {
            UICollectionViewCell<TTCollectionCell> *collectionCell = (UICollectionViewCell<TTCollectionCell> *)cell;
            
            if ([collectionCell respondsToSelector:@selector(willDisappear)]) {
                [collectionCell willDisappear];
            }
            
            [self leaveCategory:collectionCell];
            
            if ([collectionCell respondsToSelector:@selector(didDisappear)]) {
                [collectionCell didDisappear];
            }
        }
    }
}

#pragma mark -
#pragma mark ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _userDrag = YES;
    if ([self.delegate respondsToSelector:@selector(pageCollectionViewWillBeginDragging:)]) {
        [self.delegate pageCollectionViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.targetIndex = (*targetContentOffset).x / self.collectionView.frame.size.width;
    
    if ([self.delegate respondsToSelector:@selector(pageViewController:willPagingToIndex:)]) {
        [self.delegate pageViewController:self willPagingToIndex:self.targetIndex];
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
    if (_userDrag && [self.delegate respondsToSelector:@selector(pageViewController:pagingFromIndex:toIndex:completePercent:)]) {
        
        CGFloat percent = [self scrollPercent:scrollView];
        
        NSInteger fromIndex = self.currentPage;
        if (percent >= 0.5) {
            fromIndex = self.currentPage + 1;
            percent -= 1;
        } else if (percent <= -0.5) {
            fromIndex = self.currentPage - 1;
            percent += 1;
        }
        
        if (fromIndex >= 0 && fromIndex < self.pageCategories.count) {
            _currentPage = fromIndex;
        }
        
        NSInteger toIndex = percent > 0 ? fromIndex + 1 : fromIndex - 1;
        
        [self.delegate pageViewController:self pagingFromIndex:fromIndex toIndex:toIndex completePercent:percent];
    }
}

- (void)currentPageCellAppear:(BOOL)flip
{
    UICollectionViewCell<TTCollectionCell> *cell = [self pageCellAtIndex:_currentPage];
    
    if ([cell respondsToSelector:@selector(willAppear)]) {
        [cell willAppear];
    }
    
    [self enterCategory];
    
    if ([cell respondsToSelector:@selector(didAppear)]) {
        [cell didAppear];
    }
    
    if ([cell respondsToSelector:@selector(refreshIfNeeded)]) {
        [cell refreshIfNeeded];
    }
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
        if ([self.delegate respondsToSelector:@selector(pageViewController:didPagingToIndex:)]) {
            [self.delegate pageViewController:self didPagingToIndex:self.currentPage];
        }
        [self currentPageCellAppear:userDrag];
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
}

#pragma mark -
#pragma mark Methods

- (CGFloat)scrollPercent:(UIScrollView *)scrollView
{
    if (self.currentPage >= [self.collectionView numberOfItemsInSection:0]) {
        return 0;
    }
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
    
    CGSize pageSize = self.collectionView.frame.size;
    CGFloat percent = 0.0f;
    
    if (pageSize.width > 0) {
        percent = (scrollView.contentOffset.x - attributes.frame.origin.x) / pageSize.width;
    }
    return percent;
}

- (void)reloadCurrentPage
{
    UICollectionViewCell<TTCollectionCell> *cell = [self currentCollectionPageCell];
    if ([cell respondsToSelector:@selector(refreshData)]) {
        [cell refreshData];
    }
}

- (void)reloadPages
{
    [self.collectionView.collectionViewLayout invalidateLayout];
    if (self.pageCategories.count > 0) {
        [self setCurrentPage:self.currentPage scrollToPositionCenteredAnimated:NO];
    }
}

- (UICollectionViewCell<TTCollectionCell> *)currentCollectionPageCell
{
    return (UICollectionViewCell<TTCollectionCell> *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
}

#pragma mark -
#pragma mark Accessors

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        if (@available(ios 11.0, *)){
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        // Register cell classes
        for (NSString *cellClassString in self.cellClassStringArray) {
            [_collectionView registerClass:NSClassFromString(cellClassString) forCellWithReuseIdentifier:cellClassString];
        }
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (SSThemedView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[SSThemedView alloc] init];
        _backgroundView.backgroundColorThemeKey = kColorBackground3;
    }
    return _backgroundView;
}

- (void)setPageCategories:(NSArray *)pageCategories
{
    if (_pageCategories != pageCategories) {
        _pageCategories = pageCategories;
        [self.collectionView reloadData];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    if (_currentPage != currentPage) {
        self.userClick = YES;
        _currentPage = currentPage;
        
        // 直接在当前runloop执行时目标cell为nil，所以加个延迟
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 主动调用scrollView的delegate方法，用于加统计
            [self scrollViewDidEndDecelerating:self.collectionView];
        });
    }
}

- (void)setCurrentPage:(NSInteger)currentPage scrollToPositionCenteredAnimated:(BOOL)animated
{
    BOOL pageChanged = _currentPage != currentPage;
    self.currentPage = currentPage;
    if (self.currentPage >= [self.collectionView numberOfItemsInSection:0]) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentPage inSection:0];
    if (indexPath) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
        if (!animated && pageChanged) {
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }
}

#pragma mark -
// 频道驻留时长统计
- (void)enterCategory {
    UICollectionViewCell<TTCollectionCell> *currentCell = [self currentCollectionPageCell];
    [currentCell enterCategory];
}

- (void)leaveCategory:(UICollectionViewCell<TTCollectionCell> *)collectionCell {
    [collectionCell leaveCategory];
}

@end

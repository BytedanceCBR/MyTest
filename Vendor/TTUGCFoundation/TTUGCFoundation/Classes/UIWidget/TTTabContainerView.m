//
//  TTTabContainerView.m
//  Article
//
//  Created by 王霖 on 15/9/30.
//
//

#import "TTTabContainerView.h"
#import "FRUIAdapter.h"
#import "TTUGCPodBridge.h"
#import "TTThemeManager.h"
#import "ForumPlugin.h"
#import "UIViewAdditions.h"

static const CGFloat kTitleFontSize = 16.f;

#pragma mark - _TTTitleCollectionViewCell

@interface _TTTitleCollectionViewCell : UICollectionViewCell

@property(nonatomic, copy)NSString *title;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, assign)BOOL isSelected;
@end

@implementation _TTTitleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponentView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_themedChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_surfaceChangeNotification:)
                                                     name:TTSurfaceChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createComponentView {
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:[FRUIAdapter tt_fontSize:kTitleFontSize]];
        _titleLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        _titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.title = nil;
    _titleLabel.text = nil;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if (_isSelected) {
        self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText4];
    }else {
        self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    }
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay && [[TTUGCPodBridge sharedInstance] surfaceResurfaceEnable]){
        if (_isSelected){
            self.titleLabel.textColor = [[TTUGCPodBridge sharedInstance] surfaceCategoryBarColor];
        }
    }
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = _title;
}

- (void)_themedChanged:(NSNotification *)notification {
    if (_isSelected) {
        self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText4];
    }else {
        self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    }
    self.titleLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay && [[TTUGCPodBridge sharedInstance] surfaceResurfaceEnable]){
        if (_isSelected){
            self.titleLabel.textColor = [[TTUGCPodBridge sharedInstance] surfaceCategoryBarColor];
        }
    }
}

- (void)_surfaceChangeNotification:(NSNotification *)notifcation
{
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay && [[TTUGCPodBridge sharedInstance] surfaceResurfaceEnable]){
        self.titleLabel.textColor = [[TTUGCPodBridge sharedInstance] surfaceCategoryBarColor];
    }
}

+ (CGFloat)cellWidthWithTitle:(NSString *)title {
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[FRUIAdapter tt_fontSize:kTitleFontSize]]}];
    return size.width;
}

@end


#pragma mark - _TTTabBar

@class _TTTabBar;

@protocol _TTTabBarDelegate <NSObject>

- (NSUInteger)currentPageIndexTabBar:(_TTTabBar *)tabbar;

@optional
- (void)tabBar:(_TTTabBar *)tabbar didSelectedAtIndex:(NSUInteger)index;

@end

@interface _TTTabBar : SSThemedView<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property(nonatomic, weak)id<_TTTabBarDelegate> delegate;
@property(nonatomic, strong)NSMutableArray <NSString*>*titles;
@property(nonatomic, strong)UICollectionView *titleCollectionView;
@property(nonatomic, strong)SSThemedView *selectedIndicatorView;
@property(nonatomic, assign)NSUInteger selectedIndex;
@end

@implementation _TTTabBar

static NSString *cellIdentifier = @"cellIdentifier";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titles = [NSMutableArray arrayWithCapacity:10];
        self.separatorAtBottom = YES;
        self.borderColorThemeKey = kColorLine1;
        self.backgroundColorThemeKey = kColorBackground4;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = [FRUIAdapter tt_padding:15];
        self.titleCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _titleCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _titleCollectionView.showsHorizontalScrollIndicator = NO;
        _titleCollectionView.showsVerticalScrollIndicator = NO;
        _titleCollectionView.scrollsToTop = NO;
        _titleCollectionView.backgroundColor = [UIColor clearColor];
        _titleCollectionView.delegate = self;
        _titleCollectionView.dataSource = self;
        [_titleCollectionView registerClass:[_TTTitleCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
        [self addSubview:_titleCollectionView];
        
        self.selectedIndicatorView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.height - 2, 32, 2)];
        _selectedIndicatorView.backgroundColorThemeKey = kColorText4;
        [_titleCollectionView addSubview:_selectedIndicatorView];
        _selectedIndicatorView.hidden = YES;
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay && [[TTUGCPodBridge sharedInstance] surfaceResurfaceEnable]){
            _selectedIndicatorView.backgroundColorThemeKey = nil;
            _selectedIndicatorView.backgroundColor = [[TTUGCPodBridge sharedInstance] surfaceCategoryBarColor];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surfaceChangeNotifacition:) name:TTSurfaceChangeNotification object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)selectIndex:(NSInteger)index animation:(BOOL)animation {
    [_titleCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:animation scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)showAndInitialIndicatorViewPosition {
    if (_titles.count == 0 || _selectedIndicatorView.hidden == NO) {
        return;
    }
    _selectedIndicatorView.hidden = NO;
    NSString *title = _titles[0];
    CGFloat titleWidth = [_TTTitleCollectionViewCell cellWidthWithTitle:title];
    _selectedIndicatorView.frame = CGRectMake([FRUIAdapter tt_padding:15], _selectedIndicatorView.frame.origin.y, titleWidth, 2);
    [_titleCollectionView performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        [self _setCellTitleSelected:0];
    }];
}

- (void)refreshIndicatorView {
    CGFloat titleWidth = [_TTTitleCollectionViewCell cellWidthWithTitle:_titles[_selectedIndex]];
    _selectedIndicatorView.frame = CGRectMake(_selectedIndicatorView.frame.origin.x, _selectedIndicatorView.frame.origin.y, titleWidth, 2);
}

- (void)_setCellTitleSelected:(NSUInteger)index
{
    NSUInteger count = [_titleCollectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i ++) {
        _TTTitleCollectionViewCell * obj = (_TTTitleCollectionViewCell *)[_titleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if ([obj isKindOfClass:[_TTTitleCollectionViewCell class]]) {
            obj.isSelected = (i == index);
        }
    }
}

- (void)scrollWithLeftIndex:(NSInteger)leftIndex rightIndex:(NSInteger)rightIndex progress:(double)progress {
    if (leftIndex == rightIndex) {
        NSString *title = _titles[leftIndex];
        CGFloat titleWidth = [_TTTitleCollectionViewCell cellWidthWithTitle:title];
        CGFloat pointX = [self getIndicatorViewPointXWithIndex:leftIndex];
        _selectedIndicatorView.frame = CGRectMake(pointX, _selectedIndicatorView.frame.origin.y, titleWidth, 2);
        [self _setCellTitleSelected:rightIndex];
    }else {
        NSString *leftTitle = _titles[leftIndex];
        CGFloat leftTitleWidth = [_TTTitleCollectionViewCell cellWidthWithTitle:leftTitle];
        CGFloat leftCenter = [self getIndicatorViewPointXWithIndex:leftIndex] + leftTitleWidth/2;
        
        NSString *rightTitle = _titles[rightIndex];
        CGFloat rightTitleWidth = [_TTTitleCollectionViewCell cellWidthWithTitle:rightTitle];
        CGFloat rightCenter = [self getIndicatorViewPointXWithIndex:rightIndex] + rightTitleWidth/2;
        
        CGFloat temporaryCenter = leftCenter + (rightCenter - leftCenter)*progress;
        CGFloat temporaryWidth = leftTitleWidth + (rightTitleWidth - leftTitleWidth)*progress;
        
        _selectedIndicatorView.frame = CGRectMake(temporaryCenter - temporaryWidth/2, _selectedIndicatorView.frame.origin.y, temporaryWidth, 2);
    }
}

- (CGFloat)getIndicatorViewPointXWithIndex:(NSInteger)index {
    UICollectionViewLayoutAttributes * attributes = [_titleCollectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    CGFloat pointX = attributes.frame.origin.x + [FRUIAdapter tt_padding:15];
    return pointX;
}


#pragma mark UICollectionViewDelegateFlowLayout & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_titles count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _TTTitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.title = _titles[indexPath.row];
    if (indexPath.row == [_delegate currentPageIndexTabBar:self]) {
        cell.isSelected = YES;
    }else {
        cell.isSelected = NO;
    }
    return cell!=nil ? cell : [[UICollectionViewCell alloc] init];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = _titles[indexPath.row];
    CGFloat width = [_TTTitleCollectionViewCell cellWidthWithTitle:title];
    CGSize itemSize = CGSizeMake(width + [FRUIAdapter tt_padding:30], collectionView.frame.size.height);
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    if (_delegate && [_delegate respondsToSelector:@selector(tabBar:didSelectedAtIndex:)]) {
        [_delegate tabBar:self didSelectedAtIndex:indexPath.row];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(_TTTitleCollectionViewCell *)cell setIsSelected:[_delegate currentPageIndexTabBar:self]==indexPath.row];
}

#pragma ThemeChange & surfaceChange

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay && [[TTUGCPodBridge sharedInstance] surfaceResurfaceEnable]){
        _selectedIndicatorView.backgroundColorThemeKey = nil;
        _selectedIndicatorView.backgroundColor = [[TTUGCPodBridge sharedInstance] surfaceCategoryBarColor];
    }
}

- (void)surfaceChangeNotifacition:(NSNotification *)notifcation
{
    if ([[TTUGCPodBridge sharedInstance] surfaceResurfaceEnable]){
        _selectedIndicatorView.backgroundColorThemeKey = nil;
        _selectedIndicatorView.backgroundColor = [[TTUGCPodBridge sharedInstance] surfaceCategoryBarColor];
    }
}

@end


#pragma mark - _TTContainerScrollView

@interface _TTContainerScrollView : UIScrollView
@end
@implementation _TTContainerScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        if (self.contentOffset.x == self.contentInset.left && [self.panGestureRecognizer velocityInView:self].x > 0) {
            return NO;
        }
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }else {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
}
@end

#pragma mark - TTTabContainerView

@interface TTTabContainerView ()<_TTTabBarDelegate, UIScrollViewDelegate>
{
    BOOL _isClickTabToScroll;
}

@property(nonatomic, strong)NSMutableArray <UIView*>*pages;

@property(nonatomic, strong)_TTTabBar *tabBar;
@property(nonatomic, assign)CGFloat tabbarHeight;
@property(nonatomic, assign)TTTabContainerViewType tabBarType;

@property(nonatomic, assign)NSUInteger pageIndex;
@property(nonatomic, strong, readwrite)_TTContainerScrollView *scrollContainerView;

@property(nonatomic, assign)BOOL firstShowIndexFinish;

@end

@implementation TTTabContainerView

- (instancetype)initWithFrame:(CGRect)frame tabBarType:(TTTabContainerViewType)tabBarType tabBarHeight:(CGFloat)height {
    self = [super initWithFrame:frame];
    if (self) {
        self.pages = [NSMutableArray arrayWithCapacity:10];
        self.tabbarHeight = height;
        self.tabBarType = tabBarType;
        self.pageIndex = 0;
        
        [self createComponentWithTabBarType:tabBarType tabBarHeight:height];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame tabBarType:TTTabContainerViewTypeNone tabBarHeight:0];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.pages = [NSMutableArray arrayWithCapacity:10];
        self.tabbarHeight = 0;
        self.tabBarType = TTTabContainerViewTypeNone;
        self.pageIndex = 0;
        
        [self createComponentWithTabBarType:TTTabContainerViewTypeNone tabBarHeight:0];
    }
    return self;
}

- (void)createComponentWithTabBarType:(TTTabContainerViewType)tabBarType tabBarHeight:(CGFloat)height {
    self.tabBar = [[_TTTabBar alloc] initWithFrame:[self frameForTabbarWithContainerType:tabBarType tabBarHeight:height]];
    _tabBar.delegate = self;
    
    if (tabBarType == TTTabContainerViewTypeTop) {
        _tabBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    }
    else if(tabBarType == TTTabContainerViewTypeNone) {
        _tabBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    }else if (tabBarType == TTTabContainerViewTypeBottom) {
        _tabBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    }
    
    [self addSubview:_tabBar];
    
    self.scrollContainerView = [[_TTContainerScrollView alloc] initWithFrame:[self frameForScrollContainerViewWithContainerType:tabBarType TabBarHeight:height]];
    _scrollContainerView.delegate = self;
    _scrollContainerView.scrollsToTop = NO;
    _scrollContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _scrollContainerView.pagingEnabled = YES;
    _scrollContainerView.showsHorizontalScrollIndicator = NO;
    _scrollContainerView.bounces = NO;
    _scrollContainerView.contentSize = _scrollContainerView.bounds.size;
    [self addSubview:_scrollContainerView];
}
- (void)addPageView:(UIView *)view title:(NSString *)title {
    if ([_pages containsObject:view] || isEmptyString(title)) {
        return;
    }
    
    CGRect frame = CGRectMake(_pages.count * self.width, 0, self.width, _scrollContainerView.frame.size.height);
    view.frame = frame;
    [_scrollContainerView addSubview:view];
    [_pages addObject:view];
    
    [_tabBar.titles addObject:title];
    [_tabBar.titleCollectionView reloadData];

    [_tabBar selectIndex:_pageIndex animation:NO];
    [_tabBar showAndInitialIndicatorViewPosition];
    
    _scrollContainerView.contentSize = CGSizeMake(_pages.count * self.width, _scrollContainerView.bounds.size.height);
}

- (void)refreshInnerFrameForScroll {
    _scrollContainerView.contentSize = CGSizeMake(_pages.count * self.width, _scrollContainerView.bounds.size.height);
    _scrollContainerView.contentOffset = CGPointMake(_pageIndex * self.width, 0);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_firstShowIndexFinish) {
        [_pages enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = CGRectMake(idx * self.width, 0, self.width, _scrollContainerView.frame.size.height);
            obj.frame = frame;
        }];
        _scrollContainerView.contentSize = CGSizeMake(_pages.count * self.width, _scrollContainerView.bounds.size.height);
        [self performBatchUpdatesAndShowIndex:_pageIndex animation:NO];
    }
}

- (void)performBatchUpdatesAndShowIndex:(NSUInteger)index animation:(BOOL)animation  {
    typeof(self) __weak weakSelf = self;
    [_tabBar.titleCollectionView performBatchUpdates:^{
        [weakSelf.tabBar.titleCollectionView reloadData];
    } completion:^(BOOL finished) {
        [weakSelf showIndex:index animation:animation];
    }];
}

- (void)showIndex:(NSUInteger)index animation:(BOOL)animation {
//    if (index == _pageIndex) {
//        return;
//    }                     //与转屏后,原地刷新逻辑冲突..@zengruihuan
    self.firstShowIndexFinish = YES;
    [_scrollContainerView setContentOffset:CGPointMake(index * self.width, 0) animated:animation];
}

- (UIView *)pageAtIndex:(NSUInteger)index {
    if (index >= [_pages count]) {
        return nil;
    }
    return [_pages objectAtIndex:index];
}

- (NSString *)titleAtIndex:(NSUInteger)index {
    if (index >= _tabBar.titles.count) {
        return nil;
    }
    return [_tabBar.titles objectAtIndex:index];
}

- (CGRect)frameForTabbarWithContainerType:(TTTabContainerViewType)type tabBarHeight:(CGFloat)height
{
    if (type == TTTabContainerViewTypeNone) {
        return CGRectZero;
    }
    CGRect frame = CGRectMake(0, 0, self.width, height);
    if (type == TTTabContainerViewTypeBottom) {
        frame.origin.y = self.height - height;
    }
    return frame;
}

- (CGRect)frameForScrollContainerViewWithContainerType:(TTTabContainerViewType)type TabBarHeight:(CGFloat)height
{
    CGRect frame = CGRectMake(0, 0, self.width, self.height - height);
    if (type == TTTabContainerViewTypeNone) {
        frame = self.bounds;
    }
    else if (type == TTTabContainerViewTypeTop) {
        frame.origin.y = height;
    }
    return frame;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    double rate = contentOffset.x / self.width;
    NSInteger targetPage = (NSInteger)rate;
    
    if (targetPage*self.width == contentOffset.x) {
        if (self.pageIndex != targetPage) {
            NSUInteger fromPage = _pageIndex;
            self.pageIndex = targetPage;
            self.tabBar.selectedIndex = targetPage;
            [_tabBar selectIndex:targetPage animation:YES];
            if ([_delegate respondsToSelector:@selector(tabContainerView:didFromIndex:toIndex:isClickTabToScroll:)]) {
                [_delegate tabContainerView:self didFromIndex:fromPage toIndex:targetPage isClickTabToScroll:_isClickTabToScroll];
                _isClickTabToScroll = NO;
            }
        }
    }
    
    //左边页面
    NSInteger leftPage;
    //右边页面
    NSInteger rightPage;
    if (scrollView.contentOffset.x <= 0) {
        leftPage = 0;
        rightPage = 0;
    }else if (scrollView.contentOffset.x >= (self.width * (_pages.count -1))) {
        leftPage = _pages.count -1;
        rightPage = _pages.count -1;
    }else {
        leftPage = (NSInteger)rate;
        rightPage = leftPage == rate?leftPage:leftPage + 1;
    }
    [_tabBar scrollWithLeftIndex:leftPage rightIndex:rightPage progress:fabs(rate - (NSInteger)rate)];
    if ([_delegate respondsToSelector:@selector(scrollWithLeftIndex:rightIndex:progress:)]) {
        [_delegate scrollWithLeftIndex:leftPage rightIndex:rightPage progress:fabs(rate - (NSInteger)rate)];
    }
}

#pragma mark _TTTabBarDelegate

- (NSUInteger)currentPageIndexTabBar:(_TTTabBar *)tabbar {
    return _pageIndex;
}

- (void)tabBar:(_TTTabBar *)tabbar didSelectedAtIndex:(NSUInteger)index {
    _isClickTabToScroll = YES;
    [self showIndex:index animation:YES];
}
@end

//
//  TTHorizontalScrollView.m
//  Article
//
//  Created by Zhang Leonardo on 16-6-25.
//
//

#import "TTHorizontalScrollView.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"


#define reuseCellsMinVolumn 3
#define reuseCellsMaxVolumn 7

#define kBgViewTagKey 999

@interface TTHorizenCellScrollView : UIScrollView
@end

@implementation TTHorizenCellScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end


@interface TTHorizontalScrollView()<UIScrollViewDelegate>
{
    NSUInteger _beginDraggingIndex;
}

@property(nonatomic, assign)NSUInteger totalNumberOfCells;
@property(nonatomic, assign)NSUInteger totalNumberOfCaches;
@property(nonatomic, assign)BOOL scrollByDrag;
@property (nonatomic ,assign)BOOL didAppeared;

//value为NSMutableSet
@property(nonatomic, retain)NSMutableDictionary * reuseCells;
@property(nonatomic, retain)NSMutableSet * visibleCells;
@property(nonatomic, assign)NSUInteger lastCurrentIndex;//上一次的显示index
@property(nonatomic, assign)NSInteger currentIndex;

@property(nonatomic, retain)TTHorizontalScrollViewCell * lastCurrentCell;

@property(nonatomic, assign)BOOL isCodeInvokeScroll;//是否是用户手滑的滚动， 还是代码调用的滚动

@end

@implementation TTHorizontalScrollView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.cellBackgroundImage = nil;
    [self removeCellDelegates];
    self.visibleCells = nil;
    self.reuseCells = nil;
    self.ttDataSource = nil;
    self.ttDelegate = nil;
    _contentScrollView.delegate = nil;
    self.contentScrollView = nil;
    self.lastCurrentCell = nil;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if (_currentIndex != currentIndex) {
        NSString * flipDirection = @"right";
        if (currentIndex < _currentIndex) {
            flipDirection = @"left";
        }
        _currentIndex = currentIndex;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lastCurrentIndex = 0;
        self.totalNumberOfCells = 0;
        self.totalNumberOfCaches = 0;
        self.visibleCells = [NSMutableSet setWithCapacity:10];
        self.reuseCells = [NSMutableDictionary dictionaryWithCapacity:10];
        
        self.contentScrollView = [[TTHorizenCellScrollView alloc] initWithFrame:self.bounds];
        _contentScrollView.delegate = self;
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.scrollsToTop = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.scrollEnabled = YES;
        _contentScrollView.bounces = NO;
        _contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_contentScrollView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(splashViewDisappeared) name:@"kSplashViewDisappearAnimationDidFinished" object:nil];
    }
    return self;
}

- (void)removeCellDelegates
{
    for (UIView * view in _visibleCells) {
        if ([view isKindOfClass:[TTHorizontalScrollViewCell class]]) {
            ((TTHorizontalScrollViewCell *)view).delegate = nil;
        }
    }
    
    for (NSString * key in _reuseCells.allKeys) {
        for (id v in [_reuseCells objectForKey:key]) {
            if ([v isKindOfClass:[TTHorizontalScrollViewCell class]]) {
                ((TTHorizontalScrollViewCell *)v).delegate = nil;
            }
        }
    }

}

- (void)reloadData
{
    [self reloadDataAtIndex:0];
}

- (void)reloadDataAtIndex:(NSUInteger)index
{
    if (!_ttDataSource || ![_ttDataSource respondsToSelector:@selector(numberOfCellsForHorizenScrollView:)]) {
        return;
    }
    self.isCodeInvokeScroll = YES;
    
    _lastCurrentIndex = index;
    _totalNumberOfCells = [_ttDataSource numberOfCellsForHorizenScrollView:self];
    CGFloat contentSizeWidth = _totalNumberOfCells * [self widthForCell];
    [self setScrollViewContentSize:CGSizeMake(contentSizeWidth, [self heightForCell])];
    
    [self numberOfCachCells];
    
    [self scrollToIndex:index animated:NO reloadCellImmediatelyIfNoNaimated:NO];
    
    [self reloadCells:YES];
    
    [self notifyCurrentDisplayIndexWhenEndDecelerating:index];

    [[self currentDisplayCell] isCurrentDisplayWhenEndDecelerating:YES];
    
    self.lastCurrentCell = [self currentDisplayCell];
}

- (void)splashViewDisappeared
{
    [self performSelector:@selector(loadCellsNearby) withObject:nil afterDelay:0.1];
}

- (void)setScrollViewContentSize:(CGSize)contentSize
{
    _contentScrollView.contentSize = contentSize;
}

- (void)setCellBackgroundImage:(UIImage *)cellBackgroundImage
{
     _cellBackgroundImage = cellBackgroundImage;
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier suggestIndex:(NSInteger)suggestIndex
{
    TTHorizontalScrollViewCell * cell;
    
    for (TTHorizontalScrollViewCell * suggestCell in [[_reuseCells objectForKey:identifier] allObjects]) {
        if (suggestCell.index == suggestIndex) {
            cell = suggestCell;
        }
    }
    if (!cell) {
        cell = [[_reuseCells objectForKey:identifier] anyObject];
    }
    if (cell != nil) {
        if (![_visibleCells containsObject:cell]) {
            [_visibleCells addObject:cell];
        }
        [[_reuseCells objectForKey:identifier] removeObject:cell];
    }
    return cell;
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    TTHorizontalScrollViewCell * cell = [[_reuseCells objectForKey:identifier] anyObject];
    if (cell != nil) {
        if (![_visibleCells containsObject:cell]) {
            [_visibleCells addObject:cell];
        }
        [[_reuseCells objectForKey:identifier] removeObject:cell];
    }
    return cell;
}

- (TTHorizontalScrollViewCell *)currentDisplayCell
{
    for (UIView * view in _visibleCells) {
        if ([view isKindOfClass:[TTHorizontalScrollViewCell class]]) {
            if (((TTHorizontalScrollViewCell *)view).index == [self currentCellIndex]) {
                return ((TTHorizontalScrollViewCell *)view);
            }
        }
    }
    return nil;
}

- (TTHorizontalScrollViewCell *)cellAtIndex:(NSInteger)index
{
    for (UIView * view in _visibleCells) {
        if ([view isKindOfClass:[TTHorizontalScrollViewCell class]]) {
            if (((TTHorizontalScrollViewCell *)view).index == index) {
                return ((TTHorizontalScrollViewCell *)view);
            }
        }
    }
    return nil;
}

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated
{
    _scrollByDrag = NO;
    _isCodeInvokeScroll = YES;
    [self scrollToIndex:index animated:animated reloadCellImmediatelyIfNoNaimated:YES];
}

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated reloadCellImmediatelyIfNoNaimated:(BOOL)immediate
{
    _scrollByDrag = NO;
    _isCodeInvokeScroll = YES;
    if ([self widthForCell] == 0 ||  _totalNumberOfCells <= index) {
        return;
    }
    
    if([_ttDelegate respondsToSelector:@selector(horizenScrollView:willDisplayCellsFromIndex:isUserFlipScroll:)])
    {
        [_ttDelegate horizenScrollView:self willDisplayCellsFromIndex:[self currentCellIndex] isUserFlipScroll:@(!_isCodeInvokeScroll)];
    }
    
    if (!_contentScrollView.isDecelerating) {
        CGRect rect = CGRectMake(index * [self widthForCell], 0, [self widthForCell], [self heightForCell]);
        [_contentScrollView scrollRectToVisible:rect animated:animated];
    }
    
    if (!animated && immediate) {
        [self scrollViewEndScroll];
    }
    
}

#pragma mark -- private

- (void)notifyCurrentDisplayIndexWhenEndDecelerating:(NSUInteger)index
{
    if (index >= _totalNumberOfCells) {
        return;
    }
    
    if (_ttDelegate && [_ttDelegate respondsToSelector:@selector(horizenScrollView:didDisplayCellsForIndex:isUserFlipScroll:)]) {
        [_ttDelegate horizenScrollView:self didDisplayCellsForIndex:index isUserFlipScroll:[NSNumber numberWithBool:(!_isCodeInvokeScroll)]];
        
    }

    _isCodeInvokeScroll = NO;
}

- (void)notifyVisibleCellsBeginDragging
{
    for (UIView * view in _visibleCells) {
        if ([view isKindOfClass:[TTHorizontalScrollViewCell class]]) {
            [((TTHorizontalScrollViewCell *)view) parentViewWillBeginDragging];
        }
    }
    
    for (NSString * key in _reuseCells.allKeys) {
        for (id v in [_reuseCells objectForKey:key]) {
            if ([v isKindOfClass:[TTHorizontalScrollViewCell class]]) {
                [((TTHorizontalScrollViewCell *)v) parentViewWillBeginDragging];
            }
        }
    }
}

- (TTHorizontalScrollViewCell *)reloadCellAtIndex:(NSUInteger)index
{
    if (![self cellNeedShowForIndex:index]) {
        return nil;
    }
    
    if (![self contentScrollViewContainCellForIndex:index] && _ttDataSource && [_ttDataSource respondsToSelector:@selector(horizenScrollView:cellAtIndex:)]) {
        TTHorizontalScrollViewCell * cell = [_ttDataSource horizenScrollView:self cellAtIndex:index];
        cell.index = index;
        
        CGRect rect = CGRectMake(index * [self widthForCell], 0, [self widthForCell], [self heightForCell]);

        cell.frame = rect;//[self frameForCellsAtIndex:index];
        
        if (![_visibleCells containsObject:cell]) {
            [_visibleCells addObject:cell];
        }
        [cell removeFromSuperview];
        [_contentScrollView addSubview:cell];
        return cell;
    }
    else if (_ttDataSource && [_ttDataSource respondsToSelector:@selector(horizenScrollView:refreshScrollCell:cellIndex:)]){
        for (UIView * view in _contentScrollView.subviews) {
            if ([view isKindOfClass:[TTHorizontalScrollViewCell class]]) {
                TTHorizontalScrollViewCell * cell = (TTHorizontalScrollViewCell *)view;
                if (cell.index == index) {
                    [_ttDataSource horizenScrollView:self refreshScrollCell:cell cellIndex:index];
                    return cell;
                }
            }
        }
    }
    return nil;
}

- (void)loadCellsNearbyWhenFirstAppear
{
    self.didAppeared = YES;
    [self loadCellsNearby];
}

- (void)loadCellsNearby {
    NSUInteger currentIndex = [self currentCellIndex];
    if ([self cellNeedShowForIndex:currentIndex - 1]) {
        TTHorizontalScrollViewCell *cell = [self reloadCellAtIndex:currentIndex - 1];
        [cell isCurrentDisplayWhenEndDecelerating:NO];
    }
    
    if ([self cellNeedShowForIndex:currentIndex + 1]) {
        TTHorizontalScrollViewCell *cell = [self reloadCellAtIndex:currentIndex + 1];
        [cell isCurrentDisplayWhenEndDecelerating:NO];
    }
}

- (void)queueReusableCells:(BOOL)forceRemoveSubview {
    for (UIView * view in _contentScrollView.subviews) {
        if ([view isKindOfClass:[TTHorizontalScrollViewCell class]]) {
            if (![self cellNeedShowForIndex:((TTHorizontalScrollViewCell *)view).index] || forceRemoveSubview) {
                [self queueReusableCell:((TTHorizontalScrollViewCell *)view) WithIdentifier:((TTHorizontalScrollViewCell *)view).reuseIdentifier];
            }
            else {
                view.frame = [self frameForCellsAtIndex:((TTHorizontalScrollViewCell *)view).index];
            }
        }
    }
}

- (void)reloadCells:(BOOL)forceRemoveSubview
{
    [self queueReusableCells:forceRemoveSubview];
    
    for (NSUInteger i = [self cellNeedShowMinIndex]; i <= [self cellNeedShowMaxIndex] && i < _totalNumberOfCells; i ++) {
    
        [self reloadCellAtIndex:i];
        
    }
    
}

- (void)reloadCells
{
    [self reloadCells:NO];
}

- (BOOL)contentScrollViewContainCellForIndex:(NSUInteger)index
{
    for (UIView * view in _contentScrollView.subviews) {
        if ([view isKindOfClass:[TTHorizontalScrollViewCell class]]) {
            if (((TTHorizontalScrollViewCell *)view).index == index) {
                return YES;
            }
        }
    }
    return NO;
}

- (CGRect)frameForCellsAtIndex:(NSUInteger)index
{
    if (![self cellNeedShowForIndex:index]) {
        return CGRectZero;
    }
    CGRect rect = CGRectMake(index * [self widthForCell], 0, [self widthForCell], [self heightForCell]);
    return rect;
}

- (BOOL)cellNeedShowForIndex:(NSUInteger)index
{
    if (index <= [self cellNeedShowMaxIndex] && index >= [self cellNeedShowMinIndex]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)cellNeedShowMaxIndex
{
    if (_totalNumberOfCells <= 1) {
        return 0;
    }
    
    NSInteger currentIndex = [self currentCellIndex];
    NSInteger sideCache = ceil(_totalNumberOfCaches / 2.0) - 1;
    NSInteger maxIndex = currentIndex + sideCache;
    maxIndex = MIN(maxIndex, _totalNumberOfCells - 1);
    maxIndex = maxIndex < 0 ? 0 : maxIndex;
    return maxIndex;
}

- (NSUInteger)cellNeedShowMinIndex
{
    if (_totalNumberOfCells <= 2) {
        return 0;
    }
    NSInteger currentIndex = [self currentCellIndex];
    NSInteger sideCache = ceil(_totalNumberOfCaches / 2.0) - 1;
    NSInteger maxIndex = 0;
    maxIndex = MAX(currentIndex - sideCache, 0);
    return maxIndex;
}


- (void)queueReusableCell:(TTHorizontalScrollViewCell *)cell WithIdentifier:(NSString *)identifier
{
    if (cell == nil) {
        return;
    }

    NSMutableSet * set = [_reuseCells objectForKey:identifier];
    if (set == nil) {
        set = [NSMutableSet setWithCapacity:10];
        [_reuseCells setObject:set forKey:identifier];
    }
    [set addObject:cell];
    
    [_visibleCells removeObject:cell];
    [cell removeFromSuperview];
}

- (NSUInteger)numberOfCells
{
    return _totalNumberOfCells;
}

- (NSUInteger)currentCellIndex
{
    if ([self widthForCell] == 0) {
        return 0;
    }
    
    NSUInteger cIndex = floor((_contentScrollView.contentOffset.x + self.width / 2) / [self widthForCell]);
    return cIndex;
}

- (CGFloat)currentMovePercentage
{
    if([self widthForCell] == 0)
    {
        return 0;
    }
    
    float result = (_contentScrollView.contentOffset.x - [self currentCellIndex] * [self widthForCell]) / [self widthForCell];
    return  2 * result;
}

//内存中一次有多少个cells加载
- (void)numberOfCachCells
{
    NSUInteger reuseSetVolume = reuseCellsMinVolumn;
    if (_ttDataSource && [_ttDataSource respondsToSelector:@selector(numberOfCellCachesForHorizenScrollView:)]) {
        NSUInteger volu = [_ttDataSource numberOfCellCachesForHorizenScrollView:self];
        if (volu < reuseCellsMinVolumn) {
            reuseSetVolume = reuseCellsMinVolumn;
        }
        else if (volu > reuseCellsMaxVolumn) {
            reuseSetVolume = reuseCellsMaxVolumn;
        }
        else {
            reuseSetVolume = volu;
        }
    }
    self.totalNumberOfCaches = reuseSetVolume;
}

- (CGFloat)widthForCell
{
    return _contentScrollView.frame.size.width;
}

- (CGFloat)heightForCell
{
    return _contentScrollView.frame.size.height;
}

- (void)scrollViewEndScroll
{
    if (_lastCurrentIndex != [self currentCellIndex]) {
    
        TTHorizontalScrollViewCell *cell = [self reloadCellAtIndex:[self currentCellIndex]];
        [cell isCurrentDisplayWhenEndDecelerating:YES];

        [self queueReusableCells:NO];
        
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadCellsNearby) object:nil];
        [self performSelector:@selector(loadCellsNearby) withObject:nil afterDelay:0.3];
        
        [self notifyCurrentDisplayIndexWhenEndDecelerating:[self currentCellIndex]];
        
        if (_ttDelegate && [_ttDelegate respondsToSelector:@selector(horizenScrollView:didEndScrollLastDisplayCellsForIndex:)]) {
            [_ttDelegate horizenScrollView:self didEndScrollLastDisplayCellsForIndex:_lastCurrentIndex];
        }
        
        self.lastCurrentCell = [self currentDisplayCell];
        _lastCurrentIndex = [self currentCellIndex];
    }
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self loadCellsNearby];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_scrollByDrag)
    {
        if(_ttDelegate && [_ttDelegate respondsToSelector:@selector(horizenScrollView:scrollViewDidScrollToIndex:)])
        {
            [_ttDelegate horizenScrollView:self scrollViewDidScrollToIndex:[self currentCellIndex]];
        }

        
        if (_ttDelegate && [_ttDelegate respondsToSelector:@selector(horizenScrollView:scrollViewDidScrollFromIndex:toIndex:percent:)]) {
            
            NSInteger toIndex = _contentScrollView.contentOffset.x > _beginDraggingIndex * [self widthForCell] ? _beginDraggingIndex +1 : _beginDraggingIndex -1;
            toIndex = MAX(0, toIndex);
            toIndex = MIN(toIndex, _totalNumberOfCells);
            
            CGFloat percent = 0;
            if ([self widthForCell] > 0) {
                percent = (float)(_contentScrollView.contentOffset.x - _beginDraggingIndex * [self widthForCell]) / (float)[self widthForCell];
            }
            percent = fabs(percent);
            
            if (percent > 0.5) {
                self.currentIndex = toIndex;
            } else {
                self.currentIndex = _beginDraggingIndex;
            }
            
            [_ttDelegate horizenScrollView:self scrollViewDidScrollFromIndex:_beginDraggingIndex toIndex:toIndex percent:percent];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewEndScroll];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollViewEndScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _beginDraggingIndex = [self currentCellIndex];
    _scrollByDrag = YES;
    _isCodeInvokeScroll = NO;
    if(_ttDelegate && [_ttDelegate respondsToSelector:@selector(horizenScrollView:willDisplayCellsFromIndex:isUserFlipScroll:)])
    {
        [_ttDelegate horizenScrollView:self willDisplayCellsFromIndex:[self currentCellIndex] isUserFlipScroll:@(!_isCodeInvokeScroll)];
    }
    
    [self notifyVisibleCellsBeginDragging];
    
    if(scrollView.decelerating) {
        [self scrollViewEndScroll];
    }
    
    [self loadCellsNearby];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _contentScrollView.frame = self.bounds;
    CGFloat contentSizeWidth = _totalNumberOfCells * [self widthForCell];
    [self setScrollViewContentSize:CGSizeMake(contentSizeWidth, [self heightForCell])];
    CGSize scrollSize = CGSizeMake(self.width, self.height);;
   
    if ([TTDeviceHelper isPadDevice]) {
        scrollSize = self.size;
    }
    else {
        //fix:iOS7下进入图集横屏连续进入相关图集触发CCTrackerClearner导致cell宽度赋值不对的问题
        scrollSize = CGSizeMake([self screenSize].width, self.height);
    }
    for (UIView * view in _visibleCells) {
        if ([view isKindOfClass:[TTHorizontalScrollViewCell class]]) {
            TTHorizontalScrollViewCell *cell = (TTHorizontalScrollViewCell *)view;
            cell.size = scrollSize;
            cell.left = cell.width * cell.index;
        }
    }
    for (UIView * view in _reuseCells) {
        if ([view isKindOfClass:[TTHorizontalScrollViewCell class]]) {
            TTHorizontalScrollViewCell *cell = (TTHorizontalScrollViewCell *)view;
            cell.size = scrollSize;
            cell.left = cell.width * cell.index;
        }
    }
    CGPoint offset = self.contentScrollView.contentOffset;
    offset.x = self.lastCurrentIndex * scrollSize.width;
    [self.contentScrollView setContentOffset:offset animated:NO];
}

- (CGSize)screenSize {
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGSize screenSize = mainScreen.bounds.size;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;
}

@end

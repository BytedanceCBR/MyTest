//
//  AKPhotoCarouselView.m
//  Article
//
//  Created by chenjiesheng on 2018/3/6.
//

#import "AKUIHelper.h"
#import "AKPhotoCarouselCellView.h"
#import "AKPhotoCarouselView.h"
#import "AKPhotoCarouselCellModel.h"

#import <NSTimer+NoRetain.h>
#import <UIColor+TTThemeExtension.h>
@interface AKPhotoCarouselView () <UIScrollViewDelegate>

@property (nonatomic, strong)UIScrollView                           *scrollView;
@property (nonatomic, copy)  NSArray<AKPhotoCarouselCellView *>     *cellViews;
@property (nonatomic, copy)  NSArray<AKPhotoCarouselCellModel *>    *cellModels;
@property (nonatomic, assign, readwrite)NSInteger                               curIndex;
@property (nonatomic, assign)NSInteger                               expetedIndex;
@property (nonatomic, assign)CGSize                                  originSize;
@property (nonatomic, strong)NSTimer                                *photoTimer;
@property (nonatomic, strong)UITapGestureRecognizer                 *tapGesture;

@property (nonatomic, strong)UIView                                 *indexViewContainerView;
@property (nonatomic, strong)NSMutableArray<UIView *>               *indexViews;
@end

@implementation AKPhotoCarouselView

- (void)dealloc
{
    [self.photoTimer invalidate];
    self.photoTimer = nil;
}

- (instancetype)initWithModels:(NSArray<AKPhotoCarouselCellModel *> *)cellModels
{
    self = [super init];
    if (self) {
        self.cellModels = cellModels;
        [self createComponent];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!CGSizeEqualToSize(self.size, self.originSize)) {
        self.scrollView.contentSize = CGSizeMake((self.cellModels.count + 2) * self.width, self.height);
        self.originSize = self.size;
        [self refreshCurIndex:_curIndex];
        self.indexViewContainerView.centerX = self.width / 2;
        self.indexViewContainerView.bottom = self.height - [TTDeviceUIUtils tt_newPadding:10.f];
    }
}

- (void)createComponent
{
    self.originSize = self.size;
    _scrollDuration = 2;
    [self createScrollView];
    [self createCellViews];
    [self refreshCurIndex:0];
    [self createTimer];
    [self createTapGesture];
    [self createIndexsViews];
}

- (void)createIndexsViews
{
    _indexViewContainerView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        view;
    });
    [self addSubview:_indexViewContainerView];
    self.indexViews = [NSMutableArray array];
    [self refreshIndexViews];
}

- (void)refreshIndexViews
{
    for (UIView *view in self.indexViews) {
        view.hidden = YES;
    }
    if (self.cellModels.count <= 1) {
        return;
    }
    CGFloat indexViewSize = 4;
    if (self.indexViews.count < self.cellModels.count) {
        NSInteger dis = self.cellModels.count - self.indexViews.count;
        for (NSInteger i = 0; i < dis; i += 1) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, indexViewSize, indexViewSize)];
            view.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
            view.clipsToBounds = YES;
            view.layer.cornerRadius = view.width / 2;
            view.hidden = NO;
            [self.indexViewContainerView addSubview:view];
            [self.indexViews addObject:view];
        }
    }
    CGFloat paddingLeftIndexView = 6;
    CGFloat left = -paddingLeftIndexView;
    for (NSInteger i = 0; i < self.cellModels.count; i += 1) {
        UIView *view = self.indexViews[i];
        left += paddingLeftIndexView;
        view.hidden = NO;
        view.origin = CGPointMake(left, 0);
        left = view.right;
    }
    self.indexViewContainerView.size = CGSizeMake(left, indexViewSize);
    self.indexViewContainerView.centerX = self.width /2 ;
    self.indexViewContainerView.bottom = self.height - [TTDeviceUIUtils tt_newPadding:10.f];
}

- (void)updateIndexViewsHilightedStatus
{
    NSInteger selectIndex = self.curIndex;
    selectIndex = MIN(self.cellModels.count - 1, MAX(0, selectIndex));
    [self.indexViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == selectIndex) {
            obj.backgroundColor = [UIColor colorWithHexString:@"EF514A"];
        } else {
            obj.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
        }
    }];
}

- (void)createTapGesture
{
    _tapGesture = ({
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        tapGesture;
    });
    [self addGestureRecognizer:_tapGesture];
}

- (void)createTimer
{
    [_photoTimer invalidate];
    _photoTimer = nil;
    
    if (self.cellModels.count <= 1) {
        return;
    }
    WeakSelf;
    NSTimer *timer = [NSTimer tt_scheduledTimerWithTimeInterval:_scrollDuration repeats:YES block:^(NSTimer *timer) {
        StrongSelf;
        [self updateCurIndex:self.curIndex + 1];
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.photoTimer = timer;
}

- (void)createScrollView
{
    _scrollView = ({
        UIScrollView *view = [[UIScrollView alloc] initWithFrame:self.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.showsVerticalScrollIndicator = NO;
        view.showsHorizontalScrollIndicator = NO;
        view.pagingEnabled = YES;
        view.delegate = self;
        view.scrollsToTop = NO;
        view;
    });
    [self addSubview:_scrollView];
}

- (void)createCellViews
{
    NSInteger needCellCount = 3;
    NSMutableArray *cellArray = [NSMutableArray arrayWithCapacity:needCellCount];
    for (NSInteger i = 0; i < needCellCount; i += 1) {
        AKPhotoCarouselCellView *cellView = [[AKPhotoCarouselCellView alloc] initWithFrame:self.bounds];
        cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cellArray addObject:cellView];
        [self.scrollView addSubview:cellView];
    }
    self.cellViews = [cellArray copy];
}

- (void)refreshCurIndex:(NSInteger)curIndex
{
    self.scrollView.scrollEnabled = self.cellModels.count > 1;
    if (!self.scrollView.scrollEnabled) {
        [self.scrollView setContentOffset:CGPointZero];
    }
    if (curIndex > self.cellModels.count) {
        return;
    }
    for (AKPhotoCarouselCellView *cellView in self.cellViews) {
        cellView.hidden = YES;
    }
    _curIndex = curIndex;
    AKPhotoCarouselCellModel *curCellModel, *preCellModel, *nextCellModel;
    curCellModel = self.cellModels[curIndex];
    
    preCellModel = self.cellModels[(curIndex - 1) >= 0 ? curIndex - 1 : self.cellModels.count - 1];
    nextCellModel = self.cellModels[(curIndex + 1) < self.cellModels.count ? curIndex + 1 : 0];
    
    AKPhotoCarouselCellView *lastCellView = nil;
    AKPhotoCarouselCellView *curCellView = nil;
    if (preCellModel) {
        AKPhotoCarouselCellView *cellView = self.cellViews[0];
        cellView.ownIndex = curIndex - 1;
        cellView.hidden = NO;
        [cellView setupContentWithModel:preCellModel];
        cellView.left = [self cellViewOriginXAtIndex:curIndex - 1];
        lastCellView = cellView;
    }
    if (curCellModel) {
        AKPhotoCarouselCellView *cellView = self.cellViews[1];
        cellView.ownIndex = curIndex;
        cellView.hidden = NO;
        [cellView setupContentWithModel:curCellModel];
        cellView.left = [self cellViewOriginXAtIndex:curIndex];
        lastCellView = cellView;
        curCellView = cellView;
    }
    if (nextCellModel) {
        AKPhotoCarouselCellView *cellView = self.cellViews[2];
        cellView.ownIndex = curIndex + 1;
        cellView.hidden = NO;
        [cellView setupContentWithModel:nextCellModel];
        cellView.left = [self cellViewOriginXAtIndex:curIndex + 1];
        lastCellView = cellView;
    }
    _scrollView.contentOffset = CGPointMake(curCellView.left, 0);
}

- (void)refreshCellModel:(NSArray<AKPhotoCarouselCellModel *> *)cellModels
{
    if (![self checkRefreshIfNeedWithCellModels:cellModels]) {
        _cellModels = cellModels;
        return;
    }
    _cellModels = cellModels;
    _curIndex = 0;
    [self refreshCurIndex:_curIndex];
    [self setScrollDuration:_scrollDuration];
    [self refreshIndexViews];
    [self updateIndexViewsHilightedStatus];
}

- (BOOL)checkRefreshIfNeedWithCellModels:(NSArray<AKPhotoCarouselCellModel *> *)cellModels
{
    __block BOOL update = NO;
    if (cellModels.count != self.cellModels.count) {
        return YES;
    }
    
    [cellModels enumerateObjectsUsingBlock:^(AKPhotoCarouselCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AKPhotoCarouselCellModel *originModel = self.cellModels[idx];
        if (![originModel.imageURL isEqualToString:obj.imageURL] || ![originModel.openURL isEqualToString:obj.openURL]) {
            update = YES;
            *stop = YES;
        }
    }];
    return update;
}

- (AKPhotoCarouselCellView *)freeCellViewAtExpectedIndex:(NSInteger)index
{
    for (AKPhotoCarouselCellView *cellView in self.cellViews) {
        if (cellView.hidden) {
            return cellView;
        }
    }
    
    NSInteger dis = index - _curIndex;
    if (labs(dis) == 1) {
        if (dis > 0) {
            return [self cellViewAtOwnIndex:_curIndex - 1];
        } else {
            return [self cellViewAtOwnIndex:_curIndex + 1];
        }
    } else if (labs(dis) < 1) {
        if (dis > 0) {
            return [self cellViewAtOwnIndex:_curIndex - 2];
        } else {
            return [self cellViewAtOwnIndex:_curIndex + 2];
        }
    }
    return nil;
}

- (AKPhotoCarouselCellView *)cellViewAtOwnIndex:(NSInteger)index
{
    for (AKPhotoCarouselCellView *cellView in self.cellViews) {
        if (cellView.ownIndex == index) {
            return cellView;
        }
    }
    return nil;
}

- (void)moveCellView:(AKPhotoCarouselCellView *)cellView toExpectedIndex:(NSInteger)toIndex
{
    if (toIndex == self.cellModels.count) {
        if (-1 != self.curIndex) {
            if ([self.delegate respondsToSelector:@selector(photoCarouselView:willScrollToIndex:)]) {
                [self.delegate photoCarouselView:self willScrollToIndex:-1];
            }
        }
        CGFloat offsetX = self.width * self.cellModels.count;
        for (AKPhotoCarouselCellView *cellView in self.cellViews) {
            if (cellView.ownIndex == self.cellModels.count - 1) {
                cellView.ownIndex = -1;
            } else if (cellView.ownIndex == self.cellModels.count) {
                cellView.ownIndex = 0;
            } else {
                cellView.hidden = YES;
            }
            cellView.left = [self cellViewOriginXAtIndex:cellView.ownIndex];
        }
        self.curIndex = -1;
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x - offsetX, self.scrollView.contentOffset.y);
        return;
    } else if (toIndex == -1) {
        if (self.cellModels.count != self.curIndex) {
            if ([self.delegate respondsToSelector:@selector(photoCarouselView:willScrollToIndex:)]) {
                [self.delegate photoCarouselView:self willScrollToIndex:self.cellModels.count];
            }
        }
        CGFloat offsetX = self.width * self.cellModels.count;
        for (AKPhotoCarouselCellView *cellView in self.cellViews) {
            if (cellView.ownIndex == -1) {
                cellView.ownIndex = self.cellModels.count - 1;
            } else if (cellView.ownIndex == 0) {
                cellView.ownIndex = self.cellModels.count;
            } else {
                cellView.hidden = YES;
            }
            cellView.left = [self cellViewOriginXAtIndex:cellView.ownIndex];
        }
        self.curIndex = self.cellModels.count;
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x + offsetX, self.scrollView.contentOffset.y);
        return;
    }
    
    if (!cellView) {
        return;
    }
    NSInteger finalIndex = toIndex;
    NSInteger dis = toIndex - _curIndex;
    if (labs(dis) == 1) {
        if (dis > 0) {
            finalIndex = _curIndex + 2;
        } else {
            finalIndex = _curIndex - 2;
        }
    } else if (labs(dis) < 1) {
        if (dis > 0) {
            finalIndex = _curIndex + 1;
        } else {
            finalIndex = _curIndex - 1;
        }
    }
    NSInteger fixIndex = finalIndex;
    if (finalIndex == self.cellModels.count) {
        fixIndex = 0;
    }
    if (finalIndex == -1) {
        fixIndex = self.cellModels.count - 1;
    }
    AKPhotoCarouselCellModel *cellModel = self.cellModels[fixIndex];
    cellView.hidden = NO;
    cellView.ownIndex = finalIndex;
    cellView.left = [self cellViewOriginXAtIndex:finalIndex];
    [cellView setupContentWithModel:cellModel];
}

- (CGFloat)cellViewOriginXAtIndex:(NSInteger)index
{
    return (index + 1) * self.width;
}

- (void)updateCurIndex:(NSInteger)newIndex
{
    CGFloat left = [self cellViewOriginXAtIndex:newIndex];
    if (left == self.scrollView.contentOffset.x) {
        [self updateCurIndex:newIndex + 1];
    } else {
        [self.scrollView setContentOffset:CGPointMake(left, self.scrollView.contentOffset.y) animated:YES];
    }
}

#pragma action

- (void)tapGestureAction:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(photoCarouselView:didSelectedAt:cellModel:)]) {
        NSInteger index = self.curIndex;
        if (index == -1) {
            index = self.cellModels.count - 1;
        } else if (index == self.cellModels.count) {
            index = 0;
        }
        AKPhotoCarouselCellModel *cellModel = self.cellModels[index];
        [self.delegate photoCarouselView:self didSelectedAt:index cellModel:cellModel];
    }
}

#pragma Setter

- (void)setScrollDuration:(NSTimeInterval)scrollDuration
{
    _scrollDuration = scrollDuration;
    [self createTimer];
}

#pragma UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.photoTimer invalidate];
    self.photoTimer = nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self createTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat originOffsetX = [self cellViewOriginXAtIndex:self.curIndex];
    CGFloat dis = offsetX - originOffsetX;
    if (fabs(dis) >= self.width / 2) {
        NSInteger expectedIndex = self.curIndex;
        //预期滑动到 curIndex + 1 或者 curIndex - 1
        if (dis > 0) {
            //curIndex + 1
            expectedIndex = self.curIndex + 1;
        } else if (dis < 0) {
            //curIndex - 1
            expectedIndex = self.curIndex - 1;
        }
        
        AKPhotoCarouselCellView *cellView = [self freeCellViewAtExpectedIndex:expectedIndex];
        [self moveCellView:cellView toExpectedIndex:expectedIndex];
        if (expectedIndex == -1) {
            expectedIndex = self.cellModels.count;
        } else if (expectedIndex == self.cellModels.count) {
            expectedIndex = -1;
        }
        if (expectedIndex != self.curIndex) {
            if ([self.delegate respondsToSelector:@selector(photoCarouselView:willScrollToIndex:)]) {
                [self.delegate photoCarouselView:self willScrollToIndex:expectedIndex];
            }
        }
        self.curIndex = expectedIndex;
        [self updateIndexViewsHilightedStatus];
    } else {
        AKPhotoCarouselCellView *cellView = [self freeCellViewAtExpectedIndex:self.curIndex];
        [self moveCellView:cellView toExpectedIndex:self.curIndex];
    }
}

@end

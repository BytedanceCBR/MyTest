//
//  FHHorizontalPagingView.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import "FHHorizontalPagingView.h"
#import "UIColor+Theme.h"
#import "UIViewAdditions.h"
#import "FHCommonDefines.h"

@implementation FHHorizontalMoveView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if([self pointInside:point withEvent:event]) {
        if(self.currentIndex >= 0 && self.currentIndex < self.tableViewArray.count) {
            UITableView *tableView = [self.tableViewArray objectAtIndex:self.currentIndex];
            if(tableView.panGestureRecognizer != self.panGestureRecognizer) {
                [self removeGestureRecognizer:self.panGestureRecognizer];
                [((UIView *)self.panGestureRecognizer.delegate) addGestureRecognizer:self.panGestureRecognizer];
                self.panGestureRecognizer = tableView.panGestureRecognizer;
                [self addGestureRecognizer:self.panGestureRecognizer];
            }
        }
    } else {
        [self removeGestureRecognizer:self.panGestureRecognizer];
        [((UIView *)self.panGestureRecognizer.delegate) addGestureRecognizer:self.panGestureRecognizer];
        self.panGestureRecognizer = nil;
    }
    return [super hitTest:point withEvent:event];
}

@end

@implementation FHHorizontalTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (@available(iOS 11.0 , *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.estimatedRowHeight = 0;
            self.estimatedSectionFooterHeight = 0;
            self.estimatedSectionHeaderHeight = 0;
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if(self) {
        if (@available(iOS 11.0 , *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.estimatedRowHeight = 0;
            self.estimatedSectionFooterHeight = 0;
            self.estimatedSectionHeaderHeight = 0;
        }
    }
    return self;
}

-(void)setContentSize:(CGSize)contentSize {
    CGFloat delta = self.minimumHeight - (self.contentInset.top + self.contentInset.bottom + contentSize.height);
    if(delta > 0) {
        contentSize.height += delta;
    }
    [super setContentSize:contentSize];
}

@end



@implementation FHHorizontalPagingView

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.scrollView.backgroundColor = [UIColor themeWhite];
    self.scrollView.scrollsToTop = NO;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.scrollView.bounces = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    self.moveView = [[FHHorizontalMoveView alloc] init];
    self.moveView.backgroundColor = [UIColor themeWhite];
}


-(void)tableViewWillBeginDragging:(UIScrollView *)scrollView {
    self.scrollView.scrollEnabled = NO;
}

-(void)tableViewDidEndDragging:(UIScrollView *)scrollView {
    self.scrollView.scrollEnabled = YES;
}

-(void)tableViewDidScroll:(UIScrollView *)scrollView {
    CGFloat holdOffset = self.headerView.height - self.navBar.bottom;
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY <= holdOffset) {
        self.moveView.top = - offsetY;
    } else {
        self.moveView.top = - holdOffset;
    }
    CGFloat offset = - self.moveView.top;
    [self.delegate contentViewDidScroll:offset];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self resetTableView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.tableViewArray.count) {
        [self.delegate contentViewDidScroll:scrollView.contentOffset.y];
        return;
    }
    CGFloat tabIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
    self.currentIndex = roundf(tabIndex);
    [self.delegate scrollToIndex:self.currentIndex];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.delegate scrollToIndex:self.currentIndex];
}

- (void)updateSelectIndex:(NSInteger)index {
    if(index >= 0 && index < self.tableViewArray.count) {
        [self resetTableView];
        self.currentIndex = index;
        [self.scrollView setContentOffset:CGPointMake(index * SCREEN_WIDTH, 0)  animated:NO];
    }
}

-(void)updateWithHeaderView:(UIView *)headerView segmentedView:(UIView *)segmentedView navBar:(UIView *)navBar tableViewArray:(NSArray<FHHorizontalTableView *> *)tableViewArray {
    self.headerView = headerView;
    self.segmentedView = segmentedView;
    self.navBar = navBar;
    self.tableViewArray = tableViewArray;
    self.moveView.tableViewArray = tableViewArray;
    self.moveView.frame = CGRectMake(0, 0, SCREEN_WIDTH, headerView.height + segmentedView.height);
    headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, headerView.height);
    segmentedView.frame = CGRectMake(0, headerView.height, SCREEN_WIDTH, segmentedView.height);
    [self.moveView addSubview:headerView];
    [self.moveView addSubview:segmentedView];
    for(NSInteger i = 0;i < tableViewArray.count ; i++) {
        FHHorizontalTableView *tableView = [tableViewArray objectAtIndex:i];
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:self.moveView.frame];
        tableView.frame = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, self.scrollView.height);
        tableView.minimumHeight = self.headerView.height - self.navBar.bottom + self.scrollView.height;
        [self.scrollView addSubview:tableView];
    }
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.contentSize = CGSizeMake(tableViewArray.count * SCREEN_WIDTH, self.scrollView.height);
    [self addSubview:self.moveView];
}

-(void)updateWithHeaderView:(UIView *)headerView navBar:(UIView *)navBar emptyView:(UIView *)emptyView{
    self.headerView = headerView;
    self.navBar = navBar;
    UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.height, SCREEN_WIDTH, self.scrollView.height - navBar.height)];
    [blankView addSubview:emptyView];
    [self.scrollView addSubview:headerView];
    [self.scrollView addSubview:blankView];
    
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, headerView.height + blankView.height);
    self.blankView = blankView;
}

- (void)resetTableView {
    if(self.currentIndex >= 0 && self.currentIndex < self.tableViewArray.count) {
        UITableView *tableView = [self.tableViewArray objectAtIndex:self.currentIndex];
        CGFloat holdOffset = self.headerView.height - self.navBar.bottom;
        CGFloat offset = - self.moveView.top;
        for(UITableView *view  in self.tableViewArray) {
            if(view != tableView) {
                if(offset < holdOffset || view.contentOffset.y < offset) {
                    [view setContentOffset:CGPointMake(0, offset) animated:NO];
                }
            }
        }
    }
}

-(void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    self.moveView.currentIndex = currentIndex;
}

@end

//
//  FHHorizontalPagingView.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHorizontalMoveView : UIView
@property(nonatomic,assign) NSInteger currentIndex;
@property(nonatomic,strong) NSArray<UITableView *> *tableViewArray;
@property(nonatomic,weak) UIPanGestureRecognizer *panGestureRecognizer;
@end

@interface FHHorizontalTableView : UITableView
@property(nonatomic,assign) CGFloat minimumHeight;
@end

@protocol FHHorizontalPagingViewDelegate <NSObject>
- (void)contentViewDidScroll:(CGFloat)offset;
- (void)scrollToIndex:(NSInteger)index;
@end

@interface FHHorizontalPagingView : UIView <UIScrollViewDelegate>
@property(nonatomic,weak) UIView *headerView;
@property(nonatomic,weak) UIView *segmentedView;
@property(nonatomic,weak) UIView *navBar;
@property(nonatomic,strong) UIView *blankView;
@property(nonatomic,strong) FHHorizontalMoveView *moveView;
@property(nonatomic,strong) NSArray<FHHorizontalTableView *> *tableViewArray;
@property(nonatomic,weak) NSObject <FHHorizontalPagingViewDelegate> *delegate;
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,assign) NSInteger currentIndex;
-(void)updateWithHeaderView:(UIView *)headerView segmentedView:(UIView *)segmentedView navBar:(UIView *)navBar tableViewArray:(NSArray<FHHorizontalTableView *> *)tableViewArray;
-(void)updateWithHeaderView:(UIView *)headerView navBar:(UIView *)navBar emptyView:(UIView *)emptyView;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
-(void)tableViewDidScroll:(UIScrollView *)scrollView;
-(void)tableViewWillBeginDragging:(UIScrollView *)scrollView;
-(void)tableViewDidEndDragging:(UIScrollView *)scrollView;
-(void)updateSelectIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END

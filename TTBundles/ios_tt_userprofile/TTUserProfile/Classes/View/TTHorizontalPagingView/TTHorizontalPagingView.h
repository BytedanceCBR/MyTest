//
//  TTHorizontalPagingView.h
//  TTHorizontalPagingViewDemo
//
//  Created by 王迪 on 17/3/12.
//  Copyright © 2017年 wangdi. All rights reserved.
//


#import "SSThemed.h"

@class TTHorizontalPagingView,TTHorizontalPagingSegmentView;
@protocol TTHorizontalPagingViewDelegate <NSObject>
@required

/**
 返回子视图的个数，reloadData的时候会调用

 @param pagingView pagingView
 @return 视图的个数
 */
- (NSInteger)numberOfSectionsInPagingView:(TTHorizontalPagingView *)pagingView;
/**
 每一页的滚动的视图，reloadData的时候会调用

 @param pagingView pagingView
 @param index 滚动到第几个视图的索引
 @return 返回当前的滚动视图
 */
- (UIScrollView *)pagingView:(TTHorizontalPagingView *)pagingView viewAtIndex:(NSInteger)index;

/**
 返回头部视图，reloadData的时候会调用

 @return 头部视图
 */
- (UIView *)viewForHeaderInPagingView;

/**
 返回头部视图的高度，reloadData的时候会调用

 @return 头部视图的高度
 */
- (CGFloat)heightForHeaderInPagingView;

/**
 返回吸顶的segmentView，reloadData的时候回调用

 @return segmentView
 */
- (TTHorizontalPagingSegmentView *)viewForSegmentInPagingView;

/**
 segmentView的高度，reloadData的时候会调用

 @return segmentView的高度
 */
- (CGFloat)heightForSegmentInPagingView;
@optional

/**
 视图切换完成时候会调用

 @param pagingView pagingView
 @param aIndex 上一个视图的索引
 @param toIndex 当前视图的索引
 */
- (void)pagingView:(TTHorizontalPagingView *)pagingView didSwitchIndex:(NSInteger)aIndex to:(NSInteger)toIndex;

/**
 视图滚动时候会调用

 @param pagingView pagingView
 @param offset 当前滚动视图的contentOffset.y
 */
- (void)pagingView:(TTHorizontalPagingView *)pagingView scrollTopOffset:(CGFloat)offset;

@end

@interface TTHorizontalPagingView : SSThemedView
/**
 内部横向滚动的collectionView
 */
@property (nonatomic, strong, readonly) UICollectionView *horizontalCollectionView;
/**
 *  segment据顶部的距离
 */
@property (nonatomic, assign) CGFloat segmentTopSpace;
/**
 预加载数据，默认为YES
 */
@property (nonatomic, assign) BOOL shouldAdvanceLoadData;
@property (nonatomic, assign) BOOL ignoreAdjust;
/**
swipeView是否开启水平bounce效果，默认为 NO
 */
@property (nonatomic, assign) BOOL alwaysBounceHorizontal;
/**
 当前滚动视图的contentInset值
 */
@property (nonatomic, assign, readonly) CGFloat currentContentViewTopInset;

/**
 当前headerView的高度
 */
@property (nonatomic, assign, readonly) CGFloat headerViewHeight;
/**
 当前segmentView的高度
 */
@property (nonatomic, assign, readonly) CGFloat segmentViewHeight;
/**
 头部视图
 */
@property (nonatomic, strong, readonly) UIView *headerView;
/**
 代理
 */
@property (nonatomic, weak) id <TTHorizontalPagingViewDelegate> delegate;
/**
 segmentView
 */
@property (nonatomic, strong, readonly) TTHorizontalPagingSegmentView *segmentView;
/**
 当前滚动的scrollView
 */
@property (nonatomic, strong, readonly) UIScrollView *currentContentView;
/**
 *  手动控制滚动到某个视图
 *
 *  @param pageIndex 页号
 *  @param animation 是否动画滚动
 */
- (void)scrollToIndex:(NSInteger)pageIndex withAnimation:(BOOL)animation;
/**
 *  左右滑动
 *
 *  @param enable 是否允许滚动
 */
- (void)scrollEnable:(BOOL)enable;
/**
 获取指定index 的scrollView

 @param index 指定的index
 @return scrollView
 */
- (UIScrollView *)scrollViewAtIndex:(NSInteger)index;
/**
 刷新视图
 */
- (void)reloadData;

@end

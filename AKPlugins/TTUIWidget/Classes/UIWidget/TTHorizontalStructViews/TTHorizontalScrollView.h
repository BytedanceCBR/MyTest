//
//  TTHorizontalScrollView.h
//  Article
//
//  Created by Zhang Leonardo on 16-6-25.
//
//

#import "TTHorizontalScrollViewCell.h"

@protocol TTHorizontalScrollViewDelegate;
@protocol TTHorizontalScrollViewDataSource;

@interface TTHorizontalScrollView : UIView

@property(nonatomic, weak)id<TTHorizontalScrollViewDataSource> ttDataSource;

@property(nonatomic, weak)id<TTHorizontalScrollViewDelegate> ttDelegate;

@property(nonatomic, retain)UIScrollView * contentScrollView;

@property(nonatomic, retain)UIImage * cellBackgroundImage;

- (void)reloadData;

- (void)reloadDataAtIndex:(NSUInteger)index;//如果index越界，则不做任何处理

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)loadCellsNearbyWhenFirstAppear;

/**
 *  复用cell
 *
 *  @param identifier   cell的标识
 *  @param suggestIndex 建议的index， 如果没有则随机返回, 小于0的值 为无建议
 *
 *  @return cell
 */

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier suggestIndex:(NSInteger)suggestIndex;

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated;

- (TTHorizontalScrollViewCell *)currentDisplayCell;

- (TTHorizontalScrollViewCell *)cellAtIndex:(NSInteger)index;

- (void)setScrollViewContentSize:(CGSize)contentSize;

- (NSUInteger)currentCellIndex;

- (NSUInteger)numberOfCells;

- (void)removeCellDelegates;

@end

@protocol TTHorizontalScrollViewDataSource <NSObject>

@required

- (NSUInteger)numberOfCellsForHorizenScrollView:(TTHorizontalScrollView *)scrollView;

- (TTHorizontalScrollViewCell *)horizenScrollView:(TTHorizontalScrollView *)scrollView cellAtIndex:(NSUInteger)index;

@optional

- (void)horizenScrollView:(TTHorizontalScrollView *)scrollView refreshScrollCell:(TTHorizontalScrollViewCell *)cell cellIndex:(NSUInteger)index;



@optional

/*
 *  cell的缓存数量,默认是3
 *  推荐设置3-7的奇数，如果小于3，则实际使用为3。同理如果大于8，则实际使用8为cache数量
 */
- (NSUInteger)numberOfCellCachesForHorizenScrollView:(TTHorizontalScrollView *)scrollView;

@end

@protocol TTHorizontalScrollViewDelegate <NSObject>

@optional

- (void)horizenScrollViewGestureRecognizerStateEnded:(TTHorizontalScrollView *)scrollView;

- (void)horizenScrollView:(TTHorizontalScrollView *)scrollView willDisplayCellsFromIndex:(NSUInteger)index isUserFlipScroll:(NSNumber *)userScroll;
//最后一个参数用来指明，是用户手动滑动(YES)， 还是代码调用
- (void)horizenScrollView:(TTHorizontalScrollView *)scrollView didDisplayCellsForIndex:(NSUInteger)index isUserFlipScroll:(NSNumber *)userScroll;

//手指滑动、还是代码调用scrollToIndex:animated 停止时候，都会回调该方法
- (void)horizenScrollView:(TTHorizontalScrollView *)scrollView didEndScrollLastDisplayCellsForIndex:(NSUInteger)index;


- (void)horizenScrollView:(TTHorizontalScrollView *)scrollView scrollViewDidScrollToIndex:(NSUInteger)index;
/**
 *  翻页进度回调
 *
 *  @param scrollView  scrollView
 *  @param fromIndex  开始页面index
 *  @param toIndex    目标页面index
 *  @param percent    当前滑动进度
 */
- (void)horizenScrollView:(TTHorizontalScrollView *)scrollView scrollViewDidScrollFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex percent:(CGFloat)percent;

@end

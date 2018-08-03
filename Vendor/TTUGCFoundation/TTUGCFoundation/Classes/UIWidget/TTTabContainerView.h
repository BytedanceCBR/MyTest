//
//  TTTabContainerView.h
//  Article
//
//  Created by 王霖 on 15/9/30.
//
//

#import "SSThemed.h"

@class TTTabContainerView;

@protocol TTTabContainerViewDelegate <NSObject>

@optional
- (void)tabContainerView:(TTTabContainerView *)tabContainerView didFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex isClickTabToScroll:(BOOL)isClickTabToScroll;
- (void)scrollWithLeftIndex:(NSInteger)leftIndex rightIndex:(NSInteger)rightIndex progress:(double)progress;
@end

/**
 *  tab bar的位置
 */
typedef NS_ENUM(NSUInteger, TTTabContainerViewType){
    /**
     *  没有tab bar
     */
    TTTabContainerViewTypeNone = 0,
    /**
     *  tab bar在顶部
     */
    TTTabContainerViewTypeTop = 1,
    /**
     *  tab bar在底部
     */
    TTTabContainerViewTypeBottom,
};
@class _TTContainerScrollView;
@interface TTTabContainerView : SSThemedView

@property(nonatomic, weak)id<TTTabContainerViewDelegate>delegate;
@property(nonatomic, assign, readonly)NSUInteger pageIndex;
@property(nonatomic, strong, readonly)_TTContainerScrollView *scrollContainerView;

- (instancetype)initWithFrame:(CGRect)frame tabBarType:(TTTabContainerViewType)tabBarType tabBarHeight:(CGFloat)height NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)refreshInnerFrameForScroll;
- (void)addPageView:(UIView *)view title:(NSString *)title;
//用于初始设置index， 否则可能不准
- (void)performBatchUpdatesAndShowIndex:(NSUInteger)index animation:(BOOL)animation;
- (void)showIndex:(NSUInteger)index animation:(BOOL)animation;
- (UIView *)pageAtIndex:(NSUInteger)index;
- (NSString *)titleAtIndex:(NSUInteger)index;
@end

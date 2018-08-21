//
//  WDLoadMoreCell.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/11.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

/*
 * 9.20 修改新样式，分为四种状态：默认状态（点击加载更多），加载中（正在加载+图片），加载失败（加载失败，请稍后重试+重试按钮||网络不给力+重试按钮），无更多（没有更多了）
 * 9.22 cell的分割栏高度是6，所以计算topY的值时要减6；不同类型是不是还要不同高度？还要考虑ipad？
 */

typedef NS_ENUM(NSInteger, WDLoadMoreCellState) {
    WDLoadMoreCellStateInitial = 0,
    WDLoadMoreCellStateDefault,
    WDLoadMoreCellStateLoading,
    WDLoadMoreCellStateFailure,
    WDLoadMoreCellStateNoMore,
};

@protocol WDLoadMoreCellDelegate <NSObject>

- (void)loadMoreCellRequestTrigger;

@end

@interface WDLoadMoreCell : SSThemedTableViewCell

@property (nonatomic, weak) id<WDLoadMoreCellDelegate>delegate;

+ (CGFloat)cellHeightForState:(WDLoadMoreCellState)state;

- (void)refreshCellWithNewState:(WDLoadMoreCellState)state cellWidth:(CGFloat)cellWidth;

@end

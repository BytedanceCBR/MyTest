//
//  WDDetailAnswerEmptyCell.h
//  Article
//
//  Created by wangqi.kaisa on 2017/6/21.
//
//

#import "SSThemed.h"

/*
 * 6.21 横向滑动切换回答的回答详情页未获取到内容时的cell（请求失败 || 回答被删除）
 */

@protocol WDDetailAnswerEmptyCellDelegate <NSObject>

- (void)wd_detailAnswerEmptyCellReloadContent;

@end

@interface WDDetailAnswerEmptyCell : SSThemedTableViewCell

@property (nonatomic, weak) id<WDDetailAnswerEmptyCellDelegate>delegate;

- (void)setNetworkProblem;

- (void)setHasBeenDeletedWithError:(NSError *)error;

@end

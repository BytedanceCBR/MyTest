//
//  WDWendaListCellActionFooterView.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/12/29.
//

#import "SSThemed.h"

/*
 * 12.29 列表页cell底部包含三个按钮：点赞，转发，评论，单独封装成一个view，方便使用
 */

@class TTAlphaThemedButton;
@class WDAnswerEntity;

@protocol WDWendaListCellActionFooterViewDelegate <NSObject>

- (void)listCellActionFooterViewDiggButtonClick:(TTAlphaThemedButton *)diggButton;
- (void)listCellActionFooterViewCommentButtonClick;
- (void)listCellActionFooterViewForwardButtonClick;

@end

@interface WDWendaListCellActionFooterView : SSThemedView

+ (CGFloat)actionFooterHeight;

@property (nonatomic, weak) id<WDWendaListCellActionFooterViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame answerEntity:(WDAnswerEntity *)answerEntity;

- (void)refreshForwardCount:(NSNumber *)forwardCount commentCount:(NSNumber *)commentCount diggCount:(NSNumber *)diggCount isDigg:(BOOL)isDigg;

- (void)refreshForwardCount:(NSNumber *)forwardCount;

- (void)refreshCommentCount:(NSNumber *)commentCount;

- (void)refreshDiggCount:(NSNumber *)diggCount isDigg:(BOOL)isDigg;

@end

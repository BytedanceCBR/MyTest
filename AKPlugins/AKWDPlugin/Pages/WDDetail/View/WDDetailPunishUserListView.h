//
//  WDDetailPunishUserListView.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/11/28.
//

#import "SSThemed.h"

/*
 * 11.28 回答完成提示：回答完成后的惩戒用户名单公示view；高度36固定
 */

@class WDPostAnswerTipsStructModel;
@class WDDetailPunishUserListView;

@protocol WDDetailPunishUserListViewDelegate <NSObject>

- (void)detailPunishUserListViewCloseButtonTapped:(WDDetailPunishUserListView *)listView;

@end

@interface WDDetailPunishUserListView : SSThemedView

@property (nonatomic, weak) id<WDDetailPunishUserListViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame tipsModel:(WDPostAnswerTipsStructModel *)tipsModel;

@end

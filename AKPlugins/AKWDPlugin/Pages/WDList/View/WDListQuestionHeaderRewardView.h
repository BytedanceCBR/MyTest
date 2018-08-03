//
//  WDListQuestionHeaderRewardView.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/10/26.
//

#import "SSThemed.h"

/*
 * 10.26 列表页headerview中问题悬赏view
 * 10.30 未结束时高度为60，结束时高度为82
 */

@class WDListViewModel;

@interface WDListQuestionHeaderRewardView : SSThemedView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel;

- (void)reload;

@end

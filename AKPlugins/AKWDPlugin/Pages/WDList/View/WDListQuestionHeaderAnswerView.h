//
//  WDListQuestionHeaderAnswerView.h
//  Article
//
//  Created by xuzichao on 16/8/21.
//
//

#import "SSThemed.h"

/*
 * 9.21 需要AB
 */

@class WDListViewModel;

@interface WDListQuestionHeaderAnswerView : SSThemedView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel;

- (void)reload;

@end

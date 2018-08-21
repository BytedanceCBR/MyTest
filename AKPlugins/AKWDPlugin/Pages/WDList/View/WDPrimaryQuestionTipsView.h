//
//  WDPrimaryQuestionTipsView.h
//  Article
//
//  Created by 延晋 张 on 2017/7/27.
//
//

#import <TTThemed/SSThemed.h>

@class WDListViewModel;

@interface WDPrimaryQuestionTipsView : SSThemedView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel;

- (void)reload;

@end

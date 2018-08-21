//
//  WDListQuestionHeaderTitleView.h
//  Article
//
//  Created by 延晋 张 on 16/8/21.
//
//

#import "SSThemed.h"

@class WDListViewModel;

@interface WDListQuestionHeaderTitleView : SSThemedView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel;

- (void)reload;

@end

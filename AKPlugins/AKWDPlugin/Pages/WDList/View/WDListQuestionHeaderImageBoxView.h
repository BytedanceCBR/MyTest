//
//  WDListQuestionHeaderImageBoxView.h
//  Article
//
//  Created by 延晋 张 on 16/8/23.
//
//

#import "SSThemed.h"

@class WDListViewModel;

@interface WDListQuestionHeaderImageBoxView : SSThemedView

- (instancetype)initWithViewModel:(WDListViewModel *)viewModel
                            frame:(CGRect)frame;

- (void)refreshImageView;
- (CGFloat)viewHeight;

@end

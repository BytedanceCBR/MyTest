//
//  WDListQuestionHeaderTagView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/5/11.
//
//

#import "SSThemed.h"
#import "WDListQuestionHeaderCollectionView.h"

@class WDListViewModel;

@interface WDListQuestionHeaderTagView : SSThemedView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel;

- (void)reload;

@end

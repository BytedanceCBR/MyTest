//
//  WDWendaListTabView.h
//  Article
//
//  Created by xuzichao on 2017/3/13.
//
//

#import "SSThemed.h"

@class WDListViewModel;

@interface WDWendaListTabView : SSThemedView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel;

- (void)refresh;

@end

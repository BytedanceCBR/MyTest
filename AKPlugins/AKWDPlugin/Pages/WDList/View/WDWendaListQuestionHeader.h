//
//  WDWendaListQuestionHeader.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/10.
//
//  问答列表的问题view

#import "SSThemed.h"
#import "WDWendaListQuestionHeaderProtocol.h"

/*
 * 10.26 启动分成和问题悬赏需求，此view出现时标签view和问题重定向view均不显示
 */

@class WDListViewModel;

@interface WDWendaListQuestionHeader : SSThemedView<WDWendaListQuestionHeaderProtocol>

- (instancetype)initWithFrame:(CGRect)frame viewModel:(WDListViewModel *)viewModel;

@end

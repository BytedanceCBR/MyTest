//
//  WDWendaListQuestionHeaderNew.h
//  Pods
//
//  Created by wangqi.kaisa on 2017/9/14.
//
//

#import "SSThemed.h"
#import "WDWendaListQuestionHeaderProtocol.h"

/*
 * 9.14 列表页2.0改版新headerview
 * 10.26 启动分成和问题悬赏需求，此view出现时标签view和问题重定向view均不显示
 */

@class WDListViewModel;

@interface WDWendaListQuestionHeaderNew : SSThemedView<WDWendaListQuestionHeaderProtocol>

- (instancetype)initWithFrame:(CGRect)frame viewModel:(WDListViewModel *)viewModel;

@end

//
//  WDListQuestionHeaderDescView.h
//  Article
//
//  Created by 延晋 张 on 16/8/22.
//
//

#import "SSThemed.h"

/*
 * 9.14 B方案规则：
   只有文字时，默认最多显示一行，多余 ...+展开描述 点击展开全部
   只有图片时，直接展示图片
   图文俱全时，仅显示一行文字，文字末尾显示 ...+图片icon+展开全部
 * 9.21 需要AB
 * 10.18 仅用来展示A方案
 */

@class WDListViewModel;

@interface WDListQuestionHeaderDescView : SSThemedView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel;

- (void)reload;

@end

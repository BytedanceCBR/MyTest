//
//  WDListQuestionHeaderDescViewNew.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/10/18.
//

#import "SSThemed.h"

/*
 * 10.18 B方案太复杂，重新搞一个类
 只有文字时，默认最多显示一行，多余 ...+展开描述，点击展开全部
 只有图片时，直接展示图片
 图文俱全时，分三种情况：
 0 文字本身多行才能显示全，默认显示一行，末尾 ...+图片icon+展开描述，点击展开全部
 1 文字本身一行能显示全，但文字+(图片icon+展开描述)不能一行显示全，则仅显示一行，末尾 ...+图片icon+展开描述，点击展开全部
 2 文字本身一行能显示全，且文字+(图片icon+展开描述)也能一行显示全，则显示全部文字，末尾 +图片icon+展开描述，点击展开全部
 */

@class WDListViewModel;

@interface WDListQuestionHeaderDescViewNew : SSThemedView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel;

- (void)reload;

@end

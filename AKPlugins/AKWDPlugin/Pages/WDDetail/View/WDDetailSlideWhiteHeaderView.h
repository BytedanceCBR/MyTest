//
//  WDDetailSlideWhiteHeaderView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/8/2.
//
//

#import "SSThemed.h"
#import "WDDetailSlideHeaderView.h"

/*
 * 8.2  新添加一种旧的白色背景样式，就是之前web中头的效果
 */

@class WDDetailModel;

@interface WDDetailSlideWhiteHeaderView : SSThemedView<WDDetailSlideHeaderViewProtocol>

@property (nonatomic, weak) id<WDDetailSlideHeaderViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame detailModel:(WDDetailModel *)detailModel;

@end

//
//  WDNewDetailHeaderView.h
//  wenda
//
//  Created by 延晋 张 on 2017/6/27.
//  Copyright © 2017年 Bytedance Inc. All rights reserved.
//

#import "WDDetailHeaderView.h"

@interface WDNewDetailHeaderView : SSThemedView <WDDetailHeaderView>

- (instancetype)initWithFrame:(CGRect)frame detailModel:(WDDetailModel *)detailModel;

@end

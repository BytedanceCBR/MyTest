//
//  LoadMoreCell.h
//  Essay
//
//  Created by Tianhang Yu on 12-3-6.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

#define kLoadMoreCellHeight 44
#define kCellLeftPadding (9+30+9)

typedef NS_ENUM(NSInteger, SSLoadMoreCellLabelStyle)
{
    SSLoadMoreCellLabelStyleAlignLeft = 0,  // “点击加载更多”靠左对齐 默认
    SSLoadMoreCellLabelStyleAlignMiddle = 1, // “点击加载更多”居中对齐
};

@interface SSLoadMoreCell : SSThemedTableViewCell

@property (nonatomic, copy)NSString * customSSLoadMoreCellBgColorString; //default is nil
@property (nonatomic, copy)NSString * customSSLoadMoreCellSelectBgColorString;//default is nil
@property (nonatomic, assign)SSLoadMoreCellLabelStyle labelStyle;
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
- (void)addMoreLabel;
- (void)hiddenLabel:(BOOL)hidden;
@end

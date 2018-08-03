//
//  TTThemedAlertControllerActionCell.h
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/12.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTThemedAlertActionModel.h"

typedef NS_ENUM(NSInteger, TTThemedAlertControllerActionCellType)
{
    TTThemedAlertControllerActionCellTypeVertical,
    TTThemedAlertControllerActionCellTypeHorizental,
    TTThemedAlertControllerActionCellTypeHidden
};

@interface TTThemedAlertControllerActionCell : UITableViewCell

//竖排cell
- (void)configCellWithActionModel:(TTThemedAlertActionModel *)actionModel isPopover:(BOOL)isPopover;

//单行横排双按钮cell
- (void)configHorizentalCellWithLeftModel:(TTThemedAlertActionModel *)leftModel leftAction:(SEL)leftAction rightModel:(TTThemedAlertActionModel *)rightModel rightAction:(SEL)rightAction target:(id)target;
@end

//
//  WDCellRouteCenter.h
//  wenda
//
//  Created by xuzichao on 2017/2/8.
//  Copyright © 2017年 xuzichao. All rights reserved.
//

#import "WDBaseCell.h"
#import "WDCellServiceProctol.h"

@interface WDCellRouteCenter : NSObject

+ (instancetype)sharedInstance;

- (void)registerCellGroup:(id<WDCellServiceProctol>)service;

- (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width;

- (UITableViewCell<WDBaseCellDelegate> *)dequeueTableCellForData:(id)data
                              tableView:(UITableView *)view
                            atIndexPath:(NSIndexPath *)indexPath;

@end


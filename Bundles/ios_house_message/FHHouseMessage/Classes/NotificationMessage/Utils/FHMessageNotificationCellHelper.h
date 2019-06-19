//
//  FHMessageNotificationCellHelper.h
//  Article
//
//  Created by zhulijun.2539  on 2019/6/17.
//
//

#import <Foundation/Foundation.h>

@class FHMessageNotificationBaseCell;
@class FHMessageNotificationModel;

@interface FHMessageNotificationCellHelper : NSObject

+ (void)registerAllCellClassWithTableView:(UITableView *)tableView;
+ (FHMessageNotificationBaseCell *)dequeueTableCellForData:(FHMessageNotificationModel *)data tableView:(UITableView *)view atIndexPath:(NSIndexPath *)indexPath;
+ (CGFloat)heightForData:(FHMessageNotificationModel *)data cellWidth:(CGFloat)width;

+ (CGFloat)tt_newPadding:(CGFloat)normalPadding;

+ (CGFloat)tt_newFontSize:(CGFloat)normalSize;

+ (CGSize)tt_newSize:(CGSize)normalSize;

+ (NSDictionary *)listCellLogExtraForData:(FHMessageNotificationModel *)message;

@end

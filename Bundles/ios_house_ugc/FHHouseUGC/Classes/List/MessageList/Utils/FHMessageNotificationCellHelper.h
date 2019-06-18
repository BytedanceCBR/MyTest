//
//  FHMessageNotificationCellHelper.h
//  Article
//
//  Created by 邱鑫玥 on 2017/4/10.
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

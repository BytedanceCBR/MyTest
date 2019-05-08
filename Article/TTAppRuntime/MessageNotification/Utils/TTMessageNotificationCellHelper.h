//
//  TTMessageNotificationCellHelper.h
//  Article
//
//  Created by 邱鑫玥 on 2017/4/10.
//
//

#import <Foundation/Foundation.h>

@class TTMessageNotificationBaseCell;
@class TTMessageNotificationModel;

@interface TTMessageNotificationCellHelper : NSObject

+ (void)registerAllCellClassWithTableView:(UITableView *)tableView;
+ (TTMessageNotificationBaseCell *)dequeueTableCellForData:(TTMessageNotificationModel *)data tableView:(UITableView *)view atIndexPath:(NSIndexPath *)indexPath;
+ (CGFloat)heightForData:(TTMessageNotificationModel *)data cellWidth:(CGFloat)width;

+ (CGFloat)tt_newPadding:(CGFloat)normalPadding;

+ (CGFloat)tt_newFontSize:(CGFloat)normalSize;

+ (CGSize)tt_newSize:(CGSize)normalSize;

+ (NSDictionary *)listCellLogExtraForData:(TTMessageNotificationModel *)message;

@end

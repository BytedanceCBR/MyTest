//
//  FHMessageNotificationBaseCell
//  Article
//
//  Created by zhulijun.2539 on 2019/6/17.
//
//

#import "SSThemed.h"

@class FHMessageNotificationBaseCellView;
@class TTMessageNotificationModel;

@interface FHMessageNotificationBaseCell : UITableViewCell

@property (nonatomic, strong, nullable) FHMessageNotificationBaseCellView * cellView;

+ (nullable Class)cellViewClass;

+ (CGFloat)heightForData:(nullable TTMessageNotificationModel *)data cellWidth:(CGFloat)width;

- (void)refreshUI;

- (void)refreshWithData:(nullable TTMessageNotificationModel *)data;

- (nullable TTMessageNotificationModel *)cellData;

@end

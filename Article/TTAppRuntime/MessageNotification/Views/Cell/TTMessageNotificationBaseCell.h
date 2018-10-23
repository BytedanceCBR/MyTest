//
//  TTMessageNotificationBaseCell
//  Article
//
//  Created by lizhuoli on 2017/3/31.
//
//

#import "SSThemed.h"

@class TTMessageNotificationBaseCellView;
@class TTMessageNotificationModel;

@interface TTMessageNotificationBaseCell : UITableViewCell

@property (nonatomic, strong, nullable) TTMessageNotificationBaseCellView * cellView;

+ (nullable Class)cellViewClass;

+ (CGFloat)heightForData:(nullable TTMessageNotificationModel *)data cellWidth:(CGFloat)width;

- (void)refreshUI;

- (void)refreshWithData:(nullable TTMessageNotificationModel *)data;

- (nullable TTMessageNotificationModel *)cellData;

@end

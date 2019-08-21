//
//  FHHomeEntrancesCell.h
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import <UIKit/UIKit.h>
#import "FHHomeBaseTableCell.h"
#import <FHHouseBase/FHRowsView.h>

NS_ASSUME_NONNULL_BEGIN
@class FHConfigDataOpDataItemsModel;
@interface FHHomeEntrancesCell : FHHomeBaseTableCell

@property (nonatomic,copy) void (^clickBlock)(NSInteger index , FHConfigDataOpDataItemsModel *model);

+(CGFloat)rowHeight;

+(CGFloat)cellHeightForModel:(id)model;

-(void)updateWithItems:(NSArray *)items;

@end

NS_ASSUME_NONNULL_END

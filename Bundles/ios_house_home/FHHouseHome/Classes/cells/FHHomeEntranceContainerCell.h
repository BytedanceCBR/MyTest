//
//  FHHomeEntranceContainerCell.h
//  FHHouseHome
//
//  Created by CYY RICH on 2020/11/9.
//

#import "FHHomeBaseTableCell.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHConfigDataOpDataItemsModel;

@interface FHHomeEntranceContainerCell : FHHomeBaseTableCell

@property (nonatomic, copy) void (^clickBlock)(NSInteger index , FHConfigDataOpDataItemsModel *itemModel);

+ (CGFloat)rowHeight;

+ (CGFloat)cellHeightForModel:(id)model;

- (void)updateWithItems:(NSArray<FHConfigDataOpDataItemsModel *> *)items;

@end

NS_ASSUME_NONNULL_END

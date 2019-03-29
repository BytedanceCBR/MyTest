//
//  FHPriceValuationHistoryCell.h
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/22.
//

#import <UIKit/UIKit.h>
#import "FHPriceValuationHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationHistoryCell : UITableViewCell

- (void)updateCell:(FHPriceValuationHistoryDataHistoryHouseListModel *)model;

@end

NS_ASSUME_NONNULL_END

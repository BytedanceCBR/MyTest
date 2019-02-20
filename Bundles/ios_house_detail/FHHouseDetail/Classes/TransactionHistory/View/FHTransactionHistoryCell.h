//
//  FHTransactionHistoryCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/20.
//

#import <UIKit/UIKit.h>
#import "FHTransactionHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHTransactionHistoryCell : UITableViewCell

- (void)updateWithModel:(FHDetailNeighborhoodDataTotalSalesListModel *)model isLast:(BOOL)isLast;

@end

NS_ASSUME_NONNULL_END

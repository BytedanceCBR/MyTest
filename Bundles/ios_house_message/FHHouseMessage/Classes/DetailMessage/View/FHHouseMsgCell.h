//
//  FHHouseMsgCell.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import <UIKit/UIKit.h>
#import "FHHouseMsgModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseMsgCell : UITableViewCell

- (void)updateWithModel:(FHHouseMsgDataItemsItemsModel *)model;

@end

NS_ASSUME_NONNULL_END

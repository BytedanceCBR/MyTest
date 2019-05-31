//
//  FHMineBaseCell.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import <UIKit/UIKit.h>
#import "FHMineConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMineBaseCell : UITableViewCell

- (void)updateCell:(FHMineConfigDataIconOpDataModel *)model isFirst:(BOOL)isFirst;

@property(nonatomic, strong) FHMineConfigDataIconOpDataModel *model;

@end

NS_ASSUME_NONNULL_END

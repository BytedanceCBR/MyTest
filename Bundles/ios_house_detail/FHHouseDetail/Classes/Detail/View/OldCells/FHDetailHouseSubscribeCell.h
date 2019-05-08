//
//  FHDetailHouseSubscribeCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/3/19.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailHouseSubscribeCell : FHDetailBaseCell

@property (nonatomic,copy) void (^subscribeBlock)(NSString *phoneNum);

@end

@interface FHDetailHouseSubscribeModel : FHDetailBaseModel

@property (nonatomic, weak , nullable) UITableViewCell *cell;
@property(nonatomic, weak) UITableView *tableView;

@end

NS_ASSUME_NONNULL_END

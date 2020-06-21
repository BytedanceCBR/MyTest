//
//  FHDetailHouseSubscribeCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/3/19.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailHouseSubscribeCell : FHDetailBaseCell

@property(nonatomic, copy) void (^subscribeBlock)(NSString *phoneNum);
@property(nonatomic, copy) void (^legalAnnouncementClickBlock)(void);
@end

@interface FHDetailHouseSubscribeModel : FHDetailBaseModel

@property(nonatomic, weak, nullable) UITableViewCell *cell;
@property(nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;

@end

NS_ASSUME_NONNULL_END

//
//  FHDetailOldNearbyMapCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/5/21.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailOldNearbyMapCell : FHDetailBaseCell

// 左右有切换回调
@property (nonatomic,copy) void (^indexChangeCallBack)();

@end


@interface FHDetailOldNearbyMapModel :FHDetailBaseModel

@property (nonatomic, weak , nullable) UITableViewCell *cell;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *mapCentertitle;
@property (nonatomic, copy , nullable) NSString *houseId;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *score;

@end

NS_ASSUME_NONNULL_END

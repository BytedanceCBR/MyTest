//
//  FHHouseDetailPhoneCallViewModel.h
//  Pods
//
//  Created by 张静 on 2019/2/14.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"
#import <FHHouseBase/FHHouseFollowUpHelper.h>

NS_ASSUME_NONNULL_BEGIN

@class FHDetailBottomBarView;

typedef void(^FHHouseDetailPhoneCallSuccessBlock)(BOOL success);
typedef void(^FHHouseDetailPhoneCallFailBlock)(NSError *error);

@interface FHHouseDetailPhoneCallViewModel: NSObject

@property(nonatomic , strong) NSDictionary *tracerDict; // 详情页基础埋点数据

- (instancetype)initWithHouseType:(FHHouseType)houseType houseId:(NSString *)houseId;
- (void)jump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone;
- (void)licenseActionWithPhone:(FHDetailContactModel *)contactPhone;

- (void)imchatActionWithPhone:(FHDetailContactModel *)contactPhone realtorRank:(NSString *)rank position:(NSString *)position;
- (void)generateImParams:(NSString *)houseId houseTitle:(NSString *)houseTitle houseCover:(NSString *)houseCover houseType:(NSString *)houseType houseDes:(NSString *)houseDes housePrice:(NSString *)housePrice houseAvgPrice:(NSString *)houseAvgPrice;

@end

NS_ASSUME_NONNULL_END

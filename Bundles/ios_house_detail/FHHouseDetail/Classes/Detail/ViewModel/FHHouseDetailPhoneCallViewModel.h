//
//  FHHouseDetailPhoneCallViewModel.h
//  Pods
//
//  Created by 张静 on 2019/2/14.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"
#import "FHHouseDetailFollowUpViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailBottomBarView;

typedef void(^FHHouseDetailPhoneCallSuccessBlock)(BOOL success);
typedef void(^FHHouseDetailPhoneCallFailBlock)(NSError *error);

@interface FHHouseDetailPhoneCallViewModel : NSObject

@property (nonatomic, weak) FHHouseDetailFollowUpViewModel *followUpViewModel;
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;
@property(nonatomic , strong) NSDictionary *tracerDict; // 详情页基础埋点数据

- (instancetype)initWithHouseType:(FHHouseType)houseType houseId:(NSString *)houseId;

- (void)fillFormAction;
- (void)jump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone;
- (void)licenseActionWithPhone:(FHDetailContactModel *)contactPhone;
- (void)callWithPhone:(NSString *)phone searchId:(NSString *)searchId imprId:(NSString *)imprId;
- (void)callWithPhone:(NSString *)phone searchId:(NSString *)searchId imprId:(NSString *)imprId successBlock:(FHHouseDetailPhoneCallSuccessBlock)successBlock failBlock:(FHHouseDetailPhoneCallFailBlock)failBlock;
@end

NS_ASSUME_NONNULL_END

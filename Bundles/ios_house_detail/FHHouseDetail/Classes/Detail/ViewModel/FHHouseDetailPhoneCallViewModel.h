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

@interface FHHouseDetailPhoneCallViewModel : NSObject

@property (nonatomic, weak) FHHouseDetailFollowUpViewModel *followUpViewModel;
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;

- (instancetype)initWithHouseType:(FHHouseType)houseType houseId:(NSString *)houseId;

- (void)fillFormAction;
- (void)jump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone;
- (void)licenseActionWithPhone:(FHDetailContactModel *)contactPhone;
- (void)callWithPhone:(FHDetailContactModel *)contactPhone searchId:(NSString *)searchId imprId:(NSString *)imprId;

@end

NS_ASSUME_NONNULL_END

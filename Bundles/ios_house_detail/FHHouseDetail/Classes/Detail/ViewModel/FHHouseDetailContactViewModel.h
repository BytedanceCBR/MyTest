//
//  FHHouseDetailContactViewModel.h
//  Pods
//
//  Created by 张静 on 2019/2/13.
//

#import <Foundation/Foundation.h>
#import "FHDetailBottomBarView.h"
#import "FHDetailNavBar.h"
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseDetailFollowUpViewModel;
@interface FHHouseDetailContactViewModel : NSObject

@property (nonatomic, strong) FHDetailContactModel *contactPhone;
@property (nonatomic, strong) FHDetailShareInfoModel *shareInfo;
@property (nonatomic, strong, readonly)FHHouseDetailFollowUpViewModel *followUpViewModel;
@property (nonatomic, copy) NSString *searchId;
@property (nonatomic, copy) NSString *imprId;
@property (nonatomic, assign) NSInteger followStatus;
@property(nonatomic , strong) NSDictionary *tracerDict; // 详情页基础埋点数据
@property (nonatomic, weak) UIViewController *belongsVC;
@property (nonatomic, copy, nullable) NSString *customHouseId;// floor_plan_detail:floor_plan_id
@property (nonatomic, copy, nullable) NSString *fromStr;//floor_plan_detail:app_floor_plan

- (instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBarView *)bottomBar;
- (instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBarView *)bottomBar houseType:(FHHouseType)houseType houseId:(NSString *)houseId;

- (void)fillFormAction;
- (void)fillFormActionWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle;

- (void)hideFollowBtn;

@end

NS_ASSUME_NONNULL_END

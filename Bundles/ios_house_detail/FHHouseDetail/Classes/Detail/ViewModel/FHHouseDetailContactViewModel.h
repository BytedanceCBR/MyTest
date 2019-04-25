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
#import <FHHouseBase/FHHouseContactDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailContactViewModel : NSObject

@property (nonatomic, strong) FHDetailContactModel *contactPhone;
@property (nonatomic, strong) FHDetailShareInfoModel *shareInfo;
@property (nonatomic, copy) NSString *searchId;
@property (nonatomic, copy) NSString *imprId;
@property (nonatomic, assign) NSInteger followStatus;
@property(nonatomic , strong) NSDictionary *tracerDict; // 详情页基础埋点数据
@property (nonatomic, weak) UIViewController *belongsVC;
@property (nonatomic, assign)   BOOL       showenOnline;// 是否显示在线联系，默认不显示
@property (nonatomic, copy)     NSString       *onLineName;// 在线联系 名称
@property (nonatomic, copy)     NSString       *phoneCallName;// 电话咨询 或者 询底价 名称
@property (nonatomic, copy, nullable) NSString *customHouseId;// floor_plan_detail:floor_plan_id
@property (nonatomic, copy, nullable) NSString *fromStr;//floor_plan_detail:app_floor_plan

- (instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBarView *)bottomBar;
- (instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBarView *)bottomBar houseType:(FHHouseType)houseType houseId:(NSString *)houseId;
// 在线联系点击
- (void)onlineActionWithExtraDict:(NSDictionary *)extraDict;
// 拨打电话 + 询底价填表单
- (void)contactActionWithExtraDict:(NSDictionary *)extraDict;
// 基本埋点数据
- (NSDictionary *)baseParams;

- (void)fillFormActionWithActionType:(FHFollowActionType)actionType;

//为IM提供房源卡片
- (void)generateImParams:(NSString *)houseId houseTitle:(NSString *)houseTitle houseCover:(NSString *)houseCover houseType:(NSString *)houseType houseDes:(NSString *)houseDes housePrice:(NSString *)housePrice houseAvgPrice:(NSString *)houseAvgPrice;
- (void)refreshMessageDot;
- (void)hideFollowBtn;

@end

NS_ASSUME_NONNULL_END

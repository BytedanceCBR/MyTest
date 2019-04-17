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
@class TTRouteObject;

typedef void(^FHHouseDetailPhoneCallSuccessBlock)(BOOL success);
typedef void(^FHHouseDetailPhoneCallFailBlock)(NSError *error);

@interface FHHouseDetailPhoneCallViewModel : NSObject

@property (nonatomic, weak) FHHouseDetailFollowUpViewModel *followUpViewModel;
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;
@property (nonatomic, weak) UIViewController *belongsVC;
@property(nonatomic , strong) NSDictionary *tracerDict; // 详情页基础埋点数据

- (instancetype)initWithHouseType:(FHHouseType)houseType houseId:(NSString *)houseId;
- (void)fillFormActionWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle customHouseId:(NSString *)customHouseId fromStr:(NSString *)fromStr;
- (void)fillFormActionWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle;
- (void)fillFormActionWithCustomHouseId:(NSString *)customHouseId fromStr:(NSString *)fromStr;

- (TTRouteObject *)creatJump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone isPreLoad:(BOOL)isPre;
- (void)jump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone isPreLoad:(BOOL)isPre;

- (void)licenseActionWithPhone:(FHDetailContactModel *)contactPhone;

- (void)imchatActionWithPhone:(FHDetailContactModel *)contactPhone realtorRank:(NSString *)rank position:(NSString *)position;
- (void)generateImParams:(NSString *)houseId houseTitle:(NSString *)houseTitle houseCover:(NSString *)houseCover houseType:(NSString *)houseType houseDes:(NSString *)houseDes housePrice:(NSString *)housePrice houseAvgPrice:(NSString *)houseAvgPrice;

- (void)callWithPhone:(NSString *)phone realtorId:(NSString *)realtorId searchId:(NSString *)searchId imprId:(NSString *)imprId;
- (void)callWithPhone:(NSString *)phone realtorId:(NSString *)realtorId searchId:(NSString *)searchId imprId:(NSString *)imprId reportParams:(NSDictionary *)reportParams successBlock:(FHHouseDetailPhoneCallSuccessBlock)successBlock failBlock:(FHHouseDetailPhoneCallFailBlock)failBlock;
- (void)callWithPhone:(NSString *)phone realtorId:(NSString *)realtorId searchId:(NSString *)searchId imprId:(NSString *)imprId extraDict:(NSDictionary *)extraDict;

- (void)destoryRNPreloadCache;
@end

NS_ASSUME_NONNULL_END

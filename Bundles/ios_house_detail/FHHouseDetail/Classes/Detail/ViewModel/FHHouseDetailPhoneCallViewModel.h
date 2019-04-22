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

@interface FHHouseDetailFormAlertModel : NSObject

@property (nonatomic, copy) NSString *title; // 非必填
@property (nonatomic, copy) NSString *subtitle;// 非必填
@property (nonatomic, copy) NSString *btnTitle;// 非必填
@property (nonatomic, copy) NSString *leftBtnTitle;// 非必填

@end

@interface FHHouseDetailPhoneCallViewModel : NSObject

@property (nonatomic, weak) FHHouseDetailFollowUpViewModel *followUpViewModel;
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;
@property (nonatomic, weak) UIViewController *belongsVC;
@property(nonatomic , strong) NSDictionary *tracerDict; // 详情页基础埋点数据

- (instancetype)initWithHouseType:(FHHouseType)houseType houseId:(NSString *)houseId;

- (void)fillFormActionWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle customHouseId:(NSString *)customHouseId fromStr:(NSString *)fromStr withExtraDict:(NSDictionary *)extraDict;
- (void)fillFormActionWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle withExtraDict:(NSDictionary *)extraDict;
- (void)fillFormActionWithCustomHouseId:(NSString *)customHouseId fromStr:(NSString *)fromStr withExtraDict:(NSDictionary *)extraDict;
- (void)fillFormAction:(FHHouseDetailFormAlertModel *)alertModel contactPhone:(FHDetailContactModel *)contactPhone customHouseId:(NSString *)customHouseId fromStr:(NSString *)fromStr withExtraDict:(NSDictionary *)extraDict;
- (TTRouteObject *)creatJump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone isPreLoad:(BOOL)isPre andIsOpen:(BOOL)isOpen;
- (void)jump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone isPreLoad:(BOOL)isPre;

- (void)licenseActionWithPhone:(FHDetailContactModel *)contactPhone;

- (void)imchatActionWithPhone:(FHDetailContactModel *)contactPhone realtorRank:(NSString *)rank position:(NSString *)position;
- (void)generateImParams:(NSString *)houseId houseTitle:(NSString *)houseTitle houseCover:(NSString *)houseCover houseType:(NSString *)houseType houseDes:(NSString *)houseDes housePrice:(NSString *)housePrice houseAvgPrice:(NSString *)houseAvgPrice;

- (void)callWithPhone:(NSString *)phone realtorId:(NSString *)realtorId searchId:(NSString *)searchId imprId:(NSString *)imprId;
- (void)callWithPhone:(NSString *)phone realtorId:(NSString *)realtorId searchId:(NSString *)searchId imprId:(NSString *)imprId reportParams:(NSDictionary *)reportParams successBlock:(FHHouseDetailPhoneCallSuccessBlock)successBlock failBlock:(FHHouseDetailPhoneCallFailBlock)failBlock;
- (void)callWithPhone:(NSString *)phone realtorId:(NSString *)realtorId searchId:(NSString *)searchId imprId:(NSString *)imprId extraDict:(NSDictionary *)extraDict;

- (void)destoryRNPreloadCache;

//Gecko Channels
+ (NSArray *)fhGeckoChannels;
//预加载的渠道
+ (NSArray *)fhRNPreLoadChannels;
//可用的渠道
+ (NSArray *)fhRNEnableChannels;
@end

NS_ASSUME_NONNULL_END

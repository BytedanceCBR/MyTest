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
@class TTRouteObject;

typedef void(^FHHouseDetailPhoneCallSuccessBlock)(BOOL success);
typedef void(^FHHouseDetailPhoneCallFailBlock)(NSError *error);

@interface FHHouseDetailPhoneCallViewModel: NSObject

@property(nonatomic , strong) NSDictionary *tracerDict; // 详情页基础埋点数据
@property (nonatomic, weak) UIViewController *belongsVC;
@property (nonatomic, assign) BOOL rnIsUnAvalable;
@property (nonatomic, assign)   BOOL isEnterIM;
@property (nonatomic, copy) NSString *houseInfoBizTrace;

- (instancetype)initWithHouseType:(FHHouseType)houseType houseId:(NSString *)houseId;
- (void)jump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone;

- (void)licenseActionWithPhone:(FHDetailContactModel *)contactPhone;


- (void)generateImParams:(NSString *)houseId
              houseTitle:(NSString *)houseTitle
              houseCover:(NSString *)houseCover
               houseType:(NSString *)houseType
                houseDes:(NSString *)houseDes
              housePrice:(NSString *)housePrice
           houseAvgPrice:(NSString *)houseAvgPrice;

- (void)imchatActionWithPhone:(FHDetailContactModel *)contactPhone realtorRank:(NSString *)rank extraDic:(NSDictionary *)extra ;


- (void)jump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone isPreLoad:(BOOL)isPre extra:(NSDictionary*)extra;

- (TTRouteObject *)creatJump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone isPreLoad:(BOOL)isPre andIsOpen:(BOOL)isOpen extra:(NSDictionary*)extra;

- (void)destoryRNPreloadCache;

- (void)updateLoadFinish;

//Gecko Channels
+ (NSArray *)fhGeckoChannels;
//预加载的渠道
+ (NSArray *)fhRNPreLoadChannels;
//可用的渠道
+ (NSArray *)fhRNEnableChannels;

// 回调方法
- (void)vc_viewDidAppear:(BOOL)animated;

- (void)vc_viewDidDisappear:(BOOL)animated;


@end

NS_ASSUME_NONNULL_END

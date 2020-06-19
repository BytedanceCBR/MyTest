//
//  FHRealtorEvaluatingPhoneCallModel.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/17.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"
#import "FHFeedUGCCellModel.h"
#import <FHHouseBase/FHHouseFollowUpHelper.h>
#import "FHAssociatePhoneModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHRealtorEvaluatingPhoneCallModel : NSObject
- (instancetype)initWithHouseType:(FHHouseType)houseType houseId:(NSString *)houseId;
@property(nonatomic , strong) NSDictionary *tracerDict; // 详情页基础埋点数据
@property (nonatomic, assign)   BOOL isEnterIM;
- (void)imchatActionWithPhone:(FHFeedUGCCellRealtorModel *)realtorModel realtorRank:(NSString *)rank extraDic:(NSDictionary *)extra ;

- (void)phoneChatActionWithAssociateModel:(FHAssociatePhoneModel *)associatePhoneModel;
@end

NS_ASSUME_NONNULL_END

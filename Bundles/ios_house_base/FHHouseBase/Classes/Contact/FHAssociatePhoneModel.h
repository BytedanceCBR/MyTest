//
//  FHAssociatePhoneModel.h
//  FHHouseBase
//
//  Created by 张静 on 2020/4/2.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

#import "FHHouseType.h"
#import "FHAssociateReportParams.h"

NS_ASSUME_NONNULL_BEGIN



@interface FHAssociatePhoneModel : JSONModel

@property (nonatomic, strong) NSDictionary *associateInfo; // 线索相关参数
@property (nonatomic, strong) NSDictionary *reportParams; // 埋点参数
@property (nonatomic, strong) NSDictionary *extraDict; // 埋点参数

// 业务参数
@property (nonatomic, assign) BOOL showLoading; // 按钮状态
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, copy) NSString *imprId;
@property (nonatomic, copy) NSString *searchId;
@property (nonatomic, copy) NSString *realtorId;
@end

NS_ASSUME_NONNULL_END

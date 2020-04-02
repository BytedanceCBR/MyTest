//
//  FHAssociateIMModel.h
//  FHHouseBase
//
//  Created by 张静 on 2020/4/2.
//

#import "JSONModel.h"
#import "FHHouseType.h"
#import "FHAssociateReportParams.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHAssociateIMModel : JSONModel

@property (nonatomic, strong) NSDictionary *associateInfo; // 线索相关参数
@property (nonatomic, strong) FHAssociateReportParams *reportParams; // 埋点参数
@property (nonatomic , copy) NSString *imOpenUrl;

#pragma mark 必填 todo zjing test
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;

@end

NS_ASSUME_NONNULL_END

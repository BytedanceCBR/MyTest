//
//  FHNeighborhoodDetailStrategySM.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHNeighborhoodDetailSectionModel.h"
#import "FHNeighborhoodDetailSpaceCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailStrategySM : FHNeighborhoodDetailSectionModel

@property(nonatomic , strong) NSString *title;

@property(nonatomic, copy) NSDictionary *extraDic;
@property(nonatomic, copy) NSDictionary *detailTracerDic; // 详情页基础埋点数据
@end

NS_ASSUME_NONNULL_END

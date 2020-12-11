//
//  FHNeighborhoodDetailBaseInfoSM.m
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/10.
//

#import "FHNeighborhoodDetailBaseInfoSM.h"

@implementation FHNeighborhoodDetailBaseInfoSM

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    
    self.neighborhoodDetailModules = model.data.neighborhoodDetailModules;
    
    NSMutableArray *mArr = [NSMutableArray array];
    [model.data.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.value.length > 0 && ![obj.value isEqualToString:@"-"]) {
            [mArr addObject:obj];
        }
    }];
    
    if (mArr.count > 0) {
        FHNeighborhoodDetailPropertyInfoModel *propertyInfoModel = [[FHNeighborhoodDetailPropertyInfoModel alloc] init];
        propertyInfoModel.baseInfo = mArr.copy;
//        propertyInfoModel.baseInfoFoldCount = model.data.baseInfoFoldCount;
        self.propertyInfoModel = propertyInfoModel;
    }
}

@end

//
//  FHDetailAccessCellModel.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/3/6.
//

#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHCardSliderCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailAccessCellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataStrategyModel *strategy;
@property (nonatomic, strong , nullable) NSArray<FHCardSliderCellModel *> *cards;
@property (nonatomic, strong , nullable) NSDictionary *tracerDic;
@property (nonatomic, assign) CGFloat topMargin;

@end

NS_ASSUME_NONNULL_END

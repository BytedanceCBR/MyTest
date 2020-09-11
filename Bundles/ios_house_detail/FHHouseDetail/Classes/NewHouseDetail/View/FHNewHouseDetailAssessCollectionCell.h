//
//  FHNewHouseDetailAssessCollectionCell.h
//  Pods
//
//  Created by bytedance on 2020/9/10.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHCardSliderCellModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailAssessCollectionCell : FHDetailBaseCollectionCell

@end

@interface FHNewHouseDetailAssessCellModel : NSObject

@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataStrategyModel *strategy;
@property (nonatomic, copy , nullable, readonly) NSArray<FHCardSliderCellModel *> *cards;
@property (nonatomic, strong , nullable) NSDictionary *tracerDic;

@end

NS_ASSUME_NONNULL_END

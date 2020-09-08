//
//  FHNewHouseDetailNewHouseNewsCollectionCell.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/9/8.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNewModel.h"


@interface FHNewHouseDetailNewHouseNewsCollectionCell : FHDetailBaseCollectionCell

@end

@interface FHNewHouseDetailNewHouseNewsCellModel : NSObject

@property (nonatomic, strong) FHDetailNewDataTimelineModel *timeLineModel;

@end

@interface FHNewHouseDetailNewHouseNewsItemCollectionCell : FHDetailBaseCollectionCell

- (void)updateTitleColor:(UIColor *)titleColor timeColor:(UIColor *)timeColor dotColor:(UIColor *)dotColor;

@end

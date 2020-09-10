//
//  FHNewHouseDetailNewHouseNewsCollectionCell.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/9/8.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNewModel.h"


@interface FHNewHouseDetailTimeLineCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void(^selectedIndexChange)(NSInteger index);

@end

@interface FHNewHouseDetailTimeLineCellModel : NSObject

@property (nonatomic, strong) FHDetailNewDataTimelineModel *timeLineModel;

@end

@interface FHNewHouseDetailTimeLineItemCollectionCell : FHDetailBaseCollectionCell

- (void)updateTitleColor:(UIColor *)titleColor timeColor:(UIColor *)timeColor dotColor:(UIColor *)dotColor backgroundColor:(UIColor *)backgroundColor;

@end

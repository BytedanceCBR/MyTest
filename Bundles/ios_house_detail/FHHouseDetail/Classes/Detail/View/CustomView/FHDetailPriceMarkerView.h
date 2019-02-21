//
//  FHDetailPriceMarkerView.h
//  PNChartDemo
//
//  Created by 张静 on 2019/2/19.
//  Copyright © 2019年 kevinzhow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailPriceMarkerData,FHDetailPriceMarkerItem;

//typedef (CGFloat,FHDetailPriceTrendValuesModel)(^markerDataBlock)(NSInteger index);

@interface FHDetailPriceMarkerView : UIView

@property(nonatomic, copy, nullable) FHDetailPriceMarkerData *markData;

- (void)refreshContent:(FHDetailPriceMarkerData *)markData;

@end

@interface FHDetailPriceMarkerData : NSObject

@property(nonatomic, assign) double unitPerSquare;
@property(nonatomic, strong, nullable) NSArray<FHDetailPriceMarkerItem *> *trendItems;
@property(nonatomic, assign) CGPoint selectPoint;
@end

@interface FHDetailPriceMarkerItem : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) FHDetailPriceTrendValuesModel *priceModel;

@end

NS_ASSUME_NONNULL_END

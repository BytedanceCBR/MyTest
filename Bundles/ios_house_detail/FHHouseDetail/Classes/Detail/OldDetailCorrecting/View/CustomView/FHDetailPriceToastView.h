//
//  FHDetailPriceToastView.h
//  PNChartDemo
//
//  Created by 张静 on 2019/2/19.
//  Copyright © 2019年 kevinzhow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailPriceToastData,FHDetailPriceToastItem;

//typedef (CGFloat,FHDetailPriceTrendValuesModel)(^ToastDataBlock)(NSInteger index);

@interface FHDetailPriceToastView : UIView

@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *firstLabel;
@property(nonatomic , strong) UILabel *secondLabel;
@property(nonatomic , strong) UILabel *thirdLabel;

@property(nonatomic, assign) NSInteger selectIndex;
@property(nonatomic, copy, nullable) FHDetailPriceToastData *markData;

- (void)refreshContent:(FHDetailPriceToastData *)markData;

@end

@interface FHDetailPriceToastData : NSObject

@property(nonatomic, assign) double unitPerSquare;
@property(nonatomic, strong, nullable) NSArray<FHDetailPriceToastItem *> *trendItems;
@end

@interface FHDetailPriceToastItem : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) FHDetailPriceTrendValuesModel *priceModel;

@end

NS_ASSUME_NONNULL_END

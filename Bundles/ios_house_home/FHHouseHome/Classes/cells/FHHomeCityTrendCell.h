//
//  FHHomeCityTrendCell.h
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import <UIKit/UIKit.h>
#import "FHHomeBaseTableCell.h"
#import "FHHomeCityTrendView.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHomeCityTrendView;
@class FHConfigDataCityStatsModel;

@interface FHHomeCityTrendCell : FHHomeBaseTableCell

@property(nonatomic, strong)FHHomeCityTrendView *trendView;
@property (nonatomic, copy) void(^clickedDataSourceCallback)(UIButton *btn);

-(void)updateWithModel:(FHConfigDataCityStatsModel *)model;
-(void)updateTrendFont:(BOOL)isSmallSize; // yes表示是找房频道调整字号后

@end

NS_ASSUME_NONNULL_END

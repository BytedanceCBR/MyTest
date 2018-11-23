//
//  FHHomeCityTrendCell.h
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import <UIKit/UIKit.h>
#import "FHHomeBaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHomeCityTrendView;
@class FHConfigDataCityStatsModel;

@interface FHHomeCityTrendCell : FHHomeBaseTableCell

@property(nonatomic, strong)FHHomeCityTrendView *trendView;

-(void)updateWithModel:(FHConfigDataCityStatsModel *)model;

@end

NS_ASSUME_NONNULL_END

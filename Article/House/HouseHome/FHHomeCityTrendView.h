//
//  FHHomeCityTrendView.h
//  Article
//
//  Created by 谢飞 on 2018/11/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FHHomeTrendItemView;
@class FHConfigDataCityStatsModel;

@interface FHHomeCityTrendView : UIView


-(void)updateWithModel:(FHConfigDataCityStatsModel *)model;

@end

NS_ASSUME_NONNULL_END

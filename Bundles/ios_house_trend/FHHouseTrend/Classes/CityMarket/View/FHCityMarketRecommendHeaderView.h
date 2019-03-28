//
//  FHCityMarketRecommendHeaderView.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCityMarketRecommendHeaderView : UIView
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* questionLabel;
@property (nonatomic, strong) UILabel* answerLabel;
@property (nonatomic, strong) UISegmentedControl *segment;
@end

NS_ASSUME_NONNULL_END

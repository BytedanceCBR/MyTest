//
//  FHCityMarketHeaderView.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FHCityMarketHeaderPropertyBar;
@interface FHCityMarketHeaderView : UIView
@property (nonatomic, strong) FHCityMarketHeaderPropertyBar* propertyBar;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* priceLabel;
@property (nonatomic, strong) UILabel* sourceLabel;
@property (nonatomic, strong) UILabel* unitLabel;
@end

NS_ASSUME_NONNULL_END

//
//  FHCityMarketHeaderPropertyBar.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FHCityMarketHeaderPropertyItemView;
@interface FHCityMarketHeaderPropertyBar : UIView
-(void)setPropertyItem:(NSArray<FHCityMarketHeaderPropertyItemView*>*)items;
@end

NS_ASSUME_NONNULL_END

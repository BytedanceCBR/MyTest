//
//  FHCityMarketHeaderPropertyItemView.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCityMarketHeaderPropertyItemView : UIView
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* valueLabel;
@property (nonatomic, strong) UIImageView* arrawView;
-(void)setArraw:(NSInteger)flag;
@end

NS_ASSUME_NONNULL_END

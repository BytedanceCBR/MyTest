//
//  FHCityMarketBottomBarView.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCityMarketBottomBarItem : UIControl
@property (nonatomic, strong) UILabel* titleLabel;
@end

@interface FHCityMarketBottomBarView : UIView
-(void)setBottomBarItems:(NSArray<UIControl*>*)items;
@end

NS_ASSUME_NONNULL_END

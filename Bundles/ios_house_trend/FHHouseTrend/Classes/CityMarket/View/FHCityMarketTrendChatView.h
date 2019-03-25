//
//  FHCityMarketTrendChatView.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCityMarketTrendChatViewInfoItem : NSObject
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* color;
@end

@interface FHCityMarketTrendChatViewInfoBanner : UIView
@property (nonatomic, strong) UILabel* unitLabel;
@property (nonatomic, strong, setter=setItems:) NSArray<FHCityMarketTrendChatViewInfoItem*>* items;
@end

@interface FHCityMarketTrendChatView : UIView
@property (nonatomic, strong) UILabel* titleLable;
@property (nonatomic, strong) FHCityMarketTrendChatViewInfoBanner* banner;
@property (nonatomic, strong) NSArray<NSString*>* categorys;
@end

NS_ASSUME_NONNULL_END

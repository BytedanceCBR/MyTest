//
//  FHCityMarketRecomandHouseCell.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCityMarketRecomandHouseCell : UITableViewCell
@property (nonatomic, strong) UIImageView* tagView;
@property (nonatomic, strong) UIImageView* houseIconView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* subTitleLabel;
@property (nonatomic, strong) UILabel* priceLabel;
@property (nonatomic, strong) UILabel* oldPriceLabel;
@property (nonatomic, strong) UILabel* priceChangeLabel;
@end

NS_ASSUME_NONNULL_END

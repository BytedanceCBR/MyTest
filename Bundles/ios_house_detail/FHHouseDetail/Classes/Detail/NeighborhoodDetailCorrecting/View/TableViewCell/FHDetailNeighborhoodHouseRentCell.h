//
//  FHDetailNeighborhoodHouseRentCell.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/2/24.
//

#import "FHDetailBaseCell.h"
#import "YYText.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNeighborhoodHouseRentCell : FHDetailBaseCell

@end
//在租房源
@interface FHDetailNeighborhoodHouseRentCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIImageView *houseVideoImageView;
@property (nonatomic, weak) UIImageView *iconBacImageView;
@property (nonatomic, strong) YYLabel *descLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *spaceLabel;

@end
NS_ASSUME_NONNULL_END

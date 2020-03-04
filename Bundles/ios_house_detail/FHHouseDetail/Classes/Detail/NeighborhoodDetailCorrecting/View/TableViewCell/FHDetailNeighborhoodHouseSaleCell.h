//
//  FHDetailNeighborhoodHouseSaleCell.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/2/24.
//

#import "FHDetailBaseCell.h"
#import "YYText.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNeighborhoodHouseSaleCell : FHDetailBaseCell

@end
#pragma mark -  CollectionCell

//在售房源
@interface FHDetailNeighborhoodHouseSaleCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIImageView *houseVideoImageView;
@property (nonatomic, weak) UIImageView *iconBacImageView;
@property (nonatomic, strong) YYLabel *descLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *spaceLabel;

@end
NS_ASSUME_NONNULL_END

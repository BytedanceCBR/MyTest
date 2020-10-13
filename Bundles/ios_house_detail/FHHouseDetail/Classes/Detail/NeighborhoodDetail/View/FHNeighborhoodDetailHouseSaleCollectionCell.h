//
//  FHNeighborhoodDetailHouseSaleCollectionCell.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHDetailBaseCell.h"
#import "YYText.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailHouseSaleCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^didSelectItem)(NSInteger index);
@property (nonatomic, copy) void (^didSelectMoreItem)(void);
@property (nonatomic, copy) void (^willShowItem)(NSInteger index);

@end

@interface FHNeighborhoodDetailHouseSaleItemCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIImageView *houseVideoImageView;
@property (nonatomic, weak) UIImageView *iconBacImageView;
@property (nonatomic, strong) YYLabel *descLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *spaceLabel;

@end

@interface FHNeighborhoodDetailHouseSaleCellModel : NSObject
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *neighborhoodSoldHouseData;
@end

NS_ASSUME_NONNULL_END

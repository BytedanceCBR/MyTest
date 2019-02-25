//
//  FHFloorPanDetailMutiFloorPanCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/20.
//

#import "FHDetailBaseCell.h"

@class FHDetailFloorPanDetailInfoDataRecommendModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanDetailMutiFloorPanCell : FHDetailBaseCell

@end


#pragma mark -  CollectionCell

// 楼盘item
@interface FHFloorPanDetailMutiFloorPanCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong)   UIImageView       *icon;
@property (nonatomic, strong)   UILabel       *descLabel;
@property (nonatomic, strong)   UILabel       *statusLabel;
@property (nonatomic, strong)   UILabel       *priceLabel;
@property (nonatomic, strong)   UILabel       *spaceLabel;


@end

@interface FHFloorPanDetailMutiFloorPanCellModel : JSONModel
@property (nonatomic, strong , nullable) NSArray<FHDetailFloorPanDetailInfoDataRecommendModel *> *recommend;
@property (nonatomic, strong , nullable) NSDictionary *subPageParams;
@end

NS_ASSUME_NONNULL_END

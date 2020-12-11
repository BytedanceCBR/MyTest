//
//  FHNeighborhoodDetailHeaderTitleCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHDetailBaseCell.h"
#import <IGListKit/IGListKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailHeaderTitleCollectionCell : FHDetailBaseCollectionCell<IGListBindable>

@property (nonatomic, copy) void(^mapBtnClickBlock)();

@end

@interface FHNeighborhoodDetailHeaderTitleModel : NSObject<IGListDiffable>
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *districtName;//区域
@property (nonatomic, copy) NSString *tradeAreaName;//商圈
@property (nonatomic, copy) NSString *areaName;//街道


@property (nonatomic, copy, nullable) NSString *gaodeLng;
@property (nonatomic, copy, nullable) NSString *gaodeLat;
@property (nonatomic, copy, nullable) NSString *mapCentertitle;
@property (nonatomic, copy, nullable) NSString *baiduPanoramaUrl;

@end

NS_ASSUME_NONNULL_END

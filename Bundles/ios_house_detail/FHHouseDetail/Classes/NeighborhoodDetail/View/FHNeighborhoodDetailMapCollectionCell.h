//
//  FHNeighborhoodDetailMapCollectionCell.h
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/9.
//

#import "FHDetailBaseCell.h"
#import "FHDetailStaticMap.h"
#import <IGListKit/IGListKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailMapCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void(^mapBtnClickBlock)(NSString *);
@property (nonatomic, copy) void(^categoryClickBlock)(NSString *);
@property (nonatomic, copy) void (^baiduPanoramaBlock)(void);

@end

@interface FHNeighborhoodDetailMapCellModel : NSObject

@property(nonatomic, copy, nullable) NSString *gaodeLng;
@property(nonatomic, copy, nullable) NSString *gaodeLat;
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *houseId;
@property(nonatomic, copy, nullable) NSString *mapCentertitle;
@property(nonatomic, copy, nullable) NSString *houseType;
@property(nonatomic, copy, nullable) NSString *score;
@property(nonatomic, strong, nullable) FHDetailGaodeImageModel *staticImage;
@property(nonatomic, assign) BOOL useNativeMap; //降级控制，外部不使用
@property(nonatomic, assign) CGFloat topMargin; //小区详情页使用
@property(nonatomic, assign) CGFloat bottomMargin;

@property (nonatomic, copy, nullable) NSString *baiduPanoramaUrl;

@property (nonatomic, copy, nullable) NSString *emptyString;
@property (nonatomic, copy, nullable) NSArray<FHStaticMapAnnotation *> *annotations;

@end

NS_ASSUME_NONNULL_END

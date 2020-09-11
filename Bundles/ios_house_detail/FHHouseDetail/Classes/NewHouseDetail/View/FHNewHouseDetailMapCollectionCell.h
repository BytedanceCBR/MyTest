//
//  FHNewHouseDetailMapCollectionCell.h
//  Pods
//
//  Created by bytedance on 2020/9/11.
//

#import "FHDetailBaseCell.h"
#import "FHDetailStaticMap.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailMapCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^refreshActionBlock)(void);

@end

@interface FHNewHouseDetailMapCellModel : NSObject

@property(nonatomic, copy, nullable) NSString *gaodeLng;
@property(nonatomic, copy, nullable) NSString *gaodeLat;
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *houseId;
@property(nonatomic, copy, nullable) NSString *mapCentertitle;
@property(nonatomic, copy, nullable) NSString *houseType;
@property(nonatomic, copy, nullable) NSString *score;
@property(nonatomic, strong, nullable) FHDetailGaodeImageModel *staticImage;
@property(nonatomic, assign) BOOL mapOnly;
@property(nonatomic, assign) BOOL useNativeMap; //降级控制，外部不使用
@property(nonatomic, assign) CGFloat topMargin; //小区详情页使用
@property(nonatomic, assign) CGFloat bottomMargin;

@property (nonatomic, copy, nullable) NSString *baiduPanoramaUrl;

@property (nonatomic, copy, nullable) NSString *emptyString;
@property (nonatomic, copy, nullable) NSArray<FHStaticMapAnnotation *> *annotations;

@end

NS_ASSUME_NONNULL_END

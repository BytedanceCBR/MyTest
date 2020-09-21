//
//  FHNewHouseDetailSurroundingSM.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSectionModel.h"
#import "MAMapKit.h"

NS_ASSUME_NONNULL_BEGIN

@class FHNewHouseDetailSurroundingCellModel;
@class FHNewHouseDetailMapCellModel;

@interface FHNewHouseDetailSurroundingSM : FHNewHouseDetailSectionModel

@property (nonatomic, copy) NSString *baiduPanoramaUrl;
@property (nonatomic, assign) CLLocationCoordinate2D centerPoint;
@property (nonatomic, copy) NSString *mapCentertitle;
@property(nonatomic, copy) NSString *curCategory;

@property (nonatomic, strong) FHNewHouseDetailSurroundingCellModel *surroundingCellModel;

@property (nonatomic, strong) FHNewHouseDetailMapCellModel *mapCellModel;

- (NSArray *)dataItems;

@end

NS_ASSUME_NONNULL_END

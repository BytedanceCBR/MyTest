//
//  FHNeighborhoodDetailFlowLayout.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FHNeighborhoodDetailSectionModel;

@interface FHNeighborhoodDetailFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, copy) NSArray<FHNeighborhoodDetailSectionModel *> *sectionModels;

@property (nonatomic, assign) BOOL hasShowFloorpanInfo;
@end

NS_ASSUME_NONNULL_END

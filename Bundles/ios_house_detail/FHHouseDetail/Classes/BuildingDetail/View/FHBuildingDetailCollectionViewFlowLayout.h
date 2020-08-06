//
//  FHBuildingDetailCollectionViewFlowLayout.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHBuildingDetailDataItemModel;

@interface FHBuildingDetailCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) FHBuildingDetailDataItemModel *model;
@property (nonatomic, assign) BOOL existTopImageView;
@end

NS_ASSUME_NONNULL_END

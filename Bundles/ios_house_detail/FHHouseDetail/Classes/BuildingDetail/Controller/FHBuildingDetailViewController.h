//
//  FHBuildingDetailViewController.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "FHBaseViewController.h"
@class FHBuildingIndexModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHBuildingDetailViewController : FHBaseViewController

- (void)reloadData;
@property (nonatomic, strong) FHBuildingIndexModel *currentIndex;
@end

NS_ASSUME_NONNULL_END

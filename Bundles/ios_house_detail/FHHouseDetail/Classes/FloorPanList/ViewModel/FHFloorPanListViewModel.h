//
//  FHFloorPanListViewModel.h
//  FHHouseDetail
//
//  Created by bytedance on 2021/1/4.
//

#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailNewModel.h"
#import "HMSegmentedControl.h"

NS_ASSUME_NONNULL_BEGIN
@class FHHouseDetailSubPageViewController;

@interface FHFloorPanListViewModel : FHHouseDetailBaseViewModel
-(instancetype)initWithController:(FHHouseDetailSubPageViewController *)viewController collectionView:(UICollectionView *)collectionView SegementView:(UIView *)segmentView courtId:(NSString *)courtId;

@end

NS_ASSUME_NONNULL_END

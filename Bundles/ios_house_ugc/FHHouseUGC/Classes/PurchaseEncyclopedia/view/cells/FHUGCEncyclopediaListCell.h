//
//  FHUGCEncyclopediaListCell.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/21.
//

#import "FHUGCBaseCell.h"
#import "FHTracerModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHUGCEncyclopediaListCell : UICollectionViewCell
- (UIViewController *)contentViewController;
@property(nonatomic, copy)NSDictionary *headerConfigData;
@property(nonatomic, strong) FHTracerModel *tracerModel;
@end

NS_ASSUME_NONNULL_END

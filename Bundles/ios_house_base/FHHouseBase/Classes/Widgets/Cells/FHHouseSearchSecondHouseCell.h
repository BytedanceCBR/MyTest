//
//  FHHouseSearchSecondHouseCell.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/8/24.
//

#import "FHListBaseCell.h"

NS_ASSUME_NONNULL_BEGIN
//新二手房列表页、搜索页cell
@interface FHHouseSearchSecondHouseCell : FHListBaseCell

- (void)resumeVRIcon;

- (void)updateHeightByIsFirst:(BOOL)isFirst;

@end

NS_ASSUME_NONNULL_END

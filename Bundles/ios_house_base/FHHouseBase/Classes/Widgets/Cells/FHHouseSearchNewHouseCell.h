//
//  FHHouseSearchNewHouseCell.h
//  Pods
//
//  Created by xubinbin on 2020/8/27.
//

#import "FHListBaseCell.h"
#import "FHHouseCardStatusManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseSearchNewHouseCell : FHListBaseCell<FHHouseCardReadStateProtocol, FHHouseCardTouchAnimationProtocol>

- (void)resumeVRIcon;

- (void)updateHeightByIsFirst:(BOOL)isFirst;

- (void)updateHeightByTopMargin:(CGFloat)topMarigin;

@end

NS_ASSUME_NONNULL_END

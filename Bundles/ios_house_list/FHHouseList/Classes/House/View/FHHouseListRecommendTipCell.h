//
//  FHHouseListRecommendTipCell.h
//  FHHouseList
//
//  Created by 张静 on 2019/11/12.
//

#import "FHListBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListRecommendTipCell : FHListBaseCell

@property (nonatomic , copy) void (^channelSwitchBlock)(void);

@end

NS_ASSUME_NONNULL_END

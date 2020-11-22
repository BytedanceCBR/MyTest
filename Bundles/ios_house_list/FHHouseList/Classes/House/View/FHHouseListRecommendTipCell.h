//
//  FHHouseListRecommendTipCell.h
//  FHHouseList
//
//  Created by 张静 on 2019/11/12.
//

#import "FHListBaseCell.h"
#import "FHErrorView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListRecommendTipCell : FHListBaseCell

@property (nonatomic , copy) void (^channelSwitchBlock)(void);
@property (nonatomic, strong) FHErrorView *errorView;

@end

NS_ASSUME_NONNULL_END

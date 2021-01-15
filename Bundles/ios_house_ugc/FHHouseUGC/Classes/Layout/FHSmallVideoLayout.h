//
//  FHSmallVideoLayout.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/15.
//

#import "FHBaseLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSmallVideoLayout : FHBaseLayout

@property(nonatomic ,strong) FHLayoutItem *userInfoViewLayout;
@property(nonatomic ,strong) FHLayoutItem *contentLabelLayout;
@property(nonatomic ,strong) FHLayoutItem *videoImageViewLayout;
@property(nonatomic ,strong) FHLayoutItem *bottomViewLayout;
@property(nonatomic ,strong) FHLayoutItem *playIconLayout;
@property(nonatomic ,strong) FHLayoutItem *timeBgViewLayout;
@property(nonatomic ,strong) FHLayoutItem *timeLabelLayout;

@end

NS_ASSUME_NONNULL_END

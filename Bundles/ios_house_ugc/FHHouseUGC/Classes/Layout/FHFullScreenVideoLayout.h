//
//  FHFullScreenVideoLayout.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/15.
//

#import "FHBaseLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFullScreenVideoLayout : FHBaseLayout

@property(nonatomic ,strong) FHLayoutItem *iconLayout;
@property(nonatomic ,strong) FHLayoutItem *userNameLayout;
@property(nonatomic ,strong) FHLayoutItem *contentLabelLayout;
@property(nonatomic ,strong) FHLayoutItem *videoViewLayout;
@property(nonatomic ,strong) FHLayoutItem *bottomViewLayout;
@property(nonatomic ,strong) FHLayoutItem *mutedBgViewLayout;
@property(nonatomic ,strong) FHLayoutItem *muteBtnLayout;
@property(nonatomic ,strong) FHLayoutItem *videoLeftTimeLayout;

@end

NS_ASSUME_NONNULL_END

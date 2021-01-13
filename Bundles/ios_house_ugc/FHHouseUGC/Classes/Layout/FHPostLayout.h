//
//  FHPostLayout.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/14.
//

#import "FHBaseLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPostLayout : FHBaseLayout

@property(nonatomic ,strong) FHLayoutItem *userInfoViewLayout;
@property(nonatomic ,strong) FHLayoutItem *contentLabelLayout;
@property(nonatomic ,strong) FHLayoutItem *multiImageViewLayout;
@property(nonatomic ,strong) FHLayoutItem *singleImageViewLayout;
@property(nonatomic ,strong) FHLayoutItem *bottomViewLayout;
@property(nonatomic ,strong) FHLayoutItem *originViewLayout;
@property(nonatomic ,strong) FHLayoutItem *attachCardViewLayout;

@end

NS_ASSUME_NONNULL_END

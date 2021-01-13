//
//  FHAnswerLayout.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/14.
//

#import "FHBaseLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHAnswerLayout : FHBaseLayout

@property(nonatomic ,strong) FHLayoutItem *userInfoViewLayout;
@property(nonatomic ,strong) FHLayoutItem *userImaLayout;
@property(nonatomic ,strong) FHLayoutItem *usernameLayout;
@property(nonatomic ,strong) FHLayoutItem *userideLayout;
@property(nonatomic ,strong) FHLayoutItem *contentLabelLayout;
@property(nonatomic ,strong) FHLayoutItem *multiImageViewLayout;
@property(nonatomic ,strong) FHLayoutItem *singleImageViewLayout;
@property(nonatomic ,strong) FHLayoutItem *bottomViewLayout;

@end

NS_ASSUME_NONNULL_END

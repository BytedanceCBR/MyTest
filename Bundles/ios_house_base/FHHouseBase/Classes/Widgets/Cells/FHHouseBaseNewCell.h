//
//  FHHouseBaseNewCell.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/10/23.
//

#import "FHHouseBaseCell.h"
#import "UIColor+Theme.h"
#import <HTSVideoPlay/Yoga.h>
#import <HTSVideoPlay/UIView+Yoga.h>
#import "FHCommonDefines.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>


NS_ASSUME_NONNULL_BEGIN

@interface FHHouseBaseNewCell : FHHouseBaseCell

@property (nonatomic, strong) UILabel *statInfoLabel; //新房状态信息
@property (nonatomic, strong) UIView *bottomRecommendView;//底部推荐理由
@property (nonatomic, strong) UIView *bottomRecommendViewBack;//底部背景
@property (nonatomic, strong) UIImageView *bottomIconImageView; //活动icon
@property (nonatomic, strong) UILabel *bottomRecommendLabel; //活动title

@end

NS_ASSUME_NONNULL_END

//
//  FHHouseBaseNewCell.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/10/23.
//

#import "FHHouseBaseCell.h"
#import "FHCommonDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface FHHouseBaseNewCell : FHHouseBaseCell

@property (nonatomic, strong) UILabel *statInfoLabel; //新房状态信息
@property (nonatomic, strong) UIView *bottomRecommendView;//底部推荐理由
@property (nonatomic, strong) UIView *bottomRecommendViewBack;//底部背景
@property (nonatomic, strong) UIImageView *bottomIconImageView; //活动icon
@property (nonatomic, strong) UILabel *bottomRecommendLabel; //活动title
@property (nonatomic, strong, readwrite) UILabel *subTitleLabel;

@end

NS_ASSUME_NONNULL_END

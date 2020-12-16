//
//  FHNeighborhoodDetailRecommendTitleView.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailRecommendTitleView : UICollectionReusableView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIImageView *arrowsImg;

@property (nonatomic, copy) void (^moreActionBlock)(void);

- (void)setSubTitleWithTitle:(NSString *)subTitle;

- (void)setupNeighborhoodDetailStyle;

@end

NS_ASSUME_NONNULL_END

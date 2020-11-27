//
//  FHDetailSectionRelatedTitleCollectionView.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHDetailSectionTitleCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailSectionRelatedTitleCollectionView : UICollectionReusableView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIImageView *arrowsImg;

@property (nonatomic, copy) void (^moreActionBlock)(void);

- (void)setSubTitleWithTitle:(NSString *)subTitle;

@end

NS_ASSUME_NONNULL_END

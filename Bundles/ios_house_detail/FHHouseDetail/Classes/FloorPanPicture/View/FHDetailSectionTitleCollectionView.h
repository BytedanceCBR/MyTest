//
//  FHPictureListTitleCollectionView.h
//  Pods
//
//  Created by bytedance on 2020/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailSectionTitleCollectionView : UICollectionReusableView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIImageView *arrowsImg;

@property (nonatomic, copy) void (^moreActionBlock)(void);

- (void)setSubTitleWithTitle:(NSString *)subTitle;
@end

NS_ASSUME_NONNULL_END

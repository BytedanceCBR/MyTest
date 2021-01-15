//
//  FHDetailMoreView.h
//  FHHouseDetail
//
//  Created by wangzhizhou on 2021/1/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FHDetailMoreViewTapAction)(id data);
@interface FHDetailMoreView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *rightArrowImageView;
@property (nonatomic, strong) FHDetailMoreViewTapAction tapBlock;

+ (UIImage *)moreArrowImage;
@end

NS_ASSUME_NONNULL_END

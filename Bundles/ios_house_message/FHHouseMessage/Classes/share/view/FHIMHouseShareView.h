//
//  FHIMHouseShareView.h
//  ios_house_im
//
//  Created by leo on 2019/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHIMHouseShareView : UIView
@property (nonatomic, strong) UIImageView* houseImage;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* subTitleLabel;
@property (nonatomic, strong) UILabel* totalPriceLabel;
@property (nonatomic, strong) UILabel* pricePerSqmLabel;
@end

NS_ASSUME_NONNULL_END

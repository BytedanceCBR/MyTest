//
//  FHHomeTrendItemView.h
//  Article
//
//  Created by 张静 on 2018/11/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeTrendItemView : UIView

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;
@property(nonatomic, strong) UIImageView *icon;

@property(nonatomic, assign) CGFloat leftPadding;
@property(nonatomic, assign) CGFloat rightPadding;

@end

NS_ASSUME_NONNULL_END

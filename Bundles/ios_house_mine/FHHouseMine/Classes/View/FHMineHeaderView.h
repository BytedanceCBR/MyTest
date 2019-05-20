//
//  FHMineHeaderView.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMineHeaderView : UIView

@property(nonatomic, strong) UIImageView *beforeHeaderView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIImageView *editIcon;

- (void)updateAvatar:(NSString *)avatarUrl;

- (void)setUserInfoState:(NSInteger)state;

- (instancetype)initWithFrame:(CGRect)frame naviBarHeight:(CGFloat)naviBarHeight;

@end

NS_ASSUME_NONNULL_END

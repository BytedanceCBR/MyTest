//
//  TSVAvatarImageView.h
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/8.
//

#import <TTAvatar/ExploreAvatarView+VerifyIcon.h>

@class TSVUserModel;

@interface TSVAvatarImageView : ExploreAvatarView

/**
 边框宽度
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 边框颜色
 */
@property (nonatomic, strong) UIColor *borderColor;


- (instancetype)initWithFrame:(CGRect)frame model:(TSVUserModel *)model disableNightMode:(BOOL)disable;

- (void)refreshWithModel:(TSVUserModel *)model;

@end

//
//  FHUGCProgressView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/8/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCProgressView : UIView

//当前进度，0到1的值
@property(nonatomic, assign) CGFloat progress;
//分开的距离
@property(nonatomic, assign) CGFloat offset;

//设置左边条
@property(nonatomic, assign) CGFloat isLeftGradient;
@property(nonatomic, strong) UIColor *leftColor;
@property(nonatomic, strong) UIColor *leftStartColor;
@property(nonatomic, strong) UIColor *leftEndColor;

//设置右边条
@property(nonatomic, assign) CGFloat isRightGradient;
@property(nonatomic, strong) UIColor *rightColor;
@property(nonatomic, strong) UIColor *rightStartColor;
@property(nonatomic, strong) UIColor *rightEndColor;

@end

NS_ASSUME_NONNULL_END

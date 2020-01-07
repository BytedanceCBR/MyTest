//
//  UIAlertController+TTAdditions.h
//  TTBaseLib
//
//  Created by Jiang Jingtao on 2019/8/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (TTAdditions)

//sourceRect 默认是sourceView的bounds
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle sourceView:(UIView *)sourceView;

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect;

@end

NS_ASSUME_NONNULL_END

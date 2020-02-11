//
//  UIViewController+ForceLightMode.m
//  FHBHouseBase
//
//  Created by 春晖 on 2020/1/17.
//

#import "UIViewController+ForceLightMode.h"
#import <ByteDanceKit/NSObject+BTDAdditions.h>

@implementation UIViewController (ForceLightMode)

-(UIUserInterfaceStyle)overrideUserInterfaceStyle
{
    //强制lighmodel,待后续适配dark模式时再去掉
    return UIUserInterfaceStyleLight;
}

@end

@implementation UIApplication (ForceLightMode)
+(void)load {
    static dispatch_once_t onceToken;
       dispatch_once(&onceToken, ^{
           [self btd_swizzleInstanceMethod:@selector(setStatusBarStyle:) with:@selector(setStatusBarStyle_forceLightMode:)];
       });
}

- (void)setStatusBarStyle_forceLightMode:(UIStatusBarStyle)statusBarStyle {
    if (@available(iOS 13.0 , *)) {
        // 13 系统 暗黑模式 修改UIStatusBarStyleDefault为UIStatusBarStyleDarkContent
        if (statusBarStyle == UIStatusBarStyleDefault) {
            [self setStatusBarStyle_forceLightMode:UIStatusBarStyleDarkContent];
        } else {
            [self setStatusBarStyle_forceLightMode:statusBarStyle];
        }
    } else {
        // 非13系统 不变
         [self setStatusBarStyle_forceLightMode:statusBarStyle];
    }
}
@end

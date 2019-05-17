//
//  UITabBarController+TabbarConfig.m
//  TestUniversaliOS6
//
//  Created by yuxin on 3/27/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

@import ObjectiveC;

#import "UITabBarController+TabbarConfig.h"
#import "UIColor+TTThemeExtension.h"
#import "UIImage+TTThemeExtension.h"



@implementation UITabBarController (TabbarConfig)


- (NSString*)ttTabBarStyle {
    return (NSString*)objc_getAssociatedObject(self, @selector(ttTabBarStyle));
}

- (void)setTtTabBarStyle:(NSString *)ttTabBarStyle {
    objc_setAssociatedObject(self, @selector(ttTabBarStyle),ttTabBarStyle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

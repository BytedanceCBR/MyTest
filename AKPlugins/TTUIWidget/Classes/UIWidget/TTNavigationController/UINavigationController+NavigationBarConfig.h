//
//  UINavigationController+NavigationBarConfig.h
//  TestUniversaliOS6
//
//  Created by yuxin on 3/26/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
 

@interface UINavigationController (NavigationBarConfig)

@property (nonatomic, assign) BOOL  isPop;

@property (nonatomic, copy) IBInspectable NSString * ttDefaultNavBarStyle;


- (void)tt_reloadTheme;

- (void)tt_configNavBarWithTheme:(NSString *)style;


@end

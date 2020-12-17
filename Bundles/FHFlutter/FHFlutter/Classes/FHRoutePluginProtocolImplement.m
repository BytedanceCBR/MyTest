//
//  RoutePluginProtocolImplement.m
//  Runner
//
//  Created by 白昆仑 on 2019/8/21.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "FHRoutePluginProtocolImplement.h"
#import "FlutterViewWrapperController.h"
#import "TTRoute.h"
#import "NSString+BTDAdditions.h"

@interface FHRoutePluginProtocolImplement () <UIGestureRecognizerDelegate>

@end

@implementation FHRoutePluginProtocolImplement

- (void)flutterWrapperController:(UIViewController *)wrapperController handleNativeRoute:(NSString * _Nonnull)openURL params:(NSDictionary * _Nonnull)params {
    void (^invokBlock)(void) = ^() {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        
        TTRouteUserInfo *userInfo = nil;
        if ([params isKindOfClass:[NSDictionary class]]) {
            userInfo = [[TTRouteUserInfo alloc] initWithInfo:params];
        }
        NSURL *schemaUrl = [NSURL URLWithString:openURL];
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:openURL] userInfo:userInfo];
    };
    if ([NSThread isMainThread]) {
        invokBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), invokBlock);
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

// 显示/隐藏navigationBar
- (void)flutterWrapperController:(UIViewController*)controller showNavigationBar:(BOOL)isShow {
    controller.navigationController.navigationBarHidden = !isShow;
}

- (void)flutterWrapperController:(UIViewController *)controller enableInteractivePopGesture:(BOOL)enabled {
    
}

- (void)flutterWrapperController:(UIViewController *)controller updateDragBackLeftEdge:(CGFloat)edge {
    
}

@end

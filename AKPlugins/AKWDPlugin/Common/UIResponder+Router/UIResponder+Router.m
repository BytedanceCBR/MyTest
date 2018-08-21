//
//  UIResponder+Router.m
//  Pods
//
//  Created by wangqi.kaisa on 2017/9/6.
//
//

#import "UIResponder+Router.h"

@implementation UIResponder (Router)

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    [[self nextResponder] routerEventWithName:eventName userInfo:userInfo];
}

@end

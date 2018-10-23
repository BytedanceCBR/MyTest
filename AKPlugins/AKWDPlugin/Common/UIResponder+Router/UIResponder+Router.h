//
//  UIResponder+Router.h
//  Pods
//
//  Created by wangqi.kaisa on 2017/9/6.
//
//

#import <UIKit/UIKit.h>

@interface UIResponder (Router)

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

@end

//
//  TSVUIResponderHelper.h
//  AFgzipRequestSerializer
//
//  Created by 王双华 on 2017/11/10.
//

#import <Foundation/Foundation.h>

@interface TSVUIResponderHelper : NSObject

/** 获取当前应用响应链最上游的UIViewController对象，使用topViewControllerFor: */
+ (nullable UIViewController*)topmostViewController;

@end

//
//  TTStopWatch.h
//  Article
//
//  Created by fengyadong on 2017/11/16.
//

#import <Foundation/Foundation.h>

@interface TTStopWatch : NSObject

+ (void)start:(NSString *)name;
+ (NSTimeInterval)stop:(NSString *)name;

@end

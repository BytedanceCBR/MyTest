//
//  SSExceptionHandler.h
//  Article
//
//  Created by Dianwei on 13-5-5.
//
//

#import <Foundation/Foundation.h>

@interface SSExceptionHandler : NSObject
+ (void)setUmengHandler:(NSUncaughtExceptionHandler*)umHandlder;
+ (NSUncaughtExceptionHandler*)UmengHandler;
+ (void)installUnCaughtExceptionHandler;
+ (void)handleException:(NSException*)exception;
+ (NSArray*)backtraces;
@end

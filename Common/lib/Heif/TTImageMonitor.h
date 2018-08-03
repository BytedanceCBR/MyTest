//
//  TTImageMonitor.h
//  Article
//
//  Created by fengyadong on 2017/11/17.
//

#import <Foundation/Foundation.h>

@interface TTImageMonitor : NSObject

+ (BOOL)enableHeifImageForSource:(NSString *)source;
+ (BOOL)enableImageMonitorForSource:(NSString *)source;

@end

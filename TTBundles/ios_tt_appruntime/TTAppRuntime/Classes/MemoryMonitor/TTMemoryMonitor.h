//
//  TTMemoryMonitor.h
//  Article
//
//  Created by 冯靖君 on 16/10/18.
//
//

#import <Foundation/Foundation.h>

@interface TTMemoryMonitor : NSObject

+ (CGFloat)currentMemoryUsageInMBytes;
+ (CGFloat)currentMemoryUsageByAppleFormula;

+ (void)showMemoryMonitor;
+ (void)hideMemoryMonitor;
+ (void)NoHideMemoryMonitor;

@end

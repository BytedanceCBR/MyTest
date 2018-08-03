//
//  TTFPSMonitor.h
//  testTintPerformance
//
//  Created by tyh on 2017/11/15.
//  Copyright © 2017年 tyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTFPSMonitor : NSObject

+ (instancetype)sharedMonitor;

- (void)startMonitor;
@end

//
//  SSAlertCenter.h
//  Essay
//
//  Created by Tianhang Yu on 12-5-7.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSBaseAlertManager;

@interface SSAlertCenter : NSObject

+ (SSAlertCenter *)defaultCenter;

- (BOOL)addAlert:(SSBaseAlertManager *)alert;      // return no when alertSet contains alert
- (BOOL)removeAlert:(SSBaseAlertManager *)alert;   // return no when alertSet does not contain alert
- (BOOL)refresh;    // return YES if alert center restart
- (void)clearAllAlerts;
- (void)pauseAlertCenter;
- (void)resumeAlertCenter;     // default start

@end

//
//  AppAlert.h
//  Essay
//
//  Created by Tianhang Yu on 12-5-7.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "SSBaseAlertManager.h"

@interface AppAlertManager : SSBaseAlertManager
- (void)startAlertWithLocalResult:(NSDictionary *)result;
- (void)startAlertWithTopViewController:(UIViewController *)topViewController;
@end

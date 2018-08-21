//
//  AWEVideoPlayTrackerBridge.h
//  Pods
//
//  Created by lili.01 on 18/11/2016.
//
//

#import <Foundation/Foundation.h>

@interface AWEVideoPlayTrackerBridge : NSObject

//Applog3.0
+ (void)trackEvent:(NSString *)event params:(NSDictionary *)params;

@end

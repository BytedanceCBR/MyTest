//
//  AWEVideoDetailTrackingInfo.h
//  Pods
//
//  Created by Zuyang Kou on 03/07/2017.
//
//

#import <Foundation/Foundation.h>

@class TTShortVideoModel;

@interface AWEVideoDetailTracker : NSObject

+ (void)trackEvent:(NSString *)event
             model:(TTShortVideoModel *)model
   commonParameter:(NSDictionary *)commonParameter
    extraParameter:(NSDictionary *)dictionary;

- (void)flushStayPageTime;
- (NSTimeInterval)timeIntervalForStayPage;

@end

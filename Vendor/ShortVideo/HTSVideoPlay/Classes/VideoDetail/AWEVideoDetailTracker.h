//
//  AWEVideoDetailTrackingInfo.h
//  Pods
//
//  Created by Zuyang Kou on 03/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "FHFeedUGCCellModel.h"

@interface AWEVideoDetailTracker : NSObject

+ (void)trackEvent:(NSString *)event
             model:(FHFeedUGCCellModel *)model
   commonParameter:(NSDictionary *)commonParameter
    extraParameter:(NSDictionary *)dictionary;

- (void)flushStayPageTime;
- (NSTimeInterval)timeIntervalForStayPage;

@end

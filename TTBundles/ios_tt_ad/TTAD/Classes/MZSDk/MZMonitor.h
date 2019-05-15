//
//  MZMonitor.h
//  AdTracking_iOS_SDK
//
//  Created by Merlin on 12/1/15.
//  Copyright © 2015 Miaozhen Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MZMonitor : NSObject

+ (NSString *)version;
+ (void)debug:(BOOL)enabled;

+ (void)adTrack:(NSString *)trackingURL;
+ (void)adTrackClick:(NSString *)trackingURL;
+ (long)adTrackDisplay:(NSString *)trackingURL adView:(UIView *)adView;
+ (long)adTrackVideo:(NSString *)trackingURL adView:(UIView *)adView;
+ (void)adTrackStop:(long)trackId;
+ (void)adTrack:(NSString *)trackingURL withUserId:(NSString *)userId;
+ (void)adTrack:(NSString *)trackingURL withIESId:(NSString *)iesId;

+ (void)panelTrack:(NSString *)trackingURL withPanelId:(NSString *)panelId withUserId:(NSString *)userId;

+ (void)eventTrack:(NSString *)trackingURL eventName:(NSString *)eventName;

+ (void)retryCachedRequests;

+ (void)setOption:(NSString *)key withValue:(BOOL)value;
+ (void)setViewableTrackerTimeOut:(NSString *)key withValue:(NSInteger)value;

+ (void)reportAction:(NSString *)trackingURL __attribute__((deprecated));
+ (void)reportAction:(NSString *)trackingURL withPanelId:(NSString *)panelId withUserId:(NSString *)userId __attribute__((deprecated));

+ (void)reSendReport __attribute__((deprecated));

+ (BOOL)isMZURL:(NSString *)urlStr __attribute__((deprecated));

@end

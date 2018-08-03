//
//  VideoGetUpdateNumberManager.h
//  Video
//
//  Created by 于 天航 on 12-8-16.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kVideoGetUpdatesTimestampUserDefaultKey @"kVideoGetUpdatesTimestampUserDefaultKey"
static inline void setGetUpdatesTimestamp (NSNumber *timestamp) {
    [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:kVideoGetUpdatesTimestampUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline NSNumber* updatesTimestamp () {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kVideoGetUpdatesTimestampUserDefaultKey];
}

#define kVideoGetUpdatesTagKey @"kVideoGetUpdatesTagKey"
#define kVideoGetUpdatesTimestampKey @"kVideoGetUpdatesTimestampKey"

@class VideoGetUpdatesNumberManager;

@protocol VideoGetUpdatesNumberDelegate <NSObject>

@optional
- (void)videoGetUpdatesNumberManager:(VideoGetUpdatesNumberManager *)manager didGetUpdatesNumber:(NSDictionary *)updateNumberList error:(NSError *)error;

@end


@interface VideoGetUpdatesNumberManager : NSObject

@property (nonatomic, assign) id<VideoGetUpdatesNumberDelegate> delegate;
@property (nonatomic, retain) NSArray *timestamps;

+ (VideoGetUpdatesNumberManager *)sharedManager;
- (void)timingGetUpdatesNumber;

@end

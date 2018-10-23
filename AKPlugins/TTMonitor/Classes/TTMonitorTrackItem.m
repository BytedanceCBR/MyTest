//
//  TTMonitorTrackItem.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/1.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTMonitorTrackItem.h"

@implementation TTMonitorTrackItem


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
        @try {
            self.track = [aDecoder decodeObjectForKey:@"track"];
            self.retryCount = [aDecoder decodeInt64ForKey:@"retryCount"];
        }
        @catch (NSException *exception) {
            self.track = nil;
            self.retryCount = 10;//默认的最大max 为4， 设置为10是直接让retry count超过最大值， 10是拍脑门估计的的，大于max（4）即可. ┭┮﹏┭┮
        }
        @finally {
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    @try {
        if ([self.track isKindOfClass:[NSDictionary class]]) {
            [aCoder encodeObject:self.track forKey:@"track"];
        }
        [aCoder encodeInt64:self.retryCount forKey:@"retryCount"];
    }
    @catch (NSException *exception) {
    }
    @finally {
        
    }
}

@end

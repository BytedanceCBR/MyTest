//
//  TTDebugRealNetworkStoreItem.m
//  Pods
//
//  Created by 苏瑞强 on 16/12/28.
//
//

#import "TTDebugRealNetworkStoreItem.h"

#define kREQUEST_I_D                            @"requestID"
#define kSTART_TIME                             @"startTime"
#define kERROR                                  @"error"
#define kDURATION                               @"duration"
#define kHAS_TRIED_TIMES 						@"hasTriedTimes"
#define kREQUEST_URL                            @"requestUrl"

@implementation TTDebugRealNetworkStoreItem

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.requestID forKey:kREQUEST_I_D];
    [encoder encodeObject:self.startTime forKey:kSTART_TIME];
    [encoder encodeObject:self.error forKey:kERROR];
    [encoder encodeDouble:self.duration forKey:kDURATION];
    [encoder encodeInteger:self.hasTriedTimes forKey:kHAS_TRIED_TIMES];
    [encoder encodeObject:self.requestUrl forKey:kREQUEST_URL];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.requestID = [decoder decodeObjectForKey:kREQUEST_I_D];
        self.startTime = [decoder decodeObjectForKey:kSTART_TIME];
        self.error = [decoder decodeObjectForKey:kERROR];
        [self setDuration:[decoder decodeDoubleForKey:kDURATION]];
        self.hasTriedTimes = [decoder decodeIntegerForKey:kHAS_TRIED_TIMES];
        self.requestUrl = [decoder decodeObjectForKey:kREQUEST_URL];
    }
    return self;
}

@end

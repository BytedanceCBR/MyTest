//
//  TTVNetworkMonitorState.m
//  TTVPlayer
//
//  Created by lisa on 2019/2/13.
//

#import "TTVNetworkMonitorState.h"

@implementation TTVNetworkMonitorState

- (instancetype)copyWithZone:(NSZone *)zone {
    TTVNetworkMonitorState * copy = [TTVNetworkMonitorState allocWithZone:zone];
    copy.pausingBycellularNetwork = self.pausingBycellularNetwork;
    copy.flowTipViewShowed = self.flowTipViewShowed;
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (!other) {
        return NO;
    }
    if (self == other)  {
        return YES;
    }
    
    if (![other isKindOfClass:[TTVNetworkMonitorState class]]) {
        return NO;
    }
    return [self isEqualToState:(TTVNetworkMonitorState *)other];
}

- (BOOL)isEqualToState:(TTVNetworkMonitorState *)other {
    if (self.pausingBycellularNetwork == other.pausingBycellularNetwork &&
        self.flowTipViewShowed == other.flowTipViewShowed) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.pausingBycellularNetwork ^ self.flowTipViewShowed;
}

@end

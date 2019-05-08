//
//  FHUnreadMsgDataUnreadModel+Comparable.m
//  AFgzipRequestSerializer
//
//  Created by leo on 2019/2/18.
//

#import "FHUnreadMsgDataUnreadModel+Comparable.h"

@implementation FHUnreadMsgDataUnreadModel (Comparable)
- (BOOL)isStickOnTop {
    return NO;
}

- (NSTimeInterval)updateTime {
    return [[self timestamp] doubleValue];
}
@end

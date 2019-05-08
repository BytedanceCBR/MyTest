//
//  IMConversation+Comparable.m
//  AFgzipRequestSerializer
//
//  Created by leo on 2019/2/14.
//

#import "IMConversation+Comparable.h"

@implementation IMConversation (Comparable)

- (BOOL)isStickOnTop {
    return NO;
}

- (NSTimeInterval)updateTime {
    return [[self updatedAt] timeIntervalSince1970];
}

@end

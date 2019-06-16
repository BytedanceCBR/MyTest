//
//  TTFeedDislikeWord+AddType.m
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/16.
//

#import "TTFeedDislikeWord+AddType.h"

@implementation TTFeedDislikeWord (AddType)

- (TTFeedDislikeWordType)type {
    NSString *typeValue = [self.ID substringToIndex:[self.ID rangeOfString:@":"].location];
    return (TTFeedDislikeWordType)[typeValue intValue];
}

@end

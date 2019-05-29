//
//  NSString+TTLength.m
//  Article
//
//  Created by liuzuopeng on 9/7/16.
//
//

#import "NSString+TTLength.h"

@implementation NSString (TTLength)
- (NSUInteger)tt_lengthOfWords {
    NSUInteger chCounts = 0, blankCounts = 0, zhCounts = 0;
    for (NSUInteger i = 0; i < [self length]; i++) {
        unichar ch = [self characterAtIndex:i];
        if (isblank(ch)  || isspace(ch)) {
            blankCounts++;
        } else if (isascii(ch)) {
            chCounts++;
        } else {
            zhCounts++;
        }
    }
    if (chCounts == 0 && zhCounts == 0) return 0;
    return (zhCounts + (int)ceilf((float)(blankCounts + chCounts)/2.f));
}

- (NSUInteger)tt_lengthOfBytes {
    NSUInteger chCounts = 0, blankCounts = 0, zhCounts = 0;
    for (NSUInteger i = 0; i < [self length]; i++) {
        unichar ch = [self characterAtIndex:i];
        if (isblank(ch) || isspace(ch)) {
            blankCounts++;
        } else if (isascii(ch)) {
            chCounts++;
        } else {
            zhCounts++;
        }
    }
    if (chCounts == 0 && zhCounts == 0) return 0;
    return (zhCounts * 2 + (int)(blankCounts + chCounts));
}

- (NSUInteger)limitedLengthOfMaxCount:(NSUInteger)maxCount {
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < [self length]; i++) {
        unichar ch = [self characterAtIndex:i];
        if (isblank(ch) || isspace(ch)) {
            count++;
        } else if (isascii(ch)) {
            count++;
        } else {
            count += 2;
        }
        if (count >= maxCount) break;
    }
    return count;
}

- (NSUInteger)limitedIndexOfMaxCount:(NSUInteger)maxCount {
    NSUInteger count = 0;
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < [self length]; i++) {
        index = i + 1;
        unichar ch = [self characterAtIndex:i];
        if (isblank(ch) || isspace(ch)) {
            count++;
        } else if (isascii(ch)) {
            count++;
        } else {
            count += 2;
        }
        if (count >= maxCount) break;
    }
    return index;
}

@end

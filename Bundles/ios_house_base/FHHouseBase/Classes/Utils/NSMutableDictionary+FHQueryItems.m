//
//  NSMutableDictionary+FHQueryItems.m
//  FHHouseBase
//
//  Created by bytedance on 2020/11/22.
//

#import "NSMutableDictionary+FHQueryItems.h"


static NSString *const kArrayEncodeString = @"%5B%5D";

@implementation NSMutableDictionary(FHQueryItems)

- (void)fh_clearInvalidKeysIfNeed {
    NSMutableArray *oldKeys = [NSMutableArray array];
    NSMutableDictionary *exchanedDict = [NSMutableDictionary dictionary];
    for (NSString *key in [self allKeys]) {
        if ([key hasSuffix:kArrayEncodeString] || [key hasSuffix:[kArrayEncodeString lowercaseString]]) {
            NSString *exchangeKey = [key substringToIndex:key.length - kArrayEncodeString.length];
            id value = [self objectForKey:key];
            if (exchangeKey && value) {
                [exchanedDict setObject:value forKey:exchangeKey];
                [oldKeys addObject:key];
            }
        }
    }
    
    [self removeObjectsForKeys:oldKeys];
    [self addEntriesFromDictionary:exchanedDict];
}

@end

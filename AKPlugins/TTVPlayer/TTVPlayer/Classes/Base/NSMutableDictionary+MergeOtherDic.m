//
//  NSMutableDictionary+MergeOtherDic.m
//  ScreenRotate
//
//  Created by lisa on 2019/3/29.
//  Copyright © 2019 . All rights reserved.
//

#import "NSMutableDictionary+MergeOtherDic.h"

@implementation NSMutableDictionary (MergeOtherDic)

- (void)mergingWithDictionary:(NSDictionary *)dict {
    for (id key in [dict allKeys]) {
        id obj = [self mutableDictionaryCopyIfNeeded:[dict objectForKey:key]];
        id localObj = [self mutableDictionaryCopyIfNeeded:[self objectForKey:key]];
        if ([obj isKindOfClass:[NSDictionary class]] &&
            [localObj isKindOfClass:[NSMutableDictionary class]]) {
            [self setObject:localObj forKey:key];
            // Recursive merge for NSDictionary
            [localObj mergingWithDictionary:obj];
        } else if (obj) {
            [self setObject:obj forKey:key];
        }
    }
}

- (id)mutableDictionaryCopyIfNeeded:(id)dictObj {
    if ([dictObj respondsToSelector:@selector(objectForKey:)]) {
        dictObj = [dictObj mutableCopy];
    }
    return dictObj;
}

/**
 合并两个字典
 
 @param dict       被合并的字典
 @param ignoredKey 忽略的Key
 */
- (void)mergingWithDictionary:(NSDictionary *)dict ignoredDictKey:(NSString *)ignoredKey {
    for (id key in [dict allKeys]) {
        if ([key isEqualToString:ignoredKey]) {
            continue;
        }
        id obj = [self mutableDictionaryCopyIfNeeded:[dict objectForKey:key]];
        id localObj = [self mutableDictionaryCopyIfNeeded:[self objectForKey:key]];
        if ([obj isKindOfClass:[NSDictionary class]] &&
            [localObj isKindOfClass:[NSMutableDictionary class]]) {
            [self setObject:localObj forKey:key];
            // Recursive merge for NSDictionary
            [localObj mergingWithDictionary:obj];
        } else if (obj) {
            [self setObject:obj forKey:key];
        }
    }
}
@end

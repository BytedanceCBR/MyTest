//
//  TTSubEntranceManager.m
//  Article
//
//  Created by Chen Hong on 15/6/23.
//
//

#import "TTSubEntranceManager.h"
#import "TTPersistence.h"
#import "NSDictionary+TTAdditions.h"

#define kPlistName @"ttSubEntrance.plist"

@implementation TTSubEntranceManager

static NSMutableDictionary *s_cacheDict = nil;

+ (NSString *)objArrayKeyForCategory:(NSString *)category concernID:(NSString *)concernID
{
    return [NSString stringWithFormat:@"ttSubEntranceObjArray%@%@", category, concernID];
}

+ (NSString *)lastRefreshtimeIntervalKeyForCategory:(NSString *)category concernID:(NSString *)concernID
{
    return [NSString stringWithFormat:@"ttSubEntranceLastRefreshTime%@%@", category, concernID];
}

+ (NSMutableDictionary *)cacheDict {
    if (!s_cacheDict) {
        s_cacheDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return s_cacheDict;
}

+ (SubEntranceType)subEntranceTypeForCategory:(NSString *)category
{
    NSString *key = [NSString stringWithFormat:@"%@_type", category];
    if ([self.cacheDict objectForKey:key]) {
        return [self.cacheDict integerValueForKey:key defaultValue:0];
    }
    
    TTPersistence *persistence = [TTPersistence persistenceWithName:kPlistName];
    NSNumber *subEntranceType = [persistence objectForKey:key];
    return [subEntranceType integerValue];
}

+ (void)setSubEntranceType:(SubEntranceType)type forCategory:(NSString *)category
{
    NSString *key = [NSString stringWithFormat:@"%@_type", category];
    
    [self.cacheDict setValue:@(type) forKey:key];
    
    TTPersistence *persistence = [TTPersistence persistenceWithName:kPlistName];
    [persistence setObject:@(type) forKey:key];
    [persistence save];
}

+ (NSArray *)subEntranceObjArrayForCategory:(NSString *)category concernID:(NSString *)concernID
{
    NSString *key = [self objArrayKeyForCategory:category concernID:concernID];
    NSArray *subEntranceObjArray = [self.cacheDict arrayValueForKey:key defaultValue:nil];
    if (subEntranceObjArray) {
        return subEntranceObjArray;
    }
    
    TTPersistence *persistence = [TTPersistence persistenceWithName:kPlistName];
    subEntranceObjArray = [persistence objectForKey:key];
    
    [self.cacheDict setValue:(subEntranceObjArray?:@[]) forKey:key];
    return subEntranceObjArray;
}

+ (void)setSubEntranceObjArray:(NSArray *)array forCategory:(NSString *)category concernID:(NSString *)concernID
{
    NSString *key = [self objArrayKeyForCategory:category concernID:concernID];
    [self.cacheDict setValue:(array?:@[]) forKey:key];
    
    TTPersistence *persistence = [TTPersistence persistenceWithName:kPlistName];
    [persistence setObject:array forKey:key];
    [persistence save];
}

+ (NSTimeInterval)subEntranceLastRefreshTimeIntervalForCategory:(NSString *)category concernID:(NSString *)concernID
{
    TTPersistence *persistence = [TTPersistence persistenceWithName:kPlistName];
    NSNumber *interval = [persistence objectForKey:[self lastRefreshtimeIntervalKeyForCategory:category concernID:concernID]];
    return [interval doubleValue];
}

+ (void)setSubEntranceRefreshTimeInterval:(NSTimeInterval)interval forCategory:(NSString *)category concernID:(NSString *)concernID
{
    TTPersistence *persistence = [TTPersistence persistenceWithName:kPlistName];
    [persistence setObject:@(interval) forKey:[self lastRefreshtimeIntervalKeyForCategory:category concernID:concernID]];
    [persistence save];
}

@end

//
//  ExploreExtenstionDataHelper.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-10.
//
//

#import "ExploreExtenstionDataHelper.h"
#import "TTBaseMacro.h"
#import <UIKit/UIKit.h>

#define kShareLocationLatitudeKey       @"kShareLocationLatitudeKey"
#define kShareLocationLongitudeKey      @"kShareLocationLongitudeKey"
#define kShareCityKey                   @"kShareCityKey"
#define kShareSelectCityKey             @"kShareSelectCityKey"
#define kShareBaseURLDomainKey          @"kShareBaseURLDomainKey"
#define kShareIIDKey                    @"kShareIIDKey"
#define kShareDeviceIDKey               @"kShareDeviceIDKey"
#define kShareSessionIDKey              @"kShareSessionIDKey"
#define kShareFetchWidgetMinInterval    @"kShareFetchWidgetMinInterval"
#define kShareOpenUDIDKey               @"kShareOpenUDIDKey"

#define kShareUserSaveNoImgModeKey  @"kShareUserSaveNoImgModeKey"

#define kSharedTodayExtenstionImpressionKey     @"kSharedTodayExtenstionImpressionKey"

@implementation ExploreExtenstionDataHelper


+ (double)sharedLatitude
{
    NSObject * obj = [self objDataForKey:kShareLocationLatitudeKey];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)obj) doubleValue];
    }
    return 0;
}

+ (double)sharedLongitude
{
    NSObject * obj = [self objDataForKey:kShareLocationLongitudeKey];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)obj) doubleValue];
    }
    return 0;
}

+ (void)saveSharedLatitude:(double)latitude
{
    [self saveObj:@(latitude) forKey:kShareLocationLatitudeKey];
}

+ (void)saveSharedLongitude:(double)longitude
{
    [self saveObj:@(longitude) forKey:kShareLocationLongitudeKey];
}

+ (NSString *)sharedUserCity
{
    NSObject * str = [self objDataForKey:kShareCityKey];
    if ([str isKindOfClass:[NSString class]]) {
        return (NSString *)str;
    }
    return nil;
}

+ (void)saveSharedUserCity:(NSString *)userCity
{
    [self saveObj:userCity forKey:kShareCityKey];
}

+ (NSString *)sharedUserSelectCity
{
    NSObject * str = [self objDataForKey:kShareSelectCityKey];
    if ([str isKindOfClass:[NSString class]]) {
        return (NSString *)str;
    }
    return nil;
}

+ (void)saveSharedUserSelectCity:(NSString *)userCity
{
    [self saveObj:userCity forKey:kShareSelectCityKey];
}

+ (void)saveFetchWidgetMinInterval:(int)interval
{
    [self saveObj:@(interval) forKey:kShareFetchWidgetMinInterval];
}

+ (NSUInteger)fetchWidgetMinInterval
{
    NSObject * str = [self objDataForKey:kShareFetchWidgetMinInterval];
    if ([str isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)str) intValue];
    }
    return 2 * 60;
}


#pragma mark -- url


+ (NSString *)sharedBaseURLDomin
{
    NSObject * str = [self objDataForKey:kShareBaseURLDomainKey];
    if ([str isKindOfClass:[NSString class]]) {
        NSString * result = [NSString stringWithFormat:@"http://%@", str];
        return result;
    }
    return @"http://i.snssdk.com";
}


+ (void)saveSharedBaseURLDomain:(NSString *)baseURL
{
    [self saveObj:baseURL forKey:kShareBaseURLDomainKey];
}


#pragma mark -- user info

+ (void)saveSharedIID:(NSString *)iid
{
    [self saveObj:iid forKey:kShareIIDKey];
}

+ (NSString *)sharedIID
{
    NSObject * str = [self objDataForKey:kShareIIDKey];
    if ([str isKindOfClass:[NSString class]]) {
        return (NSString *)str;
    }
    return nil;
}

+ (void)saveSharedDeviceID:(NSString *)deviceID
{
    [self saveObj:deviceID forKey:kShareDeviceIDKey];
}

+ (NSString *)sharedDeviceID
{
    NSObject * str = [self objDataForKey:kShareDeviceIDKey];
    if ([str isKindOfClass:[NSString class]]) {
        return (NSString *)str;
    }
    return nil;
}

+ (void)saveSharedOpenUDID:(NSString *)openUDID
{
    [self saveObj:openUDID forKey:kShareOpenUDIDKey];
}

+ (NSString *)sharedOpenUDID {
    NSObject *openUDID = [self objDataForKey:kShareOpenUDIDKey];
    if ([openUDID isKindOfClass:[NSString class]]) {
        return (NSString *)openUDID;
    }
    return nil;
}

+ (void)saveSharedSessionID:(NSString *)sessionID
{
    [self saveObj:sessionID forKey:kShareSessionIDKey];
}

+ (NSString *)sharedSessionID
{
    NSObject * str = [self objDataForKey:kShareSessionIDKey];
    if ([str isKindOfClass:[NSString class]]) {
        return (NSString *)str;
    }
    return nil;
}

+ (void)saveUserSetNoImgMode:(BOOL)noImgMode
{
    [self saveObj:@(noImgMode) forKey:kShareUserSaveNoImgModeKey];
}

+ (BOOL)isUserSetNoImgMode
{
    NSObject * str = [self objDataForKey:kShareUserSaveNoImgModeKey];
    if ([str isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)str) boolValue];
    }
    return NO;
}

#pragma mark -- impression

+ (void)appendTodayExtenstionImpression:(NSArray *)impressions
{
    if ([impressions count] == 0) {
        return;
    }
    NSData * impressiondata = (NSData *)[self objDataForKey:kSharedTodayExtenstionImpressionKey];
    NSMutableArray * mutImpressions = [NSMutableArray arrayWithCapacity:10];
    if (impressiondata) {
        NSArray * array  = [NSKeyedUnarchiver unarchiveObjectWithData:impressiondata];
        if ([array count] > 0) {
            [mutImpressions addObjectsFromArray:array];
        }
    }
    [mutImpressions addObjectsFromArray:impressions];
    NSData * savedData = [NSKeyedArchiver archivedDataWithRootObject:mutImpressions];
    [self saveObj:savedData forKey:kSharedTodayExtenstionImpressionKey];
}

+ (NSMutableDictionary *)fetchTodayExtenstionDict
{
    NSData * impressiondata = (NSData *)[self objDataForKey:kSharedTodayExtenstionImpressionKey];
    NSArray * array = nil;
    if (impressiondata) {
        array  = [NSKeyedUnarchiver unarchiveObjectWithData:impressiondata];
    }
    NSMutableDictionary * dict = nil;
    if ([array count] > 0) {
        dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@(1) forKey:@"list_type"];
        [dict setValue:@"today_extenstion" forKey:@"key_name"];
        [dict setValue:array forKey:@"impression"];
    }
    
    return dict;
}

+ (void)clearSavedTodayExtenstions
{
    [self removeObjForKey:kSharedTodayExtenstionImpressionKey];
}


#pragma mark -- util

+ (BOOL)supportExtenstion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0;
}

+ (NSString *)appGroupKey
{
    NSString * groupKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ShareGroupKey"];
    if (!isEmptyString(groupKey)) {
        return groupKey;
    }

//    if ([self isInHouseApp]) {
//        return @"group.com.ss.iphone.InHouse.article.News.ShareDefaults";
//    }
//
//    return @"group.todayExtenstionShareDefaults";
//
    if ([self isInHouseApp]) {
        return @"group.com.fp1.extension";
    }
    
    return @"group.com.f100.client.extension";
}

+ (void)saveObj:(NSObject<NSCoding> *)obj forKey:(NSString *)key
{
    if (![self supportExtenstion]) {
        return;
    }
    
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:[self appGroupKey]];
    [defaults setObject:obj forKey:key];
    [defaults synchronize];
}

+ (NSObject<NSCoding> *)objDataForKey:(NSString *)key
{
    if (![self supportExtenstion]) {
        return nil;
    }
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:[self appGroupKey]];
    return [defaults objectForKey:key];
}

+ (void)removeObjForKey:(NSString *)key
{
    if (isEmptyString(key)) {
        return;
    }
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:[self appGroupKey]];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}

+ (NSString*)bundleIdentifier {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (BOOL)isInHouseApp {
    NSRange isRange = [[self bundleIdentifier] rangeOfString:@"fp1" options:NSCaseInsensitiveSearch];
    if (isRange.location != NSNotFound) {
        return YES;
    }
    return NO;
}

@end

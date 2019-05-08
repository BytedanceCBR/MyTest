//
//  TTURLTracker.m
//  Titan
//
//  Created by yin on 2017/5/11.
//  Copyright © 2017年 toutiao. All rights reserved.
//

#import "TTURLTracker.h"
#import <TTPersistence/TTPersistence.h>
#import <TTBaseLib/NSStringAdditions.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTNetWorkHelper.h>
#import <TTTracker/TTTrackerProxy.h>
#import <TTTracker.h>
#import <TTTracker/TTLogServer.h>
#import <TTBaseLib/NSString+URLEncoding.h>
#import <TTInstallService/TTInstallIDManager.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/TTBusinessManager.h>
#import <TTBaseLib/TTBusinessManager+StringUtils.h>
//#import "TTInstallIDWrapperManager.h"
#import <TTNetBusiness/TTHttpsControlManager.h>
//#import "SSURLTracker.h"

#define kRequsetTimes 5

static TTURLTracker * tracker;
static NSString *const kTrackFaildURLFileName = @"TTADTrackFailedURLs.plist";

@interface TTURLTracker ()

@property(nonatomic, strong)TTPersistence *persistence;
@property(nonatomic, strong)NSURLSession *uploadSession;

@end

@implementation TTURLTracker


+ (TTURLTracker *)shareURLTracker
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tracker = [[TTURLTracker alloc] init];
    });
    return tracker;
}

- (void)dealloc
{
    [_uploadSession invalidateAndCancel];
    self.uploadSession = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)init
{
    self = [super init];
    if (self) {
        TTPersistenceOption* option = [[TTPersistenceOption alloc] init];
        option.supportNSCoding = YES;
        _persistence = [TTPersistence persistenceWithName:kTrackFaildURLFileName option:option];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        configuration.URLCache = nil;
        _uploadSession = [NSURLSession sessionWithConfiguration:configuration];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveWillEnterForegroundNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}


- (void)trackURLs:(NSArray *)URLs {
    if (![URLs isKindOfClass:[NSArray class]]) {
        return;
    }
    [URLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self trackURL:obj];
    }];
}

- (void)trackURL:(NSString *)urlString
{
    [self trackURL:urlString model:nil];
}

- (void)trackURLs:(NSArray *)URLs model:(TTURLTrackerModel *)trackModel
{
    if (![URLs isKindOfClass:[NSArray class]]) {
        return;
    }
    [URLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self trackURL:obj model:trackModel];
    }];
}

- (NSString *)normalReplaceUrl:(NSString *)sendURLStr
{
    // 替换时间戳
    NSRange timeStampRange = [sendURLStr rangeOfString:@"{TS}"];
    if (timeStampRange.location == NSNotFound) {
        timeStampRange = [sendURLStr rangeOfString:@"__TS__"];
    }
    if (timeStampRange.location != NSNotFound) {
        long long timeStamp = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
        sendURLStr = [sendURLStr stringByReplacingCharactersInRange:timeStampRange withString:[NSString stringWithFormat:@"%lli", timeStamp]];
    }
    
    // idfa
    NSRange range = [sendURLStr rangeOfString:@"{IDFA}"];
    if (range.location == NSNotFound) {
        range = [sendURLStr rangeOfString:@"__IDFA__"];
    }
    if (range.location != NSNotFound) {
        NSString *idfa = [TTDeviceHelper idfaString];
        if (!isEmptyString(idfa)) {
            sendURLStr = [sendURLStr stringByReplacingCharactersInRange:range withString:idfa];
        }
    }
    
    // mac地址
    range = [sendURLStr rangeOfString:@"{MAC}"];
    if (range.location == NSNotFound) {
        range = [sendURLStr rangeOfString:@"__MAC__"];
    }
    if (range.location != NSNotFound) {
        NSString *string = [[[[TTDeviceHelper MACAddress] componentsSeparatedByString:@":"] componentsJoinedByString:@""] MD5HashString];
        if (!isEmptyString(string)) {
            sendURLStr = [sendURLStr stringByReplacingCharactersInRange:range withString:string];
        }
    }
    
    // mac1地址
    range = [sendURLStr rangeOfString:@"{MAC1}"];
    if (range.location == NSNotFound) {
        range = [sendURLStr rangeOfString:@"__MAC1__"];
    }
    if (range.location != NSNotFound) {
        NSString *string = [[TTDeviceHelper MACAddress] MD5HashString];
        if (!isEmptyString(string)) {
            sendURLStr = [sendURLStr stringByReplacingCharactersInRange:range withString:string];
        }
    }
    
    // OPENUDID
    range = [sendURLStr rangeOfString:@"{OPENUDID}"];
    if (range.location == NSNotFound) {
        range = [sendURLStr rangeOfString:@"__OPENUDID__"];
    }
    if (range.location != NSNotFound) {
        NSString *string = [TTDeviceHelper openUDID];
        if (!isEmptyString(string)) {
            sendURLStr = [sendURLStr stringByReplacingCharactersInRange:range withString:string];
        }
    }
    
    //  ua
    range = [sendURLStr rangeOfString:@"{UA}"];
    if (range.location == NSNotFound) {
        range = [sendURLStr rangeOfString:@"__UA__"];
    }
    if (range.location != NSNotFound) {
        NSString *string = [[NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]] URLEncodedString];
        if (!isEmptyString(string)) {
            sendURLStr = [sendURLStr stringByReplacingCharactersInRange:range withString:string];
        }
    }
    
    //  os
    range = [sendURLStr rangeOfString:@"{OS}"];
    if (range.location == NSNotFound) {
        range = [sendURLStr rangeOfString:@"__OS__"];
    }
    if (range.location != NSNotFound) {
        NSString *string = @"1";//1 iOS
        if (!isEmptyString(string)) {
            sendURLStr = [sendURLStr stringByReplacingCharactersInRange:range withString:string];
        }
    }
    
    //  IP
    range = [sendURLStr rangeOfString:@"{IP}"];
    if (range.location == NSNotFound) {
        range = [sendURLStr rangeOfString:@"__IP__"];
    }
    if (range.location != NSNotFound) {
        NSString *string = [[[TTNetworkHelper getIPAddresses] allValues] firstObject];
        if (!isEmptyString(string)) {
            sendURLStr = [sendURLStr stringByReplacingCharactersInRange:range withString:string];
        }
    }
    
    // 替换did
    NSRange deviceIdRange = [sendURLStr rangeOfString:@"{DUID}"];
    if (deviceIdRange.location == NSNotFound) {
        deviceIdRange = [sendURLStr rangeOfString:@"__DUID__"];
    }
    if (deviceIdRange.location != NSNotFound) {
        
        NSString* didStr = [[TTInstallIDManager sharedInstance] deviceID];
        if (!isEmptyString(didStr)) {
            sendURLStr = [sendURLStr stringByReplacingCharactersInRange:deviceIdRange withString:didStr];
        }
    }
    
    return sendURLStr;
}

- (NSString *)adReplaceUrl:(NSString *)sendURLStr
{
    // 替换时间戳
    NSRange timeStampRange = [sendURLStr rangeOfString:@"{TS}"];
    if (timeStampRange.location == NSNotFound) {
        timeStampRange = [sendURLStr rangeOfString:@"__TS__"];
    }
    if (timeStampRange.location != NSNotFound) {
        long long timeStamp = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
        sendURLStr = [sendURLStr stringByReplacingCharactersInRange:timeStampRange withString:[NSString stringWithFormat:@"%lli", timeStamp]];
    }
    
    // 替换did
    NSRange deviceIdRange = [sendURLStr rangeOfString:@"{UID}"];
    if (deviceIdRange.location == NSNotFound) {
        deviceIdRange = [sendURLStr rangeOfString:@"__UID__"];
    }
    if (deviceIdRange.location != NSNotFound) {
        
        NSString* didStr = [[TTInstallIDManager sharedInstance] deviceID];
        if (!isEmptyString(didStr)) {
            sendURLStr = [sendURLStr stringByReplacingCharactersInRange:deviceIdRange withString:didStr];
        }
    }
    return sendURLStr;
}

- (void)thirdMonitorUrl:(NSString *)urlString
{
    [self trackURL:urlString model:nil isNormal:YES];
}

- (void)thirdMonitorUrls:(NSArray *)URLs
{
    if (![URLs isKindOfClass:[NSArray class]]) {
        return;
    }
    [URLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self trackURL:obj model:nil isNormal:YES];
    }];
}

- (void)trackURL:(NSString *)urlString model:(TTURLTrackerModel *)trackModel isNormal:(BOOL)isNormal
{
    if (isEmptyString(urlString))
    {
        return;
    }
    
    NSString * sendURLStr = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (isEmptyString(sendURLStr)) {
        return;
    }
    
    NSString* adId = trackModel.ad_id;
    
    if (isNormal)
    {
        sendURLStr = [self normalReplaceUrl:sendURLStr];
    }
    else
    {
        sendURLStr = [self adReplaceUrl:sendURLStr];
    }
    
    NSURL * url = [TTStringHelper URLWithURLString:sendURLStr];
    
    url = [[TTHttpsControlManager sharedInstance_tt] transferedURLFrom:url];
    if (!url) {
        return;
    }
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:trackModel.ad_id forKey:@"ad_id"];
    
    if (!TTNetworkConnected()) {
        [self cacheFailedURL:url dict:dict];
        return;
    }
    
    NSString *trackDescription = [NSString stringWithFormat:@"TrackURL:%@", url.absoluteString];
    [TTLogServer sendValueToLogServer:trackDescription parameters:@{@"color":@"ff0000"}];
    
    [[self.uploadSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = ((NSHTTPURLResponse *)response).statusCode;
        }
        if (error) {
            [self cacheFailedURL:url dict:dict];
        } else {
            if (statusCode < 400 && statusCode >0) {
                [self sendEventWithURL:url statusCode:statusCode];
            }
            else
            {
                [self cacheFailedURL:url dict:dict];
            }
        }
        if (!isEmptyString(adId)) {
            [self sendAdEvent:adId url:url.absoluteString statusCode:statusCode];
        }
    }] resume];
    
}

- (void)trackURL:(NSString *)urlString model:(TTURLTrackerModel *)trackModel
{
    [self trackURL:urlString model:trackModel isNormal:NO];
}


- (void)receiveWillEnterForegroundNotification:(NSNotification *)notification
{
    if (TTNetworkConnected()) {
        NSString *filePath = [[TTPersistence cacheDirectory] stringByAppendingPathComponent:kTrackFaildURLFileName];
        NSData* data = [NSData dataWithContentsOfFile:filePath];
        
        NSDictionary *dataDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [dataDict.allKeys enumerateObjectsUsingBlock:^(NSString *  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSURL *url = [self urlCachedKey:key dataDict:dataDict];
            NSString *adId = [self adIdCachedKey:key dataDict:dataDict];
            NSInteger tryTimes = [self timesCachedKey:key dataDict:dataDict];
            
            if (tryTimes >= kRequsetTimes) {
                [self removeURLFromCacheWithKey:key];
            }
            else {
                
                if ([url isKindOfClass:[NSURL class]]) {
                    [[self.uploadSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        
                        NSInteger statusCode = -1;
                        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                            statusCode = ((NSHTTPURLResponse *)response).statusCode;
                        }
                        if (!error && statusCode < 400 && statusCode >0) {
                            [self removeURLFromCacheWithKey:key];
                            [self sendEventWithURL:url statusCode:statusCode];
                        }
                        if (!isEmptyString(adId) && url) {
                            [self sendAdEvent:adId url:url.absoluteString statusCode:statusCode];
                        }
                    }] resume];
                }
                [self addTimesCachedKey:key dataDict:dataDict];
            }
        }];
    }
}

- (void)cacheFailedURL:(NSURL *)url dict:(NSDictionary*)dict
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
    [dictionary setValue:url forKey:@"url"];
    [dictionary setValue:@(1) forKey:@"times"];
    
    NSString *currentTimeKeyString = [TTBusinessManager simpleDateStringSince:[[NSDate date] timeIntervalSince1970]];
    NSMutableString *persistenceKeyString = nil;
    if (url && currentTimeKeyString) {
        persistenceKeyString = [NSMutableString stringWithFormat:@"%@%@",url,currentTimeKeyString];
    }
    
    if (persistenceKeyString) {
        [self.persistence setValue:dictionary forKey:@(persistenceKeyString.hash).stringValue];
        [self.persistence save];
    }
    
}

//由于前期只在key下存NSURL,现在改为存dict,故需区分开
- (NSURL* )urlCachedKey:(NSString *)key dataDict:(NSDictionary*)dataDict
{
    NSDictionary* dict = [dataDict valueForKey:key];
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        return (NSURL *)[dict valueForKey:@"url"];
    }
    return nil;
}

- (NSString *)adIdCachedKey:(NSString *)key dataDict:(NSDictionary*)dataDict
{
    NSDictionary* dict = [dataDict valueForKey:key];
    
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        return (NSString *)[dict valueForKey:@"ad_id"];
    }
    return nil;
}

- (void)addTimesCachedKey:(NSString *)key dataDict:(NSDictionary*)dataDict
{
    NSDictionary* dict = [dataDict valueForKey:key];
    
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSInteger times = [[dictionary valueForKey:@"times"] integerValue];
        [dictionary setValue:@(times + 1) forKey:@"times"];
        [self.persistence setValue:dictionary forKey:key];
        [self.persistence save];
    }
    
}

- (NSInteger)timesCachedKey:(NSString *)key dataDict:(NSDictionary*)dataDict
{
    NSDictionary* dict = [dataDict valueForKey:key];
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        return [[dict valueForKey:@"times"]integerValue];
    }
    return kRequsetTimes;
}


- (void)removeURLFromCacheWithKey:(NSString *)key
{
    [self.persistence setValue:nil forKey:key];
    [self.persistence save];
}

- (void)sendEventWithURL:(NSURL *)url statusCode:(NSInteger)statusCode
{
    ttTrackEventWithCustomKeys(@"ad_stat", @"track_url", @(statusCode).stringValue, nil, @{@"url" : url.absoluteString});
}

//trackUrl之后发送adId
- (void)sendAdEvent:(NSString*)adId url:(NSString*)url statusCode:(NSInteger)statusCode
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:4];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:url forKey:@"url"];
    [dict setValue:@(statusCode).stringValue forKey:@"ext_value"];
    [dict setValue:@(connectionType) forKey:@"nt"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    ttTrackEventWithCustomKeys(@"embeded_ad", @"track_url",adId, nil, dict);
}


@end




@implementation TTURLTrackerModel

- (instancetype)initWithAdId:(NSString*)ad_id logExtra:(NSString*)log_extra
{
    self = [super init];
    if (self) {
        self.ad_id = ad_id;
        self.log_extra = log_extra;
    }
    return self;
}

@end

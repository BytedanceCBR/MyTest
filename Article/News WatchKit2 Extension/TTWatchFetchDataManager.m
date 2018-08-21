//
//  WatachFetchDataManager.m
//  Article
//
//  Created by 邱鑫玥 on 16/8/18.
//
//

#import "TTWatchFetchDataManager.h"
#import "TTWatchMacroDefine.h"
#import "TTWatchCommonInfoManager.h"

#define kLoadCountKey 8
#define kBackgroundRefreshTimeInterval (30*60)
#define kFetchRemoteDataInterval (60*30)

#define kWatchStoreKey @"kWatchStoreKey"
#define kWatchLastFetchRemoteDataKey @"kWatchLastFetchRemoteDataKey"

@interface TTWatchFetchDataManager ()<NSURLSessionDownloadDelegate>

@property(assign,nonatomic) NSInteger lastFetchRemoteDataTime;
@property(strong,nonatomic) NSURLSession *backgroundSession;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
@property(strong,nonatomic) WKApplicationRefreshBackgroundTask *backgroundTask;
#pragma clang diagnostic pop

@end


@implementation TTWatchFetchDataManager

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static TTWatchFetchDataManager *manager ;
    dispatch_once(&onceToken, ^{
        manager = [[TTWatchFetchDataManager alloc] init];
        [manager loadFetchRemoteDataTime];
    });
    return manager;
}

- (void)fetchDataWithCompleteBlock:(void (^)(NSData *data, NSError *error))completionBlock
{
    
    NSString * url = [self requestURLString];
    NSURLRequest * request = [NSURLRequest requestWithURL:[[self class] URLWithURLString:url]];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock){
                completionBlock(data,error);
            }
            
            if(!error){
                [self saveData:data];
                
                //每次必定通知complication去刷新数据
                [self refreshComplication];
                //并且每次必定更新从远端获取数据的时间
                [self updateFetchRemoteDataTime];
            }
        });
    }] resume];
}

- (void)saveData:(NSData *)data{
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kWatchStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSData *)getStoredData{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kWatchStoreKey];
}

- (void)refreshComplication{
   [[CLKComplicationServer sharedInstance].activeComplications enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull each, NSUInteger idx, BOOL * _Nonnull stop) {
        [[CLKComplicationServer sharedInstance] reloadTimelineForComplication: each];
    }];
}

#pragma mark - 判断是否应该从远端获取数据
- (BOOL)shouldFetchRemoteData{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - _lastFetchRemoteDataTime;
    if(interval < kFetchRemoteDataInterval){
        return NO;
    }
    else{
        return YES;
    }
}

- (void)updateFetchRemoteDataTime{
    _lastFetchRemoteDataTime = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setInteger:_lastFetchRemoteDataTime forKey:kWatchLastFetchRemoteDataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)loadFetchRemoteDataTime{
    _lastFetchRemoteDataTime = [[NSUserDefaults standardUserDefaults] integerForKey:kWatchLastFetchRemoteDataKey];
}

#pragma mark - 后台加载数据
- (void)scheduleNextBackgroundRefresh{
    if([[[WKInterfaceDevice currentDevice] systemVersion] floatValue] >= 3.0){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        [[WKExtension sharedExtension] scheduleBackgroundRefreshWithPreferredDate:[NSDate dateWithTimeIntervalSinceNow:kBackgroundRefreshTimeInterval] userInfo:nil scheduledCompletion:^(NSError *error){
#pragma clang diagnostic pop
        }];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)startBackgroundRefreshWithTask:(WKApplicationRefreshBackgroundTask *)task{
#pragma clang diagnostic pop
    if(!_backgroundTask){
        _backgroundTask = task;
        NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSUUID UUID].UUIDString];
        _backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigObject delegate:self delegateQueue:nil];
        NSURLSessionDownloadTask *downloadTask = [_backgroundSession downloadTaskWithURL:[NSURL URLWithString:[self requestURLString]]];
        
        [downloadTask resume];
    }
    else{
        [task setTaskCompleted];
    }
}

- (void)stopBackgroundRefresh{
    [_backgroundSession invalidateAndCancel];
    _backgroundSession = nil;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSData *data = [NSData dataWithContentsOfURL:location];
    dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        if(data && [WKExtension sharedExtension].applicationState == WKApplicationStateBackground){
#pragma clang diagnostic pop
            [self saveData:data];

            //每次必定通知complication去刷新数据
            [self refreshComplication];
            //并且每次必定更新从远端获取数据的时间
            [self updateFetchRemoteDataTime];
            
            self.hasBackgroundRefreshData = YES;
        }
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_backgroundTask setTaskCompleted];
        _backgroundTask = nil;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        if([WKExtension sharedExtension].applicationState == WKApplicationStateBackground){
#pragma clang diagnostic pop
            [self scheduleNextBackgroundRefresh];
        }
    });
}

#pragma mark - 获取远端URL相关
+ (NSURL *)URLWithURLString:(NSString *)str
{
    if (isEmptyString(str)) {
        return nil;
    }
    NSString * fixStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL * u = [NSURL URLWithString:fixStr];
    if (!u) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        u = [NSURL URLWithString:[fixStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
#pragma clang diagnostic pop
    }
    return u;
}

+ (NSString*)customURLStringFromString:(NSString*)urlStr supportedMix:(BOOL)supportedMix
{
    if (isEmptyString(urlStr)) {
        return nil;
    }
    NSRange range = [urlStr rangeOfString:@"?"];
    __block NSString *sep = (range.location == NSNotFound) ? @"?" : @"&";
    NSMutableString *string = [NSMutableString stringWithString:urlStr];
    
    NSDictionary *params = [self commonHeaderDictionaryWithSupportedMix:supportedMix];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *stringKey = key;
        NSString *stringValue = obj;
        NSString *queryString = [NSString stringWithFormat:@"%@=", key];
        if (!isEmptyString(stringValue) && [string rangeOfString:queryString].location == NSNotFound) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
            stringValue = [stringValue stringByAddingPercentEscapesUsingEncoding :NSUTF8StringEncoding];
#pragma clang diagnostic pop
            [string appendFormat:@"%@%@=%@", sep, stringKey, stringValue];
            sep = @"&";
        }
    }];
    return [string copy];
}

+ (NSDictionary *)commonHeaderDictionaryWithSupportedMix:(BOOL)supportedMix
{
    NSMutableDictionary *params = @{}.mutableCopy;
    NSString * iid = nil;
    if (!isEmptyString(iid)) {
        params[@"iid"] = iid;
    }
    if (supportedMix) {
        params[@"ssmix"] = @"a";
    }
    
    return [params copy];
}

- (NSString *)urlStr
{
    // TODO:here 此处实现待优化
    NSString * result = [NSString stringWithFormat:@"%@%@",@"http://i.snssdk.com",@"/2/article/v30/stream/"];
    return result;
}

- (NSString *)requestURLString
{
    NSMutableString * urlString = [[NSMutableString alloc] initWithCapacity:30];
    [urlString appendString:[self urlStr]];
    [urlString appendFormat:@"?count=%i", kLoadCountKey];
    [urlString appendFormat:@"&min_behot_time=%i", 0];
    
    /*double latitude = [ExploreExtenstionDataHelper sharedLatitude];
    double longitude = [ExploreExtenstionDataHelper sharedLongitude];
    if (latitude != 0 && longitude != 0) {
        [urlString appendFormat:@"&latitude=%f", latitude];
        [urlString appendFormat:@"&longitude=%f", longitude];
    }
    
    NSString * city = [ExploreExtenstionDataHelper sharedUserCity];
    if (!isEmptyString(city)) {
        [urlString appendFormat:@"&city=%@", city];
    }
    
    NSString * selectCity = [ExploreExtenstionDataHelper sharedUserSelectCity];
    if (!isEmptyString(selectCity)) {
        [urlString appendFormat:@"&user_city=%@", selectCity];
    }*/
    
    [urlString appendString:@"&tt_from=watch"];
    
    /*if (!isEmptyString([ExploreExtenstionDataHelper sharedIID])) {
        [urlString appendFormat:@"&iid=%@", [ExploreExtenstionDataHelper sharedIID]];
    }*/
    if (!isEmptyString([TTWatchCommonInfoManager deviceID])) {
        [urlString appendFormat:@"&device_id=%@", [TTWatchCommonInfoManager deviceID]];
    }
    
    [urlString appendFormat:@"&os_version=%@",[[WKInterfaceDevice currentDevice] systemVersion]];
    
    NSString * resultURLStr = [[self class] customURLStringFromString:urlString supportedMix:NO];
    return resultURLStr;
}



@end

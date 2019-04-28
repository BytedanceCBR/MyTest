//
//  ExploreWidgetFetchListManager.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-11.
//
//

#import "ExploreWidgetFetchListManager.h"
#import "ExploreExtenstionDataHelper.h"
#import "SSWidgetCookieManager.h"
#import "ExploreWidgetItemModel.h"

#import "TTBaseMacro.h"
#import "TTWidgetTool.h"

#define kLoadCountKey 4


@interface ExploreWidgetFetchListManager()<NSURLConnectionDelegate>
@property(nonatomic, retain)NSMutableData * responseData;
@property(nonatomic, assign, readwrite)BOOL isLoading;
@property(nonatomic, retain)NSURLConnection * connection;
@end

@implementation ExploreWidgetFetchListManager

- (void)dealloc
{
    [_connection cancel];
    self.connection = nil;
    self.delegate = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.itemModels = [self fetchCacheItems];
        
    }
    return self;
}

- (void)tryFetchRequest
{
    if ([self couldFetchWidgetAPI]) {
        [self fetchRequest];
    }
}


- (void)fetchRequest
{
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    if (!isEmptyString([ExploreExtenstionDataHelper sharedSessionID]) && isEmptyString([SSWidgetCookieManager sessionIDFromCookie])) {
        [SSWidgetCookieManager setSessionIDToCookie:[ExploreExtenstionDataHelper sharedSessionID]];
    }
    
    NSString * url = [self requestURLString];
    NSURLRequest * request = [NSURLRequest requestWithURL:[TTWidgetTool URLWithURLString:url]];
    
    [_connection cancel];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [_connection start];
}

- (void)notifyFailed
{
    self.isLoading = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(widgetLoadDataFailed:)]) {
        [_delegate widgetLoadDataFailed:self];
    }
}


- (void)notifyUpdate:(NSArray *)models
{
    self.isLoading = NO;
    if ([models count] > 0) {
        self.itemModels = [NSArray arrayWithArray:models];
        [self saveCacheItems];
    }
    [self saveFetchTime];
    if (_delegate && [_delegate respondsToSelector:@selector(widgetLoadDataFinish:)]) {
        [_delegate widgetLoadDataFinish:self];
    }
}



+ (NSString *)urlStr
{
    // TODO:here 此处实现待优化
    NSString * result = [NSString stringWithFormat:@"%@%@",[ExploreExtenstionDataHelper sharedBaseURLDomin],@"/2/article/v30/stream/"];
    return result;
}

- (NSString *)requestURLString
{
    NSMutableString * urlString = [[NSMutableString alloc] initWithCapacity:30];
    [urlString appendString:[ExploreWidgetFetchListManager urlStr]];
    [urlString appendFormat:@"?count=%i", kLoadCountKey];
    [urlString appendFormat:@"&min_behot_time=%i", 0];
    
    double latitude = [ExploreExtenstionDataHelper sharedLatitude];
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
    }
    
    [urlString appendString:@"&tt_from=today_extenstion"];
    
    if (!isEmptyString([ExploreExtenstionDataHelper sharedIID])) {
        [urlString appendFormat:@"&iid=%@", [ExploreExtenstionDataHelper sharedIID]];
    }
    
    if (!isEmptyString([ExploreExtenstionDataHelper sharedDeviceID])) {
        [urlString appendFormat:@"&device_id=%@", [ExploreExtenstionDataHelper sharedDeviceID]];
    }
    
    NSString * resultURLStr = [TTWidgetTool customURLStringFromString:urlString supportedMix:NO];
    return resultURLStr;
    
}

- (void)saveCacheItems
{
    if (!_itemModels) {
        return;
    }
    @try {
        [[NSUserDefaults standardUserDefaults] setValue:[NSKeyedArchiver archivedDataWithRootObject:_itemModels] forKey:@"ExploreWidgetCacheItems"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    @catch (NSException *exception) {
        NSLog(@"ExploreWidgetFetchListManager NSException %@", exception);
    }
    @finally {
        
    }
}

- (NSArray *)fetchCacheItems
{
    @try {
        id obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExploreWidgetCacheItems"];
        if (obj) {
            NSArray * result = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
            return result;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"*** ExploreWidgetFetchListManager fetchCacheItems %@", exception);
        return nil;
    }
    @finally {
    }
    return nil;
}

- (void)saveFetchTime
{
    [[NSUserDefaults standardUserDefaults] setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"ExploreWidgetLatelyFetchTimeKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSTimeInterval)latelyFetchTime
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"ExploreWidgetLatelyFetchTimeKey"] doubleValue];
}

- (BOOL)couldFetchWidgetAPI
{
    NSUInteger minInterval = [ExploreExtenstionDataHelper fetchWidgetMinInterval];
    NSTimeInterval latelyTimeInterval = [self latelyFetchTime];
    NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
    if (nowInterval - latelyTimeInterval > minInterval) {
        return YES;
    }
    return NO;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSMutableArray * itemModels = [NSMutableArray arrayWithCapacity:4];
    
    @try {
        NSError * tError = nil;
        NSDictionary * response = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingAllowFragments error:&tError];
        if (!tError) {
            NSArray * datas = [response objectForKey:@"data"];
            if ([datas isKindOfClass:[NSArray class]]) {
                int count = 0;
                for (NSDictionary * itemDict in datas) {
                    if ([itemDict isKindOfClass:[NSDictionary class]]) {
                        
                        int cellType = [[itemDict objectForKey:@"cell_type"] intValue];
                        if (cellType != 0) {// 0 is article
                            continue;
                        }
                        if (![[itemDict allKeys] containsObject:@"group_id"]) {
                            continue;
                        }
                        
                        ExploreWidgetItemModel * itemModel = [[ExploreWidgetItemModel alloc] initWithDict:itemDict];
                        if (itemModel) {
                            [itemModels addObject:itemModel];
                            count ++;
                        }
                    }
                    if (count >= kExploreWidgetMaxItemCount) {
                        break;
                    }
                }
            }
        }
        [self notifyUpdate:itemModels];
        
    }
    @catch (NSException *exception) {
        NSLog(@"***widget exception %@", exception);
        self.isLoading = NO;
    }
    @finally {
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self notifyFailed];
}

@end

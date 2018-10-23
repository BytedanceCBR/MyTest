//
//  TTAdWebResPreloadManager.m
//  Article
//
//  Created by yin on 2017/1/13.
//
//

#import "TTAdWebResPreloadManager.h"

#import "Article.h"
#import "NSStringAdditions.h"
#import "NetworkUtilities.h"
#import "SSCommonLogic.h"
#import "SSSimpleCache.h"
#import "TTAdCanvasManager.h"
#import "TTAdCanvasModel.h"
#import "TTAdCanvasPreloader.h"
#import "TTAdFeedModel.h"
#import "TTAdLog.h"
#import "TTAdResourceDownloader.h"
#import "TTAdResourceModel.h"
#import "TTAdThirdPreloader.h"
#import "TTNetworkManager.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTMonitor.h"

#define kTTAdWebResPreloadModelsPath @"adWebResPreload.plist"
#define TTAdResPreloadResponse  @"TTAdResPreloadResponse"
#define TTAdResPreloadFirstEnterPage  @"TTAdResPreloadFirstEnterPage.plist"

#define kAdResourceTimeOutInterval 3600*24*3
#define kAdResourceDictMaxNumber 500

#define responseStr(str) [str stringByAppendingString:TTAdResPreloadResponse]


static  NSString * const hasInitKey = @"TTAdWebResURLProtocolKey";


@interface TTAdWebResPreloadManager ()

@property (nonatomic, strong) NSMutableSet* urlArray; //已经预加载的广告
@property (nonatomic, strong) NSMutableDictionary* resourceModelDict;
@property (nonatomic, strong) NSOperationQueue* operationQueue;
@property (nonatomic, assign) BOOL hasRegisterProtocol;
@property (nonatomic, assign) NSInteger preloadNum;
@property (nonatomic, assign) NSInteger matchNum;
@property (nonatomic, assign) BOOL executing;
@property (nonatomic, weak) NSBlockOperation* lastOperation;

@end

@implementation TTAdWebResPreloadManager

+ (instancetype)sharedManager{
    static TTAdWebResPreloadManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        _sharedManager.hasRegisterProtocol = NO;
        _sharedManager.isWebTargetPreload = NO;
        _sharedManager.preloadNum =0;
        _sharedManager.matchNum = 0;
        _sharedManager.urlArray = [NSMutableSet setWithObjects:@"", @"0", @"null", nil];
        _sharedManager.resourceModelDict = [[NSMutableDictionary alloc] init];
        _sharedManager.operationQueue = [[NSOperationQueue alloc] init];
        _sharedManager.operationQueue.maxConcurrentOperationCount = 1;
        _sharedManager.executing = NO;
        [_sharedManager readResourceModelDict];
//        [_sharedManager cachedCanvasProject];
    });
    return _sharedManager;
}

//- (void)cachedCanvasProject {
//    NSDictionary *cachedProject = [TTAdCanvasManager getCacheCanvasDict];
//    NSArray *cachedIds = [cachedProject allKeys];
//    [self.urlArray addObjectsFromArray:cachedIds];
//}

- (void)readResourceModelDict
{
    NSDictionary* modelDict = [self getDiskResourceModelDict];
    if (SSIsEmptyDictionary(modelDict)) {
        return;
    }
    [self.resourceModelDict addEntriesFromDictionary:modelDict];
}

- (void)preloadResource:(ExploreOrderedData *)orderData {
    Article *article = orderData.article;
    ArticlePreloadWebType preloadWebType = article.preloadWeb;
    BOOL canPreload = NO;
    if (preloadWebType == ArticlePreloadWebTypeAdsResAlways) {
        canPreload = YES;
    } else if (preloadWebType == ArticlePreloadWebTypeAdsResOnlyWifi && TTNetworkWifiConnected()) {
        canPreload = YES;
    }

    if (!canPreload) {
        return;
    }
    
    NSString *ad_id = orderData.ad_id;
    if (ad_id == nil) {
        return;
    }
    
    if (!ad_id) {
        return;
    }
    
    if ([self.urlArray containsObject:ad_id]) {
        return;
    }

    if ([TTAdCanvasPreloader needPreloadResource:orderData]) { // 沉浸式预加载
        id<TTAdPreloader> preloader = [TTAdCanvasPreloader sharedPreloader];
        [preloader preloadResource:orderData completed:^(BOOL result, NSError * _Nullable error) {
            if (result) {
                return;
            }
            NSMutableDictionary *attribute = @{}.mutableCopy;
            TTAdFeedModel *rawAd = orderData.raw_ad;
            attribute[@"ad_id"] = rawAd.ad_id;
            attribute[@"log_extra"] = rawAd.log_extra;
            if (error.domain != nil) {
                attribute[error.domain] = @(error.code);
            }
            [[TTMonitor shareManager] trackService:@"ad_canvas_preload" attributes:attribute];
        }];
        [self.urlArray addObject:ad_id];
    } else {    // 第三方普通预加载
        if ([SSCommonLogic isAdUseV2PreloadEnable]) {
            id<TTAdPreloader> preloader = [TTAdThirdPreloader sharedPreloader];
            [preloader preloadResource:orderData completed:nil];
            [self.urlArray addObject:ad_id];
        } else {
            [self preloadThirdResource:ad_id];
        }
    }
}

- (void)preloadThirdResource:(NSString *)ad_id {
    if (ad_id == nil) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:ad_id forKey:@"creative_id"];
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting preloadAdURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error,id jsonObj){
        StrongSelf;
        NSError *jsonError;
        TTAdResPreloadModel* model = [[TTAdResPreloadModel alloc] initWithDictionary:jsonObj error:&jsonError];
        if (model) {
            [self.urlArray addObject:ad_id];
            [self requestResourceList:model];
        }
    }];
}

- (void)requestResourceList:(TTAdResPreloadModel*)model
{
    if (model.data.count == 0) {
        return;
    }
    //超过500条,清除资源配置list
    if (self.resourceModelDict.allKeys.count > kAdResourceDictMaxNumber) {
        [self.resourceModelDict removeAllObjects];
    }
    [model.data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdResPreloadDataModel* dataModel = (TTAdResPreloadDataModel*)obj;
        if (dataModel) {
            //更新内存缓存及磁盘缓存
            [self synchronizeReourceModel:dataModel];
            //下载具体资源
            [self downloadResourceWithModel:dataModel];
        }
    }];
}


- (void)downloadResourceWithModel:(TTAdResPreloadDataModel *)dataModel
{
    NSDictionary* preloadData = dataModel.preload_data;
    if (SSIsEmptyDictionary(preloadData) || isEmptyString(dataModel.source_url)) {
        return;
    }
    NSString* cdnString = [preloadData valueForKey:@"url"];
    if (isEmptyString(cdnString)) {
        return;
    }
    //注意imageRes存在本地是以cndString为key存储的
    if ([[SSSimpleCache sharedCache] fileCachePathIfExist:cdnString]) {
        return;
    }
    
    [self addRequestOperationUrl:cdnString];
}

- (void)addRequestOperationUrl:(NSString*)urlString
{
    WeakSelf;
    NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
        StrongSelf;
        NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            StrongSelf;
            if (data && [data isKindOfClass:[NSData class]]) {
                //将CDN上imageRes存到本地,以cndString为key存储,后期直接以cndString为key取出
                [[SSSimpleCache sharedCache] setData:(NSData *)data forKey:urlString withTimeoutInterval:kAdResourceTimeOutInterval];
                if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSData* responseData = [NSKeyedArchiver archivedDataWithRootObject:response];
                    [[SSSimpleCache sharedCache] setData:responseData forKey:responseStr(urlString) withTimeoutInterval:kAdResourceTimeOutInterval];
                }
            }
            self.executing = NO;
        }];
        while (self.executing) {
            //execut未结束,hold住task的resume执行
        }
        [dataTask resume];
        self.executing = YES;
    }];
    if (self.lastOperation) {
        [operation addDependency:self.lastOperation];
    }
    [self.operationQueue addOperation:operation];
    self.lastOperation = operation;
}

- (void)synchronizeReourceModel:(TTAdResPreloadDataModel*)dataModel
{
    if (!dataModel || isEmptyString(dataModel.source_url)) {
        return;
    }
    
    if ([self.resourceModelDict.allKeys containsObject:dataModel.source_url]) {
        TTAdResPreloadDataModel* resourceModel = self.resourceModelDict[dataModel.source_url];
        if (resourceModel &&dataModel.ad_id.count >0) {
            NSNumber* ad_id = dataModel.ad_id[0];
            if (ad_id.longLongValue > 0) {
                if (![resourceModel.ad_id containsObject:ad_id]) {
                    [resourceModel.ad_id addObject:ad_id];
                }
                else
                {
                    [self.resourceModelDict setValue:dataModel forKey:dataModel.source_url];
                }
            }
        }
    }
    else
    {
        [self.resourceModelDict setValue:dataModel forKey:dataModel.source_url];
    }
    
    [self saveDiskResourceModelDict:self.resourceModelDict];
    
}

- (NSDictionary*)getResourceModelDict
{
    if (!SSIsEmptyDictionary(self.resourceModelDict)) {
        return self.resourceModelDict;
    }
    return nil;
}


- (void)saveDiskResourceModelDict:(NSDictionary*)modelDict
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:modelDict];
    NSString * filePath = [kTTAdWebResPreloadModelsPath stringCachePath];
    if (data) {
        [data writeToFile:filePath atomically:YES];
    }
}

- (NSDictionary*)getDiskResourceModelDict
{
    NSString * filePath = [kTTAdWebResPreloadModelsPath stringCachePath];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    
    if (!data) {
        return nil;
    }
    NSDictionary* modelDict = nil;
    @try {
        modelDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
        LOGE(@"TTAdWebResPreloadManager unarchieve:%@",exception.description);
    } @finally {
        
    }
    
    if (!modelDict||![modelDict isKindOfClass:[NSDictionary class]]||modelDict.allKeys.count == 0) {
        return nil;
    }
    return modelDict;
}

- (void)startCaptureAdWebResRequest
{
    if (self.hasRegisterProtocol == NO) {
        [NSURLProtocol registerClass:[TTAdWebResURLProtocol class]];
        //先将isWebTargetPreload置为空
        self.isWebTargetPreload = NO;
        self.preloadNum = 0;
        self.matchNum = 0;
        self.hasRegisterProtocol = YES;
    }
}

- (void)stopCaptureAdWebResRequest
{
    if (self.hasRegisterProtocol == YES) {
        [NSURLProtocol unregisterClass:[TTAdWebResURLProtocol class]];
        self.isWebTargetPreload = NO;
        self.preloadNum = 0;
        self.matchNum = 0;
        self.hasRegisterProtocol = NO;
        [self resetLoadStatus];
    }
}

- (void)finishCaptureThePage
{
    self.preloadNum = 0;
    self.matchNum = 0;
}

//将所有资源的是否userFor预加载状态还原
- (void)resetLoadStatus
{
    [self.resourceModelDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        TTAdResPreloadDataModel* model = (TTAdResPreloadDataModel*)obj;
        model.loadStatus = @(NO);
        model.matchStatus = @(NO);
    }];
}

- (void)clearCache
{
    if (self.resourceModelDict.allKeys.count > 0) {
        [self.resourceModelDict removeAllObjects];
    }
    if (self.urlArray.count > 0) {
        [self.urlArray removeAllObjects];
    }
    [self saveDiskResourceModelDict:self.resourceModelDict];
    [self clearEnterPageCache];
}

- (NSInteger)preloadNumInWebView
{
    return self.preloadNum;
}

- (NSInteger)matchNumInWebView
{
    return self.matchNum;
}

- (NSInteger)preloadTotalAdID:(NSString*)adid
{
    __block NSInteger resNum = 0;
    if (isEmptyString(adid)) {
        return resNum;
    }
    [self.resourceModelDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        TTAdResPreloadDataModel* model = (TTAdResPreloadDataModel*)obj;
        if (model && !SSIsEmptyArray(model.ad_id)) {
            if ([model.ad_id containsObject:@(adid.longLongValue)]) {
                resNum ++;
            }
        }
    }];
    return resNum;
}

- (BOOL)hasPreloadResource:(NSString *)adId
{
    __block BOOL contain = NO;
    if (isEmptyString(adId)) {
        return NO;
    }
    [self.resourceModelDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        TTAdResPreloadDataModel* model = (TTAdResPreloadDataModel*)obj;
        if (model && !SSIsEmptyArray(model.ad_id)) {
            if ([model.ad_id containsObject:@(adId.longLongValue)]) {
                contain = YES;
            }
        }
    }];
    return contain;
}

- (BOOL)isFirstEnterPageAdid:(NSString*)adid
{
    if (isEmptyString(adid)) {
        return NO;
    }
    NSString * filePath = [TTAdResPreloadFirstEnterPage stringCachePath];
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    BOOL containAdId = NO;
    if ([dict.allKeys containsObject:adid]) {
        if ([[dict valueForKey:adid] integerValue] == 1) {
            containAdId = YES;
        }
    }
    [dict setValue:@"1" forKey:adid];
    [dict writeToFile:filePath atomically:YES];
    return !containAdId;
}

- (void)clearEnterPageCache
{
    NSString * filePath = [TTAdResPreloadFirstEnterPage stringCachePath];
    [@{} writeToFile:filePath atomically:YES];
}

@end

@interface TTAdWebResURLProtocol ()

@end

@implementation TTAdWebResURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest*)theRequest
{
    if ([SSCommonLogic isAdResPreloadEnable] == NO) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:hasInitKey inRequest:theRequest]) {
        return NO;
    }
    
    NSString* requestHeader = [theRequest valueForHTTPHeaderField:@"User-Agent"];
    if (isEmptyString(requestHeader)) {
        return NO;
    }
   
    BOOL hasContain = NO;
    NSDictionary* modelDict = [[TTAdWebResPreloadManager sharedManager] getResourceModelDict];
    //统计matchUrl数量
    [self setPreloadNumDict:modelDict containUrl:theRequest.URL.absoluteString];
    hasContain = [self hasModelDict:modelDict containUrl:theRequest.URL.absoluteString];
    return hasContain;
}


+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)theRequest
{
    return theRequest;
}

- (void)startLoading
{
    //做下标记，防止递归调用
    [NSURLProtocol setProperty:@(YES) forKey:hasInitKey inRequest:[self.request mutableCopy]];
    
    NSDictionary* modelDict = [[TTAdWebResPreloadManager sharedManager] getResourceModelDict];
    NSString* urlString = self.request.URL.absoluteString;
    TTAdResPreloadDataModel* dataModel = [[self class] dataModel:modelDict url:urlString];
    NSString* cdnString = [dataModel.preload_data valueForKey:@"url"];
    if (dataModel && [[SSSimpleCache sharedCache] isCacheExist:cdnString] && [[SSSimpleCache sharedCache] isCacheExist:responseStr(cdnString)]) {
        
        [TTAdWebResPreloadManager sharedManager].isWebTargetPreload = YES;
        //同一个url被load多次 preloadNum不重复计算 (比如页面再次刷新)
        if (dataModel.loadStatus.boolValue == NO) {
            [TTAdWebResPreloadManager sharedManager].preloadNum += 1;
            dataModel.loadStatus = @(YES);
        }
        
        NSData *data = [[SSSimpleCache sharedCache] dataForUrl:cdnString];
        
        NSData* responseData = [[SSSimpleCache sharedCache] dataForUrl:[cdnString stringByAppendingString:TTAdResPreloadResponse]];
        
        NSHTTPURLResponse* httpResponse = [NSKeyedUnarchiver unarchiveObjectWithData:responseData];
        
        NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:[self.request URL] statusCode:httpResponse.statusCode HTTPVersion:nil headerFields:httpResponse.allHeaderFields];
        
        [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        
        [[self client] URLProtocol:self didLoadData:data];
        [[self client] URLProtocolDidFinishLoading:self];
        
    }
    
}

+ (BOOL)hasModelDict:(NSDictionary*)modelDict containUrl:(NSString*)urlString
{
    if (SSIsEmptyDictionary(modelDict) || isEmptyString(urlString)) {
        return NO;
    }
    BOOL hasContain = NO;
    
    if ([modelDict.allKeys containsObject:urlString]) {
        TTAdResPreloadDataModel* dataModel = [modelDict valueForKey:urlString];
        NSString* cdnString = [dataModel.preload_data valueForKey:@"url"];
        if (dataModel &&[dataModel isKindOfClass:[TTAdResPreloadDataModel class]]) {
            if ([[SSSimpleCache sharedCache] isCacheExist:cdnString] && [[SSSimpleCache sharedCache] isCacheExist:responseStr(cdnString)]) {
                hasContain = YES;
            }
        }
    }
    return hasContain;
}

+ (void)setPreloadNumDict:(NSDictionary*)modelDict containUrl:(NSString*)urlString
{
    if (SSIsEmptyDictionary(modelDict) || isEmptyString(urlString)) {
        return ;
    }
    TTAdResPreloadDataModel* dataModel = [self dataModel:modelDict url:urlString];
    
    if ([modelDict.allKeys containsObject:urlString]) {
        [TTAdWebResPreloadManager sharedManager].isWebTargetPreload = YES;
        //同一个url被load多次 preloadNum不重复计算
        if (dataModel.matchStatus.boolValue == NO) {
            [TTAdWebResPreloadManager sharedManager].matchNum += 1;
            dataModel.matchStatus = @(YES);
        }
    }
    
}

+ (TTAdResPreloadDataModel*)dataModel:(NSDictionary*)modelDict url:(NSString*)urlString
{
    if (SSIsEmptyDictionary(modelDict)) {
        return nil;
    }
    TTAdResPreloadDataModel* dataModel = nil;
    if ([modelDict.allKeys containsObject:urlString]) {
        TTAdResPreloadDataModel* model = [modelDict valueForKey:urlString];
        if (model &&[model isKindOfClass:[TTAdResPreloadDataModel class]]) {
            dataModel = model;
        }
    }
    return dataModel;
}

- (void)stopLoading
{
    
}

@end

//
//  TTArticleSearchManager.m
//  Article
//
//  Created by yangning on 2017/4/17.
//
//

#import "TTArticleSearchManager.h"
#import "TTPersistence.h"
#import "TTNetworkManager.h"
#import "TTSearchHomeSugModel.h"
#import "ArticleURLSetting.h"
#import "JSONAdditions.h"

NSString *const TTArticleSearchRecommendStateChangedNotification = @"TTArticleSearchRecommendStateChangedNotification";

NSString *const TTWeatherHasChangeNotification = @"TTWeatherHasChangeNotification";
NSString *const TTWeatherIconRefreshIntervalKey = @"TTWeatherIconRefreshIntervalKey";
NSString *const TTWeatherIconRefreshLastTimeKey = @"TTWeatherIconRefreshLastTimeKey";
NSString *const TTWeatherModelCacheKey = @"TTWeatherModelCacheKey";

static NSString *const kTTArticleSearchCacheFileName = @"TTArticleSearch.plist";

NSString *const TTArticleDefaultSearchHistoryCacheKey = @"com.ss.search.keyword";
NSString *const TTArticleEntrySearchHistoryCacheKey   = @"com.ss.entry.search.keyword";

static NSString *const kTTArticleSearchRecommendHiddenCacheKey = @"com.ss.search.recommend_hidden";

static const NSInteger kMaxArticleSearchHistoryKeywordCount = 20;

// 注意：以下常量为服务端返回类型字符串，请勿修改
static NSString *const kTTArticleSearchKeywordHistoryType   = @"hist";
static NSString *const kTTArticleSearchKeywordRecommendType = @"recom";
static NSString *const kTTArticleSearchKeywordInboxType     = @"inbox";

//////////////////////////////////////////////////////////////////////////////////////

@implementation TTArticleSearchKeyword
{
    NSString *_keyword;
    NSString *_typeString;
}

- (instancetype)initWithKeyword:(NSString *)keyword typeString:(NSString *)typeString
{
    if (self = [super init]) {
        _keyword = [keyword copy];
        _typeString = [typeString copy];
    }
    return self;
}

- (NSString *)keyword
{
    return _keyword;
}

- (TTArticleSearchKeywordType)type
{
    if ([_typeString isEqualToString:kTTArticleSearchKeywordHistoryType]) {
        return TTArticleSearchKeywordHistory;
    } else if ([_typeString isEqualToString:kTTArticleSearchKeywordRecommendType]) {
        return TTArticleSearchKeywordRecommend;
    } else if ([_typeString isEqualToString:kTTArticleSearchKeywordInboxType]) {
        return TTArticleSearchKeywordInbox;
    }
    NSAssert(NO, @"unknown type.");
    return TTArticleSearchKeywordRecommend;
}

- (NSString *)typeString
{
    return _typeString;
}

- (BOOL)isEqualToSearchKeyword:(TTArticleSearchKeyword *)searchKeyword
{
    if (!searchKeyword) {
        return NO;
    }
    
    BOOL haveEqualKeyword = (!self.keyword && !searchKeyword.keyword) || [self.keyword isEqualToString:searchKeyword.keyword];
    BOOL haveEqualType = (!self.typeString && !searchKeyword.typeString) || [self.typeString isEqualToString:searchKeyword.typeString];
    
    return haveEqualKeyword && haveEqualType;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[TTArticleSearchKeyword class]]) {
        return NO;
    }
    
    return [self isEqualToSearchKeyword:object];
}

- (NSUInteger)hash
{
    return [self.keyword hash] ^ [self.typeString hash];
}

@end

//////////////////////////////////////////////////////////////////////////////////////

@implementation TTArticleSearchHistoryContext

@end

//////////////////////////////////////////////////////////////////////////////////////

@interface TTArticleSearchManager ()

@property (nonatomic) TTArticleSearchHistoryContext *context;
@property (nonatomic) TTPersistence *persistence;

@property (nonatomic, copy) NSArray<TTArticleSearchKeyword *> *inboxKeywords;
@property (nonatomic, copy) NSArray<TTArticleSearchKeyword *> *historyKeywords;
@property (nonatomic, copy) NSArray<TTArticleSearchKeyword *> *recommendKeywords;

@property (nonatomic) BOOL isLoading;

@end

@implementation TTArticleSearchManager

- (instancetype)init
{
    return [self initWithContext:nil];
}

- (instancetype)initWithContext:(void(^)(TTArticleSearchHistoryContext *))block
{
    if (self = [super init]) {
        _context = [TTArticleSearchHistoryContext new];
        if (block) {
            block(_context);
        }
        [self loadLocalCache];
    }
    return self;
}

#pragma mark - Public method

- (void)insertKeyword:(NSString *)keyword
{
    NSCParameterAssert(!isEmptyString(keyword));
    if (isEmptyString(keyword)) {
        return;
    }
    
    TTArticleSearchKeyword *searchKeyword = [[TTArticleSearchKeyword alloc] initWithKeyword:keyword typeString:kTTArticleSearchKeywordHistoryType];
    NSMutableArray *historyWords = [self.historyKeywords mutableCopy];
    [historyWords removeObject:searchKeyword];
    [historyWords insertObject:searchKeyword atIndex:0];
    
    if (historyWords.count > kMaxArticleSearchHistoryKeywordCount) {
        [historyWords removeLastObject];
    }
    self.historyKeywords = [historyWords copy];
    [self synchronize];
}

- (void)removeKeyword:(NSString *)keyword
{
    NSCParameterAssert(!isEmptyString(keyword));
    if (isEmptyString(keyword)) {
        return;
    }
    
    TTArticleSearchKeyword *searchKeyword = [[TTArticleSearchKeyword alloc] initWithKeyword:keyword typeString:kTTArticleSearchKeywordHistoryType];
    NSMutableArray *historyWords = [self.historyKeywords mutableCopy];
    [historyWords removeObject:searchKeyword];
    self.historyKeywords = [historyWords copy];
    [self synchronize];
}

- (void)removeAllKeywords
{
    self.historyKeywords = @[];
    [self synchronize];
}

- (BOOL)isContentEmpty
{
    return self.historyKeywords.count + self.recommendKeywords.count + self.inboxKeywords.count == 0;
}

+ (BOOL)recommendHiddenIndeed
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kTTArticleSearchRecommendHiddenCacheKey] &&
        [[NSUserDefaults standardUserDefaults] boolForKey:kTTArticleSearchRecommendHiddenCacheKey]) {
        return YES;
    }
    return NO;
}

+ (BOOL)recommendHidden
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTArticleSearchRecommendHiddenCacheKey];
}

+ (void)setRecommendHidden:(BOOL)hidden
{
    [[NSUserDefaults standardUserDefaults] setBool:hidden forKey:kTTArticleSearchRecommendHiddenCacheKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:TTArticleSearchRecommendStateChangedNotification object:self userInfo:nil];
}

+ (void)tryFetchSearchTipIfNeedWithTabName:(NSString *)tab categoryID:(NSString *)categoryID
{
    NSString *refreshCountForSerchTipKey = [NSString stringWithFormat:@"kRefreshCountForSearchTip%@",tab];
    NSString *currentRefreshCountKey = [NSString stringWithFormat:@"kCountRefreshedForSearchTip%@",tab];

    // 服务端设定的刷新次数
    NSInteger refreshCount = [[NSUserDefaults standardUserDefaults] integerForKey:refreshCountForSerchTipKey];
    if (refreshCount <= 0) {
        refreshCount = 4;
    }
    // 当前刷新次数
    NSInteger countHasRefreshed = [[NSUserDefaults standardUserDefaults] integerForKey:currentRefreshCountKey];
    // 刷新次数+1
    [[NSUserDefaults standardUserDefaults] setInteger:(countHasRefreshed + 1) % refreshCount forKey:currentRefreshCountKey];
    
    // 满足刷新条件
    if (countHasRefreshed % refreshCount == 0) {
        [self fetchHomePageSuggestWithFlag:TTArticleSearchHomeFlagSuggest tabName:tab categoryID:categoryID];
    }
}

+ (void)fetchHomePageSuggestWithFlag:(TTArticleSearchHomeFlag)flag tabName:(NSString *)tab categoryID:(NSString *)categoryID
{
    if ((flag & (TTArticleSearchHomeFlagSuggest | TTArticleSearchHomeFlagWeather)) == 0) {
        return;
    }
    
    NSString *refreshCountForSerchTipKey = [NSString stringWithFormat:@"kRefreshCountForSearchTip%@",tab];
    NSString *homePageSearchSuggestKey = [NSString stringWithFormat:@"kHomepageSearchSuggest%@",[tab isEqualToString:@"video"]? @"video" : @"normal"];

    NSMutableDictionary *suggestParams = [NSMutableDictionary dictionaryWithCapacity:2];
    
    if (flag & TTArticleSearchHomeFlagSuggest) {
        NSMutableDictionary *suggestWord = [NSMutableDictionary dictionary];
        [suggestWord setValue:tab forKey:@"from"];
        [suggestWord setValue:categoryID forKey:@"sug_category"];
        [suggestParams setValue:suggestWord forKey:@"suggest_word"];
    }
    
    if (flag & TTArticleSearchHomeFlagWeather) {
        [suggestParams setValue:@(1) forKey:@"weather"];
    }
    
    NSString *json = [suggestParams tt_JSONRepresentation];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:json forKey:@"suggest_params"];
    
    flag &= (TTArticleSearchHomeFlagSuggest | TTArticleSearchHomeFlagWeather);
    [params setValue:@(flag) forKey:@"flag"];
    
    if ([SSCommonLogic searchHintSuggestEnable]) {
        [params setValue:@(1) forKey:@"recom_cnt"];
    }
    
    NSString *url = [ArticleURLSetting searchPlaceholderTextURLString];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error && [jsonObj isKindOfClass:[NSDictionary class]]) {
            NSError *jsonError = nil;
            TTSearchHomeSugModel *model = [[TTSearchHomeSugModel alloc] initWithDictionary:jsonObj error:&jsonError];
            if (!jsonError && model.data) {
                if (flag & TTArticleSearchHomeFlagSuggest) {
                    NSString *placeholder = model.data.homePageSearchSuggest;
                    NSInteger call_per_refresh = [model.data.callPerRefresh intValue];
                    
                    [[NSUserDefaults standardUserDefaults] setInteger:call_per_refresh forKey:refreshCountForSerchTipKey];
                    
                    NSString *oldPlaceholder = [[NSUserDefaults standardUserDefaults] valueForKey:homePageSearchSuggestKey];
                    
                    if (!oldPlaceholder || ![oldPlaceholder isEqualToString:placeholder]) {
                        [[NSUserDefaults standardUserDefaults] setValue:placeholder forKey:homePageSearchSuggestKey];
                        
                        if (!isEmptyString(tab)) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"kSearchPlaceHolderHasChanged" object:self userInfo:@{@"tab":tab}];
                        }
                    }
                }
                
                if (flag & TTArticleSearchHomeFlagWeather) {
                    if (model.data.weather) {
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
                        [userInfo setValue:tab forKey:@"tab"];
                        [userInfo setValue:model.data.weather forKey:@"weatherModel"];
                        
                        NSInteger weatherRefreshInterval = [model.data.weather_refresh_interval intValue];
                        [[NSUserDefaults standardUserDefaults] setInteger:weatherRefreshInterval forKey:TTWeatherIconRefreshIntervalKey];
                        
                        [self updateCachedWeather:model.data.weather];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:TTWeatherHasChangeNotification object:self userInfo:userInfo];
                    }
                }
            }
        }
    }];

}


+ (void)tryGetWeather:(NSString *)categoryID tabName:(NSString *)tabName {
    [TTArticleSearchManager fetchHomePageSuggestWithFlag:TTArticleSearchHomeFlagWeather tabName:tabName categoryID:categoryID];
}

+ (void)updateCachedWeather:(TTSearchWeatherModel *)weatherModel {
    weatherModel.current_time = @([[NSDate date] timeIntervalSince1970]); // 使用本地时间，接口里返回的值不知道是什么时间，与当前时间相差较大
    NSDictionary *weatherDict = [weatherModel toDictionary];
    [[NSUserDefaults standardUserDefaults] setValue:weatherDict forKey:TTWeatherModelCacheKey];
}

+ (TTSearchWeatherModel *)cachedWeatherModel {
    NSDictionary *weatherDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:TTWeatherModelCacheKey];
    TTSearchWeatherModel *cacheWeather = [[TTSearchWeatherModel alloc] initWithDictionary:weatherDict error:nil];
    
    // 缓存有效期2小时
    if ([[NSDate date] timeIntervalSince1970] - [cacheWeather.current_time floatValue] > 2 * 3600) {
        return nil;
    }
    return cacheWeather;
}

+ (BOOL)enableWeather {
    static BOOL enable = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enable = [SSCommonLogic boolForKey:@"tt_top_searchbar_weather_setting"];
    });
    return enable;
}

#pragma mark - Custom accessors

- (TTPersistence *)persistence
{
    if (!_persistence) {
        _persistence = [TTPersistence persistenceWithName:kTTArticleSearchCacheFileName];
    }
    return _persistence;
}

#pragma mark - Private methods

- (void)loadLocalCache
{
    NSArray *words = [NSArray arrayWithArray:[self.persistence objectForKey:self.context.cacheKey]];
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *word in words) {
        TTArticleSearchKeyword *keyword = [[TTArticleSearchKeyword alloc] initWithKeyword:word typeString:kTTArticleSearchKeywordHistoryType];
        [array addObject:keyword];
    }
    self.historyKeywords = [array copy];
}

- (void)synchronize
{
    NSArray *words = [self.historyKeywords valueForKeyPath:@"keyword"];
    [self.persistence setObject:words forKey:self.context.cacheKey];
    [self.persistence save];
    if (self.delegate) {
        [self.delegate articleSearchManager:self didUpdateWithError:nil];
    }
}

- (void)fetchSearchSuggestInfo
{
    WeakSelf;
    [self fetchSearchSuggestInfoWithFrom:self.context.from
                                category:self.context.category
                         homePageSuggest:self.context.homePageSuggest
                              completion:^(NSArray<TTArticleSearchKeyword *> *recommendKeywords, NSArray<TTArticleSearchKeyword *> *inboxKeywords, NSError *error) {
                                  StrongSelf;
                                  self.recommendKeywords = recommendKeywords;
                                  self.inboxKeywords = inboxKeywords;
                                  
                                  if (self.delegate) {
                                      [self.delegate articleSearchManager:self didUpdateWithError:error];
                                  }
                              }];
}

- (void)fetchSearchSuggestInfoWithFrom:(NSString *)from
                              category:(NSString *)category
                       homePageSuggest:(NSString *)homePageSuggest
                            completion:(void(^)(NSArray<TTArticleSearchKeyword *> *recommendKeywords, NSArray<TTArticleSearchKeyword *> *inboxKeywords, NSError *error))completion
{
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    NSString *url =  [NSString stringWithFormat:@"%@/search/suggest/initial_page/",[CommonURLSetting baseURL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"from"] = from ? : @"";
    params[@"sug_category"] = category ? : @"";
    params[@"homepage_search_suggest"] = homePageSuggest ? : @"";
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url
                                                     params:params
                                                     method:@"GET"
                                           needCommonParams:YES
                                                   callback:^(NSError *error, id jsonObj) {
                                                       StrongSelf;
                                                       self.isLoading = NO;
                                                       [self handleResponse:jsonObj error:error completion:completion];
                                                   }];
}

- (void)handleResponse:(id)response
                 error:(NSError *)error
        completion:(void(^)(NSArray<TTArticleSearchKeyword *> *recommendKeywords, NSArray<TTArticleSearchKeyword *> *inboxKeywords, NSError *error))completion
{
    if (!completion) {
        return;
    }
    
    if (error) {
        completion(nil, nil, error);
        return;
    }
    
    if (![response isKindOfClass:[NSDictionary class]]) {
        completion(nil, nil, [self invalidResponseError]);
        return;
    }
    
    if (![response[@"message"] isEqualToString:@"success"]) {
        completion(nil, nil, [self failedRequestError]);
        return;
    }
    
    if (![response[@"data"] isKindOfClass:[NSDictionary class]]) {
        completion(nil, nil, [self invalidResponseError]);
        return;
    }
    
    NSArray *suggest_word_list = response[@"data"][@"suggest_word_list"];
    if (![suggest_word_list isKindOfClass:[NSArray class]]) {
        completion(nil, nil, [self invalidResponseError]);
        return;
    }
    
    NSMutableArray<TTArticleSearchKeyword *> *recommendKeywords = [NSMutableArray array];
    NSMutableArray<TTArticleSearchKeyword *> *inboxKeywords = [NSMutableArray array];
    for (NSDictionary *item in suggest_word_list) {
        if (![item isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        if (![item[@"type"] isKindOfClass:[NSString class]] || ![item[@"word"] isKindOfClass:[NSString class]]) {
            continue;
        }
        
        if ([item[@"type"] isEqualToString:kTTArticleSearchKeywordRecommendType]) {
            TTArticleSearchKeyword *keyword = [[TTArticleSearchKeyword alloc] initWithKeyword:item[@"word"] typeString:item[@"type"]];
            [recommendKeywords addObject:keyword];
        }
        else if ([item[@"type"] isEqualToString:kTTArticleSearchKeywordInboxType]) {
            TTArticleSearchKeyword *keyword = [[TTArticleSearchKeyword alloc] initWithKeyword:item[@"word"] typeString:item[@"type"]];
            [inboxKeywords addObject:keyword];
        }
    }
    completion([recommendKeywords copy], [inboxKeywords copy], nil);
}

- (NSError *)failedRequestError
{
    return [NSError errorWithDomain:NSStringFromClass(self.class)
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey: @"Failed request."}];
}

- (NSError *)invalidResponseError
{
    return [NSError errorWithDomain:NSStringFromClass(self.class)
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey: @"Invalid response."}];
}

@end

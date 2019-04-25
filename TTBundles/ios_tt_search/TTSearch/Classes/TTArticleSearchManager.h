//
//  TTArticleSearchManager.h
//  Article
//
//  Created by yangning on 2017/4/17.
//
//

#import <Foundation/Foundation.h>

extern NSString *const TTArticleDefaultSearchHistoryCacheKey;
extern NSString *const TTArticleEntrySearchHistoryCacheKey;

extern NSString *const TTArticleSearchRecommendStateChangedNotification;

extern NSString *const TTWeatherHasChangeNotification;
extern NSString *const TTWeatherIconRefreshIntervalKey;
extern NSString *const TTWeatherIconRefreshLastTimeKey;
extern NSString *const TTWeatherModelCacheKey;

typedef NS_ENUM(NSInteger, TTArticleSearchKeywordType) {
    TTArticleSearchKeywordHistory   = 0,
    TTArticleSearchKeywordRecommend = 1,
    TTArticleSearchKeywordInbox     = 2,
};

// 控制首页搜索提示框API(/search/suggest/homepage_suggest/)请求类型
typedef NS_OPTIONS(NSUInteger, TTArticleSearchHomeFlag) {
    TTArticleSearchHomeFlagSuggest = 1 << 0,    // 推荐词
    TTArticleSearchHomeFlagWeather = 1 << 1,    // 天气
};

@protocol TTArticleSearchManagerDelegate;
@class TTArticleSearchKeyword;
@class TTArticleSearchHistoryContext;
@class TTSearchWeatherModel;

@interface TTArticleSearchManager : NSObject

@property (nonatomic, copy, readonly) NSArray<TTArticleSearchKeyword *> *inboxKeywords;
@property (nonatomic, copy, readonly) NSArray<TTArticleSearchKeyword *> *historyKeywords;
@property (nonatomic, copy, readonly) NSArray<TTArticleSearchKeyword *> *recommendKeywords;

@property (nonatomic, weak) id<TTArticleSearchManagerDelegate> delegate;

- (instancetype)initWithContext:(void(^)(TTArticleSearchHistoryContext *))block NS_DESIGNATED_INITIALIZER;

- (void)insertKeyword:(NSString *)keyword;
- (void)removeKeyword:(NSString *)keyword;
- (void)removeAllKeywords;

- (void)fetchSearchSuggestInfo;

- (BOOL)isContentEmpty;

+ (BOOL)recommendHiddenIndeed;
+ (BOOL)recommendHidden;
+ (void)setRecommendHidden:(BOOL)hidden;

// 取首页搜索框里的建议搜索词
+ (void)tryFetchSearchTipIfNeedWithTabName:(NSString *)tab categoryID:(NSString *)categoryID;

// 取首页搜索框里的建议搜索词和天气
+ (void)fetchHomePageSuggestWithFlag:(TTArticleSearchHomeFlag)flag tabName:(NSString *)tab categoryID:(NSString *)categoryID;

// 启动后定时获取天气
+ (void)tryGetWeather:(NSString *)categoryID tabName:(NSString *)tabName;

// 缓存在磁盘的天气数据
+ (TTSearchWeatherModel *)cachedWeatherModel;

// 是否显示天气
+ (BOOL)enableWeather;

@end

@protocol TTArticleSearchManagerDelegate <NSObject>

@optional
- (void)articleSearchManager:(TTArticleSearchManager *)manager didUpdateWithError:(NSError *)error;

@end

@interface TTArticleSearchKeyword : NSObject

@property (nonatomic, readonly) NSString *keyword;
@property (nonatomic, readonly) TTArticleSearchKeywordType type;
@property (nonatomic, readonly) NSString *typeString;

- (instancetype)initWithKeyword:(NSString *)keyword typeString:(NSString *)typeString;

@end

@interface TTArticleSearchHistoryContext : NSObject

@property (nonatomic, copy) NSString *cacheKey;
@property (nonatomic, copy) NSString *from;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *homePageSuggest;

@end

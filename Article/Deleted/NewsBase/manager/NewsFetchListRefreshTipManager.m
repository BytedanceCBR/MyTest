//
//  NewsFetchListRefreshTipManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-10-31.
//
//

#import "NewsFetchListRefreshTipManager.h"
#import "ArticleURLSetting.h"
#import "TTArticleCategoryManager.h"
#import "TTLocationManager.h"
#import "NSDictionary+TTAdditions.h"
#import "TTNetworkManager.h"

@interface NewsFetchListRefreshTipManager()

@property(nonatomic, strong)NSMutableArray <TTHttpTask *> * fetchInfoOPs;

@end

@implementation NewsFetchListRefreshTipManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _fetchInfoOPs = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    [_fetchInfoOPs enumerateObjectsUsingBlock:^(TTHttpTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    
    [_fetchInfoOPs removeAllObjects];
}

- (void)cancel
{
    [_fetchInfoOPs enumerateObjectsUsingBlock:^(TTHttpTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    [_fetchInfoOPs removeAllObjects];
}

- (void)fetchListRefreshTipWithMinBehotTime:(NSTimeInterval)minBehotTime categoryID:(NSString *)categoryID count:(NSUInteger)count
{
    if (isEmptyString(categoryID)) {
        return;
    }
    
    NSString * url = [ArticleURLSetting refreshTipURLString];
    NSMutableDictionary * getCondition = [NSMutableDictionary dictionaryWithCapacity:10];
    [getCondition setValue:@(minBehotTime) forKey:@"min_behot_time"];
    [getCondition setValue:categoryID forKey:@"category"];
    [getCondition setValue:@(count) forKey:@"count"];
    
    TTCategory *newsLocalCategory = [TTArticleCategoryManager newsLocalCategory];
    if (newsLocalCategory) {
        if ([TTArticleCategoryManager isUserSelectedLocalCity]) {
            [getCondition setValue:newsLocalCategory.name forKey:@"user_city"];
        }
    }

    NSString *city = [TTLocationManager sharedManager].city;
    [getCondition setValue:city forKey:@"city"];
    
    WeakSelf;
    __block TTHttpTask *fetchInfoOP = [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:getCondition method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        
        NSString * tipString = nil;
        NSInteger count = 0;
        
        if (error == nil) {
            NSDictionary *data = [jsonObj tt_dictionaryValueForKey:@"data"];
            tipString = [data tt_stringValueForKey:@"tip"];
            count = [data tt_intValueForKey:@"count"];
        }
        
        if (count <= 0) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
            [dict setValue:categoryID forKey:@"categoryID"];
            [dict setValue:@(count) forKey:@"count"];
            [[TTMonitor shareManager] trackService:@"feed_refresh_tip_abnormal" status:1 extra:dict];
        }
        else if (error != nil) {
            [[TTMonitor shareManager] trackService:@"feed_refresh_tip_api_error" status:1 extra:nil];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(refreshTipManager:fetchedTip:categoryID:count:)]) {
            [_delegate refreshTipManager:self fetchedTip:tipString categoryID:categoryID count:count];
        }
        [self.fetchInfoOPs removeObject:fetchInfoOP];
    }];
    
    [self.fetchInfoOPs addObject:fetchInfoOP];
}

@end

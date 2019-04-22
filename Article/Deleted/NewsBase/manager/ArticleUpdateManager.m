//
//  ArticleUpdateManager.m
//  Article
//
//  Created by SunJiangting on 14-12-16.
//
//

#import "ArticleUpdateManager.h"
#import "NewsFetchArticleDetailManager.h"
#import "ArticleURLSetting.h"
#import "TTNetworkManager.h"
#import "ExploreOrderedData+TTBusiness.h"

#define ArticleMaxRetryCount 5

static const NSInteger ArticleMaximumNumberOfRetryTimes = 5;
NSString *const ArticleDidUpdateNotification = @"ArticleDidUpdateNotification";

@interface ArticleUpdateManager ()
@property(nonatomic, strong) NSMutableDictionary *updateCommandQueue;
@end

@implementation ArticleUpdateManager
static ArticleUpdateManager *_sharedManager;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedManager = [[self alloc] init]; });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _updateCommandQueue = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

- (void)addUpdateCommand:(NSString *)commandId groupModels:(NSDictionary *)groupModels {
    if (groupModels.count == 0) {
        return;
    }
    [groupModels enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *commandKey = [NSString stringWithFormat:@"%@|%@", key, obj];
        [_updateCommandQueue setValue:commandId forKey:commandKey];
    }];
    
    for (NSNumber *uniqueID in groupModels.allKeys) {
        NSString *uniqueIDStr = [NSString stringWithFormat:@"%@", uniqueID];
        NSArray<Article *> *articles = [Article objectsWithQuery:@{@"uniqueID":uniqueIDStr}];
        for (Article *article in articles) {
            NSString *itemId = [groupModels valueForKey:article.groupModel.groupID];
            if ([itemId isEqualToString:@"0"] || [itemId isEqualToString:article.groupModel.itemID]) {
                [self fetchLatestArticleFull:article withOperationPriority:NSOperationQueuePriorityNormal atCDNIndex:0 processedError:nil];
            }
        }
    }
}

- (void)fetchLatestArticleFull:(Article *)article
         withOperationPriority:(NSOperationQueuePriority)priority
                    atCDNIndex:(NSUInteger)index
                processedError:(NSError *)error {
    NSString *requestURL = [self latestArticleURLString:article atCDNIndex:index];
    if (isEmptyString(requestURL)) {
        return;
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:requestURL params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (error) {
            [self fetchLatestArticleFull:article withOperationPriority:priority atCDNIndex:(index + 1) processedError:error];
        } else {
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[jsonObj objectForKey:@"data"]];
            if (!article) {
                return;
            }

            [data removeObjectForKey:@"group_id"];
            if (data[@"item_id"]) {
                data[@"item_id"] = [NSString stringWithFormat:@"%@", data[@"item_id"]];
            }
            
            NSString *abstract = [data valueForKey:@"abstract"];
            //此处需要判断没有删除的情况， 没有返回delete的，都认为没有被删除
            if (![[data allKeys] containsObject:@"delete"]) {
                [data setObject:@0 forKey:@"delete"];
            }
            [self _resetArticle:article];
            article.abstract = abstract;
            [article updateWithDictionary:data];
            [article save];
            
            NSString *groupId = [NSString stringWithFormat:@"%lld", article.uniqueID];
            if (!isEmptyString(groupId)) {
                [[NSNotificationCenter defaultCenter] postNotificationName:ArticleDidUpdateNotification object:nil userInfo:@{@"uniqueID":groupId}];
            }
        }

    }];
}

// 地址返回为空，则不会发送请求
- (NSString *)latestArticleURLString:(Article *)article atCDNIndex:(NSUInteger)index {
    if (article.uniqueID == 0 || index > ArticleMaximumNumberOfRetryTimes) {
        return nil;
    }
    NSArray *hosts = [NewsFetchArticleDetailManager articleDetailURLHostsIsFull:YES];

    if (index >= hosts.count) {
        return nil;
    }

    NSString *host = nil;
    if (index == 0) {
        if ([hosts count] == 0) {
            host = [[CommonURLSetting defaultArticleDetailURLHosts] objectAtIndex:0];;
        } else {
            host = [hosts objectAtIndex:0];
        }
    } else {
        host = [hosts objectAtIndex:index];
    }
    
    NSArray<NSString *> *hostComponents = [host componentsSeparatedByString:@"://"];
    if (hostComponents.count == 1) {
        host = [NSString stringWithFormat:@"http://%@", host];
    }
    NSString *groupId = [NSString stringWithFormat:@"%lld", article.uniqueID];
    NSString *itemID = article.itemID;
    NSNumber *aggrType = article.aggrType;
    if (isEmptyString(itemID)) {
        itemID = @"0";
    }
    NSString *commandKey = [NSString stringWithFormat:@"%@|%@", groupId, itemID];
    NSString *commandID = [_updateCommandQueue valueForKey:commandKey];
    NSString *prefix = [NSString stringWithFormat:@"%@%@", host, [ArticleURLSetting detailFullPathString]];
    if (!commandID) {
        commandID = @"0";
    }
    return [NewsFetchArticleDetailManager articleCDNPathWithPrefix:prefix groupID:groupId itemID:itemID aggrType:aggrType.integerValue   commandID:commandID];
}

- (void)_resetArticle:(Article *)article {
    article.comment = nil;
    article.comments = nil;
    article.zzComments = nil;
    article.listGroupImgDicts = nil;
    article.imageDetailListString = nil;
    article.largeImageDict = nil;
    article.middleImageDict = nil;
    article.thumbnailListString = nil;
    article.filterWords = nil;
}

@end

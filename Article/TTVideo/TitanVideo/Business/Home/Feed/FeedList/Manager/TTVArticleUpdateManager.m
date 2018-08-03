//
//  TTVArticleUpdateManager.m
//  Article
//
//  Created by SunJiangting on 14-12-16.
//
//

#import "TTVArticleUpdateManager.h"
#import "TTServiceDeviceHelper.h"
#import "TTVideoArticleService.h"
#import "TTVVideoArticle+Extension.h"
#import "TTVideoApiModel.h"

#define kArticleFullURLHostKey @"kArticleFullURLHostKey"        //请求完整信息
#define kArticleContentURLHostKey @"kArticleContentURLHostKey"  //请求详情页信息（content，image）
#define ArticleMaxRetryCount 5

static const NSInteger ArticleMaximumNumberOfRetryTimes = 5;

extern NSError *ttcommonlogic_handleError(NSError *error, NSDictionary *result, NSString **exceptionInfo);

@interface TTVArticleUpdateManager ()

@property(nonatomic, strong) NSMutableDictionary *updateCommandQueue;
/// 处理更新命令的队列
@property(nonatomic, strong) NSMutableDictionary *updateOperationQueue;

@end

@implementation TTVArticleUpdateManager
static TTVArticleUpdateManager *_sharedManager;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedManager = [[self alloc] init]; });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _updateCommandQueue = [NSMutableDictionary dictionaryWithCapacity:1];
        _updateOperationQueue = [NSMutableDictionary dictionaryWithCapacity:1];
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

    //TODO: check
    for (NSNumber *uniqueID in groupModels.allKeys) {
        NSString *uniqueIDStr = [NSString stringWithFormat:@"%@", uniqueID];
        TTVideoArticleService *aritcleService = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService  class]];
        TTVVideoArticle *article = [aritcleService articlesByUniqueId:uniqueIDStr];
        if (article) {
            NSString *itemId = [groupModels valueForKey:@(article.groupId).stringValue];
            if ([itemId isEqualToString:@"0"] || [itemId isEqualToString:@(article.itemId).stringValue]) {
                [self fetchLatestArticleFull:article atCDNIndex:0 processedError:nil];
            }
        }
    }
}

- (void)fetchLatestArticleFull:(TTVVideoArticle *)article
                    atCDNIndex:(NSUInteger)index
                processedError:(NSError *)error {
    NSString *requestURL = [self latestArticleURLString:article atCDNIndex:index];
    NSString *iid = @(article.itemId).stringValue;
    if (isEmptyString(iid)) {
        iid = @"0";
    }
    NSString *commandKey = [NSString stringWithFormat:@"%@|%@", @(article.groupId), iid];
    if (isEmptyString(requestURL)) {
        // finish
        [_updateOperationQueue setValue:nil forKey:commandKey];
        return;
    }

    if ([_updateOperationQueue valueForKey:commandKey]) {
        TTHttpTask *task = [_updateOperationQueue valueForKey:commandKey];
        if ([task isKindOfClass:[TTHttpTask class]]) {
            [task cancel];
        }
    }
    TTHttpTask *task = [self taskWithUrl:requestURL atCDNIndex:index article:article];
    [_updateOperationQueue setValue:task forKey:commandKey];
}

- (TTHttpTask *)taskWithUrl:(NSString *)url atCDNIndex:(NSUInteger)index article:(TTVVideoArticle *)article
{
    TTHttpTask *task = [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, NSDictionary *jsonObj) {
        if (![jsonObj isKindOfClass:[NSDictionary class]]) {
            return ;
        }
        if (jsonObj) {
            jsonObj = @{@"result":jsonObj};
        }
        NSError *logicError = ttcommonlogic_handleError(error, jsonObj, NULL);
        NSString *groupId = @(article.groupId).stringValue;
        if (!isEmptyString(groupId)) {
            [_updateOperationQueue setValue:nil forKey:groupId];
        }
        if (logicError) {
            [self fetchLatestArticleFull:article atCDNIndex:(index + 1) processedError:logicError];
        } else {
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[jsonObj objectForKey:@"data"]];
            if ([data isKindOfClass:[NSDictionary class]]) {
                [data removeObjectForKey:@"group_id"];
                if (data[@"item_id"]) {
                    data[@"item_id"] = [NSString stringWithFormat:@"%@", data[@"item_id"]];
                }

                //此处需要判断没有删除的情况， 没有返回delete的，都认为没有被删除
                if (![[data allKeys] containsObject:@"delete"]) {
                    [data setObject:@0 forKey:@"delete"];
                }
#warning todop 返回的数据不全? 暂时禁用
                return;
                [article reset];
                article.abstract = [data valueForKey:@"abstract"];
                NSDictionary *dic = [jsonObj valueForKey:@"result"];
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    dic = [dic valueForKey:@"data"];
                }
                NSError *error = nil;
                TTFeedItemContentStructModel *content = [[TTFeedItemContentStructModel alloc] initWithDictionary:dic error:&error];
                if (error) {
                    return;
                }
                [article updateWithContentStruct:content];
                article.updated = YES;
            }

        }

    }];
    return task;
}

+ (NSArray *)defaultArticleDetailURLHosts {
    return @[@"m.quduzixun.com"];
}

- (NSArray *)articleDetailURLHostsIsFull:(BOOL)full
{
    NSArray * hosts = nil;
    if (full) {
        hosts = [[NSUserDefaults standardUserDefaults] objectForKey:kArticleFullURLHostKey];
    }
    else {
        hosts = [[NSUserDefaults standardUserDefaults] objectForKey:kArticleContentURLHostKey];
    }

    // 默认
    if (SSIsEmptyArray(hosts)) {
        hosts = [[self class] defaultArticleDetailURLHosts];
    }
    return hosts;
}

#warning todo 怎么防止主端变了.
- (NSString *)detailCDNAPIVersionString
{
    return @"16";
}

- (NSString *)articleCDNPathWithPrefix:(NSString *)prefix
                               groupID:(NSString *)groupID
                                itemID:(NSString *)itemID
                              aggrType:(NSInteger)groupType
                             commandID:(NSString *)commandID {
    if ([prefix hasSuffix:@"/"]) {
        prefix = [prefix substringToIndex:prefix.length - 1];
    }
    NSString *version = [self detailCDNAPIVersionString];
    NSString *platform = [TTServiceDeviceHelper isPadDevice] ? @"4" : @"2";
    NSMutableString *result = [NSMutableString stringWithCapacity:50];
    if (!isEmptyString(prefix)) {
        [result appendString:prefix];
    }
    [result appendFormat:@"/%@/%@", version, platform];
    if (!isEmptyString(groupID)) {
        [result appendFormat:@"/%@", groupID];
    } else {
        [result appendString:@"/0"];
    }
    if (!isEmptyString(itemID)) {
        [result appendFormat:@"/%@", itemID];
    } else {
        [result appendString:@"/0"];
    }
    [result appendFormat:@"/%@/", @(groupType)];
    if (!isEmptyString(commandID)) {
        [result appendString:commandID];
        [result appendString:@"/"];
    }
    return [result copy];
}

// 地址返回为空，则不会发送请求
- (NSString *)latestArticleURLString:(TTVVideoArticle *)article atCDNIndex:(NSUInteger)index {
    if (article.groupId == 0 || index > ArticleMaximumNumberOfRetryTimes) {
        return nil;
    }
    NSArray *hosts = [self articleDetailURLHostsIsFull:YES];

    if (index >= hosts.count) {
        return nil;
    }

    NSString *host = nil;
    if (index == 0) {
        if ([hosts count] == 0) {
            host = [[[self class] defaultArticleDetailURLHosts] objectAtIndex:0];;
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
    NSString *groupId = [NSString stringWithFormat:@"%lld", article.groupId];
    NSString *itemID = @(article.itemId).stringValue;
    NSNumber *aggrType = @(article.aggrType);
    if (isEmptyString(itemID)) {
        itemID = @"0";
    }
    NSString *commandKey = [NSString stringWithFormat:@"%@|%@", groupId, itemID];
    NSString *commandID = [_updateCommandQueue valueForKey:commandKey];
    NSString *prefix = [NSString stringWithFormat:@"%@%@", host, @"/article/full/"];
    if (!commandID) {
        commandID = @"0";
    }
    return [self articleCDNPathWithPrefix:prefix groupID:groupId itemID:itemID aggrType:aggrType.integerValue   commandID:commandID];
}


@end

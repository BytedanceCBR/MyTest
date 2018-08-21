//
//  SSHTTPProcesser.m
//  Article
//
//  Created by SunJiangting on 14-10-24.
//
//

#import "SSHTTPProcesser.h"
#import "TTHTTPProcesserMessage.h"
#import "TTMessageCenter.h"


#import "Article.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "NewsFetchArticleDetailManager.h"

#import "ExploreMixListDefine.h"
#import "ArticleUpdateManager.h"
#import "TTNetworkManager.h"
#import "NSDataAdditions.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
#import "TTAdManager.h"
#import "TTHTTPProcesserMessageHandle.h"
#import "TTVHTTPProcesserMessageHandle.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTServerDateCalibrator.h"
#import "TTArticleCategoryManager.h"

@interface SSHTTPProcesser ()
@property (nonatomic, strong) NSMutableArray *handledCommandIds;
@end

@implementation SSHTTPProcesser
static SSHTTPProcesser *_processer;
+ (instancetype)sharedProcesser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _processer = [[self alloc] init];
    });
    return _processer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.handledCommandIds = [NSMutableArray arrayWithCapacity:1];
        [TTHTTPProcesserMessageHandle shareTTHTTPProcesserMessageHandle];//接受视频接口发送的消息,处理下架等功能
        [TTVHTTPProcesserMessageHandle shareTTVHTTPProcesserMessageHandle];
    }
    return self;
}

- (void)preprocessHTTPResponse:(id<SSHTTPResponseProtocol>)HTTPResponse
      requestTotalTimeInterval:(int64_t)total
                    requestURL:(NSURL *)url
{
    /// 处理ResponseHeaders
    NSString *contentType = nil;
    if ([HTTPResponse respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *allHeaderFields = [HTTPResponse allHeaderFields];
        if (!SSIsEmptyDictionary(allHeaderFields)) {
            contentType = allHeaderFields[@"Content-Type"];
            [self processHTTPHeaderFields:allHeaderFields requestTotalTimeInterval:total requestURL:url];
            
            if (!contentType) {
                for (NSString *key in [allHeaderFields allKeys]) {
                    if ([[key lowercaseString] isEqualToString: [@"Content-Type" lowercaseString]]) {
                        contentType = allHeaderFields[key];
                    }
                }
            }
        }
    }
    if ([HTTPResponse respondsToSelector:@selector(responseData)]) {
        NSData *responseData = [HTTPResponse responseData];
        if (!(!responseData || ![responseData isKindOfClass:[NSData class]] || responseData.length == 0) && contentType && [contentType rangeOfString:@"ssmix="].location != NSNotFound) {
            responseData = [responseData tt_dataWithFingerprintType:TTFingerprintTypeEnumXOR];
            if ([HTTPResponse respondsToSelector:@selector(setResponseData:)]) {
                [HTTPResponse setResponseData:responseData];
            }
            
        }
    }
}

@end

#define kMaxRequestDelay    2000.f

@implementation SSHTTPProcesser (SSProcessHeaderFields)

- (void)processHTTPHeaderFields:(NSDictionary *)headerFields requestTotalTimeInterval:(int64_t)total requestURL:(NSURL *)url
{
    // 校准云端时钟
    NSString *headerKey = @"X-TT-TIMESTAMP";
    BOOL hasKey = [headerFields.allKeys containsObject:headerKey] || [headerFields.allKeys containsObject:[headerKey lowercaseString]];
    BOOL validHost = ([url.host rangeOfString:@"snssdk.com"].location != NSNotFound) || ([url.host rangeOfString:@"toutiao.com"].location != NSNotFound);
    if (hasKey && validHost && total < kMaxRequestDelay) {
        double serverTimestamp = [headerFields doubleValueForKey:headerKey defaultValue:0];
        if (serverTimestamp > 0) {
            NSTimeInterval accurateServerTimpstamp = serverTimestamp + total/1000.f;
            [[TTServerDateCalibrator sharedCalibrator] calibrateLocalDateWithServerTimeInterval:accurateServerTimpstamp];
        }
    }
    
    /// 处理Header部分,如果有文章时时下架，则通知文章时时下架
    /// 说明: gs=group_ids, as = ad_ids, p = params, t = type, rg = remove grup, ug = remove group is = item ids
    /// "X-SS-Command" = "[{\"i\": \"1\", \"p\": {\"gs\": \"123456\"}, \"t\": \"rg\"}]";
    NSString *command = [headerFields valueForKey:@"X-SS-Command"];
    //    if ([request.url.absoluteString rangeOfString:@"stream"].location != NSNotFound) {
    
    if (isEmptyString(command)) {
        return;
    }
    
    NSError *error = nil;
    NSArray *array = [NSString tt_objectWithJSONString:command error:&error];
    if (![array isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSMutableArray *feedbackIds = [NSMutableArray arrayWithCapacity:1];
    [array enumerateObjectsUsingBlock:^(NSDictionary * dict, NSUInteger idx, BOOL *stop) {
        
        if (![dict isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSString *feedbackId = [dict valueForKey:@"i"];
        NSString *type = [dict valueForKey:@"t"];
        
        if (!isEmptyString(feedbackId) && !isEmptyString(type)) {
            NSString *commandId = [NSString stringWithFormat:@"%@_%@", feedbackId, type];
            @synchronized (self) {
                BOOL hasHandled = [self.handledCommandIds containsObject:commandId];
                if (!hasHandled) {
                    [self.handledCommandIds addObject:commandId];
                } else {
                    return;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([type isEqualToString:@"sc"]) {
                NSDictionary *pDict = dict[@"p"];
                if (pDict && [pDict isKindOfClass:[NSDictionary class]]) {
                    if (pDict[@"tcnc"]) {
                        [SSCommonLogic setCategoryNameConfigDict:pDict[@"tcnc"]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kCategoryRefresh" object:nil userInfo:nil];
                    }
                    
                    if (pDict[@"tscc"]) {
                        [SSCommonLogic setFeedStartCategoryConfig:pDict[@"tscc"]];
                    }
                    
                    if (pDict[@"tstc"]) {
                        [SSCommonLogic setFeedStartTabConfig:pDict[@"tstc"]];
                    }
                    
                    if (pDict[@"ttc"]) {
                        [SSCommonLogic setCategoryTabAllConfig:pDict[@"ttc"]];
                    }
                }
            }
            
            if ([type isEqualToString:@"ar"]) {
                NSDictionary *pDict = dict[@"p"];
                if (pDict && [pDict isKindOfClass:[NSDictionary class]]) {
                    if (pDict[@"fcr"] && [pDict[@"fcr"] integerValue] == 1) {
                        [[TTArticleCategoryManager sharedManager] startGetCategory];
                    }
                }
            }
        });
        
        NSArray *groupOpts = @[@"rg", @"ug"];
        
        if ([groupOpts containsObject:type]) {
            
            NSDictionary *pDict = dict[@"p"];
            if (![pDict isKindOfClass:[NSDictionary class]]) {
                return;
            }
            
            NSArray *items = pDict[@"is"];
            if (![items isKindOfClass:[NSArray class]]) {
                return;
            }
            
            NSMutableDictionary *groupModels = [NSMutableDictionary dictionaryWithCapacity:2];
            [items enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSArray class]]) {
                    if (obj.count == 2) {
                        NSString *gi= [NSString stringWithFormat:@"%@", obj[0]];
                        NSString *ii =[NSString stringWithFormat:@"%@", obj[1]];
                        if (gi.length > 0 && ii.length > 0) {
                            [groupModels setValue:ii forKey:gi];
                        }
                    }
                }
            }];
            
            if (groupModels.count > 0) {
                if ([type isEqualToString:@"rg"]) {
                    /// 文章实时下架类型
                    [self _handleArticleOfflineWithGroupModels:groupModels commandId:feedbackId];
                } else if ([type isEqualToString:@"ug"]) {
                    [self _handleArticleUpdateWithGroupModels:groupModels commandId:feedbackId];
                }
            }
            
        } else if ([type isEqualToString:@"ra"]) {
            
            NSMutableArray<NSString *> *adIds = [NSMutableArray arrayWithCapacity:1];
            NSDictionary *pDict = dict[@"p"];
            if (![pDict isKindOfClass:[NSDictionary class]]) {
                return;
            }
            
            NSString *groupIdString = pDict[@"as"];
            if (isEmptyString(groupIdString)) {
                return;
            }
            
            NSArray *removes = [groupIdString componentsSeparatedByString:@","];
            [removes enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
                NSString *adId = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (adId.length > 0) {
                    [adIds addObject:adId];
                }
            }];
            [self _handlePersistOfflineWithIds:adIds commandId:feedbackId];
        }
        
        if (feedbackId.length > 0) {
            [feedbackIds addObject:feedbackId];
        }
    }];
    
    if (feedbackIds.count > 0) {
        [self _handleFeedbackWithIds:feedbackIds];
    }
}

- (void)_handleFeedbackWithIds:(NSArray *)ids {
    NSString *feedbackIDString = [ids componentsJoinedByString:@","];
    if (feedbackIDString.length > 0) {
        NSDictionary * parameters = @{@"command_ids":feedbackIDString};
        NSString *feedback_url = @"http://i.snssdk.com/command/feedback/";

        if ([NSThread isMainThread]) {
            [[TTNetworkManager shareInstance] requestForJSONWithURL:feedback_url params:parameters method:@"GET" needCommonParams:YES callback:nil];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TTNetworkManager shareInstance] requestForJSONWithURL:feedback_url params:parameters method:@"GET" needCommonParams:YES callback:nil];
            });
        }
    }
}

- (void)_handlePersistOfflineWithIds:(NSArray<NSString *> *)array commandId:(NSString *)commandId {
    if (array.count > 0) {
        void(^ remove)(void) = ^{
            //需要先发出notification， 再删除数据库
//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[ExploreOrderedData entityName]];
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adID in %@", array];
//            fetchRequest.predicate = predicate;
//            NSArray * mixedDatas = [[SSModelManager sharedManager] entitiesWithFetch:fetchRequest error:nil];
            
            NSMutableArray *results= [NSMutableArray arrayWithCapacity:array.count];
            
            for (NSString *adID in array) {
                NSString *adIDStr = [NSString stringWithFormat:@"%@", adID];
                NSArray *objs = [ExploreOrderedData objectsWhere:@"WHERE adIDStr = ?" arguments:@[adIDStr]];
                [results addObjectsFromArray:objs];
            }
            
            [results enumerateObjectsUsingBlock:^(ExploreOrderedData * obj, NSUInteger idx, BOOL *stop) {
                ExploreOriginalData *originalData = (ExploreOriginalData *)obj.originalData;
                NSMutableDictionary * userInfo1 = [NSMutableDictionary dictionaryWithCapacity:2];
                [userInfo1 setValue:obj forKey:kExploreMixListDeleteItemKey];
                if ([originalData isKindOfClass:[Article class]]) {
                    [userInfo1 setValue:@(((Article *)originalData).uniqueID) forKey:@"uniqueID"];
                }
                obj.cellDeleted = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListItemDeleteNotification object:nil userInfo:userInfo1];
            }];
            
            for (ExploreOrderedData *obj in results) {
                [obj deleteObject];
            }
            
            ///...
            // 下架下拉刷新广告
            if (array.count > 0) {
                NSDictionary *refreshADUserInfo = @{kExploreMixListDeleteRefreshADItemsKey : array};
                [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListRefreshADItemDeleteNotification object:nil userInfo:refreshADUserInfo];
            }
            if (array.count > 0) {
                id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
                
                [[adManagerInstance class] realTimeRemoveAd:array];
            }
        };
        
        if ([NSThread isMainThread]) {
            remove();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                remove();
            });
        }

        THREAD_SAFECALL_MESSAGE(TTHTTPProcesserMessage, @selector(message_deleteAdRealTimeWithAdIds:commandId:), message_deleteAdRealTimeWithAdIds:array commandId:commandId);
    }
}

- (void)_handleArticleUpdateWithGroupModels:(NSDictionary *)groupModels commandId:(NSString *)commandId {
    THREAD_SAFECALL_MESSAGE(TTHTTPProcesserMessage, @selector(message_updateArticleRealTimeGroupModels:commandId:), message_updateArticleRealTimeGroupModels:groupModels commandId:commandId);
    [[ArticleUpdateManager sharedManager] addUpdateCommand:commandId groupModels:groupModels];
}

- (void)_handleArticleOfflineWithGroupModels:(NSDictionary *)groupModels commandId:(NSString *)commandId {
    if (groupModels.count > 0) {
        [self _notifyArticleRemoveWithGroupModels:groupModels commandId:commandId];
    }
}

- (void)_notifyArticleRemoveWithGroupModels:(NSDictionary *)groupModels commandId:(NSString *)commandId {
    if (groupModels.count == 0) {
        return;
    }
    NSArray *groupIds = groupModels.allKeys;
    if (groupIds.count == 0) {
        return;
    }
    void(^ remove)(void) = ^{
        //需要先发出notification， 再删除数据库
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[ExploreOrderedData entityName]];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"originalData.uniqueID in %@", groupIds];
//        fetchRequest.predicate = predicate;
//        NSArray * mixedDatas = [[SSModelManager sharedManager] entitiesWithFetch:fetchRequest error:nil];
        
        
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:groupIds.count];
        for (NSNumber *uniqueID in groupIds) {
            NSString *uniqueIDStr = [NSString stringWithFormat:@"%@", uniqueID];
            NSArray *objs = [ExploreOrderedData objectsWithQuery:@{@"uniqueID":uniqueIDStr}];
            [results addObjectsFromArray:objs];
        }
        
        
        [results enumerateObjectsUsingBlock:^(ExploreOrderedData * obj, NSUInteger idx, BOOL *stop) {
            ExploreOriginalData *originalData = (ExploreOriginalData *)obj.originalData;
            NSString *itemId = [groupModels valueForKey:@(obj.originalData.uniqueID).stringValue];
            if ([itemId isEqualToString:@"0"] || [itemId isEqualToString:obj.article.itemID]) {
                NSMutableDictionary * userInfo1 = [NSMutableDictionary dictionaryWithCapacity:2];
                [userInfo1 setValue:obj forKey:kExploreMixListDeleteItemKey];
                if ([originalData isKindOfClass:[Article class]]) {
                    ((Article *)originalData).articleDeleted = @(YES);
                    [userInfo1 setValue:@(((Article *)originalData).uniqueID) forKey:@"uniqueID"];
                }
                obj.cellDeleted = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListItemDeleteNotification object:nil userInfo:userInfo1];
            }
        }];
//        [[SSModelManager sharedManager] removeEntities:mixedDatas error:nil];
        
        for (ExploreOrderedData *obj in results) {
            [obj deleteObject];
        }
    };
    
    if ([NSThread isMainThread]) {
        remove();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            remove();
        });
    }
    THREAD_SAFECALL_MESSAGE(TTHTTPProcesserMessage, @selector(message_deleteArticleRealTimeGroupModels:commandId:), message_deleteArticleRealTimeGroupModels:groupModels commandId:commandId);
}

@end

@implementation SSHTTPResponseProtocolItem
@synthesize responseData = _responseData;

@end

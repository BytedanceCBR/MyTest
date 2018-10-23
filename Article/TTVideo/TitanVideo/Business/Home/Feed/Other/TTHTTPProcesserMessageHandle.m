//
//  TTHTTPProcesserMessageHandle.m
//  Article
//
//  Created by panxiang on 2017/4/7.
//
//

#import "TTHTTPProcesserMessageHandle.h"
#import "TTMessageCenter.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreMixListDefine.h"
#import "ArticleUpdateManager.h"
#import "TTAdManager.h"

@implementation TTHTTPProcesserMessageHandle
ShareImplement(TTHTTPProcesserMessageHandle);
- (void)dealloc
{
    UNREGISTER_MESSAGE(TTHTTPProcesserMessage, self);
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        REGISTER_MESSAGE(TTHTTPProcesserMessage, self);
    }
    return self;
}

- (void)message_deleteArticleRealTimeGroupModels:(NSDictionary *)groupModels commandId:(NSString *)commandId
{
    NSArray *groupIds = groupModels.allKeys;
    if (groupIds.count == 0) {
        return;
    }
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

    for (ExploreOrderedData *obj in results) {
        [obj deleteObject];
    }
}

- (void)message_updateArticleRealTimeGroupModels:(NSDictionary *)groupModels commandId:(NSString *)commandId
{
    [[ArticleUpdateManager sharedManager] addUpdateCommand:commandId groupModels:groupModels];
}

- (void)message_deleteAdRealTimeWithAdIds:(NSArray *)array commandId:(NSString *)commandId
{
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
        [TTAdManager realTimeRemoveAd:array];
    }
}
@end

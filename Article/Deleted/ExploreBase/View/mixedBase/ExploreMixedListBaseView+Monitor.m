//
//  ExploreMixedListBaseView+Monitor.m
//  Article
//
//  Created by 王霖 on 16/7/13.
//
//

#import "ExploreMixedListBaseView+Monitor.h"
#import "TTMonitorConfiguration.h"
#import "TTMonitor.h"
#import "NSObject+TTAdditions.h"

@implementation ExploreMixedListBaseView (Monitor)

- (void)exploreMixedListTimeConsumingMonitorWithContext:(NSDictionary *)context {
    
    NSString * categoryID = [[context objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListConditionListUnitIDKey];
    NSString * concernID = [[context objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListConditionListConcernIDKey];
    NSMutableDictionary * monitorDictonary = [NSMutableDictionary dictionary];
    if (isEmptyString(categoryID)) {
        [monitorDictonary setValue:concernID forKey:@"category"];
    }else {
        [monitorDictonary setValue:categoryID forKey:@"category"];
    }
    [monitorDictonary setValue:concernID forKey:@"concern_id"];
    NSUInteger isRefresh = [[context objectForKey:kExploreFetchListGetMoreKey] boolValue] ? 0 : 1;
    [monitorDictonary setValue:@(isRefresh) forKey:@"is_refresh"];
    
    NSDictionary * exploreMixedListConsumeTimeStamps = [[context objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
    //总耗时时间戳
    int64_t start = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListTriggerRequestTimeStampKey] longLongValue];
    int64_t end = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListFinishRequestTimeStampKey] longLongValue];
    int64_t totalConsume = [NSObject machTimeToSecs:end - start]*1000;
    if (totalConsume > 0) {
        [monitorDictonary setValue:@(totalConsume) forKey:@"total"];
    }
    
    //从本地数据库中获取数据的时间戳
    int64_t getLocalDataOperationBegin = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListGetLocalDataOperationBeginTimeStampKey] longLongValue];
    int64_t getLocalDataOperationEnd = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListGetLocalDataOperationEndTimeStampKey] longLongValue];
    int64_t getLocalDataOperationConsume = [NSObject machTimeToSecs:getLocalDataOperationEnd - getLocalDataOperationBegin]*1000;
    if (getLocalDataOperationConsume > 0) {
        [monitorDictonary setValue:@(getLocalDataOperationConsume) forKey:@"get_local_op"];
    }
    
    //从远端请求数据的时间戳
    int64_t getRemoteDataOperationBegin = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListGetRemoteDataOperationBeginTimeStampKey] longLongValue];
    int64_t remoteRequestBegin = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListRemoteRequestBeginTimeStampKey] longLongValue];
    int64_t getRemoteDataOperationEnd = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListGetRemoteDataOperationEndTimeStampKey] longLongValue];
    int64_t getRemoteDataOperationConsume = [NSObject machTimeToSecs:getRemoteDataOperationEnd - getRemoteDataOperationBegin]*1000;
    int64_t getRemoteDataOperationNetworkConsume = [NSObject machTimeToSecs:getRemoteDataOperationEnd - remoteRequestBegin]*1000;
    if (getRemoteDataOperationConsume > 0) {
        [monitorDictonary setValue:@(getRemoteDataOperationConsume) forKey:@"get_remote_op"];
    }
    if (getRemoteDataOperationNetworkConsume) {
        [monitorDictonary setValue:@(getRemoteDataOperationNetworkConsume) forKey:@"network"];
    }
    
    //插入预处理时间戳
    int64_t preInsertOperationBegin = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListPreInsertOperationBeginTimeStampKey] longLongValue];
    int64_t preInsertOperationEnd = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListPreInsertOperationEndTimeStampKey] longLongValue];
    int64_t preInsertOperationConsume = [NSObject machTimeToSecs:preInsertOperationEnd - preInsertOperationBegin]*1000;
    if (preInsertOperationConsume > 0) {
        [monitorDictonary setValue:@(preInsertOperationConsume) forKey:@"pre_insert_op"];
    }
    
    //插入Core Data时间戳
    int64_t insertDataOperationBegin = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListInsertDataOperationBeginTimeStampKey] longLongValue];
    int64_t insertDataOperationEnd = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListInsertDataOperationEndTimeStampKey] longLongValue];
    int64_t insertDataOperationConsume = [NSObject machTimeToSecs:insertDataOperationEnd - insertDataOperationBegin]*1000;
    if (insertDataOperationConsume > 0) {
        [monitorDictonary setValue:@(insertDataOperationConsume) forKey:@"insert_op"];
    }
    
    //保存Core Data上下文时间戳
    int64_t saveRemoteOperationBegin = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListSaveRemoteOperationBeginTimeStampKey] longLongValue];
    int64_t saveRemoteOperationEnd = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListSaveRemoteOperationEndTimeStampKey] longLongValue];
    int64_t saveRemoteOperationConsume = [NSObject machTimeToSecs:saveRemoteOperationEnd - saveRemoteOperationBegin]*1000;
    if (saveRemoteOperationConsume > 0) {
        [monitorDictonary setValue:@(saveRemoteOperationConsume) forKey:@"save_op"];
    }
    
    //额外处理的时间戳
    int64_t postSaveOperationBegin = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListPostSaveOperationBeginTimeStampKey] longLongValue];
    int64_t postSaveOperationEnd = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListPostSaveOperationEndTimeStampKey] longLongValue];
    int64_t postSaveOperationConsume = [NSObject machTimeToSecs:postSaveOperationEnd - postSaveOperationBegin]*1000;
    if (postSaveOperationConsume > 0) {
        [monitorDictonary setValue:@(postSaveOperationConsume) forKey:@"post_save_op"];
    }
    
    //ExploreFetchListManager回调的时间戳
    int64_t managerCallbackOperationBegin = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListManagerCallbackOperationBeginTimeStampKey] longLongValue];
    int64_t managerCallbackOperationEnd = [[exploreMixedListConsumeTimeStamps objectForKey:kExploreFetchListManagerCallbackOperationEndTimeStampKey] longLongValue];
    int64_t managerCallbackOperationConsume = [NSObject machTimeToSecs:managerCallbackOperationEnd - managerCallbackOperationBegin]*1000;
    if (managerCallbackOperationConsume > 0) {
        [monitorDictonary setValue:@(managerCallbackOperationConsume) forKey:@"fetch_manager_op"];
    }
    [[TTMonitor shareManager] trackData:monitorDictonary logTypeStr:@"channel_fetch"];
    [TTDebugRealMonitorManager cacheDevLogWithEventName:@"ChannelFetch" params:monitorDictonary];
}

- (void)monitorWithEvent:(NSString *)event label:(NSString *)label duration:(float)duration needAggregate:(BOOL)needAggregate {
    if (duration > 0 && !isEmptyString(event) && !isEmptyString(label)) {
        [[TTMonitor shareManager] event:event label:label duration:duration needAggregate:needAggregate];
    }
}

@end

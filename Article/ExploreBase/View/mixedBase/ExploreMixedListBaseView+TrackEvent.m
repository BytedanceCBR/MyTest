//
//  ExploreMixedListBaseView+TrackEvent.m
//  Article
//
//  Created by Chen Hong on 16/5/24.
//
//

#import "ExploreMixedListBaseView+TrackEvent.h"
#import "ExploreListHelper.h"
#import "TTNetworkMonitorTransaction.h"
#import "NetworkUtilities.h"
#import "ExploreCellBase.h"
#import "TTCategoryDefine.h"
#import "TTMonitor.h"
//#import "Bubble-Swift.h"
#import "TTCategoryStayTrackManager.h"
#import "FHEnvContext.h"

@implementation ExploreMixedListBaseView (TrackEvent)

- (void)trackEventStartLoad {
    self.startLoadDate = [NSDate date];
}

- (void)trackEventUpdateRemoteItemsCount:(NSUInteger)remoteItemsCount {
    self.remoteItemsCount = remoteItemsCount;
}

- (void)trackEventUpdateRemoteItemsCountAfterMerge:(NSUInteger)remoteItemsCountAfterMerge {
    self.remoteItemsCountAfterMerge = remoteItemsCountAfterMerge;
}


/*
针对刷新事件新增:
主要是对于统计字段的label进行区分:
推荐频道不需要加上频道名，其余需要变成label_频道名
*/
- (NSString *)modifyEventLabelForRefreshEvent:(NSString *)label{
    NSMutableString *muLabel = [NSMutableString stringWithString:label];
    //这种判断事件的只针对存在频道ID的情况下进行
    if(!isEmptyString(self.categoryID)){
        if(![self.categoryID isEqualToString:kTTMainCategoryID]){
            [muLabel appendFormat:@"_%@",self.categoryID];
        }
    }
    return [muLabel copy];
}

- (void)trackEventForLabel:(NSString *)label
{
    if (isEmptyString(label)) {
        return;
    }
    if (!isEmptyString(self.umengEventName)) {
        wrapperTrackEvent(self.umengEventName, label);
    }
    else {
        [ExploreListHelper trackEventForLabel:label listType:self.listType categoryID:self.categoryID concernID:self.concernID refer:self.refer];
    }
}

//log3.0
- (void)trackRefershEvent3ForLabel:(NSString *)label
{
    if (isEmptyString(label)) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];

//    [dict setValue:self.concernID forKey:@"concern_id"];
//    [dict setValue:@(self.refer) forKey:@"refer"];
    
    [dict setValue:self.categoryID forKey:@"category_name"];
    [dict setValue:[TTCategoryStayTrackManager shareManager].enterType forKey:@"enter_type"];
    [dict setValue:label forKey:@"refresh_type"];
    
//    [[EnvContext shared].tracer writeEvent:@"category_refresh" params:dict];
    [FHEnvContext recordEvent:dict andEventKey:@"category_refresh"];
    
//    [TTTrackerWrapper eventV3:@"category_refresh" params:dict isDoubleSending:YES];
    
}

- (void)trackLoadStatusEventWithErorr:(NSError *)error isLoadMore:(BOOL)isLoadMore
{
    if (self.listType != ExploreOrderedDataListTypeCategory) {
        return;
    }
    
    NSString *label;
    NSInteger status = 0;
    if (!error) {
        label = @"done";
    } else {
        label = @"unknown_error";
        
        if (!TTNetworkConnected()) {
            label = @"no_connections";
        }
        else if (error.code == kInvalidDataFormatErrorCode) {
            label = @"api_error";
        }
        else if (error.code == kServerUnAvailableErrorCode) {
            label = @"service_unavailable";
        }
        else if (error.code == kInvalidSeverStatusErrorCode) {
            label = @"server_error";
        } else {
            NSError *underlyingError = [error userInfo][NSUnderlyingErrorKey];
            if (underlyingError)
            {
                status = [TTNetworkMonitorTransaction statusCodeForNSUnderlyingError:underlyingError];
                if (status == 2) {
                    //ConnectTimeoutException
                    label = @"connect_timeout";
                } else if (status == 3) {
                    label = @"network_timeout";
                } else {
                    label = @"network_error";
                }
            }
        }
    }

    [self trackLoadStatusEventForLabel:label isLoadMore:isLoadMore status:status];
}

- (void)trackLoadStatusEventForLabel:(NSString *)label isLoadMore:(BOOL)isLoadMore status:(NSInteger)status {
    if (isEmptyString(label)) {
        return;
    }
    
    NSString *channelLabel = [self.categoryID isEqualToString:kTTMainCategoryID] ? @"newtab" : @"category";
    
    NSString *trackLabel = [NSString stringWithFormat:@"%@_%@_%@", channelLabel, (isLoadMore?@"load_more":@"refresh"), label];
    
    NSDictionary *extraDict = @{@"count":@(self.remoteItemsCount),
                                 @"finalCount":@(self.remoteItemsCountAfterMerge)};
    
    NSString *value = nil;
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.startLoadDate];
    
    //如果刷新成功 记一下时间
    BOOL success = [label isEqualToString:@"done"];
    if (success) {
        value = [NSString stringWithFormat:@"%.0f", timeInterval*1000];
        self.startLoadDate = nil;
    }
    //如果失败 回传status
    else if ([label isEqualToString:@"network_error"]) {
        value = @(status).stringValue;
    }
    
    wrapperTrackEventWithCustomKeys(@"load_status", trackLabel, value,nil,extraDict);
    
    //端监控
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:2];
    [events setValue:label forKey:@"label"];
    [events setValue:self.categoryID forKey:@"category"];
    [events setValue:@(timeInterval*1000) forKey:@"load_time"];
    [events setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"timestamp"];
    [[TTMonitor shareManager] trackService:@"feed_load" status:(success ? 0 : 1) extra:events];
    
    CLSLog(@"%@", trackLabel);
}

@end

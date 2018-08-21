//
//  TTVFeedListViewController+Track.m
//  Article
//
//  Created by panxiang on 2017/3/27.
//
//

#import "TTVFeedListViewController+Track.h"
#import "ExploreListHelper.h"
#import "TTNetworkMonitorTransaction.h"
#import "NetworkUtilities.h"
#import "ExploreCellBase.h"
#import "TTCategoryDefine.h"


@implementation TTVFeedListViewController (Track)

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
    [ExploreListHelper trackEventForLabel:label listType:ExploreOrderedDataListTypeCategory categoryID:self.categoryID concernID:nil refer:self.refer];
}

- (void)trackRefreshV3ForCategory:(NSString *)categoryName refreshMethod:(NSString *)methodName
{
    if (isEmptyString(categoryName)) {
        return;
    }
//    [TTTrackerWrapper eventV3:@"category_refresh"
//                       params:@{@"categoty_name" : categoryName,
//                                @"refresh_method": methodName,
//                               }
//              isDoubleSending:YES];
}


- (void)trackLoadStatusEventWithErorr:(NSError *)error isLoadMore:(BOOL)isLoadMore
{
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
    //如果刷新成功 记一下时间
    if ([label isEqualToString:@"done"]) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.startLoadDate];
        value = [NSString stringWithFormat:@"%.0f", timeInterval*1000];
        self.startLoadDate = nil;

    }
    //如果失败 回传status
    if ([label isEqualToString:@"network_error"]) {
        value = @(status).stringValue;
    }
    wrapperTrackEventWithCustomKeys(@"load_status", trackLabel, value,nil,extraDict);

}

- (void)trackRefreshV3ForCategory:(NSString *)categoryName refreshMethod:(NSString *)methodName erorr:(NSError *)error isLoadMore:(BOOL)isLoadMore
{
    NSString *label;
    NSInteger status = 0;
    if (!error) {
        label = @"done";
    } else {
        label = @"unknown_error";
        
        if (!TTNetworkConnected()) {
            label = @"no_connection";
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
    [self trackRefreshV3ForCategory:categoryName refreshMethod:methodName label:label isloadMore:isLoadMore status:status];
}

- (void)trackRefreshV3ForCategory:(NSString *)categoryName refreshMethod:(NSString *)methodName label:(NSString *)label isloadMore:(BOOL)isLoadMore status:(NSInteger)status
{
    if (isEmptyString(label)) {
        return;
    }
    
    NSString *trackLabel = [NSString stringWithFormat:@"%@_%@", (isLoadMore?@"load_more":@"refresh"), label];
    
    [TTTrackerWrapper eventV3:@"load_status"
                       params:@{@"category_name" :categoryName,
                                                      @"refresh_method":methodName,
                                                      @"status"        :trackLabel,
                                                    }
              isDoubleSending:YES];
}


@end


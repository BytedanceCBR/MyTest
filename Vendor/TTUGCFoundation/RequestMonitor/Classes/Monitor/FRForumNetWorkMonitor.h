//
//  FRForumNetWorkMonitor.h
//  Pods
//
//  Created by ranny_90 on 2017/10/19.
//

#import <Foundation/Foundation.h>
#import "TTRequestModel.h"

@class FRForumMonitorModel;

extern void ConfigureNetWorkMonitor(NSString *monitorService, id className);

typedef NS_ENUM(NSUInteger, kTTNetworkErrorDomainType) {
    kTTNetworkErrorNetWorkDomainNone = 0,//无错误
    kTTNetworkErrorNetWorkDomainType = 1,//cornet错误
    kTTNetworkErrorSeverJsonDomainType = 2,//后端数据解析错误
    kTTNetworkErrorSeverDataDomainType = 3,//接口后端业务逻辑错误
    kTTNetWorkErrorJsonModelParseType = 4, //idl接口respons解析错误
    kTTNetworkErrorOtherDomainType = 5, //其他错误
};

typedef NS_ENUM(NSUInteger, kTTNetworkMonitorStatus) {
    kTTNetworkMonitorStatusNone = -1,
    kTTNetworkMonitorStatusSucess = 1,
    kTTNetworkMonitorStatusCronetError = 1001,//cornet错误
    kTTNetworkMonitorStatusServerJsonError = 1002,//后端数据json解析错误
    kTTNetworkMonitorStatusSeverDataError = 1003,//接口后端业务逻辑错误
    kTTNetworkMonitorStatusJsonModelParseError = 1004,//接口response解析为jsonmodel错误
    kTTNetworkMonitorStatusOtherError = 1005, //其他错误

};

typedef NS_ENUM(NSUInteger, kTTNetworkMonitorPostStatus) {
    kTTNetworkMonitorPostStatusThreadDataError = 2001, //图文帖子发布接口内部数据解析错误
    kTTNetworkMonitorPostStatusRepostDataError = 2002, //图文帖子转发接口内部数据解析错误
    kTTNetworkMonitorPostStatusVideoDataError = 2003, //视频帖子发布接口内部数据解析错误
};

typedef NS_ENUM(NSUInteger, kTTNetworkMonitorThreadDtailStatus) {
    kTTNetworkMonitorThreadDtailStatusContentError = 2004, //帖子详情页content接口内部数据解析错误
    kTTNetworkMonitorThreadDtailStatusInfoError = 2005, //帖子详情页info接口内部数据解析错误
    kTTNetworkMonitorThreadDtailStatusInfoDeleteError = 2006, //帖子详情页info接口数据删除错误
    kTTNetworkMonitorThreadDtailStatusCommentError = 2007, //帖子详情页comment接口内部数据解析错误
};

typedef NS_ENUM(NSUInteger, kTTNetworkMonitorConcerHomePageStatus) {
    kTTNetworkMonitorConcerHomePageStatusHeadEmptyIDError = 2008, //关心主页Head接口内部数据解析错误
};

typedef NS_ENUM(NSUInteger, kTTNetworkMonitorFollowActionStatus) {
    kTTNetworkMonitorFollowActionStatusError = 2009, //关注接口内部数据解析错误
};

typedef NS_ENUM(NSUInteger, TTCommentRepostInfoStatus) {//评论并转发详情页info接口
    TTCommentRepostInfoStatusDeleted = 2010, //请求成功，但评论并转发帖已删除
    TTCommentRepostInfoStatusFaild = 2011, //接口内部数据请求失败
};


@interface FRForumNetWorkMonitor : NSObject

+ (instancetype)sharedInstance;

- (NSString *)getMonitorServiceForClassName:(NSString *)className;

- (FRForumMonitorModel *)monitorNetWorkErrorWithRequestModel:(TTRequestModel *)requestModel WithError:(NSError *)error;

- (NSUInteger)monitorStatusWithNetError:(NSError *)error;

@end





//
//  FRForumMonitor.h
//  Article
//
//  Created by 王霖 on 16/8/6.
//
//

#import <Foundation/Foundation.h>
#import "FRForumNetWorkMonitor.h"

typedef NS_ENUM(NSUInteger, TTPostVideoStatusMonitor) {
    TTPostVideoStatusMonitorImageUploadFailed = 97,
    TTPostVideoStatusMonitorVideoUploadFailed = 98,
    TTPostVideoStatusMonitorVideoUploadCancelled = 1,
    TTPostVideoStatusMonitorVideoUploadSdkFailed = 96,
    TTPostVideoStatusMonitorVideoUploadSdkCancelled = 2,
    TTPostVideoStatusMonitorImageUploadSDKFailed = 95,
    TTPostVideoStatusMonitorPostThreadFailed = 99,
    TTPostVideoStatusMonitorPostThreadJSONModelFailed = 100, //JSONModel解析错误
    TTPostVideoStatusMonitorPostThreadSucceed = 0,
};

typedef NS_ENUM(NSUInteger, TTSDKPostVideoStatusMonitor) {
    TTSDKPostVideoStatusMonitorFailed = 95,
    TTSDKPostVideoStatusMonitorCancelled = 1,
    TTSDKPostVideoStatusMonitorSucceed = 0,
};

extern NSString * const TTForumMonitorExtraKeyThreadID;
extern NSString * const TTForumMonitorExtraKeyConcernID;
extern NSString * const TTForumMonitorExtraKeyErrorDomain;
extern NSString * const TTForumMonitorExtraKeyErrorCode;
extern NSString * const TTForumMonitorExtraKeyNetwork;

// 监控comment、content、head、thread_list接口的请求成功/失败
typedef NS_ENUM(NSUInteger, TTForumNetworkStatus) {
    TTForumNetworkStatusCompleted = 1, //请求成功
    TTForumNetworkStatusFailed = 99, //请求失败
};

// 监控info接口的请求成功/失败
typedef NS_ENUM(NSUInteger, TTForumGetInfoStatus) {
    TTForumGetInfoStatusSucceed = 1,  //请求成功，且有帖子内容
    TTForumGetInfoStatusDeleted = 98, //请求成功，但帖子内容已被删除
    TTForumGetInfoStatusFailed = 99,  //请求失败
};

typedef NS_ENUM(NSUInteger, TTPostThreadStatus) {
    TTPostThreadStatusImageUploadFailed = 97, //图片上传失败
    TTPostThreadstatusPostThreadFailed = 98, //图片上传成功，但发帖失败
    TTPostThreadstatusPostThreadJSONModelFailed = 100, //JSONModel解析错误
    TTPostThreadStatusPostThreadSucceed = 1, //发帖成功
};

typedef NS_ENUM(NSUInteger, TTShareToRepostInfoStatus) {//站外分享接口
    TTShareToRepostInfoStatusSucceed = 1,//请求成功
    TTShareToRepostInfoStatusFailed = 99, //请求失败
};

typedef NS_ENUM(NSUInteger, TTThreadDetailPreloadStatus) {
    TTThreadDetailPreloadStatusImmediately = 1, //content和thread都有，立即渲染
    TTThreadDetailPreloadStatusInfoResponse = 2,//info回来后渲染
    TTThreadDetailPreloadStatusContentResponse = 3,//content回来后渲染
    TTThreadDetailPreloadStatusInfoContentResponse = 4, //info和content都回来后渲染
    //异常状态
    TTThreadDetailPreloadStatusThreadNotLoadedContent = 99,//由于content原因未加载
    TTThreadDetailPreloadStatusThreadNotLoadedInfo = 98, //由于info原因未加载
    TTThreadDetailPreloadStatusThreadNotLoadedInfoContent = 97, //info和content都失败的未加载
    TTThreadDetailPreloadStatusThreadDeleted = 96, //删除的情况de 预加载埋点只包括帖子没渲染就删了的情况
    TTThreadDetailPreloadStatusLoadWebviewButNotDomReady = 80,  //加载了webview，但是没捕捉到domready事件。
    //没有埋到的状态
    TTThreadDetailPreloadStatusUndetermind = 50, //埋点不严密才会进此状态
    
};

#ifdef DEBUG
#define UGCLog(format, ...) \
NSString *data = [[NSString stringWithFormat:format, __VA_ARGS__] stringByReplacingOccurrencesOfString:@"\n" withString:@""]; \
NSLog((@"✍💚%d %s %@" ), __LINE__,__PRETTY_FUNCTION__, data);
#else
#define UGCLog(format, ...) [FRForumMonitor log:[NSString stringWithFormat:format, __VA_ARGS__]];
#endif

@interface FRForumMonitor : NSObject

+ (void)log:(NSString *)event; //debugReal
#pragma mark - 帖子详情页

+ (void)trackThreadCommentError:(NSError *)error extra:(NSDictionary *)extra;

#pragma mark - commentRepost详情页

+ (void)trackCommentRepostInfoStatus:(NSInteger)status extra:(NSDictionary *)extra;

#pragma mark - 关心主页

+ (void)trackConcernHeadStatus:(NSInteger)status extra:(NSDictionary *)extra;


#pragma mark - 发图文帖子

+ (void)trackPostThreadStatus:(TTPostThreadStatus)status
                        extra:(NSDictionary *)extra
                        retry:(BOOL)retry;

#pragma mark - 发视频帖子
/**
 *  视频上传、发帖接口端监控
 *  @param status 视频上传状态端监控
 *  @param extra 端监控数据
 *  @param retry 是否时重试
 */

+ (void)ugcVideoSDKPostMonitorUploadVideoPerformanceWithStatus:(TTSDKPostVideoStatusMonitor)status extra:(NSDictionary *)extra;

+ (void)ugcVideoSDKPostThreadMonitorUploadVideoPerformanceWithStatus:(TTPostVideoStatusMonitor)status
                                                               extra:(NSDictionary *)extra
                                                               retry:(BOOL)retry
                                                        isShortVideo:(BOOL)isShortVideo;

#pragma mark - 帖子预载监控
+ (void)trackThreadDetailPreloadStatus:(TTThreadDetailPreloadStatus)status
                                 extra:(NSDictionary *)extra;

#pragma mark - gif下载统计
/**
 * gif下载统计
 */
+ (void)trackGifDownloadSucceed:(BOOL)succeed index:(NSUInteger)index costTimeInterval:(NSTimeInterval)costTimeInterval;

#pragma mark - 旧逻辑


/**
 *  发送帖子详情页content和info接口端监控
 *
 *  @param data 端监控数据
 */
+ (void)threadDetailMonitorFetchDataPerformanceWithData:(NSDictionary *)data;

/**
 *  发送帖子详情页评论接口端监控
 *
 *  @param data 端监控数据
 */
+ (void)threadDetailCommentMonitorFetchDataPerformanceWithData:(NSDictionary *)data;

/**
 *  发送关心主页头部接口端监控
 *
 *  @param data 端监控数据
 */
+ (void)concernHomeHeadMonitorFetchDataPerformanceWithData:(NSDictionary *)data;

/**
 *  发送关心主页帖子tab接口端监控
 *
 *  @param data 端监控数据
 */
+ (void)concernThreadTabMonitorFetchDataPerformanceWithData:(NSDictionary *)data;



@end

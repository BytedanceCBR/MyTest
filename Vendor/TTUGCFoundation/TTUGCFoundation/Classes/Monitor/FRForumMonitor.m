//
//  FRForumMonitor.m
//  Article
//
//  Created by 王霖 on 16/8/6.
//
//

#import "FRForumMonitor.h"
#import "TTMonitorConfiguration.h"
#import "TTDebugRealMonitorManager.h"
#import "FRApiModel.h"
#import "FRForumNetWorkMonitor.h"
#import "TTKitchenHeader.h"

NSString * const TTForumMonitorExtraKeyThreadID = @"thread_id";
NSString * const TTForumMonitorExtraKeyConcernID = @"concern_id";
NSString * const TTForumMonitorExtraKeyErrorDomain = @"error_domain";
NSString * const TTForumMonitorExtraKeyErrorCode = @"error_code";
NSString * const TTForumMonitorExtraKeyNetwork = @"network";

@implementation FRForumMonitor
+ (void)load {
    ConfigureNetWorkMonitor(@"ugc_post_thread_thread_process", [FRUgcPublishPostV4CommitRequestModel class]);
    ConfigureNetWorkMonitor(@"ugc_thread_repost",[FRUgcPublishRepostV6CommitRequestModel class]);
    ConfigureNetWorkMonitor(@"ugc_video_post_thread_process", [FRUgcPublishVideoV3CommitRequestModel class]);
    ConfigureNetWorkMonitor(@"ugc_detail_get_content", [FRUgcThreadDetailV2ContentRequestModel class]);
    ConfigureNetWorkMonitor(@"ugc_concern_get_list", [FRUgcConcernThreadV3ListRequestModel class]);
    ConfigureNetWorkMonitor(@"ugc_share_to_repost", [FRUgcPublishShareV3NotifyRequestModel class]);
    ConfigureNetWorkMonitor(@"ugc_concern_get_head", [FRConcernV1HomeHeadRequestModel class]);
    ConfigureNetWorkMonitor(@"ugc_comment_author_delete", [FRUgcCommentAuthorActionV2DeleteRequestModel class]);
    ConfigureNetWorkMonitor(@"ugc_footer_repost_list", [FRUgcRepostV1ListRequestModel class]);
    ConfigureNetWorkMonitor(@"ugc_footer_digg_list", [FRUgcDiggV1ListRequestModel class]);
}

+ (void)log:(NSString *)event{
    if (event) {
        [TTDebugRealMonitorManager cacheDevLogWithEventName:[NSString stringWithFormat:@"ugc %@", event] params:nil];
    }
}

#pragma mark - 帖子详情页

+ (void)trackThreadCommentError:(NSError *)error extra:(NSDictionary *)extra{
    
    NSInteger status = [[FRForumNetWorkMonitor sharedInstance] monitorStatusWithNetError:error];
    [[TTMonitor shareManager] trackService:@"ugc_detail_get_comment" status:status extra:extra];
}

#pragma mark - commentRepost详情页

+ (void)trackCommentRepostInfoStatus:(NSInteger)status extra:(NSDictionary *)extra{
    [[TTMonitor shareManager] trackService:@"ugc_comment_repost" status:status extra:extra];
}

#pragma mark - 关心主页

+ (void)trackConcernHeadStatus:(NSInteger)status extra:(NSDictionary *)extra {
    [[TTMonitor shareManager] trackService:@"ugc_concern_get_head" status:status extra:extra];
}


#pragma mark - 发图文帖子

+ (void)trackPostThreadStatus:(TTPostThreadStatus)status
                        extra:(NSDictionary *)extra
                        retry:(BOOL)retry{
    [[TTMonitor shareManager] trackService:retry? @"ugc_thread_post_retry": @"ugc_thread_post" status:status extra:extra];
}

#pragma mark - 发视频帖子

+ (void)ugcVideoSDKPostMonitorUploadVideoPerformanceWithStatus:(TTSDKPostVideoStatusMonitor)status extra:(NSDictionary *)extra {
    
    //extra 字段的解释见 https://wiki.bytedance.net/pages/viewpage.action?pageId=86368536
    
    [[TTMonitor shareManager] trackService:@"ugc_video_post_video_sdk" status:status extra:extra];
}

+ (void)ugcVideoSDKPostThreadMonitorUploadVideoPerformanceWithStatus:(TTPostVideoStatusMonitor)status
                                                               extra:(NSDictionary *)extra
                                                               retry:(BOOL)retry
                                                        isShortVideo:(BOOL)isShortVideo {
    //    {
    //        "cover_networks" = 183; //封面图上传耗时
    //        "erro_no" = 0; //错误码
    //        "is_resend" = 0; //是否是重试
    //        network = 818; //发文接口耗时
    //        total = 537650; // 总耗时
    //        "video_networks" = 536635; //上传视频耗时
    //        若status = TTPostVideoStatusMonitorVideoUploadSdkFailed／TTPostVideoStatusMonitorVideoUploadSdkCancelled，其他字段的解释见
    //         https://wiki.bytedance.net/pages/viewpage.action?pageId=86368536
    //    }
    [[TTMonitor shareManager] trackService:retry? @"ugc_video_post_thread_retry_sdk": @"ugc_video_post_thread_sdk" status:status extra:extra];
    if (isShortVideo) {
        [[TTMonitor shareManager] trackService:retry? @"ugc_shortvideo_post_retry": @"ugc_shortvideo_post" status:status extra:extra];
    }
}

#pragma mark - gif下载统计
+ (void)trackGifDownloadSucceed:(BOOL)succeed index:(NSUInteger)index costTimeInterval:(NSTimeInterval)costTimeInterval
{
    [[TTMonitor shareManager] trackService:@"ugc_gif_download" status:succeed?0:1 extra:@{@"costTime":@(costTimeInterval)}];
}

#pragma mark - 帖子详情页预载统计
+ (void)trackThreadDetailPreloadStatus:(TTThreadDetailPreloadStatus)status
                                 extra:(NSDictionary *)extra
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:extra];
    [mutableDict setObject:@(status) forKey:@"status"];
    [[TTMonitor shareManager] trackService:@"ugc_thread_detail_preload" value:mutableDict extra:nil];
}
#pragma mark - 旧逻辑

+ (void)threadDetailMonitorFetchDataPerformanceWithData:(NSDictionary *)data {
    [[TTMonitor shareManager] trackData:data logTypeStr:@"thread_detail"];
}

+ (void)threadDetailCommentMonitorFetchDataPerformanceWithData:(NSDictionary *)data {
    [[TTMonitor shareManager] trackData:data logTypeStr:@"thread_detail_comment"];
}

+ (void)concernHomeHeadMonitorFetchDataPerformanceWithData:(NSDictionary *)data {
    [[TTMonitor shareManager] trackData:data logTypeStr:@"concern_home_head"];
}

+ (void)concernThreadTabMonitorFetchDataPerformanceWithData:(NSDictionary *)data {
    [[TTMonitor shareManager] trackData:data logTypeStr:@"concern_thread_tab"];
}



@end

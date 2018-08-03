//
//  TTVideoUploadOperation.h
//  Article
//
//  Created by 徐霜晴 on 16/10/12.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTVideoUploadStatusMonitor) {
    TTVideoUploadStatusMonitorGetUploadIDFailed = 99, //获取uploadID或者获取上传进度失败
    TTVideoUploadStatusMonitorUploadFailed = 98, //获取uploadID成功，但上传失败
    TTVideoUploadStatusMonitorGetLocalVideoFailed = 97,//读取本地视频失败
    TTVideoUploadStatusMonitorUploadCancelled = 1, //用户取消了本次上传
    TTVideoUploadStatusMonitorUploadCompleted = 0, //上传完成
};


extern NSString * const TTVideoUploadErrorDomain;
typedef NS_ENUM(NSInteger, TTVideoUploadErrorCode) {
    TTVideoUploadErrorCodeUserCancelled = -999,
    TTVideoUploadErrorCodeNoUploadID = -30000,
};
typedef void(^TTVideoUploadProgressBlock)(long long uploadedSizeOfVideo, long long totalSizeOfVideo);
typedef void(^TTVideoUploadCompleteBlock)(BOOL completed, NSString *videoID, NSError *error);
typedef void(^TTVideoUploadUpdateVideoIdBlock)(NSString *videoID);

@interface TTVideoUploadOperation : NSOperation

@property (nonatomic, assign, readonly) long long totalSizeOfVideo;
@property (nonatomic, assign, readonly) long long uploadedSizeOfVideo;
@property (nonatomic, copy, readonly) NSString *taskID;

- (instancetype)initWithVideoPath:(NSString *)path
                           taskID:(NSString *)taskID
                         uploadId:(NSString *)uploadId
                    updateVideoId:(TTVideoUploadUpdateVideoIdBlock)updateVideoId
                         progress:(TTVideoUploadProgressBlock)progress
                        completed:(TTVideoUploadCompleteBlock)completed;

//有的业务想要第一步走自己的接口
//其他请求参数和返回都一样
- (void)userOtherUploadApi:(NSString *)uploadApiStr;

@end

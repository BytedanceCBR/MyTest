//
//  TTRecordedVideo.h
//  Article
//
//  Created by xuzichao on 2017/6/13.
//
//

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, TTVideoSourceType) {
    //录制视频
    TTVideoSourceTypeFromCamera = 1,
    //本地上传
    TTVideoSourceTypeFromAlbum = 2,
};

typedef NS_ENUM(NSInteger, TTVideoCoverSourceType) {
    //用户选择了封面
    TTVideoCoverSourceTypeUserSelection = 0,
    //视频第一帧
    TTVideoCoverSourceTypeDefault = 1,
};

typedef NS_ENUM(NSUInteger, TTPostVideoSource) {
    TTPostVideoSourceOther = -1,
    TTPostVideoSourceUGCVideoFromCamera = 1,
    TTPostVideoSourceUGCVideoFromAlbum = 2,
    TTPostVideoSourceShortVideoFromCamera = 5,
    TTPostVideoSourceShortVideoFromAlbum = 6,
    TTPostVideoSourceShortVideoFromUGCVideo = 7, //UGC视频转小视频
};

#define TTRecordedVideoPickedNotification @"TTRecordedVideoPickedNotification"

@interface TTRecordedVideo : NSObject

/**
 用户输入的视频标题
 */
@property (nonatomic, copy) NSString * _Nullable title;

@property (nonatomic, copy) NSString * _Nullable title_rich_span;

@property (nonatomic, copy) NSString * _Nullable mentionUser;

@property (nonatomic, copy) NSString * _Nullable mentionConcern;

/**
 视频来源：拍摄 or 相册
 */
@property (nonatomic, assign) TTVideoSourceType videoSource;
@property (nonatomic, assign) TTPostVideoSource postVideoSource;

/**
 压缩完的视频文件的本地URL
 */
@property (nonatomic, strong) NSURL * _Nonnull videoURL;

/**
 压缩完的视频文件的asset
 */
@property (nonatomic, strong) AVAsset * _Nonnull videoAsset;

/**
 视频封面来源：用户选择 or 自动
 */
@property (nonatomic, assign) TTVideoCoverSourceType videoCoverSource;

/**
 视频封面
 */
@property (nonatomic, strong) UIImage * _Nonnull coverImage;

/**
 视频封面时间戳
 */
@property (nonatomic, assign) NSTimeInterval coverImageTimestamp;

@property (nonatomic, copy) NSDictionary *extraTrackForPublish;

@property (nonatomic, copy) NSString *musicID;

@end


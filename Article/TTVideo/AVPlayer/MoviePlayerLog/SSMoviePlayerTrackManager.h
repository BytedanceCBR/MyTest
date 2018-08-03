//
//  SSMoviePlayerTrackManager.h
//  Article
//
//  Created by Zhang Leonardo on 15-3-19.
//
//

#import <Foundation/Foundation.h>
#import "SSMoviePlayerLogManager.h"

typedef NS_ENUM(NSInteger, SSVideoType) {
    SSVideoTypeVideo = 1 << 16,
    SSVideoTypeLiveVideo = 2 << 16,
    SSVideoTypeAdVideo = 3 << 16,
    SSVideoTypeLiveReplay = 4 << 16,
};

@protocol SSMoviePlayerTrackManagerDelegate;

@interface SSMoviePlayerTrackManager : NSObject

//业务层log接收者
@property(nonatomic,weak)id<SSMovieLogReceiver> logReceiver;

//依赖外部提供的一些统计参数，如当前网络，运营商等
@property(nonatomic,weak)id<SSMoviePlayerTrackManagerDelegate> trackDelegate;

//用户点击了播放按钮或重试播放按钮
- (void)userClickPlayButtonForID:(NSString *)videoID fetchURL:(NSString *)fetchURL isClearALl:(BOOL)clearAll;

//加载超时重试播放
- (void)autoRetryPlay;

//获取到了播放的地址，开始播放
- (void)fetchedVideoStartPlay;

// 用户拖拽了进度条
- (void)seekToTime:(NSTimeInterval)afterSeekTime cacheDuration:(NSTimeInterval)cacheDuration;

//播放过了一帧
- (void)showedOnceFrame;

//缓冲一次
- (void)movieStalled;

//缓冲到达视频最后
- (void)movieBufferDidReachEnd;

//因为错误播放结束，记录错误信息和当前播放时长
- (void)movieFinishError:(NSError *)error currentPlaybackTime:(NSTimeInterval)currentPlaybackTime;

//记录网络错误，播放videoUrl超时
- (void)setError:(NSString *)errorStr;

//记录视频cdn地址解析错误
- (void)setDNSErrorDict:(NSDictionary *)dnsErrorDict;

//请求api获取url失败
- (void)setApiErrorDict:(NSDictionary *)errorDict;

//跳转后的URL
- (void)setMovieVideoURL:(NSString *)uri serverIP:(NSString *)si;

//跳转前的URL
- (void)setMovieOriginVideoURL:(NSString *)uri;

//视频时长
- (void)setMovieDuration:(NSInteger)duration;

//视频大小
- (void)setMovieSize:(NSInteger)size;

//切换前视频清晰度
- (void)setMovieLastDefinition:(NSString *)definition;

//视频清晰度
- (void)setMovieDefinition:(NSString *)definition;

//视频预加载大小
- (void)setMoviePreloadSize:(NSInteger)size;

//视频预加载最小步长
- (void)setMoviePreloadMinStep:(NSInteger)step;

//视频预加载最大步长
- (void)setMoviePreloadMaxStep:(NSInteger)step;

//视频类型
- (void)setVideoType:(SSVideoType)type;

//视频播放了多少bytes
- (void)setVideoPlaySize:(NSInteger)size;

//视频加载了多少bytes
- (void)setVideoDownloadSize:(NSInteger)size;

//播放器播放失败 error
- (void)setPlayError:(NSError *)error;

//结束时候调用
- (void)sendEndTrack;

//结束视频，只记录时间，不立即发送
- (void)endTrack;

//清空
- (void)clearAll;

//发送
- (void)flushTrack;

@end


@protocol SSMoviePlayerTrackManagerDelegate <NSObject>

//当前网络
- (NSString *)connectMethodName;
//当前运营商
- (NSString *)carrierMNC;

@end

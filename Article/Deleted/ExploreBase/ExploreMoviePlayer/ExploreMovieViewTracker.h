//
//  ExploreMovieViewTracker.h
//  Article
//
//  Created by Chen Hong on 15/9/21.
//
//

#import "TTGroupModel.h"
#import "ExploreVideoSP.h"
#import "TTMoviePlayerDefine.h"

@class SSMoviePlayerController;
@interface ExploreMovieViewTracker : NSObject

@property(nonatomic, assign)BOOL wasInDetail;
@property(nonatomic, assign)BOOL hasEnterDetail;//这个字段不表示当前在详情页，而是表示进过详情页，自动播放埋点需要判断是不是在直接在列表上自动播放，还是从详情页返回列表后续播
@property(nonatomic, assign)BOOL isReplaying;
@property(nonatomic, assign)ExploreMovieViewType type;
@property(nonatomic, assign)ExploreMovieViewSubType subType;//上一个source ,列表的source
@property(nonatomic, strong)NSString *aID;
@property(nonatomic, assign)CGFloat effectivePlayTime;
@property(nonatomic, strong)NSArray *clickTrackURLs;
@property(nonatomic, copy)NSString *clickTrackUrl;
@property(nonatomic, strong)NSArray *playTrackUrls;
@property(nonatomic, strong)NSArray *activePlayTrackUrls;
@property(nonatomic, strong)NSArray *effectivePlayTrackUrls;
@property(nonatomic, strong)NSArray *playOverTrackUrls;
@property(nonatomic, strong)NSString *videoThirdMonitorUrl;
@property(nonatomic, weak) UIView* movieView;
@property(nonatomic, assign)long timerId;
@property(nonatomic, assign)NSInteger trackSDK;
@property(nonatomic, weak)  UIView* trackSDKView;
@property(nonatomic, strong)NSString *cID;
@property(nonatomic, strong)NSString *logExtra;
@property(nonatomic, copy)NSString *gdLabel;
@property(nonatomic, strong)TTGroupModel *gModel;
@property(nonatomic, strong)SSMoviePlayerController *moviePlayerController;
@property(nonatomic, assign)BOOL isPlaybackEnded;
@property(nonatomic, assign)BOOL enableRotate;
@property(nonatomic, assign)BOOL hasSendPlayEndEvent;//浮层发送video_over事件
@property(nonatomic, assign)NSTimeInterval preResolutionWatchingDuration;//切换清晰度之前观看的时长 note:这个单位是毫秒

@property (nonatomic, assign) TTVideoPlayType videoPlayType;
/** 直播专用状态 */
@property (nonatomic, strong) NSNumber *liveStatus;

//多清晰度的统计
@property(nonatomic, assign)BOOL enableMultiResolutionTrack;
@property(nonatomic, assign)ExploreVideoDefinitionType definitionType;
//包含统计的全部参数字典
@property(nonatomic, strong) NSDictionary *ssTrackerDic;
@property(nonatomic, assign)BOOL hasPlayEndMainVideo;


/**
 *  为了过滤自动播放统计对推荐的影响，只有没有用户主动操作过的自动播放，isAutoPlaying 才为 YES，不发正常的统计。（只做统计用）
 */
@property(nonatomic, assign)BOOL isAutoPlaying;
@property(nonatomic, copy)NSString *authorId;


- (void)resetStatus;//播放结束后,下一个视频开始
- (void)sendPlayTrack;
- (void)sendEndTrack;
- (void)sendPauseTrack;
- (void)sendContinueTrack;
- (void)sendEnterFullScreenTrack;
- (void)sendExistFullScreenTrack:(BOOL)sendByFullScreenButton;
- (void)sendMoveProgressBarTrackFromTime:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime;
- (void)sendNetAlertWithLabel:(NSString *)label;
- (void)sendControlViewClickTrack;
- (void)sendVideoPlayTrack;
- (void)sendVideoThirdMonitorUrl;
- (void)sendVideoFinishUITrackWithEvent:(NSString *)event prefix:(NSString *)prefix;
//视频首帧时间 = (PlayUrl - GetUrl) + (OneFrame - PlayUrl)
- (void)sendGetUrlTrack;//获得了视频URL
- (void)sendPlayUrlTrack;//开始播放url
- (void)sendPlayOneFrameTrack;//开发播放第一帧,包括重播的第一帧

- (NSTimeInterval)watchedDuration;
- (NSInteger)playPercent;
- (void)addExtraValueFromDic:(NSDictionary *)dic;
- (void)addExtraValue:(id)value forKey:(NSString *)key;
- (void)removeExtraValueForKey:(NSString *)key;

// 记住播放进度后，再次续播
- (void)sendContinuePlayTrack:(NSString *)stopEvent;
- (NSString *)dataTrackLabel;

- (void)sendPrePlayBtnClickTrack;

//解决视频广告autoplay下点进视频详情页未发detail_play问题
- (void)sendPlayTrackInDetailByAutoPlay;

//mzSDK track
- (void)mzTrackVideoUrls:(NSArray*)trackUrls adView:(UIView*)adView;
- (void)mzStopTrack;

@end

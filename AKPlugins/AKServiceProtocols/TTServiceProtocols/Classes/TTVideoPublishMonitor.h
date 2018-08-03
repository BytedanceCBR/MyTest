//
//  TTVideoPublishMonitorP.h
//  Article
//
//  Created by xushuangqing on 06/02/2018.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTVideoPublishState) {
    TTVideoPublishStateNetworkCheckFailed = 101,
    TTVideoPublishState4GNetworkFailed = 102,
    TTVideoPublishStateLoginFailed = 103,
    TTVideoPublishStateRealnameFailed = 104,
    TTVideoPublishStateCoverFailed = 105,
    TTVideoPublishStateTitleFailed = 106,
    TTVideoPublishStatePublished = 0,
};

typedef NS_ENUM(NSUInteger, TTVideoPublishAction) {
    TTVideoPublishActionStart = 0, //用户点击“发布按钮” （对标post_topic_video）
    TTVideoPublishActionStartUpload = 1, //草稿生成，准备上传
    TTVideoPublishActionCancelled = 2, //用户在上传过程中删除了视频
    TTVideoPublishActionFailDelete = 3, //用户在上传失败后删除了视频（对标video_publish_fail_delete）
    TTVideoPublishActionDone = 4, //视频上传成功（对标video_publish_done）
};

typedef NS_ENUM(NSUInteger, TTVideoPublishTrack) {
    TTVideoPublishTrackPublishButtonClicked = 0, //点击发布
    
    TTVideoPublishTrackTitleLengthFail = 101, //本地检查视频标题未通过（超出最大字数限制）[iOS无此状况，超出最大字数时发布按钮不可点击]
    TTVideoPublishTrackLoginNeeded = 102, //需要登录:弹出登录弹窗
    TTVideoPublishTrackLoginFailed = 103, //需要登录:放弃登录
    TTVideoPublishTrackNoNetwork = 104, //网络不可用
    TTVideoPublishTrackRealnameNeeded = 105, //需要绑定手机号：向服务端check失败
    TTVideoPublishTrackRealnameFailed = 106, //需要绑定手机号：用户放弃绑定[数据可能不准]
    TTVideoPublishTrackRealnameBinded = 107, //需要绑定手机号：用户成功绑定
    TTVideoPublishTrackTitleCheckNotPass = 108, //标题检测：检测请求失败（包括网络失败、强行不通过和标题党）
    TTVideoPublishTrackTitleCheckFailed = 109, //标题检测：检测后放弃发送（包括网络失败、强行不通过和标题党放弃发送）
    TTVideoPublishTrackGetCoverFailed = 110, //获取封面失败
    TTVideoPublishTrack4GNetworkTipNeeded = 111, //4G网络提示（上传前）：弹窗显示
    TTVideoPublishTrack4GNetworkTipFailed = 112, //4G网络提示（上传前）放弃发送
    TTVideoPublishTrackVideoIsWenda = 113, //视频的输出为问答
    
    TTVideoPublishTrackPublishStart = 114, //执行上传Task
    
    TTVideoPublishTrack4GNetworkPaused = 115, //4G网络提示（上传中）：弹窗显示
    TTVideoPublishTrack4GNetworkCancelled = 116, //4G网络提示（上传中）：放弃发送【iOS无此状况，弹窗提示时已经放弃发送】
    TTVideoPublishTrackUploadFailed = 117, //上传失败【包括取消、删除和失败】
    TTVideoPublishTrackCoverUploadFailed = 118, //封面补传失败
    TTVideoPublishTrackPublishFailed = 119, //发文失败
    TTVideoPublishTrackUploadDeleted = 120, //删除视频：上传过程中删除
    
    TTVideoPublishTrackPublishDone = 1, //视频上传成功
    
    TTVideoPublishTrackFailDelete = 121, //删除视频：上传失败后删除
    TTVideoPublishTrackFailRetry = 122, //重试
};


typedef NS_ENUM(NSUInteger, TTVideoPublishResult) {
    TTVideoPublishResultNoNeed = 0,
    TTVideoPublishResultPass = 1,
    TTVideoPublishResultFail = -1,
};

@protocol TTVideoPublishMonitor <NSObject>

- (void)trackVideoAction:(TTVideoPublishAction)action extra:(NSDictionary *)extra;

//type:TTPostVideoSource
//1:拍摄的UGC视频，2:录制的UGC视频，5:拍摄的小视频，6:录制的小视频，7:UGC视频转的小视频
- (void)trackVideoWithType:(NSInteger)type state:(TTVideoPublishTrack)state extra:(NSDictionary *)extra;
- (void)recordVideoPublishState:(TTVideoPublishState)state extraTrack:(NSDictionary *)extra;

- (void)recordVideoPublish4GNetworkState:(TTVideoPublishResult)results;
- (void)recordVideoPublishLoginState:(TTVideoPublishResult)results;
- (void)recordVideoPublishRealnameState:(TTVideoPublishResult)results;
- (void)recordVideoPublishTitleState:(TTVideoPublishResult)results;

@end

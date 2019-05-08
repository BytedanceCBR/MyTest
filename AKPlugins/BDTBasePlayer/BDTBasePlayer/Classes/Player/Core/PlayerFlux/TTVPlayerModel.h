//
//  TTVPlayerModel.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerState.h"
#import "TTVPlayerTipCreator.h"

@protocol TTVPlayerControlBottomView;
@protocol TTVPlayerViewControlView;
@protocol TTVPlayerContext;

@interface TTVPlayerModel : NSObject

//获取视频url时参数
@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, copy) NSString *groupID;
@property(nonatomic, assign) NSInteger aggrType;
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, copy) NSString *adID;
@property (nonatomic, copy) NSString *logExtra;
@property (nonatomic, copy) NSDictionary *logPb;
@property (nonatomic, assign) TTVPlayerSP sp;

#pragma mark 视频4中播放方式
/**
 视频唯一ID 通过videoID 获取视频的url
 */
@property (nonatomic, copy) NSString *videoID;
/**
 使用本地url,播放本地视频
 */
@property (nonatomic, copy) NSString *localURL;

/**
 直接通过url请求
 */
@property (nonatomic, copy) NSString *urlString;

/**
 接口直接下发播放地址相关信息,videoPlayInfo中会有好接个视频的url,播放的时候,依次旋转一个能播放的url.
 */
@property(nonatomic, copy)NSDictionary *videoPlayInfo;

/**
 统计使用
 */
@property(nonatomic, copy)NSString *trackLabel;
@property(nonatomic, copy)NSString *enterFrom;
@property(nonatomic, copy)NSString *fromGid;//相关视频关联点击统计
@property(nonatomic, copy)NSString *categoryName;
@property(nonatomic, copy)NSString *authorId;

/**
 feed下发的视频地址,过期时间
 */
@property(nonatomic, assign) NSTimeInterval expirationTime;

/**
 当静音的时候显示静音提示图案 ,默认NO
 */
@property (nonatomic, assign) BOOL showMutedView;

/**
 自研播放器 默认 YES
 */
@property (nonatomic, assign) BOOL useOwnPlayer;

/**
 缓存播放进度  默认 YES
 */
@property (nonatomic, assign) BOOL enableCache;


/**
 是否显示清晰度按钮 默认YES
 */
@property(nonatomic, assign)BOOL enableResolution;

/**
 第一次播放,用户没有选择的情况下,wifi下默认的清晰度
 */
@property(nonatomic, assign)TTVPlayerResolutionType defaultResolutionType;


/**
 禁用视频播放完成界面
 */
@property (nonatomic, assign) BOOL disableFinishUIShow;

/**
 是否是自动播放
 */
@property(nonatomic, assign) BOOL isAutoPlaying;

/**
 初始化的时候静音播放
 */
@property(nonatomic, assign) BOOL mutedWhenStart;

/**
 是否是循环播放,这个字段不会控制播放器行为，只是用来标示和埋点
 */
@property(nonatomic, assign) BOOL isLoopPlay;

/**
 主端分享一期 默认为空
 */
@property(nonatomic, assign) NSInteger playerShowShareMore;

/**
 是否是视频业务创建的播放器 默认为空
 */
@property(nonatomic, assign) BOOL isVideoBusiness;

/**
 专题 id
 */
@property(nonatomic, copy) NSString *videoSubjectID;


/**
 是否打开通用的埋点 ,默认关闭
 */
@property(nonatomic, assign) BOOL enableCommonTracker;

/**
 播放结束自动移出
 */
@property(nonatomic, assign) BOOL removeWhenFinished;

/**
 禁用TrafficAlert
 */
@property(nonatomic, assign)BOOL enableChangeResolutionAlert;

/**
 禁用controlView,始终不显示controlView,播放器控制界面
 */
@property(nonatomic, assign)BOOL disableControlView;

/**
 所有埋点都加的 extra
 禁用 audioSession setActive
 */
@property (nonatomic, strong) NSDictionary *commonExtra;
@property(nonatomic, assign)BOOL disableSessionDeactive;

/**
 是否是广告业务,排除号外广告
 */
@property(nonatomic, assign) BOOL isAdBusiness;
@end

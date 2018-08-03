//
//  TTLiveTopBannerInfoModel.h
//  TTLive
//
//  Created by xuzichao on 16/3/11.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTLiveType) {
    TTLiveTypeUnknown = 0,
    TTLiveTypeStar    = 1,
    TTLiveTypeMatch   = 2,
    TTLiveTypeVideo   = 3,
    TTLiveTypeSimple  = 4   // 简单的通用样式
};

typedef NS_ENUM(NSUInteger, TTLiveStatus) {
    TTLiveStatusUnknown = 0,
    TTLiveStatusPre     = 1,
    TTLiveStatusPlaying = 2,
    TTLiveStatusOver    = 3
};

// 普通样式
@interface TTLiveSimpleInfoModel : NSObject

@property (nonatomic, copy)      NSString *title;
@property (nonatomic, strong)    NSDictionary *covers;

@end

//明星
@interface TTLiveStarInfoModel : NSObject

@property (nonatomic, strong)    NSDictionary *icon;
@property (nonatomic, copy)      NSString *title;
@property (nonatomic, copy)      NSString *name;
@property (nonatomic, strong)    NSDictionary *covers;
@property (nonatomic, strong)    NSNumber *starId;
@property (nonatomic, copy)      NSString *openURL;

@end

///...
// 赛事直播H5视频源详情
@interface TTLiveMatchVideoH5SourceDetail : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *openURL;
@end

// 赛事直播H5视频源
typedef NS_ENUM(NSUInteger, TTLiveMatchVideoH5SourceType) {
    TTLiveMatchVideoH5SourceTypeUnknown     = 0,
    TTLiveMatchVideoH5SourceTypeLive        = 1,
    TTLiveMatchVideoH5SourceTypeCollection  = 2,
    TTLiveMatchVideoH5SourceTypePlayback    = 3
};
@interface TTLiveMatchVideoH5SourceInfo : NSObject
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, strong) NSArray<TTLiveMatchVideoH5SourceDetail *> *videoSourceArray;
@property (nonatomic, assign) TTLiveMatchVideoH5SourceType sourceType;
@end

// 赛事
@interface TTLiveMatchInfoModel : NSObject

@property (nonatomic, copy)      NSString *title;

@property (nonatomic, strong)    NSNumber *team2_score;
@property (nonatomic, strong)    NSDictionary *team2_icon;
@property (nonatomic, copy)      NSString *team2_url;
@property (nonatomic, copy)      NSString *team2_name;
@property (nonatomic, copy)    NSString *team2_id;

@property (nonatomic, strong)    NSNumber *team1_score;
@property (nonatomic, strong)    NSDictionary *team1_icon;
@property (nonatomic, copy)      NSString *team1_url;
@property (nonatomic, copy)      NSString *team1_name;
@property (nonatomic, copy)    NSString *team1_id;

@property (nonatomic, strong)    NSDictionary *covers;

@property (nonatomic, strong) TTLiveMatchVideoH5SourceInfo *matchVideoLiveSource; // 视频直播
@property (nonatomic, strong) TTLiveMatchVideoH5SourceInfo *matchVideoCollectionSource; // 视频集锦
@property (nonatomic, strong) TTLiveMatchVideoH5SourceInfo *matchVideoPlaybackSource; // 视频回放

@end


///...
// 视频直播
@interface TTLiveVideoInfoModel : NSObject

@property (nonatomic, strong) NSDictionary *videoCover;
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *openURL;
@property (nonatomic, assign) BOOL playbackEnable;
// @property (nonatomic, copy) NSString *replayURL;

@end

//身份
@interface TTLiveLeaderModel : NSObject

@property (nonatomic, strong)  NSNumber *role;
@property (nonatomic, strong)  NSNumber *uid;


@end


//角色
@interface TTLiveRoleModel : NSObject

@property (nonatomic, strong)  NSNumber *role;
@property (nonatomic, copy)    NSString *name;

@end


//频道
@interface TTLiveChannelModel : NSObject

@property (nonatomic, copy)    NSString *name;
@property (nonatomic, copy)    NSString *channelId;
@property (nonatomic, copy)    NSString *channelUrl;

@end


//背景信息
@interface TTLiveBackgroundModel : NSObject

@property (nonatomic, strong) TTLiveMatchInfoModel *match;
@property (nonatomic, strong) TTLiveStarInfoModel *star;
@property (nonatomic, strong) TTLiveVideoInfoModel *video;
@property (nonatomic, strong) TTLiveSimpleInfoModel *simple;

@end

//背景信息
@interface TTLiveShareInfoModel : NSObject

@property (nonatomic, copy)    NSString *url;
@property (nonatomic, copy)    NSString *summary;
@property (nonatomic, copy)    NSString *title;
@property (nonatomic, strong)  NSNumber *share_group_id;

@end

@interface TTLiveTopBannerInfoModel : NSObject

@property (nonatomic, strong)  NSNumber *status;
@property (nonatomic, strong)  NSNumber *followed;
@property (nonatomic, strong)  NSArray  *leaders;
@property (nonatomic, strong)  NSArray  *roles;
@property (nonatomic, copy)    NSString *title;
@property (nonatomic, copy)    NSString *talk_tips;
@property (nonatomic, strong)  NSNumber *start_time;
@property (nonatomic, strong)  NSNumber *background_type;
@property (nonatomic, copy)    NSString *summary;
@property (nonatomic, strong)  NSArray  *channels;
@property (nonatomic, strong)  NSNumber *default_channel;
@property (nonatomic, copy)    NSString *status_display;
@property (nonatomic, strong)  NSNumber *participated;

@property (nonatomic, strong)  NSString *subtitle;
@property (nonatomic, copy)    NSString *follow_tips;
@property (nonatomic, copy)    NSString *participated_suffix;
@property (nonatomic, strong)  TTLiveShareInfoModel *share;
@property (nonatomic, strong)  TTLiveBackgroundModel *background;

@property (nonatomic, assign) NSUInteger refresh_interval;

@property (nonatomic, assign) BOOL cameraBeautyEnable; // 是否开启美颜效果
@property (nonatomic, assign) BOOL initializeWithSelfieMode;
@property (nonatomic, assign) BOOL infiniteLike;
@property (nonatomic, assign) BOOL disableComment;
@property (nonatomic, copy) NSString *topMessageID;
@property (nonatomic, copy) NSString *infiniteLikeIcon;
@property (nonatomic, copy) NSArray<NSString *> *infiniteLikeIconList;

@end



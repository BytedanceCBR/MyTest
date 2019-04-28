//
//  ExploreVideoSP.h
//  Article
//
//  Created by Chen Hong on 15/5/8.
//
//

#ifndef Article_ExploreVideoSP_h
#define Article_ExploreVideoSP_h

typedef NS_ENUM(NSUInteger, ExploreVideoSP){
    ExploreVideoSPToutiao,
    ExploreVideoSPLeTV,
    ExploreVideoSPUnknown,
};

typedef NS_ENUM(NSUInteger, TTVideoPlayType) {
    TTVideoPlayTypeDefault = 0, // 默认
    TTVideoPlayTypeNormal = 1, // 点播
    TTVideoPlayTypeLive = 2, // 直播
    TTVideoPlayTypeLivePlayback = 3, // 直播回放
    TTVideoPlayTypePasterAD = 100 // 贴片广告 (server不依赖该值)

};

typedef NS_ENUM(NSInteger, TTVideoTitleFontStyle)
{
    TTVideoTitleFontStyleNormal,
    TTVideoTitleFontStyleSmall,
    TTVideoTitleFontStyleUltraSmall
};

/**
 *  视频清晰度
 */
typedef NS_ENUM(NSUInteger, ExploreVideoDefinitionType)
{
    /**
     *  标清
     */
    ExploreVideoDefinitionTypeSD = 0,
    /**
     *  高清
     */
    ExploreVideoDefinitionTypeHD = 1,
    /**
     *  超清
     */
    ExploreVideoDefinitionTypeFullHD = 2,
    /**
     *  未知
     */
    ExploreVideoDefinitionTypeUnknown = 3,
};

typedef void(^MoviePlayStatus)(void);
typedef void(^EventOfMovieViewMonitorBlock)(UIView * _Nonnull movieView);

#endif

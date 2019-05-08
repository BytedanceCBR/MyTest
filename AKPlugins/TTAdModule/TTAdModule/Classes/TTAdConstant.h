//
//  TTAdConstant.h
//  Article
//
//  Created by yin on 16/10/27.
//
//

#ifndef TTAdConstant_h
#define TTAdConstant_h
#import <TTBaseLib/NetworkUtilities.h>

extern NSString * const TTAdActionTypeWebString;
extern NSString * const TTAdActionTypePhoneString;
extern NSString * const TTAdActionTypeAppString;
extern NSString * const TTAdActionTypeActionString;
extern NSString * const TTAdActionTypeFormString;
extern NSString * const TTAdActionTypeCounselString;

#pragma mark -- Canvas Notification
extern NSString * const kTTAdCanvasVideoNotificationViewAppear;
extern NSString * const kTTAdCanvasVideoNotificationViewDisappear;
extern NSString * const kTTAdCanvasVideoNotificationEnterBackGround;
extern NSString * const kTTAdCanvasVideoNotificationBecomeActive;
extern NSString * const kTTAdCanvasVideoNotificationAppStoreShow;
extern NSString * const kTTAdCanvasVideoNotificationAppStoreHide;

extern NSString * const kTTAdCanvasVideoNotificationPause;
extern NSString * const kTTAdCanvasVideoNotificationResume;

extern NSString * const kTTAdCanvasNotificationExitCanvasPage;

typedef NS_ENUM(NSInteger, TTAdCreatvieType) {
    TTAdCreatvieTypeApp,
    TTAdCreatvieTypeWeb,
    TTAdCreatvieTypeAction,
    TTAdCreatvieTypeForm,
    TTAdCreatvieTypeCounsel,
    
    //商圈广告相关类型
    TTAdCreatvieTypeLocationAction,
    TTAdCreatvieTypeLocationForm,
    TTAdCreatvieTypeLocationcounsel
};

typedef NS_ENUM(NSUInteger, TTAdActionType) {
    TTAdActionTypeWeb,
    TTAdActionTypeApp,
    TTAdActionTypePhone,
    TTAdActionTypeCounsel,
    TTAdActionTypeForm
};

typedef void (^TTAdCallListenBlock)(NSString* status);

typedef NS_ENUM(NSInteger, TTAdDisplayStyle) {
    TTAdDisplayStyleRightPhoto = 2,
    TTAdDisplayStyleLargePhoto = 3,
    TTAdDisplayStyleGroupPhoto = 4,
    TTAdDisplayStyleVedio = 5
};

typedef NS_OPTIONS(NSUInteger, TTAdPreloadOption) {
    TTAdPreloadOptionWifi       = 1 << 0,
    TTAdPreloadOption4G         = 1 << 1,
    TTAdPreloadOption3G         = 1 << 2,
    TTAdPreloadOption2G         = 1 << 3,
    TTAdPreloadOptionMobile     = 1 << 4,
    TTAdPreloadOptionAll        = 31
};


typedef NS_ENUM(NSUInteger, TTAdCanvasVideoPlayType) {
    TTAdCanvasVideoPlayType_None,
    TTAdCanvasVideoPlayType_Start,
    TTAdCanvasVideoPlayType_Pause,
    TTAdCanvasVideoPlayType_Resume,
};

typedef NS_ENUM(NSUInteger, TTAdCanvasScrollOrientation) {
    TTAdCanvasScrollOrientation_Up,
    TTAdCanvasScrollOrientation_Down
};

typedef NS_ENUM(NSUInteger, TTAdCanvasItemShowStatus) {
    TTAdCanvasItemShowStatus_None,
    TTAdCanvasItemShowStatus_WillDisplay,  //部分展示
    TTAdCanvasItemShowStatus_DidDisplay, //全部展示
    TTAdCanvasItemShowStatus_WillEndDisplay, //部分消失
    TTAdCanvasItemShowStatus_DidEndDisplay, //全部消失
};

typedef NS_ENUM(NSInteger, TTAdFeedDataDisplayType) {
    /// 旧版小图模式
    TTAdFeedDataDisplayTypeeSmall = 1,
    /// 新版大图模式
    TTAdFeedDataDisplayTypeLarge = 2,
    /// 新版组(三)图模式
    TTAdFeedDataDisplayTypeGroup = 3,
    /// 新版小(右)图模式
    TTAdFeedDataDisplayTypeeRight = 4,
    //轮播图样式
    TTAdFeedDataDisplayTypeLoop = 5,
};

typedef enum TTPhotoDetailAdDisplayType
{
    TTPhotoDetailAdDisplayType_Default,
    TTPhotoDetailAdDisplayType_BigImage,
    TTPhotoDetailAdDisplayType_SmallImage,
    TTPhotoDetailAdDisplayType_GroupImage
    
}TTPhotoDetailAdDisplayType;

extern TTNetworkFlags TTAdNetworkGetFlags(void);

// 单例声明
#undef	Singleton_Interface
#define Singleton_Interface( __class ) \
+ (__class *)sharedManager;


// 单例定义
#undef	Singleton_Implementation
#define Singleton_Implementation( __class ) \
+ (__class *)sharedManager \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

/**
 广告数据模型 遵循协议
 协议中标识 广告中必须含有的重要字段
 */
@protocol TTAd <NSObject>
@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *log_extra;
@end

@protocol TTAdAppAction <NSObject>
@property (nonatomic, copy) NSString *download_url;
@property (nonatomic, copy) NSString *apple_id;
@property (nonatomic, copy) NSString *open_url;
@property (nonatomic, copy) NSString *ipa_url;
@property (nonatomic, copy) NSString *appUrl;
@property (nonatomic, copy) NSString *tabUrl;
@end

@protocol TTAdCounselAction <NSObject>
@property (nonatomic, copy) NSString *formUrl;
@end

@protocol TTAdPhoneAction <NSObject>
@property (nonatomic, copy) NSString *phoneNumber;
@end

@protocol TTAdFormAction <NSObject>
@property (nonatomic, copy) NSString *formUrl;
@end

@protocol TTAdDetailAction <NSObject>
@property (nonatomic, copy) NSString *web_url;
@property (nonatomic, copy) NSString *open_url;
@property (nonatomic, copy) NSString *web_title;
@end

@protocol TTAdArticle <NSObject>

@property (nonatomic, copy) NSString* groupId;

@end


@interface TTAdModel : NSObject <TTAd>
@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *log_extra;
@end


#define tt(x) [TTDeviceUIUtils tt_newPadding:(x)]



#endif /* TTAdConstant_h */

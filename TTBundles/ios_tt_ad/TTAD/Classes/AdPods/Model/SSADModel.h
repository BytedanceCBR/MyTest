//
//  SSADModel.h
//  Article
//
//  Created by Zhang Leonardo on 12-11-18.
//
//

/**
 * 广告的model， 目前splash广告、area广告共用，通过adModelType区分
 * API wiki https://wiki.bytedance.net/pages/viewpage.action?pageId=70869190
 *
 **/

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

#define SSADModelAreaADUmengAppPlistType    @"umengapplist"
#define SSADModelAreaADWapAppType           @"wap_app"
#define SSADModelAreaADOwnApplistType       @"own_applist"
#define SSADModelAreaAD360UnionType         @"360_union"
#define SSADModelAreaADSplashType           @"splash"

/**
 *  广告类型
 */
typedef NS_ENUM(NSUInteger, SSADModelType) {
    SSADModelTypeDisplayArea = 1, // banner , umeng app list etc ...  @2017-6-16 删除所有area相关代码
    SSADModelTypeSplash,          // 开屏广告
    SSADModelTypeChannelRefresh   // 频道下拉刷新广告位
};

/**
 * 开屏广告 对应具体广告类型
 */
typedef NS_ENUM(NSInteger, TTSplashADCommerceType) {
    TTSplashADCommerceTypeDefault   = 0,   // 占位符
    TTSplashADCommerceTypeFirst     = 1,   // 开屏首刷广告
    TTSplashADCommerceTypeCPT       = 2,   //默认值
    TTSplashADCommerceTypeGD        = 3,   
};

/**
 *  开屏广告类型
 */
typedef NS_ENUM(NSUInteger, SSSplashADType) {
    SSSplashADTypeImage = 0,                // 图片类型，包括GIF图。
    SSSplashADTypeVideoFullscreen = 2,      // 视频类型A，铺满全屏。
    SSSplashADTypeVideoCenterFit_16_9 = 3,   // 视频类型B，16:9居中于屏幕，有底图。
    SSSplashADTypeImage_ninebox = 4          //图片九宫格样式,不同区域对应不同落地页
};

/**
 *  splash广告banner的类型
 */
typedef NS_ENUM(NSUInteger, SSSplashADBannerMode) {
    SSSplashADBannerModeNoBanner    = 0, // 全图展示
    SSSplashADBannerModeShowBanner  = 1 // 头条标识固定底部，与广告拼接
};

/**
 开屏广告中 图片类型广告中间的 点击引导按钮样式
*/
typedef NS_ENUM(NSUInteger, TTSplashClikButtonStyle) {
    TTSplashClikButtonStyleNone             = 0, //不展示
    TTSplashClikButtonStyleStrip            = 1, //展示为长条，默认值
    TTSplashClikButtonStyleRoundRect        = 2,
    TTSplashClikButtonStyleStripAction      = 3, //展示为长条 附带第二动作
    TTSplashClikButtonStyleDefault          = TTSplashClikButtonStyleStrip
};

/**
 * 下拉刷新广告
 */
@protocol TTAdRefreshModel;

@interface TTAdRefreshModel : JSONModel

@property (nonatomic, assign) SSADModelType adModelType;
@property (nonatomic, copy)   NSString *splashID;
@property (nonatomic, copy)   NSString *logExtra;
@property (nonatomic, copy)   NSDictionary *imageInfo;

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, copy)   NSArray *shownTrackURLs;
@property (nonatomic, copy)   NSArray *fullyShownTrackURLs;
@property (nonatomic, copy)   NSArray *supportedChannels;

@property (nonatomic, strong) NSArray<TTAdRefreshModel> *intervalCreatives;

@end

@protocol SSADModel;
@interface SSADModel : JSONModel

//public
@property (nonatomic, assign) SSADModelType adModelType;
@property (nonatomic, assign) NSTimeInterval requestTimeInterval;
@property (nonatomic, copy)   NSString *splashID;                        // 此处为创意id
@property (nonatomic, copy)   NSString *logExtra;                        // 发送统计的时候带回去

//splash 广告
@property (nonatomic, assign) NSTimeInterval displayTime;
@property (nonatomic, assign) NSTimeInterval maxDisplayTime;
@property (nonatomic, assign) NSInteger splashDisplayAfterSecond;        //延时显示时间
@property (nonatomic, assign) NSInteger splashExpireSeconds;
@property (nonatomic, assign) NSInteger splashInterval;
@property (nonatomic, assign) NSInteger splashLeaveInterval;

@property (nonatomic, copy)   NSString *splashOpenURL;                   // 落地页1： 某详情页
@property (nonatomic, strong)   NSArray *splashOpenUrlList;              //针对图片九宫格openUrls
@property (nonatomic, copy)   NSString *splashActionType;                // 落地页2： web, app, ""
@property (nonatomic, copy)   NSString *splashDownloadURLStr;
@property (nonatomic, copy)   NSString *splashAppName;
@property (nonatomic, copy)   NSString *splashAlertText;
@property (nonatomic, copy)   NSString *splashAppleID;

@property (nonatomic, copy)   NSString *splashWebURLStr;
@property (nonatomic, copy)   NSArray *splashWebUrlList;            //针对图片九宫格webUrls
@property (nonatomic, copy)   NSString *splashWebTitle;

@property (nonatomic, strong) NSArray *splashTrackURLStrings;
@property (nonatomic, strong) NSArray *splashClickTrackURLStrings;

@property (nonatomic, copy)   NSString *display_density;
@property (nonatomic, copy)   NSDictionary *imageInfo;
@property (nonatomic, copy)   NSDictionary *landscapeImageInfo;

/// 允许再什么网络状况下加载，参考 @see TTNetworkFlags 默认展示(TTNetworkFlagWifi)
@property (nonatomic, strong) NSNumber *predownload;
@property (nonatomic, strong) NSNumber *splashBannerMode;
@property (nonatomic, strong) NSNumber *splashShowOnWifiOnly;
/// 是否展示跳过按钮和查看按钮，默认展示(YES)
@property (nonatomic, strong) NSNumber *displaySkipButton;               // skip_btn 服务器下发字段
/// 是否展示广告点击按钮，0不显示按钮，1显示新样式，2显示旧样式，默认为1。
@property (nonatomic, strong) NSNumber *displayViewButton;               // click_btn
@property (nonatomic, copy)   NSString *buttonText;
@property (nonatomic, copy)   NSString *actionURL;                      // 落地页3： 第三方

@property (nonatomic, assign) TTSplashADCommerceType commerceType;  // 开屏广告的商业类型
// 分时广告
@property (nonatomic, strong) NSArray<SSADModel> *intervalCreatives;

/// 如果是gif，是否循环播放
@property (nonatomic, strong) NSNumber *repeats;

// 开机视频广告
@property (nonatomic, assign) SSSplashADType splashADType;
@property (nonatomic, assign) BOOL videoMute;
@property (nonatomic, copy)   NSString *videoId;
@property (nonatomic, copy)   NSString *videoGroupId;
@property (nonatomic, copy)   NSArray *videoURLArray;
@property (nonatomic, copy)   NSArray *videoPlayTrackURLArray;
@property (nonatomic, copy)   NSArray *videoActionTrackURLArray;
@property (nonatomic, copy)   NSArray *videoPlayOverTrackURLArray;
@property (nonatomic, copy)   NSString *video_density;

///__deprecated wait for hero
@property (nonatomic, assign) NSInteger splashImgHeight;
@property (nonatomic, assign) NSInteger splashImgWidth;
@property (nonatomic, copy)   NSString *splashActionTitle;
@property (nonatomic, copy)   NSString *splashActionURLStr;
@property (nonatomic, copy)   NSString *splashClickTrackURLString;
@property (nonatomic, copy)   NSString *splashTrackURLStr;
@property (nonatomic, copy)   NSString *splashURLString;
@property (nonatomic, strong) NSNumber *splashHideIfExist;

//area 广告
@property (nonatomic, copy)   NSString * areaUniqueKeyName;
@property (nonatomic, copy)   NSString * areaType;
@property (nonatomic, copy)   NSString * areaTitle;
@property (nonatomic, copy)   NSString * areaWapAppURL;
@property (nonatomic, strong) NSNumber * areaInterval;

@end

@interface SSADModel (TTAdMeida)
- (CGSize)imageSize;
- (CGSize)videoSize;
@end

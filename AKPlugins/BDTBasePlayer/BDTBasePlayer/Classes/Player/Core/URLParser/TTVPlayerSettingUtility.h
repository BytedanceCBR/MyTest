//
//  TTVPlayerSettingUtility.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerState.h"

extern NSString *const kTTVAlertTitle;
extern NSString *const kTTVAlertStop;
extern NSString *const kTTVAlertPlay;

typedef enum : NSUInteger {
    TTVTrafficAlertShowAlways,//总是显示流量提醒
    TTVTrafficAlertShowOnce,//只显示一次流量提醒
} TTVTrafficAlertShowTimes;

@interface TTVPlayerSettingUtility : NSObject

+ (NSString *)leTVUserKey;
+ (void)saveLeTVUserKey:(NSString *)userKey;
+ (NSString *)leTVSecretKey;
+ (void)saveLeTVSecretKey:(NSString *)secretKey;
+ (NSString *)toutiaoUserKey;
+ (void)saveToutiaoUserKey:(NSString *)userKey;
+ (NSString *)toutiaoSecretKey;
+ (void)saveToutiaoSecretKey:(NSString *)secretKey;
+ (NSString *)leTVVideoType;
+ (NSString *)toutiaoVideoType;

+ (TTVTrafficAlertShowTimes)trafficAlertShowTimes;
+ (BOOL)tt_play_image_enhancement;
+ (BOOL)tt_video_business_refactor;
+ (BOOL)tt_video_detail_playlast_showtext;
+ (BOOL)tt_video_detail_playlast_enable;
+ (BOOL)ttvs_isVideoNewRotateEnabled;
+ (NSInteger)ttvs_isVideoFeedCellHeightAjust;
+ (NSInteger)ttvs_isVideoShowOptimizeShare;
+ (BOOL)ttvs_playerImageScaleEnable;
@end


//
//  TTVPlayerSettingUtility.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPlayerSettingUtility.h"
#import "TTBaseMacro.h"
#import <UIKit/UIKit.h>
#import "TTDeviceHelper.h"

extern BOOL ttvs_isTitanVideoBusiness(void);
extern BOOL ttvs_isVideoNewRotateEnabled(void);
BOOL ttvs_playerImageScaleEnable(void);
extern BOOL ttvs_isVideoDetailPlayLastEnabled(void);
extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern NSInteger ttvs_isVideoFeedCellHeightAjust(void);

NSString *const kTTVAlertTitle = @"您当前正在使用移动网络，继续播放将消耗流量";
NSString *const kTTVAlertStop = @"停止播放";
NSString *const kTTVAlertPlay = @"继续播放";

@implementation TTVPlayerSettingUtility

#pragma mark - fetch url

+ (NSString *)leTVUserKey {
    NSString *userKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"kLeTVUserKey"];
    if (isEmptyString(userKey)) {
        return @"ff03bba36a";
    }
    return userKey;
}

+ (void)saveLeTVUserKey:(NSString *)userKey {
    if (isEmptyString(userKey)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:userKey forKey:@"kLeTVUserKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)leTVSecretKey {
    NSString *secretKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"kLeTVSecretKey"];
    if (isEmptyString(secretKey)) {
        return @"944fdf087f83a1f6b7aad88ec2793bbc";
    }
    return secretKey;
}

+ (void)saveLeTVSecretKey:(NSString *)secretKey {
    if (isEmptyString(secretKey)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:secretKey forKey:@"kLeTVSecretKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)toutiaoUserKey {
    NSString *userKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"kToutiaoVideoUserKey"];
    if (isEmptyString(userKey)) {
        return @"toutiao";
    }
    return userKey;
}

+ (void)saveToutiaoUserKey:(NSString *)userKey {
    if (isEmptyString(userKey)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:userKey forKey:@"kToutiaoVideoUserKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)toutiaoSecretKey {
    NSString *secretKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"kToutiaoVideoSecretKey"];
    if (isEmptyString(secretKey)) {
        return @"17601e2231500d8c3389dd5d6afd08de";
    }
    return secretKey;
}

+ (void)saveToutiaoSecretKey:(NSString *)secretKey {
    if (isEmptyString(secretKey)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:secretKey forKey:@"kToutiaoVideoSecretKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)leTVVideoType {
    return @"mp4";
}

+ (NSString *)toutiaoVideoType {
    return @"mp4";
}

#pragma mark - new traffic
+ (TTVTrafficAlertShowTimes)trafficAlertShowTimes {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"TTVideoTrafficTipSettingKey"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"TTVideoTrafficTipSettingKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"TTVideoTrafficTipSettingKey"];
}

+ (BOOL)tt_play_image_enhancement
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_play_image_enhancement"] && [[UIDevice currentDevice].systemVersion floatValue] >= 8.0;
}

+ (BOOL)tt_video_business_refactor
{
    return ttvs_isTitanVideoBusiness();
}

+ (BOOL)tt_video_detail_playlast_showtext {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_video_detail_playlast_showtext"];
}

+ (BOOL)tt_video_detail_playlast_enable {
#if INHOUSE
    return YES;
#else
    return ttvs_isVideoDetailPlayLastEnabled();
#endif
}

+ (BOOL)ttvs_playerImageScaleEnable
{
    return ttvs_playerImageScaleEnable();
}

+ (NSInteger)ttvs_isVideoShowOptimizeShare
{
    return ttvs_isVideoShowOptimizeShare();
}

+ (NSInteger)ttvs_isVideoFeedCellHeightAjust
{
    return ttvs_isVideoFeedCellHeightAjust();
}

+ (BOOL)ttvs_isVideoNewRotateEnabled
{
    return ttvs_isVideoNewRotateEnabled();
}
@end

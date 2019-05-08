//
//  TTVSettingsConfiguration.h
//  Article
//
//  Created by pei yun on 2017/9/14.
//
//

#import <Foundation/Foundation.h>


extern NSString* const TTAdAppointAlertViewShowKey;
extern NSString* const TTAdAppointAlertViewCloseKey;
extern NSString * const TTStrongPushNotificationWillShowNotification;
extern NSString * const TTStrongPushNotificationDidShowNotification;
extern NSString * const TTStrongPushNotificationWillHideNotification;
extern NSString * const TTStrongPushNotificationDidHideNotification;
extern NSString * _Nonnull const kExploreMovieViewDidChangeFullScreenNotifictaion;

extern BOOL ttvs_isVideoNewRotateEnabled(void);
extern void ttvs_setIsVideoNewRotateEnabled(BOOL enabled);
extern NSInteger ttvs_isVideoFeedCellHeightAjust(void);
extern CGFloat ttvs_listVideoMaxHeight(void);
extern CGFloat ttvs_detailVideoMaxHeight(void);
extern BOOL ttvs_isVideoCellShowShareEnabled(void);
extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern NSInteger ttvs_isVideoShowDirectShare(void);
extern BOOL ttvs_enabledVideoRecommend(void);
extern BOOL ttvs_enabledVideoNewButton(void);
extern BOOL ttvs_playerImageScaleEnable(void);
extern BOOL ttvs_threeTopBarEnable(void);
extern BOOL ttvs_isShareIndividuatioEnable(void);
extern NSInteger ttvs_isShareTimelineOptimize(void);
extern BOOL ttvs_isVideoFeedURLEnabled(void);
extern BOOL ttvs_isTitanVideoBusiness(void);
extern BOOL ttvs_isVideoDetailPlayLastEnabled(void);

extern NSDictionary *ttvs_videoMidInsertADDict(void);
extern BOOL ttvs_videoMidInsertADEnable(void);
extern BOOL ttvs_isEnhancePlayerTitleFont(void);
extern NSInteger ttvs_getVideoMidInsertADReqStartTime(void);
extern NSInteger ttvs_getVideoMidInsertADReqEndTime(void);
extern BOOL ttvs_isDoubleTapForDiggEnabled(void);

@interface TTVSettingsConfiguration : NSObject

+ (void)setTitanVideoBusiness:(BOOL)enabled;
+ (void)setManualSwitchTitanVideoBusiness:(BOOL)enabled;
+ (NSMutableDictionary *)ttv_video_settings;

+ (void)setNewPlayerEnabled:(BOOL)enabled;
+ (BOOL)isNewPlayerEnabled;

@end

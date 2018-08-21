//
//  ExploreExtenstionDataHelper.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-10.
//
//

/**
 *  扩展与宿主应用之间分享数据用, 不要import其他类
 */
#import <Foundation/Foundation.h>

@interface ExploreExtenstionDataHelper : NSObject

#pragma mark -- 
#pragma mark -- 地理位置

/**
 *  用户坐标
 */
+ (double)sharedLatitude;
+ (double)sharedLongitude;
/**
 *  保存用户坐标
 */
+ (void)saveSharedLatitude:(double)latitude;
+ (void)saveSharedLongitude:(double)longitude;

/**
 *  用户所在城市
 */
+ (NSString *)sharedUserCity;

/**
 *  保存用户所在城市
 */
+ (void)saveSharedUserCity:(NSString *)userCity;

/**
 *  用户选择的城市
 *
 *  @return 用户选择的城市
 */
+ (NSString *)sharedUserSelectCity;

/**
 *  用户选择的城市
 *
 *  @param userCity 用户选择的城市
 */
+ (void)saveSharedUserSelectCity:(NSString *)userCity;

/**
 *  获取两次请求widget api 最小的间隔时间
 *
 *  @param interval 秒
 */
+ (void)saveFetchWidgetMinInterval:(int)interval;

+ (NSUInteger)fetchWidgetMinInterval;

/**
 *  用户是否设置了无图模式
 */
+ (void)saveUserSetNoImgMode:(BOOL)noImgMode;

+ (BOOL)isUserSetNoImgMode;


#pragma mark -- url

+ (void)saveSharedBaseURLDomain:(NSString *)baseURL;
+ (NSString *)sharedBaseURLDomin;

#pragma mark -- user info

+ (void)saveSharedIID:(NSString *)iid;
+ (NSString *)sharedIID;

+ (void)saveSharedDeviceID:(NSString *)deviceID;
+ (NSString *)sharedDeviceID;

+ (void)saveSharedOpenUDID:(NSString *)openUDID;
+ (NSString *)sharedOpenUDID;

+ (void)saveSharedSessionID:(NSString *)sessionID;
+ (NSString *)sharedSessionID;

#pragma mark -- impression

+ (void)appendTodayExtenstionImpression:(NSArray *)impressions;
+ (NSMutableDictionary *)fetchTodayExtenstionDict;
+ (void)clearSavedTodayExtenstions;

@end

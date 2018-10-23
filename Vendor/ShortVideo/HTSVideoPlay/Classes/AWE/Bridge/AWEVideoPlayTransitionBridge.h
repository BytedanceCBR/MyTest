//
//  AWEVideoPlayTransitionBridge.h
//  Pods
//
//  Created by lili.01 on 18/11/2016.
//
//

#import <Foundation/Foundation.h>
@class TTShortVideoModel;

NS_ASSUME_NONNULL_BEGIN

@interface AWEVideoPlayTransitionBridge : NSObject

+ (void)openProfileViewWithUserId:(NSString *)userId
                           params:(nullable NSDictionary *)params;

+ (void)openProfileViewWithUserId:(NSString *)userId
                           params:(nullable NSDictionary *)params
                         userInfo:(nullable NSDictionary *)userInfo;

/*
 params:pushWithTransitioningAnimationEnable 表示push动画是否采用transitioning方式
 */
+ (void)openProfileViewWithUserId:(NSString *)userId params:(NSDictionary *)params userInfo:(NSDictionary *)userInfo pushWithTransitioningAnimationEnable:(BOOL)pushWithTransitioningAnimationEnable;

+ (BOOL)canOpenAweme;

+ (BOOL)canOpenHotsoon;

+ (void)openAweme;

+ (void)openHotSoon;

+ (BOOL)canOpenAppWithGroupSource:(NSString *)groupSource;

+ (void)openAppWithGroupSource:(NSString *)groupSource;

+ (void)openDownloadViewWithConfigDict:(NSDictionary *)configDict
                         confirmBlock:(void(^)())confirmBlock
                          cancelBlock:(void(^)())cancelBlock;

+ (NSDictionary *)getConfigDictWithGroupSource:(NSString *)groupSource;
@end

NS_ASSUME_NONNULL_END

//
//  TTAdSplashMediator.h
//  Article
//
//  Created by yin on 2017/11/13.
//

#import <Foundation/Foundation.h>
#import "TTAdSplashManager.h"
#import "SSADManager.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"

@interface TTAdSplashMediator : NSObject

//是否展示是否请求广告的类型
@property (nonatomic, assign) TTAdSplashShowType splashADShowType;

//广告资源类型
@property (nonatomic, assign, readonly) TTAdSplashResouceType resouceType;

@property (nonatomic, assign) BOOL showByForground;

//判断开屏广告是否要展示（启动或回前台）
@property (nonatomic, assign, readonly) BOOL adWillShow;

//当前是否有开屏广告正在展现
@property (nonatomic, assign, readonly) BOOL isAdShowing;

//ignore 是否忽略 忽略传YES  遵循传NO  ***** 如果支持首刷务必设为NO ******
@property(nonatomic, assign)BOOL ignoreFirstLaunch;

// 启动时 NO； 无论是否启动开屏广告，检查完标记为YES； 进入后台前标记为 NO
@property (nonatomic, assign) BOOL finishCheck;

/**
 单例
 
 @return TTAdSplashManager开屏管理单例对象
 */
+ (TTAdSplashMediator *)shareInstance;

/**
 展示开屏广告
 
 @param keyWindow Key Window或者View 保证放在key window的最高层级上
 @param type 展示并请求、不展示但请求、不展示不请求
 @return 是否展示广告
 */
- (BOOL)displaySplashOnWindow:(UIView *)keyWindow splashShowType:(TTAdSplashShowType)type;

/**
 开屏广告缓存召回
 
 @param adIDs 召回广告的ad_id数组
 @return 召回成功与否
 */
- (BOOL)discardAd:(NSArray<NSString *> *)adIDs;

+ (void)clearResouceCache;

+ (UIImage *)splashImageForPrefix:(NSString*)prefix extension:(NSString*)extension;

- (void)didEnterBackground;

+ (BOOL)useSplashSDK;

@end

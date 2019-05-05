//
//  SSADManager.h
//  Article
//
//  Created by Zhang Leonardo on 12-11-13.
//

/**
//  头条中集成:umeng UFP广告
//  段子中集成:umeng UFP，doMob splash广告
//  首刷广告 @PM 秦兆农 https://wiki.bytedance.net/pages/viewpage.action?pageId=72791014
*/

#import <Foundation/Foundation.h>
#import "SSADModel.h"
#import "SSADTrackInfoList.h"
#import "TTAdManagerProtocol.h"

extern NSString *const kSSADPickedModelKey;
extern NSString *const kSSADPickedReadyResultKey;
extern NSString *const kSSADShowFinish; //广告展示结束

#define kAdSpalshOpenURLLeave @"kAdSpalshOpenURLLeave"                          //开屏吊起第三方app的离开时间,时间戳距离1970

@interface SSADManager : NSObject

@property (nonatomic, assign) BOOL adShow;  //判断开屏广告是否要展示
@property (nonatomic, assign) SSSplashADShowType splashADShowType;//当前展示广告的类型
@property (nonatomic, assign) BOOL isSplashADShowed; //当前是否有开屏广告在展现
@property (nonatomic, assign) BOOL showByForground;  //标识仅仅是后台到前台触发开屏(app启动后)
@property (nonatomic, assign) SSAdSplashResouceType resouceType;
@property (nonatomic, assign) BOOL finishCheck; // 启动时 NO； 无论是否启动开屏广告，检查完标记为YES； 进入后台前标记为 NO

+ (SSADManager *)shareInstance;

+ (NSArray *)getADControlSplashModels;
+ (SSADModel *)pickedFitSplashModelWithTrackInfoList:(SSADTrackInfoList *)trackList;

+ (BOOL)isSuitableTTCoverSplashADModel:(SSADModel *)model isIntervalCreatives:(BOOL)isIntervalCreatives;
//+ (void)saveSplashShowTime;//记录本次splash显示的时间
//+ (NSTimeInterval)recentlySplashShowTime;//最近一次splash显示的时间

+ (BOOL)splashADModelHasAction:(SSADModel *)model;
//生成默认启动图
+ (UIImageView *)adSplashBgImageViewWithFrame:(CGRect)viewFrame;

- (void)performActionForSplashADModel:(SSADModel *)model;

- (void)updateADControlInfoForSplashModels:(NSArray *)models;

/**
 *  此方法为4.0.1头条为了适配ios8 添加，调用后不需要调用didFinishLaunchingWithRootViewController:与willEnterForegroundWithRootViewController:或者applicationDidBecomeActive:splashShowType:
 *
 *  @param keyWindow key window
 *  @param type      类型
 */
- (BOOL)applicationDidBecomeActiveShowOnWindow:(UIWindow *)keyWindow splashShowType:(SSSplashADShowType)type;
- (void)didEnterBackground;

@end

@interface SSADManager (TTAdDiscard)
/**
 * 广告召回指令
 * @param adID 召回广告的ad_id数组
 */
- (BOOL)discardAd:(NSArray<NSString *> *)adIDs;

@end


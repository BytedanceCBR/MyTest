//
//  TTADRefreshManager.h
//  Article
//
//  Created by ranny_90 on 2017/3/20.
//
//

#import <Foundation/Foundation.h>
#import "TTAdRefreshRelateModel.h"
#import "TTADRefreshAnimationView.h"
#import "TTAdSingletonManager.h"

typedef void(^TTRefreshPrefetcheCompletedBlock)(id jsonObj, NSError *error);

typedef NS_ENUM(NSUInteger, TTAppLaunchType) {
    TTAppLaunchType_FirstLauch,     //冷启动app
    TTAppLaunchType_HotLaunch,           //热启动app
    TTAppLaunchType_Other,           //其他情况启动app
};

@class TTADRefreshAnimationView;

@interface TTADRefreshManager : NSObject <TTAdSingletonProtocol>

@property(nonatomic,assign)TTAppLaunchType lauchType;

+ (instancetype)sharedManager;

//请求获取广告元数据的网络接口
-(void)fetchRefreshADModelsWithCompleteBlock:(TTRefreshPrefetcheCompletedBlock)completion;

//创建广告下拉刷新动画
-(UIView *)createAnimateViewWithFrame:(CGRect)frame WithLoadingText:(NSString *)loadingText WithPullLoadingHeight:(CGFloat)pullLoadingHeight;

//获取下拉刷新合适的广告数据并进行刷新动画的替换
-(void)configureAnimateViewWithChannelId:(NSString *)channelId WithRefreshView:(TTRefreshView *)refreshView WithRefreshAnimateView:(UIView *)refreshAnimateAdView;

//重置下拉刷新动画为defualt动画
-(void)configureDefaultAnimateViewForRefreshView:(TTRefreshView *)refreshView;


//关于track_show事件
- (void)trackAdFreshShowWithChannelId:(NSString *)channelId WithADItemModel:(TTAdRefreshItemModel *)adItemModel;

//关于track_showInteval事件
- (void)trackAdFreshShowIntervalWithChannelId:(NSString *)channelId WithADItemModel:(TTAdRefreshItemModel *)adItemModel WithTimeInteval:(NSTimeInterval)inteval;

//实时回收下拉刷新广告数据
- (void)realTimeRemoveAd:(NSArray<NSString *> *)adIDs;

//清空下拉刷新数据
-(void)clearADRefreshCache;

@end

//
//  UIScrollView+Refresh.h
//  Zhidao
//
//  Created by Nick Yu on 3/13/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRefreshView.h"
#import "TTLoadMoreView.h"

@interface UIScrollView (Refresh)

- (void)addPullDownWithInitText:(NSString *)initText
                       pullText:(NSString *)pullText
                    loadingText:(NSString *)loadingText
                     noMoreText:(NSString *)noMoreText
                       timeText:(NSString *)timeText
                    lastTimeKey:(NSString *)timeKey
                  actionHandler:(pullActionHandler)actionHandler;
- (void)addPullUpWithInitText:(NSString *)initText
                     pullText:(NSString *)pullText
                  loadingText:(NSString *)loadtingText
                   noMoreText:(NSString *)noMoreText
                     timeText:(NSString *)timeText
                  lastTimeKey:(NSString *)timeKey
               ActioinHandler:(pullActionHandler)actionHandler;
- (void)triggerPullDown;
- (void)triggerPullUp;
- (void)finishPullDownWithSuccess:(BOOL)success;
- (void)finishPullUpWithSuccess:(BOOL)success;
- (void)pullView:(UIView *)view stateChange:(PullDirectionState)state;

// 触发下拉刷新且不显示icon动画
- (void)triggerPullDownAndHideAnimationView;

@property (nonatomic, strong, readwrite) TTRefreshView *pullDownView;
@property (nonatomic, strong, readwrite) TTLoadMoreView *pullUpView;
@property (nonatomic, assign, readwrite) BOOL isMutex;
@property (nonatomic, assign, readwrite) BOOL hasMore;
@property (nonatomic ,assign, readwrite) BOOL disableWhenLoad;
@property (nonatomic, assign, readwrite) BOOL hideNoneIcon;
@property(nonatomic) BOOL   needPullRefresh;

@property (nonatomic, assign, readwrite) BOOL disableWifiOptimize;

@property (nonatomic, assign, readwrite) BOOL isDone;

@property (nonatomic,assign) UIEdgeInsets originContentInset;
@property (nonatomic,assign) CGFloat currentRestingContentInsetBottom;

@property (nonatomic,assign) CGFloat customTopOffset;
@property (nonatomic,assign) CGFloat ttRefreshViewTopInset;
//头条专属的 业务相关
@property (nonatomic, assign) BOOL ttHasIntegratedMessageBar;
@property (nonatomic, weak, readwrite) UIView * ttIntegratedMessageBar;

@end

/// @brief 默认的接口太难创建了
/// @author sunnyxx
@interface UIScrollView (TTSimpleCreates)

- (void)tt_addDefaultPullDownRefreshWithHandler:(pullActionHandler)hander;
- (void)tt_addDefaultPullUpLoadMoreWithHandler:(pullActionHandler)hander;
- (void)tt_addPullUpLoadMoreWithNoMoreText:(NSString *)noMoreText withHandler:(pullActionHandler)hander;

@end

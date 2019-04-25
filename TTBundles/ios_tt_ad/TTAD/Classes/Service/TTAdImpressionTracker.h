//
//  TTAdImpressionTracker.h
//  Article
//
//  Created by carl on 2017/3/3.
//
//

#import <Foundation/Foundation.h>


/**
 标准 监听器 必须实现的接口规范
 */
@protocol TTVisibleTrackerProtocol <NSObject>
- (BOOL)resetTrack:(id)context;
- (void)stopTrack;
/**
 *有一定情况，会导致没有开始计算
 * 1）后台切回 2）详情页回来
 * 这两种情况下没有滑动的话就没有开始计算需要手动调用一下这个方法
 */
- (void)startTrackForce;
- (NSDictionary *)endTrack;
@end

/**
 默认实现 最简单监听器 - @2017-02-07 当前采用的等价show_over实现方式
 */
@interface TTVisibleTracker : NSObject <TTVisibleTrackerProtocol>
- (BOOL)resetTrack:(id)context;
- (void)stopTrack;
- (NSDictionary *)endTrack;
@end

/**
 根据画布在窗口的可视区域进行监控
 监控区域 最小单位是像素
 时间间隔 最小单位是毫秒
 */
@interface TTPercentVisibleTracker : NSObject <TTVisibleTrackerProtocol>

@property (nonatomic, copy) NSString *identify;
@property (nonatomic, assign, readonly) CGRect visibleCanvas;
@property (nonatomic, assign, readonly) CGFloat percent;

- (instancetype)initWithVisible:(CGRect)visibleRect percent:(CGFloat)percent scrollView:(UIScrollView *)view;
- (BOOL)resetTrack:(id)context;
- (void)startTrackForce;
- (void)stopTrack;
- (NSDictionary *)endTrack;

@end
/**
 *针对视频播放时长的监控
 */
@protocol TTVAutoPlayingCell;
@interface TTVideoPercentVisibleTracker : TTPercentVisibleTracker

- (instancetype)initWithVisible:(CGRect)visibleRect percent:(CGFloat)percent scrollView:(UIScrollView *)view movieCell:(id<TTVAutoPlayingCell>)cell;

@end

/**
 组合 监控器（容器）
 */
@interface TTCompositeVisibleTracker : NSObject <TTVisibleTrackerProtocol>

- (instancetype)initWithTrackers:(NSArray<id<TTVisibleTrackerProtocol>>*)trackers;
- (BOOL)resetTrack:(id)context;
- (void)stopTrack;
- (void)startTrackForce;
- (NSDictionary *)endTrack;

@end


/**
 Cell 监控管理者
 被监控者 必须实现接口 TTVisibleTrackerProtocol
 */
@interface TTAdImpressionTracker : NSObject

+ (instancetype)sharedImpressionTracker;

- (void)track:(id)keyObj tracker:(id<TTVisibleTrackerProtocol>)tracker;
- (void)track:(id)keyObj visible:(CGRect)visibleRect scrollView:(UIScrollView *)view;
- (void)track:(id)keyObj visible:(CGRect)visibleRect scrollView:(UIScrollView *)view movieCell:(id<TTVAutoPlayingCell>)cell;
- (void)reset:(id)context;
- (NSString *)endTrack:(id)keyObj;
- (void)startTrackForce;

@end

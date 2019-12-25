//
//  FHMinisdkManager.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/2.
//

#import <Foundation/Foundation.h>
#import <BDDiamond20/BDMTaskCenterManager.h>

NS_ASSUME_NONNULL_BEGIN

/** 春节活动 管理器
 *
 * 负责管理春节活动
 */

@interface FHMinisdkManager : NSObject

//春节活动进来为YES，app第一次启动时候需要
@property(nonatomic, assign) BOOL isSpring;
@property(nonatomic, assign) BOOL isShowing;
@property(nonatomic, strong) NSURL *url;
    
+ (instancetype)sharedInstance;
    
//App冷启动调用，调用时机:初始化App时候
- (void)initTask;
    
//外部链接拉活App调用，ackToken通过url传递
- (void)appBecomeActive:(NSString *)ackToken;

//在我们App完成指定任务后调用
- (void)taskComplete:(BDDTaskFinishBlock)finishBlock;
//执行任务
- (void)excuteTask;
//任务完成
- (void)taskFinished;

- (void)goSpring;
    
@end

NS_ASSUME_NONNULL_END

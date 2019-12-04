//
//  FHMinisdkManager.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/2.
//

#import <Foundation/Foundation.h>
#import <BDDiamond20/BDMTaskCenterManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMinisdkManager : NSObject
    
+ (instancetype)sharedInstance;
    
//App冷启动调用，调用时机:初始化App时候
- (void)initTask;
    
//外部链接拉活App调用，ackToken通过url传递
- (void)appBecomeActive:(NSString *)ackToken;
    
//在我们App完成指定任务后调用
- (void)taskComplete:(BDDTaskFinishBlock)finishBlock;
    
@end

NS_ASSUME_NONNULL_END

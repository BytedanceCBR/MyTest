//
//  TTActivityTaskManager.h
//  Article
//
//  Created by 冯靖君 on 2017/11/30.
//

#warning TODO 需保证线程安全

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TTActivityTaskState)
{
    TTActivityTaskStateUnScheduled,       //任务未调度，task初始化后的默认状态
    TTActivityTaskStateBlocked,           //任务阻塞
    TTActivityTaskStateCompletion         //任务完成
};

typedef void(^TTActivityTaskAction)(void);

@interface TTActivityTask : NSObject

/**
 *  初始化任务
 *  @param      identifier      任务标识，可以使用类名
 *  @param      dependencies    任务依赖，为其他任务identifier的set
                                注意！此处的依赖意味着自己depend的所有task必须已经执行完
 *  @param      taskAction      任务执行block
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                      dependencies:(NSSet <NSString *> *)dependencies
                        taskAction:(TTActivityTaskAction)taskAction;

@end

@interface TTActivityTaskManager : NSObject

/**
 *  调度任务。执行时机托管给manager
 *  注，不解决循环依赖问题。业务层保证
 */
+ (void)scheduleTask:(TTActivityTask *)task;

@end

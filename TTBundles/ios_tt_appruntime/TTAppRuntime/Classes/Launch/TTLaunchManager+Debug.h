//
//  TTLaunchManager+Debug.h
//  TTAppRuntime
//
//  Created by wangzhizhou on 2020/12/1.
//
#if INHOUSE

#import "TTLaunchManager.h"
#import "TTLaunchDefine.h"
#import "TTStartupTask.h"
#import <FHBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN
@interface TTLaunchTaskInfo : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) FHTaskType type;
@property (nonatomic, assign) uint16_t priority;
@property (nonatomic, strong) TTStartupTask *taskInstance;
@end

@interface TTLaunchTaskDebugInfo : NSObject
@property (nonatomic, copy) NSString *taskTypeName;
@property (nonatomic, assign) FHTaskType taskType;
@property (nonatomic, copy) NSArray<TTLaunchTaskInfo *> *priorityTasks;
@end

@interface TTLaunchManager(Debug)
- (NSArray<TTLaunchTaskDebugInfo *> *)launchTasksDebugInfo;
@end

@interface TTLaunchManagerDebugInfoViewController: FHBaseViewController
@end

NS_ASSUME_NONNULL_END

#endif

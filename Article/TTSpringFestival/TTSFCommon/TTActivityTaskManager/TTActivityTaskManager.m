//
//  TTActivityTaskManager.m
//  Article
//
//  Created by 冯靖君 on 2017/11/30.
//  任务关系管理

#import "TTActivityTaskManager.h"

static TTActivityTaskManager *_sharedManager = nil;

@interface TTActivityTask ()

@property (nonatomic, copy) NSString *identifier;                       //任务标识
@property (nonatomic, strong) NSSet <NSString *> *dependencies;         //任务依赖
@property (nonatomic, assign) TTActivityTaskState state;              //任务状态
@property (nonatomic, copy) TTActivityTaskAction taskAction;          //任务执行体

@end

@implementation TTActivityTask

- (instancetype)initWithIdentifier:(NSString *)identifier
                      dependencies:(NSSet<NSString *> *)dependencies
                        taskAction:(TTActivityTaskAction)taskAction
{
    if (self = [super init]) {
        _identifier = identifier;
        _dependencies = [dependencies copy];
        _taskAction = taskAction;
        _state = TTActivityTaskStateUnScheduled;
    }
    return self;
}

@end

@interface TTActivityTaskManager ()

@property (nonatomic, strong) NSMutableSet <TTActivityTask *> *tasks;

@end

@implementation TTActivityTaskManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[TTActivityTaskManager alloc] init];
    });
    return _sharedManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [super allocWithZone:zone];
    });
    return _sharedManager;
}

#pragma mark - public

+ (void)scheduleTask:(TTActivityTask *)task
{
    if (isEmptyString(task.identifier) || !task.taskAction || task.state == TTActivityTaskStateCompletion) {
        return;
    }
    
    // 检查任务依赖关系，如果有依赖任务尚未执行则block，否则直接执行
    TTActivityTaskManager *manager = [TTActivityTaskManager sharedManager];
    if ([manager checkBlock:task]) {
        [manager blockTask:task];
    } else {
        [manager executeTask:task];
    }
}

#pragma mark - private

- (BOOL)checkBlock:(TTActivityTask *)task
{
    __block BOOL shouldBlocked = NO;
    [task.dependencies enumerateObjectsUsingBlock:^(NSString * _Nonnull dependTaskIdentifier, BOOL * _Nonnull stop) {
        BOOL isCurDependTaskUnCompletion = YES;
        for (TTActivityTask *inSetTask in self.tasks) {
            if ([inSetTask.identifier isEqualToString:dependTaskIdentifier] &&
                inSetTask.state == TTActivityTaskStateCompletion) {
                isCurDependTaskUnCompletion = NO;
                break;
            }
        }
        
        if (isCurDependTaskUnCompletion) {
            shouldBlocked = YES;
            *stop = YES;
        }
    }];
    return shouldBlocked;
}

- (void)blockTask:(TTActivityTask *)task
{
    if (task && task.taskAction && task.state == TTActivityTaskStateUnScheduled) {
        task.state = TTActivityTaskStateBlocked;
        [self.tasks addObject:task];
    }
}

- (void)executeTask:(TTActivityTask *)task
{
    // 执行当前任务
    if (task && task.taskAction && task.state != TTActivityTaskStateCompletion) {
        if (task.state == TTActivityTaskStateUnScheduled) {
            [self.tasks addObject:task];
        }
        task.state = TTActivityTaskStateCompletion;
        task.taskAction();
    }
    
    // 检查有没有依赖这个任务的block任务
    for (TTActivityTask *inSetTask in self.tasks) {
        [TTActivityTaskManager scheduleTask:inSetTask];
    }
}

- (NSMutableSet *)tasks
{
    if (!_tasks) {
        _tasks = [NSMutableSet set];
    }
    return _tasks;
}

@end

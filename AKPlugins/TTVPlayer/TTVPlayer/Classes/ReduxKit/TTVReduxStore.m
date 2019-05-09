//
//  TTVReduxStore.m
//  Created by panxiang on 2018/7/20.
//

#import "TTVReduxStore.h"
#import "TTVReduxMainStore.h"
#import "NSObject+PerformSelector.h"
#import <libkern/OSAtomic.h>

@interface TTVReduxStore() {
    OSSpinLock _lock;
}

@property (nonatomic, strong) NSObject<TTVReduxStateProtocol>* rootState;    // 根 state
@property (nonatomic, strong) NSObject<TTVReduxReducerProtocol> * rootReducer;// 根 reducer
@property (nonatomic, strong) NSHashTable<NSObject<TTVReduxStateObserver> *> * observers; // 都需要通知，不能重复注册, 弱持有

@end

@implementation TTVReduxStore

- (instancetype)initWithReducer:(NSObject<TTVReduxReducerProtocol> *)reducer state:(NSObject<TTVReduxStateProtocol> *)state {
    self = [super init];
    if (self) {
        self.rootReducer = reducer;
        self.rootReducer.store = self;
        self.rootState = state;
        self.observers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        _lock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void)dealloc {
//    [[TTVReduxMainStore sharedInstance] removeStoreForKey:self.key];
}

- (instancetype)deepCopyOfObject:(id)object {
    NSData * archiveData = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:NO error:nil];
    if (archiveData) {
        id deepCoped = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
        return deepCoped;
    }
    return object;
}

#pragma mark - TTVReduxStoreProtocol
// TODO，need Copy it ???
- (NSObject<TTVReduxStateProtocol> *)state {
//    return (NSObject<TTVReduxStateProtocol> *)[self deepCopyOfObject:self.rootState];
    return self.rootState;
}

- (NSObject<TTVReduxReducerProtocol> *)reducer {
    return self.rootReducer;
}

- (void)subscribe:(NSObject<TTVReduxStateObserver> *)observer {
    if (observer && [observer respondsToSelector:@selector(stateDidChangedToNew:lastState:store:)]) {
        [self.observers addObject:observer];
        // 添加订阅成功通知
        if ([observer respondsToSelector:@selector(subscribedStoreSuccess:)]) {
            [observer subscribedStoreSuccess:self];
        }
    }
}

- (void)unSubscribe:(NSObject<TTVReduxStateObserver> *)observer {
    [self.observers removeObject:observer];
    if ([observer respondsToSelector:@selector(unsubcribedStoreSuccess:)]) {
        [observer unsubcribedStoreSuccess:self];
    }
}

- (void)dispatch:(NSObject<TTVReduxActionProtocol> *)action {

    // 可以执行的 action，先执行
    [action.target redux_performSelector:action.selector withObjects:action.params];

    // 遍历所有的 reducer, 得到新 state，通知所有的 observer，state 进行了改变
    // state进行了改变需要进行单元测试？？？
    // 这里需要加锁是否会引起崩溃 ？？？？？内存问题？
//    __block NSObject<TTVReduxStateProtocol> * stateCopyed = [self.rootState copy];

    // 获取所有的 reducer TODO
    NSArray * allreducers = [[self.rootReducer allSubreducers] arrayByAddingObject:self.rootReducer];

    __weak typeof(self) weakSelf = self;
    [allreducers enumerateObjectsUsingBlock:^(NSObject<TTVReduxReducerProtocol> *  _Nonnull subReducer, NSUInteger idx, BOOL * _Nonnull stop) {
//        @autoreleasepool {
            __strong typeof(self) strongSelf = weakSelf;
            // 记录lastState
            NSObject<TTVReduxStateProtocol> *lastState = [strongSelf.rootState copy];
            // 计算 newStat
            NSObject<TTVReduxStateProtocol> * newState = [subReducer executeWithAction:action state:strongSelf.rootState];

            if (![lastState isEqual:newState]) {
                //if different notify all observer
                [strongSelf.observers.allObjects enumerateObjectsUsingBlock:^(NSObject<TTVReduxStateObserver> * _Nonnull observer, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([observer respondsToSelector:@selector(stateDidChangedToNew:lastState:store:)]) {
                        [observer stateDidChangedToNew:newState lastState:[action.type isEqualToString:TTVReduxAction_Type_init]?nil:lastState store:strongSelf];
                    }
                }];
            }
//        }
    }];
}

//- (void)dispatch:(NSObject<TTVReduxActionProtocol> *)action {
//
//    // 可以执行的 action，先执行
//    [action.target redux_performSelector:action.selector withObjects:action.params];
//
//    // 获取所有的 reducer
//    NSArray * allreducers = [[self.rootReducer allSubreducers] arrayByAddingObject:self.rootReducer];
//
//    __weak typeof(self) weakSelf = self;
//    [allreducers enumerateObjectsUsingBlock:^(NSObject<TTVReduxReducerProtocol> *  _Nonnull subReducer, NSUInteger idx, BOOL * _Nonnull stop) {
//        @autoreleasepool {
//            __strong typeof(self) strongSelf = weakSelf;
//
//            // 记录lastState
//            // 计算 newStat
//            NSObject<TTVReduxStateProtocol> * newState = [subReducer executeWithAction:action state:[strongSelf.rootState copy]];
//
//            if (![newState isEqual:strongSelf.rootState]) {
//                NSObject<TTVReduxStateProtocol> * lastState = [strongSelf.rootState copy];
//
//                strongSelf.rootState = newState;
//                //if different notify all observer
//                [strongSelf.observers.allObjects enumerateObjectsUsingBlock:^(NSObject<TTVReduxStateObserver> * _Nonnull observer, NSUInteger idx, BOOL * _Nonnull stop) {
//                    if ([observer respondsToSelector:@selector(stateDidChangedToNew:lastState:store:)]) {
//                        [observer stateDidChangedToNew:newState lastState:lastState store:strongSelf];
//                    }
//                }];
//            }
//        }
//    }];
//}

- (void)setSubState:(NSObject<TTVReduxStateProtocol> *)subState forKey:(id<NSCopying>)key {
    [self.rootState setSubState:subState forKey:key];
}

- (NSObject<TTVReduxStateProtocol> *)subStateForKey:(id<NSCopying>)key {
    return [self.rootState subStateForKey:key];
}

- (void)setSubReducer:(NSObject<TTVReduxReducerProtocol> *)subReducer forKey:(id<NSCopying>)key {
    [self.rootReducer setSubReducer:subReducer forKey:key];
}

- (NSObject<TTVReduxReducerProtocol> *)subReducerForKey:(id<NSCopying>)key {
    return [self.rootReducer subReducerForKey:key];
}




@end

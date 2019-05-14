//
//  TTVReduxStore.h
//  Created by panxiang on 2018/7/20.
//

#import <Foundation/Foundation.h>
#import "TTVReduxState.h"
#import "TTVReduxAction.h"
#import "TTVReduxReducer.h"
#import "TTVReduxProtocol.h"

@class TTVReduxStore;

@protocol TTVReduxStateObserver <NSObject>

/**
 状态已经发生改变

 @param newState 改变后的状态
 @param lastState 改变前的状态,上一个状态
 @param store 持有state 的仓库
 */
- (void)stateDidChangedToNew:(NSObject<TTVReduxStateProtocol> *)newState lastState:(NSObject<TTVReduxStateProtocol> *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store;

// 状态将要发生改变 TODO

@optional
/**
 成功订阅通知
 
 @param store 订阅的 store
 */
- (void)subscribedStoreSuccess:(id<TTVReduxStoreProtocol>)store;

//combineReducer
//combineState


/**
 成功接触订阅通知

 @param store 订阅的 store
 */
- (void)unsubcribedStoreSuccess:(id<TTVReduxStoreProtocol>)store;

@end

@interface TTVReduxStore : NSObject<TTVReduxStoreProtocol>

/**
 初始化方法，传入一个根 reducer 和根的 state

 @param reducer  根 reducer,里面有 多个 subReducer由 root 进行管理，可以改变 state
 @param state 根 state，存放数据，里面有 多个 subState 由 root 进行管理
 @return store 节点，此节点存储数据state
 */
- (instancetype)initWithReducer:(NSObject<TTVReduxReducerProtocol> *)reducer
                          state:(NSObject<TTVReduxStateProtocol> *)state;

/// store 对应的 key，通过 key 可以从 mainStore 中取出 store
@property (nonatomic, copy, readonly) NSObject<NSCopying> *key;

@end

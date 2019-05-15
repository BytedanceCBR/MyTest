
#ifndef ReduxKitHeader_h
#define ReduxKitHeader_h

#ifndef redux_isEmptyString
#define redux_isEmptyString(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif

@protocol TTVReduxActionProtocol,TTVReduxStateProtocol,TTVReduxReducerProtocol;


@protocol TTVReduxStoreProtocol<NSObject>

/**
 用来拿到当前的根 state, 通过根 state，可以传入 key，拿到 subState，进行状态判断, 可不修改
 */
@property (nonatomic, copy, readonly) NSObject<TTVReduxStateProtocol> *state;


/**
 用来拿到当前的根 reducer, 通过根 reducer，可以传入 key，拿到 subReducer，进行状态判断
 */
@property (nonatomic, strong, readonly) NSObject<TTVReduxReducerProtocol> *reducer;


/**
 订阅 state 的变化
 
 @param observer 观察者，会收到- (void)newState:(NSObject<TTVReduxStateProtocol> *)state;回调
 */
- (void)subscribe:(id)observer;

/**
 订阅 state 的变化
 
 @param observer 观察者，订阅后会收到- (void)newState:(NSObject<TTVReduxStateProtocol> *)state;回调
 同时 block 也会收到回调，和上面的方法二选一
 */
//- (void)subscribe:(id)observer newStateBlock:(void(^)(TTVReduxState * newState))newStateBlock;

/**
 移除订阅的变化
 
 @param observer observer 观察者，订阅后会收到- (void)newState:(NSObject<TTVReduxStateProtocol> *)state;回调
 */
- (void)unSubscribe:(id)observer;


/**
 action 分发功能；当有修改 state 需求时，调用此方法，进行对 state 的修改
 
 @param action 引起数据变化的事件
 */
- (void)dispatch:(NSObject<TTVReduxActionProtocol> *)action;

@optional
/**
 添加 subReducer
 
 @param subReducer 子 reducer
 @param key key
 */
- (void)setSubReducer:(NSObject<TTVReduxReducerProtocol> *)subReducer forKey:(NSObject<NSCopying> *)key;

/**
 获取子 reducer，self 为 root reducer
 
 @param key key
 */
- (NSObject<TTVReduxReducerProtocol> *)subReducerForKey:(NSObject<NSCopying> *)key;

/**
 添加 substate
 
 @param subState 子 state
 @param key key
 */
- (void)setSubState:(NSObject<TTVReduxStateProtocol> *)subState forKey:(NSObject<NSCopying> *)key;

/**
 获取子 state，self 为 root state
 
 @param key key
 */
- (NSObject<TTVReduxStateProtocol> *)subStateForKey:(NSObject<NSCopying> *)key;

@end

@protocol TTVReduxReducerProtocol<NSObject>


/**
 reducer 计算方法，处理一个 action 和当前 store 的 state，返回一个新的 state

 @param action  触发事件
 @param state  store 当前的旧的根状态
 @return 新根的状态
 */
- (NSObject<TTVReduxStateProtocol> *)executeWithAction:(NSObject<TTVReduxActionProtocol> *)action
                                     state:(NSObject<TTVReduxStateProtocol> *)state;

@optional
/// 以下是root state 才需要实现的协议, 如果不是 root，则不需要实现以下方法

/**
 添加 subReducer
 
 @param subReducer 子 reducer
 @param key key
 */
- (void)setSubReducer:(NSObject<TTVReduxReducerProtocol> *)subReducer forKey:(NSObject<NSCopying> *)key;


/**
 获取子 reducer，self 为 root reducer
 
 @param key key
 */
- (NSObject<TTVReduxReducerProtocol> *)subReducerForKey:(NSObject<NSCopying> *)key;

/**
 从 rootreducer得到所有的 subreducer

 @return 所有 subreducer
 */
- (NSArray< NSObject<TTVReduxReducerProtocol>*> *)allSubreducers;

/// reducer 所属的 store
@property (nonatomic, weak) NSObject<TTVReduxStoreProtocol> * store;


@end

@protocol TTVReduxActionProtocol<NSObject>

@property (nonatomic, copy, readonly)   NSString     *type; // action 的类型

@optional
@property (nonatomic, strong, readonly) id target;          // 可以执行的 action的 target
@property (nonatomic, assign, readonly) SEL selector;       // 可以执行的 action 的 selector
@property (nonatomic, strong, readonly) NSArray * params;   // selector 需要的参数

@property (nonatomic, strong) NSDictionary *info;           // action 携带的额外的信息

@end

@protocol TTVReduxStateProtocol<NSObject, NSCopying>

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;
- (id)copyWithZone:(NSZone *)zone;

@optional
/// 以下是root state 才需要实现的协议, 如果不是 root，则不需要实现以下方法
/**
 添加 substate
 
 @param subState 子 state
 @param key key
 */
- (void)setSubState:(NSObject<TTVReduxStateProtocol> *)subState forKey:(NSObject<NSCopying> *)key;

/**
 获取子 state，self 为 root state
 
 @param key key
 */
- (NSObject<TTVReduxStateProtocol> *)subStateForKey:(NSObject<NSCopying> *)key;

@end


#endif /* ReduxKitHeader_h */

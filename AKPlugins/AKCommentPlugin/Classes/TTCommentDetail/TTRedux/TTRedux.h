//
//  TTRedux.h
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import <Foundation/Foundation.h>

@class Store;
@interface Action : NSObject
@property (nonatomic, assign) BOOL shouldMiddlewareHandle;
@end

@interface State : NSObject
@end

typedef State* (^ReducerCallback)(State *);
@protocol Reducer <NSObject>
@property (nonatomic, weak) Store *store;
@required

- (State *)handleAction:(Action *)action withState:(State *)state;

@end

@class Store;
@protocol Middleware <NSObject> //在action传递到store之前作一层前置处理.
@property (nonatomic, weak) Store *store;

- (void)handleAction:(Action *)action;

@end
@protocol Subscriber <NSObject>

- (void)onStateChange:(State *)state;

@end

@interface Store : NSObject
@property (nonatomic, strong) NSMutableArray<Subscriber> *subscribers;
@property (nonatomic, strong) id<Reducer> reducer;
@property (nonatomic, strong) State *state;

- (instancetype)initWithReducer:(id<Reducer>)reducer;

- (void)subscribe:(id<Subscriber>)subscriber;

- (void)unsubscribe:(id<Subscriber>)subscriber;

- (void)dispatch:(Action *)action;

@end

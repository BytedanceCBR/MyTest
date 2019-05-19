//
//  TTVReduxReducer.m
//  Created by panxiang on 2018/7/20.
//

#import "TTVReduxReducer.h"
#import "TTVReduxAction.h"
#import "TTVReduxState.h"

@interface TTVReduxReducer ()

@property (nonatomic, strong) NSMutableDictionary<id, NSObject<TTVReduxReducerProtocol> *>* subReducers;

@end

@implementation TTVReduxReducer

@synthesize store;

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setSubReducer:(NSObject<TTVReduxReducerProtocol> *)subReducer forKey:(id<NSCopying>)key {
    if ([((NSObject *)key) conformsToProtocol:@protocol(NSCopying)]) {
        if (!self.subReducers) {
            self.subReducers = @{}.mutableCopy;
        }
        self.subReducers[key] = subReducer;
        if ([subReducer respondsToSelector:@selector(store)]) {
            subReducer.store = self.store;
        }
    }
}

- (NSObject<TTVReduxReducerProtocol> *)subReducerForKey:(id<NSCopying>)key {
    if ([((NSObject *)key) conformsToProtocol:@protocol(NSCopying)]) {
        return self.subReducers[key];
    }
    return nil;
}

//- (void)dispatchAllSubreducerWithAction:(id<TTVReduxActionProtocol> )action
//                                  state:(NSObject<TTVReduxStateProtocol> * )state
//                            finishBlock:(void (^)(NSObject<TTVReduxStateProtocol> *))finishBlock {
//    
//    [self.subReducers.allValues enumerateObjectsUsingBlock:^(NSObject<TTVReduxReducerProtocol> *  _Nonnull subReducer, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([subReducer respondsToSelector:@selector(executeWithAction:state:)]) {
//            
//            NSObject<TTVReduxStateProtocol> * newState = [subReducer executeWithAction:action state:state];
//            
//            if (finishBlock) {
//                finishBlock(newState);
//            }
//        }
//    }];
//}

- (NSObject<TTVReduxStateProtocol> *)executeWithAction:(id<TTVReduxActionProtocol>)action
                                     state:(NSObject<TTVReduxStateProtocol> *)state {
    return state;
}

- (NSArray< NSObject<TTVReduxReducerProtocol>*> *)allSubreducers {
    return self.subReducers.allValues;
}

@end

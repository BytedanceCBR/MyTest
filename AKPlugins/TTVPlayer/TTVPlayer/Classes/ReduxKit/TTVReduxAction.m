//
//  TTVReduxAction.m
//  Created by panxiang on 2018/7/20.
//

#import "TTVReduxAction.h"
@interface TTVReduxAction ()

@property (nonatomic, copy)   NSString * type; // action 的类型
@property (nonatomic, strong) id target;          // 可以执行的 action的 target
@property (nonatomic, assign) SEL selector;       // 可以执行的 action 的 selector
@property (nonatomic, strong) NSArray * params;   // selector 需要的参数

@end

@implementation TTVReduxAction

@synthesize type = _type, info = _info;
@synthesize target = _target, selector = _selector, params = _params;

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                        params:(NSArray *)params
                    actionType:(NSString *)type
                          info:(NSDictionary *)info {
    self = [super init];
    if (self) {
        _target = target;
        _selector = selector;
        _params = params;
        _type = type;
        _info = info;
    }
    return self;
}

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                        params:(NSArray *)params
                    actionType:(NSString *)type {
    return [self initWithTarget:target selector:selector params:params actionType:type info:nil];
}

- (instancetype)initWithType:(NSString *)type {
    return [self initWithTarget:nil selector:nil params:nil actionType:type info:nil];
}

- (instancetype)initWithType:(NSString *)type info:(NSDictionary *)info{
    return [self initWithTarget:nil selector:nil params:nil actionType:type info:info];
}

+ (instancetype)actionWithType:(NSString *)type info:(NSDictionary *)info {
    TTVReduxAction *action = [[[self class] alloc] initWithTarget:nil selector:nil params:nil actionType:type info:info];
    return action;
}

- (BOOL)isValidAction {
    return !redux_isEmptyString(self.type);
}

+ (BOOL)isValidActon:(TTVReduxAction *)action {
    return !redux_isEmptyString(action.type);
}
@end

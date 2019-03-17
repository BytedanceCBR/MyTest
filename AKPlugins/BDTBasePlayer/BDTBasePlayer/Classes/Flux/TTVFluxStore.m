//
//  TTVFluxStore.m
//  Pods
//
//  Created by xiangwu on 2017/3/3.
//
//

#import "TTVFluxStore.h"
#import "TTVFluxAction.h"

@interface TTVFluxStore ()

@property (nonatomic, strong) NSMutableDictionary *actionDict;

@end

@implementation TTVFluxStore

- (void)dealloc
{

}

- (instancetype)init {
    self = [super init];
    if (self) {
        _actionDict = [NSMutableDictionary dictionary];
        _state = [self defaultState];
    }
    return self;
}

- (void)executeInMainThread:(void(^)(void))execute
{
    if ([NSThread isMainThread]) {
        execute();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            execute();
        });
    }
}

- (void)registerForActionClass:(Class)actionClass observer:(id)observer {
    NSString *key = NSStringFromClass(actionClass);
    NSHashTable *observerArray = [self.actionDict valueForKey:key];
    if (!observerArray) {
        observerArray = [NSHashTable weakObjectsHashTable];
        [self.actionDict setValue:observerArray forKey:key];
    }
    [observerArray addObject:observer];
}

- (void)unregisterForActionClass:(Class)actionClass observer:(id)observer {
    NSString *key = NSStringFromClass(actionClass);
    NSHashTable *observerArray = [self.actionDict valueForKey:key];
    [observerArray removeObject:observer];
}

- (BOOL)respondToAction:(TTVFluxAction *)action {
    NSString *key = NSStringFromClass(action.class);
    NSHashTable *observerArray = [self.actionDict valueForKey:key];
    if (observerArray.count) {
        return YES;
    }
    return NO;
}

- (void)receiveAction:(TTVFluxAction *)action {
    [self reduceAction:&action];
    NSString *key = NSStringFromClass(action.class);
    NSHashTable *observerArray = [[self.actionDict valueForKey:key] mutableCopy];
    for (id observer in observerArray) {
        if ([observer respondsToSelector:@selector(actionChangeCallbackWithAction:state:)]) {
            [observer actionChangeCallbackWithAction:action state:self.state];
        }
    }
}

- (void)reduceAction:(TTVFluxAction *__autoreleasing *)action {
    //implement by subclass
}

- (id)defaultState {
    //implement by subclass
    return nil;
}

@end

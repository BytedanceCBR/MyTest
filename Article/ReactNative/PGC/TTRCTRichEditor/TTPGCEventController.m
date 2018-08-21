//
//  TTPGCEventController.m
//  Article
//
//  Created by liaozhijie on 2017/7/21.
//
//

#import "TTPGCEventController.h"

@implementation TTPGCEventControllerListener

// 初始化
- (instancetype)initWithCaller:(id)caller
                        selector:(SEL)selector {
    return [self initWithNamespace:nil caller:caller selector:selector data:nil];
}

- (instancetype)initWithNamespace:(NSString *)namespace
                    caller:(id)caller
                  selector:(SEL)selector {
    return [self initWithNamespace:namespace caller:caller selector:selector data:nil];
}

- (instancetype)initWithNamespace:(NSString *)namespace
                          caller:(id)caller
                        selector:(SEL)selector
                            data:(id)data {
    if (self = [super init]) {
        self.namespace = namespace;
        self.caller = caller;
        self.selector = selector;
        self.data = data;
    }
    return self;
}

@end

@implementation TTPGCEventController

+ (instancetype) sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

// 事件注册dictionary
- (TTPGCEventControllerMap *)getEventMap {
    if (!_eventMap) {
        _eventMap = [[TTPGCEventControllerMap alloc] init];
    }
    return _eventMap;
}

// 获取事件队列，为空时自动创建
- (TTPGCEventControllerQueue *)getEventQueue:(NSString *)eventName
                                 createOnNil:(BOOL)createOnNil {
    TTPGCEventControllerMap * map = [self getEventMap];
    if (!map) {
        return nil;
    }

    TTPGCEventControllerQueue * queue = [map valueForKey:eventName];
    if (!queue && createOnNil) {
        queue = [[TTPGCEventControllerQueue alloc] init];
        [map setValue:queue forKey:eventName];
    }
    return queue;
}

// 获取事件队列
- (TTPGCEventControllerQueue *)getEventQueue:(NSString *)eventName {
    return [self getEventQueue:eventName createOnNil:YES];
}

// 订阅
- (TTPGCEventControllerListener *)on:(NSString *)eventName
                            listener:(TTPGCEventControllerListener *)listener {
    if (!listener) {
        return listener;
    }
    TTPGCEventControllerQueue * queue = [self getEventQueue:eventName];
    [queue addObject:listener];
    return listener;
}

- (TTPGCEventControllerListener *)on:(NSString *)namespace
                           eventName:(NSString*)eventName
                              caller:(id)caller
                            selector:(SEL)selector
                                data:(id)data {
    if (!caller || !selector) {
        return nil;
    }
    TTPGCEventControllerListener * listener = [[TTPGCEventControllerListener alloc] initWithNamespace:namespace caller:caller selector:selector data:data];
    return [self on:eventName listener:listener];
}

- (TTPGCEventControllerListener *)on:(NSString *)eventName
                              caller:(id)caller
                            selector:(SEL)selector {
    return [self on:nil eventName:eventName caller:caller selector:selector data:nil];
}

- (TTPGCEventControllerListener *)on:(NSString *)eventName
                              caller:(id)caller
                            selector:(SEL)selector
                                data:(id)data {
    return [self on:nil eventName:eventName caller:caller selector:selector data:data];
}

- (TTPGCEventControllerListener *)on:(NSString *)namespace
                           eventName:(NSString *)eventName
                              caller:(id)caller
                            selector:(SEL)selector {
    return [self on:namespace eventName:eventName caller:caller selector:selector data:nil];
}

// 取消订阅
- (void)off:(NSString *)eventName
   listener:(TTPGCEventControllerListener *)listener {
    TTPGCEventControllerQueue * queue = [self getEventQueue:eventName];
    for (NSUInteger i = 0; i < queue.count; i ++) {
        TTPGCEventControllerListener * listenerItem = queue[i];
        if (listenerItem == listener) {
            [queue removeObjectAtIndex:i];
            i --;
        }
    }
}

- (void)off:(NSString *)eventName {
    TTPGCEventControllerQueue * queue = [self getEventQueue:eventName];
    [queue removeAllObjects];
}

- (void)off:(NSString *)namespace
  eventName:(NSString *)eventName {
    TTPGCEventControllerQueue * queue = [self getEventQueue:eventName];
    for (NSUInteger i = 0; i < queue.count; i ++) {
        TTPGCEventControllerListener * listener = queue[i];
        if ([listener.namespace isEqualToString:namespace]) {
            [queue removeObjectAtIndex:i];
            i --;
        }
    }
}

- (void)offByNamespace:(NSString *)namespace {
    TTPGCEventControllerMap * map = [self getEventMap];
    for (NSString * eventName in map.allKeys) {
        [self off:namespace eventName:eventName];
    }
}

- (void)clear {
    [[self getEventMap] removeAllObjects];
}

// 触发事件
- (BOOL)emit:(NSString *)namespace
   eventName:(NSString *)eventName
        data:(id)data
   canCancel:(BOOL)canCancel {
    TTPGCEventControllerQueue * queue = [self getEventQueue:eventName createOnNil:NO];
    BOOL handled = NO;
    if (queue) {
        handled = queue.count > 0;
        for (TTPGCEventControllerListener * listener in queue) {
            BOOL cancel = NO;
            if (namespace && ![namespace isEqualToString:listener.namespace]) {
                continue;
            }
            if (listener.caller) {
                cancel = [listener.caller performSelector:listener.selector withObjects:eventName, data, listener.data, nil];
            }
            if (cancel && canCancel) {
                break;
            }
        }
    }
    return handled;
}

- (BOOL)emit:(NSString *)eventName
        data:(id)data
   canCancel:(BOOL)canCancel {
    return [self emit:nil eventName:eventName data:data canCancel:canCancel];
}

@end

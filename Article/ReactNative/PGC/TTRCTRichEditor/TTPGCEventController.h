//
//  TTPGCEventController.h
//  Article
//
//  Created by liaozhijie on 2017/7/21.
//
//

#ifndef TTPGCEventController_h
#define TTPGCEventController_h

// 事件订阅控制实现
@interface TTPGCEventControllerListener : NSObject

// selector
@property (nonatomic) SEL selector;
// caller
@property (nonatomic, weak) id caller;

@property (nonatomic) id data;

@property (nonatomic, strong) NSString * namespace;

// 初始化
- (instancetype)initWithCaller:(id)caller
                        selector:(SEL)selector;

- (instancetype)initWithNamespace:(NSString *)namespace
                    caller:(id)caller
                  selector:(SEL)selector;

- (instancetype)initWithNamespace:(NSString *)namespace
                           caller:(id)caller
                         selector:(SEL)selector
                             data:(id)data;

@end

typedef NSMutableArray<TTPGCEventControllerListener *> TTPGCEventControllerQueue;

typedef NSMutableDictionary<NSString *, TTPGCEventControllerQueue *> TTPGCEventControllerMap;

// TTPGCEventController
@interface TTPGCEventController : NSObject

@property (nonatomic, strong) TTPGCEventControllerMap * eventMap;

+ (instancetype)sharedInstance;

// 订阅
- (TTPGCEventControllerListener *)on:(NSString *)eventName
                            listener:(TTPGCEventControllerListener *)listener;

- (TTPGCEventControllerListener *)on:(NSString *)namespace
                           eventName:(NSString*)eventName
                              caller:(id)caller
                            selector:(SEL)selector
                                data:(id)data;

- (TTPGCEventControllerListener *)on:(NSString *)eventName
                              caller:(id)caller
                            selector:(SEL)selector;

- (TTPGCEventControllerListener *)on:(NSString *)eventName
                              caller:(id)caller
                            selector:(SEL)selector
                                data:(id)data;

- (TTPGCEventControllerListener *)on:(NSString *)namespace
                           eventName:(NSString *)eventName
                              caller:(id)caller
                            selector:(SEL)selector;

// 取消订阅
- (void)off:(NSString *)eventName
   listener:(TTPGCEventControllerListener *)listener;

- (void)off:(NSString *)eventName;

- (void)off:(NSString *)namespace
  eventName:(NSString *)eventName;

- (void)offByNamespace:(NSString *)namespace;

- (void)clear;

// 触发事件
- (BOOL)emit:(NSString *)namespace
   eventName:(NSString *)eventName
        data:(id)data
   canCancel:(BOOL)canCancel;

- (BOOL)emit:(NSString *)eventName
        data:(id)data
   canCancel:(BOOL)canCancel;

@end

#endif /* TTPGCEventController_h */

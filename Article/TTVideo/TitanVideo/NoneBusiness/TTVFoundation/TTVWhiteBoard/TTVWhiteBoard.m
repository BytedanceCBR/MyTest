//
//  TTVWhiteBoard.m
//  Article
//
//  Created by pei yun on 2017/5/8.
//
//

#import "TTVWhiteBoard.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTVWhiteBoardSubject.h"
#import "objc/runtime.h"

@interface TTVHandlerWrapper : NSObject

@property (nonatomic, weak) id handler;
@property (nonatomic, assign) SEL selector;
+ (instancetype)wrapperWithHandler:(id)handler;

@end

@implementation TTVHandlerWrapper

+ (instancetype)wrapperWithHandler:(id)handler {
    TTVHandlerWrapper *wrapper = [TTVHandlerWrapper new];
    wrapper.handler = handler;
    return wrapper;
}

- (BOOL)isEqual:(TTVHandlerWrapper *)wrapper {
    if (self.handler == nil) return NO;
    if (![wrapper isKindOfClass:[self class]]) return NO;
    return [self.handler isEqual:wrapper.handler];
}

- (NSUInteger)hash {
    return [self.handler hash];
}

@end

@interface TTVWhiteBoard ()

@property (nonatomic, strong) NSMutableDictionary *subjects;
@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSMutableDictionary *messageTable;

@end

@implementation TTVWhiteBoard

- (instancetype)init {
    self = [super init];
    if (self) {
        _subjects = [NSMutableDictionary dictionary];
        _values = [NSMutableDictionary dictionary];
        _messageTable = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)valueForKey:(NSString *)key {
    return [self.values objectForKey:key];
}

- (RACSignal *)signalForKey:(NSString *)key {
    NSAssert(key, @"key should not be nil");
    if (key == nil) return [RACSignal empty];
    
    TTVWhiteBoardSubject *subject = [self subjectForKey:key];
    if (subject == nil) {
        subject = [TTVWhiteBoardSubject subject];
        subject.currentValue = [self.values objectForKey:key];
        
        [self.subjects setObject:subject forKey:key];
        
        [self.rac_deallocDisposable addDisposable:[RACDisposable disposableWithBlock:^{
            [subject sendCompleted];
        }]];
    }
    return subject;
}

- (TTVWhiteBoardSubject *)subjectForKey:(NSString *)key {
    return [self.subjects objectForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    NSAssert(key, @"key should not be nil");
    if (key == nil) return;
    
    if (value) {
        [self.values setObject:value forKey:key];
    }
    else {
        [self.values removeObjectForKey:key];
    }
    
    [[self subjectForKey:key] sendNext:value];
}

- (NSArray *)queryMessage:(nonnull NSString *)message withParameters:(nullable id)parameter {
    NSMutableArray *result = [NSMutableArray array];
    NSString *key = message;
    NSArray *handlerArray = [self.messageTable objectForKey:key];
    if (handlerArray ==  nil) return @[];
    for (TTVHandlerWrapper * handlerWrapper in handlerArray) {
        id handler = handlerWrapper.handler;
        SEL messageSelector = handlerWrapper.selector;
        if (![handler respondsToSelector:messageSelector]) continue;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id ret = [handler performSelector:messageSelector withObject:parameter];
#pragma clang diagnostic pop
        if (ret == nil) continue;
        [result addObject:ret];
    }
    return result;
}

- (void)registMessageHandler:(nonnull id)handler forMessageSelector:(nonnull SEL)messageSelector {
    NSString *message = [NSStringFromSelector(messageSelector) stringByReplacingOccurrencesOfString:@":" withString:@""];
    [self registMessage:message forMessageHandler:handler forMessageSelector:messageSelector];
}

- (void)registMessage:(nonnull NSString *)message forMessageHandler:(nonnull id)handler forMessageSelector:(nonnull SEL)messageSelector
{
    NSAssert(message, @"message should not be nil");
    NSAssert(handler, @"handler should not be nil");
    NSAssert(messageSelector, @"message selector should not be nil");
    NSAssert([handler respondsToSelector:messageSelector], @"handler should implement %@", NSStringFromSelector(messageSelector));
#if DEBUG
    Method messageMethod = class_getInstanceMethod([handler class], messageSelector);
    char *returnType = method_copyReturnType(messageMethod);
    __unused NSString *result = [NSString stringWithCString:returnType encoding:NSUTF8StringEncoding];
    free(returnType);
    NSAssert(![result isEqualToString:@"v"], ([NSString stringWithFormat:@"handler:%@ message selector:%@ return type should not be void", NSStringFromClass([handler class]), NSStringFromSelector(messageSelector)]));
#endif
    NSString *key = message;
    NSMutableArray *handlerArray = [self.messageTable objectForKey:key] ?: [NSMutableArray array];
    if ([handlerArray containsObject:[TTVHandlerWrapper wrapperWithHandler:handler]]) return;
    
    TTVHandlerWrapper *wrapper = [TTVHandlerWrapper wrapperWithHandler:handler];
    wrapper.selector = messageSelector;
    [handlerArray addObject:wrapper];
    [self.messageTable setObject:handlerArray forKey:key];
}

- (void)removeHandler:(id)handler {
    for (NSString *key in self.messageTable) {
        NSMutableArray *handlerArray = [self.messageTable objectForKey:key];
        [handlerArray removeObject:[TTVHandlerWrapper wrapperWithHandler:handler]];
    }
}

#pragma mark - subscripting

- (void)setObject:(nullable id)object forKeyedSubscript:(nonnull NSString *)key {
    [self setValue:object forKey:key];
}

- (nullable id)objectForKeyedSubscript:(nonnull NSString *)key {
    return [self valueForKey:key];
}

@end

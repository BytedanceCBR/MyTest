//
//  NSObject+TTAdditions.m
//  Pods
//
//  Created by zhaoqin on 8/19/16.
//
//

#import "NSObject+TTAdditions.h"
#import <mach/mach_time.h>
@import ObjectiveC;


@implementation NSObject (Singleton)

static NSMutableDictionary* _instanceDict;

//命名
+ (id)sharedInstance_tt {
    id _instance;
    
    [[self lockForSharedInstance_tt] lock];
    if (_instanceDict == nil) {
        _instanceDict = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    NSString*_className = NSStringFromClass([self class]);
    _instance = _instanceDict[_className];
    if (_instance == nil) {
        _instance = [[self.class alloc] init];
        [_instanceDict setValue:_instance forKey:_className];
    }
    [[self lockForSharedInstance_tt] unlock];
    
    return _instance;
    
}

+ (void)destorySharedInstance_tt {
    [[self lockForSharedInstance_tt] lock];
    if (_instanceDict == nil) {
        [[self lockForSharedInstance_tt] unlock];
        return;
    }
    
    NSString *_className = NSStringFromClass([self class]);
    if ([_instanceDict objectForKey:_className]) {
        [_instanceDict removeObjectForKey:_className];
    }
    [[self lockForSharedInstance_tt] unlock];
}

+ (NSRecursiveLock *)lockForSharedInstance_tt {
    static NSRecursiveLock * lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [[NSRecursiveLock alloc] init];
    });
    return lock;
}

@end

@implementation NSObject (Time)

+ (double)machTimeToSecs:(uint64_t)time
{
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    return (double)time * (double)timebase.numer /
    (double)timebase.denom / NSEC_PER_SEC;
}

+ (uint64_t)currentUnixTime
{
    return mach_absolute_time ();
}

+ (double)elapsedTimeBlock:(void (^)(void))block
{
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;
    
    uint64_t start = mach_absolute_time ();
    block ();
    uint64_t end = mach_absolute_time ();
    uint64_t elapsed = end - start;
    
    double time = [self machTimeToSecs:elapsed];
    NSLog(@"BNRTimeBlock %f",time);
    return time;
}

@end

static NSMutableSet <NSString *>*storeKeySets;


@implementation NSObject (TTSelector)

- (BOOL)tt_performSelector:(SEL)executeSelector onlyOnceInSelector:(SEL)externSelector
{
    if (![self respondsToSelector:executeSelector]) {
        return NO;
    }
    
    if (!storeKeySets) {
        @synchronized (self) {
            if (!storeKeySets) {
                storeKeySets = [[NSMutableSet alloc] initWithCapacity:5];
            }
        }
    }
    __block NSString *storeKey = [NSStringFromSelector(externSelector) stringByAppendingString:NSStringFromSelector(executeSelector)];
    [storeKeySets enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:storeKey]) {
            *stop = YES;
            storeKey = obj;
        }
    }];
    [storeKeySets addObject:storeKey];
    
    if (objc_getAssociatedObject(self, CFBridgingRetain(storeKey))) {
        return NO;
    }
    [self performSelector:executeSelector onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
    objc_setAssociatedObject(self, CFBridgingRetain(storeKey), @"hadExecuted", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return YES;
}

/// 注明： 如果返回值为基本类型，struct除外，其余都转换为NSNumber。 如果返回值是struct。则转为NSValue
- (id)performSelector:(SEL)aSelector withObjects:(id)object, ... {
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:2];
    if (object) {
        [parameters addObject:object];
        va_list arglist;
        va_start(arglist, object);
        id arg;
        while ((arg = va_arg(arglist, id))) {
            if (arg) {
                [parameters addObject:arg];
            }
        }
        va_end(arglist);
    }
    return [self _performSelector:aSelector withObjects:parameters];
}

- (id)_performSelector:(SEL)aSelector withObjects:(NSArray *)objects {
    if (![self respondsToSelector:aSelector]) {
        return nil;
    }
    NSArray *parameters = [objects copy];
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:aSelector];
    if (!methodSignature) {
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = aSelector;
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    if (numberOfArguments > 2) {
        for (int i = 2; i < numberOfArguments; i++) {
            NSInteger idx = i - 2;
            id parameter = (parameters.count > idx) ? parameters[idx] : nil;
            [invocation setArgument:&parameter atIndex:i];
        }
    }
    [invocation retainArguments];
    [invocation invokeWithTarget:self];
    const char *type = methodSignature.methodReturnType;
    if (!strcmp(type, @encode(void)) || methodSignature.methodReturnLength == 0) {
        return nil;
    }
    id returnValue;
    if (!strcmp(type, @encode(id))) {
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    //    NSNumber, 基本类型都转换位NSNumber
    void *buffer = (void *)malloc(methodSignature.methodReturnLength);
    [invocation getReturnValue:buffer];
    returnValue = STCreateValueFromPrimitivePointer(buffer, type);
    free(buffer);
    return returnValue;
}

NSValue *STCreateValueFromPrimitivePointer(void *pointer, const char *objCType) {
    // CASE marcro inspired by https://www.mikeash.com/pyblog/friday-qa-2013-02-08-lets-build-key-value-coding.html
#define CASE(ctype)                                                                                                                                  \
if (strcmp(objCType, @encode(ctype)) == 0) {                                                                                                     \
return @((*(ctype *)pointer));                                                                                                               \
}
    CASE(BOOL);
    CASE(char);
    CASE(unsigned char);
    CASE(short);
    CASE(unsigned short);
    CASE(int);
    CASE(unsigned int);
    CASE(long);
    CASE(unsigned long);
    CASE(long long);
    CASE(unsigned long long);
    CASE(float);
    CASE(double);
#undef CASE
    @try {
        return [NSValue valueWithBytes:pointer objCType:objCType];
    }
    @catch (NSException *exception) {
    }
    return nil;
}


@end

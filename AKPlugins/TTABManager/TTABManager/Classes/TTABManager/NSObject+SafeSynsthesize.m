//
//  NSObject+SafeSynsthesize.m
//  Pods
//
//  Created by fengyadong on 2017/8/31.
//
//

#import "NSObject+SafeSynsthesize.h"
#import <objc/runtime.h>

@implementation NSObject (SafeSynsthesize)

- (dispatch_queue_t)getConcurrentQueueForStoreKey:(NSString *)key {
    __block NSString *storeKey = key;
    
    //这里扫一遍的意思是保证get方法传入的storeKey的地址和第一次set方法传入的storeKey保持一致，所有的storeKey被存放在一个互斥的可变集合中，这样即使两个字符串地址不同，但只要取值相等，就能够拿到正确的队列
    [self.tt_storeKeySets enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:storeKey]) {
            *stop = YES;
            storeKey = obj;
        }
    }];
    [self.tt_storeKeySets addObject:storeKey];
    
    
    id queue = objc_getAssociatedObject(self, (__bridge const void *)storeKey);
    
    if (queue) {
        return queue;
    }
    
    @synchronized (self) {
        queue = objc_getAssociatedObject(self, (__bridge const void *)storeKey);
        if (queue) {
            return queue;
        }
        queue = dispatch_queue_create([[NSString stringWithFormat:@"safe.synsthesize.%@.%@",NSStringFromClass([self class]),key] cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
        
        objc_setAssociatedObject(self, (__bridge const void *)storeKey, queue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return queue;
}

- (NSMutableSet <NSString *>*)tt_storeKeySets {
    static dispatch_once_t onceToken;
    __block NSMutableSet <NSString *>* storeKeySets = nil;
    dispatch_once(&onceToken, ^{
            storeKeySets = [[NSMutableSet alloc] initWithCapacity:2];
            objc_setAssociatedObject(self, _cmd, storeKeySets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    storeKeySets = objc_getAssociatedObject(self, _cmd);
    return storeKeySets;
}

@end

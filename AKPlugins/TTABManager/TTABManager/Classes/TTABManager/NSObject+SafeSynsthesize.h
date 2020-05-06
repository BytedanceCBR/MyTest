//
//  NSObject+SafeSynsthesize.h
//  Pods
//
//  Created by fengyadong on 2017/8/31.
//
//

#import <Foundation/Foundation.h>

#define SAFE_SYNNSTHESIZE(property,upper,type)    \
@synthesize property = _##property; \
- (type)property { \
    __block type property = nil;   \
    dispatch_sync([self getConcurrentQueueForStoreKey:@#property], ^{    \
        property = _##property; \
    }); \
    return property;    \
}   \
- (void)set##upper:(type)property {\
    dispatch_barrier_async([self getConcurrentQueueForStoreKey:@#property], ^{   \
        _##property = property; \
    }); \
}   \

@interface NSObject (SafeSynsthesize)

- (dispatch_queue_t)getConcurrentQueueForStoreKey:(NSString *)key;

@end

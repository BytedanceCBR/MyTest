//
//  BTDMacros.h
//  Pods
//
//  Created by willorfang on 16/8/5.
//
//

#import <Foundation/Foundation.h>
#import <pthread.h>

#ifndef __BTDMacros_H__
#define __BTDMacros_H__

// return the clamped value
#define BTD_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))

// swap two value
#define BTD_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)

#define BTDAssertMainThread() NSAssert([NSThread isMainThread], @"This method must be called on the main thread")

#if DEBUG
#define btd_keywordify autoreleasepool {}
#else
#define btd_keywordify try {} @catch (...) {}
#endif

#ifndef weakify
#if __has_feature(objc_arc)
#define weakify(object) btd_keywordify __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) btd_keywordify __block __typeof__(object) block##_##object = object;
#endif
#endif

#ifndef strongify
#if __has_feature(objc_arc)
#define strongify(object) btd_keywordify __typeof__(object) object = weak##_##object;
#else
#define strongify(object) btd_keywordify __typeof__(object) object = block##_##object;
#endif
#endif

/**
 Whether in main queue/thread.
 */
static inline bool dispatch_is_main_queue()
{
    return pthread_main_np() != 0;
}

/**
 Submits a block for asynchronous execution on a main queue and returns immediately.
 */
static inline void dispatch_async_on_main_queue(void (^block)())
{
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#ifndef onExit

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused"
static void blockCleanUp(__strong void(^*block)(void))
{
    (*block)();
}
#pragma clang diagnostic pop

#define onExit \
btd_keywordify __strong void(^block)(void) __attribute__((cleanup(blockCleanUp), unused)) = ^

#endif

#ifndef BTD_MUTEX_LOCK
#define BTD_MUTEX_LOCK(lock) \
pthread_mutex_lock(&(lock)); \
@onExit{ \
pthread_mutex_unlock(&(lock)); \
};
#endif

#ifndef BTD_SEMAPHORE_LOCK
#define BTD_SEMAPHORE_LOCK(lock) \
dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER); \
@onExit{ \
dispatch_semaphore_signal(lock); \
};
#endif


#if DEBUG
#define BTDLog(s, ...) \
NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define BTDLog(s, ...)
#endif

#define BTD_isEmptyString(param)        ( !(param) ? YES : ([(param) isKindOfClass:[NSString class]] ? (param).length == 0 : NO) )
#define BTD_isEmptyArray(param)         ( !(param) ? YES : ([(param) isKindOfClass:[NSArray class]] ? (param).count == 0 : NO) )
#define BTD_isEmptyDictionary(param)    ( !(param) ? YES : ([(param) isKindOfClass:[NSDictionary class]] ? (param).count == 0 : NO) )

#endif

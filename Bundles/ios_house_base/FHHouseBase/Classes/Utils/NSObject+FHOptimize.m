//
//  NSObject+FHOptimize.m
//  FHHouseBase
//
//  Created by 张元科 on 2020/5/18.
//

#import "NSObject+FHOptimize.h"
#import <objc/runtime.h>


static char * const WANSObjectExecuteOnceExecutionInfoAssociationKey;

@interface NSObject (ApplicationKit_ExecuteOnce_Private)

@property (readwrite) NSDictionary *excuteOnce_executionInfo;

@end

@implementation NSObject (FHOptimize)

+(void)load {
    SEL originalSel = NSSelectorFromString(@"optimize");
    SEL swizzeledSel = @selector(swizzeled_optimize);
    Class cls = NSClassFromString(@"NSISEngine");
    
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method swizzledMethod = class_getInstanceMethod(self, swizzeledSel);
    class_addMethod(cls, swizzeledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    BOOL c = class_addMethod(cls, originalSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (!c) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)swizzeled_optimize {
    if ([NSThread isMainThread]) {
        [self swizzeled_optimize];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self swizzeled_optimize];
        });
    }
}

- (NSDictionary *)excuteOnce_executionInfo {
    return objc_getAssociatedObject(self, &WANSObjectExecuteOnceExecutionInfoAssociationKey);
}

- (void)setExcuteOnce_executionInfo:(NSDictionary *)excuteOnce_executionInfo {
    objc_setAssociatedObject(self, &WANSObjectExecuteOnceExecutionInfoAssociationKey, excuteOnce_executionInfo, OBJC_ASSOCIATION_COPY);
}

- (void)executeOnce:(void (^)(void))code token:(NSString *)token {
    @synchronized(self) {
        if (!token) return;
        
        BOOL executed = [[self excuteOnce_executionInfo][token] boolValue];
        if (!executed) {
            code();
            NSMutableDictionary *executionInfo = [NSMutableDictionary dictionaryWithDictionary:self.excuteOnce_executionInfo];
            executionInfo[token] = @(YES);
            self.excuteOnce_executionInfo = executionInfo;
        }
    }
}

@end

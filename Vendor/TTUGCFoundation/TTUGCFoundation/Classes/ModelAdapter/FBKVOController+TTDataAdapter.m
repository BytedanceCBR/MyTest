//
//  FBKVOController+TTDataAdapter.m
//  Article
//
//  Created by SongChai on 08/05/2017.
//
//

#import "FBKVOController+TTDataAdapter.h"
#import <objc/runtime.h>
#import <objc/message.h>


NSString *const TTKVONotificationKeyPathKey = @"TTKVONotificationKeyPathKey";

@implementation FBKVOController (TTDataAdapter)

/**
 * KVOController升级1.2.0，不需要用runtime的方式进行增加kvo change keypath了
+ (void)load {
    Class class = NSClassFromString(@"_FBKVOSharedController");
    if (class) {
        
        SEL oriSelector = @selector(observeValueForKeyPath:ofObject:change:context:);
        Method originalMethod = class_getInstanceMethod(class, oriSelector);
        if (!originalMethod) {
            return;
        }
        SEL swizzledSelector = NSSelectorFromString([NSString stringWithFormat:@"_tt_data_adapter_%@", NSStringFromSelector(oriSelector)]);
        
        void (^observeValueForKeyPathSwizzleBlock)(id ,NSString*, id, NSDictionary*, void *) = ^void(id target,NSString* keyPath, id object, NSDictionary* change, void *context) {
            NSDictionary<NSString *, id> *changeWithKeyPath = change;
            // add the keyPath to the change dictionary for clarity when mulitple keyPaths are being observed
            if (keyPath) {
                NSMutableDictionary<NSString *, id> *mChange = [NSMutableDictionary dictionaryWithObject:keyPath forKey:TTKVONotificationKeyPathKey];
                [mChange addEntriesFromDictionary:change];
                changeWithKeyPath = [mChange copy];
            }
            
            ((void(*)(id, SEL, NSString*, id, NSDictionary*, void*))objc_msgSend)(target, swizzledSelector, keyPath, object, changeWithKeyPath, context);
        };
        
        
        IMP implementation = imp_implementationWithBlock(observeValueForKeyPathSwizzleBlock);
        class_addMethod(class, swizzledSelector, implementation, method_getTypeEncoding(originalMethod));
        Method newMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalMethod, newMethod);
    }
}
**/
@end

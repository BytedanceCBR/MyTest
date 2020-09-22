//
//  TTMultiDiggManager+FHUGC.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/9/22.
//

#import "TTMultiDiggManager+FHUGC.h"
#import "NSObject+BTDAdditions.h"
#import <objc/runtime.h>
@implementation TTMultiDiggManager (FHUGC)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self btd_swizzleInstanceMethod:NSSelectorFromString(@"updateNumLayersWithNum:") with:@selector(fh_updateNumLayersWithNum:)];
    });
}

- (void)fh_updateNumLayersWithNum:(NSInteger)num {
    Ivar ivar = class_getInstanceVariable([self class], [@"_numLayers" UTF8String]);
    NSMutableArray<CALayer *> *numLayers = object_getIvar(self, ivar);
    [numLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    [numLayers removeAllObjects];
    [self fh_updateNumLayersWithNum:num];
}

@end

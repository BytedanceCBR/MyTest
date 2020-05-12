//
//  FHLynxPageBridge.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/5/12.
//

#import "FHLynxPageBridge.h"

@interface FHLynxPageBridge()
@property(nonatomic,weak)UIViewController *weakVC;
@end

@implementation FHLynxPageBridge

- (instancetype)initWithParam:(id)param{
    self = [super init];
    if (self) {
        _weakVC = param;
    }
    return self;
}

+ (NSString *)name {
    return @"FCommonPageBridge";
}

//note 此类已经废弃，暂时保留作为备份，添加方法请移步TTLynxBridgeEngine (TTLynxExtension)
+ (NSDictionary<NSString *,NSString *> *)methodLookup {
    return @{
        @"updateStatusPage" : NSStringFromSelector(@selector(updateStatusPage:)),
//        @"dispatchEvent": NSStringFromSelector(@selector(dispatchEvent:label:params:)),
    };
}

- (void)updateStatusPage:(NSNumber *)status {
    __weak typeof(self) wSelf = self;

    void (^invokBlock)(void) = ^() {
        if (wSelf.weakVC) {
            if ([self.weakVC respondsToSelector:@selector(updateStatusPage:)]) {
                [self.weakVC performSelector:@selector(updateStatusPage:) withObject:status];
            }
        }
    };
    if ([NSThread isMainThread]) {
        invokBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), invokBlock);
    }
}

@end

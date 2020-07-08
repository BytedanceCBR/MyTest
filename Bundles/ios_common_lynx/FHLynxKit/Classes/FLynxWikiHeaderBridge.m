//
//  FLynxWikiHeaderBridge.m
//  Pods
//
//  Created by liuyu on 2020/5/21.
//

#import "FLynxWikiHeaderBridge.h"
@interface FLynxWikiHeaderBridge()
@property(nonatomic,weak)NSObject *weakObj;
@end

@implementation FLynxWikiHeaderBridge

- (instancetype)initWithParam:(id)param{
    self = [super init];
    if (self) {
            _weakObj = param;
    }
    return self;
}

+ (NSString *)name {
    return @"FLynxWikiHeaderBridge";
}

+ (NSDictionary<NSString *,NSString *> *)methodLookup {
    return @{
        @"onSelectChange" : NSStringFromSelector(@selector(onSelectChange:)),
    };
}

- (void)onSelectChange:(id)param {
    __weak typeof(self) wSelf = self;
    
    void (^invokBlock)(void) = ^() {
        if (wSelf.weakObj) {
            if ([self.weakObj respondsToSelector:@selector(onSelectChange:)]) {
                [self.weakObj performSelector:@selector(onSelectChange:) withObject:param];
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

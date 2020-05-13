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

+ (NSDictionary<NSString *,NSString *> *)methodLookup {
    return @{
        @"updateStatusPage" : NSStringFromSelector(@selector(updateStatusPage:)),
        @"close" : NSStringFromSelector(@selector(close)),
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

- (void)close{
    __weak typeof(self) wSelf = self;

      void (^invokBlock)(void) = ^() {
          if (wSelf.weakVC) {
              [wSelf.weakVC.navigationController popViewControllerAnimated:YES];
          }
      };
      if ([NSThread isMainThread]) {
          invokBlock();
      } else {
          dispatch_sync(dispatch_get_main_queue(), invokBlock);
      }
}




@end

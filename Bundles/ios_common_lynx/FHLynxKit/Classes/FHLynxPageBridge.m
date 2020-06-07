//
//  FHLynxPageBridge.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/5/12.
//

#import "FHLynxPageBridge.h"

@interface FHLynxPageBridge()
@property(nonatomic,weak)UIViewController *weakVC;
@property(nonatomic,weak)NSObject *weakObj;
@end

@implementation FHLynxPageBridge

- (instancetype)initWithParam:(id)param{
    self = [super init];
    if (self) {
        if ([param isKindOfClass:[UIViewController class]]) {
            _weakVC = param;
        }else {
            _weakObj = param;
        }
        
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
        @"disLike":NSStringFromSelector(@selector(disLike:)),
        @"tapFHEncyclopediaAction":NSStringFromSelector(@selector(tapFHEncyclopediaAction)),
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

- (void)disLike:(id)param {
    __weak typeof(self) wSelf = self;
    void (^invokBlock)(void) = ^() {
        if (wSelf.weakObj) {
            if ([self.weakObj respondsToSelector:@selector(disLike:)]) {
                [self.weakObj performSelector:@selector(disLike:) withObject:param];
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

- (void)tapFHEncyclopediaAction{
    __weak typeof(self) wSelf = self;
    void (^invokBlock)(void) = ^() {
        if (wSelf.weakObj) {
            if ([self.weakObj respondsToSelector:@selector(tapFHEncyclopediaAction:)]) {
                [self.weakObj performSelector:@selector(tapFHEncyclopediaAction:) withObject:nil];
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

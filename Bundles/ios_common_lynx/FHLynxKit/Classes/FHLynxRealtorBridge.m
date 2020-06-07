//
//  FHLynxRealtorBridge.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/6/7.
//

#import "FHLynxRealtorBridge.h"

@interface FHLynxRealtorBridge()
@property(nonatomic,weak)id birdge;
@end

@implementation FHLynxRealtorBridge


- (instancetype)initWithParam:(id)param{
    self = [super init];
    if (self) {
        self.birdge = param;
    }
    return self;
}

+ (NSString *)name {
    return @"FRealtorCardBridge";
}

+ (NSDictionary<NSString *,NSString *> *)methodLookup {
    return @{
        @"onCallPhoneClick" : NSStringFromSelector(@selector(phoneClick)),
        @"onImClick" : NSStringFromSelector(@selector(imclick)),
        @"onAvatorClick" : NSStringFromSelector(@selector(realtorInfoClick)),
    };
}

- (void)phoneClick {
    void (^invokBlock)(void) = ^() {
           if ([self.birdge respondsToSelector:@selector(phoneClick)]) {
            [self.birdge performSelector:@selector(phoneClick) withObject:nil];
        }
    };
    if ([NSThread isMainThread]) {
        invokBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), invokBlock);
    }
}

- (void)imclick {
    void (^invokBlock)(void) = ^() {
        if ([self.birdge respondsToSelector:@selector(imclick)]) {
                 [self.birdge performSelector:@selector(imclick) withObject:nil];
        }
    };
    if ([NSThread isMainThread]) {
        invokBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), invokBlock);
    }
}

- (void)realtorInfoClick {
    void (^invokBlock)(void) = ^() {
        if ([self.birdge respondsToSelector:@selector(realtorInfoClick)]) {
                 [self.birdge performSelector:@selector(realtorInfoClick) withObject:nil];
        }
    };
    if ([NSThread isMainThread]) {
        invokBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), invokBlock);
    }
}



@end

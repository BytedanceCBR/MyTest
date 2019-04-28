//
//  TTVWhiteBoardSubject.m
//  Article
//
//  Created by pei yun on 2017/5/8.
//
//

#import "TTVWhiteBoardSubject.h"
#import "RACDisposable.h"
#import "RACScheduler.h"
#import "RACSubscriber.h"

@interface RACScheduler ()
+ (instancetype)subscriptionScheduler;
@end

@implementation TTVWhiteBoardSubject

#pragma mark RACSignal

- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
    RACDisposable *subscriptionDisposable = [super subscribe:subscriber];
    
    RACDisposable *schedulingDisposable = nil;
    if (self.currentValue) {
        schedulingDisposable = [RACScheduler.subscriptionScheduler schedule:^{
            @synchronized (self) {
                [subscriber sendNext:self.currentValue];
            }
        }];
    }
    
    return [RACDisposable disposableWithBlock:^{
        [subscriptionDisposable dispose];
        [schedulingDisposable dispose];
    }];
}

#pragma mark RACSubscriber

- (void)sendNext:(id)value {
    @synchronized (self) {
        self.currentValue = value;
        [super sendNext:value];
    }
}

@end

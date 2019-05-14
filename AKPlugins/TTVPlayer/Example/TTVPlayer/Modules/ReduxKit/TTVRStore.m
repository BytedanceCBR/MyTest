//
//  TTVRStore.m
//  Created by panxiang on 2018/7/20.
//

#import "TTVRStore.h"

@interface TTVRStore()

@property (nonatomic,strong) NSMutableDictionary *subscriptions;

@end


@implementation TTVRStore

@synthesize state;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _subscriptions = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dispatch:(TTVRAction *)action
{
    TTVRReducer *reducer = [[TTVRReducer alloc] init];
    [reducer executeWithAction:action state:self.state finishBlock:^(TTVRState *state) {
        
        self.state = state;
        [self executeAllSubscribeWithAction:action state:state];
    }];
}

- (void)executeAllSubscribeWithAction:(TTVRAction *)action state:(TTVRState *)state
{
    NSArray *array = self.subscriptions.allValues;
    for (TTVSubscription subscription in array)
    {
        subscription(action,state);
    }
}

- (NSString *)subscribe:(TTVSubscription)subscription
{
    TTVSubscription copySubscription = [subscription copy];
    NSString *key = [NSString stringWithFormat:@"%p",copySubscription];
    if (subscription) {
        [self.subscriptions setObject:copySubscription forKey:key];
    }
    return key;
}

- (void)unSubscribe:(NSString *)key
{
    [self.subscriptions removeObjectForKey:key];
}

@end

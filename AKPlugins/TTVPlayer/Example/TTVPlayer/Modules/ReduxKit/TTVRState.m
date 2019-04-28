//
//  TTVRState.m
//  Created by panxiang on 2018/7/20.
//

#import "TTVRState.h"

@interface TTVRState ()
@property (nonatomic ,strong)NSMutableDictionary *states;
@end
@implementation TTVRState
- (instancetype)init
{
    self = [super init];
    if (self) {
        _states = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)keyFromClass:(Class <NSObject>)classKey
{
    return [NSString stringWithFormat:@"ttvl_state_key_%@",classKey];
}

- (id)stateForKey:(Class <NSObject>)classKey
{
    NSString *key = [self keyFromClass:classKey];
    if (key) {
        return [_states objectForKey:key];
    }
    return nil;
}

- (void)setState:(id)state forKey:(Class <NSObject>)classKey
{
    if (!classKey) {
        return;
    }
    NSString *key = [self keyFromClass:classKey];
    if (key && state) {
        [_states setObject:state forKey:key];
    }
}
@end

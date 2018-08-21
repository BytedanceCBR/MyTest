//
//  TTRedux.m
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import "TTRedux.h"


@implementation Action
@end

@implementation State
@end

@interface Store()

@end

@implementation Store

- (instancetype)initWithReducer:(id<Reducer>)reducer {
    self = [super init];
    if (self) {
        _reducer = reducer;
    }
    return self;
}

- (void)subscribe:(id<Subscriber>)subscriber {
    if (!subscriber) {
        return;
    }
    [self.subscribers addObject:subscriber];
}

- (void)unsubscribe:(id<Subscriber>)subscriber {
    if (!subscriber) {
        return;
    }
    [self.subscribers removeObject:subscriber];
}

- (void)dispatch:(Action *)action {
    State *state = [_reducer handleAction:action withState:self.state];
    self.state = state;
}

#pragma mark - getter & setter

- (void)setState:(State *)state {
    _state = state;
    for (id<Subscriber> subscriber in self.subscribers) {
        if ([subscriber respondsToSelector:@selector(onStateChange:)]) {
            [subscriber onStateChange:state];
        }
    }
}

- (NSMutableArray<Subscriber> *)subscribers {
    if (!_subscribers) {
        _subscribers = [[NSMutableArray<Subscriber> alloc] init];
    }
    return _subscribers;
}

@end

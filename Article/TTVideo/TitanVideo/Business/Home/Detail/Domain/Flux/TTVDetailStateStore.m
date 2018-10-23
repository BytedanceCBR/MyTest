//
//  TTVDetailStateStore.m
//  Article
//
//  Created by panxiang on 2017/7/7.
//
//

#import "TTVDetailStateStore.h"
#import "TTVDetailStateModel.h"
#import "TTVFluxDispatcher.h"

@implementation TTVDetailStateAction

@end

@interface TTVDetailStateStore ()
@property (nonatomic, strong) TTVFluxDispatcher *dispatcher;
@end

@implementation TTVDetailStateStore
@dynamic state;

- (void)dealloc
{
    [_dispatcher unregisterStore:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dispatcher = [[TTVFluxDispatcher alloc] init];
        [_dispatcher registerStore:self];
    }
    return self;
}

- (void)sendAction:(TTVDetailEventType)event payload:(id)payload
{
    TTVDetailStateAction *action = [[TTVDetailStateAction alloc] initWithActionType:event payload:payload];
    [self.dispatcher dispatchAction:action];
}

#pragma mark - override

- (void)reduceAction:(TTVFluxAction *__autoreleasing *)action {
    
}

- (TTVDetailStateModel *)defaultState
{
    TTVDetailStateModel *model = [[TTVDetailStateModel alloc] init];
    return model;
}

@end


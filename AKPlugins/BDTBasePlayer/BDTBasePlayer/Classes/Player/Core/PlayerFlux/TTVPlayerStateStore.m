//
//  TTVPlayerStateStore.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPlayerStateStore.h"
#import "TTVPlayerStateModel.h"
#import "TTVPlayerStateAction.h"
#import "TTVPlayerSettingUtility.h"

@interface TTVPlayerStateStore ()

@property (nonatomic, assign) NSTimeInterval watchDurationStart;
@property (nonatomic, strong) TTVPlayerStateModel *state;
@property (nonatomic, strong) TTVFluxDispatcher *dispatcher;
@end

@implementation TTVPlayerStateStore
@dynamic state;
- (instancetype)init {
    self = [super init];
    if (self) {
        _dispatcher = [[TTVFluxDispatcher alloc] init];
        [_dispatcher registerStore:self];
    }
    return self;
}

- (void)sendAction:(TTVPlayerEventType)event payload:(id)payload
{
    TTVPlayerStateAction *action = [[TTVPlayerStateAction alloc] initWithActionType:event payload:payload];
    [self.dispatcher dispatchAction:action];
}

#pragma mark - override

- (void)reduceAction:(TTVFluxAction *__autoreleasing *)action {

}

- (TTVPlayerStateModel *)defaultState
{
    TTVPlayerStateModel *model = [[TTVPlayerStateModel alloc] init];
    return model;
}

@end

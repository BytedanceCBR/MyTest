//
//  TTVConfiguredPart.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/30.
//

#import "TTVConfiguredPart.h"
#import "TTVPlayerState.h"

@implementation TTVConfiguredPart

@synthesize part, configOfPart = _configOfPart, player = _player, playerStore = _playerStore, customBundle = _customBundle, playerAction = _playerAction;

- (instancetype)initWithPart:(NSObject<TTVPlayerPartProtocol> *)part {
    self = [super init];
    if (self) {
        self.part = part;
    }
    return self;
}

- (instancetype)initWithPart:(NSObject <TTVPlayerPartProtocol> *)part config:(NSDictionary *)config {
    self = [super init];
    if (self) {
        self.part = part;
        self.configOfPart = config;
    }
    return self;
}

- (void)setConfigOfPart:(NSDictionary *)configOfPart {
    _configOfPart = configOfPart;
    // 更换 config 需要重新 apply 这个 config
    if (configOfPart.count > 0) {
        [self applyConfigOfPart];
    }
}

- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    if ([self.part respondsToSelector:@selector(stateDidChangedToNew:lastState:store:)]) {
        [((NSObject<TTVReduxStateObserver>*)self.part) stateDidChangedToNew:newState lastState:lastState store:store];
    }
}

- (void)subscribedStoreSuccess:(id<TTVReduxStoreProtocol>)store {
    if ([self.part respondsToSelector:@selector(subscribedStoreSuccess:)]) {
        [((NSObject<TTVReduxStateObserver>*)self.part) subscribedStoreSuccess:store];
    }
    [self applyConfigOfPart];
}

- (void)unsubcribedStoreSuccess:(id<TTVReduxStoreProtocol>)store {
    if ([self.part respondsToSelector:@selector(unsubcribedStoreSuccess:)]) {
        [((NSObject<TTVReduxStateObserver>*)self.part) unsubcribedStoreSuccess:store];
    }
}
#pragma mark - TTVPartProtocol
- (TTVPlayerPartKey)key {
    return self.part.key;
}

- (void)applyConfigOfPart {
    
}

- (void)setPlayer:(TTVPlayer *)player {
    _player = player;
    if ([part respondsToSelector:@selector(setPlayer:)]) {
        ((NSObject<TTVPlayerContextNew> *)part).player = self.player;
    }
}

- (void)setPlayerStore:(TTVReduxStore *)playerStore {
    _playerStore = playerStore;
    if ([part respondsToSelector:@selector(setPlayerStore:)]) {
        ((NSObject<TTVPlayerContextNew> *)part).playerStore = self.playerStore;
    }
}

- (void)setCustomBundle:(NSBundle *)customBundle {
    _customBundle = customBundle;
    if ([part respondsToSelector:@selector(setCustomBundle:)]) {
        ((NSObject<TTVPlayerContextNew> *)part).customBundle = self.customBundle;
    }
}

- (void)setPlayerAction:(TTVPlayerAction *)playerAction {
    _playerAction = playerAction;
    if ([part respondsToSelector:@selector(setPlayerAction:)]) {
        ((NSObject<TTVPlayerContextNew> *)part).playerAction = self.playerAction;
    }
}

- (void)viewDidLoad:(TTVPlayer *)playerVC {
    if ([part respondsToSelector:@selector(viewDidLoad:)]) {
        [(NSObject<TTVPlayerContextNew> *)part viewDidLoad:self.player];
    }
}
- (void)viewDidLayoutSubviews:(TTVPlayer *)playerVC {
    if ([part respondsToSelector:@selector(viewDidLayoutSubviews:)]) {
        [(NSObject<TTVPlayerContextNew> *)part viewDidLayoutSubviews:self.player];
    }
}
@end

//
//  TTVPlayerPartManager.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/9.
//

#import "TTVPlayerPartManager.h"
#import "TTVPlayer.h"
#import "TTVPlayerState.h"
#import "TTVPartFactory.h"


@interface TTVPlayerPartManager ()

@property (nonatomic, strong) NSMutableDictionary * config;    // 播放器的配置文件，此文件是外部合并过的
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSObject<TTVPlayerPartProtocol> *> *allLoadedPartsDic; // 所有已经加载的 parts
@property (nonatomic, strong) TTVPartFactory * partFactory; // 因为本类要创建 part，所以需要一个工厂

@end

@implementation TTVPlayerPartManager

@synthesize playerStore, player, customBundle, playerAction;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.allLoadedPartsDic = @{}.mutableCopy;
    }
    return self;
}

#pragma mark - TTVReduxStateObserver
- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    if (newState.fullScreenState.isFullScreen != lastState.fullScreenState.isFullScreen) {
        [self loadAllParts:newState.fullScreenState.isFullScreen];
    }
    
    //////////////// for Player Delegate ///////////////
    // lock
    if (newState.controlViewState.isLocked != lastState.controlViewState.isLocked) {
        if (newState.controlViewState.isLocked) {
            // delegate
            if ([self.player.delegate respondsToSelector:@selector(playerDidEnterLockStatus:)]) {
                [self.player.delegate playerDidEnterLockStatus:self.player];
            }
        }
        else {
            // delegate
            if ([self.player.delegate respondsToSelector:@selector(playerDidEnterUnlockStatus:)]) {
                [self.player.delegate playerDidEnterUnlockStatus:self.player];
            }
        }
    }
    
    // loading
    if (newState.loadingViewState.shouldShow != lastState.loadingViewState.shouldShow) {
        if (newState.loadingViewState.shouldShow) {
            if ([self.player.delegate respondsToSelector:@selector(playerDidStartLoading:)]) {
                [self.player.delegate playerDidStartLoading:self.player];
            }
        }
        else {
            if ([self.player.delegate respondsToSelector:@selector(playerDidStopLoading:)]) {
                [self.player.delegate playerDidStopLoading:self.player];
            }
        }
    }
    
    // immersive status
    if (newState.controlViewState.showed != lastState.controlViewState.showed) {
        if (newState.controlViewState.showed) {
            // delegate
            if ([self.player.delegate respondsToSelector:@selector(playerDidEnterPlaybackControlStatus:playbackControlView:locked:)]) {
                [self.player.delegate playerDidEnterPlaybackControlStatus:self.player playbackControlView:(newState.controlViewState.locked?self.player.controlViewLocked:self.player.controlView) locked:newState.controlViewState.locked];
            }
        }
        else {
            // delegate
            if ([self.player.delegate respondsToSelector:@selector(playerDidEnterImmersiveStatus:immersiveView:locked:)]) {
                [self.player.delegate playerDidEnterImmersiveStatus:self.player immersiveView:(newState.controlViewState.locked?self.player.controlViewLocked.immersiveContentView:self.player.controlView.immersiveContentView) locked:newState.controlViewState.locked];
            }
        }
    }
    
    // slider
    if (newState.seekStatus.isSliderPanning != lastState.seekStatus.isSliderPanning) {
        if (newState.seekStatus.isSliderPanning) {
            if ([self.player.delegate respondsToSelector:@selector(playerSliderDidStaifrtPanning:)]) {
                [self.player.delegate playerSliderDidStartPanning:(UIView<TTVSliderControlProtocol> *)[self.player partControlForKey:TTVPlayerPartControlKey_Slider]];
            }
        }
        else {
            if ([self.player.delegate respondsToSelector:@selector(playerSliderDidStopPanning:)]) {
                [self.player.delegate playerSliderDidStopPanning:(UIView<TTVSliderControlProtocol> *)[self.player partControlForKey:TTVPlayerPartControlKey_Slider]];
            }
        }
    }
    
    if (newState.seekStatus.isPanningOutOfSlider != lastState.seekStatus.isPanningOutOfSlider) {
        if (newState.seekStatus.isPanningOutOfSlider) {
            // delegate
            if ([self.player.delegate respondsToSelector:@selector(playerGestureDidStartSeeking:)]) {
                [self.player.delegate playerGestureDidStartSliderPanning:(UIView<TTVSliderControlProtocol> *)[self.player partControlForKey:TTVPlayerPartControlKey_Slider]];
            }
        }
        else {
            // delegate
            if ([self.player.delegate respondsToSelector:@selector(playerGestureDidStopSeeking:)]) {
                [self.player.delegate playerGestureDidStopSliderPanning:(UIView<TTVSliderControlProtocol> *)[self.player partControlForKey:TTVPlayerPartControlKey_Slider]];
            }
        }
    }
    
    // to 4g
    if (newState.networkState.pausingBycellularNetwork != lastState.networkState.pausingBycellularNetwork) {
        if (newState.networkState.pausingBycellularNetwork) {
            if ([self.player.delegate respondsToSelector:@selector(playerDidPauseByCellularNet:)]) {
                [self.player.delegate playerDidPauseByCellularNet:self.player];
            }
        }
    }
    
    // to full
    if (newState.fullScreenState.isFullScreen != lastState.fullScreenState.isFullScreen) {
        if (newState.fullScreenState.isFullScreen) {
            if ([self.player.delegate respondsToSelector:@selector(playerDidEnterFullscreen:)]) {
                [self.player.delegate playerDidEnterFullscreen:self.player];
            }
        }
        else {
            if ([self.player.delegate respondsToSelector:@selector(playerDidExitFullscreen:)]) {
                [self.player.delegate playerDidExitFullscreen:self.player];
            }
        }
    }
}

- (void)subscribedStoreSuccess:(TTVReduxStore *)store {
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}

#pragma mark - part management
- (void)setPlayerConfigData:(NSDictionary *)configData {
    // 内置 part
    self.config = configData.mutableCopy;
    
    // 拼接使用者注册的 part
    if ([self.player.customPartDelegate respondsToSelector:@selector(additionalPartKeysWhenInitForMode:)]) {
        for (NSInteger index = 0;index < 3;index++) {
            NSArray <NSNumber *>* partsKey;
            NSMutableDictionary * configDic;
            if (index == 0) {
                partsKey = [self.player.customPartDelegate additionalPartKeysWhenInitForMode:TTVPlayerDisplayMode_All];
                configDic = [self additionalPartOfKeys:partsKey].mutableCopy;
                [configDic addEntriesFromDictionary:self.config[@"All"]];
                if (configDic.count > 0) {
                    self.config[@"All"] = configDic;
                }
            }
            else if (index == 1) {
                partsKey = [self.player.customPartDelegate additionalPartKeysWhenInitForMode:TTVPlayerDisplayMode_Inline];
                configDic = [self additionalPartOfKeys:partsKey].mutableCopy;
                [configDic addEntriesFromDictionary:self.config[@"Inline"]];
                if (configDic.count > 0) {
                    self.config[@"Inline"] = configDic;
                }
            }
            else if (index == 2) {
                partsKey = [self.player.customPartDelegate additionalPartKeysWhenInitForMode:TTVPlayerDisplayMode_Fullscreen];
                configDic = [self additionalPartOfKeys:partsKey].mutableCopy;
                [configDic addEntriesFromDictionary:self.config[@"Fullscreen"]];
                if (configDic.count > 0) {
                    self.config[@"Fullscreen"] = configDic;
                }
            }
        }
    }
    
    // 业务方拼接 part
    if ([self.player.customPartDelegate respondsToSelector:@selector(additionalPartConfigWhenInitForMode:)]) {
        for (NSInteger index = 0;index < 3;index++) {
            NSArray<NSDictionary *> * partsArray;
            NSMutableDictionary * configDic;
            if (index == 0) {
                partsArray = [self.player.customPartDelegate additionalPartConfigWhenInitForMode:TTVPlayerDisplayMode_All];
                configDic = [self additionalPartOfConfigArray:partsArray].mutableCopy;
                [configDic addEntriesFromDictionary:self.config[@"All"]];
                if (configDic.count > 0) {
                    self.config[@"All"] = configDic;
                }
            }
            else if (index == 1) {
                partsArray = [self.player.customPartDelegate additionalPartConfigWhenInitForMode:TTVPlayerDisplayMode_Inline];
                configDic = [self additionalPartOfConfigArray:partsArray].mutableCopy;
                [configDic addEntriesFromDictionary:self.config[@"Inline"]];
                if (configDic.count > 0) {
                    self.config[@"Inline"] = configDic;
                }
            }
            else if (index == 2) {
                partsArray = [self.player.customPartDelegate additionalPartConfigWhenInitForMode:TTVPlayerDisplayMode_Fullscreen];
                configDic = [self additionalPartOfConfigArray:partsArray].mutableCopy;
                [configDic addEntriesFromDictionary:self.config[@"Fullscreen"]];
                if (configDic.count > 0) {
                    self.config[@"Fullscreen"] = configDic;
                }
            }
        }
    }
    
    // factory
    self.partFactory = [[TTVPartFactory alloc] init];
    self.partFactory.customPartDelegate = self.player.customPartDelegate;
    TTVPlayerControlViewFactory * controlFactory = [TTVPlayerControlViewFactory sharedInstance];
    controlFactory.customViewDelegate = self.player.customViewDelegate;
    self.partFactory.controlFactory = controlFactory;
}

- (NSDictionary *)additionalPartOfKeys:(NSArray <NSNumber *>*)partsKey {
    __block NSMutableDictionary * parts = @{}.mutableCopy;
    [partsKey enumerateObjectsUsingBlock:^(NSNumber * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *part = @{}.mutableCopy;
        part[@"AvailableOnInit"] = @(YES);
        part[@"Key"] = key;
        parts[key] = part;
    }];
    return parts;
}

- (NSDictionary *)additionalPartOfConfigArray:(NSArray <NSDictionary *>*)partsConfig {
    __block NSMutableDictionary * parts = @{}.mutableCopy;
    [partsConfig enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull part, NSUInteger idx, BOOL * _Nonnull stop) {
        [parts setDictionary:part];
    }];
    return parts;
}

- (void)loadAllParts:(BOOL)isFullScreen {
    // 根据当前状态，来判断要加载，哪个 config， all+inline 还是 all+full, 设置 factory 的 config,
    // 没有加载过状态和已经加载过不一样：没有加载过，重新加载，已经加载过的，all 里的不动，还需要移除没有的，增加多余的, 覆盖相同的，重新更改配置
    NSDictionary * allConfig = self.config[@"All"];
    NSDictionary * inlineConfig = self.config[@"Inline"];
    NSDictionary * fullscreenConfig = self.config[@"Fullscreen"];
    
    // 这是 partfactory 的 config， 以 standard 中为准
    NSDictionary * standandConfig = isFullScreen?fullscreenConfig:inlineConfig;
    
    // 加载 all 中的配置，生成 part
    [[self.config[@"All"] allValues] enumerateObjectsUsingBlock:^(id  _Nonnull part, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([part isKindOfClass:NSDictionary.class]) {
            part = (NSDictionary *)part;
            TTVPlayerPartKey key = [part[@"Key"] integerValue] ;
            if ([part[@"AvailableOnInit"] boolValue]) {
                [self addPartFromConfigForKey:key];
            }
        }
    }];
    
    // 需要以这个 standConfig 里配置的为准
    [[standandConfig allValues] enumerateObjectsUsingBlock:^(id  _Nonnull statndandPart, NSUInteger idx, BOOL * _Nonnull stop) {
         if ([statndandPart isKindOfClass:NSDictionary.class]) {
             statndandPart = (NSDictionary *)statndandPart;
             // statnd看下loadpart有没有，如果有，更换配置为现在的, 更换配置
             // 如果没有进行add
             TTVPlayerPartKey key = [statndandPart[@"Key"] integerValue];
             if (self.allLoadedPartsDic[@(key)]) {
                 NSObject<TTVPlayerPartProtocol> * part = [self partForKey:key];
                 if ([part respondsToSelector:@selector(setConfigOfPart:)]) {
                     [part performSelector:@selector(setConfigOfPart:) withObject:statndandPart];
                 }
             }
             else {
                 if ([statndandPart[@"AvailableOnInit"] boolValue]) {
                     [self addPartFromConfigForKey:key];
                 }
             }
         }
    }];
    
    // 对 无效的配置 中有的，stand 没有的，差集， loadpart 中进行移除
    NSDictionary * invalidConfig = !isFullScreen?fullscreenConfig:inlineConfig;
    [invalidConfig enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull invalidPart, BOOL * _Nonnull stop) {
        if ([invalidPart isKindOfClass:NSDictionary.class]) {
            invalidPart = (NSDictionary *)invalidPart;
            if (!standandConfig[key]) {
                TTVPlayerPartKey key = [invalidPart[@"Key"] integerValue];
                if (self.allLoadedPartsDic[@(key)]) {
                    [self removePartForKey:key];
                }
            }
        }
    }];
}
- (NSDictionary *)partConfigForKey:(TTVPlayerPartKey)key {
    NSDictionary * allConfig = self.config[@"All"];
    NSDictionary * inlineConfig = self.config[@"Inline"];
    NSDictionary * fullscreenConfig = self.config[@"Fullscreen"];
    
    // 这是 partfactory 的 config， 以 standard 中为准
    NSDictionary * standandConfig = [self state].fullScreenState.isFullScreen?fullscreenConfig:inlineConfig;
    NSMutableDictionary * partConfigDic = allConfig.mutableCopy;
    [partConfigDic addEntriesFromDictionary:standandConfig];
    
    // find
    __block NSDictionary * partConfig;
    [partConfigDic.allValues enumerateObjectsUsingBlock:^(id  _Nonnull part, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([part isKindOfClass:NSDictionary.class]) {
            if ([part[@"Key"] integerValue] == key ) {
                partConfig = (NSDictionary *)part;
                *stop = YES;
            }
        }
    }];
    return partConfig;
}

#pragma mark - TTVPartManagerProtocol
- (void)addPartFromConfigForKey:(TTVPlayerPartKey)key {
    if (![self partForKey:key]) {
        NSObject<TTVPlayerPartProtocol> * part = [self.partFactory createPartForKey:key];
        if (part) {
            [self addPart:part];
            // 设置 config
            if ([part respondsToSelector:@selector(setConfigOfPart:)]) {
                [part performSelector:@selector(setConfigOfPart:) withObject:[self partConfigForKey:key]];
            }
        }
    }
}

- (void)addPart:(NSObject<TTVPlayerPartProtocol> *)part {
    // 如果已经有 part 了，不能重新添加
    if ([self partForKey:part.key]) {
        return;
    }
    self.allLoadedPartsDic[@(part.key)] = part;
    // player context
    if ([part conformsToProtocol:@protocol(TTVPlayerContexts)]) {
        if ([part respondsToSelector:@selector(setPlayer:)]) {
            ((NSObject<TTVPlayerContexts> *)part).player = self.player;
        }
        if ([part respondsToSelector:@selector(setPlayerStore:)]) {
            ((NSObject<TTVPlayerContexts> *)part).playerStore = self.playerStore;
        }
        if ([part respondsToSelector:@selector(setCustomBundle:)]) {
            ((NSObject<TTVPlayerContexts> *)part).customBundle = self.customBundle;
        }
        if ([part respondsToSelector:@selector(setPlayerAction:)]) {
            ((NSObject<TTVPlayerContexts> *)part).playerAction = self.playerAction;
        }
        if ([part respondsToSelector:@selector(setControlViewFactory:)]) {
            part.controlViewFactory = [TTVPlayerControlViewFactory sharedInstance];
        }
    }
    // redux
    if ([part conformsToProtocol:@protocol(TTVReduxStateObserver)]) {
        [self.playerStore subscribe:part];
    }
}
- (void)removePart:(NSObject<TTVPlayerPartProtocol> *)part {
    [self.playerStore unSubscribe:part];
    
    // 移除这个 part 相关的所有 UI
    if ([part respondsToSelector:@selector(removeAllControlView)]) {
        [part removeAllControlView];
    }
    
    [self.allLoadedPartsDic removeObjectForKey:@(part.key)];
}

- (void)removePartForKey:(TTVPlayerPartKey)key {
    NSObject <TTVPlayerPartProtocol> * part = [self partForKey:key];
    [self removePart:part];
}

- (void)removeAllParts {
    [self.allLoadedPartsDic.allValues enumerateObjectsUsingBlock:^(id<TTVPlayerPartProtocol>  _Nonnull part, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removePart:part];
    }];
}

- (NSObject<TTVPlayerPartProtocol> *)partForKey:(TTVPlayerPartKey)key {
    return self.allLoadedPartsDic[@(key)];
}

/// 所有的 parts
- (NSArray<NSObject<TTVPlayerPartProtocol>*> *)allParts {
   return self.allLoadedPartsDic.allValues;
}

#pragma mark - context
- (void)viewDidLoad:(TTVPlayer *)playerVC {
    // 将所有目前注册过的 part 的 view 都添加到 container View 上,
    [self loadAllParts:[self state].fullScreenState.isFullScreen];
}

- (void)viewDidLayoutSubviews:(TTVPlayer *)playerVC {
    // 如果 各 part 需要布局
    [self.allLoadedPartsDic.allValues enumerateObjectsUsingBlock:^(id<TTVPlayerContexts,TTVPlayerPartProtocol,TTVReduxStateObserver>  _Nonnull part, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([part respondsToSelector:@selector(viewDidLayoutSubviews:)]) {
            [part viewDidLayoutSubviews:playerVC];
        }
    }];

}


@end

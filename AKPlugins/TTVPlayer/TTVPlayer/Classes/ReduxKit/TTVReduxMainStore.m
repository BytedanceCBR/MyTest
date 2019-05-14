//
//  TTVStoreFetcher.m
//  TTVPlayer
//
//  Created by lisa on 2018/12/26.
//

#import "TTVReduxMainStore.h"
#import "TTVReduxStore.h"

@interface TTVReduxMainStore ()

@property (nonatomic, strong) id<TTVReduxStoreProtocol> defaultStore;
@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, id<TTVReduxStoreProtocol>> *stores;

@end

@implementation TTVReduxMainStore

- (instancetype)init {
    self = [super init];
    if (self) {
        self.stores = @{}.mutableCopy;
    }
    return self;
}

// 单例
+ (instancetype _Nonnull)sharedInstance {
    static dispatch_once_t onceToken;
    static TTVReduxMainStore *instance;
    dispatch_once(&onceToken, ^{
        instance = [[TTVReduxMainStore alloc] init];
    });
    return instance;
}

- (id<TTVReduxStoreProtocol>)defaultStore {
    if (!_defaultStore) {
        _defaultStore = [[TTVReduxStore alloc] initWithReducer:[[TTVReduxReducer alloc] init] state:[[TTVReduxState alloc] init]];
        [self setStore:_defaultStore forKey:@"defaultStore"];
    }
    return _defaultStore;
}

- (id<TTVReduxStoreProtocol>)storeForKey:(id<NSCopying>)key {
    return self.stores[key];
}

- (void)setStore:(id<TTVReduxStoreProtocol>)store forKey:(id<NSCopying>)key {
    self.stores[key] = store;
}

- (void)removeStoreForKey:(id<NSCopying>)key {
    if (key) {
        [self.stores removeObjectForKey:key];
    }
}

- (NSArray<id<TTVReduxStoreProtocol>> *)allStores {
    return self.stores.allValues;
}

@end

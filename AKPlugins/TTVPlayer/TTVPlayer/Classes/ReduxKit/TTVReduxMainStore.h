//
//  TTVStoreFetcher.h
//  TTVPlayer
//
//  Created by lisa on 2018/12/26.
//

#import <Foundation/Foundation.h>
#import "TTVReduxProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 单例类，相当于根 store ，可以拿到所有的 store，默认有一个 default store，其他的都是创建而来
 */
@interface TTVReduxMainStore : NSObject

+ (instancetype _Nonnull)sharedInstance;


/**
 其他没有明确归属创建的节点，可以默认到这里

 @return self
 */
@property (nonatomic, strong, readonly) id<TTVReduxStoreProtocol> defaultStore;

/**
 获取某个节点

 @param key 节点对应的 key
 @return 对应节点
 */
- (id<TTVReduxStoreProtocol>)storeForKey:(id<NSCopying>)key;


/**
 设置节点到 mainStore

 @param store  子 store
 @param key  对应的 key
 */
- (void)setStore:(id<TTVReduxStoreProtocol>)store forKey:(id<NSCopying>)key;


/**
 从 mainstore 移除

 @param key 对应的 key
 */
- (void)removeStoreForKey:(id<NSCopying>)key;

- (NSArray<id<TTVReduxStoreProtocol>> *)allStores;

@end

NS_ASSUME_NONNULL_END

//
//  TTVPlayer+Part.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/1.
//

#import "TTVPlayer.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerPartManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 player 中管理 part 的部分
 */
@interface TTVPlayer (Part)<TTVPartManagerProtocol>

/**
 初始化 partmanager

 @return partmanager
 */
- (TTVPlayerPartManager *)createPartManager;

/**
 用于加入不从配置文件配置的 part, 直接挂载到系统中，调用后立即生效

 @param part @see TTVPlayerPartProtocol
 */
- (void)addPart:(NSObject<TTVPlayerPartProtocol> *)part;

/**
 移除 part，立即生效，同时移除他所关联到UI, 调用后立即生效

 @param part @see TTVPlayerPartProtocol
 */
- (void)removePart:(NSObject<TTVPlayerPartProtocol> *)part;

/**
 通过配置文件的配置，创建一个 part，并把它挂载到系统中, 调用后立即生效

 @param key plist中配置的 key @see TTVPlayerPartKey
 */
- (void)addPartFromConfigForKey:(TTVPlayerPartKey)key;

/**
 移除 part, 调用后立即生效

 @param key plist中配置的 key @see TTVPlayerPartKey
 */
- (void)removePartForKey:(TTVPlayerPartKey)key;

/**
 移除所有的 parts包括他们对应的 UI, 调用后立即生效
 */
- (void)removeAllParts;

/**
 获取所有的 parts

 @return allparts
 */
- (NSArray<NSObject<TTVPlayerPartProtocol>*> *)allParts;

/**
 从已经加载的 parts 中，获取当前的 part

 @param key @see TTVPlayerPartKey
 @return part （already loaded）
 */
- (NSObject<TTVPlayerPartProtocol> *)partForKey:(TTVPlayerPartKey)key;
@end

NS_ASSUME_NONNULL_END

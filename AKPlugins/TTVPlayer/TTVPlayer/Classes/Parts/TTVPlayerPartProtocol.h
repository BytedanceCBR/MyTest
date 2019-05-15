//
//  TTVPlayerPartProtocol.h
//  test
//
//  Created by lisa on 2019/1/9.
//  Copyright © 2019 lina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerDefine.h"
#import "TTVPlayerControlViewFactory.h"

NS_ASSUME_NONNULL_BEGIN

/**
 part：用来拆分播放器功能：带 UI 不带 UI
 所有的 part，需要遵循 part 协议来完成功能
 1、需要实现 告知外界 part 的加载时机，根据 part 的类型？？
 2、需要告知哪些 view 在哪些状态下加载到 playbackControl 上，在右边的状态：inline、fullscreen、lock、unlock
 3、需要可以传入整体自定义 UI，需要调用时机，也可以修改已有 UI 样式
 */
@protocol TTVPlayerPartProtocol <NSObject>

/// 所有的 part 都需要有个 key，跟 part 一一绑定
- (TTVPlayerPartKey)key;

@optional
/**
 key 对应的 view

 @param key key
 @return control view
 */
- (UIView *)viewForKey:(NSUInteger)key;

/// config 来自 才会有这个的实现
- (void)setControlView:(UIView *)controlView forKey:(TTVPlayerPartControlKey)key;

/// 移除所有的 view
- (void)removeAllControlView;


/// 有需要从外界自定义view，可以从工厂拿到 view 的实例
@property (nonatomic, strong) TTVPlayerControlViewFactory * controlViewFactory;

@end


///-----------------------------------------------------------------
/// @name 带有 part 管理类
///-----------------------------------------------------------------
@protocol TTVPartManagerProtocol <NSObject>

/// 用于加入不从配置文件配置的 part, 直接挂载到系统中
- (void)addPart:(NSObject<TTVPlayerPartProtocol> *)part;
- (void)removePart:(NSObject<TTVPlayerPartProtocol> *)part;

/// 通过配置文件的配置，创建或者移除一个 part，并把它挂载到系统中
- (void)addPartFromConfigForKey:(TTVPlayerPartKey)key;
- (void)removePartForKey:(TTVPlayerPartKey)key;

/// 移除所有的 parts
- (void)removeAllParts;

/// 所有的 parts
- (NSArray<NSObject<TTVPlayerPartProtocol>*> *)allParts;

/// 从挂载队列拿 part
- (NSObject<TTVPlayerPartProtocol> *)partForKey:(TTVPlayerPartKey)key;

@end

/// 实现这个 delegate 的类，可以得到manager 相关的回调和通知,
//@protocol TTVPartManagerDelegate <NSObject>
//
///// part manager 将要添加 parts
//- (void)partManagerWillAddParts:(NSObject<TTVPartManagerProtocol> *)manager;
///// part manager 已经添加完 parts，如果要 额外加入 part，可以通过这种方式
//- (void)partManagerDidAddParts:(NSObject<TTVPartManagerProtocol> *)manager;
//
/////
//- (void)partManagerWillRemove
//@end

///-----------------------------------------------------------------
/// @name 带有配置的 part
///-----------------------------------------------------------------
@protocol TTVConfigedPartProtocol <NSObject, TTVPlayerPartProtocol>

@property (nonatomic, strong) NSObject<TTVPlayerPartProtocol> * part;
@property (nonatomic, strong) NSDictionary * configOfPart;

- (void)applyConfigOfPart;

@end

/////-----------------------------------------------------------------
///// @name 带有播放控制的
/////-----------------------------------------------------------------
//@protocol TTVConfigedPlaybackPartProtocol <NSObject, TTVPlaybackControlViewDisplayDelegate, TTVPartProtocol, TTVConfigedPartProtocol>
//
//@end

NS_ASSUME_NONNULL_END

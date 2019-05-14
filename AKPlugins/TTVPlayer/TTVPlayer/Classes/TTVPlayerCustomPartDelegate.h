//
//  TTVPlayerCustomPartDelegate.h
//  ScreenRotate
//
//  Created by lisa on 2019/3/26.
//  Copyright © 2019 zuiye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerDefine.h"
#import "TTVPlayerPartProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 自定义 part, 可以覆盖已有的 part 以及新增外部 part
 */
@protocol TTVPlayerCustomPartDelegate <NSObject>

/**
 不同的 key，返回不同的 自定义的 part，适合在想修改已经存在的内置的 part，可以使用此方式，这里函数默认是已经注册到了partManager 中了

 @param key @see TTVPlayerPartKey
 @return part
 */
- (NSObject<TTVPlayerPartProtocol> *)customPartForKey:(TTVPlayerPartKey)key;

@optional
/**
 额外注册到partManager 中的 part，并由 partManager 在最开始就初始化就创建出来，时机不能控制，如果要自己控制时机，需要调用 addPart 方法进行添加
 此方法注册后，不会影响内置的 part，如果 额外的 key 跟内置相同
 场景：一些业务的 part 加入到框架中来，比如统计 part

 @param mode @see TTVPlayerDisplayMode 播放器的展示模式
 @return @[@(1),@(2)]
 */
- (NSArray<NSNumber *> *)additionalPartKeysWhenInitForMode:(TTVPlayerDisplayMode)mode;

/**
 额外注册到partManager 中的 part，并由 partManager 在最开始就初始化就创建出来，时机不能控制，如果要自己控制时机，需要调用 addPart 方法进行添加

 @param mode @see TTVPlayerDisplayMode 播放器的展示模式
 @return 类似于内置配置的功能配置文件 https://bytedance.feishu.cn/space/sheet/shtcnXivxqXVBTnIxvRQjJ#ba2e02
 */
- (NSArray<NSDictionary *> *)additionalPartConfigWhenInitForMode:(TTVPlayerDisplayMode)mode;// 此接口待测试，并未测试过

@end

NS_ASSUME_NONNULL_END

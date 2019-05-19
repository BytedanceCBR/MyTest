//
//  TTVNavigationPart.h
//  TTVPlayer
//
//  Created by lisa on 2019/2/1.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContext.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

/**
 1、需要时刻在 container 布局上，处于最外层 view，不可被除了 tip 以外的 view 遮挡
 2、布局，顶部对齐
 */
@interface TTVNavigationPart : NSObject<TTVPlayerContext, TTVReduxStateObserver, TTVPlayerPartProtocol>

@property (nonatomic, strong) TTVPlayerNavigationBar * navigationBar; // 需要抽象出一个类,用于可以设置 backButton 和 自定义的 title，类似系统的 UINavigationBar, 这个默认的是 navigationBar 里面的

@end

NS_ASSUME_NONNULL_END

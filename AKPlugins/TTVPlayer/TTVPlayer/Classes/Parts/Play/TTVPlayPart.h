//
//  TTVPlayPart.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/4.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContextNew.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerCustomViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 无法修改内核状态，只依赖内核状态，进行变化
 1、按钮控制播放暂停
 2、双击手势控制播放暂停
 3、自定义按钮样式
 */
@interface TTVPlayPart : NSObject<TTVPlayerContextNew, TTVReduxStateObserver, TTVPlayerPartProtocol>

/// UI 
@property (nonatomic, strong) UIView<TTVToggledButtonProtocol> *centerPlayButton; // default play Button
@property (nonatomic, strong) UIView<TTVToggledButtonProtocol> *bottomPlayButton; // default 进度条旁边的play button




@end

NS_ASSUME_NONNULL_END

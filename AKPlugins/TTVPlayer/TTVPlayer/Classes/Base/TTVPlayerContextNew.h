//
//  TTVPlayerContextNew.h
//  Article
//
//  Created by panxiang on 2018/10/24.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerMacro.h"
#import "TTVPlayerState.h"

#import "TTVReduxKit.h"
#import "TTVPlayerAction.h"


// 是否考虑要下沉？？？TODO should remove all?

@class TTVPlayerStore;
@class TTVPlayer;

@protocol TTVPlayerContextNew <NSObject>

@optional

/// Redux架构中，当前存储节点， 便利方法
@property (nonatomic, weak) TTVReduxStore   * playerStore;

/// Redux 架构中，action
@property (nonatomic, weak) TTVPlayerAction * playerAction;
/// 播放器
@property (nonatomic, weak) TTVPlayer       * player;

/// 用户传入的自定义的 bundle，custom 相关的都需要从这里先加载
@property (nonatomic, weak) NSBundle        * customBundle;

/**
 需要在此方法添加 view

 @param playerVC playerVC 可以获取所有的 view，以及 part
 */
- (void)viewDidLoad:(TTVPlayer *)playerVC;

/**
 需要在此方法layout view

 @param playerVC playerVC 可以获取所有的 view，以及 part
 */
- (void)viewDidLayoutSubviews:(TTVPlayer *)playerVC;


@end





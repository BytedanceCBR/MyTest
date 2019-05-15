//
//  TTVPlaybackControlView.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/19.
//

#import <UIKit/UIKit.h>
#import "TTVTouchIgoringView.h"
#import "TTVPlayerControlViewFactory.h"

NS_ASSUME_NONNULL_BEGIN

/**
 本类用于管理所有播放控制层上的control，在 unlock 状态和 lock 状态下 control
 */
@interface TTVPlaybackControlView : UIView

- (instancetype)initWithFrame:(CGRect)frame controlFactroy:(TTVPlayerControlViewFactory *)controlFactroy;

/// 为了让 top 和 bottom 可以各自做动画，将其他的 control 添加到 contentView 中,整体消失，所以生成 contentView 放在 controlView 的最下面
@property (nonatomic, strong) TTVTouchIgoringView * contentView;

/// 导航栏
@property (nonatomic, strong) TTVTouchIgoringView * topBar;

/// 底部栏
@property (nonatomic, strong) TTVTouchIgoringView * bottomBar;

/// 沉浸态 view
@property (nonatomic, strong) TTVTouchIgoringView * immersiveContentView;

@end

NS_ASSUME_NONNULL_END

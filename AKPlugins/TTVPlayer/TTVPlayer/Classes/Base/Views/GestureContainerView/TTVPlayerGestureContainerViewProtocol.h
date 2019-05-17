//
//  TTVPlayerControl.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TTVPlayerGestureContainerViewProtocol <NSObject>

/**
 本协议是Player的 containerView 的协议
 */
@property (nonatomic ,strong ,readonly)UIView *controlView;
@property (nonatomic ,strong ,readonly)UIView *controlsOverlayView;
@property (nonatomic ,strong ,readonly)UIView *controlsUnderlayView;

@property (nonatomic, readonly) BOOL isFullScreen;

@end
NS_ASSUME_NONNULL_END

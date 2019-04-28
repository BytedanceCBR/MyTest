//
//  TTVPlayerFullScreenState.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/13.
//

#import <UIKit/UIKit.h>
#import "TTVReduxProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVFullScreenState : NSObject<TTVReduxStateProtocol, NSCopying>

/// 界面应该处于全屏状态, 竖屏或者横屏全屏，这里描述不准确 ？？？？TODO
@property (nonatomic, getter=isFullScreen) BOOL fullScreen;
//@property (nonatomic) BOOL supportsPortaitFullScreen; // ?? TODO
//@property (nonatomic) BOOL isTransitioning; // ?? TODO

//@property (nonatomic) UIDeviceOrientation deviceOrientation;
@property (nonatomic) BOOL enableRotate;

@end

NS_ASSUME_NONNULL_END

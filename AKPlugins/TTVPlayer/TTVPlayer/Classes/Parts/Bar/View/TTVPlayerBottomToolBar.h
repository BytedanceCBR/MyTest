//
//  TTVPlayerNavigationBar.h
//  TTVPlayer
//
//  Created by lisa on 2019/2/7.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerDefine.h"
#import "TTVTouchIgoringView.h"
#import "TTVPlayerCustomPartDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 系统自带的navigationBar，有约束布局，高度修改困难；所以放弃系统自带的 bar，采用自定义 bar
 */
@interface TTVPlayerBottomToolBar : TTVTouchIgoringView<TTVBarProtocol>


@end

NS_ASSUME_NONNULL_END

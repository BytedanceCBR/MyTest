//
//  TTSharePanelTransformMessage.h
//  TTShareService
//
//  Created by lishuangyang on 2017/9/7.
//  Copyright © 2017年 muhuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTMessageCenter.h"

typedef void(^TTSharePanelFullScreenTransformHandler)(BOOL isFullScreen, UIInterfaceOrientation orientation );
@protocol TTSharePanelTransformMessage <NSObject>

@optional
- (void)message_sharePanelIfNeedTransformWithBlock:(TTSharePanelFullScreenTransformHandler )fullScreenTransformHandler;

- (void)message_sharePanelIfNeedTransform:(BOOL)isMovieFullScreen;

- (void)message_sharePanelNeedMovieViewExistFullScreen;

@end

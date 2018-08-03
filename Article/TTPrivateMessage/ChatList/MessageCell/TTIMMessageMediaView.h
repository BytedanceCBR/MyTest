//
//  TTIMMessageMediaView.h
//  EyeU
//
//  Created by matrixzk on 10/20/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTIMMessage;
@interface TTIMMessageMediaView : UIView

- (void)setupMediaViewWithMessage:(TTIMMessage *)message;
- (void)refreshSendProgressViewWithProgress:(CGFloat)newProgress;

@end

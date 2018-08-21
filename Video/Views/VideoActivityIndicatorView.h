//
//  VideoActivityIndicatorView.h
//  Video
//
//  Created by 于 天航 on 12-8-16.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSActivityIndicatorView.h"

@interface VideoActivityIndicatorView : SSActivityIndicatorView

+ (VideoActivityIndicatorView *)sharedView;
- (void)showWithMessage:(NSString *)message duration:(CGFloat)displayDuration;

@end

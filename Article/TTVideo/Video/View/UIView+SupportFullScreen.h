//
//  UIView+SupportFullScreen.m.h
//  Article
//
//  Created by lishuangyang on 2017/7/7.
//
//

#import <UIKit/UIKit.h>

@interface UIView (supportFullScreen)

- (void)addTransFormIsFullScreen:(BOOL)isFullScreen;

+ (UIView *)defaultParentView;

- (void)changeFrameIsFullScreen:(BOOL)isFullScreen;

@end

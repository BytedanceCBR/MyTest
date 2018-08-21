//
//  UIButton+TouchArea.h
//  DailyPopThreads
//
//  Created by zhuchao on 13-7-15.
//  Copyright (c) 2013年 Cencent. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIButton (TouchArea)

@property(nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

@end

@interface UIButton (BlockToSelector)
/**
 *  Button提供Block
 *
 *  @param target target
 *  @param block block
 *  @param controlEvents controlEvents
 */
- (void)addTarget:(id)target withActionBlock:(void(^)(void))block forControlEvent:(UIControlEvents)controlEvents;

@end


typedef NS_ENUM(NSUInteger, TTButtonEdgeInsetsStyle) {
    TTButtonEdgeInsetsStyleImageLeft,
    TTButtonEdgeInsetsStyleImageRight,
    TTButtonEdgeInsetsStyleImageTop,
    TTButtonEdgeInsetsStyleImageBottom
};

@interface UIButton (TTEdgeInsets)

/**
 *  设置Button中图片与文字的距离
 *
 *  @param style style
 *  @param space space 
 */
- (void)layoutButtonWithEdgeInsetsStyle:(TTButtonEdgeInsetsStyle)style imageTitlespace:(CGFloat)space;

@end

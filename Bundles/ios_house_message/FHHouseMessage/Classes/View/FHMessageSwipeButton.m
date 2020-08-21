//
//  SwipeButton.m
//  SwipeTableView
//
//  Created by zhao on 16/8/11.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "FHMessageSwipeButton.h"

#define NULL_STRING(string) [string isEqualToString:@""] || !string

@implementation FHMessageSwipeButton

//只有title
+ (FHMessageSwipeButton *)createSwipeButtonWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor touchBlock:(TouchSwipeButtonBlock)block
{
    return [self createSwipeButtonWithTitle:title font:15 textColor:[UIColor blackColor] backgroundColor:backgroundColor  touchBlock:block];
}

+ (FHMessageSwipeButton *)createSwipeButtonWithTitle:(NSString *)title font:(CGFloat)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor touchBlock:(TouchSwipeButtonBlock)block
{
    return [self createSwipeButtonWithTitle:title font:font textColor:textColor backgroundColor:backgroundColor image:nil touchBlock:block];
}


//只有图片
+ (FHMessageSwipeButton *)createSwipeButtonWithImage:(UIImage *)image backgroundColor:(UIColor *)color touchBlock:(TouchSwipeButtonBlock)block
{
    return [self createSwipeButtonWithTitle:nil font:15 textColor:[UIColor blackColor] backgroundColor:color image:image touchBlock:block];
}

//图片、文字都有，且图片在上 文字在下
+ (FHMessageSwipeButton *)createSwipeButtonWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor image:(UIImage *)image touchBlock:(TouchSwipeButtonBlock)block
{
    return [self createSwipeButtonWithTitle:title font:15 textColor:[UIColor blackColor] backgroundColor:backgroundColor image:image touchBlock:block];
}

+ (FHMessageSwipeButton *)createSwipeButtonWithTitle:(NSString *)title font:(CGFloat)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor image:(UIImage *)image touchBlock:(TouchSwipeButtonBlock)block
{
    FHMessageSwipeButton *button = [self buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:font];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    button.backgroundColor = backgroundColor;
    button.touchBlock = block;
    
    // 算出文字的size
    // button的宽度去文字和图片两个中的最大宽度 其它值将在SwipeView中设置
    button.frame = CGRectMake(0, 0, 108, 80);
    
    return button;
}

/**
 *  防止文字太长或图片太大 导致图片或文字的位置不在中间
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.titleLabel.text && self.imageView.image)
    {
        CGFloat marginH = (self.frame.size.height - self.imageView.frame.size.height - self.titleLabel.frame.size.height)/3;
        
        //图片
        CGPoint imageCenter = self.imageView.center;
        imageCenter.x = self.frame.size.width/2;
        imageCenter.y = self.imageView.frame.size.height/2 + marginH;
        self.imageView.center = imageCenter;
        //文字
        CGRect newFrame = self.titleLabel.frame;
        newFrame.origin.x = 0;
        newFrame.origin.y = self.frame.size.height - newFrame.size.height - marginH;
        newFrame.size.width = self.frame.size.width;
        self.titleLabel.frame = newFrame;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
}

@end

//
//  SSTitleBarView.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"
/*
 *  如果需要支持旋转，需要在父View的laoutSubview中调用SSTitleBarView的adjustSelfFrame
 */

#define TitleBarHeight  44
@interface SSTitleBarView : SSViewBase

@property(nonatomic, strong, readonly) UIView * baseView;

@property(nonatomic, strong) UIView * leftView;
@property(nonatomic, strong) UIView * rightView;
@property(nonatomic, strong) UIView * centerView;

@property(nonatomic, strong) UIView * portraitBackgroundView;
@property(nonatomic, strong) UIView * landscapeBackgroundView;

@property(nonatomic, strong) UIView * portraitBottomView;
@property(nonatomic, strong) UIView * landscapeBottomView;

@property(nonatomic, assign) UIEdgeInsets titleBarEdgeInsets;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIView * bottomLineView;
@property (nonatomic, strong) UIButton * titleLabelButton;


+ (float)titleBarHeight;
- (void)showBottomShadow;
- (void)addTitleBadgeView:(UIView *)view;
- (void)setTitleText:(NSString *)title;
/*
 *  设置可拉伸的背景
 */
- (void)setBackgroundImage:(UIImage *)image;

#pragma mark -- protected
- (void)relayout;
@end

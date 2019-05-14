//
//  TTIndicatorView.h
//  test
//
//  Created by lisa on 2018/12/14.
//  Copyright © 2018 lina. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface TTVIndicatorView : UIView


/**
 对外方法，由基础方法完成功能
 显示默认3s消失的弹框
 展示在 keywindow 上, 整体居中布局
 
 @param text 文字
 @param image 图片，图片在文字的上面，分两行布局
 */
+ (instancetype)showIndicatorAudoHideWithText:(NSString * _Nonnull)text image:(UIImage * _Nullable)image;



/**
 基础方法，不能自动消失，需要调用 hide 进行消失操作
 
 @param view 添加到的 view 上，整体居中布局
 @param text 文字
 @param image 图片在文字的上面，分两行布局
 */
+ (instancetype)showIndicatorAddedToView:(UIView * _Nonnull)view
                                    text:(NSString * _Nonnull)text
                                   image:(UIImage * _Nullable)image;



/**
 基础方法，隐藏弹框, 立即消失
 
 @param view 添加到的 view 上，整体居中布局
 @param animated 是否有动画，当页面切换 dealloc 时，不应该再做动画，应该整体消失
 */
+ (void)hideForView:(UIView * _Nonnull)view animated:(BOOL)animated;


/**
 拿到view 上的 indicator
 
 @param view 添加到的 view 上，整体居中布局
 @return 添加到 view 上的 indicator
 */
+ (TTVIndicatorView * _Nullable)indicatorForView:(UIView * _Nonnull)view;


- (void)hideAnimated:(BOOL)animated;
- (void)show;



/// 隐藏提示框，可以传入此回调，因为多数弹框只是提示出来，不需要回调处理，所以把他从方法参数中移除，作为成员变量。
@property (nonatomic, copy) void (^hideCompletionBlock)(void);

/// 设置提示框展示的时间，单位：秒 s, 一般不会设置这个变量，所以也放下来了。
@property (nonatomic, assign) NSTimeInterval stayDuration;



@end

NS_ASSUME_NONNULL_END

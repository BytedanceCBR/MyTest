//
//  TTAsyncCornerImageView.h
//  Pods
//
//  Created by zhaoqin on 15/11/2016.
//
//

#import <UIKit/UIKit.h>

/**
 * TTAsyncCornerImageView
 */

@class SSThemedLabel;

@interface TTAsyncCornerImageView : UIImageView

/**
 圆角半径
 */
@property (nonatomic, assign) CGFloat cornerRadius;

/**
 占位图名字
 */
@property (nonatomic, strong) NSString *placeholderName;

/**
 边框宽度
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 边框颜色
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 遮罩颜色
 */
@property (nonatomic, strong) UIColor *coverColor;

/**
 初始化方法

 @param frame 控件的frame
 @param allowCorner 是否是圆角头像
 @return 控件对象
 */
- (instancetype)initWithFrame:(CGRect)frame allowCorner:(BOOL)allowCorner;

/**
 添加响应点击事件
 
 @param target 处理点击事件的对象
 @param action 调用的方法
 */
- (void)addTouchTarget:(id)target action:(SEL)action;

/**
 展示网络下载的头像
 
 @param urlString 头像的URL
 */
- (void)tt_setImageWithURLString:(NSString *)urlString;

/**
 TTNewCommentCell中夜间模式点击cell会清楚所有subview的background，需要重新设置夜间遮罩
 */
- (void)refreshNightCoverView;

/**
 当占位图不用UIImageView时，设置其显示背景色及文字

 @param text 文案
 @param fontSize 字体大小
 @param textColorThemeKey 字体颜色
 @param backgroundColorThemeKey 背景颜色Key
 @param backgroundColors 背景颜色数组
 */
- (void)tt_setImageText:(NSString *)text fontSize:(CGFloat)fontSize textColorThemeKey:(NSString *)textColorThemeKey backgroundColorThemeKey:(NSString *)backgroundColorThemeKey backgroundColors:(NSArray *)backgroundColors;

- (void)setFrame:(CGRect)frame;

@end

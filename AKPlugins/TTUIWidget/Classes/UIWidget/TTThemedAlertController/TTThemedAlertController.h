//
//  TTThemedAlertController.h
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/10.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTThemedAlertControllerCommon.h"

//默认值
#define TTThemedAlertDefaultTitleFontSize    17.0f
#define TTThemedAlertDefaultSubTitleFontSize 13.0f

//自定义的属性，可添加
#define TTThemedTitleFontKey    @"TTThemedTitleFontKey"
#define TTThemedSubTitleFontKey @"TTThemedSubTitleFontKey"

@interface TTThemedAlertController : UIViewController

//使用正标题和副标题初始化
- (nonnull instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredType:(TTThemedAlertControllerType)type;

//添加左上角图片
- (void)addBannerImage:(nonnull NSString *)bundleImageName;

//添加按钮
- (void)addActionWithTitle:(nullable NSString *)title actionType:(TTThemedAlertActionType)actionType actionBlock:(nullable TTThemedAlertActionBlock)actionBlock;

//添加textField（可连续添加，显示顺序同添加顺序）
- (void)addTextFieldWithConfigurationHandler:(nullable TTThemedAlertTextFieldActionBlock)actionBlock;

//添加textView（只支持添加一个）
- (void)addTextViewWithConfigurationHandler:(nullable TTThemedAlertTextViewActionBlock)actionBlock;

//添加UI自定义属性
- (void)addTTThemedAlertControllerUIConfig:(nullable NSDictionary *)configuration;

//获取唯一的UITextView
- (nullable UITextView *)uniqueTextView;

//指定presentingViewController并显示alert、actionSheet
- (void)showFrom:(nonnull UIViewController *)viewController animated:(BOOL)animated;

//键盘弹起状态下弹出alertController
- (void)showFrom:(nonnull UIViewController *)viewController animated:(BOOL)animated keyboardPresentingWithFrameTop:(CGFloat)keyboardFrameTop;

//指定presentingViewController并显示popOver（iPad only）
- (void)showFrom:(nonnull UIViewController *)viewController sourceView:(nullable UIView *)sourceView sourceRect:(CGRect)sourceRect sourceBarButton:(nullable UIBarButtonItem *)barButtonItem animated:(BOOL)animated;

@end

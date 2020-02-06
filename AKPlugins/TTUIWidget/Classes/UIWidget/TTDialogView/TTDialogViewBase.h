//
//  TTFMAudioDialogView.h
//  Article
//
//  Created by Jesse He on 2018/5/25.
//

#import "SSThemed.h"
#import <UIKit/UIKit.h>

@class TTDialogViewBase;

/**
 对话框退出的触发区域

 - TTDialogViewBaseExitAreaCloseButton: 关闭按钮区域
 - TTDialogViewBaseExitAreaBlank: 空白区域
 */
typedef NS_ENUM(NSUInteger, TTDialogViewBaseExitArea) {
    TTDialogViewBaseExitAreaCloseButton,
    TTDialogViewBaseExitAreaBlank
};

/**
 确认回调

 @param dialogView 弹窗实例
 */
typedef void(^TTDialogViewBaseConfirmHandler)(TTDialogViewBase *dialogView);

/**
 取消回调

 @param dialogView 弹窗实例
 */
typedef void(^TTDialogViewBaseCancelHandler)(TTDialogViewBase *dialogView);

/**
 取消回调
 
 @param dialogView 弹窗实例
 @param exitArea 对话框退出的触发区域
 */
typedef void(^TTDialogViewBaseCancelHandlerWithExitArea)(TTDialogViewBase *dialogView, TTDialogViewBaseExitArea exitArea);

/**
 多选项按钮确认回调

 @param dialogView 弹窗实例
 @param selectedIndex 选项索引
 */
typedef void(^TTDialogViewBaseActionHandler)(TTDialogViewBase *dialogView, NSInteger selectedIndex);

/*
 * TTDialogViewBase 弹窗容器
 * 灰色透明底，红色确认按钮，右上角是"x"关闭按钮;中间是弹窗的内容区域，调用addDialogContentView添加自定义内容视图
 * 弹窗的宽高依赖于自定义内容视图的宽高。宽度=自定义内容视图的宽度，高度=自定义内容视图的高度+顶部固定高+底部固定高
 */

@interface TTDialogViewBase : UIView

/**
 存放所有DialogView相关的图片资源文件的Bundle，如果其他库依赖本类的资源，使用该bundle获取
 */
@property (nonatomic, class, readonly) NSBundle *resourceBundle;

/*
 * 弹窗容器
 */
@property (nonatomic, strong, readonly) SSThemedView *containerView;

/*
 * initDialogViewWithTitle 弹窗初始化
 * title : 弹窗确认按钮标题
 * confirmHandler: 弹窗确认点击回调
 * cancelHandler: 弹窗点击关闭按钮回调
 */
- (instancetype)initDialogViewWithTitle:(NSString *)title
                         confirmHandler:(TTDialogViewBaseConfirmHandler)confirmHandler
                          cancelHandler:(TTDialogViewBaseCancelHandler)cancelHandler;

/*
 * initDialogViewWithTitle 弹窗初始化
 * title : 弹窗确认按钮标题
 * confirmHandler: 弹窗确认点击回调
 * cancelHandler: 弹窗点击关闭按钮回调
 */
- (instancetype)initDialogViewWithTitle:(NSString *)title
                         confirmHandler:(TTDialogViewBaseConfirmHandler)confirmHandler
                          cancelHandlerWithExitArea:(TTDialogViewBaseCancelHandlerWithExitArea)cancelHandlerWithExitArea;

/**
 弹窗初始化方法
 
 @param actions 动作名数组
 @param actionsDetail 动作详情字典 [action: detail]
 @param actionHandler 动作回调
 @param cancelHandler 取消回调
 @return 弹窗视图实例
 */
- (instancetype)initDialogViewWithActions:(NSArray<NSString *> *)actions
                            actionsDetail:(NSDictionary<NSString *, NSDictionary *> *)actionsDetail
                            actionHandler:(TTDialogViewBaseActionHandler)actionHandler
                            cancelHandler:(TTDialogViewBaseCancelHandler)cancelHandler;

/**
 弹窗初始化方法
 
 @param actions 动作名数组
 @param actionsDetail 动作详情字典 [action: detail]
 @param actionHandler 动作回调
 @param cancelHandler 取消回调
 @return 弹窗视图实例
 */
- (instancetype)initDialogViewWithActions:(NSArray<NSString *> *)actions
                            actionsDetail:(NSDictionary<NSString *, NSDictionary *> *)actionsDetail
                            actionHandler:(TTDialogViewBaseActionHandler)actionHandler
                            cancelHandlerWithExitArea:(TTDialogViewBaseCancelHandlerWithExitArea)cancelHandlerWithExitArea;

//添加的时候，view必须有确定宽高
- (void)addDialogContentView:(UIView *)view;

- (void)addDialogContentView:(UIView *)view atTop:(BOOL)top;

//弹窗的展示和关闭
- (void)show;
- (void)hide;

@end

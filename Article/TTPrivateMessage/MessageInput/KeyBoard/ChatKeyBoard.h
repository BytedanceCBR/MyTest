//
//  ChatKeyBoard.h
//  FaceKeyboard
//
//  Company：     SunEee
//  Blog:        devcai.com
//  Communicate: 2581502433@qq.com

//  Created by ruofei on 16/3/29.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatToolBarItem.h"
#import "ChatKeyBoardMacroDefine.h"
#import "ChatToolBar.h"

@class ChatKeyBoard;
@protocol ChatKeyBoardDelegate <NSObject>
@optional

/**
 *  输入状态
 */
- (void)chatKeyBoardTextViewDidBeginEditing:(UITextView *)textView;
- (void)chatKeyBoardSendText:(NSString *)text;
- (void)chatKeyBoardTextViewDidChange:(UITextView *)textView;

///...
// 左侧图片选取按钮点击
- (void)chatKeyBoardImagePickedButtonPressed;

@end

/**
 *  数据源
 */
@protocol ChatKeyBoardDataSource <NSObject>

@required
- (NSArray<ChatToolBarItem *> *)chatKeyBoardToolbarItems;

@end

@interface ChatKeyBoard : UIView

/**
 *  默认是导航栏透明，或者没有导航栏
 */
+ (instancetype)keyBoard;

/**
 *  当导航栏不透明时（强制要导航栏不透明）
 *
 *  @param translucent 是否透明
 *
 *  @return keyboard对象
 */
+ (instancetype)keyBoardWithNavgationBarTranslucent:(BOOL)translucent;


/**
 *  直接传入父视图的bounds过来
 *
 *  @param bounds 父视图的bounds，一般为控制器的view
 *
 *  @return keyboard对象
 */
+ (instancetype)keyBoardWithParentViewBounds:(CGRect)bounds;

/**
 *
 *  设置关联的表
 */
@property (nonatomic, weak) UITableView *associateTableView;

@property (nonatomic, weak) id<ChatKeyBoardDataSource> dataSource;
@property (nonatomic, weak) id<ChatKeyBoardDelegate> delegate;

@property (nonatomic, readonly, strong) ChatToolBar *chatToolBar;

/**
 *  placeHolder内容
 */
@property (nonatomic, copy) NSString * placeHolder;
/**
 *  placeHolder颜色
 */
@property (nonatomic, strong) UIColor *placeHolderColor;

// 是否显示左侧图片选取按钮
@property (nonatomic, assign) BOOL allowImage;

@property (nonatomic, assign) BOOL shouldTableViewContentScrollToBottomWhenKeybordUp;

/**
 *  键盘弹出
 */
- (void)keyboardUp;

/**
 *  键盘收起
 */
- (void)keyboardDown;

@end

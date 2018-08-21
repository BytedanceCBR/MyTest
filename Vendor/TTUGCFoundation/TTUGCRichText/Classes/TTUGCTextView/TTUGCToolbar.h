//
//  TTUGCToolbar.h
//  Article
//  发布器底部工具栏
//
//  Created by Jiyee Sheng on 31/08/2017.
//
//


#import "SSThemed.h"


@class TTUGCEmojiInputView;

@protocol TTUGCToolbarDelegate <NSObject>

@optional

- (void)toolbarDidClickKeyboardButton:(BOOL)switchToKeyboardInput;
- (void)toolbarDidClickAtButton;
- (void)toolbarDidClickHashtagButton;
- (void)toolbarDidClickEmojiButton:(BOOL)switchToEmojiInput;

@end

@protocol TTUGCToolbarProtocol <NSObject>

/**
 * 强制设置 keyboard 按钮为键盘状态
 */
- (void)markKeyboardAsVisible;

@end

@interface TTUGCToolbar : SSThemedView <TTUGCToolbarProtocol>

@property (nonatomic, weak) id <TTUGCToolbarDelegate> delegate;

@property (nonatomic, strong, readonly) TTUGCEmojiInputView *emojiInputView;

@property (nonatomic, assign) BOOL banAtInput; // 是否支持 at 功能
@property (nonatomic, assign) BOOL banHashtagInput; // 是否支持添加话题
@property (nonatomic, assign) BOOL banEmojiInput; // 是否支持表情输入

@property (nonatomic, assign) BOOL emojiInputViewVisible; // 表情输入框是否可见

/**
 * 强制设置 keyboard 按钮为键盘状态
 */
- (void)markKeyboardAsVisible;

@end

//
//  TTUGCToolbar.h
//  Article
//  发布器底部工具栏
//
//  Created by Jiyee Sheng on 31/08/2017.
//
//


#import "SSThemed.h"
#import "TTUGCEmojiInputView.h"

@protocol TTUGCToolbarDelegate <NSObject>

@optional

- (void)toolbarDidClickKeyboardButton:(BOOL)switchToKeyboardInput;
- (void)toolbarDidClickLongText;
- (void)toolbarDidClickAtButton;
- (void)toolbarDidClickHashtagButton;
- (void)toolbarDidClickEmojiButton:(BOOL)switchToEmojiInput;
- (void)toolbarDidClickShoppingButton;

@end

@protocol TTUGCToolbarProtocol <NSObject>

/**
 * 强制设置 keyboard 按钮为键盘状态
 */
- (void)markKeyboardAsVisible;

@end

@interface TTUGCToolbar : SSThemedView <TTUGCToolbarProtocol>

@property (nonatomic, weak) id <TTUGCToolbarDelegate> delegate;

@property (nonatomic, strong) TTUGCEmojiInputView *emojiInputView;
@property (nonatomic, strong) SSThemedButton *keyboardButton;
@property (nonatomic, strong) SSThemedButton *emojiButton;

@property (nonatomic, assign) BOOL banLongText; // 是否支持长文
@property (nonatomic, assign) BOOL banAtInput; // 是否支持 at 功能
@property (nonatomic, assign) BOOL banHashtagInput; // 是否支持添加话题
@property (nonatomic, assign) BOOL banEmojiInput; // 是否支持表情输入
@property (nonatomic, assign) BOOL banShoppingInput; // 是否支持电商
@property (nonatomic, assign) BOOL banPicInput; // 是否支持图片

@property (nonatomic, assign) BOOL emojiInputViewVisible; // 表情输入框是否可见

- (void)layoutViewWithFrame:(CGRect)newFrame;
- (void)layoutToolbarViewWithOrigin:(CGPoint)origin;
/**
 * 强制设置 keyboard 按钮为键盘状态
 */
- (void)markKeyboardAsVisible;

// 图片按钮点击blk
@property (nonatomic, copy)     dispatch_block_t       picButtonClkBlk;

@end

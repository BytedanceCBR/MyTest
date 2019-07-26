//
//  FHWenDaToolbar.h
//  Article
//
//


#import "SSThemed.h"
#import "TTUGCToolbar.h"

@interface FHWenDaToolbar : SSThemedView <TTUGCToolbarProtocol>

@property (nonatomic, weak) id <TTUGCToolbarDelegate> delegate;

@property (nonatomic, strong, readonly) TTUGCEmojiInputView *emojiInputView;

@property (nonatomic, assign) BOOL banLongText; // 是否支持长文
@property (nonatomic, assign) BOOL banAtInput; // 是否支持 at 功能
@property (nonatomic, assign) BOOL banHashtagInput; // 是否支持添加话题
@property (nonatomic, assign) BOOL banEmojiInput; // 是否支持表情输入
@property (nonatomic, assign) BOOL banShoppingInput; // 是否支持电商

@property (nonatomic, assign) BOOL emojiInputViewVisible; // 表情输入框是否可见

- (void)layoutViewWithFrame:(CGRect)newFrame;

/**
 * 强制设置 keyboard 按钮为键盘状态
 */
- (void)markKeyboardAsVisible;

// 图片按钮点击blk
@property (nonatomic, copy)     dispatch_block_t       picButtonClkBlk;

@end
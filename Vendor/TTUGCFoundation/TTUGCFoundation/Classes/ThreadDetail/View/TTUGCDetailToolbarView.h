//
//  TTUGCDetailToolbarView.h
//  Article
//
//  Created by 王霖 on 16/12/12.
//
//

#import <SSThemed.h>

@class TTAlphaThemedButton;
@class TTDiggButton;

extern CGFloat TTUGCDetailGetToolbarHeight(void);

NS_ASSUME_NONNULL_BEGIN
@interface TTUGCDetailToolbarView : SSThemedView

@property (nonatomic, strong, readonly) TTAlphaThemedButton *writeCommentButton;
@property (nonatomic, strong, readonly) TTAlphaThemedButton *emojiButton;
@property (nonatomic, strong, readonly) TTDiggButton *diggButton;
@property (nonatomic, strong, readonly) TTAlphaThemedButton *shareButton;

@property (nonatomic, assign) BOOL banEmojiInput; // 是否支持表情输入

@end
NS_ASSUME_NONNULL_END


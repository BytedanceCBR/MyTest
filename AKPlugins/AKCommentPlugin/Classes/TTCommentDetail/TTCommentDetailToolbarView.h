//
//  TTCommentDetailToolbarView.h
//  Article
//
//  Created by Jiyee Sheng on 21/01/2018.
//
//


#import <TTThemed/SSThemed.h>


@class TTAlphaThemedButton;

@interface TTCommentDetailToolbarView : SSThemedView

@property (nonatomic, strong, readonly) TTAlphaThemedButton *writeButton;   // 写评论输入框
@property (nonatomic, strong, readonly) TTAlphaThemedButton *emojiButton;   // 表情按钮
@property (nonatomic, strong, readonly) TTAlphaThemedButton *diggButton;     // 点赞按钮
@property (nonatomic, strong, readonly) TTAlphaThemedButton *shareButton;   // 分享按钮

@property (nonatomic, assign) BOOL banEmojiInput; // 是否支持表情输入

extern CGFloat TTCommentDetailToolbarViewHeight(void);

@end

//
//  TTCommentFunctionView.h
//  Article
//
//  Created by ranny_90 on 2017/11/13.
//

#import <TTThemed/SSThemed.h>
#import <TTUGCFoundation/TTUGCToolbar.h>


@protocol TTCommentFunctionDelegate <TTUGCToolbarDelegate>

@optional
- (void)toolbarDidClickAtButton;
- (void)toolbarDidClickEmojiButton:(BOOL)switchToEmojiInput;
- (void)toolBarDidClickRepostButton;
- (void)toolbarNeedHiddenStatusUpdate:(BOOL)isNeedToHidden;

@end


typedef NS_ENUM(NSUInteger, TTCommentFunctionEmojiButtonState) {
    TTCommentFunctionEmojiButtonStateEmoji = 1,
    TTCommentFunctionEmojiButtonStateKeyboard = 2,
};

@interface TTCommentFunctionView : SSThemedView

@property (nonatomic, weak) id <TTCommentFunctionDelegate> delegate;

@property (nonatomic, assign) TTCommentFunctionEmojiButtonState emojiButtonState;

@property (nonatomic, strong) NSString *repostTitle;

//关于评论并转发
@property (nonatomic, assign) BOOL banCommentRepost;

@property (nonatomic, assign) BOOL banEmojiInput;

/**
 * 是否勾选中评论并转发
 * @return 返回选中状态，如果勾选项隐藏则返回 NO
 */
- (BOOL)isCommentRepostChecked;

@end

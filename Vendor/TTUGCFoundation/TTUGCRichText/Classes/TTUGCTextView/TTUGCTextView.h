//
//  TTUGCTextView.h
//  Article
//  UGC 发布器输入框，支持 @ 功能，Emoji 表情输入
//
//  Created by Jiyee Sheng on 30/08/2017.
//
//


#import "SSThemed.h"
#import "HPGrowingTextView.h"
#import "TTUGCEmojiInputView.h"

@class TTUGCTextView;
@class TTRichSpanText;


@protocol TTUGCTextViewDelegate <NSObject>

@optional

- (BOOL)textViewShouldBeginEditing:(TTUGCTextView *)textView;
- (BOOL)textViewShouldEndEditing:(TTUGCTextView *)textView;

- (void)textViewDidBeginEditing:(TTUGCTextView *)textView;
- (void)textViewDidEndEditing:(TTUGCTextView *)textView;

- (BOOL)textView:(TTUGCTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(TTUGCTextView *)textView;

- (void)textView:(TTUGCTextView *)textView willChangeHeight:(float)height withDiffHeight:(CGFloat)diffHeight;
- (void)textView:(TTUGCTextView *)textView didChangeHeight:(float)height withDiffHeight:(CGFloat)diffHeight;

- (void)textViewDidChangeSelection:(TTUGCTextView *)textView;
- (BOOL)textViewShouldReturn:(TTUGCTextView *)textView;

- (void)textViewDidInputTextAt:(TTUGCTextView *)textView;
- (void)textViewDidInputTextHashtag:(TTUGCTextView *)textView;

@end

@interface TTUGCTextView : SSThemedView <TTUGCEmojiInputViewDelegate>

@property (nonatomic, weak) id <TTUGCTextViewDelegate> delegate;

@property (nonatomic, strong, readonly) HPGrowingTextView *internalGrowingTextView;

/**
 * 支持直接设置 richSpanText，用于富文本内容的填充
 * 获取 richSpanText 只能获取 copy 之后的副本，暂不支持在外部直接修改 richSpanText
 * 如果有修改的需求，修改完执行 setRichSpanText:
 */
@property (nonatomic, strong) TTRichSpanText *richSpanText;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy, readonly) NSAttributedString *attributedText;

/**
 * 字体大小，默认采用跟帖子一致的字体大小
 */
@property (nonatomic, assign) CGFloat textViewFontSize;

/**
 * 纯文本输入样式，高亮样式在内部设置，外部暂不可控
 */
@property (nonatomic, copy) NSDictionary *typingAttributes;

/**
 * 键盘日夜间状态
 */
@property (nonatomic, assign) UIKeyboardAppearance keyboardAppearance;

/**
 * 控制 HPGrowingTextView 和 UITextView 之间的 insets
 */
@property (nonatomic, assign) UIEdgeInsets contentInset;

/**
 * Inset the text container's layout area within the text view's content area
 */
@property (nonatomic, assign) UIEdgeInsets textContainerInset;

/**
 * 光标选中位置
 */
@property (nonatomic, assign) NSRange selectedRange;

/**
 * 来源统计参数
 */
@property (nonatomic, copy) NSString *source;

/**
 * 键盘弹出状态，埋点参数
 */
@property (nonatomic, assign, readonly) BOOL keyboardVisible;

/**
 * 是否禁用 at 人选择，将不响应用户手动输入 @ 字符，默认 NO
 */
@property (nonatomic, assign) BOOL isBanAt;

/**
 * 是否禁用话题选择，将不响应用户手动输入 # 字符，默认 NO
 */
@property (nonatomic, assign) BOOL isBanHashtag;

/**
 * 是否用户手动输入了 @ 字符
 */
@property (nonatomic, assign) BOOL didInputTextAt;

/**
 * 是否用户手动输入了 # 字符
 */
@property (nonatomic, assign) BOOL didInputTextHashtag;

/**
 * 刷新 placeholder 状态，并触发 textViewDidChange 回调事件
 */
- (void)refreshTextViewUI;

/**
 * 替换 richSpanText，用于外部强制插入或替换内容，如 @ 和 # 内容插入
 * @param richSpanText 用于替换内容的富文本
 * @param range 替换位置，length == 0 表示插入，length > 0 表示替换
 */
- (void)replaceRichSpanText:(TTRichSpanText *)richSpanText inRange:(NSRange)range;

@end

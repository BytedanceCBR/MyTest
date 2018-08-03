//
//  TTUGCTextView.m
//  Article
//
//  Created by Jiyee Sheng on 30/08/2017.
//
//

#import "TTUGCTextView.h"
#import "TTUGCEmojiTextAttachment.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Emoji.h"
#import "TTUGCEmojiParser.h"
#import "HPTextViewInternal.h"
#import "UITextView+TTAdditions.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"

@interface TTUGCTextView () <HPGrowingTextViewDelegate>

@property (nonatomic, assign) BOOL didInputTextBackspaceOrAnythingElse;

@property (nonatomic, assign) CGFloat diffHeight;

@property (nonatomic, assign) CGFloat fontSize;

@end

@implementation TTUGCTextView {
    TTRichSpanText *_richSpanText; // 内部使用 TTRichSpanText 使用此变量，因为重写了 richSpanText 方法执行 copy 操作。
}

@dynamic richSpanText;

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        CGRect rect = frame;
        rect.origin.x = 0;
        rect.origin.y = 0;

        self.isBanAt = NO;
        self.isBanHashtag = NO;

        HPGrowingTextView *internalGrowingTextView = [[HPGrowingTextView alloc] initWithFrame:rect];
        internalGrowingTextView.font = [self tt_fontOfSize:self.textViewFontSize];
        internalGrowingTextView.delegate = self;
        internalGrowingTextView.contentInset = UIEdgeInsetsZero;
        internalGrowingTextView.contentMode = UIViewContentModeRedraw;
        [self addSubview:internalGrowingTextView];

        // 禁用表情和字符拖拽
        if (@available(iOS 11.0 , *)) {
            internalGrowingTextView.internalTextView.textDragInteraction.enabled = NO;
        }

        _internalGrowingTextView = internalGrowingTextView;
        self.typingAttributes = self.customTypingAttributes;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardVisibleChanged:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardVisibleChanged:) name:UIKeyboardWillHideNotification object:nil];
    }

    return self;
}

- (void)dealloc {

    _internalGrowingTextView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (TTRichSpanText *)richSpanText {
    return [_richSpanText copy];
}

- (void)setRichSpanText:(TTRichSpanText *)richSpanText {
    _richSpanText = richSpanText;

    // 根据构造的 richSpanText 渲染 UITextView
    NSAttributedString *attributedString = [self attributedStringFromRichSpanText:richSpanText];
    self.attributedText = attributedString;
    self.selectedRange = NSMakeRange(attributedString.length, 0);

    [self refreshTextViewUI];

    [self.internalGrowingTextView refreshHeight];
}

- (NSString *)text {
    return [TTUGCEmojiParser stringify:self.internalGrowingTextView.attributedText];
}

- (void)setText:(NSString *)text {
    TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:nil];
    self.richSpanText = richSpanText;
}

- (NSAttributedString *)attributedText {
    return self.internalGrowingTextView.attributedText;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    self.internalGrowingTextView.attributedText = attributedText;
}

- (void)setTypingAttributes:(NSDictionary *)typingAttributes {
    self.internalGrowingTextView.internalTextView.typingAttributes = typingAttributes;

    // 因为 typingAttributes 会根据当前 cursor 所在的 attributedString 样式变化，故需要保存 textAttributes 来处理复制粘贴的问题
    ((HPTextViewInternal *)self.internalGrowingTextView.internalTextView).textAttributes = typingAttributes;
}

- (NSDictionary *)typingAttributes {
    return ((HPTextViewInternal *)self.internalGrowingTextView.internalTextView).textAttributes ?: self.customTypingAttributes;
}

- (UIEdgeInsets)contentInset {
    return self.internalGrowingTextView.contentInset;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    self.internalGrowingTextView.contentInset = contentInset;
}

- (UIEdgeInsets)textContainerInset {
    return self.internalGrowingTextView.internalTextView.textContainerInset;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    self.internalGrowingTextView.internalTextView.textContainerInset = textContainerInset;
}

- (NSRange)selectedRange {
    return self.internalGrowingTextView.selectedRange;
}

- (void)setSelectedRange:(NSRange)selectedRange {
    self.internalGrowingTextView.selectedRange = selectedRange;
}

- (CGFloat)textViewFontSize {
    if (_fontSize == 0) {
        CGFloat size = 0;
        switch ([TTDeviceHelper getDeviceType]) {
            case TTDeviceModePad:
            case TTDeviceMode736:
            case TTDeviceMode812:
            case TTDeviceMode667: size = 17.f; break;
            case TTDeviceMode568:
            case TTDeviceMode480: size = 15.f; break;
        }

        _fontSize = size;
    }

    return _fontSize;
}

- (void)setTextViewFontSize:(CGFloat)textViewFontSize {
    _fontSize = textViewFontSize;

    self.internalGrowingTextView.font = [self tt_fontOfSize:textViewFontSize];
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
    self.internalGrowingTextView.internalTextView.keyboardAppearance = keyboardAppearance;
}

- (UIKeyboardAppearance)keyboardAppearance {
    return self.internalGrowingTextView.internalTextView.keyboardAppearance;
}

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];

    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        [self.delegate textViewDidBeginEditing:self];
    }

    return [self.internalGrowingTextView becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];

    return [self.internalGrowingTextView resignFirstResponder];
}

- (BOOL)isFirstResponder {
    return [self.internalGrowingTextView isFirstResponder];
}

- (void)refreshTextViewUI {
    [self.internalGrowingTextView.internalTextView showOrHidePlaceHolderTextView];

    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegate textViewDidChange:self];
    }
}

- (void)replaceRichSpanText:(TTRichSpanText *)richSpanText inRange:(NSRange)range {
    // Translate location of NSAttributedString -> location of TTRichSpanText (NSString)
    NSUInteger cursorBegin = [self transformIndexOfAttributedString:self.attributedText withIndex:range.location];

    // Remove selected text
    if (NSMaxRange(range) <= self.attributedText.length && range.length > 0) {
        NSUInteger cursorEnd = [self transformIndexOfAttributedString:self.attributedText withIndex:(range.location + range.length)];
        [_richSpanText replaceCharactersInRange:NSMakeRange(cursorBegin, cursorEnd - cursorBegin) withText:@""];
    }

    // Insert text
    [_richSpanText insertRichSpanText:richSpanText atIndex:cursorBegin];

    // convert TTRichSpanText -> NSAttributedString
    self.attributedText = [self attributedStringFromRichSpanText:_richSpanText];

    // Reset cursor
    self.selectedRange = NSMakeRange(range.location + richSpanText.text.length, 0);

    // 这里不能触发 textViewDidChange 方法，因为没有做到数据驱动，只能手动刷新...
//    [self.inputTextView textViewDidChange:self.inputTextView];

    // Scroll to cursor position
    [self.internalGrowingTextView scrollRangeToVisible:self.internalGrowingTextView.selectedRange];

    // Reset placeholder and call textViewDidChange delegate method
    [self refreshTextViewUI];

    [self.internalGrowingTextView refreshHeight];
}

#pragma mark - UIKeyboardNotification

- (void)keyboardVisibleChanged:(NSNotification *)notification {
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        _keyboardVisible = YES;
    } else {
        _keyboardVisible = NO;
    }
}


#pragma mark - HPGrowingTextViewDelegate

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        return [self.delegate textViewShouldBeginEditing:self];
    } else {
        return YES;
    }
}

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
        return [self.delegate textViewShouldEndEditing:self];
    } else {
        return YES;
    }
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        [self.delegate textViewDidBeginEditing:self];
    }
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
        [self.delegate textViewDidEndEditing:self];
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 重置 typingAttributes，保证输入文字颜色正确，否则受插入的 attributedString 影响
    self.internalGrowingTextView.internalTextView.typingAttributes = self.typingAttributes;

    // 优先处理 @ 动作
    if (!self.isBanAt && [text isEqualToString:@"@"]) {

        if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidInputTextAt:)]) {
            [self.delegate textViewDidInputTextAt:self];
            self.didInputTextAt = YES;
            return NO;
        }

        self.didInputTextAt = NO;
    }

    // 优先处理 # 动作
    if (!self.isBanHashtag && [text isEqualToString:@"#"]) {


        if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidInputTextHashtag:)]) {
            [self.delegate textViewDidInputTextHashtag:self];

            self.didInputTextHashtag = YES;
            return NO;
        }

        self.didInputTextHashtag = NO;
    }

    // 处理键盘删除按钮
    self.didInputTextBackspaceOrAnythingElse = [text isEqualToString:@""] || text.length > 0 || range.length > 0;

    if (self.delegate && [self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate textView:self shouldChangeTextInRange:range replacementText:text];
    }

    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {

    // 优先处理 @ 和 # 动作

//    NSLog(@"textViewDidChange: %@ %@", self.text, NSStringFromRange(self.selectedRange));

    self.didInputTextBackspaceOrAnythingElse = NO;

    NSUInteger originCursor = self.selectedRange.location;

    NSUInteger cursor = [self transformIndexOfAttributedString:self.attributedText withIndex:originCursor]; // 重置 cursor

    NSString *originText = _richSpanText.text;
    NSString *currentText = self.text;
    NSInteger offset = currentText.length - originText.length;
    NSUInteger start = cursor;
    if (offset > 0) {
        start -= offset;
    }

    // 处理 Undo 事件
    if (cursor == ULONG_MAX || start > originText.length || start > currentText.length) {
        return;
    }

    NSString *commonPrefix = [[originText substringToIndex:start] commonPrefixWithString:[currentText substringToIndex:start] options:NSLiteralSearch];
    NSRange insertedRange = NSMakeRange([commonPrefix length], cursor - [commonPrefix length]);
    NSRange deletedRange = NSMakeRange([commonPrefix length], cursor - [commonPrefix length] - offset);
//    NSLog(@"replace %@ %@ with %@", NSStringFromRange(deletedRange), [_richSpanText.text substringWithRange:deletedRange], [currentText substringWithRange:insertedRange]);
    NSString *replaceText = [currentText substringWithRange:insertedRange];
    NSArray *oldLinks = _richSpanText.richSpans.links;
    NSArray <TTRichSpanLink *> *brokenLinks = [_richSpanText replaceCharactersInRange:deletedRange withText:replaceText];
    if (brokenLinks.count == 1) {
        TTRichSpanLink *link = brokenLinks.firstObject;

        //Delete Last Character In Link
        if (deletedRange.location + deletedRange.length == link.start + link.length && deletedRange.length == 1 && isEmptyString(replaceText)) {
            NSRange brokenRange = NSMakeRange(link.start, link.length - 1);
            [_richSpanText replaceCharactersInRange:brokenRange withText:replaceText];
        }
    }
    NSArray *newLinks = _richSpanText.richSpans.links;

    // 如果 links 发生了变化, 就重置样式和 cursor
    if (![oldLinks isEqualToArray:newLinks]) {
        NSAttributedString *prevAttributedText = self.attributedText;
        self.attributedText = [self attributedStringFromRichSpanText:_richSpanText];
        self.selectedRange = NSMakeRange(originCursor + self.attributedText.length - prevAttributedText.length, 0);
        [growingTextView scrollRangeToVisible:growingTextView.selectedRange];
    }

    //    NSLog(@"old, new links: %d, %d", oldLinks.count, newLinks.count);

    [self refreshTextViewUI];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    self.height = height;
    self.diffHeight = height - self.internalGrowingTextView.height;

    if (self.delegate && [self.delegate respondsToSelector:@selector(textView:willChangeHeight:withDiffHeight:)]) {
        [self.delegate textView:self willChangeHeight:height withDiffHeight:self.diffHeight];
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textView:didChangeHeight:withDiffHeight:)]) {
        [self.delegate textView:self didChangeHeight:height withDiffHeight:self.diffHeight];
    }
}

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView {

    // called before textViewDidChange method...
    UITextRange *selection = growingTextView.internalTextView.selectedTextRange;

    NSInteger start = [growingTextView.internalTextView offsetFromPosition:growingTextView.internalTextView.beginningOfDocument toPosition:selection.start];
    NSInteger end = [growingTextView.internalTextView offsetFromPosition:growingTextView.internalTextView.beginningOfDocument toPosition:selection.end];

    NSRange selectedRange = NSMakeRange(MAX(start, 0), MAX(end - start, 0));

    NSArray<TTRichSpanLink *> *richSpanLinks = [_richSpanText richSpanLinksOfAttributedString];

    for (TTRichSpanLink *link in richSpanLinks) {
        if (link.type == TTRichSpanLinkTypeLink) {
            NSRange linkRange = NSMakeRange(link.start, link.length);

            NSRange forceSelectedRange = NSMakeRange(NSNotFound, 0);

            // 控制可选中区域，对于链接只能整体选中
            if (selectedRange.length == 0 && selectedRange.location > linkRange.location && selectedRange.location < linkRange.location + linkRange.length) {
                if (selectedRange.location < linkRange.location + linkRange.length / 2) {
                    forceSelectedRange = NSMakeRange(linkRange.location, 0);
                } else {
                    forceSelectedRange = NSMakeRange(linkRange.location + linkRange.length, 0);
                }
            } else if (selectedRange.length > 0 && NSIntersectionRange(linkRange, selectedRange).length > 0) {
                if (!NSEqualRanges(NSUnionRange(linkRange, selectedRange), selectedRange)) {
                    NSInteger min = MIN(selectedRange.location, linkRange.location);
                    NSInteger max = MAX(selectedRange.location + selectedRange.length, linkRange.location + linkRange.length);

                    forceSelectedRange = NSMakeRange(MAX(min, 0), MAX(max - min, 0));
                }
            }

            // 避免重复处理和按 backspace 按键时强制选择等情况
            if (forceSelectedRange.location == NSNotFound || self.didInputTextBackspaceOrAnythingElse) {
                continue;
            } else {
                growingTextView.selectedRange = forceSelectedRange;
            }
        }
    }
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewShouldReturn:)]) {
        return [self.delegate textViewShouldReturn:self];
    } else {
        return YES;
    }
}

#pragma mark - TTUGCEmojiInputViewDelegate

- (void)emojiInputView:(UIView *)emojiInputView didSelectEmojiTextAttachment:(TTUGCEmojiTextAttachment *)emojiTextAttachment {
    // 插入表情图片
    UITextView *textView = self.internalGrowingTextView.internalTextView;

    if (emojiTextAttachment.idx == TTUGCEmojiBlank) {
        return;
    } else if (emojiTextAttachment.idx == TTUGCEmojiDelete) {
        NSRange selectedRange = textView.selectedRange;
        if (selectedRange.length > 0) {
            [textView.textStorage deleteCharactersInRange:selectedRange];
        } else if (textView.textStorage.length > 0) {
            [textView deleteBackward]; // 这里保证多字节字符（系统 Emoji）删除问题
        }
    } else {
        emojiTextAttachment.fontSize = textView.font.pointSize;
        emojiTextAttachment.descender = textView.font.descender;
        NSMutableAttributedString *attributedString = [[NSAttributedString attributedStringWithAttachment:emojiTextAttachment] mutableCopy];
        [attributedString addAttributes:self.typingAttributes ?: @{
            NSFontAttributeName : textView.font,
            NSForegroundColorAttributeName : SSGetThemedColorWithKey(kColorText1),
        } range:NSMakeRange(0, 1)];

        // 如果有光标选中文字，执行替换操作
        NSRange selectedRange = textView.selectedRange;
        if (selectedRange.length > 0) {
            [textView.textStorage deleteCharactersInRange:selectedRange];
        }
        [textView.textStorage insertAttributedString:attributedString atIndex:textView.selectedRange.location];

        textView.selectedRange = NSMakeRange(textView.selectedRange.location + 1, 0);
    }

    [self growingTextViewDidChange:self.internalGrowingTextView];  // 手动触发 textView 回调方法

    [self.internalGrowingTextView refreshHeight];

    [textView scrollRangeToVisible:textView.selectedRange];
}


#pragma mark - Utils

- (UIFont *)tt_fontOfSize:(CGFloat)size {
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
        if ([UIFont fontWithName:@"PingFangSC-Regular" size:size]) {
            return [UIFont fontWithName:@"PingFangSC-Regular" size:size];
        }
    }

    return [UIFont systemFontOfSize:size];
}

- (NSAttributedString *)attributedStringFromRichSpanText:(TTRichSpanText *)richSpanText {
    NSMutableAttributedString *mutableAttributedString = [[TTUGCEmojiParser parseInTextKitContext:richSpanText.text fontSize:self.textViewFontSize] mutableCopy];

    [mutableAttributedString addAttributes:[self typingAttributes] range:NSMakeRange(0, mutableAttributedString.length)];

    NSArray <TTRichSpanLink *> *richSpanLinks = [richSpanText richSpanLinksOfAttributedString];

    [richSpanLinks enumerateObjectsUsingBlock:^(TTRichSpanLink *obj, NSUInteger idx, BOOL *stop) {
        NSRange range = NSMakeRange(obj.start, obj.length);
        [mutableAttributedString addAttributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:self.textViewFontSize],
            NSForegroundColorAttributeName : SSGetThemedColorWithKey(kColorText5)
        } range:range];
    }];

    return [mutableAttributedString copy];
}

- (NSUInteger)transformIndexOfAttributedString:(NSAttributedString *)attributedString withIndex:(NSUInteger)index {
    NSRange range = NSMakeRange(0, index);
    NSAttributedString *attributedSubstring = [attributedString attributedSubstringFromRange:range];
    NSString *substring = [TTUGCEmojiParser stringify:attributedSubstring];
    return substring.length;
}

- (NSDictionary *)customTypingAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = self.textViewFontSize * 1.4f;
    paragraphStyle.maximumLineHeight = self.textViewFontSize * 1.4f;
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;

    NSDictionary<NSString *, id> *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:self.textViewFontSize],
        NSForegroundColorAttributeName : SSGetThemedColorWithKey(kColorText1),
        NSParagraphStyleAttributeName : paragraphStyle,
        NSBaselineOffsetAttributeName : @(self.textViewFontSize * 0.2f) // 保证文字在光标居中，妥协的是表情的 baseline 得跟文字一致，无法跟文字垂直居中
    };

    return attributes;
}

@end

//
//  TTUGCTextViewInternal.m
//  Article
//
//  Created by Jiyee Sheng on 14/09/2017.
//
//

#import "TTUGCTextViewInternal.h"
#import "TTUGCEmojiParser.h"


@implementation TTUGCTextViewInternal

- (void)cut:(id)sender
{
    NSRange selectedRange = self.selectedRange;
    NSAttributedString *attributedText = [self.attributedText attributedSubstringFromRange:selectedRange];

    [UIPasteboard generalPasteboard].string = [TTUGCEmojiParser stringify:attributedText ignoreCustomEmojis:YES];

    // 如果有光标选中文字，执行替换操作
    if (selectedRange.length > 0) {
        [self.textStorage deleteCharactersInRange:selectedRange];
    }

    if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegate textViewDidChange:self];
    }
}

- (void)copy:(id)sender
{
    NSRange range = self.selectedRange;
    NSAttributedString *attributedText = [self.attributedText attributedSubstringFromRange:range];

    [UIPasteboard generalPasteboard].string = [TTUGCEmojiParser stringify:attributedText ignoreCustomEmojis:YES];
}

- (void)paste:(id)sender
{
    NSMutableAttributedString *attributedText = [[TTUGCEmojiParser parseInTextKitContext:[UIPasteboard generalPasteboard].string fontSize:self.font.pointSize] mutableCopy];

    if (!attributedText) return;

    if (self.font) {
        [attributedText addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attributedText.length)];
    }
    if (self.textColor) {
        [attributedText addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, attributedText.length)];
    }
    if (self.typingAttributes) {
        [attributedText addAttributes:self.typingAttributes range:NSMakeRange(0, attributedText.length)];
    }
    if (self.textAttributes) {
        [attributedText addAttributes:self.textAttributes range:NSMakeRange(0, attributedText.length)];
    }

    // 如果有光标选中文字，执行替换操作
    NSRange selectedRange = self.selectedRange;
    if (selectedRange.length > 0) {
        [self.textStorage deleteCharactersInRange:selectedRange];
    }
    [self.textStorage insertAttributedString:attributedText atIndex:self.selectedRange.location];

    self.selectedRange = NSMakeRange(self.selectedRange.location + attributedText.length, 0);

    if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegate textViewDidChange:self];
    }
}

@end

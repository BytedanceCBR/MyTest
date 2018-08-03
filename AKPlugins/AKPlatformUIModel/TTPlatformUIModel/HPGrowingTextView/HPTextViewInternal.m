//
//  HPTextViewInternal.m
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import "HPTextViewInternal.h"
#import "TTModuleBridge.h"
#import <TTBaselib/TTBaseMacro.h>

@implementation HPTextViewInternal

-(void)setText:(NSString *)text
{
    BOOL originalValue = self.scrollEnabled;
    //If one of GrowingTextView's superviews is a scrollView, and self.scrollEnabled == NO,
    //setting the text programatically will cause UIKit to search upwards until it finds a scrollView with scrollEnabled==yes
    //then scroll it erratically. Setting scrollEnabled temporarily to YES prevents this.
    [self setScrollEnabled:YES];
    [super setText:text];
    [self setScrollEnabled:originalValue];
}

- (void)setScrollable:(BOOL)isScrollable
{
    [super setScrollEnabled:isScrollable];
}

-(void)setContentOffset:(CGPoint)s
{
	if(self.tracking || self.decelerating){
		//initiated by user...
        
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
        
	} else {

		float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
		if(s.y < bottomOffset && self.scrollEnabled){            
            UIEdgeInsets insets = self.contentInset;
            insets.bottom = 8;
            insets.top = 0;
            self.contentInset = insets;            
        }
	}
    
    // Fix "overscrolling" bug
    if (s.y > self.contentSize.height - self.frame.size.height && !self.decelerating && !self.tracking && !self.dragging)
        s = CGPointMake(s.x, self.contentSize.height - self.frame.size.height);
    
	[super setContentOffset:s];
}

-(void)setContentInset:(UIEdgeInsets)s
{
	UIEdgeInsets insets = s;
	
	if(s.bottom>8) insets.bottom = 0;
	insets.top = 0;

	[super setContentInset:insets];
}

-(void)setContentSize:(CGSize)contentSize
{
    // is this an iOS5 bug? Need testing!
    if(self.contentSize.height > contentSize.height)
    {
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
    }
    
    [super setContentSize:contentSize];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.displayPlaceHolder && self.placeholder && self.placeholderColor)
    {
        if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = self.textAlignment;
            CGRect rect = CGRectMake(5, self.textContainerInset.top + self.contentInset.top, self.frame.size.width-self.contentInset.left, self.frame.size.height- self.contentInset.top);
            [self.placeholder drawInRect:rect withAttributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName:self.placeholderColor, NSParagraphStyleAttributeName:paragraphStyle}];
        }
        else {
            [self.placeholderColor set];
            [self.placeholder drawInRect:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f) withAttributes:@{NSFontAttributeName: self.font}];
        }
    }
}

-(void)setPlaceholder:(NSString *)placeholder
{
	_placeholder = placeholder;
	
	[self setNeedsDisplay];
}

- (void)cut:(id)sender
{
    NSRange selectedRange = self.selectedRange;
    NSAttributedString *attributedText = [self.attributedText attributedSubstringFromRange:selectedRange];

    [UIPasteboard generalPasteboard].string = [self stringify:attributedText];

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

    [UIPasteboard generalPasteboard].string = [self stringify:attributedText];
}

- (void)paste:(id)sender
{
    NSMutableAttributedString *attributedText = [[self parseInTextKitContext:[UIPasteboard generalPasteboard].string] mutableCopy];

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

//业务不该直接引进
- (NSString *)stringify:(NSAttributedString *)text
{
    __block NSString *string = nil;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:text forKey:@"stringifyText"];
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"TTUGCEmojiParser.stringify" object:nil withParams:param complete:^(id  _Nullable result) {
        string = result;
    }];
    return isEmptyString(string)? @"": string;
    
}

- (NSAttributedString *)parseInTextKitContext:(NSString *)text
{
    __block NSAttributedString *string = nil;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:text forKey:@"text"];
    [param setValue:@(self.font.pointSize) forKey:@"fontSize"];
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"TTUGCEmojiParser.parseInTextKitContext" object:nil withParams:param complete:^(id  _Nullable result) {
        string = result;
    }];
    return string;
}

@end

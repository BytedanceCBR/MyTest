//
//  AWECommentInputBar.m
//  LiveStreaming
//
//  Created by SongLi.02 on 10/21/16.
//  Copyright © 2016 Bytedance. All rights reserved.
//

#import "AWECommentInputBar.h"
#import "HTSVideoPlayColor.h"
#import "HTSVideoPlayToast.h"
#import "TTDeviceHelper.h"
#import "SSThemed.h"
#import "TTThemeConst.h"
#import "UIImageAdditions.h"
#import <TTUGCFoundation/TTUGCTextView.h>
#import <TTUGCFoundation/TTUGCTextViewMediator.h>
#import <UIViewAdditions.h>
#import "UIColor+Theme.h"
#import <TTBaseLib/UITextView+TTAdditions.h>
#import <TTUGCFoundation/TTRichSpanText.h>
#import <TTBaseLib/NSObject+MultiDelegates.h>

@interface AWECommentInputBar () <HTSVideoPlayGrowingTextViewDelegate>
//@property (nonatomic, strong) HTSVideoPlayGrowingTextView *textView;
@property (nonatomic, strong) SSThemedButton *sendButton;
@property (nonatomic, weak) id<HTSVideoPlayGrowingTextViewDelegate> textViewDelegate;
@property (nonatomic, copy) void(^onSendBlock)(AWECommentInputBar *inputBar, NSString *text);
@property (nonatomic, strong) SSThemedView *textBgView;

@property (nonatomic, strong) TTUGCTextViewMediator *textViewMediator;

@end

@implementation AWECommentInputBar

- (instancetype)initWithFrame:(CGRect)frame textViewDelegate:(id<HTSVideoPlayGrowingTextViewDelegate>)delegate sendBlock:(void(^)(AWECommentInputBar *inputBar, NSString *text))sendBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
        self.separatorAtTOP = YES;
        self.borderColorThemeKey = kColorLine7;
        self.textViewDelegate = delegate;
        self.onSendBlock = sendBlock;
        
        _maxInputCount = 50;
        _defaultPlaceHolder = @"说点什么...";
        _params = [NSMutableDictionary dictionary];
        
        _textBgView = [[SSThemedView alloc] initWithFrame:CGRectMake(14, 6, CGRectGetWidth(self.bounds) - 14 - 20 - 40, 32)];
        
        _textBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _textBgView.borderColorThemeKey = kColorLine1;
        _textBgView.backgroundColorThemeKey = @"grey7";
        _textBgView.layer.cornerRadius = _textBgView.frame.size.height / 2;
        _textBgView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _textBgView.layer.masksToBounds = YES;
        [self addSubview:_textBgView];
        
//        CGRect textRect = CGRectMake(10, 0, CGRectGetWidth(_textBgView.bounds) - 10, CGRectGetHeight(_textBgView.bounds));
//        _textView = [[HTSVideoPlayGrowingTextView alloc] initWithFrame:textRect];
//        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//        _textView.backgroundColor = [UIColor clearColor];
//        _textView.textColor = [UIColor tt_themedColorForKey:kColorText1];
//        _textView.placeholder = @"优质评论将会被优先展示";
//        _textView.placeholderColor = [UIColor tt_themedColorForKey:@"grey3"];
//        _textView.delegate = self;
//        CGFloat verticalMargin = (self.textView.internalTextView.frame.size.height - [UIFont systemFontOfSize:16.0f].pointSize - 4.f) / 2.f;
//        _textView.internalTextView.textContainerInset = UIEdgeInsetsMake(verticalMargin, self.textView.internalTextView.textContainerInset.left, verticalMargin, self.textView.internalTextView.textContainerInset.right);
//        _textView.font = [UIFont systemFontOfSize:16.0f];
//        [_textBgView addSubview:_textView];
        [_textBgView addSubview:self.inputTextView];
        
        // TextView and Toolbar Mediator
        self.textViewMediator = [[TTUGCTextViewMediator alloc] init];
        self.textViewMediator.textView = self.inputTextView;
        self.inputTextView.delegate = self.textViewMediator;
        [self.inputTextView tt_addDelegate:self asMainDelegate:NO];
        
        _sendButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_textBgView.frame) + 10, CGRectGetMaxY(self.textBgView.frame) - 32, 40, 32)];
        _sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        if ([TTDeviceHelper OSVersionNumber] > 8.2) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            _sendButton.titleLabel.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightMedium];
#pragma clang diagnostic pop
        } else {
            _sendButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        }
        
        _sendButton.titleColorThemeKey = @"red1";
//        _sendButton.highlightedTitleColorThemeKey = kColorText6Highlighted;
        _sendButton.disabledTitleColorThemeKey = kColorText9;
        _sendButton.enabled = NO;
        [_sendButton setTitle:@"发布" forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(handleSend) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendButton];
        
        [self clearInputBar];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//非SSThemedView在通知回调里改颜色
- (void)themeChanged:(NSNotification *)notification
{
//    _textView.textColor = [UIColor tt_themedColorForKey:kColorText1];
//    _textView.placeholderColor = [UIColor tt_themedColorForKey:kColorText3];
}

- (void)setDefaultPlaceHolder:(NSString *)defaultPlaceHolder
{
    _defaultPlaceHolder = defaultPlaceHolder.copy;
    self.inputTextView.internalGrowingTextView.placeholder = defaultPlaceHolder;
    [self layoutIfNeeded];
}

- (void)clearInputBar
{
    [self.params removeAllObjects];
    self.targetCommentModel = nil;
    self.sendButton.enabled = NO;
    self.sendButton.selected = NO;
    self.inputTextView.text = nil;
    self.inputTextView.internalGrowingTextView.placeholder = self.defaultPlaceHolder;
}

- (void)becomeActive
{
    [self.inputTextView becomeFirstResponder];
}

- (BOOL)isActive
{
    return [self.inputTextView isFirstResponder];
}

- (void)resignActive
{
    [self.inputTextView resignFirstResponder];
}

- (void)setMinY:(CGFloat)minY
{
    CGRect frame = self.frame;
    frame.origin.y = minY;
    self.frame = frame;
}

- (void)setMaxY:(CGFloat)maxY
{
    CGRect frame = self.frame;
    frame.origin.y = maxY - CGRectGetHeight(frame);
    self.frame = frame;
}


#pragma mark - Actions

- (void)handleSend
{
    !self.onSendBlock ?: self.onSendBlock(self, self.inputTextView.text);
}

#pragma mark - HTSVideoPlayGrowingTextViewDelegate

- (BOOL)growingTextViewShouldBeginEditing:(HTSVideoPlayGrowingTextView *)growingTextView;
{
    if ([self.textViewDelegate respondsToSelector:_cmd]) {
        return [self.textViewDelegate growingTextViewShouldBeginEditing:growingTextView];
    }
    return YES;
}

- (void)growingTextViewDidBeginEditing:(HTSVideoPlayGrowingTextView *)growingTextView
{
    if ([self.textViewDelegate respondsToSelector:_cmd]) {
        [self.textViewDelegate growingTextViewDidBeginEditing:growingTextView];
    }
}

- (BOOL)growingTextViewShouldEndEditing:(HTSVideoPlayGrowingTextView *)growingTextView
{
    if ([self.textViewDelegate respondsToSelector:_cmd]) {
        return [self.textViewDelegate growingTextViewShouldEndEditing:growingTextView];
    }
    return YES;
}

- (void)growingTextViewDidEndEditing:(HTSVideoPlayGrowingTextView *)growingTextView
{
    if ([self.textViewDelegate respondsToSelector:_cmd]) {
        [self.textViewDelegate growingTextViewDidEndEditing:growingTextView];
    }
}

- (BOOL)growingTextView:(HTSVideoPlayGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([self.textViewDelegate respondsToSelector:_cmd]) {
        return [self.textViewDelegate growingTextView:growingTextView shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (BOOL)growingTextViewShouldReturn:(HTSVideoPlayGrowingTextView *)growingTextView
{
    BOOL shouldReturn = YES;
    if ([self.textViewDelegate respondsToSelector:_cmd]) {
        shouldReturn = [self.textViewDelegate growingTextViewShouldReturn:growingTextView];
    }

    return shouldReturn;
}

- (void)growingTextViewDidChange:(HTSVideoPlayGrowingTextView *)growingTextView
{
    
    if (growingTextView.text.length > self.maxInputCount) {
        growingTextView.text = [growingTextView.text substringToIndex:self.maxInputCount];
        [HTSVideoPlayToast show:[NSString stringWithFormat:@"最多%ld字", (long)self.maxInputCount]];
    }
    
    if (growingTextView.text.length == 0) {
        self.sendButton.enabled = NO;
        self.sendButton.selected = NO;
    } else {
        self.sendButton.enabled = YES;
        self.sendButton.selected = YES;
    }
    
    !self.textDidChangeBlock ?: self.textDidChangeBlock(growingTextView);
}

- (void)growingTextView:(HTSVideoPlayGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    CGFloat diff = height - growingTextView.frame.size.height;
    {
        CGRect frame = self.frame;
        frame.size.height += diff;
        frame.origin.y -= diff;
        self.frame = frame;
    }
    /*//加了auto resize 就不用了
    {
        CGRect frame = self.textBgView.frame;
        frame.size.height += diff;
        frame.origin.y -= diff;
        self.textBgView.frame = frame;
    }
    */
    {
        CGRect frame = self.sendButton.frame;
        frame.origin.y = CGRectGetMaxY(self.textBgView.frame) - frame.size.height;
        self.sendButton.frame = frame;
    }
}

+ (UIImage *)imageWithUIColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (TTUGCTextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(10.f, 0, CGRectGetWidth(_textBgView.bounds) - 10, CGRectGetHeight(_textBgView.bounds))];
        _inputTextView.isBanHashtag = YES;
        _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _inputTextView.backgroundColorThemeKey = @"grey7";
        _inputTextView.layer.masksToBounds = YES;
        _inputTextView.textViewFontSize = [TTDeviceUIUtils tt_newFontSize:16.f];
        _inputTextView.typingAttributes = @{
                                            NSFontAttributeName: [UIFont systemFontOfSize:_inputTextView.textViewFontSize],
                                            NSForegroundColorAttributeName : SSGetThemedColorWithKey(kColorText1),
                                            };
        
        HPGrowingTextView *internalTextView = _inputTextView.internalGrowingTextView;
        internalTextView.minHeight = [TTDeviceUIUtils tt_newPadding:32.f];
        internalTextView.contentInset = UIEdgeInsetsMake(0.f, 8.f, 0.f, 4.f);
        CGFloat verticalMargin = floorf(([TTDeviceUIUtils tt_newPadding:32.f] - [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]].lineHeight) / 2.f); // 文字垂直居中
        internalTextView.internalTextView.textContainerInset = UIEdgeInsetsMake(verticalMargin, internalTextView.internalTextView.textContainerInset.left, verticalMargin, internalTextView.internalTextView.textContainerInset.right);
        internalTextView.placeholder = @"说点什么...";
        internalTextView.backgroundColor = [UIColor clearColor];
        internalTextView.textColor = SSGetThemedColorWithKey(kColorText1);
        internalTextView.tintColor = [UIColor themeRed];
        internalTextView.placeholderColor = SSGetThemedColorWithKey(@"grey3");
        internalTextView.internalTextView.placeHolderFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
        _inputTextView.layer.cornerRadius = 4;
        _inputTextView.richSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];
    }
    
    return _inputTextView;
}

@end

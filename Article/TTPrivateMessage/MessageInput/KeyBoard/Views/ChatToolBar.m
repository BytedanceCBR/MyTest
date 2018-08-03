//
//  ToolbarView.m
//  FaceKeyboard

//  Company：     SunEee
//  Blog:        devcai.com
//  Communicate: 2581502433@qq.com

//  Created by ruofei on 16/3/28.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import "ChatToolBar.h"
#import "ChatToolBarItem.h"
#import "ChatKeyBoardMacroDefine.h"

///...
#import "TTAlphaThemedButton.h"
#import "TTThemedAlertController.h"
#import "TTIndicatorView.h"

#define Image(str) (str == nil || str.length == 0) ? nil : [UIImage themedImageNamed:str]
///...
#define ItemW 30                  //44
#define ItemH kChatToolBarHeight  //49
#define SendBtnW 44
#define ItemPadding 6
#define TextViewH 33

#define TextViewVerticalOffset  ((ItemH-TextViewH)/2.0)
///...
//#define TextViewMargin          8
#define TextViewMargin 15

@interface ChatToolBar ()<RFTextViewDelegate>

@property CGFloat previousTextViewHeight;

/** 临时记录输入的textView */
@property (nonatomic, copy) NSString *currentText;

@property (nonatomic, strong) RFTextView *textView;
@property (nonatomic, strong) TTAlphaThemedButton *imageButton;
@property (nonatomic, strong) TTAlphaThemedButton *sendButton;

@property (nonatomic, strong) UIView *topLineView;

@end

@implementation ChatToolBar

#pragma mark -- dealloc

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"self.textView.contentSize"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValue];
        [self initSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    self.image = [UIImage imageWithUIColor:[UIColor tt_themedColorForKey:kColorBackground3]];
    self.textView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.textView.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    self.textView.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.textView.placeHolderTextColor = [UIColor tt_themedColorForKey:kColorText9];
    self.textView.tintColor = [UIColor colorWithDayColorName:@"587cf4" nightColorName:@"445dc6"];
    _topLineView.backgroundColor = _topLineColor ? : [UIColor tt_themedColorForKey:kColorLine1];
}

- (void)setDefaultValue
{
    self.allowImage = YES;
}

- (void)initSubviews
{
    // barView
    self.image = [UIImage imageWithUIColor:[UIColor tt_themedColorForKey:kColorBackground3]];
    self.userInteractionEnabled = YES;
    self.previousTextViewHeight = TextViewH;
    
    // top line
    _topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), [TTDeviceHelper ssOnePixel])];
    _topLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _topLineView.backgroundColor = _topLineColor ? : [UIColor tt_themedColorForKey:kColorLine1];
    [self addSubview:_topLineView];
    
    ///...
    self.imageButton = [self createBtn:kButKindImage action:@selector(toolbarBtnClick:)];
    
    self.textView = [[RFTextView alloc] init];
    self.textView.frame = CGRectMake(0, 0, 0, TextViewH);
    self.textView.layer.cornerRadius = TextViewH / 2;
    self.textView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.textView.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    self.textView.delegate = self;
    
    ///...
    self.textView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.textView.placeHolderTextColor = [UIColor tt_themedColorForKey:kColorText9];
    self.textView.tintColor = [UIColor colorWithDayColorName:@"587cf4" nightColorName:@"445dc6"];
    
//    self.textView.contentInset = UIEdgeInsetsMake(0.0f, 8.f, 0.0f, 0.f);

//    UIEdgeInsets inset = self.textView.textContainerInset;
//    inset.left = 8;
//    inset.right = 8;
//    self.textView.textContainerInset = inset;
    self.textView.textContainer.lineFragmentPadding = 8;
    
    ///...
    self.sendButton = [self createBtn:kButKindSend action:@selector(toolbarBtnClick:)];
    self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.sendButton.titleColorThemeKey = kColorText9;
    self.sendButton.hidden = !_alwaysShowSendButton;
    [self addSubview:self.sendButton];
    [self addSubview:self.textView];
    [self addSubview:self.imageButton];
    
    //设置frame
    [self setbarSubViewsFrame];
    
    //KVO
    [self addObserver:self forKeyPath:@"self.textView.contentSize" options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setbarSubViewsFrame];
}

// 设置子视图frame
- (void)setbarSubViewsFrame
{
    CGFloat barViewH = self.frame.size.height;
    
    // 为 EyeU 定制一个视频/发送按钮
    self.sendButton.frame = CGRectMake(CGRectGetWidth(self.frame) - SendBtnW - 10, barViewH - ItemH, SendBtnW, ItemH);
    
    if (self.allowImage) {
        self.imageButton.frame = CGRectMake(self.sendButton.left - ItemW - ItemPadding, barViewH - ItemH, ItemW, ItemH);
    } else {
        self.imageButton.frame = CGRectZero;
    }
    
    CGFloat textViewX = TextViewMargin;
    CGFloat textViewW = CGRectGetWidth(self.frame) - (self.allowImage ? (CGRectGetWidth(self.imageButton.frame) + ItemPadding) : 0) - (CGRectGetWidth(self.sendButton.frame) + 10) - 11 - TextViewMargin;
    
//    if (CGRectGetWidth(self.imageButton.frame) == 0) {
//        textViewW = textViewW - ItemPadding;
//    }
    
    self.textView.frame = CGRectMake(textViewX, TextViewVerticalOffset, textViewW, CGRectGetHeight(self.textView.frame));
}

- (void)setAllowImage:(BOOL)allowImage {
    _allowImage = allowImage;
    self.imageButton.hidden = !allowImage;
    [self setbarSubViewsFrame];
}

#pragma mark -- 加载barItems
- (void)loadBarItems:(NSArray<ChatToolBarItem *> *)barItems
{
    for (ChatToolBarItem* barItem in barItems)
    {
        [self setBtn:(NSInteger)barItem.itemKind normalStateImageStr:barItem.normalStr selectStateImageStr:barItem.selectStr highLightStateImageStr:barItem.highLStr];
    }
}

#pragma mark -- 调整文本内容
- (void)setTextViewContent:(NSString *)text
{
    self.currentText = self.textView.text = text;
    if (text.length > 0) {
        self.sendButton.titleColorThemeKey = kColorText6;
    } else {
        self.sendButton.titleColorThemeKey = kColorText9;
    }
}
- (void)clearTextViewContent
{
    self.currentText = self.textView.text = @"";
}

#pragma mark -- 调整placeHolder
- (void)setTextViewPlaceHolder:(NSString *)placeholder
{
    if (placeholder == nil) {
        return;
    }
    
    self.textView.placeHolder = placeholder;
}

- (void)setTextViewPlaceHolderColor:(UIColor *)placeHolderColor
{
    if (placeHolderColor == nil) {
        return;
    }
    self.textView.placeHolderTextColor = placeHolderColor;
}

#pragma mark -- 关于按钮
- (void)setBtn:(ButKind)btnKind normalStateImageStr:(NSString *)normalStr
selectStateImageStr:(NSString *)selectStr highLightStateImageStr:(NSString *)highLightStr
{
    UIButton *btn;
    
    switch (btnKind) {
        case kButKindImage:
            btn = self.imageButton;
            [btn setImage:Image(normalStr) forState:UIControlStateNormal];
            [btn setImage:Image(selectStr) forState:UIControlStateSelected];
            [btn setImage:Image(highLightStr) forState:UIControlStateHighlighted];
            break;
        case kButKindSend:
            btn = self.sendButton;
            [btn setTitle:@"发送" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (TTAlphaThemedButton *)createBtn:(ButKind)btnKind action:(SEL)sel
{
    TTAlphaThemedButton *btn = [TTAlphaThemedButton new];
    
    switch (btnKind) {
        case kButKindImage:
            btn.tag = 5;
            break;
        case kButKindSend:
            btn.tag = 7;
            break;
            
        default:
            break;
    }
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    return btn;
}

- (void)sendText
{
    if ([self.delegate respondsToSelector:@selector(chatToolBarSendText:)] &&
        [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        [self.delegate chatToolBarSendText:self.textView.text];
        [self setTextViewContent:@""];
    } else if (self.textView.text.length > 0) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"不能发送空白消息" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
}

#pragma mark -- UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.textView.text.length > 0 && !_alwaysShowSendButton) {
        self.sendButton.hidden = NO;
    }
    wrapperTrackEventWithCustomKeys(@"private_letter", @"dialog", nil, nil, @{@"dialog" : @"input_box"});
    if ([self.delegate respondsToSelector:@selector(chatToolBarTextViewDidBeginEditing:)]) {
        [self.delegate chatToolBarTextViewDidBeginEditing:self.textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self sendText];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    ///...
    if (!_alwaysShowSendButton) {
        BOOL hasText = (textView.text.length > 0);
        self.sendButton.hidden = !hasText;
//        self.videoButton.hidden = hasText;
    }
    
    self.currentText = textView.text;
    
    if (textView.text.length <= 0) {
        self.sendButton.titleColorThemeKey = kColorText9;
    } else {
        self.sendButton.titleColorThemeKey = kColorText6;
    }
    
    if ([self.delegate respondsToSelector:@selector(chatToolBarTextViewDidChange:)])
    {
        [self.delegate chatToolBarTextViewDidChange:self.textView];
    }
}

- (void)textViewDeleteBackward:(RFTextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(chatToolBarTextViewDeleteBackward:)]) {
        
        [self.delegate chatToolBarTextViewDeleteBackward:textView];
    }
}

#pragma mark - kvo回调
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"self.textView.contentSize"]) {
        [self layoutAndAnimateTextView:self.textView];
    }
}

#pragma mark -- 工具栏按钮点击事件
- (void)toolbarBtnClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 5:
            [self handelImageClick:sender];
            break;
        case 7:
            [self handelSendClick:sender];
            break;
        default:
            break;
    }
}

- (void)handelSendClick:(UIButton *)sender
{
    if (self.textView.text.length == 0) {
        return;
    }
    wrapperTrackEventWithCustomKeys(@"private_letter", @"dialog", nil, nil, @{@"dialog" : @"sent_msg"});
    [self sendText];
}

- (void)handelImageClick:(UIButton *)sender
{
    BOOL keyBoardChanged = YES;
    
    [self resumeTextViewContentSize];
    
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    } else {
        keyBoardChanged = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(chatToolBar:imageBtnPressed:keyBoardState:)]) {
        [self.delegate chatToolBar:self imageBtnPressed:sender.selected keyBoardState:keyBoardChanged];
    }
}

#pragma mark -- 重写set方法

///...
- (void)setTopLineColor:(UIColor *)topLineColor
{
    _topLineColor = topLineColor;
    _topLineView.backgroundColor = topLineColor;
}
///...
- (void)setAlwaysShowSendButton:(BOOL)alwaysShowSendButton
{
    _alwaysShowSendButton = alwaysShowSendButton;
    
    if (alwaysShowSendButton) {
        _sendButton.hidden = NO;
    }
}

#pragma mark -- 私有方法

//- (void)adjustTextViewContentSize
//{
//    //调整 textView和recordBtn frame
//    self.currentText = self.textView.text;
//    self.textView.text = @"";
//    self.textView.contentSize = CGSizeMake(CGRectGetWidth(self.textView.frame), TextViewH);
////    self.recordBtn.frame = CGRectMake(self.textView.frame.origin.x, TextViewVerticalOffset, self.textView.frame.size.width, TextViewH);
//}

- (void)resumeTextViewContentSize
{
    self.textView.text = self.currentText;
}


#pragma mark -- 计算textViewContentSize改变

- (CGFloat)getTextViewContentH:(RFTextView *)textView {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return ceil([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}

- (CGFloat)fontWidth
{
    return [UIFont systemFontOfSize:14].lineHeight; //16号字体
}

- (CGFloat)maxLines
{
//    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat line = 3;
//    if (h == 480) {
//        line = 3;
//    }else if (h == 568){
//        line = 3.5;
//    }else if (h == 667){
//        line = 4;
//    }else if (h == 736){
//        line = 4.5;
//    }
    return line;
}

- (void)layoutAndAnimateTextView:(RFTextView *)textView
{
    CGFloat maxHeight = [self fontWidth] * [self maxLines] + 16;
    CGFloat contentH = [self getTextViewContentH:textView];
    
    BOOL isShrinking = contentH < self.previousTextViewHeight;
    CGFloat changeInHeight = contentH - self.previousTextViewHeight;
    
    if (!isShrinking && (self.previousTextViewHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewHeight);
    }
    
    if (changeInHeight != 0.0f) {
        ///...
        textView.shouldNotDrawPlaceholder = YES;
        
        [UIView animateWithDuration:0.25f
                         animations:^{
                             if (isShrinking) {
//                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
//                                     self.previousTextViewHeight = MIN(contentH, maxHeight);
//                                 }
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }
                             CGRect inputViewFrame = self.frame;
                             self.frame = CGRectMake(0.0f,
                                                    0, //inputViewFrame.origin.y - changeInHeight
                                                    inputViewFrame.size.width,
                                                     (inputViewFrame.size.height + changeInHeight));
                             if (!isShrinking) {
//                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
//                                     self.previousTextViewHeight = MIN(contentH, maxHeight);
//                                 }
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                             ///...
                             if (finished) {
                                 textView.shouldNotDrawPlaceholder = NO;
                                 [textView setNeedsDisplay];
                             }
                         }];
        self.previousTextViewHeight = MIN(contentH, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
                           CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    //动态改变自身的高度和输入框的高度
    CGRect prevFrame = self.textView.frame;
    
    NSUInteger numLines = MAX([self.textView numberOfLinesOfText],
                              [[self.textView.text componentsSeparatedByString:@"\n"] count] + 1);
    
    
    self.textView.frame = CGRectMake(prevFrame.origin.x, prevFrame.origin.y, prevFrame.size.width, prevFrame.size.height + changeInHeight);
    
    self.textView.contentInset = UIEdgeInsetsMake(0.0f, 0.f, 0.0f, 0.f);
//    if (numLines > 1) {
//        self.textView.textContainerInset = UIEdgeInsetsMake(0.0f, 8.f, 0.0f, 8.f);
//    } else {
//        self.textView.textContainerInset = UIEdgeInsetsMake(8.0f, 8.f, 8.0f, 8.f);
//    }
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    //self.messageInputTextView.scrollEnabled = YES;
    if (numLines >= 3) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.textView.contentSize.height-self.textView.bounds.size.height);
        [self.textView setContentOffset:bottomOffset animated:YES];
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length-2, 1)];
    }
}

@end

//
//  ChatKeyBoard.m
//  FaceKeyboard

//  Company：     SunEee
//  Blog:        devcai.com
//  Communicate: 2581502433@qq.com

//  Created by ruofei on 16/3/29.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import "ChatKeyBoard.h"
#import "ChatToolBar.h"
#import "ChatToolBarItem.h"
#import "TTIndicatorView.h"
#import "TTIMChatViewController.h"
#import "UIViewController+NavigationBarStyle.h"

@interface ChatKeyBoard () <ChatToolBarDelegate>

@property (nonatomic, strong) ChatToolBar *chatToolBar;

@property (nonatomic, assign) BOOL translucent;

/**
 *  聊天键盘 上一次的 y 坐标
 */
@property (nonatomic, assign) CGFloat lastChatKeyboardY;

@end

@implementation ChatKeyBoard

#pragma mark -- life

+ (instancetype)keyBoard
{
    return [self keyBoardWithNavgationBarTranslucent:YES];
}

/**
 *  如果导航栏是透明的，则键盘的初始位置为 kScreenHeight-kChatToolBarHeight
 *
 *  否则，导航栏的高度为 kScreenHeight-kChatToolBarHeight-64
 */
+ (instancetype)keyBoardWithNavgationBarTranslucent:(BOOL)translucent
{
    CGRect frame = CGRectZero;
    if (translucent) {
        frame = CGRectMake(0, kScreenHeight - kChatToolBarHeight, kScreenWidth, kChatKeyBoardHeight);
    }else {
        frame = CGRectMake(0, kScreenHeight - kChatToolBarHeight - 64, kScreenWidth, kChatKeyBoardHeight);
    }
    return [[self alloc] initWithFrame:frame];
}

+ (instancetype)keyBoardWithParentViewBounds:(CGRect)bounds
{
    CGRect frame = CGRectMake(0, bounds.size.height - kChatToolBarHeight, kScreenWidth, kChatKeyBoardHeight);
    return [[self alloc] initWithFrame:frame];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [self removeObserver:self forKeyPath:@"self.chatToolBar.frame"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _chatToolBar = [[ChatToolBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kChatToolBarHeight)];
        _chatToolBar.delegate = self;
        [self addSubview:self.chatToolBar];
        
        self.lastChatKeyboardY = frame.origin.y;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [self addObserver:self forKeyPath:@"self.chatToolBar.frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.chatToolBar.width = self.width;
    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.chatToolBar.tt_safeAreaInsets)){
        self.frame = CGRectMake(self.left,
                                self.top - self.chatToolBar.tt_safeAreaInsets.bottom,
                                self.width,
                                self.chatToolBar.height + self.tt_safeAreaInsets.bottom);
        [self updateAssociateTableViewFrame];
    }
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self keyboardDown];
//}
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    if (point.y < 0) {
//        [self keyboardDown];
//        return nil;
//    }
//    return [super hitTest:point withEvent:event];
//}

#pragma mark -- 跟随键盘的坐标变化
- (void)keyBoardWillChangeFrame:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect begin = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect end = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        CGFloat targetY = CGRectGetMinY(end) - CGRectGetHeight(self.chatToolBar.frame) - (kScreenHeight - [self getSuperViewH]);


        if(begin.size.height >= 0 && (begin.origin.y - end.origin.y > 0))
        {
            // 键盘弹起 (包括，第三方键盘回调三次问题，监听仅执行最后一次)
            
            self.lastChatKeyboardY = self.frame.origin.y;
            self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
//                self.morePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
//                self.facePanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            [self updateAssociateTableViewFrame];
            
        }
        else if (end.origin.y == kScreenHeight && begin.origin.y!=end.origin.y && duration > 0)
        {
            self.lastChatKeyboardY = self.frame.origin.y;
            CGFloat targetY = CGRectGetMinY(end) - CGRectGetHeight(self.frame) - (kScreenHeight - [self getSuperViewH]);
            //键盘收起
            self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
            [self updateAssociateTableViewFrame];
        }
        else if ((begin.origin.y-end.origin.y<0) && duration == 0)
        {
            self.lastChatKeyboardY = self.frame.origin.y;
            //键盘切换
            self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
            [self updateAssociateTableViewFrame];
        }
        
    }];
}

/**
 *  调整关联的表的高度
 */
- (void)updateAssociateTableViewFrame
{
    if (self.shouldTableViewContentScrollToBottomWhenKeybordUp) {
        
        // 处理智能表情附加view
        CGFloat offset = 0;
        if (CGRectGetMinY(self.subviews.firstObject.frame) < 0) { // 默认智能表情view为第一个子View
            offset = CGRectGetHeight(self.subviews.firstObject.frame);
        }
        _associateTableView.frame = CGRectMake(0, 0, CGRectGetWidth(_associateTableView.frame), CGRectGetMinY(self.frame) - offset);
        CGFloat contentHeight = _associateTableView.contentSize.height + _associateTableView.contentInset.top + _associateTableView.contentInset.bottom;
        CGFloat frameHeight = CGRectGetHeight(_associateTableView.frame);
        if (contentHeight > frameHeight) {
            _associateTableView.contentOffset = CGPointMake(0, contentHeight - _associateTableView.contentInset.top - frameHeight);
        }
        
    } else {
        
        //表的原来的偏移量
        CGFloat original =  _associateTableView.contentOffset.y;
        
        //键盘的y坐标的偏移量
        CGFloat keyboardOffset = self.frame.origin.y - self.lastChatKeyboardY;
        
        //更新表的frame
        _associateTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.origin.y);
        
        //表的超出frame的内容高度
        CGFloat tableViewContentDiffer = _associateTableView.contentSize.height - _associateTableView.frame.size.height;
        
        
        //是否键盘的偏移量，超过了表的整个tableViewContentDiffer尺寸
        CGFloat offset = 0;
        if (fabs(tableViewContentDiffer) > fabs(keyboardOffset)) {
            offset = original-keyboardOffset;
        }else {
            offset = tableViewContentDiffer;
        }
        
        if (_associateTableView.contentSize.height +_associateTableView.contentInset.top+_associateTableView.contentInset.bottom> _associateTableView.frame.size.height) {
            _associateTableView.contentOffset = CGPointMake(0, offset);
        }
    }
    
}
#pragma mark -- kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"self.chatToolBar.frame"]) {
        
        CGRect newRect = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        CGRect oldRect = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        CGFloat changeHeight = newRect.size.height - oldRect.size.height;
        self.lastChatKeyboardY = self.frame.origin.y;
        self.frame = CGRectMake(0, self.frame.origin.y - changeHeight, self.frame.size.width, self.frame.size.height + changeHeight);
        
        [self updateAssociateTableViewFrame];
    }
}

#pragma mark -- ChatToolBarDelegate

// 相册选取按钮
- (void)chatToolBar:(ChatToolBar *)toolBar imageBtnPressed:(BOOL)select keyBoardState:(BOOL)change
{
    if ([self.delegate respondsToSelector:@selector(chatKeyBoardImagePickedButtonPressed)]) {
        [self.delegate chatKeyBoardImagePickedButtonPressed];
    }
}

- (void)chatToolBarTextViewDidBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(chatKeyBoardTextViewDidBeginEditing:)]) {
        [self.delegate chatKeyBoardTextViewDidBeginEditing:textView];
    }
    TTIMChatViewController *chatVC = (TTIMChatViewController *)[self ss_nextResponderWithClass:[TTIMChatViewController class]];
    if ([chatVC isKindOfClass:[TTIMChatViewController class]]) {
        chatVC.ttDisableDragBack = YES;
    }    
}

- (void)chatToolBarSendText:(NSString *)text
{
    [self.chatToolBar clearTextViewContent];
    
    if (!self.chatToolBar.alwaysShowSendButton) {
        self.chatToolBar.sendButton.hidden = YES;
    }

    if ([self.delegate respondsToSelector:@selector(chatKeyBoardSendText:)]) {
        [self.delegate chatKeyBoardSendText:text];
    }
}

- (void)chatToolBarTextViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 300) {
        textView.text = [textView.text substringToIndex:301];
        [textView deleteBackward];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"字数超出限制，已自动截断" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }

    if ([self.delegate respondsToSelector:@selector(chatKeyBoardTextViewDidChange:)]) {
        [self.delegate chatKeyBoardTextViewDidChange:textView];
    }
}

- (void)chatToolBarTextViewDeleteBackward:(RFTextView *)textView
{
    NSRange range = textView.selectedRange;
    NSString *handleText;
    NSString *appendText;
    if (range.location == textView.text.length) {
        handleText = textView.text;
        appendText = @"";
    }else {
        handleText = [textView.text substringToIndex:range.location];
        appendText = [textView.text substringFromIndex:range.location];
    }
    
    if (handleText.length > 0) {
        
        [self deleteBackward:handleText appendText:appendText];
    }
}

#pragma mark -- dataSource

- (void)setDataSource:(id<ChatKeyBoardDataSource>)dataSource
{
    _dataSource = dataSource;
    if (dataSource == nil) {
        return;
    }
    
    if ([self.dataSource respondsToSelector:@selector(chatKeyBoardToolbarItems)]) {
        NSArray<ChatToolBarItem *> *barItems = [self.dataSource chatKeyBoardToolbarItems];
        [self.chatToolBar loadBarItems:barItems];
    }
}

#pragma mark -- set方法
- (void)setAssociateTableView:(UITableView *)associateTableView
{
    if (_associateTableView != associateTableView) {
        _associateTableView = associateTableView;
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    
    [self.chatToolBar setTextViewPlaceHolder:placeHolder];
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor
{
    _placeHolderColor = placeHolderColor;
    
    [self.chatToolBar setTextViewPlaceHolderColor:placeHolderColor];
}

///...
- (void)setAllowImage:(BOOL)allowImage
{
    self.chatToolBar.allowImage = allowImage;
}


- (void)keyboardUp
{
    [self.chatToolBar.textView becomeFirstResponder];
}


- (void)keyboardDown
{
    TTIMChatViewController *chatVC = (TTIMChatViewController *)[self ss_nextResponderWithClass:[TTIMChatViewController class]];
    if ([chatVC isKindOfClass:[TTIMChatViewController class]]) {
        chatVC.ttDisableDragBack = NO;
    }
    [self.chatToolBar.textView resignFirstResponder];
    if ([self.chatToolBar.textView isFirstResponder])
    {
    }
    else
    {
        if(([self getSuperViewH] - CGRectGetMinY(self.frame)) > self.chatToolBar.frame.size.height + self.tt_safeAreaInsets.bottom)
        {
            [UIView animateWithDuration:0.25 animations:^{
                
                self.lastChatKeyboardY = self.frame.origin.y;
                CGFloat y = self.frame.origin.y;
                y = [self getSuperViewH] - self.chatToolBar.frame.size.height - self.tt_safeAreaInsets.bottom;
                self.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height);
                
                [self updateAssociateTableViewFrame];
                
            }];
            
        }
    }
}

- (CGFloat)getSuperViewH
{
    if (self.superview == nil) {
        NSException *excp = [NSException exceptionWithName:@"ChatKeyBoardException" reason:@"未添加到父视图上面" userInfo:nil];
        [excp raise];
    }
    
    return self.superview.frame.size.height;
}


#pragma mark - 回删表情或文字

- (void)deleteBackward:(NSString *)text appendText:(NSString *)appendText
{
    if (IsTextContainFace(text)) { // 如果最后一个是表情
        
        NSRange startRang = [text rangeOfString:@"[" options:NSBackwardsSearch];
        NSString *current = [text substringToIndex:startRang.location];
        [self.chatToolBar setTextViewContent:[current stringByAppendingString:appendText]];
        self.chatToolBar.textView.selectedRange = NSMakeRange(current.length, 0);
        
    }else { // 如果最后一个系统键盘输入的文字是纯文字
        NSString *current = [text substringToIndex:text.length - 1];
        [self.chatToolBar setTextViewContent:[current stringByAppendingString:appendText]];
        self.chatToolBar.textView.selectedRange = NSMakeRange(current.length, 0);
    }
}

// 处理智能表情View
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.subviews.firstObject.frame, point)) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

@end

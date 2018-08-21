//
//  KMKeyboardContainer.m
//  Drawus
//
//  Created by Tianhang Yu on 12-4-4.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSKeyboardContainer.h"

@interface SSKeyboardContainer () {

    BOOL isKeyboardShow;
    CGFloat moveUpHeight;
    CGFloat moveDownHeight;
    CGFloat keyboardHeight;
}

@property (nonatomic, retain) UIView *inputView;

@property (nonatomic, assign) id shownTarget;
@property (nonatomic, assign) SEL shownSelector;
@property (nonatomic, assign) id hiddenTarget;
@property (nonatomic, assign) SEL hiddenSelector;

@end

@implementation SSKeyboardContainer

@synthesize inputView=_inputView;

@synthesize shownTarget    =_shownTarget;
@synthesize shownSelector  =_shownSelector;
@synthesize hiddenTarget   =_hiddenTarget;
@synthesize hiddenSelector =_hiddenSelector;

- (void)dealloc
{
    self.inputView = nil;

    self.shownTarget    = nil;
    self.shownSelector  = nil;
    self.hiddenTarget   = nil;
    self.hiddenSelector = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification 
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasHidden:)
                                                     name:UIKeyboardDidHideNotification 
                                                   object:nil];
    }
    return self;
}

#pragma mark - public

- (void)setShownTarget:(id)target selector:(SEL)selector
{
    _shownTarget = target;
    _shownSelector = selector;
}

- (void)setHiddenTarget:(id)target selector:(SEL)selector
{
    _hiddenTarget = target;
    _hiddenSelector = selector;
}

#pragma mark - KeyboardNotificationAction

- (void)moveSubviewsDependKeyboard:(BOOL)show keyboardHeight:(CGFloat)keyboardHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        
        if (moveUpHeight > 0)
        {
            for (UIView *v in self.subviews) {

                CGRect frame = v.frame;
                
                if (show) {
                    frame.origin.y -= moveUpHeight;
                }
                else {
                    frame.origin.y += moveUpHeight;
                }
                
                v.frame = frame;
            }
        }
        else if (moveDownHeight > 0)
        {
            for (UIView *v in self.subviews) {

                CGRect frame = v.frame;
                
                if (show) 
                {
                    if (CGRectGetMinY(frame) >= CGRectGetMaxY(_inputView.frame) - moveDownHeight)
                    {
                        frame.origin.y += moveDownHeight;
                    }
                }
                else
                {
                    if (CGRectGetMinY(frame) >= CGRectGetMaxY(_inputView.frame) + moveDownHeight)
                    {
                        frame.origin.y -= moveDownHeight;
                    }
                }
                
                v.frame = frame;  
            }
        }
    }];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    if (isKeyboardShow == YES) {
        return;
    }
    
    isKeyboardShow = YES;

    for (UIView *v in self.subviews) 
    {
        if ([v isKindOfClass:[UITextView class]] || [v isKindOfClass:[UITextField class]]) 
        {
            if (v.isFirstResponder) 
            {
                self.inputView = v;
            }
        }
    }
    
    // get keyboard height
    NSDictionary *info = [notification userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [value CGRectValue];
    keyboardRect = [self convertRect:keyboardRect fromView:nil];
    
    keyboardHeight = keyboardRect.size.height;
    
    // if height of input view changed, have something more to deal with
    CGFloat preInputHeight = _inputView.bounds.size.height;

    if (_shownTarget && [_shownTarget respondsToSelector:_shownSelector])
    {
        NSMethodSignature *signature = [_shownTarget methodSignatureForSelector:_shownSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:_shownTarget];
        [invocation setSelector:_shownSelector];
        [invocation setArgument:&self atIndex:2];
        NSNumber *number = [NSNumber numberWithFloat:keyboardHeight];
        [invocation setArgument:&number atIndex:3];
        [invocation invoke];   
    }
    
    // get move height for keyboard
    CGFloat maxY = CGRectGetMaxY(_inputView.frame);
    CGFloat keyboardOriginY = self.bounds.size.height - keyboardHeight;
    
    if (maxY > keyboardOriginY) 
    {
        moveUpHeight = maxY - keyboardOriginY;
        moveDownHeight = 0.f;
    }
    else
    {
        moveUpHeight = 0.f;
        moveDownHeight = _inputView.bounds.size.height - preInputHeight;
    }
    
    [self moveSubviewsDependKeyboard:YES keyboardHeight:keyboardHeight];
}

- (void)keyboardWasHidden:(NSNotification *)notification
{
    if (isKeyboardShow == NO) {
        return;
    }
    
    isKeyboardShow = NO;

    if (_hiddenTarget && [_hiddenTarget respondsToSelector:_hiddenSelector])
    {
        NSMethodSignature *signature = [_hiddenTarget methodSignatureForSelector:_hiddenSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:_hiddenTarget];
        [invocation setSelector:_hiddenSelector];
        [invocation setArgument:&self atIndex:2];
        NSNumber *number = [NSNumber numberWithFloat:keyboardHeight];
        [invocation setArgument:&number atIndex:3];
        [invocation invoke];   
    }
    
    [self moveSubviewsDependKeyboard:NO keyboardHeight:moveUpHeight];
}

@end

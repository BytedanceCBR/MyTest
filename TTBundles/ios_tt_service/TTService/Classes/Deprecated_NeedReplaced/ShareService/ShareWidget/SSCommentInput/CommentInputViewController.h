//
//  CommentInputViewController.h
//  Article
//
//  Created by Dianwei on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
/*
 *  评论输入框， 主要用于iphone
 */
#import <UIKit/UIKit.h>
#import "SSViewControllerBase.h"
#import "SSCommentInputView.h"

@protocol CommentInputViewControllerDelegate;

@interface CommentInputViewController : SSViewControllerBase <UITextViewDelegate>

@property(nonatomic, weak)id<CommentInputViewControllerDelegate>delegate;

@property(nonatomic, retain)SSCommentInputView * commentInputView;

- (instancetype)initWithMaxWordsCount:(NSInteger)maxWordsCount;

@end


@protocol CommentInputViewControllerDelegate <NSObject>

@optional

- (void)commentInputViewControllerCancelled:(CommentInputViewController*)controller;
- (void)commentInputViewController:(CommentInputViewController*)controller responsedReceived:(NSNotification*)notification;
- (BOOL)commentInputViewControllerWillSendMsg:(CommentInputViewController *)controller;

@end


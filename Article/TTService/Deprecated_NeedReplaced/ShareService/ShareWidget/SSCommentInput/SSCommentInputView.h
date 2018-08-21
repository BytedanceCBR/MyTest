//
//  SSCommentInputView.h
//  Article
//
//  Created by Zhang Leonardo on 13-3-20.
//
//


#import "SSCommentInputViewBase.h"
//#import "SSCommentModel.h"
#import "SSCommentInputHeader.h"

@protocol SSCommentInputViewDelegate;

@interface SSCommentInputView : SSCommentInputViewBase

@property(nonatomic, weak)id<SSCommentInputViewDelegate> delegate;
@property(nonatomic, retain)UIViewController *topMostViewController;

- (void)setCondition:(NSDictionary *)conditions;

@end

@protocol SSCommentInputViewDelegate <NSObject>
@optional
- (BOOL)commentInputViewWillSendMsg:(SSCommentInputView *)controller;
- (void)commentInputViewCancelled:(SSCommentInputView *)controller;
- (void)commentInputView:(SSCommentInputView *)inputView responsedReceived:(NSNotification*)notification;

@end

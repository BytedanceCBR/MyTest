//
//  TTIMChatViewController.h
//  EyeU
//
//  Created by matrixzk on 10/18/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSViewControllerBase.h"

@class TTIMMessage;
@interface TTIMChatViewController : SSViewControllerBase

@property (nonatomic, copy, readonly) NSString *sessionId;
@property (nonatomic, copy) NSString *draft;
@property (nonatomic, copy) void(^willExitBlock)(NSString *sessionId, NSString *draft, BOOL shouldRemoveChat);

/**
 *  聊天列表消息数据源
 */
- (NSArray<TTIMMessage *> *)messages;

/**
 *  UI动画展示 `msgsArray` 所包含的消息
 */
- (void)showMessages:(NSArray<TTIMMessage *> *)msgsArray;

/**
 *  动画删除消息，同时在数据库中标记该消息为删除
 */
- (void)deleteMessage:(TTIMMessage *)message;

/**
 *  dismiss消息发送框
 */
- (void)dismissMessageInputView;

@end

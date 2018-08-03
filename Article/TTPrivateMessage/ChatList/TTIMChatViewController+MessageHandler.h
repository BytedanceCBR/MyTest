//
//  TTIMChatViewController+MessageHandler.h
//  EyeU
//
//  Created by matrixzk on 10/31/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMChatViewController.h"
#import "TTIMMessageCell.h"
#import "TTIMMessageInputViewController.h"

@interface TTIMChatViewController (MessageHandler) <TTIMMessageCellEventDelegate, TTIMMessageInputViewDelegate, UIAlertViewDelegate>

- (void)sendMessages:(NSArray<TTIMMessage *> *)messages;


@end

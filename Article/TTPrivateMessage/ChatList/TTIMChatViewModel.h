//
//  TTIMChatViewModel.h
//  EyeU
//
//  Created by matrixzk on 11/6/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTIMMsgExt.h"

@class TTIMMessage;
typedef void(^TTIMHistoryMsgsFetchFinishedHandler)(NSArray<TTIMMessage *> *historyMsgs, BOOL hasMore);

@interface TTIMChatViewModel : NSObject <TTIMMsgExt>

@property (nonatomic, copy) void(^showNewMessagesBlock)(NSArray<TTIMMessage *> *newMessages);

- (instancetype)initWithSessionId:(NSString *)sessionId messageArray:(NSMutableArray *)msgArray;
- (void)fetchHistoryMessagesWithFinishHandler:(TTIMHistoryMsgsFetchFinishedHandler)finishHandler;

@end

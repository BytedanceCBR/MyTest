//
//  TTIMChatViewModel.m
//  EyeU
//
//  Created by matrixzk on 11/6/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMChatViewModel.h"
#import "TTIMMessage.h"
#import "TTIMSDKService.h"


static int kHistoryMsgNumOfPerPage = 20;

@interface TTIMChatViewModel ()
@property (nonatomic, weak) NSMutableArray<TTIMMessage *> *messageArray;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) TTIMHistoryMsgsFetchFinishedHandler fetchHistoryMsgsFinishedHandler;
@property (nonatomic, strong) TTIMChatMessage *lastMsg;
@property (nonatomic) BOOL noMoreHistoryMsgs;
@end

@implementation TTIMChatViewModel

- (instancetype)initWithSessionId:(NSString *)sessionId messageArray:(NSMutableArray *)msgArray
{
    self = [super init];
    if (self) {
        _sessionId = sessionId;
        _messageArray = msgArray;
    }
    return self;
}

- (void)fetchHistoryMessagesWithFinishHandler:(TTIMHistoryMsgsFetchFinishedHandler)finishHandler
{
    if (self.noMoreHistoryMsgs) {
        finishHandler(nil, NO);
        return;
    }
    self.fetchHistoryMsgsFinishedHandler = finishHandler;
    
    if (!self.lastMsg) {
        [[TTIMSDKService sharedInstance] queryMsg:self.sessionId limit:kHistoryMsgNumOfPerPage];
        // finishHandler(nil, NO);
        return;
    }
    
    [[TTIMSDKService sharedInstance] queryMsg:self.sessionId mid:_lastMsg.svrMsgId cid:_lastMsg.clientMsgId limit:kHistoryMsgNumOfPerPage];
}

- (void)handleSendStateUpdateWithSendingMessage:(TTIMChatMessage *)chatMsg
{
    // 退出聊天界面再次进入时，数据源msg和发送中的msg就是两个实例了，但他们状态要保持同步
    [self.messageArray enumerateObjectsUsingBlock:^(TTIMMessage * _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop) {
        if (msg.clientMsgId == chatMsg.clientMsgId && msg != chatMsg && msg.status != chatMsg.status) {
            msg.status = chatMsg.status;
            *stop = YES;
            // NSLog(@">>> ttim 命中聊天列表 msg 状态同步 msgClientId : %@", @(msg.clientMsgId));
        }
    }];
}

#pragma mark - TTIMMsgExt protocal Methods

- (void)onAdd:(NSString *)chatName msg:(TTIMChatMessage *)chatMsg
{
    //IMSDK使用了同一个Message实例，只是上层丢进去了一个子类的TTIMMessage再拿出来变成了TTIMChatMessage，需要强制转换一下
    TTIMMessage *msg = (TTIMMessage *)chatMsg;
    !self.showNewMessagesBlock ? : self.showNewMessagesBlock(@[msg]);
}

- (void)onUpdate:(NSString *)sessionName msg:(TTIMChatMessage *)chatMsg
{
    [self handleSendStateUpdateWithSendingMessage:chatMsg];
}

- (void)onSendAck:(NSString *)chatName msg:(TTIMChatMessage *)chatMsg
{
    [self handleSendStateUpdateWithSendingMessage:chatMsg];
}

- (void)onGet:(NSString *)chatName msgs:(NSArray *)listMsg
{
    TTIMMessage *lastMsg = self.messageArray.lastObject;
    
    NSMutableArray *duplicateMsgs = [NSMutableArray arrayWithCapacity:listMsg.count];
    [listMsg enumerateObjectsUsingBlock:^(TTIMChatMessage * _Nonnull chatMsg, NSUInteger idx, BOOL * _Nonnull stop) {
        if (lastMsg.clientMsgId >= chatMsg.clientMsgId) {
            [duplicateMsgs addObject:chatMsg];
        }
    }];
    
    NSArray *tempMsgs;
    if (duplicateMsgs.count > 0) {
        NSMutableArray *msgs = [NSMutableArray arrayWithArray:listMsg];
        [msgs removeObjectsInArray:duplicateMsgs];
        tempMsgs = msgs;
    } else {
        tempMsgs = listMsg;
    }
    
    
    NSMutableArray *newMsgs = [NSMutableArray arrayWithCapacity:tempMsgs.count];
    [tempMsgs enumerateObjectsUsingBlock:^(TTIMChatMessage * _Nonnull chatMsg, NSUInteger idx, BOOL * _Nonnull stop) {
        TTIMMessage *msg = [[TTIMMessage alloc] initWithChatMessage:chatMsg];
        msg.shouldShowCellAnimation = YES;
        
        __block BOOL shouldAdd = YES;
        
        [newMsgs enumerateObjectsUsingBlock:^(TTIMMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (msg.clientMsgId == obj.clientMsgId) {
                *stop = YES;
                shouldAdd = NO;
            }
        }];

        if (shouldAdd) {
            [newMsgs addObject:msg];
        }
        
        // TODO: test
//        if (msg.messageType == TTIMMessageTypeImage) {
//            msg.messageType = TTIMMessageTypeExpress;
//        }
        
//        if ([self checkValidityOfMessage:msg]) {
//            [newMsgs addObject:msg];
//        }
    }];
    
    if (newMsgs.count > 0 && self.showNewMessagesBlock) {
        self.showNewMessagesBlock(newMsgs);
    }
}

- (void)onQueryMsg:(NSString *)chatName msgs:(NSArray *)listMsg
{
    if (![chatName isEqualToString:self.sessionId]) {
        return;
    }
    
    if (listMsg.count == 0) {
        self.noMoreHistoryMsgs = YES;
        if (self.fetchHistoryMsgsFinishedHandler) {
            self.fetchHistoryMsgsFinishedHandler(nil, NO);
        }
        return;
    }
    
    self.lastMsg = listMsg.firstObject;
    
    NSMutableArray<TTIMMessage *> *oldderMsgs = [NSMutableArray arrayWithCapacity:listMsg.count];
    [listMsg enumerateObjectsUsingBlock:^(TTIMChatMessage * _Nonnull chatMsg, NSUInteger idx, BOOL * _Nonnull stop) {
        TTIMMessage *msg = [[TTIMMessage alloc] initWithChatMessage:chatMsg];
        [oldderMsgs addObject:msg];
    }];
    
    if (self.fetchHistoryMsgsFinishedHandler) {
        self.fetchHistoryMsgsFinishedHandler(oldderMsgs, (listMsg.count == kHistoryMsgNumOfPerPage));
    }
}

/*
-(void)onDel:(NSString*)chatName msgs:(NSArray*)listMsg;
-(void)onDelTalbe:(NSString*)chatName isDel:(BOOL)isDel;
-(void)onMsgCenterQuery:(NSDictionary*)dic;
-(void)onChat:(NSString*)chatName unreadCount:(int)value;
*/

@end

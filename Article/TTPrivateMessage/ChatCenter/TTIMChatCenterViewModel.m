//
//  TTIMChatCenterViewModel.m
//  EyeU
//
//  Created by matrixzk on 11/8/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMChatCenterViewModel.h"

#import "TTIMSDKService.h"
#import "TTIMSessioniItem.h"
#import "TTIMUtils.h"
#import "TTIMDateFormatter.h"
#import "TTIMMessage.h"
#import "TTUserData.h"
#import "TTUserServices.h"
#import "TTPLManager.h"

#pragma mark - TTIMChatCenterModel

@interface TTIMChatCenterModel ()

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, strong) TTUserData *userModel;
@property (nonatomic, strong) TTIMChatMessage *latestMsg;

@end

@implementation TTIMChatCenterModel

@end


#pragma mark - TTIMChatCenterViewModel


NSString * const kTTIMNewMessageDidReceivedNotification = @"kTTIMNewMessageDidReceivedNotification";

@interface TTIMChatCenterViewModel ()
@property (nonatomic, copy) TTIMChatCenterDataSourceResultHandler resultHandler;
@property (nonatomic, strong) NSMutableDictionary<NSString *,TTIMChatCenterModel*> *sessionsDict;
@end

@implementation TTIMChatCenterViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sessionsDict = [NSMutableDictionary new];
    }
    return self;
}

- (void)fetchChatCenterSessionsWithResultHandler:(TTIMChatCenterDataSourceResultHandler)resultHandler
{
    self.resultHandler = resultHandler;
    
    [[TTIMSDKService sharedInstance] queryCenterMsgList];
}

- (void)removeChatWithSessionId:(NSString *)sessionId
{
    if (!self.sessionsDict[sessionId]) return;
    
    [self.sessionsDict removeObjectForKey:sessionId];
    [[TTIMSDKService sharedInstance] deleteSession:sessionId];
}

#pragma mark -

- (void)handleNewMessage:(TTIMChatMessage *)chatMsg sessionName:(NSString *)sessionName
{
    [self handleNewMessage:chatMsg sessionName:sessionName newCount:([chatMsg isSelf] ? 0 : 1)];
}

- (void)handleNewMessage:(TTIMChatMessage *)chatMsg sessionName:(NSString *)sessionName newCount:(NSUInteger)newCount
{
    if (isEmptyString(sessionName) || !chatMsg) return;
    
    TTIMChatCenterModel *chatCenterModel = (TTIMChatCenterModel *)self.sessionsDict[sessionName];
    if (chatCenterModel) {
        
        if (chatCenterModel.latestMsg.clientMsgId <= chatMsg.clientMsgId) {
            chatCenterModel.unreadCount += newCount;
            [self generateChatCenterModel:chatCenterModel
                              withMessage:chatMsg
                                sessionId:sessionName];
            
            !self.didAddNewMessageHandler ? : self.didAddNewMessageHandler([self.sessionsDict copy]);
        }
        
    } else {
        
        TTIMChatCenterModel *chatCenterModel = [TTIMChatCenterModel new];
        chatCenterModel.unreadCount = newCount;
        [self generateChatCenterModel:chatCenterModel
                          withMessage:chatMsg
                            sessionId:sessionName];
        
        chatCenterModel = [[self class] filteredModelWithIMChatCenterModel:chatCenterModel];
        [self.sessionsDict setValue:chatCenterModel forKey:sessionName]; // if is nil, remove it
        
        !self.didAddNewMessageHandler ? : self.didAddNewMessageHandler([self.sessionsDict copy]);
    }
}

#pragma mark - 

- (void)onAdd:(NSString *)sessionName msg:(TTIMChatMessage *)chatMsg
{
    [self handleNewMessage:chatMsg sessionName:sessionName];
}

- (void)onSendAck:(NSString *)sessionName msg:(TTIMChatMessage *)chatMsg
{
    if (![self.sessionsDict.allKeys containsObject:sessionName]) return;
    
    [self handleNewMessage:chatMsg sessionName:sessionName];
}

- (void)onUpdate:(NSString *)sessionName msg:(TTIMChatMessage *)chatMsg
{
    [self handleNewMessage:chatMsg sessionName:sessionName];
}

- (void)onGet:(NSString *)sessionName msgs:(NSArray *)listMsg
{
    if (isEmptyString(sessionName) || (listMsg.count == 0)) return;
    
    TTIMChatCenterModel *chatCenterModel = (TTIMChatCenterModel *)self.sessionsDict[sessionName];
    __block NSUInteger newCount = 0;
    [listMsg enumerateObjectsUsingBlock:^(TTIMChatMessage * _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![msg isSelf] && chatCenterModel.latestMsg.svrMsgId < msg.svrMsgId && msg.isShow == IMMsgNotDelete) newCount ++;
    }];
    
    if (newCount == 0) return;
    
    [self handleNewMessage:listMsg.lastObject sessionName:sessionName newCount:newCount];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTIMNewMessageDidReceivedNotification object:nil];
    [[TTPLManager sharedManager] refreshUnreadNumber];
}

- (void)onMsgCenterQuery:(NSDictionary*)dic
{
    if (self.resultHandler) {
        [self.sessionsDict removeAllObjects];
        
        for (NSString *sessionId in dic.allKeys) {
            
            TTIMSessioniItem *item = dic[sessionId];
            
            TTIMChatCenterModel *chatCenterModel = [TTIMChatCenterModel new];
            chatCenterModel.unreadCount = item.mUnReadCount;
            [self generateChatCenterModel:chatCenterModel
                              withMessage:item.lastMsg
                                sessionId:sessionId];
            chatCenterModel = [[self class] filteredModelWithIMChatCenterModel:chatCenterModel];
            if (chatCenterModel) {
                [self.sessionsDict setValue:chatCenterModel forKey:sessionId];
            }
        }
        
        // 为了保持数据库中的userData和服务端同步，需要在从IMSDK拿到sessionID列表后刷新本地数据库中的值
        NSArray<NSString *> *userIDs = dic.allKeys;
        [TTUserServices fetchUserDatasWithUserIds:userIDs completion:^(NSArray<TTUserData *> * _Nullable userDatas, BOOL success) {
            if (success) {
                [userDatas enumerateObjectsUsingBlock:^(TTUserData * _Nonnull userData, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *userID = userData.userId;
                    TTIMChatCenterModel *model = [self.sessionsDict valueForKey:userID];
                    model = [[self class] filteredModelWithIMChatCenterModel:model];
                    if (!model) {
                        [self.sessionsDict removeObjectForKey:userID];
                    }
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    !self.didAddNewMessageHandler ? : self.didAddNewMessageHandler([self.sessionsDict copy]);
                });
            }
        }];
        self.resultHandler(self.sessionsDict);
    }
    [[TTPLManager sharedManager] refreshUnreadNumber];
}

#pragma mark - 

- (void)generateChatCenterModel:(TTIMChatCenterModel *)chatCenterModel withMessage:(TTIMChatMessage *)msg sessionId:(NSString *)sessionId
{
    if (isEmptyString(sessionId)) {
        return;
    }
    chatCenterModel.sessionId = sessionId;
    chatCenterModel.latestMsg = msg;
    chatCenterModel.displayedDate = [TTIMDateFormatter formattedDate4ChatCenter:[NSDate dateWithTimeIntervalSince1970:msg.createTime]];
    chatCenterModel.msgDescription = [[self class] msgContentDescriptionFromMessage:msg];
    
    TTUserData *userData = [TTUserData objectForPrimaryKey:sessionId];
    if (!userData) {
        [TTUserServices fetchUserDataWithUserId:sessionId completion:^(TTUserData * _Nullable userData, BOOL success) {
            if (success) {
                chatCenterModel.userModel = userData;
                TTIMChatCenterModel *filteredModel = [[self class] filteredModelWithIMChatCenterModel:chatCenterModel];
                if (!filteredModel) {
                    [self.sessionsDict removeObjectForKey:sessionId];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    !self.didAddNewMessageHandler ? : self.didAddNewMessageHandler([self.sessionsDict copy]);
                });
            }
        }];
    }
    chatCenterModel.userModel = userData;
    chatCenterModel.draft = [[TTPLManager sharedManager] getDraftWithSessionId:sessionId];
}

// 用于对IMChatCenterModel进行过滤，有可能直接返回nil（干掉这个Model）
+ (TTIMChatCenterModel *)filteredModelWithIMChatCenterModel:(TTIMChatCenterModel *)model
{
    if (!model) {
        return nil;
    }
    // 过滤拉黑用户
    if (model.userModel.isBlocking.boolValue) {
        return nil;
    }
    
    return model;
}

+ (NSString *)msgContentDescriptionFromMessage:(TTIMChatMessage *)msg
{
    // 处理系统暂不支持该类型消息的展示
    if (![TTIMMessage isSupportedMessageType:msg.msgType]) {
        return [TTIMMessage promptTextOfUnsupportedMessage];
    }
    
    NSString *msgDescription;
    switch (msg.msgType) {
        case IMMsgTypeText:
        case IMMsgTypeSystem:
        {
            if ([msg isKindOfClass:[TTIMMessage class]]) {
                msgDescription = [(TTIMMessage *)msg msgText];
            } else {
                NSDictionary *contentDict = [TTIMUtils dictionaryFromJSONString:msg.content];
                if ([contentDict isKindOfClass:[NSDictionary class]]) {
                    msgDescription = [contentDict valueForKey:@"text"];
                }
            }
        }
            break;
            
        case IMMsgTypeImage:
            msgDescription = @"[图片]";
            break;
            
        default:
            break;
    }
    
    if (msgDescription.length == 0) {
        msgDescription = @"[未知消息]";
    }
    
    return msgDescription;
}

@end

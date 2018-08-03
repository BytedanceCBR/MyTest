//
//  TTIMChatCenterViewModel.h
//  EyeU
//
//  Created by matrixzk on 11/8/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTIMMsgExt.h"

@class TTUserData, TTIMChatMessage;
@interface TTIMChatCenterModel : NSObject

@property (nonatomic, copy, readonly) NSString *sessionId;
@property (nonatomic, strong, readonly) TTUserData *userModel;
@property (nonatomic, strong, readonly) TTIMChatMessage *latestMsg;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, copy) NSString *draft;
@property (nonatomic, copy) NSString *msgDescription;
@property (nonatomic, copy) NSString *displayedDate;

@end

typedef void(^TTIMChatCenterDataSourceResultHandler)(NSDictionary<NSString *,TTIMChatCenterModel*> *sessions);
extern NSString * const kTTIMNewMessageDidReceivedNotification;

@interface TTIMChatCenterViewModel : NSObject <TTIMMsgExt>

@property (nonatomic, copy) TTIMChatCenterDataSourceResultHandler didAddNewMessageHandler;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *,TTIMChatCenterModel*> *sessionsDict;

- (void)fetchChatCenterSessionsWithResultHandler:(TTIMChatCenterDataSourceResultHandler)resultHandler;
- (void)generateChatCenterModel:(TTIMChatCenterModel *)chatCenterModel withMessage:(TTIMChatMessage *)msg sessionId:(NSString *)sessionId;
+ (NSString *)msgContentDescriptionFromMessage:(TTIMChatMessage *)msg;
- (void)removeChatWithSessionId:(NSString *)sessionId;

@end

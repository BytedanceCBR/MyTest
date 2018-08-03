//
//  TTIMMessageSender.h
//  EyeU
//
//  Created by matrixzk on 12/6/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kTTIMMediaMessageUploadProgressChangedNotification;

@class TTIMMessage;
@interface TTIMMessageSender : NSObject

+ (void)sendMessage:(TTIMMessage *)msg toUsers:(NSArray *)toUserIds;
+ (void)sendMessage:(TTIMMessage *)msg toUsers:(NSArray *)toUserIds needNotifyStory:(BOOL)notifyStory;
+ (void)sendMessage:(TTIMMessage *)msg fromUser:(NSString *)fromUserId toUsers:(NSArray *)toUserIds;
+ (void)sendMessage:(TTIMMessage *)msg fromUser:(NSString *)fromUserId toUsers:(NSArray *)toUserIds needNotifyStory:(BOOL)notifyStory;

@end

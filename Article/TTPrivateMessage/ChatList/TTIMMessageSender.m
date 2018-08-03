//
//  TTIMMessageSender.m
//  EyeU
//
//  Created by matrixzk on 12/6/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMMessageSender.h"

#import "TTIMMessage.h"
#import "TTIMSDKService.h"
#import <TTAccountBusiness.h>



NSString * const kTTIMMediaMessageUploadProgressChangedNotification = @"kTTIMMediaMessageUploadProgressChangedNotification";

@implementation TTIMMessageSender

+ (void)sendMessage:(TTIMMessage *)msg toUsers:(NSArray *)toUserIds
{
    [self sendMessage:msg toUsers:toUserIds needNotifyStory:NO];
}

+ (void)sendMessage:(TTIMMessage *)msg toUsers:(NSArray *)toUserIds needNotifyStory:(BOOL)notifyStory
{
    NSString *fromUserId = [TTAccountManager userID];
    [self sendMessage:msg fromUser:fromUserId toUsers:toUserIds needNotifyStory:notifyStory];
}

+ (void)sendMessage:(TTIMMessage *)msg fromUser:(NSString *)fromUserId toUsers:(NSArray *)toUserIds
{
    [self sendMessage:msg fromUser:fromUserId toUsers:toUserIds needNotifyStory:NO];
}

+ (void)sendMessage:(TTIMMessage *)msg fromUser:(NSString *)fromUserId toUsers:(NSArray *)toUserIds needNotifyStory:(BOOL)notifyStory
{
//    if (toUserIds.count == 0) {
//        NSLog(@">>>> ttim >>>> UserId can't be NULL.");
//        return;
//    }
    
    msg.fromUser = [fromUserId longLongValue];
    msg.sendDate = [NSDate date];
    
    // 如果只发送给一个user，就不对msg做copy了，因为有些场景对该msg是有KVO的，比如重发时。
//    NSMutableArray *msgArray;
//    if (toUserIds.count == 1) {
//        NSString *userId = toUserIds.firstObject;
//        if (userId.length > 0) {
//            msg.toUser = userId;
//            msgArray = [NSMutableArray arrayWithObject:msg];
//        }
//    } else {
//        msgArray = [[NSMutableArray alloc] initWithCapacity:toUserIds.count];
//        [toUserIds enumerateObjectsUsingBlock:^(NSString * _Nonnull userId, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (userId.length == 0) { return; }
//            TTIMMessage *message = [msg copy];
//            message.toUser = userId;
//            [msgArray addObject:message];
//        }];
//    }
    
    NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:toUserIds.count];
    [toUserIds enumerateObjectsUsingBlock:^(NSString * _Nonnull userId, NSUInteger idx, BOOL * _Nonnull stop) {
        if (userId.length == 0) { return; }
        TTIMMessage *message = [msg copy];
        message.toUser = userId;
        message.shouldShowCellAnimation = YES;
        [msgArray addObject:message];
    }];
    
    if (msgArray.count == 0) { return; }
    
    if (notifyStory) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTEUMultimediaWillUploadCompletionNotification object:nil];
    }
    
    switch (msg.messageType) {
        case TTIMMessageTypeText:
//        case TTIMMessageTypeMagicExpression:
            for (TTIMMessage *msg in msgArray) {
                [[TTIMSDKService sharedInstance] sendMessage:msg];
            }
            break;
            
        case TTIMMessageTypeImage:
        {
            // 表情图片，直接发送
            if (msg.imageServerURL.length > 0) {
                for (TTIMMessage *msg in msgArray) {
                    msg.sendProgress = 1; // 避免显示loadingView
                    [[TTIMSDKService sharedInstance] sendMessage:msg];
                }
                break;
            }
            
            // 选取的本地图片，先上传，再发送
//            TEUImageUploadType type = msg.uploadOriginalPhoto ? TEUImageUploadTypeOriginal : TEUImageUploadTypeCompressed;
//            [self uploadImage:msg.tempLocalSelectedImage
//                         type:type
//          thenSendWrapperMsgs:msgArray
//              needNotifyStory:notifyStory];
        }
            break;
            
        default:
            break;
    }
}

//+ (void)uploadImage:(UIImage *)image type:(TEUImageUploadType)type thenSendWrapperMsgs:(NSArray *)msgArray needNotifyStory:(BOOL)notifyStory
//{
//    if (!image || msgArray.count == 0) {
//        NSLog(@">>> ttim >>> send image msg, but image is NULL !");
//    }
//    
//    for (TTIMMessage *msg in msgArray) {
//        msg.sendState = TTIMMessageSendStatePrepared;
//        [[TTIMSDKService sharedInstance] addMessage:msg];
//    }
//    
//    [TEUMultiMediaUploader uploadImage:image type:type progressBlk:^(CGFloat completedProgress) {
//        for (TTIMMessage *msg in msgArray) {
//            // NSLog(@">>> progress upload : %@", @(completedProgress));
//            msg.sendProgress = completedProgress;
//            [[NSNotificationCenter defaultCenter] postNotificationName:kTTIMMediaMessageUploadProgressChangedNotification object:msg];
//        }
//    } completionBlk:^(NSDictionary *respObj, NSError *error) {
//        
//        void(^handleError)() = ^() {
//            for (TTIMMessage *msg in msgArray) {
//                msg.sendState = TTIMMessageSendStateFailed;
//                [[TTIMSDKService sharedInstance] updateMessage:msg];
//            }
//            if (notifyStory) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:kTEUMultimediaDidUploadCompletionNotification object:nil userInfo:nil];
//            }
//        };
//        
//        if (error) {
//            handleError();
//        } else {
//            
//            if (![respObj isKindOfClass:[NSDictionary class]]) {
//                handleError();
//                return;
//            }
//            
//            NSString *imageURL = [[respObj tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"image_url"];
//            if (imageURL.length > 0) {
//                for (TTIMMessage *msg in msgArray) {
//                    msg.imageServerURL = imageURL;
//                    [msg generateMessageContent];
//                    
//                    // 上传成功后清空ext信息
//                    msg.ext = @"";
//                    
//                    [[TTIMSDKService sharedInstance] sendMessage:msg];
//                }
//                
//                if (notifyStory) {
//                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
//                    [userInfo setValue:@(TEUStoryUploadMediaTypeImage)
//                                forKey:kTEUStoryUploadMediaTypeKey];
//                    [userInfo setValue:imageURL
//                                forKey:kTEUStoryUploadImageURLKey];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kTEUMultimediaDidUploadCompletionNotification object:nil userInfo:[userInfo copy]];
//                }
//                
//            } else {
//                handleError();
//            }
//        }
//    }];
//}
//

@end

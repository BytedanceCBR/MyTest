//
//  TTIMMessage.h
//  EyeU
//
//  Created by matrixzk on 10/20/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TTIMChatMessage.h"
#import "TTIMCommonDef.h"

typedef NS_ENUM(NSInteger, TTIMMessageType) {
    TTIMMessageTypeSystem  = IMMsgTypeSystem,
    TTIMMessageTypeText    = IMMsgTypeText,
    TTIMMessageTypeImage   = IMMsgTypeImage,
};

typedef NS_ENUM(NSInteger, TTIMMessageSubtype) {
    TTIMMessageSubtypeUnsupportedMsgPrompt = 100
};

typedef NS_ENUM(NSInteger, TTIMMessageSendState) {
    TTIMMessageSendStateNormal   = IMMsgStatusNormal,   // server 返回的消息状态
    TTIMMessageSendStatePrepared = IMMsgStatusPending,  // 发送图片等文件消息时上传 server 时的状态
    TTIMMessageSendStateSending  = IMMsgStatusSending,  // 消息信息发送中状态
    TTIMMessageSendStateSuccess  = IMMsgStatusSuccess,  // 消息发送成功
    TTIMMessageSendStateFailed    = IMMsgStatusFail      // 消息发送失败
};


@protocol TTIMMessageSendStateDelegate <NSObject>

@optional
- (void)ttimMessageSendStateChanged:(TTIMMessageSendState)newState;
- (void)ttimMessageSendProgressChanged:(CGFloat)newProgress;

@end

extern NSString * const kTTIMUnsupportedMsgPromptHighlightedText;


@interface TTIMMessage : TTIMChatMessage <NSCopying>

@property (nonatomic, weak) id<TTIMMessageSendStateDelegate> delegate;
@property (nonatomic, assign) TTIMMessageSendState sendState;
@property (nonatomic, assign) CGFloat sendProgress;

@property (nonatomic, copy, readonly) NSString *avatarImageURL;
@property (nonatomic, assign) TTIMMessageType messageType;
@property (nonatomic, assign) TTIMMessageSubtype messageSubtype;
@property (nonatomic, strong) NSDate *sendDate;

@property (nonatomic, copy) NSString *msgText;
@property (nonatomic, copy) NSString *msgTextContentRichSpans;

@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) UIImage *tempLocalSelectedImage;

/// 相机拍摄返回的图片URL
@property (nonatomic, copy) NSString *localCameraImageURL;
@property (nonatomic) BOOL uploadOriginalPhoto;

/// 从本地相册取出的照片或视频，类型为PHAsset(>=iOS8) 或 ALAsset(<iOS8)。
@property (nonatomic, strong) id assert;
@property (nonatomic, copy) NSString *assertIdentifier;

@property (nonatomic) CGSize imageOriginSize;
@property (nonatomic, copy) NSString *imageServerURL;

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *localVideoPath;

/// 魔法表情名字，用于列表显示图片
@property (nonatomic, copy) NSString *magicExpressionName;

/// 若不为nil，则在cell上展示msg发送时间
@property (nonatomic, copy) NSString *formattedSendDate;

/// 对文本消息的文本size作缓存
@property (nonatomic, strong) NSValue *cachedTextSize;

/// 是否已展示在聊天列表，用于cell动画
@property (nonatomic, assign) BOOL shouldShowCellAnimation;

/**
 *  从IMSDK过来的消息是 `TTIMChatMessage` 类型，经该方法初始化为 `TTIMMessage` 类型
 */
- (instancetype)initWithChatMessage:(TTIMChatMessage *)chatMsg;

/**
 *  将消息内容转换为json格式作消息发送(端与端间约定的消息格式)
 */
- (void)generateMessageContent;

/**
 *  提取消息主要内容做序列化，以备重发
 */
- (void)generateMessageExtraInfo;

/**
 *  版本兼容，是否为当前版本支持的消息类型
 */
+ (BOOL)isSupportedMessageType:(IMMsgType)msgType;

/**
 *  发送系统提示消息，使用指定的文本
 */
+ (void)sendPromptMessageWithText:(NSString *)text toUser:(NSString *)toUserId;

@end

@interface TTIMMessage (MessageText)

/**
 * 发送失败的提示文案
 */
+ (NSString *)promptTextOfFailedMessageWithErrorCode:(IMErrorCode)errorCode;

/**
 * 版本兼容，当前版本不支持的消息类型显示该文本
 */
+ (NSString *)promptTextOfUnsupportedMessage;

/**
 * 第一次对话的提示文案
 */
+ (NSString *)promptTextOfWelcomeMessage;

@end

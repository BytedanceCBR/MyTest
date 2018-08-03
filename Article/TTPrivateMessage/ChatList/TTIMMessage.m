//
//  TTIMMessage.m
//  EyeU
//
//  Created by matrixzk on 10/20/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMMessage.h"

#import "TTIMUtils.h"
#import "TTInstallIDManager.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <TTAccountBusiness.h>
#import "TTUserServices.h"
#import "TTUserData.h"
#import "TTIMSDKService.h"

static NSString * const kTTIMMsgContentTextKey           = @"text"; // 文本信息内容
static NSString * const kTTIMMsgContentTextRichSpanKey           = @"text_rich_span"; // 文本信息内容
static NSString * const kTTIMMsgContentImageServerURLKey = @"url"; // server生成的图片url
static NSString * const kTTIMMsgContentImageWidthKey     = @"width"; // 图片宽，用户UI布局占位
static NSString * const kTTIMMsgContentImageHeightKey    = @"height"; // 图片高，用户UI布局占位

// cell文本高度缓存Key
static NSString * const kTTIMDeviceLandscapeKey = @"kTTIMDeviceLandscapeKey";
static NSString * const kTTIMDevicePortraitKey  = @"kTTIMDevicePortraitKey";

// 相册中的图片id，PHAsset(>=iOS8) 或 ALAsset(<iOS8)的资源标识
static NSString * const kTTIMMessageAssertIdentifierKey = @"kTTIMMessageAssertIdentifierKey";
static NSString * const kTTIMMessageLocalImageSizeKey   = @"kTTIMMessageLocalImageSizeKey";

// 相机拍摄返回的视频或照片
static NSString * const kTTIMMessageCameraImageURLKey   = @"kTTIMMessageCameraImageURLKey";

// 提示文案
NSString * const kTTIMUnsupportedMsgPromptHighlightedText = @"立即更新";

@interface TTIMMessage ()

@property (nonatomic, copy) NSString *avatarImageURL;
@property (nonatomic, strong) NSMutableDictionary *cellTextSizeCacheDict;

@end

@implementation TTIMMessage

@synthesize sendDate = _sendDate;

- (instancetype)initWithChatMessage:(TTIMChatMessage *)chatMsg {
    if (self = [super init]) {
        if (chatMsg) {
            self.svrMsgId = chatMsg.svrMsgId;
            self.clientMsgId = chatMsg.clientMsgId;
            self.deviceId = chatMsg.deviceId;
            self.fromUser = chatMsg.fromUser;
            self.toUser = chatMsg.toUser;
            self.createTime = chatMsg.createTime;
            self.messageType = (TTIMMessageType)chatMsg.msgType;
            self.isRead = chatMsg.isRead;
            self.isShow = chatMsg.isShow;
            self.errorCode = chatMsg.errorCode;
            self.originCid = chatMsg.originCid;

            // sendState 和 sendDate 重写了 setter 方法，这里同时对 status 和 createTime 赋值了
            self.sendState = (TTIMMessageSendState)chatMsg.status;
            self.sendDate = [NSDate dateWithTimeIntervalSince1970:chatMsg.createTime];
            
            if (chatMsg.content.length > 0) {
                self.content = chatMsg.content;
                [self parseMessageContent:chatMsg.content];
            }
            
            // 这里在某种情况下会更改了self.content解析赋的值，有隐患
            if ([chatMsg isSelf] && chatMsg.ext.length > 0) {
                self.ext = chatMsg.ext;
                [self parseMessageExtraInfo:chatMsg.ext];
            }
            
            [self checkMessageValidity];
        }
    }
    return self;
}

- (instancetype)init {
    if (self = [self initWithChatMessage:nil]) {
        self.deviceId = [[[TTInstallIDManager sharedInstance] deviceID] longLongValue];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    TTIMMessage *copyMsg = [[self class] allocWithZone:zone];
    
    copyMsg->_sendState = _sendState;
    copyMsg->_sendProgress = _sendProgress;
    copyMsg.messageType = _messageType;
    copyMsg.messageSubtype = _messageSubtype;
    copyMsg.sendDate = _sendDate;
    copyMsg.msgText = _msgText;
    copyMsg.msgTextContentRichSpans = _msgTextContentRichSpans;
    copyMsg.thumbImage = _thumbImage;
    copyMsg.tempLocalSelectedImage = _tempLocalSelectedImage;
    copyMsg.localCameraImageURL = _localCameraImageURL;
    copyMsg.assert = _assert;
    copyMsg.assertIdentifier = _assertIdentifier;
    copyMsg.imageOriginSize = _imageOriginSize;
    copyMsg.imageServerURL = _imageServerURL;
    copyMsg.videoId = _videoId;
    copyMsg.localVideoPath = _localVideoPath;
    copyMsg.formattedSendDate = _formattedSendDate;
    copyMsg.magicExpressionName = _magicExpressionName;
    copyMsg.uploadOriginalPhoto = _uploadOriginalPhoto;
    
    copyMsg.deviceId = self.deviceId;
    copyMsg.clientMsgId = self.clientMsgId;
    copyMsg.svrMsgId = self.svrMsgId;
    copyMsg.fromUser = self.fromUser;
    copyMsg.toUser = self.toUser;
    copyMsg.isRead = self.isRead;
    copyMsg.isShow = self.isShow;
    copyMsg.content = self.content;
    copyMsg.ext = self.ext;
    copyMsg.errorCode = self.errorCode;
    copyMsg.originCid = self.originCid;
    
    return copyMsg;
}

// 校验消息的合法性，并对消息类型和显示做相应校正(只作显示用，不改变已入库的消息数据)
- (BOOL)checkMessageValidity {
    BOOL isSupported = [self.class isSupportedMessageType:self.msgType];
    
    if (!isSupported) {
        // 不支持的消息类型，用转为文本类型消息展示，并做相应提示
        self.messageType = TTIMMessageTypeText;
        self.messageSubtype = TTIMMessageSubtypeUnsupportedMsgPrompt;
        self.msgText = [self.class promptTextOfUnsupportedMessage];
        self.msgTextContentRichSpans = nil;
    }
    
    return isSupported;
}

+ (BOOL)isSupportedMessageType:(IMMsgType)msgType
{
    TTIMMessageType messageType = (TTIMMessageType)msgType;
    
    BOOL isSupported = YES;
    switch (messageType) {
        case TTIMMessageTypeText:
//        case TTIMMessageTypeImage:// NK_WARNING: 这个版本不支持图片
        case TTIMMessageTypeSystem:
            break;
            
        default:
            isSupported = NO;
            break;
    }
    
    return isSupported;
}

+ (void)sendPromptMessageWithText:(NSString *)text toUser:(NSString *)toUserId
{
    if (isEmptyString(text) || isEmptyString(toUserId)) {
        return;
    }
    
    TTIMMessage *message = [TTIMMessage new];
    message.messageType = TTIMMessageTypeSystem;
    message.msgText = text;
    message.toUser = toUserId;
    message.fromUser = [TTAccountManager userID].longLongValue;
    message.sendDate = [NSDate date];
    [message generateMessageContent];
    
    [[TTIMSDKService sharedInstance] addMessage:message];
}

#pragma mark - cell cache

- (void)setCachedTextSize:(NSValue *)cachedTextSize
{
    NSString *key = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kTTIMDevicePortraitKey : kTTIMDeviceLandscapeKey;
    self.cellTextSizeCacheDict[key] = cachedTextSize;
}

- (NSValue *)cachedTextSize
{
    NSString *key = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kTTIMDevicePortraitKey : kTTIMDeviceLandscapeKey;
    if ([TTDeviceHelper isPadDevice] == NO){
        key = kTTIMDevicePortraitKey;
    }
    return self.cellTextSizeCacheDict[key] ? : nil;
}

#pragma mark - getter
- (NSString *)avatarImageURL
{
    if (!_avatarImageURL) {
        NSString *avatarUrl;
        if ([self isSelf]) {
            avatarUrl = [TTAccountManager avatarURLString];
        } else {
            NSString *userID = [NSString stringWithFormat:@"%lld", self.fromUser];
            TTUserData *userData = [TTUserData objectForPrimaryKey:userID];
            avatarUrl = userData.avatarUrl;
            if (!avatarUrl) {
                [TTUserServices fetchUserDataWithUserId:userID completion:^(TTUserData * _Nullable userData, BOOL success) {
                    if (success) {
                        _avatarImageURL = userData.avatarUrl;
                    }
                }];
            }
        }
        _avatarImageURL = avatarUrl;
    }
    return _avatarImageURL;
}

- (NSMutableDictionary *)cellTextSizeCacheDict
{
    if (!_cellTextSizeCacheDict) {
        _cellTextSizeCacheDict = [NSMutableDictionary dictionary];
    }
    return _cellTextSizeCacheDict;
}

#pragma mark -

- (void)generateMessageContent
{
    NSMutableDictionary *contentDict = [NSMutableDictionary new];
    
    switch (self.messageType) {
        case TTIMMessageTypeText:
        case TTIMMessageTypeSystem:
            [contentDict setValue:self.msgText forKey:kTTIMMsgContentTextKey];
            break;
            
        case TTIMMessageTypeImage:
            [contentDict setValue:self.imageServerURL
                           forKey:kTTIMMsgContentImageServerURLKey];
            [contentDict setValue:@(self.imageOriginSize.width)
                           forKey:kTTIMMsgContentImageWidthKey];
            [contentDict setValue:@(self.imageOriginSize.height)
                           forKey:kTTIMMsgContentImageHeightKey];
            break;
        default:
            break;
    }
    
    self.content = [TTIMUtils jsonStringFromDictionary:contentDict];
}

- (void)parseMessageContent:(NSString *)msgContent
{
    NSDictionary *contentDict = [TTIMUtils dictionaryFromJSONString:msgContent];
    if (!([contentDict isKindOfClass:[NSDictionary class]] && contentDict.count > 0)) {
        return;
    }
    
    switch (self.messageType) {
        case TTIMMessageTypeText:
        case TTIMMessageTypeSystem:
            self.msgText = contentDict[kTTIMMsgContentTextKey];
            self.msgTextContentRichSpans = contentDict[kTTIMMsgContentTextRichSpanKey];
            break;
            
        case TTIMMessageTypeImage:
            self.imageServerURL = contentDict[kTTIMMsgContentImageServerURLKey];
            self.imageOriginSize = CGSizeMake([contentDict[kTTIMMsgContentImageWidthKey] floatValue],
                                              [contentDict[kTTIMMsgContentImageHeightKey] floatValue]);
            break;
        default:
            //处理系统暂不支持该类型消息的展示
            break;
    }
}


// 主要保存多媒体消息信息，入库，用于再次展示在界面上时做消息重发。
- (void)generateMessageExtraInfo
{
    NSMutableDictionary *extraDict = [NSMutableDictionary new];
    
    switch (self.messageType) {
        case TTIMMessageTypeImage:
        {
            NSString *identifier;
            if ([self.assert isKindOfClass:[PHAsset class]]) {
                identifier = [(PHAsset *)self.assert localIdentifier];
            } else if ([self.assert isKindOfClass:[ALAsset class]]) {
                identifier = [(ALAsset *)self.assert defaultRepresentation].url.absoluteString;
            }
            [extraDict setValue:identifier forKey:kTTIMMessageAssertIdentifierKey];
            
            [extraDict setValue:NSStringFromCGSize(self.imageOriginSize)
                         forKey:kTTIMMessageLocalImageSizeKey];
            
            // 相机拍摄返回的图片URL
            [extraDict setValue:self.localCameraImageURL
                         forKey:kTTIMMessageCameraImageURLKey];
        } break;
            
        default:
            break;
    }
    
    self.ext = [TTIMUtils jsonStringFromDictionary:extraDict];
}

- (void)parseMessageExtraInfo:(NSString *)extraInfo
{
    NSDictionary *extraDict = [TTIMUtils dictionaryFromJSONString:extraInfo];
    if (!([extraDict isKindOfClass:[NSDictionary class]] && extraDict.count > 0)) {
        return;
    }
    
    switch (self.messageType) {
        case TTIMMessageTypeImage:
        {
            self.imageOriginSize = CGSizeFromString(extraDict[kTTIMMessageLocalImageSizeKey]);
            self.assertIdentifier = extraDict[kTTIMMessageAssertIdentifierKey];
            self.localCameraImageURL = extraDict[kTTIMMessageCameraImageURLKey];
        } break;
            
        default:
            //处理系统暂不支持该类型消息的展示
            break;
    }
}


#pragma mark - override super property

- (void)setMessageType:(TTIMMessageType)messageType
{
    _messageType = messageType;
    self.msgType = (IMMsgType)messageType;
}

- (void)setSendDate:(NSDate *)sendDate
{
    _sendDate = sendDate;
    self.createTime = [sendDate timeIntervalSince1970];
}

- (NSDate *)sendDate
{
    if (_sendDate) {
        return _sendDate;
    }
    return [NSDate dateWithTimeIntervalSince1970:self.createTime];
}

- (void)setStatus:(IMMsgStatus)status
{
    // TODO: 私信需求的临时方案，有坑，依赖于 TTIMSDK 中对 errorCode 和 status 的赋值顺序
    if (status == IMMsgStatusFail &&
        (self.errorCode == IMErrorCodeMessageIllegal/* || self.errorCode == IMErrorCodeUserForbidden*/)) {
        status = IMMsgStatusSuccess;
    }
    
    [super setStatus:status];
    // 这里必须触发setter方法，进而触发delegate回调
    
    self.sendState = (TTIMMessageSendState)status;
}

- (IMMsgStatus)status
{
    return (IMMsgStatus)_sendState;
}

#pragma mark - setter

- (void)setSendState:(TTIMMessageSendState)sendState
{
    _sendState = sendState;
    [super setStatus:(IMMsgStatus)sendState];
    if ([self.delegate respondsToSelector:@selector(ttimMessageSendStateChanged:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate ttimMessageSendStateChanged:sendState];
        });
    }
}

- (void)setSendProgress:(CGFloat)sendProgress
{
    _sendProgress = sendProgress;
    
    // NSLog(@">>>>> progress msg : %@", @(sendProgress));
    if ([self.delegate respondsToSelector:@selector(ttimMessageSendProgressChanged:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate ttimMessageSendProgressChanged:sendProgress];
        });
    }
}

@end

@implementation TTIMMessage (MessageText)

+ (NSString *)promptTextOfFailedMessageWithErrorCode:(IMErrorCode)errorCode;
{
    NSString *text;
    switch (errorCode) {
        case IMErrorCodeUserForbidden: {
            // 被对方拉黑
            text = @"你已被对方拉黑，不可发送消息";
        }
            break;
        case IMErrorCodeUserNotFriends: {
            // 未关注对方
            text = @"你未关注对方，不可发送消息";
        }
            break;
            
        default:
            break;
    }
    
    return text;
}

+ (NSString *)promptTextOfUnsupportedMessage
{
    return [NSString stringWithFormat:@"当前版本不支持查看此消息，请更新后查看。 %@", kTTIMUnsupportedMsgPromptHighlightedText];
}

+ (NSString *)promptTextOfWelcomeMessage
{
    return [NSString stringWithFormat:@"现在可以开始聊天了"];
}

@end

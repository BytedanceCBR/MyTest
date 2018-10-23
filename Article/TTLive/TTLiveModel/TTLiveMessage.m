//
//  TTLiveMessage.m
//  Article
//
//  Created by matrixzk on 1/28/16.
//
//

#import "TTLiveMessage.h"
#import <TTAccountManager.h>
#import <TTDeviceHelper.h>
static NSString *TTLiveDeviceLandscapeKey = @"TTLiveDeviceLandscapeKey";
static NSString *TTLiveDevicePortraitKey  = @"TTLiveDevicePortraitKey";

@implementation TTLiveMessageCard

@end

@interface TTLiveMessage ()
@end

@implementation TTLiveMessage
{
    NSMutableDictionary *_cellTextSizeCacheDict;
    NSMutableDictionary *_cellContentSizeCacheDict;
}

@synthesize cachedSizeOfCellText = _cachedSizeOfCellText;
@synthesize cachedSizeOfCellContent = _cachedSizeOfCellContent;

- (void)dealloc
{
    if (TTLiveMessageTypeVideo == self.msgType &&
        TTLiveMessageNetworkStateLoading == self.networkState) {
        [self.msgSender cancelVideoUpload];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _networkState = TTLiveMessageNetworkStatePrepared;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    TTLiveMessage *copyedMsg = [[self class] allocWithZone:zone];
    
    copyedMsg.msgId = _msgId;
    copyedMsg.sendTime = _sendTime;
    copyedMsg.msgType = _msgType;
    copyedMsg.msgTag = _msgTag;
    copyedMsg.likeCount = _likeCount;
    copyedMsg.liked = _liked;
    
    copyedMsg.replyedMessage = _replyedMessage;
    
    copyedMsg.userId = _userId;
    copyedMsg.userRoleName = _userRoleName;
    copyedMsg.userDisplayName = _userDisplayName;
    copyedMsg.userAvatarURLStr = _userAvatarURLStr;
    copyedMsg.userVip = _userVip;
    
    copyedMsg.openURLStr = _openURLStr;
    copyedMsg.link = _link;
    
    copyedMsg.msgText = _msgText;
    copyedMsg.localSelectedImageURL = _localSelectedImageURL;
    copyedMsg.localSelectedVideoURL = _localSelectedVideoURL;
    copyedMsg.localWavAudioURL = _localWavAudioURL;
    
    copyedMsg.mediaFileUrl = _mediaFileUrl;
    copyedMsg.mediaFileSize = _mediaFileSize;
    copyedMsg.mediaFileDuration = _mediaFileDuration;
    copyedMsg.mediaFileSourceId = _mediaFileSourceId;
    
    copyedMsg.cardModel = _cardModel;
    copyedMsg.imageModel = _imageModel;
    copyedMsg.sizeOfOriginImage = _sizeOfOriginImage;
    copyedMsg.audioHadPlayed = _audioHadPlayed;
    
    copyedMsg.networkState = TTLiveMessageNetworkStateSuccess;
    
    // 默认只有给被回复的msg赋值时才用copy
    copyedMsg.isReplyedMsg = YES;
    copyedMsg.disableComment = _disableComment;
    copyedMsg.isTop = _isTop;
    
    return copyedMsg;
}

- (void)setNetworkState:(TTLiveMessageNetworkState)networkState
{
    _networkState = networkState;
    
    if ([self.delegate respondsToSelector:@selector(ttLiveMessageSendStateChanged:)]) {
        [self.delegate ttLiveMessageSendStateChanged:_networkState];
    }
}

- (void)setLoadingProgress:(NSNumber *)loadingProgress
{
    _loadingProgress = loadingProgress;
    
    if ([self.delegate respondsToSelector:@selector(ttLiveMessageSendProgressChanged:)]) {
        [self.delegate ttLiveMessageSendProgressChanged:_loadingProgress];
    }
}

- (void)setCellLayout:(TTLiveCellLayout)cellLayout{
    _cellLayout = cellLayout;
    if ([self.userId isEqualToString: [TTAccountManager userID]]){
        _cellLayout = 0;
        if (cellLayout & TTLiveCellLayoutIsTop) {
            _cellLayout = TTLiveCellLayoutIsTop;
        }
    }
}

#pragma mark - cell cache

- (void)setCachedSizeOfCellText:(NSValue *)cachedSizeOfCellText
{
    if (!_cellTextSizeCacheDict) {
        _cellTextSizeCacheDict = [NSMutableDictionary dictionary];
    }
    
    NSString *key = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? TTLiveDevicePortraitKey : TTLiveDeviceLandscapeKey;
    _cellTextSizeCacheDict[key] = cachedSizeOfCellText;
}

- (void)setCachedSizeOfCellContent:(NSValue *)cachedSizeOfCellContent
{
    if (!_cellContentSizeCacheDict) {
        _cellContentSizeCacheDict = [NSMutableDictionary dictionary];
    }
    NSString *key = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? TTLiveDevicePortraitKey : TTLiveDeviceLandscapeKey;
    _cellContentSizeCacheDict[key] = cachedSizeOfCellContent;
}

- (NSValue *)cachedSizeOfCellText
{
    NSString *key = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? TTLiveDevicePortraitKey : TTLiveDeviceLandscapeKey;
    if ([TTDeviceHelper isPadDevice] == NO){
        key = TTLiveDevicePortraitKey;
    }
    return _cellTextSizeCacheDict[key] ? : nil;
}

- (NSValue *)cachedSizeOfCellContent
{
    NSString *key = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? TTLiveDevicePortraitKey : TTLiveDeviceLandscapeKey;
    if ([TTDeviceHelper isPadDevice] == NO){
        key = TTLiveDevicePortraitKey;
    }
    return _cellContentSizeCacheDict[key] ? : nil;
}

#pragma 类方法
+ (instancetype)createMessageForHostTipWithMessage:(TTLiveMessage *)message{
    TTLiveMessage *hostTip = [[TTLiveMessage alloc] init];
    hostTip.userId = message.userId;
    hostTip.userDisplayName = message.userDisplayName;
    hostTip.userRoleName = message.userRoleName;
    hostTip.openURLStr = [NSString stringWithFormat:@"sslocal://profile?uid=%@", message.userId];
    hostTip.msgType = TTLiveMessageTypeHostTip;
    return hostTip;
}


@end

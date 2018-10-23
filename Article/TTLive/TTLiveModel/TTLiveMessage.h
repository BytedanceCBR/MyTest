//
//  TTLiveMessage.h
//  Article
//
//  Created by matrixzk on 1/28/16.
//
//

#import <Foundation/Foundation.h>
#import "TTImageInfosModel.h"
#import "TTLiveMessageSender.h"
#import "TTLiveCellHelper.h"
typedef NS_ENUM(NSInteger, TTLiveMessageType) {
    TTLiveMessageTypeText  = 1,
    TTLiveMessageTypeImage = 2,
    TTLiveMessageTypeAudio = 3,
    TTLiveMessageTypeVideo = 4,
    TTLiveMessageTypeProfileCard = 5,
    TTLiveMessageTypeMediaCard = 6,
    TTLiveMessageTypeArticleCard = 7,
    TTLiveMessageTypeHostTip = 8,
};

typedef NS_ENUM(NSInteger, TTLiveMessageNetworkState) {
    TTLiveMessageNetworkStatePrepared,
    TTLiveMessageNetworkStateLoading,
    TTLiveMessageNetworkStateSuccess,
    TTLiveMessageNetworkStateFaild
};


@protocol TTLiveMessageSendStateDelegate <NSObject>
@optional
- (void)ttLiveMessageSendStateChanged:(TTLiveMessageNetworkState)newState;
- (void)ttLiveMessageSendProgressChanged:(NSNumber *)newProgressNum;
@end

@interface TTLiveMessageCard : NSObject

@property (nonatomic, strong) NSString *cardId;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *vip;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *sourceIcon;
@property (nonatomic, strong) NSString *sourceName;

@end

@interface TTLiveMessage : NSObject <NSCopying>

@property (nonatomic, weak) id<TTLiveMessageSendStateDelegate> delegate;

//本地消息相关
@property (nonatomic, strong) NSNumber *msgId;
@property (nonatomic, copy)   NSString *sendTime;
@property (nonatomic, assign) TTLiveMessageType msgType;
@property (nonatomic, copy) NSString *msgTag;
@property (nonatomic, assign) NSUInteger likeCount;
@property (nonatomic, assign) BOOL liked;

// 默认只有给被回复的msg赋值时才用copy
@property (nonatomic, copy) TTLiveMessage *replyedMessage;
@property (nonatomic, assign) BOOL isReplyedMsg;

// User
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userDisplayName;
@property (nonatomic, copy) NSString *userRoleName;
@property (nonatomic, copy) NSString *userAvatarURLStr;
@property (nonatomic, strong) NSNumber *userVip;

//对外跳转链接
@property (nonatomic, copy) NSString *openURLStr;
@property (nonatomic, copy) NSString *link;

// Text
@property (nonatomic, copy) NSString *msgText;

/// Video & Audio &image

// media file source from local
@property (nonatomic, strong) NSURL *localSelectedVideoURL;
@property (nonatomic, strong) UIImage *tempLocalSelectedImage;
@property (nonatomic, strong) NSURL *localSelectedImageURL; //相册图片路径
@property (nonatomic, strong) NSURL *localWavAudioURL; // 用于播放
@property (nonatomic, strong) NSURL *localAmrAudioURL; // 用于上传server

// server 下发的音频或视频信息，用于去server取数据
@property (nonatomic, copy) NSString *mediaFileSourceId;
@property (nonatomic, copy) NSString *mediaFileDuration;
@property (nonatomic, copy) NSString *mediaFileSize;
@property (nonatomic, copy) NSString *mediaFileUrl;

//CardModel
@property (nonatomic, strong) TTLiveMessageCard *cardModel;

/// 用于显示在cell上的图片做缩放处理后的缩略图。
@property (nonatomic, strong) UIImage *thumbImage;
/// server拿到的数据转为model。
@property (nonatomic, strong) TTImageInfosModel *imageModel;
/// 原图size，用于UI布局。
@property (nonatomic) CGSize sizeOfOriginImage;

//网络成功与失败状态
@property (nonatomic, strong) TTLiveMessageSender *msgSender;
@property (nonatomic, assign) TTLiveMessageNetworkState networkState;
@property (nonatomic, strong) NSNumber *loadingProgress;

// flag
@property (nonatomic, assign) BOOL audioHadPlayed;
@property (nonatomic, assign) BOOL audioIsPlaying;
//@property (nonatomic, assign) BOOL hadDisplayed4EventTrack;


// cache
@property (nonatomic, strong) NSValue *cachedSizeOfCellText;
@property (nonatomic, strong) NSValue *cachedSizeOfCellContent;
//@property (nonatomic, strong) NSValue *sizeCacheOf

//禁止评论
@property (nonatomic, assign)BOOL disableComment;
//是否置顶
@property (nonatomic, assign)BOOL isTop;

// layout
@property (nonatomic, assign) TTLiveCellLayout cellLayout;

+ (instancetype)createMessageForHostTipWithMessage:(TTLiveMessage *)message;

@end

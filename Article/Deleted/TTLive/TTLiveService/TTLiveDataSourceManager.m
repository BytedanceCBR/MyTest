//
//  TTLiveDataSourceManager.m
//  Article
//
//  Created by matrixzk on 8/2/16.
//
//

#import "TTLiveDataSourceManager.h"

#import "TTLiveMainViewController.h"
#import "TTLiveChatTableViewController.h"

#import "NSTimer+Additions.h"
#import "NetworkUtilities.h"
#import "TTNetworkManager.h"

#import "TTIndicatorView.h"
#import "MJExtension.h"

#import "TTLiveStreamDataModel.h"
#import "TTLiveOverallInfoModel.h"
#import "TTLiveTopBannerInfoModel.h"
#import "TTLiveTabCategoryItem.h"
#import "TTMonitor.h"

@interface TTLiveDataSourceManager ()

@property (nonatomic, weak) TTLiveMainViewController *chatroom;
@property (nonatomic, strong) NSTimer *pollingTimer;
@property (nonatomic, strong) NSTimer *uploadPariseTimer;
@property (nonatomic, assign) BOOL couldRequestStreamInfo;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation TTLiveDataSourceManager

- (void)dealloc
{
    LOGD(@">>>>>>>> TTLiveDataSourceManager dealloc !!!");
    [_pollingTimer invalidate];
    _pollingTimer = nil;
    [_uploadPariseTimer invalidate];
    _uploadPariseTimer = nil;
}

- (instancetype)initWithChatroom:(TTLiveMainViewController *)chatroom
{
    self = [super init];
    if (self) {
        _chatroom = chatroom;
        _couldRequestStreamInfo = YES;
        
        [self setupMJExtensionModelMapping];
        
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.timeZone = [NSTimeZone localTimeZone];
        _dateFormatter.dateFormat = @"HH:mm";
    }
    return self;
}

- (NSString *)formattedTimeWithDate:(NSDate *)date
{
    return [_dateFormatter stringFromDate:date];
}

- (void)pauseTimer {
    [_pollingTimer tt_pause];
    [_uploadPariseTimer tt_pause];
}

- (void)resumeTimer {
    [_pollingTimer tt_resume];
    [_uploadPariseTimer tt_resume];
}

- (void)fetchHeaderInfoWithLiveId:(NSString *)liveId finishBlock:(void(^)(NSError *error, TTLiveTopBannerInfoModel *headerInfo, NSString *tips))finishBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:liveId forKey:@"live_id"];
    
    NSString *url = [NSString stringWithFormat:@"%@/info/", [CommonURLSetting liveTalkURLString]];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:@"GET" needCommonParams:YES callback:^(NSError *error,id jsonObj){
        
        if (error) {
            
            NSString *text;
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                text = [jsonObj objectForKey:@"tips"];
            }
            
            if (finishBlock) {
                finishBlock(error, nil,text);
            }
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:params];
            [dic setValue:@(error.code) forKey:@"error_code"];
            [[TTMonitor shareManager] trackService:@"ttlive_info" status:1 extra:dic];
            return ;
        }
        
        if (!finishBlock) {
            return;
        }
        
        id data;
        
        if ([jsonObj isKindOfClass:[NSDictionary class]]) {
            data = [jsonObj objectForKey:@"data"];
        }
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            finishBlock(error, [TTLiveTopBannerInfoModel mj_objectWithKeyValues:data], nil);
        }
    }];
}


// 调整轮询时间间隔
- (void)adjustPollingTimerWithTimeInterval:(NSTimeInterval)newInterval
{
    if (self.pollingTimer.timeInterval == newInterval) {
        return;
    }
    
    NSTimeInterval timeInterval = MAX(newInterval, 5);
    
    if (self.pollingTimer.timeInterval == timeInterval) {
        return;
    }
    
    if (self.pollingTimer) {
        [self.pollingTimer invalidate];
        self.pollingTimer = nil;
    }
    
    WeakSelf;
    self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval block:^{
        
        StrongSelf;
        
        if (!TTNetworkConnected()) {
            return ;
        }
        
//        if (self.swipePageVC.internalScrollView.tracking ||
//            self.swipePageVC.internalScrollView.decelerating ||
//            self.swipePageVC.internalScrollView.dragging) {
//            return ;
//        }
        
        UIViewController *currentChannelVC = [self.chatroom currentChannelVC];
        if ([currentChannelVC isKindOfClass:[TTLiveChatTableViewController class]]) {
            
            TTLiveChatTableViewController *chatVC = (TTLiveChatTableViewController *)currentChannelVC;
            [chatVC fetchLiveStreamDataSourceWithRefreshType:TTLiveMessageListRefreshTypePolling];
            
        } else {
            
            TTLiveChatTableViewController *chatVC = [self.chatroom suitableChatViewController];
            if ([chatVC isKindOfClass:[TTLiveChatTableViewController class]]) {
                [chatVC fetchLiveStreamDataSourceWithRefreshType:TTLiveMessageListRefreshTypePolling];
            }
        }
        
    } repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.pollingTimer forMode:NSRunLoopCommonModes];
}

- (void)uploadParise {
    NSTimeInterval timeInterval = 1;
    
    WeakSelf;
    self.uploadPariseTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval block:^{
        
        StrongSelf;
        
        if (!TTNetworkConnected()) {
            return ;
        }
        
        NSUInteger lastCount = self.chatroom.userDigCount;
        self.chatroom.userDigCount = 0;
        if (lastCount != 0) {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setValue:self.chatroom.overallModel.liveId forKey:@"live_id"];
            [params setValue:@(lastCount) forKey:@"like_count"];
            
            NSString *url = [NSString stringWithFormat:@"%@/infinite_like/",[CommonURLSetting liveTalkURLString]];
            [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:@"POST" needCommonParams:YES callback:^(NSError *error,id jsonObj){
                if (error) {
                    self.chatroom.userDigCount += lastCount;
                }
            }];
        }
        
    } repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.pollingTimer forMode:NSRunLoopCommonModes];
}

//- (void)fetchChatStreamDataSourceWithRefreshType:(TTLiveMsgListRefreshType)refreshType
//{   
//}

// 获取数据流数据
- (void)fetchStreamDataWithChannelItem:(TTLiveTabCategoryItem *)channelItem
                             isPolling:(BOOL)isPolling
                           resultBlock:(void (^)(NSError *error, TTLiveStreamDataModel *streamDataModel))resultBlock
{
    
    if (!self.couldRequestStreamInfo) {
        resultBlock(nil, nil);
        return;
    }
    self.couldRequestStreamInfo = NO;
    
    if (!channelItem) {
        resultBlock(nil, nil);
        self.couldRequestStreamInfo = YES;
        return;
    }
    
    TTLiveOverallInfoModel *chatroomInfo = self.chatroom.overallModel;
    
    NSMutableArray *cursorsArray = [[NSMutableArray alloc] initWithCapacity:chatroomInfo.channelItems.count];
    [chatroomInfo.channelItems enumerateObjectsUsingBlock:^(TTLiveTabCategoryItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableDictionary *cursorDict = [[NSMutableDictionary alloc] initWithCapacity:3];
        [cursorDict setValue:item.categoryId forKey:@"channel"];
        
        if (item.categoryId == channelItem.categoryId) {
            [cursorDict setValue:channelItem.history forKey:@"history"];
            [cursorDict setValue:[channelItem.history boolValue] ? channelItem.minCursor : channelItem.maxCursor
                          forKey:@"cursor"];
            
            // TODO: delete log
            // NSLog(@"--- use maxCursor : %@, %@", tableVC.channelItem.maxCursor, item.maxCursor);
            
        } else {
            item.history = @(0);
            [cursorDict setValue:item.history forKey:@"history"];
            [cursorDict setValue:item.maxCursor forKey:@"cursor"];
        }
        
        [cursorsArray addObject:cursorDict];
    }];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:chatroomInfo.liveId forKey:@"live_id"];
    [params setValue:@(0) forKey:@"media_real_play"];
    [params setValue:[self dictionaryToJsonString:cursorsArray] forKey:@"cursors"];
    [params setValue:[NSNumber numberWithUnsignedInteger:[self chatroom].lastInfiniteLike] forKey:@"last_infinite_like"];
    [params setValue:@"1" forKey:@"sequence"];
    // TODO: delete log.
    // NSLog(@"-- cursor : %@", params[@"cursors"]);
//#warning change
    NSString *url = [NSString stringWithFormat:/*@"http://10.6.131.78:9866/live_talk/stream/"];*/@"%@/stream/",[CommonURLSetting liveTalkURLString]];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:@"POST" needCommonParams:YES callback:^(NSError *error,id jsonObj){
        
        NSString *tips;
        TTLiveStreamDataModel *streamDataModel;
        if ([jsonObj isKindOfClass:[NSDictionary class]]) {
            tips = jsonObj[@"tips"];
            streamDataModel = [self changeModelToTheNeedModel:[TTLiveStreamDataModel mj_objectWithKeyValues:jsonObj[@"data"]]];
        }
        
        if (error && !isPolling) {
            
            if (isEmptyString(tips)) {
                tips = TTNetworkConnected() ? @"加载失败，请稍后重试" : @"没有网络";
            }
            
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:tips
                                     indicatorImage:nil
                                        autoDismiss:YES
                                     dismissHandler:nil];
        }
        if (error) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:@(error.code) forKey:@"error_code"];
            [dic setValue:chatroomInfo.liveId forKey:@"live_id"];
            [[TTMonitor shareManager] trackService:@"ttlive_polling" status:1 extra:dic];
        }
        resultBlock(error, error ? nil : streamDataModel);
        self.couldRequestStreamInfo = YES;
    }];
}

//生成实际使用的信息数组
- (TTLiveStreamDataModel *)changeModelToTheNeedModel:(TTLiveStreamDataModel *)originModel
{
    for (TTLiveMessageRegionModel *regionModel in originModel.msgRegionArray) {
        NSMutableArray *msgArray = [[NSMutableArray alloc] init];
        for (TTLiveMessageModel *messageModel in regionModel.messageArray) {
            
            TTLiveMessage *message = [self switchMessageModleToMessage:messageModel];
            
            [msgArray addObject:message];
        }
        
        regionModel.messageArray = msgArray;
    }
    
    return originModel;
}

- (TTLiveMessage *)switchMessageModleToMessage:(TTLiveMessageModel *)messageModel
{
    TTLiveMessage *message = [[TTLiveMessage alloc] init];
    message.msgId = messageModel.msgId;
    message.msgTag = messageModel.tag;
    // 如果服务端下发tag(比赛时间)则优先显示
    NSString *dateString = [self formattedTimeWithDate:[NSDate dateWithTimeIntervalSince1970:messageModel.time.doubleValue]];
    message.sendTime = isEmptyString(messageModel.tag) ? dateString: messageModel.tag;
    message.msgType = messageModel.content_type.integerValue;
    message.userId = messageModel.uid.stringValue;
    message.userDisplayName = messageModel.user_name;
    message.userVip = messageModel.user_vip;
    message.userAvatarURLStr = messageModel.user_pic;
    message.userRoleName = messageModel.role;
    message.msgText = messageModel.contentText;
    message.openURLStr = messageModel.contentOpenUrl;
    message.link = messageModel.contentLink;
    message.networkState = TTLiveMessageNetworkStateSuccess;
    message.loadingProgress = [NSNumber numberWithFloat:1.0];
    message.likeCount = messageModel.like_count.integerValue;
    message.liked = messageModel.liked.boolValue;
    
    //回复
    if (messageModel.reply) {
        message.replyedMessage = [self switchMessageModleToMessage:messageModel.reply];
        message.replyedMessage.isReplyedMsg = YES;
    }
    
    //媒体文件类型
    if (message.msgType == TTLiveMessageTypeImage) {
        if (messageModel.contentPictureArray.count > 0) {
            message.imageModel = [[TTImageInfosModel alloc] initWithDictionary:messageModel.contentPictureArray.firstObject];
        }
    }
    else if (message.msgType == TTLiveMessageTypeAudio) {
        if (messageModel.contentAudioArray.count > 0) {
            TTLiveMessageAudioModel *audioInfo = messageModel.contentAudioArray.firstObject;
            message.mediaFileUrl = audioInfo.url;
            message.mediaFileSourceId = audioInfo.audioId;
            message.mediaFileSize = audioInfo.size.stringValue;
            message.mediaFileDuration = audioInfo.length.stringValue;
        }
    }
    else if (message.msgType == TTLiveMessageTypeVideo) {
        if (messageModel.contentVideoArray.count > 0) {
            TTLiveMessageVideoModel *videoInfo = messageModel.contentVideoArray.firstObject;
            message.mediaFileUrl = videoInfo.url;
            message.mediaFileSourceId = videoInfo.videoId;
            CGFloat byteSize = videoInfo.size.floatValue;
            message.mediaFileSize = [TTLiveCellHelper formattedSizeWithVideoFileSize:byteSize];
            message.mediaFileDuration = videoInfo.length.stringValue;
            message.imageModel = [[TTImageInfosModel alloc] initWithDictionary:videoInfo.cover];
        }
    } else if (message.msgType == TTLiveMessageTypeProfileCard) {
        TTLiveMessageProfileModel *profile = messageModel.contentProfile;
        TTLiveMessageCard *card = [[TTLiveMessageCard alloc] init];
        card.cardId = profile.profileId;
        card.icon = profile.icon;
        card.name = profile.name;
        card.vip = profile.vip;
        card.summary = profile.summary;
        message.cardModel = card;
    } else if (message.msgType == TTLiveMessageTypeMediaCard) {
        TTLiveMessageMediaModel *media = messageModel.contentMedia;
        TTLiveMessageCard *card = [[TTLiveMessageCard alloc] init];
        card.cardId = media.mediaId;
        card.icon = media.icon;
        card.name = media.name;
        card.summary = media.summary;
        message.cardModel = card;
    } else if (message.msgType == TTLiveMessageTypeArticleCard) {
        TTLiveMessageArticleModel *article = messageModel.contentArticle;
        TTLiveMessageCard *card = [[TTLiveMessageCard alloc] init];
        card.cardId = article.articleId;
        card.icon = article.icon;
        card.name = article.title;
        card.sourceIcon = article.sourceIcon;
        card.sourceName = article.sourceName;
        message.cardModel = card;
    }
    
    return message;
}

- (NSString*)dictionaryToJsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

- (void)setupMJExtensionModelMapping
{
    /// info
    [TTLiveTopBannerInfoModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"leaders":@"TTLiveLeaderModel",
                 @"roles":@"TTLiveRoleModel",
                 @"channels":@"TTLiveChannelModel"
                 };
    }];
    [TTLiveTopBannerInfoModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"cameraBeautyEnable":       @"settings.beauty",
                 @"initializeWithSelfieMode": @"settings.front_camera",
                 @"infiniteLike" :            @"settings.infinite_like",
                 @"infiniteLikeIcon" :        @"settings.infinite_like_icon",
                 @"infiniteLikeIconList" :    @"settings.infinite_like_icon_list",
                 @"disableComment":           @"settings.disable_comment",
                 @"topMessageID":             @"settings.notice_msg_id",
                 };
    }];
    [TTLiveChannelModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"channelId":@"id",
                 @"channelUrl":@"conf.url",
                 };
    }];
    [TTLiveMatchInfoModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"team2_icon":@"team2.icon",
                 @"team2_url":@"team2.url",
                 @"team2_name":@"team2.name",
                 @"team2_score":@"team2.score",
                 @"team2_id":@"team2.id",
                 @"team1_icon":@"team1.icon",
                 @"team1_url":@"team1.url",
                 @"team1_name":@"team1.name",
                 @"team1_score":@"team1.score",
                 @"team1_id":@"team1.id",
                 @"covers":@"covers[0]",
                 @"matchVideoLiveSource" : @"videos.live",
                 @"matchVideoCollectionSource" : @"videos.collection",
                 @"matchVideoPlaybackSource" : @"videos.playback"
                 };
    }];
    ///...
    [TTLiveMatchVideoH5SourceInfo mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"videoSourceArray":@"TTLiveMatchVideoH5SourceDetail"
                 };
    }];
    [TTLiveMatchVideoH5SourceInfo mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"title" : @"name",
                 @"videoSourceArray" : @"sources"
                 };
    }];
    [TTLiveMatchVideoH5SourceDetail mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"title" : @"source_name",
                 @"openURL" : @"open_url"
                 };
    }];
    
    [TTLiveSimpleInfoModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"covers":@"covers[0]"
                 };
    }];
    
    [TTLiveStarInfoModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"covers":@"covers[0]",
                 @"starId":@"id",
                 @"openURL":@"open_url"
                 };
    }];
    [TTLiveVideoInfoModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"videoCover": @"covers[0]",
                 @"videoId": @"id",
                 @"openURL": @"ope_url",
                 @"playbackEnable": @"play_back"
                 };
    }];
    
    /// stream
    [TTLiveStreamDataModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return  @{
                  @"score1" : @"match.score1",
                  @"score2" : @"match.score2",
                  @"subtitle" : @"match.subtitle",
                  @"msgRegionArray" : @"msg"
                  };
    }];
    [TTLiveStreamDataModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"msgRegionArray":@"TTLiveMessageRegionModel"
                 };
    }];
    [TTLiveMessageRegionModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return  @{
                  @"messageArray" : @"msgs",
                  @"replyArray" : @"replies"
                  };
    }];
    [TTLiveMessageRegionModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"messageArray":@"TTLiveMessageModel"
                 };
    }];
    [TTLiveMessageModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"msgId":@"id",
                 @"contentLink":@"content.link",
                 @"contentOpenUrl":@"content.open_url",
                 @"contentText":@"content.text",
                 @"contentAudioArray":@"content.audio",
                 @"contentPictureArray":@"content.picture",
                 @"contentVideoArray":@"content.video",
                 @"contentProfile":@"content.profile",
                 @"contentMedia":@"content.media",
                 @"contentArticle":@"content.article"
                 };
    }];
    [TTLiveMessageModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"messageArray":@"TTLiveMessage",
                 @"contentAudioArray":@"TTLiveMessageAudioModel",
                 @"contentVideoArray":@"TTLiveMessageVideoModel"
                 };
    }];
    [TTLiveMessageAudioModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"audioId":@"id"
                 };
    }];
    [TTLiveMessageVideoModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"videoId":@"id"
                 };
    }];
    [TTLiveMessageProfileModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"profileId":@"id"
                 };
    }];
    [TTLiveMessageMediaModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"mediaId":@"id"
                 };
    }];
    [TTLiveMessageArticleModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"articleId":@"id",
                 @"sourceIcon":@"source_icon",
                 @"sourceName":@"source_name"
                 };
    }];
}


@end

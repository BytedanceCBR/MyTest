//
//  TTLiveAudioManager.m
//  Article
//
//  Created by matrixzk on 8/1/16.
//
//

#import "TTLiveAudioManager.h"

#import "TTLiveMessage.h"
#import "TTAudioPlayer.h"

#import <AVFoundation/AVFoundation.h>

#import "TTLiveMainViewController.h"
#import "TTLiveChatTableViewController.h"
#import "TTLiveCellHelper.h"

#import "TTNetworkManager.h"
#import "NSDataAdditions.h"
#import "amrFileCodec.h"
#import "TTIndicatorView.h"
#import "NetworkUtilities.h"


static NSString *TTLiveAudioPlayModeSpeaker  = @"扬声器播放";
static NSString *TTLiveAudioPlayModeEarphone = @"听筒播放";


@interface TTLiveAudioManager () <TTAudioPlayerDelegate>

@property (nonatomic, strong) TTLiveMessage *currentAudioMessage;
@property (nonatomic, assign) BOOL isPlayingAudioFinishedTone;
@property (nonatomic, strong) TTAudioPlayer *audioPlayer;
@property (nonatomic, copy) NSString *currentAudioPlayMode;
@property (nonatomic, strong) NSMutableArray *audiosPrepared4AutoPlay;
@property (nonatomic, weak) TTLiveMainViewController *currentChatroom;
@property (nonatomic, weak) TTLiveChatTableViewController *chatVCContainCurrentAudioMsg;
@property (nonatomic, assign) BOOL audioMsgHadPlayedWhenTouchToPlay;

@end


@implementation TTLiveAudioManager

static TTLiveAudioManager *_sharedInstance;

+ (instancetype)sharedManager
{
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [[self alloc] init];
        }
    }
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [super allocWithZone:zone];
        }
    }
    return _sharedInstance;
}

//+ (void)freeSharedManager
//{
//    _sharedInstance = nil;
//}

- (void)dealloc
{
//    NSLog(@">>>>>>>> TTLiveAudioManager Dealloc CALLED!!!");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _currentAudioPlayMode = TTLiveAudioPlayModeSpeaker;
        
        _audioPlayer = [TTAudioPlayer new];
        _audioPlayer.delegate = self;
        self.audioPlayer.umengEventName = @"livecell";
        
//        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
//        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
//                                sizeof(sessionCategory),
//                                &sessionCategory);
        
//        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
//                                 sizeof (audioRouteOverride),
//                                 &audioRouteOverride);
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopCurrentPlayingAudioIfNeeded) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

//+ (NSString *)audioFilePathWithMessageId:(NSString *)msgId
//{
//    NSString *filePath = [NSTemporaryDirectory()
//                          stringByAppendingPathComponent:[NSString stringWithFormat:@"TempAudios/%@.wav", msgId]];
//    return filePath;
//}

- (void)createAudioCacheDirectoryIfNeeded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cameraVideoGroupPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"TempAudios"];
    
    // 判断文件夹是否存在，如果不存在，则创建
    if ([fileManager fileExistsAtPath:cameraVideoGroupPath]) {
        return;
    }
    
    NSError *error;
    [fileManager createDirectoryAtPath:cameraVideoGroupPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
}

- (void)setCurrentChatroom:(TTLiveMainViewController *)currentChatroom
{
    _currentChatroom = currentChatroom;
    
    [self.audioPlayer setTrackerDictionary:[self dict4EventTrack]];
}

- (NSDictionary *)dict4EventTrack
{
    NSMutableDictionary *trackerDic = [[NSMutableDictionary alloc] init];
    [trackerDic setValue:_currentChatroom.overallModel.liveId forKey:@"value"];
    [trackerDic setValue:_currentChatroom.overallModel.liveStateNum forKey:@"stat"];
    [trackerDic setValue:_currentChatroom.overallModel.referFrom forKey:@"refer"];
    return trackerDic;
}

+ (void)playAudioWithMessage:(TTLiveMessage *)message chatroom:(TTLiveMainViewController *)chatroom
{
//    [chatroom stopLiveVideoIfNeeded];
    [chatroom pauseLiveVideoIfNeeded];
    
    TTLiveAudioManager *manager = [TTLiveAudioManager sharedManager];
    TTAudioPlayer *audioPlayer = manager.audioPlayer;
    
    audioPlayer.needTracker = YES;
    
    if (chatroom) {
        // 当前msg正在播放，停掉即可。
        if (message.audioIsPlaying) {
            message.audioIsPlaying = NO;
            [self stopCurrentPlayingAudioIfNeeded];
            manager.currentAudioMessage = nil;
            [chatroom startLiveVideoIfNeeded];
            //NSLog(@"\n\n>>>>>>> 手动 停止当前正在播放语音。");
            return;
        }
        
        // 停掉当前正在播放的音频(如果有)
        if (manager.currentAudioMessage.audioIsPlaying || audioPlayer.isPlaying) {
            [self stopCurrentPlayingAudioIfNeeded];
            //NSLog(@"\n\n>>>>>>> 手动 停止当前正在播放语音，开始播放新语音。");
        }
        
        // 清空之前数据(如果有)
        manager.audiosPrepared4AutoPlay = nil;
        
        // 更新当前chatVC
        manager.currentChatroom = chatroom;
        TTLiveChatTableViewController *currentChatVC = (TTLiveChatTableViewController *)[chatroom currentChannelVC];
        manager.chatVCContainCurrentAudioMsg = [currentChatVC isKindOfClass:[TTLiveChatTableViewController class]] ? currentChatVC : nil;
        
        // 若为听筒模式，给提示
        if ([TTLiveAudioPlayModeEarphone isEqualToString:manager.currentAudioPlayMode]) {
            [TTLiveAudioManager showIndicatorViewWithText:@"当前听筒播放模式"];
        }
        
        manager.audioMsgHadPlayedWhenTouchToPlay = message.audioHadPlayed;
    }
    
    //NSLog(@"\n\n>>>>>>> 开始 准备 播放 新语音。");
    
    // KVO更新cellUI播放状态
    message.audioIsPlaying = YES;
    //    message.audioHadPlayed = YES;
    // 更新 currentAudioMessage
    manager.currentAudioMessage = message;
    
    // 先尝试取本地缓存
    if (!message.localWavAudioURL) {
        NSString *pathStr= [NSTemporaryDirectory()
                            stringByAppendingPathComponent:[NSString stringWithFormat:@"TempAudios/%@.wav", message.msgId]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathStr]) {
            message.localWavAudioURL = [NSURL URLWithString:pathStr];
        } else {
            // 没有缓存，开始请求server
            [manager fetchAudioDataWithMessage:message];
            return;
        }
    }
    
    // 有缓存，尝试播放
    if ([audioPlayer setAudioPlayFileUrl:message.localWavAudioURL]) {
        // 开始播放
        [TTLiveAudioManager startPlayAudio];
    } else {
        message.localWavAudioURL = nil;
        // 缓存无效，开始请求server
        [manager fetchAudioDataWithMessage:message];
    }
}

+ (void)startPlayAudio
{
    TTLiveAudioManager *manager = [TTLiveAudioManager sharedManager];
    if (!manager.currentAudioMessage.audioHadPlayed) {
        manager.currentAudioMessage.audioHadPlayed = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [manager.audioPlayer startPlaying];
        //NSLog(@">>>>> ProximityMonitoring -- Enable: %@, State: %@", @([[UIDevice currentDevice] isProximityMonitoringEnabled]), @([[UIDevice currentDevice] proximityState]));
    });
}

- (void)stopCurrentPlayingAudioIfNeeded{
    [TTLiveAudioManager stopCurrentPlayingAudioIfNeeded];
}

+ (void)stopCurrentPlayingAudioIfNeeded
{
    TTLiveAudioManager *manager = [TTLiveAudioManager sharedManager];
    if (manager.currentAudioMessage.audioIsPlaying) {
        manager.currentAudioMessage.audioIsPlaying = NO;
    }
    if (manager.audioPlayer.isPlaying) {
        [manager.audioPlayer stopPlaying];
    }
    
    // 清空语音连播数据
    manager.audiosPrepared4AutoPlay = nil;
    manager.currentChatroom = nil;
    manager.chatVCContainCurrentAudioMsg = nil;
}

- (void)fetchAudioDataWithMessage:(TTLiveMessage *)audioMsg
{
    [[TTNetworkManager shareInstance] requestForJSONWithURL:audioMsg.mediaFileUrl params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        if (error) {
            [self handleErrorOfAudioDataDownload];
            return ;
        }
        
        NSDictionary *audioObj = [[[jsonObj tt_dictionaryValueForKey:@"data"] tt_dictionaryValueForKey:@"audio_list"] tt_dictionaryValueForKey:@"audio_1"];
        NSString *base64MainUrl = [audioObj tt_stringValueForKey:@"main_url"];
        NSString *base64BackupUrl = [audioObj tt_stringValueForKey:@"backup_url_1"];
        
        // 下发的是base64编码后的url，解码
        NSString *realMainUrl;
        if (!isEmptyString(base64MainUrl)) {
            realMainUrl = [[NSString alloc] initWithData:[NSData ss_dataWithBase64EncodedString:base64MainUrl]
                                                encoding:NSUTF8StringEncoding];
        }
        NSString *realBackupUrl;
        if (!isEmptyString(base64BackupUrl)) {
            realBackupUrl = [[NSString alloc] initWithData:[NSData ss_dataWithBase64EncodedString:base64BackupUrl]
                                                  encoding:NSUTF8StringEncoding];
        }
        
        NSMutableArray *urlArray = [NSMutableArray arrayWithCapacity:2];
        if (!isEmptyString(realMainUrl)) {
            [urlArray addObject:realMainUrl];
        }
        if (!isEmptyString(realBackupUrl)) {
            [urlArray addObject:realBackupUrl];
        }
        
        if (urlArray.count == 0) {
            [self handleErrorOfAudioDataDownload];
        } else {
            // 开始下载音频data
            [self downloadAudioDataWithURLs:urlArray audioMsg:audioMsg];
        }
    }];
}

- (void)downloadAudioDataWithURLs:(NSMutableArray *)urls audioMsg:(TTLiveMessage *)audioMsg
{
    NSString *url = urls.firstObject;
    if (isEmptyString(url)) {
        [self handleErrorOfAudioDataDownload];
        return;
    }
    [urls removeObject:url];
    
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        
        if (error) {
            
            // 重试备选链接
            if (urls.count > 0) {
                [self downloadAudioDataWithURLs:urls audioMsg:audioMsg];
            } else {
                [self handleErrorOfAudioDataDownload];
            }
            
            return ;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // 子线程转音频格式
            NSData *wavData = DecodeAMRToWAVE((NSData *)obj);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 拿到data直接播放
                if ([self.audioPlayer setAudioWidthData:wavData]) {
                    
                    // 开始播放
                    if (self.currentAudioMessage == audioMsg) {
                        
                        // 取待连播语音消息数据源(只在第一次播放未播语音时取)
                        if (!self.audiosPrepared4AutoPlay && !self.currentAudioMessage.isReplyedMsg) {
                            self.audiosPrepared4AutoPlay = [TTLiveAudioManager selectAudiosPrepared4AutoPlay];
                            //NSLog(@">>>>>>> 手动 播放语音前 加载待连播语音，条数：%d", manager.audiosPrepared4AutoPlay.count);
                        }
                        // 开始播放
                        [TTLiveAudioManager startPlayAudio];
                    }
                    
                    // 缓存到本地
                    [self createAudioCacheDirectoryIfNeeded];
                    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"TempAudios/%@.wav", audioMsg.msgId]];
                    audioMsg.localWavAudioURL = [NSURL URLWithString:filePath];
                    
                    // TODO: 在另一个队列做本地存储操作
                    [wavData writeToFile:filePath atomically:YES];
                    
                } else {
                    audioMsg.localWavAudioURL = nil;
                    audioMsg.audioIsPlaying = NO;
                    
                    [self handleErrorOfAudioDataDownload];
                }
            });
        });
    }];
}

- (void)handleErrorOfAudioDataDownload
{
    self.currentAudioMessage.localWavAudioURL = nil;
    self.currentAudioMessage.audioIsPlaying = NO;
    
    NSString *tips = TTNetworkConnected() ? @"播放失败" : @"没有网络";
    [TTLiveAudioManager showIndicatorViewWithText:tips];
    
    // event track
    wrapperTrackEventWithCustomKeys(@"livecell", @"audio_download_fail", nil, nil, [self dict4EventTrack]);
}

// 扬声器与听筒切换，isManu : 是否是手动自动切换。
- (void)switchToAudioPlayMode:(NSString *)audioPlayMode isManual:(BOOL)isManu showTips:(BOOL)showTips
{
    if (isManu) {
        self.currentAudioPlayMode = audioPlayMode;
    }
    
    NSString *eventTrackLabel;
    NSString *tips;
    if ([TTLiveAudioPlayModeEarphone isEqualToString:audioPlayMode]) {
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        tips = @"当前听筒播放模式";
        eventTrackLabel = isManu ? @"audio_cut_ear" : @"audio_cut_auto_ear";
        
    } else if ([TTLiveAudioPlayModeSpeaker isEqualToString:audioPlayMode]) {
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        tips = @"当前扬声器播放模式";
        eventTrackLabel = isManu ? @"audio_cut_spe" : @"audio_cut_auto_spe";
    }
    
    if (showTips && !isEmptyString(tips)) {
        [TTLiveAudioManager showIndicatorViewWithText:tips];
    }
    
    if (eventTrackLabel) {
//        [[TTLiveManager sharedManager] trackerEvent:@"livecell" label:eventTrackLabel tab:nil extValue:nil];
        wrapperTrackEventWithCustomKeys(@"livecell", eventTrackLabel, nil, nil, [self dict4EventTrack]);
    }
}

+ (void)switchAudioPlayMode
{
    if ([AVAudioSessionCategoryPlayAndRecord isEqualToString:[AVAudioSession sharedInstance].category]) {
        [[TTLiveAudioManager sharedManager] switchToAudioPlayMode:TTLiveAudioPlayModeSpeaker
                                                         isManual:YES
                                                         showTips:YES];
    } else if ([AVAudioSessionCategoryPlayback isEqualToString:[AVAudioSession sharedInstance].category]) {
        [[TTLiveAudioManager sharedManager] switchToAudioPlayMode:TTLiveAudioPlayModeEarphone
                                                         isManual:YES
                                                         showTips:YES];
    }
}

+ (NSString *)audioPlayModeSwitchable
{
    NSString *result = TTLiveAudioPlayModeEarphone;
    if ([TTLiveAudioPlayModeEarphone isEqualToString:[TTLiveAudioManager sharedManager].currentAudioPlayMode]) {
        result = TTLiveAudioPlayModeSpeaker;
    }
    return result;
}

+ (void)showIndicatorViewWithText:(NSString *)tips
{
    if (isEmptyString(tips)) {
        return;
    }
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                              indicatorText:tips
                             indicatorImage:nil
                                autoDismiss:YES
                             dismissHandler:nil];
}

// 播放语音消息发送提示音
//- (void)playToneOfAudioPlayFinished
//{
//    self.isPlayingAudioFinishedTone = YES;
//    
//    NSURL *audioTipUrl = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"audioTip" ofType:@"wav"]];
//    if ([self.audioPlayer setAudioPlayFileUrl:audioTipUrl]) {
//        [self.audioPlayer startPlaying];
//    }
//}

// 取可播放语音消息，以备连播
+ (NSMutableArray *)selectAudiosPrepared4AutoPlay
{
    TTLiveAudioManager *manager = [TTLiveAudioManager sharedManager];
    
    if (![manager.chatVCContainCurrentAudioMsg isKindOfClass:[TTLiveChatTableViewController class]]) {
        return nil;
    }
    
//    TTLiveChatTableViewController *currentChatVC = (TTLiveChatTableViewController *)[manager.currentChatroom currentChannelVC];
//    if (![currentChatVC isKindOfClass:[TTLiveChatTableViewController class]]) {
//        return nil;
//    }
    
    NSMutableArray *audoisReady = [NSMutableArray new];
    [manager.chatVCContainCurrentAudioMsg.messageArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TTLiveMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (manager.currentAudioMessage == message ||
            (message.replyedMessage && message.replyedMessage.msgId == manager.currentAudioMessage.msgId)) {
            *stop = YES;
            return ;
        }
        
        if (TTLiveMessageTypeAudio == message.msgType && !message.audioHadPlayed) {
            [audoisReady insertObject:message atIndex:0];
        }
    }];
    
    return audoisReady;
}

// 尝试语音消息自动连播
- (void)autoPlayAudiosIfNeeded
{
    if (self.audioMsgHadPlayedWhenTouchToPlay || self.currentAudioMessage.isReplyedMsg) {
        
//        self.audiosPrepared4AutoPlay = nil;
//        [self.currentChatroom startLiveVideoIfNeeded];
        
        [self audiosAutoPlayDidFinished];
        
        return;
    }
    
    if (self.audiosPrepared4AutoPlay.count > 0) { // 有待连播语音
        
        // 出栈，开始播放
        TTLiveMessage *nextAudioMsg = self.audiosPrepared4AutoPlay.firstObject;
        [self.audiosPrepared4AutoPlay removeObject:nextAudioMsg];
        [TTLiveAudioManager playAudioWithMessage:nextAudioMsg chatroom:nil];
        //NSLog(@">>>>>>> 连播 ing ... 出栈，开始播放，剩余 待播放语音条数：%d", self.audiosPrepared4AutoPlay.count);
        
    } else { // 可连播语音已全部出栈
        
        // 尝试取新拉取的待连播语音
        self.audiosPrepared4AutoPlay = [TTLiveAudioManager selectAudiosPrepared4AutoPlay];
        //NSLog(@">>>>>>> 播放结束，取新语音，取到新的待播放语音条数：%d", self.audiosPrepared4AutoPlay.count);
        
        if (self.audiosPrepared4AutoPlay.count > 0) { // 有新的待播放语音
            
            // 出栈，开始播放
            TTLiveMessage *nextAudioMsg = self.audiosPrepared4AutoPlay.firstObject;
            [self.audiosPrepared4AutoPlay removeObject:nextAudioMsg];
            [TTLiveAudioManager playAudioWithMessage:nextAudioMsg chatroom:nil];
            //NSLog(@">>>>>>> 取到新待播放语音 播放第一条，剩余 待播放语音条数：%d", self.audiosPrepared4AutoPlay.count);
            
        } else { // 暂无新的语音消息
            
            //NSLog(@">>>>>>> 没取到新语音，连播结束！！");
            
//            self.audiosPrepared4AutoPlay = nil;
//            [self.currentChatroom startLiveVideoIfNeeded];
            
            [self audiosAutoPlayDidFinished];
        }
    }
}

- (void)audiosAutoPlayDidFinished
{
    [self switchToAudioPlayMode:self.currentAudioPlayMode isManual:NO showTips:NO];
    
    self.audiosPrepared4AutoPlay = nil;
    [self.currentChatroom startLiveVideoIfNeeded];
}


#pragma mark TTAudioPlayerDelegate

// 播放完成
- (void)ttAudioPlayerSuccessFinished
{
    if (self.isPlayingAudioFinishedTone) {
        
        // NSLog(@">>>>>>> ```TONE``` played finished.");
        
        self.isPlayingAudioFinishedTone = NO;
        
        // 尝试语音消息连播
        [self autoPlayAudiosIfNeeded];
        
        return;
    }
    
    // NSLog(@">>>>>>> audio finished, will play ```TONE```.");
    self.currentAudioMessage.audioIsPlaying = NO;
    
//    [self switchToAudioPlayMode:self.currentAudioPlayMode isManual:NO showTips:NO];
    // 播放语音结束提示音
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self playToneOfAudioPlayFinished];
//    });
    
    NSURL *audioTipUrl = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"audioTip" ofType:@"wav"]];
    if ([self.audioPlayer setAudioPlayFileUrl:audioTipUrl]) {
        self.isPlayingAudioFinishedTone = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.audioPlayer startPlaying];
        });
    }
    
}

// 播放失败
- (void)ttAudioPlayerFailedError:(NSError *)error
{
    self.isPlayingAudioFinishedTone = NO;
    self.currentAudioMessage.audioIsPlaying = NO;
    [self switchToAudioPlayMode:self.currentAudioPlayMode isManual:NO showTips:NO];
    
    // event track
    wrapperTrackEventWithCustomKeys(@"livecell", @"audio_play_fail", nil, nil, [self dict4EventTrack]);
}

// 贴近或远离听筒
- (void)ttAudioDeviceProximityStateChange:(BOOL)proximityState
{
    LOGD(@">>>>>>>> ttAudioDeviceProximityStateChange : %@", @(proximityState));
    if (proximityState) { // 贴近
        [self switchToAudioPlayMode:TTLiveAudioPlayModeEarphone isManual:NO showTips:NO];
        [TTLiveCellHelper dismissCellMenuIfNeeded];
    } else { // 远离
        [self switchToAudioPlayMode:self.currentAudioPlayMode
                           isManual:NO
                           showTips:[TTLiveAudioPlayModeSpeaker isEqualToString:self.currentAudioPlayMode]];
    }
}

@end

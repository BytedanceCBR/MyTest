//
//  TTLiveAudioManager.h
//  Article
//
//  Created by matrixzk on 8/1/16.
//
//

#import <Foundation/Foundation.h>

@class TTLiveMainViewController, TTLiveMessage;


@interface TTLiveAudioManager : NSObject

/// 播放语音msg
+ (void)playAudioWithMessage:(TTLiveMessage *)message chatroom:(TTLiveMainViewController *)chatroom;

/// 停止当前正在播放语音 (若有)
+ (void)stopCurrentPlayingAudioIfNeeded;

/// 播放器与听筒切换
+ (void)switchAudioPlayMode;

/// 可切换到的播放模式 (播放器或听筒)
+ (NSString *)audioPlayModeSwitchable;

@end

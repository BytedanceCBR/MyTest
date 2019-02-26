//
//  TTVAudioActiveCenter.h
//  Article
//
//  Created by panxiang on 2017/7/7.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerProtocol.h"
@class TTVPlayerStateStore;
@interface TTVAudioActiveCenter : NSObject<TTVPlayerContext>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
+ (void)setupAudioSessionIsMuted:(BOOL)isMuted;
- (void)deactive;
- (void)beactive;
+ (void)beactive;
@end

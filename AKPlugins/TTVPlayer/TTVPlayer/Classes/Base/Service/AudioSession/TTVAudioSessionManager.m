//
//  TTVAudioSessionManager.m
//  Article
//
//  Created by Chen Hong on 16/3/24.
//
//

#import "TTVAudioSessionManager.h"
#import <AVFoundation/AVFoundation.h>

@interface TTVAudioSessionManager ()

@property (nonatomic) dispatch_queue_t audioSessionQueue;

@end

@implementation TTVAudioSessionManager

+ (instancetype)sharedInstance
{
    static TTVAudioSessionManager *audioSessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioSessionManager = [[TTVAudioSessionManager alloc] init];
    });
    return audioSessionManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.audioSessionQueue = dispatch_queue_create("com.toutiao.audioSessionQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (BOOL)setCategory:(NSString *)category
{
    NSError *categoryError = nil;
    
    BOOL success = [[AVAudioSession sharedInstance] setCategory:category error:&categoryError];
    
    if (!success)
    {
        NSLog(@"Error setting audio session category: %@", categoryError);
    }
    
    return success;
}

- (void)setActive:(BOOL)active
{
    if (active) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(p_setActive:) object:@(NO)];
        [self p_setActive:@(YES)];
    } else {
        [self performSelector:@selector(p_setActive:) withObject:@(NO) afterDelay:1.5f];
    }
}

- (void)p_setActive:(NSNumber *)active
{
    dispatch_async(_audioSessionQueue, ^{
        NSError *activeError = nil;
        
        ///< 恢复其他app 音乐播放
        BOOL success = [[AVAudioSession sharedInstance] setActive:[active boolValue] withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&activeError];
        
        if (@available(iOS 11.0, *)) {

        } else {
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }
        
        if (!success) {
            NSLog(@"Error setting audio session active: %@", activeError);
        }
    });
}

@end

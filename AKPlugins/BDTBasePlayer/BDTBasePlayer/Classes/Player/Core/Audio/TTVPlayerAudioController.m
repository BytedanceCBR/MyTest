//
//  TTVPlayerAudioController.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPlayerAudioController.h"
#import <AVFoundation/AVFoundation.h>

@interface TTVPlayerAudioController ()
@end

@implementation TTVPlayerAudioController

+ (TTVPlayerAudioController *)sharedInstance {
    static TTVPlayerAudioController *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTVPlayerAudioController alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setCategory:(NSString *)category {
    NSError *categoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:category error:&categoryError];
}

- (void)setActive:(BOOL)active {
    NSError *activeError = nil;
    [[AVAudioSession sharedInstance] setActive:active withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&activeError];
}

@end

//
//  TTAShortVideoTracker.m
//  HTSVideoPlay
//
//  Created by carl on 2017/12/28.
//

#import "TTAShortVideoTracker.h"
#import "TTShortVideoModel+TTAdFactory.h"

@interface TTAShortVideoTracker ()
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) NSTimeInterval playSeconds;
@property (nonatomic, assign) NSTimeInterval beginTimestamp;
@property (nonatomic, strong) TTShortVideoModel *model;
@end

@implementation TTAShortVideoTracker

- (instancetype)initWithModel:(TTShortVideoModel *)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)begin {
    self.playing = NO;
    self.beginTimestamp = 0;
    self.playSeconds = 0;
}

- (void)play {
    self.playing = YES;
    self.beginTimestamp = [[NSDate date] timeIntervalSince1970];
    self.playSeconds = 0;

    TTAdShortVideoModel *adModel = self.model.rawAd;
    NSMutableDictionary *extra = @{}.mutableCopy;
    [adModel trackDrawWithTag:@"draw_ad" label:@"play" extra:extra];
    [adModel sendTrackURLs:adModel.play_track_url_list];
}

- (void)pause {
    self.playing = NO;
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - self.beginTimestamp;
    self.playSeconds += duration;
}

- (void)resume {
    if (self.playing) {
        return;
    }
    self.playing = YES;
    self.beginTimestamp = [[NSDate date] timeIntervalSince1970];
}

- (void)stop {
    self.playing = NO;
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - self.beginTimestamp;
    self.playSeconds += duration;
    TTAdShortVideoModel *adModel = self.model.rawAd;
    NSMutableDictionary *extra = @{}.mutableCopy;
    if (self.playSeconds <= 1) {
        return;
    }
    [extra setValue:@(ceilf(self.playSeconds * 1000)) forKey:@"duration"];
    [extra setValue:@(self.model.video.duration) forKey:@"video_length"];
    [adModel trackDrawWithTag:@"draw_ad" label:@"break" extra:extra];
    if (adModel.effective_play_time && self.playSeconds > adModel.effective_play_time) {
        [adModel sendTrackURLs:adModel.effective_play_track_url_list];
    }
}

- (void)over {
    TTAdShortVideoModel *adModel = self.model.rawAd;
    NSMutableDictionary *extra = @{}.mutableCopy;
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - self.beginTimestamp;
    self.playSeconds += duration;
    [extra setValue:@(ceilf(self.playSeconds * 1000)) forKey:@"duration"];
    [extra setValue:@(self.model.video.duration) forKey:@"video_length"];
    [adModel trackDrawWithTag:@"draw_ad" label:@"over" extra:extra];
    [adModel sendTrackURLs:adModel.playover_track_url_list];
    
    if (adModel.effective_play_time && self.playSeconds > adModel.effective_play_time) {
        [adModel sendTrackURLs:adModel.effective_play_track_url_list];
    }
    
    self.playing = NO;
    self.playSeconds = 0;
}

- (void)end {
    if (self.playing) {
        [self stop];
    }
}

@end

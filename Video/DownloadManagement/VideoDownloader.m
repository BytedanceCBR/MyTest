//
//  VideoDownloader.m
//  Video
//
//  Created by Dianwei on 12-7-24.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoDownloader.h"

@interface VideoDownloader()
@property(nonatomic, readwrite, retain)VideoData *video;
@end

@implementation VideoDownloader
@synthesize video, delegate, currentStatus, progress;
- (void)dealloc
{
     self.video = nil;
    self.delegate = nil;
    [self removeObserver:self forKeyPath:@"currentStatus"];
    [self removeObserver:self forKeyPath:@"progress"];
    [super dealloc];
}

- (id)initWithVideo:(VideoData*)tVideo
{
    self = [super init];
    if(self)
    {
        self.video = tVideo;
        [self addObserver:self forKeyPath:@"currentStatus" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

- (void)start
{
    [self startWithPriority:NSOperationQueuePriorityNormal];
}

- (void)startWithPriority:(NSOperationQueuePriority)priority
{}

- (void)stop
{}

- (void)remove
{
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentStatus"])
    {
        video.downloadStatus = [change valueForKey:NSKeyValueChangeNewKey];
        [[SSModelManager sharedManager] save:nil];
        if(delegate && [delegate respondsToSelector:@selector(videoDownloader:downloadStatusChangedTo:)])
        {
            [delegate performSelector:@selector(videoDownloader:downloadStatusChangedTo:) withObject:self withObject:[change valueForKey:NSKeyValueChangeNewKey]];
        }
    }
    else if([keyPath isEqualToString:@"progress"])
    {
        if(delegate && [delegate respondsToSelector:@selector(videoDownloader:progressChangedTo:)])
        {
            [delegate performSelector:@selector(videoDownloader:progressChangedTo:) withObject:self withObject:[change valueForKey:NSKeyValueChangeNewKey]];
        }
    }
}

@end

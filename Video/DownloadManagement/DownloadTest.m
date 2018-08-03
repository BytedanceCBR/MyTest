//
//  DownloadTest.m
//  Video
//
//  Created by Dianwei on 12-7-22.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "DownloadTest.h"
#import "VideoData.h"
#import "M3U8VideoDownloader.h"
#import "SSModelManager.h"
#import "Segment.h"
#import "VideoDownloaderManager.h"
#import "MP4VideoDownloader.h"

@interface DownloadTest()<VideoDownloaderProtocol>
@property(nonatomic, retain)M3U8VideoDownloader *removeDownloader;
@property(nonatomic, retain)M3U8VideoDownloader *restartDownloader;
@property(nonatomic, retain)MP4VideoDownloader *mp4Downloader;
@end

@implementation DownloadTest
{
    BOOL _restarted;
}
@synthesize removeDownloader, restartDownloader, mp4Downloader;
+ (VideoData*)videoDataWithDictionary:(NSDictionary*)dict
{
    VideoData *data = [VideoData entityWithDictionary:dict];
    [[SSModelManager sharedManager] insertObject:data];
    [[SSModelManager sharedManager] save:nil];
    return data;
}


- (void)testDownload
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], @"http://meta.video.qiyi.com/247/b3228f02d411526f2b7dc636fc026980.m3u8", nil] 
                                                     forKeys:[NSArray arrayWithObjects:@"id", @"download_url", nil]];
    
    VideoData *data = [DownloadTest videoDataWithDictionary:dict];
    
    M3U8VideoDownloader *downloader = [(M3U8VideoDownloader*)[VideoDownloaderManager downloaderForType:VideoDownloaderTypeM3U8 video:data] retain];

    downloader.delegate = self;
    
    [downloader start];
    
}

- (void)testRemove
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], @"http://m3u8.tdimg.com/147/189/040/2.m3u8", nil] 
                                                     forKeys:[NSArray arrayWithObjects:@"id", @"download_url", nil]];
    
    VideoData *data = [DownloadTest videoDataWithDictionary:dict];
    self.removeDownloader = (M3U8VideoDownloader*)[VideoDownloaderManager downloaderForType:VideoDownloaderTypeM3U8 video:data];
    removeDownloader.delegate = self;
    [removeDownloader start];
}

- (void)testRestart
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:3], @"http://m3u8.tdimg.com/147/189/040/2.m3u8", nil] 
                                                     forKeys:[NSArray arrayWithObjects:@"id", @"download_url", nil]];
    
    VideoData *data = [DownloadTest videoDataWithDictionary:dict];
    self.restartDownloader = (M3U8VideoDownloader*)[VideoDownloaderManager downloaderForType:VideoDownloaderTypeM3U8 video:data];
    restartDownloader.delegate = self;
    [restartDownloader start];
}

- (void)testBatchDownload
{
    NSArray *array = [NSArray arrayWithObjects:@"http://m3u8.tdimg.com/147/189/040/2.m3u8", @"http://hot.vrs.sohu.com/ipad724210.m3u8", @"http://my.tv.sohu.com/ipad/26422463.m3u8", @"http://v.ku6.com/fetchwebm/BtcW7MaarMhgaLSbOqdxaA...m3u8",nil];
    
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [mDict setObject:[NSNumber numberWithInt:idx] forKey:@"id"];
        [mDict setObject:obj forKey:@"download_url"];
        VideoData *video = [DownloadTest videoDataWithDictionary:mDict];
        [mArray addObject:video];
    }];
    
    for(VideoData *video in mArray)
    {
        M3U8VideoDownloader *downloader = [[M3U8VideoDownloader alloc] initWithVideo:video];
        downloader.delegate = self;
        [downloader start];
    }    
}

- (void)testMP4Download
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:13], @"http://www.baidu.com", nil] 
                                                     forKeys:[NSArray arrayWithObjects:@"id", @"download_url", nil]];
    
    VideoData *data = [DownloadTest videoDataWithDictionary:dict];
    
    self.mp4Downloader = (MP4VideoDownloader*)[VideoDownloaderManager downloaderForType:VideoDownloaderTypeMP4 video:data];
    mp4Downloader.delegate = self;
    [mp4Downloader start];
    [self performSelector:@selector(stopAndRestartMP4) withObject:nil afterDelay:15];
    
}

- (void)stopAndRestartMP4
{
    [mp4Downloader stop];
    [mp4Downloader start];
}

- (void)videoDownloader:(VideoDownloader *)downloader progressChangedTo:(NSNumber *)newProgress
{
    NSLog(@"new progress:%@. id:%@", newProgress, downloader.video.groupID);
}

- (void)videoDownloader:(VideoDownloader *)downloader downloadStatusChangedTo:(NSNumber *)newStatus
{
    NSLog(@"new status:%@, id:%@", newStatus, downloader.video.groupID);
    if(downloader == removeDownloader)
    {
        if([newStatus intValue] == DownloadStatusDownloadFinished)
        {
            [downloader remove];
            NSArray *segments = [[SSModelManager sharedManager] entitiesWithQuery:[NSDictionary dictionaryWithObject:@"0" forKey:@"groupID"] entityDescription:[Segment entityDescription] error:nil];
            assert(segments.count == 0);
        }
    }
    else if(downloader == restartDownloader)
    {
        if([newStatus intValue] == DownloadStatusDownloadingFiles && !_restarted)
        {
            _restarted = YES;
            [downloader stop];
            [downloader start];
        }
    }
}

@end

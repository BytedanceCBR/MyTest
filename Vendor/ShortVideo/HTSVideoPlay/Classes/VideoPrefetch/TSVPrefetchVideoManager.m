//
//  TSVPrefetchVideoManager.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/12/25.
//

#import "TSVPrefetchVideoManager.h"
#import "TSVPrefetchVideoConfig.h"
#import "TTShortVideoModel.h"
#import "IESVideoPlayer.h"
#import "AWEVideoConstants.h"
#import "TTHTSVideoConfiguration.h"

NSString * const TSVVideoPrefetchShortVideoFeedCardGroup = @"com.shortvideo.feedcard";
NSString * const TSVVideoPrefetchShortVideoFeedFollowGroup = @"com.shortvideo.feedfollow";
NSString * const TSVVideoPrefetchShortVideoTabGroup = @"com.shortvideo.tab";
NSString * const TSVVideoPrefetchDetailGroup = @"com.shortvideo.detail";

@implementation TSVPrefetchVideoManager

+ (BOOL)isPrefetchEnabled
{
    return [TSVPrefetchVideoConfig isPrefetchEnabled];
}

+ (void)startPrefetchShortVideo:(TTShortVideoModel *)model group:(NSString *)group
{
    if (model) {
        NSString *urlStr = [model.video.playAddr.urlList firstObject];
        NSString *videoID = model.video.videoId;
        [[IESVideoPreloader preloaderWithType:IESVideoPlayerTypeSpecify] preloadVideoID:videoID andVideoURL:urlStr preloadSize:[TSVPrefetchVideoConfig prefetchSize] group:group];
    }
}

+ (void)cancelPrefetchShortVideoForGroup:(NSString *)group
{
    [[IESVideoPreloader preloaderWithType:IESVideoPlayerTypeSpecify] cancelGroup:group];
}

+ (void)startPrefetchShortVideoInDetailWithDataFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)manager
{
    if (![self isPrefetchEnabled]) {
        return;
    }
    
    NSInteger currentIndex = manager.currentIndex;
    
    NSInteger preIndex = currentIndex - 1;
    if (preIndex >= 0 && preIndex < [manager numberOfShortVideoItems]) {
        TTShortVideoModel *shortVideoModel = [manager itemAtIndex:preIndex];
        [self startPrefetchShortVideo:shortVideoModel group:TSVVideoPrefetchDetailGroup];
    }
    
    NSInteger nextIndex = currentIndex + 1;
    if (nextIndex >= 0 && nextIndex < [manager numberOfShortVideoItems]) {
        TTShortVideoModel *shortVideoModel = [manager itemAtIndex:nextIndex];
        [self startPrefetchShortVideo:shortVideoModel group:TSVVideoPrefetchDetailGroup];
    }
}

+ (void)cancelPrefetchShortVideoInDetail
{
    [self cancelPrefetchShortVideoForGroup:TSVVideoPrefetchDetailGroup];
}

@end

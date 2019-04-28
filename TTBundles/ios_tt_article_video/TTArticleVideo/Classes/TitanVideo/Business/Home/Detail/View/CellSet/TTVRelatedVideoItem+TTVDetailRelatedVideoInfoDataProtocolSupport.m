//
//  TTVRelatedVideoItem+TTVDetailRelatedVideoInfoDataProtocolSupport.m
//  Article
//
//  Created by pei yun on 2017/6/2.
//
//

#import "TTVRelatedVideoItem+TTVDetailRelatedVideoInfoDataProtocolSupport.h"
#import <TTVideoService/Common.pbobjc.h>
#import "TTImageInfosModel+Extention.h"
#import "TTVDetailRelatedADInfoDataProtocol.h"
#import "TTVRelatedVideoADPic+TTVDetailRelatedADInfoDataProtocol.h"
#import "TTVRelatedVideoItem+TTVDetailRelatedADInfoDataProtocol.h"

@implementation TTVRelatedVideoItem (TTVDetailRelatedVideoInfoDataProtocolSupport)

- (NSNumber *)groupFlags
{
    return @(self.article.groupFlags);
}

- (NSString *)source
{
    return self.article.source;
}

- (NSNumber *)commentCount
{
    return @(self.article.commentCount);
}

- (NSString *)mediaName
{
    //TODOPY
    return nil;
}

- (NSDictionary *)videoDetailInfo
{
    TTVVideoDetailInfo *videoDetailInfo = self.article.videoDetailInfo;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSDictionary *largeImageDict = [TTImageInfosModel dictionaryWithImageUrlList:self.article.largeImageList];
    [dict setValue:largeImageDict forKey:@"detail_video_large_image"];
    [dict setValue:@(videoDetailInfo.showPgcSubscribe) forKey:@"show_pgc_subscribe"];
    [dict setValue:@(videoDetailInfo.videoPreloadingFlag) forKey:@"video_preloading_flag"];
    [dict setValue:videoDetailInfo.videoThirdMonitorURL forKey:@"video_third_monitor_url"];
    [dict setValue:@(self.article.groupFlags) forKey:@"group_flags"];
    [dict setValue:@(videoDetailInfo.directPlay) forKey:@"direct_play"];
    [dict setValue:self.article.videoId forKey:@"video_id"];
    [dict setValue:@(videoDetailInfo.videoWatchCount) forKey:@"video_watch_count"];
    [dict setValue:@(videoDetailInfo.videoType) forKey:@"video_type"];
    return [dict copy];
}

- (NSString *)relatedVideoExtraInfoShowTag
{
    return self.relatedVideoExtraInfo.showTag;
}

- (NSNumber *)videoDuration
{
    return @(self.article.videoDetailInfo.videoDuration);
}

- (NSNumber *)hasRead
{
    //TODOPY
    return @(NO);
}

- (NSString *)title
{
    return self.article.title;
}

- (id<TTVDetailRelatedADInfoDataProtocol>)videoAdExtra
{
    return self;
}

- (TTImageInfosModel *)listMiddleImageModel
{
    return [[TTImageInfosModel alloc] initWithImageUrlList:self.article.middleImageList];
}

@end

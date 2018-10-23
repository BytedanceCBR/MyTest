//
//  TTVideoFeedListItemCreator.m
//  Article
//
//  Created by panxiang on 2017/4/13.
//
//

#import "TTVideoFeedListItemCreator.h"
#import "TTBusinessManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTVFeedListVideoCellHeader.h"
@implementation TTVFeedListItemCreator
+ (TTVFeedListItem *)configureItem:(TTVFeedListItem *)item
{
    TTVVideoArticle *article = [item article];
    if ([item isKindOfClass:[TTVFeedListItem class]]) {
        TTVFeedListVideoItem *videoItem = (TTVFeedListVideoItem *)item;
        NSInteger playTimes = article.videoDetailInfo.videoWatchCount;
        videoItem.playTimes = [[TTBusinessManager formatPlayCount:playTimes] stringByAppendingString:@"次播放"];
        NSString *durationText = nil;
        int64_t duration = article.videoDetailInfo.videoDuration;
        if (duration > 0) {
            int minute = (int)duration / 60;
            int second = (int)duration % 60;
            durationText = [NSString stringWithFormat:@"%02i:%02i", minute, second];
        } else {
            durationText = @"00:00";
        }
        videoItem.durationTimeString = durationText;
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithImageUrlList:article.largeImageList];
        videoItem.imageModel = model;
        return videoItem;
    }
    return item;
}

@end

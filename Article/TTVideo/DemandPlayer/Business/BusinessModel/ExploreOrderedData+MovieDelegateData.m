//
//  ExploreOrderedData+MovieDelegateData.m
//  Article
//
//  Created by panxiang on 2017/5/7.
//
//

#import "ExploreOrderedData+MovieDelegateData.h"
#import "Article.h"

@implementation ExploreOrderedData (MovieDelegateData)
- (NSInteger)ttv_videoDuration
{
    return [self.article.videoDuration integerValue];
}

- (NSInteger)ttv_videoWatchCount
{
    return [self.article.videoDetailInfo longValueForKey:VideoWatchCountKey defaultValue:0];
}

- (BOOL)ttv_isPreloadVideoEnabled
{
    return self.article.isPreloadVideoEnabled;
}

- (NSString *)ttv_videoLocalURL
{
    return self.article.videoLocalURL;
}
- (BOOL)ttv_couldAutoPlay
{
    return [self couldAutoPlay];
}

- (TTGroupModel *)ttv_groupModel
{
    return self.article.groupModel;
}
@end

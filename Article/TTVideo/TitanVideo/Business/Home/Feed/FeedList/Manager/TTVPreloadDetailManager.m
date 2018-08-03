//
//  TTVPreloadDetailManager.m
//  Article
//
//  Created by panxiang on 2017/5/3.
//
//

#import "TTVPreloadDetailManager.h"
#import "NewsFetchArticleDetailManager.h"
#import "NSTimer+NoRetain.h"
#import "TTVFeedListViewModel.h"
#import "TTVFeedListItem.h"
#import "TTVFeedListVideoItem.h"
#import "NetworkUtilities.h"
#import "NSArray+BlocksKit.h"
#import "ExploreListHelper.h"
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTAdManager.h"
#import "SSWebViewUtil.h"
#import "TTVFeedListViewController.h"
#import "Article+TTVArticleProtocolSupport.h"
#import "NewsDetailLogicManager.h"
#import <TTSettingsManager/TTSettingsManager.h>

#define kPreloadMoreThreshold           10

extern void tt_listView_preloadWebRes(Article *article, NSDictionary *rawAdData);
extern void tt_ad_adSiteWebPreload(Article *article, UIView *listView);

@interface TTVPreloadDetailManager ()<NewsFetchArticleDetailManagerDelegate>
@property (nonatomic, strong) NewsFetchArticleDetailManager *detailPrefetchManager;
@property (nonatomic, strong) NSTimer *preloadTimer;
@property(nonatomic, weak)TTVFeedListViewModel *listVideoModel;
@end

@implementation TTVPreloadDetailManager

- (void)dealloc
{
    [self.preloadTimer invalidate];
    self.preloadTimer = nil;
}

- (instancetype)initWithModel:(TTVFeedListViewModel *)viewModel
{
    self = [super init];
    if (self) {
        _detailPrefetchManager = [[NewsFetchArticleDetailManager alloc] init];
        _detailPrefetchManager.delegate = self;
        _listVideoModel = viewModel;
    }
    return self;
}

- (void)tryPreload {
    [self.preloadTimer invalidate];
    self.preloadTimer = nil;
    @weakify(self);
    self.preloadTimer = [NSTimer tt_scheduledTimerWithTimeInterval:0.3f repeats:NO block:^(NSTimer *timer) {
        @strongify(self);
        [self preload];
    }];
}

- (void)preload {
    [self preloadMore];
    [self preloadDetail];
}

- (void)suspendPreloadDetail
{
    [self.detailPrefetchManager suspendAllRequests];
}


- (void)preloadMore {
    if (self.listVideoModel.lastFetchRiseError) {
        return;
    }
    if(!self.listVideoModel.isLoading && TTNetworkConnected() && [self.listVideoModel.dataArr count] > 0)
    {
        NSArray *visibleCells = [self.tableView visibleCells];
        if([visibleCells count] > 0)
        {
            id obj = [visibleCells objectAtIndex:0];
            if ([obj isKindOfClass:[TTVFeedListCell class]])
            {
                TTVFeedListCell * cell = (TTVFeedListCell *)obj;
                TTVFeedListItem *item = (TTVFeedListItem *)cell.item;
                if ([item isKindOfClass:[TTVFeedListItem class]]) {
                    NSUInteger index = [self.listVideoModel.dataArr indexOfObject:item];
                    if (index > 0 && index < [self.listVideoModel.dataArr count] && [self.listVideoModel.dataArr count] - index <= kPreloadMoreThreshold) {
                        if ([self.delegate respondsToSelector:@selector(onPreloadMore)]) {
                            [self.delegate onPreloadMore];
                        }
                    }
                }
            }
        }
    }
}


- (void)preloadDetail {

    if(TTNetworkConnected() && [self.listVideoModel.dataArr count] > 0)
    {
        NSArray *visibleCells = [[self.tableView visibleCells] bk_select:^BOOL(id obj) {
            return [obj isKindOfClass:[TTVFeedListCell class]];
        }];
        TTVFeedListCell *cell = [visibleCells firstObject];
        if (cell == nil) {
            return;
        }
        NSUInteger currentIndex = [self.listVideoModel.dataArr indexOfObject:(TTVFeedListItem *)cell.item];
        if (currentIndex == NSNotFound) {
            return;
        }
        NSUInteger moreLength = [ExploreListHelper countForPreloadCell];
        NSInteger endIndex = MIN(self.listVideoModel.dataArr.count, (currentIndex + moreLength + [visibleCells count]));
        for(NSInteger idx = currentIndex; idx < endIndex; idx ++)
        {
            [self preloadDetailAtIndex:idx];
        }
        [self.detailPrefetchManager resumeAllRequests];


        if ([self.delegate respondsToSelector:@selector(onPreloadDetail)]) {
            [self.delegate onPreloadDetail];
        }
    }
}

- (void)preloadDetailAtIndex:(NSInteger)index {
    if (index >= [self.listVideoModel.dataArr count]) {
        return;
    }
    id obj = [self.listVideoModel.dataArr objectAtIndex:index];
    if (![obj isKindOfClass:[TTVFeedListItem class]]) {
        return;
    }

    TTVFeedListItem *item = (TTVFeedListItem *)obj;
    TTVFeedItem *videoFeed = item.originData;
    Article *article = [videoFeed ttv_convertedArticle];
    videoFeed.savedConvertedArticle = article;
    NSNumber *adID = article.relatedVideoExtraInfo[kArticleInfoRelatedVideoAdIDKey];
    if (article) {
        //预加载三方广告落地页资源
        NSDictionary *rawAdData = videoFeed.rawAdData;
        tt_listView_preloadWebRes(article, rawAdData);
    }
    if (article.articleType == ArticleTypeWebContent) {
        //预加载wap类型详情页
        // 客户端处于wifi环境下，预加载类型为ArticlePreloadWebTypeOnlyWifiAndAds，代表是建站广告预加载，并且广告ID不为0
        if (TTNetworkWifiConnected() && article.preloadWeb == ArticlePreloadWebTypeOnlyWifiAndAds && [adID longLongValue] != 0) {
            tt_ad_adSiteWebPreload(article, self.superView);
        }

        if (article.preloadWeb != ArticlePreloadWebTypeOnlyWifiAndAds && [adID longLongValue] != 0) {//不预加载非建站广告，直接return
            // 不预加载非建站广告
            return;
        }

    } else if(![article isContentFetched]){
        [self.detailPrefetchManager fetchDetailForArticle:article withOperationPriority:NSOperationQueuePriorityVeryLow notifyError:NO];
    }
}

#pragma mark - NewsFetchArticleDetailManagerDelegate

- (void)fetchDetailManager:(NewsFetchArticleDetailManager *)manager finishWithResult:(NSDictionary *)result
{
    Article *article = result[@"data"];
    article.detailInfoUpdated = YES;
}

@end

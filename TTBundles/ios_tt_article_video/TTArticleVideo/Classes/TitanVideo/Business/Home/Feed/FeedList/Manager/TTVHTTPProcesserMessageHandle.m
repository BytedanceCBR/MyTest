//
//  TTVHTTPProcesserMessageHandle.m
//  Article
//
//  Created by panxiang on 2017/4/7.
//
//

#import "TTVHTTPProcesserMessageHandle.h"
#import "TTMessageCenter.h"
#import "Article.h"
#import "ExploreMixListDefine.h"
#import "TTVArticleUpdateManager.h"
#import "TTAdManager.h"
#import "TTVideoFeedListService+DataManager.h"
#import "TTVideoFeedListServiceMessage.h"

@implementation TTVHTTPProcesserMessageHandle
ShareImplement(TTVHTTPProcesserMessageHandle);

- (void)dealloc
{
    UNREGISTER_MESSAGE(TTHTTPProcesserMessage, self);
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        REGISTER_MESSAGE(TTHTTPProcesserMessage, self);
    }
    return self;
}

- (void)message_deleteArticleRealTimeGroupModels:(NSDictionary *)groupModels commandId:(NSString *)commandId
{
    NSArray *groupIds = groupModels.allKeys;
    if (groupIds.count == 0) {
        return;
    }
    TTVideoFeedListService *articleService = [[TTServiceCenter sharedInstance] getService:[TTVideoFeedListService class]];
    for (NSNumber *uniqueID in groupIds) {
        [articleService removeArticleByUniqueId:[NSString stringWithFormat:@"%@",uniqueID]];
    }
}

- (void)message_updateArticleRealTimeGroupModels:(NSDictionary *)groupModels commandId:(NSString *)commandId
{
    [[TTVArticleUpdateManager sharedManager] addUpdateCommand:commandId groupModels:groupModels];
}

- (void)message_deleteAdRealTimeWithAdIds:(NSArray *)array commandId:(NSString *)commandId
{
    TTVideoFeedListService *articleService = [[TTServiceCenter sharedInstance] getService:[TTVideoFeedListService class]];
    for (NSString *adID in array) {
        [articleService removeArticleByUniqueId:[NSString stringWithFormat:@"%@", adID]];
    }

    // 下架下拉刷新广告
    if (array.count > 0) {
        NSDictionary *refreshADUserInfo = @{kExploreMixListDeleteRefreshADItemsKey : array};
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListRefreshADItemDeleteNotification object:nil userInfo:refreshADUserInfo];
    }
    if (array.count > 0) {
        [TTAdManager realTimeRemoveAd:array];
    }
}
@end

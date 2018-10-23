//
//  TTArticleDetailNatantViewModel.m
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//  详情页浮层VM

#import "TTArticleDetailNatantViewModel.h"
#import "ExploreEntryManager.h"

@interface TTArticleDetailNatantViewModel () <ArticleInfoManagerDelegate>

@property(nonatomic, strong) TTDetailModel *detailModel;
@property(nonatomic, strong) ArticleInfoManager *natantDataManager;

@end

@implementation TTArticleDetailNatantViewModel

- (instancetype)initWithDetailModel:(TTDetailModel *)detailModel
{
    self = [super init];
    if (self) {
        _detailModel = detailModel;
        [self p_initNatantDataManager];
    }
    return self;
}

#pragma mark - public

- (void)tt_startFetchInformationWithFinishBlock:(TTArticleDetailFetchInformationBlock)block
{
    //请求information接口
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setObject:self.detailModel.article.groupModel forKey:kArticleInfoManagerConditionGroupModelKey];
    if ([[self.detailModel.article.comment allKeys] containsObject:@"comment_id"]) {
        [condition setValue:[self.detailModel.article.comment objectForKey:@"comment_id"] forKey:kArticleInfoManagerConditionTopCommentIDKey];
    }
//    [condition setValue:@"1" forKey:@"dislike_source"];
    
    // 转载推荐评论ids
    NSString *zzCommentsID = [self.detailModel.article zzCommentsIDString];
    if (!isEmptyString(zzCommentsID)) {
        [condition setValue:zzCommentsID forKey:@"zzids"];
    }
    
    if ([self.detailModel.adID longLongValue]) {
        NSString *adIDString = [NSString stringWithFormat:@"%lld", [self.detailModel.adID longLongValue]];
        [condition setValue:adIDString forKey:@"ad_id"];
    }
    [condition setValue:self.detailModel.categoryID forKey:kArticleInfoManagerConditionCategoryIDKey];
    [condition setValue:self.detailModel.gdLabel forKey:@"from"];
    [condition setValue:@(0) forKey:@"article_page"];
    
    [self.natantDataManager startFetchArticleInfo:condition finishBlock:block];
}

#pragma mark - private

- (void)p_initNatantDataManager
{
    _natantDataManager = [[ArticleInfoManager alloc] init];
    _natantDataManager.detailModel = self.detailModel;
    _natantDataManager.delegate = self;
}

- (void)p_updateArticleByDict:(NSDictionary *)dict
{
    //added 5.9.9 info更新转码开关
    if ([[dict allKeys] containsObject:@"ignore_web_transform"]) {
        self.detailModel.article.ignoreWebTranform = [dict objectForKey:@"ignore_web_transform"];
    }
    
    //added 5.8+:info会下发natant_level和group_flags用于详情页结构实时可控，需要更新到article
    if ([[dict allKeys] containsObject:@"natant_level"]) {
        self.detailModel.article.natantLevel = [dict objectForKey:@"natant_level"];
    }
    
    if (![self.detailModel.article isVideoSubject] && [[dict allKeys] containsObject:@"group_flags"]) {
        self.detailModel.article.groupFlags = [dict objectForKey:@"group_flags"];
    }
    
    if ([[dict allKeys] containsObject:@"go_detail_count"]) {
        int goDetailCount = [[dict objectForKey:@"go_detail_count"] intValue];
        self.detailModel.article.goDetailCount = @(goDetailCount);
    }
    
    if ([[dict allKeys] containsObject:@"bury_count"]) {
        int buryCount = [[dict objectForKey:@"bury_count"] intValue];
        self.detailModel.article.buryCount = buryCount;
    }
    
    if ([[dict allKeys] containsObject:@"user_bury"]) {
        BOOL userBury = [[dict objectForKey:@"user_bury"] boolValue];
        self.detailModel.article.userBury = userBury;
    }
    
    BOOL bannComment = [[dict objectForKey:@"ban_comment"] boolValue];
    self.detailModel.article.banComment = bannComment;
    
    if ([[dict allKeys] containsObject:@"repin_count"]) {
        int repinCount = [[dict objectForKey:@"repin_count"] intValue];
        self.detailModel.article.repinCount = @(repinCount);
    }
    
    if ([[dict allKeys] containsObject:@"digg_count"]) {
        int diggCount = [[dict objectForKey:@"digg_count"] intValue];
        self.detailModel.article.diggCount = diggCount;
    }
    
    
    if ([[dict allKeys] containsObject:@"ordered_info"]) {
        NSArray *array = [dict tt_arrayValueForKey:@"ordered_info"];
        for (NSDictionary *dataDic in array) {
            if ([[dataDic tt_stringValueForKey:@"name"] isEqualToString:@"like_and_rewards"]) {
                NSDictionary *data = [dataDic tt_dictionaryValueForKey:@"data"];
                self.detailModel.article.likeCount = @([data tt_intValueForKey:@"like_num"]);
            }
        }
    }
    
    if ([[dict allKeys] containsObject:@"like_desc"]) {
        NSString *friendsLikeInfo = [dict objectForKey:@"like_desc"];
        self.detailModel.article.likeDesc = friendsLikeInfo;
    }
    
    if ([[dict allKeys] containsObject:@"share_url"]) {
        NSString * shareURL = [dict objectForKey:@"share_url"];
        self.detailModel.article.shareURL = shareURL;
    }
    
    if ([[dict allKeys] containsObject:@"display_title"]) {
        NSString * displayTitle = [dict objectForKey:@"display_title"];
        self.detailModel.article.displayTitle = displayTitle;
    }
    
    if ([[dict allKeys] containsObject:@"display_url"]) {
        NSString * displayURL = [dict objectForKey:@"display_url"];
        self.detailModel.article.displayURL = displayURL;
    }
    
    /*
     * information 接口返回的接口字段 comment_count 数字不是及时的，所以更新评论数不使用该接口字段
     *
     * 应该使用all_comments接口的total_number字段，该字段是实时更新的
     */
    
    //        if ([[dict allKeys] containsObject:@"comment_count"]) {
    //            int commentCount = [[dict objectForKey:@"comment_count"] intValue];
    //            self.detailModel.article.commentCount = @(commentCount);
    //        }
    
    if ([[dict allKeys] containsObject:@"user_repin"]) {
        BOOL userRepin = [[dict objectForKey:@"user_repin"] boolValue];
        self.detailModel.article.userRepined = userRepin;
    }
    
    if ([[dict allKeys] containsObject:@"user_digg"]) {
        BOOL userDigg = [[dict objectForKey:@"user_digg"] boolValue];
        self.detailModel.article.userDigg = userDigg;
    }
    
    if ([[dict allKeys] containsObject:@"delete"]) {
        BOOL delArticle = [[dict objectForKey:@"delete"] boolValue];
        self.detailModel.article.articleDeleted = @(delArticle);
    }
    
    if ([[dict allKeys] containsObject:@"user_like"]) {
        BOOL userLike = [[dict objectForKey:@"user_like"] boolValue];
        self.detailModel.article.userLike = @(userLike);
    }
    
    if ([[dict allKeys] containsObject:@"media_info"]) {
        NSDictionary *mediaInfo = [dict objectForKey:@"media_info"];
//        if ([self.detailModel.article hasVideoSubjectID]) {
//            self.detailModel.article.detailMediaInfo = mediaInfo;
//        } else {
//            self.detailModel.article.mediaInfo = mediaInfo;
//        }
        self.detailModel.article.mediaInfo = mediaInfo;

        //LOGD(@"information: %@", mediaInfo);
        if ([[mediaInfo allKeys] containsObject:@"subcribed"]) {
            BOOL subscribed = [mediaInfo tt_boolValueForKey:@"subcribed"];
            self.detailModel.article.isSubscribe = @(subscribed);

            NSString *entryID = [mediaInfo stringValueForKey:@"media_id" defaultValue:nil];
            if (!isEmptyString(entryID)) {
                NSArray *entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];
                if (entries.count > 0) {
                    ExploreEntry *entry = entries[0];
                    if (entry && [entry.subscribed boolValue] != subscribed) {
                        entry.subscribed = @(subscribed);
                        [entry save];
                    }
                }
            }
        }
    }
    
    if ([[dict allKeys] containsObject:@"user_info"]){
        NSDictionary *userInfo = [dict tt_dictionaryValueForKey:@"user_info"];
        self.detailModel.article.userInfo = userInfo;
    }
    
    if ([[dict allKeys] containsObject:@"video_watch_count"]) {
        NSInteger videoWatchCount = [[dict objectForKey:@"video_watch_count"] integerValue];
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.article.videoDetailInfo];
        NSInteger currentWatchCount = [info[@"video_watch_count"] integerValue];
        if (videoWatchCount > currentWatchCount) {
            info[@"video_watch_count"] = @(videoWatchCount);
            self.detailModel.article.videoDetailInfo = info;
        }
    }
    
    if ([dict objectForKey:@"h5_extra"]) {
        NSDictionary *h5_extra = [dict dictionaryValueForKey:@"h5_extra" defalutValue:@{}];
        if (SSIsEmptyDictionary(self.detailModel.article.h5Extra)) {
            self.detailModel.article.h5Extra = h5_extra;
        } else {
            self.detailModel.article.h5Extra = ({
                NSMutableDictionary *h5Extra = self.detailModel.article.h5Extra.mutableCopy;
                [h5Extra addEntriesFromDictionary:h5_extra];
                h5Extra.copy;
            });
        }
    }
    
    if ([dict objectForKey:@"ban_bury"]) {
        self.detailModel.article.banBury = [NSNumber numberWithInteger:[dict integerValueForKey:@"ban_bury" defaultValue:0]];
    }
    if ([dict objectForKey:@"ban_digg"]) {
        self.detailModel.article.banDigg = [NSNumber numberWithInteger:[dict integerValueForKey:@"ban_digg" defaultValue:0]];
    }
    
    [self.detailModel.article save];
    //[[SSModelManager sharedManager] save:nil];
}

#pragma mark - ArticleInfoManagerDelegate

- (void)articleInfoManager:(ArticleInfoManager *)manager getStatus:(NSDictionary *)dict
{
    [self p_updateArticleByDict:dict];
}

- (void)articleInfoManagerFetchInfoFailed:(ArticleInfoManager *)manager
{
    //do nothing now
}

@end

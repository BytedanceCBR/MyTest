//
//  TTVRelatedItem+TTVArticleProtocolSupport.m
//  Article
//
//  Created by pei yun on 2017/6/13.
//
//

#import "TTVRelatedItem+TTVArticleProtocolSupport.h"
#import "TTImageInfosModel+Extention.h"
#import "TTAccountManager.h"
#import "TTAccountManager.h"
#import "Article.h"
#import "TTVVideoArticle+Extension.h"
#import "TTVUserInfo+Extension.h"
#import <TTBaseLib/JSONAdditions.h>
#include <objc/runtime.h>
#import "TTVRelatedItem+Extension.h"
#import "TTVRelatedItem+TTVComputedProperties.h"
#import "ExploreOrderedADModel+TTVSupport.h"
#import "TTAdVideoRelateAdModel.h"

@implementation TTVRelatedItem (TTVArticleProtocolSupport)

- (int64_t)uniqueID
{
    return self.article.groupId;
}

- (TTGroupModel *)groupModel
{
    TTVVideoArticle *article = self.article;
    return [[TTGroupModel alloc] initWithGroupID:[@(article.groupId) stringValue] itemID:[@(article.itemId) stringValue] impressionID:nil aggrType:article.aggrType];
}

- (NSString *)itemID
{
    return [@(self.article.itemId) stringValue];
}

- (NSNumber *)groupFlags
{
    return @(self.article.groupFlags);
}

- (NSNumber *)aggrType
{
    return @(self.article.aggrType);
}

- (int)articleType
{
    return self.article.articleType;
}

- (NSNumber *)natantLevel
{
    return @(self.article.natantLevel);
}

- (NSNumber *)videoType
{
    //TODOPY
    //    return @(self.videoBusinessType);
    return @0;
}

- (NSString *)sourceAvatar
{
    return self.article.sourceAvatar;
}

- (NSNumber *)articleDeleted
{
    return @(self.article.extend.deleted);
}

- (void)setUserRepined:(BOOL)userRepined
{
    [self.article setUserRepin:userRepined];
}

- (void)setLogExtra:(NSString *)logExtra
{
    [self.article setLogExtra:logExtra];
}

- (BOOL)userRepined
{
    return self.article.userRepin;
}

- (void)setCommentCount:(int)commentCount
{
    [self.article setCommentCount:commentCount];
}

- (int)commentCount
{
    return (int)self.article.commentCount;
}

- (NSNumber *)detailVideoProportion
{
    return @(self.article.videoProportionArticle);
}

- (NSDictionary *)comment
{
    return nil;
    //TODEL
}

- (NSDictionary *)relatedVideoExtraInfo
{
    return self.article.extend.relatedVideoExtraInfo;
}

- (NSDictionary *)videoDetailInfo
{
    TTVVideoDetailInfo *videoDetailInfo = self.article.videoDetailInfo;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.largeImageDict forKey:@"detail_video_large_image"];
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

- (BOOL)detailShowPortrait
{
    return self.article.showPortraitArticle;
}

- (NSString *)videoLocalURL
{
    return nil;
}

- (NSString *)videoID
{
    return self.article.videoId;
}

- (NSString *)title
{
    return self.article.title;
}

- (NSDictionary *)largeImageDict
{
    return [TTImageInfosModel dictionaryWithImageUrlList:self.article.largeImageList];
}

- (NSDictionary *)videoPlayInfo
{
    NSDictionary *dict = nil;
    NSString *videoPlayInfo = self.article.videoPlayInfo;
    if ([videoPlayInfo isKindOfClass:[NSString class]] && videoPlayInfo.length > 0) {
        NSError *error = nil;
        NSData *stringData = [videoPlayInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            if ([self respondsToSelector:@selector(videoPlayInfo)]) {
                NSMutableDictionary *muDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
                NSString *uid = TTAccountManager.userID;
                [muDic setValue:(uid?uid:@"0") forKey:@"user_id"];
                [muDic setValue:[self videoID] forKey:@"video_id"];
                dict = [muDic copy];
            }
        }
    }
    return dict;
}

- (NSNumber *)videoDuration
{
    return @(self.article.videoDetailInfo.videoDuration);
}

- (NSDictionary *)videoExtendLink
{
    //TODEL
    return nil;
}

- (BOOL)banComment
{
    return self.article.banComment;
}

- (BOOL)hasImage
{
    return NO;
}

- (NSDictionary *)mediaInfo
{
    return nil;
}

- (NSDictionary *)detailMediaInfo
{
    return nil;
}

- (NSDictionary *)userInfo
{
    if (self.hasVideoItem) {
        return [self.videoItem.userInfo dictionary];
    }
    return nil;
}

- (NSDictionary *)detailUserInfo
{
    return [self userInfo];
}

- (NSArray *)zzComments
{
    return nil;
}

- (NSArray *)commoditys
{
    return nil;
}

- (NSString *)rawAdData
{
    return nil;
}

- (TTAdVideoRelateAdModel *)videoAdExtra
{
    TTAdVideoRelateAdModel *relatedAdModel = objc_getAssociatedObject(self, @selector(videoAdExtra));
    if (!relatedAdModel) {
        relatedAdModel = [[TTAdVideoRelateAdModel alloc] initWithDict:self.rawJsonDict];
        objc_setAssociatedObject(self, @selector(videoAdExtra), relatedAdModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return relatedAdModel;
}

- (NSString *)source
{
    return self.article.source;
}

- (NSString *)mediaUserID
{
    return self.article.userId;
}


- (void)setDetail:(ArticleDetail *)detail {
    
    objc_setAssociatedObject(self, @"kTTVArticleDetail", detail, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ArticleDetail *)detail
{
    ArticleDetail *detail = objc_getAssociatedObject(self, @"kTTVArticleDetail");
    if (!detail) {
        detail = [[ArticleDetail alloc] init];
        detail.content = self.article.extend.content;
        detail.updateTime = self.article.extend.updateTime;
    }
    return detail;
}

- (NSNumber *)isOriginal
{
    return @(self.article.isOriginal);
}

- (double)articlePublishTime
{
    return self.article.publishTime;
}

- (int)buryCount
{
    return (int)self.article.buryCount;
}

- (void)setBuryCount:(int)buryCount {
    [self.article setBuryCount:buryCount];
}

- (int)diggCount
{
    return (int)self.article.diggCount;
}

- (void)setDiggCount:(int)diggCount {
    [self.article setDiggCount:diggCount];
}

- (BOOL)userBury
{
    return self.article.userBury;
}

- (void)setUserBury:(BOOL)userBury
{
    self.article.userBury = userBury;
}

- (BOOL)userDigg
{
    return self.article.userDigg;
}

- (void)setUserDigg:(BOOL)userDigg
{
    self.article.userDigg = userDigg;
}

- (NSNumber *)banBury
{
    return @(self.article.banBury);
}

- (NSNumber *)banDigg
{
    return @(self.article.banDigg);
}

- (NSUInteger)preloadWeb
{
    return self.article.preloadWeb;
}

- (NSString *)shareURL
{
    return self.article.shareURL;
}

- (NSString *)displayURL
{
    return self.article.displayURL;
}

- (NSString *)firstZzCommentMediaId
{
    if (self.zzComments.count > 0) {
        if ([self.zzComments[0] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *comment = self.zzComments[0];
            NSDictionary *mediaInfo = [comment tt_dictionaryValueForKey:@"media_info"];
            NSString *mediaId = [mediaInfo tt_stringValueForKey:@"media_id"];
            return mediaId;
        }
    }
    return nil;
}

- (NSString *)articleDetailContent
{
    return self.article.extend.content;
}

- (NSString *)articleURLString
{
    return self.article.articleURL;
}

- (BOOL)isVideoSourceUGCVideo
{
    if (!isEmptyString(self.article.videoSource)) {
        if ([self.article.videoSource isEqualToString:@"ugc_video"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isVideoSourceHuoShan
{
    if (!isEmptyString(self.article.videoSource)) {
        if ([self.article.videoSource isEqualToString:@"huoshan"]){
            return YES;
        }
    }
    return NO;
}

- (BOOL)isVideoSourceUGCVideoOrHuoShan
{
    return [self isVideoSourceUGCVideo] || [self isVideoSourceHuoShan];
}

- (NSString *)zzCommentsIDString
{
    NSInteger count = self.zzComments.count;
    if (count > 0) {
        NSMutableArray *ids = [NSMutableArray arrayWithCapacity:count];
        
        for (NSDictionary *commentDic in self.zzComments) {
            NSString *cmtId = [commentDic tt_stringValueForKey:@"comment_id"];
            if (!isEmptyString(cmtId)) {
                [ids addObject:cmtId];
            }
        }
        
        if (ids.count > 0) {
            return [ids componentsJoinedByString:@","];
        }
    }
    
    return nil;
}

- (NSString *)videoSubjectID
{
    if ([self hasVideoSubjectID]) {
        id subjectID = [self.videoDetailInfo valueForKey:kArticleInfoRelatedVideoSubjectIDKey];
        if ([subjectID isKindOfClass:[NSNumber class]]) {
            NSString *str = [subjectID stringValue];
            if (!isEmptyString(str) && ![str isEqualToString:@"0"]) {
                return str;
            }
        } else if ([subjectID isKindOfClass:[NSString class]] && !isEmptyString(((NSString *)subjectID))) {
            return subjectID;
        }
    }
    return nil;
}

- (BOOL)shouldDirectShowVideoSubject
{
    // TODEL
    return NO;
}

- (BOOL)directPlay
{
    return self.article.videoDetailInfo.directPlay;
}

- (NSString *)relatedLogExtra
{
    TTVRelatedVideoAD *ad = nil;
    if (self.hasAdPic) {
        if ([self.adPic hasAd]) {
            ad = self.adPic.ad;
        }
    }
    if (self.hasVideoItem) {
        if ([self.videoItem hasAd]) {
            ad = self.videoItem.ad;
        }
    }
    
    NSString *logExtr = ad.logExtra;
    if (isEmptyString(logExtr)) {
        logExtr = [self.relatedVideoExtraInfo tt_stringValueForKey:kArticleInfoRelatedVideoLogExtraKey];
    }
    return logExtr;
}

- (BOOL)hasVideoSubjectID
{
    return [[self.videoDetailInfo allKeys] containsObject:kArticleInfoRelatedVideoSubjectIDKey];
}

- (BOOL)hasVideoPlayInfoUrl
{
    NSDictionary *videoList = [self.videoPlayInfo valueForKey:@"video_list"];
    BOOL hasUrl = NO;
    for (NSDictionary *dic in [videoList allValues]) {
        NSString *url0 = [dic valueForKeyPath:@"main_url"];
        NSString *url1 = [dic valueForKeyPath:@"backup_url_1"];
        NSString *url2 = [dic valueForKeyPath:@"backup_url_2"];
        NSString *url3 = [dic valueForKeyPath:@"backup_url_3"];
        
        if (url0.length > 0 || url1.length >0 || url2.length > 0
            || url3.length > 0) {
            hasUrl = YES;
            break;
        }
    }
    return hasUrl;
}

- (BOOL)isVideoUrlValid
{
    return YES;
}

- (NSString *)videoIDOfVideoDetailInfo
{
    return self.videoID;
}

- (ExploreOrderedADModel *)adModel
{
    ExploreOrderedADModel *result = objc_getAssociatedObject(self, @selector(adModel));
    if (!result) {
        NSDictionary *dict = self.rawJsonDict;
        result = [[ExploreOrderedADModel alloc] initWithDictionary:dict];
        if (isEmptyString(result.ad_id) && dict[@"ad_id"]) {
            result.ad_id = [NSString stringWithFormat:@"%@", dict[@"ad_id"]];
        }
        if (isEmptyString(result.ad_id)) {
            result = nil;
        }
        if ([dict[@"effective_play_time"] isKindOfClass:[NSNumber class]] || [dict[@"effective_play_time"] isKindOfClass:[NSString class]]) {
            result.effectivePlayTime = [dict[@"effective_play_time"] floatValue];
        }
        result.click_track_url_list = dict[@"click_track_url_list"];
        result.playTrackUrls = dict[@"play_track_url_list"];
        result.activePlayTrackUrls = dict[@"active_play_track_url_list"];
        result.effectivePlayTrackUrls = dict[@"effective_play_track_url_list"];
        result.playOverTrackUrls = dict[@"playover_track_url_list"];
        objc_setAssociatedObject(self, @selector(adModel), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (NSDictionary *)h5Extra
{
    return [NSString tt_objectWithJSONString:self.article.h5Extra error:nil];
}

- (BOOL)showExtendLink
{
    NSString *linkUrl = [self.videoExtendLink valueForKey:@"url"];
    NSString *appid = [self.videoExtendLink valueForKey:@"apple_id"];
    BOOL isDownloadApp = [[self.videoExtendLink valueForKey:@"is_download_app"] boolValue];
    BOOL show = NO;
    if (isDownloadApp) {
        if (appid.length > 0 || linkUrl.length > 0) {
            show = YES;
        }
    }
    else
    {
        if (linkUrl.length > 0) {
            show = YES;
        }
    }
    return show;
}

- (BOOL)isContentFetched
{
    return !isEmptyString(self.article.extend.content);
}

- (BOOL)isVideoSubject
{
    return !!([self.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeVideoSubject);
}

- (BOOL)isContentFetchedWithForceLoadNative:(BOOL)forceLoadNative
{
    return !isEmptyString(self.article.extend.content);
}

- (instancetype)managedObjectContext {
    return self;
}

- (BOOL)isImageSubject
{
    return NO;
}

- (void)updateFollowed:(BOOL)followed
{
    if (self.hasVideoItem) {
        self.videoItem.userInfo.follow = followed;
    }
}

- (Article *)ttv_convertedArticle
{
    Article *article = [Article objectWithDictionary:nil];
    for (NSString *propertyName in ttv_propertyNamesInProtocol(NSStringFromProtocol(@protocol(TTVArticleProtocol)))) {
        if ([self respondsToSelector:NSSelectorFromString(propertyName)]) {
            if ([self valueForKey:propertyName]) {
                [article setValue:[self valueForKey:propertyName] forKey:propertyName];
            }
        }
    }
    article.hasVideo = @(self.article.hasVideo);
    return article;
}

#pragma mark - Helpers

- (TTVVideoArticle *)article
{
    if (self.hasVideoItem) {
        return self.videoItem.article;
    } else if (self.hasAdPic) {
        return self.adPic.article;
    }
    return nil;
}

- (NSString *)adIDStr
{
    return self.ad.adId;
}

- (NSString *)logExtra
{
    return self.ad.logExtra;
}

- (NSDictionary *)logPbDic
{
    NSDictionary *dic = [self.videoItem.logPb tt_JSONValue];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        return dic;
    }
    return nil;
}

- (NSDictionary *)novelData
{
    return nil;
}
@end

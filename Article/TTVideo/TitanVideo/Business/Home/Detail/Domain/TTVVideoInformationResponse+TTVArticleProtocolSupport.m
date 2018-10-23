//
//  TTVVideoInformationResponse+TTVArticleProtocolSupport.m
//  Article
//
//  Created by pei yun on 2017/5/23.
//
//

#import "TTVVideoInformationResponse+TTVArticleProtocolSupport.h"
#import "TTImageInfosModel+Extention.h"
#import "TTAccountManager.h"
#import "Article.h"
#import "TTVFeedItem+Extension.h"
#import "TTVVideoArticle+Extension.h"
#import "TTVUserInfo+Extension.h"
#include <objc/runtime.h>
#import "TTVVideoInformationResponse+TTVComputedProperties.h"
#import <TTBaseLib/JSONAdditions.h>
#import "ExploreOrderedADModel+TTVSupport.h"
#import "TTAdFeedModel.h"
#import "ExploreOrderedADModel.h"

@interface TTVVideoInformationResponseProperty : NSObject
@property (nonatomic, strong) NSDictionary *activityDic;
@property (nonatomic, strong) NSArray *commoditys;
@property (nonatomic, strong) NSDictionary *logPbDic;
@end

@implementation TTVVideoInformationResponseProperty

@end


@implementation TTVVideoInformationResponse (TTVArticleProtocolSupport)

- (TTVVideoInformationResponseProperty *)extend {
    
    TTVVideoInformationResponseProperty *object = objc_getAssociatedObject(self, @"TTVVideoInformationResponseProperty");
    if (!object) {
        object = [[TTVVideoInformationResponseProperty alloc] init];
        self.extend = object;
    }
    return object;
}

- (void)setExtend:(TTVVideoInformationResponseProperty *)extend {
    if ([extend isKindOfClass:[TTVVideoInformationResponseProperty class]]) {
        objc_setAssociatedObject(self, @"TTVVideoInformationResponseProperty", extend, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}


- (int64_t)uniqueID
{
    int64_t result = self.article.groupId;
    if (result == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman uniqueID];
    }
    return result;
}

- (TTGroupModel *)groupModel
{
    TTVVideoArticle *article = self.article;
    return [[TTGroupModel alloc] initWithGroupID:[@(self.uniqueID) stringValue] itemID:self.itemID impressionID:nil aggrType:article.aggrType];
}

- (NSString *)itemID
{
    NSString *result = [@(self.article.itemId) stringValue];
    if ((result.length == 0 || [result isEqualToString:@"0"]) && self.articleMiddleman) {
        result = [self.articleMiddleman itemID];
    }
    return result;
}

- (NSNumber *)groupFlags
{
    NSNumber *result = @(self.article.groupFlags);
    if ([result longLongValue] == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman groupFlags];
    }
    return result;
}

- (NSNumber *)aggrType
{
    NSNumber *result = @(self.article.aggrType);
    if ([result longLongValue] == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman aggrType];
    }
    return result;
}

- (int)articleType
{
    int result = self.article.articleType;
    if (result == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman articleType];
    }
    return result;
}

- (NSNumber *)natantLevel
{
    NSNumber *result = @(self.article.natantLevel);
    if ([result intValue] == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman natantLevel];
    }
    return result;
}

- (NSNumber *)videoType
{
    //TODOPY
//    return @(self.videoBusinessType);
    return @0;
}

- (NSNumber *)articleDeleted
{
    if (self.delete_p) {
        return @(YES);
    }
    if (self.article.extend.deleted) {
        return @(YES);
    }
    if (self.articleMiddleman) {
        return [self.articleMiddleman articleDeleted];
    }
    return @(NO);
}

- (void)setUserRepined:(BOOL)userRepined
{
    [self.article setUserRepin:userRepined];
    if (self.articleMiddleman) {
        [self.articleMiddleman setUserRepined:userRepined];
    }
}

- (void)setLogExtra:(NSString *)logExtra
{
    [self.article setLogExtra:logExtra];
    if (self.articleMiddleman) {
        [self.articleMiddleman setLogExtra:logExtra];
    }
}

- (BOOL)userRepined
{
    BOOL result = self.article.userRepin;
    if (!result && self.articleMiddleman) {
        result = [self.articleMiddleman userRepined];
    }
    return result;
}

- (void)setCommentCount:(int)commentCount
{
    [self.article setCommentCount:commentCount];
    if (self.articleMiddleman) {
        [self.articleMiddleman setCommentCount:commentCount];
    }
}

- (int)commentCount
{
    int result = (int)self.article.commentCount;
    if (result == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman commentCount];
    }
    return result;
}

- (NSNumber *)detailVideoProportion
{
    NSNumber *result = @(self.article.videoProportionArticle);
    if ([result floatValue] == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman detailVideoProportion];
    }
    return result;
}

- (NSDictionary *)comment
{
    return nil;
    //TODEL
}

- (NSDictionary *)relatedVideoExtraInfo
{
    return nil;
    //TODEL
}

- (NSDictionary *)videoDetailInfo
{
    NSMutableDictionary *dict = nil;
    TTVVideoDetailInfo *videoDetailInfo = self.article.videoDetailInfo;
    if ((!self.article.hasVideoDetailInfo || isEmptyString(videoDetailInfo.videoId)) && self.articleMiddleman) {
        dict = [[self.articleMiddleman videoDetailInfo] mutableCopy];
    }
    if (dict == nil) {
        dict = [[NSMutableDictionary alloc] init];
    }
    if (!SSIsEmptyDictionary(self.largeImageDict)) {
        [dict setValue:self.largeImageDict forKey:@"detail_video_large_image"];
    }
    if (videoDetailInfo.showPgcSubscribe > 0) {
        [dict setValue:@(videoDetailInfo.showPgcSubscribe) forKey:@"show_pgc_subscribe"];
    }
    if (videoDetailInfo.videoPreloadingFlag > 0) {
        [dict setValue:@(videoDetailInfo.videoPreloadingFlag) forKey:@"video_preloading_flag"];
    }
    if (!isEmptyString(videoDetailInfo.videoThirdMonitorURL)) {
        [dict setValue:videoDetailInfo.videoThirdMonitorURL forKey:@"video_third_monitor_url"];
    }
    if (self.article.groupFlags > 0) {
        [dict setValue:@(self.article.groupFlags) forKey:@"group_flags"];
    }
    if (videoDetailInfo.directPlay > 0) {
        [dict setValue:@(videoDetailInfo.directPlay) forKey:@"direct_play"];
    }
    if (!isEmptyString(self.article.videoId)) {
        [dict setValue:self.article.videoId forKey:@"video_id"];
    }
    if (videoDetailInfo.videoWatchCount > 0) {
        [dict setValue:@(videoDetailInfo.videoWatchCount) forKey:@"video_watch_count"];
    }
    if (videoDetailInfo.videoType > 0) {
        [dict setValue:@(videoDetailInfo.videoType) forKey:@"video_type"];
    }
    return [dict copy];
}

- (BOOL)detailShowPortrait
{
    BOOL result = self.article.showPortraitArticle;
    if (!result && self.articleMiddleman) {
        result = [self.articleMiddleman detailShowPortrait];
    }
    return result;
}

- (NSString *)videoLocalURL
{
    return nil;
}

- (NSString *)videoID
{
    NSString *result = self.article.videoId;
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman videoID];
    }
    return result;
}

- (NSString *)title
{
    NSString *result = self.article.title;
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman title];
    }
    return result;
}

- (NSString *)sourceAvatar
{
    NSString *result = self.article.sourceAvatar;
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman sourceAvatar];
    }
    return result;
}

- (NSDictionary *)largeImageDict
{
    if (!self.article.hasLargeImageList && self.articleMiddleman) {
        return [self.articleMiddleman largeImageDict];
    }
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
    if (!dict && self.articleMiddleman) {
        dict = [self.articleMiddleman videoPlayInfo];
    }
    return dict;
}

- (NSNumber *)videoDuration
{
    NSNumber *result = @(self.article.videoDetailInfo.videoDuration);
    if ([result longLongValue] == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman videoDuration];
    }
    return result;
}
//
//- (void)setVideoExtendLink:(NSDictionary *)videoExtendLink
//{
//    //TODEL
//    [self.article.extend setVideoExtendLinkInfo:videoExtendLink];
//    return;
//}

- (NSDictionary *)videoExtendLink
{
    //TODEL
    return self.article.extend.videoExtendLinkInfo;
}

- (BOOL)banComment
{
    BOOL result = self.article.banComment;
    if (!result && self.articleMiddleman) {
        result = [self.articleMiddleman banComment];
    }
    return result;
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
    return [self.userInfoEntity dictionary];
}

- (NSDictionary *)detailUserInfo
{
    return [self userInfo];
}

- (NSArray *)zzComments
{
    return nil;
}

- (TTAdVideoRelateAdModel *)videoAdExtra
{
    return nil;
}

- (NSString *)source
{
    NSString *result = self.article.source;
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman source];
    }
    return result;
}

- (NSString *)mediaUserID
{
    NSString *result = self.article.userId;
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman mediaUserID];
    }
    return result;
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
    NSNumber *result = @(self.article.isOriginal);
    if (![result boolValue] && self.articleMiddleman) {
        result = [self.articleMiddleman isOriginal];
    }
    return result;
}

- (double)articlePublishTime
{
    double result = self.article.publishTime;
    if (result == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman articlePublishTime];
    }
    return result;
}

- (int)buryCount
{
    int result = (int)self.article.buryCount;
    if (result == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman buryCount];
    }
    return result;
}

- (void)setBuryCount:(int)buryCount {
    [self.article setBuryCount:buryCount];
    if (self.articleMiddleman) {
        [self.articleMiddleman setBuryCount:buryCount];
    }
}

- (int)diggCount
{
    int result = (int)self.article.diggCount;
    if (result == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman diggCount];
    }
    return result;
}

- (void)setDiggCount:(int)diggCount {
    [self.article setDiggCount:diggCount];
    if (self.articleMiddleman) {
        [self.articleMiddleman setDiggCount:diggCount];
    }
}

- (BOOL)userBury
{
    BOOL result = self.article.userBury;
    if (!result && self.articleMiddleman) {
        result = [self.articleMiddleman userBury];
    }
    return result;
}

- (void)setUserBury:(BOOL)userBury
{
    [self.article setUserBury:userBury];
    if (self.articleMiddleman) {
        [self.articleMiddleman setUserBury:userBury];
    }
}

- (BOOL)userDigg
{
    BOOL result = self.article.userDigg;
    if (!result && self.articleMiddleman) {
        result = [self.articleMiddleman userDigg];
    }
    return result;
}

- (void)setUserDigg:(BOOL)userDigg
{
    [self.article setUserDigg:userDigg];
    if (self.articleMiddleman) {
        [self.articleMiddleman setUserDigg:userDigg];
    }
}

- (NSNumber *)banBury
{
    NSNumber *result = @(self.article.banBury);
    if (![result boolValue] && self.articleMiddleman) {
        result = [self.articleMiddleman banBury];
    }
    return result;
}

- (NSNumber *)banDigg
{
    NSNumber *result = @(self.article.banDigg);
    if (![result boolValue] && self.articleMiddleman) {
        result = [self.articleMiddleman banDigg];
    }
    return result;
}

- (NSUInteger)preloadWeb
{
    NSUInteger result = self.article.preloadWeb;
    if (result == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman preloadWeb];
    }
    return result;
}

- (NSString *)shareURL
{
    NSString *result = self.article.shareURL;
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman shareURL];
    }
    return result;
}

- (NSString *)displayURL
{
    NSString *result = self.article.displayURL;
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman displayURL];
    }
    return result;
}

- (NSString *)firstZzCommentMediaId
{
    NSString *result = nil;
    if (self.zzComments.count > 0) {
        if ([self.zzComments[0] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *comment = self.zzComments[0];
            NSDictionary *mediaInfo = [comment tt_dictionaryValueForKey:@"media_info"];
            result = [mediaInfo tt_stringValueForKey:@"media_id"];
        }
    }
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman firstZzCommentMediaId];
    }
    return result;
}

- (NSString *)articleDetailContent
{
    NSString *result = self.article.extend.content;
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman articleDetailContent];
    }
    return result;
}

- (NSString *)articleURLString
{
    NSString *result = self.article.articleURL;
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman articleURLString];
    }
    return result;
}

- (BOOL)isVideoSourceUGCVideo
{
    BOOL result = NO;
    if (!isEmptyString(self.article.videoSource)) {
        if ([self.article.videoSource isEqualToString:@"ugc_video"]) {
            result = YES;
        }
    }
    if (!result && self.articleMiddleman) {
        result = [self.articleMiddleman isVideoSourceUGCVideo];
    }
    return result;
}

- (BOOL)isVideoSourceHuoShan
{
    BOOL result = NO;
    if (!isEmptyString(self.article.videoSource)) {
        if ([self.article.videoSource isEqualToString:@"huoshan"]){
            result = YES;
        }
    }
    return result;
}

- (BOOL)isVideoSourceUGCVideoOrHuoShan
{
    return [self isVideoSourceUGCVideo] || [self isVideoSourceHuoShan];
}

- (NSString *)zzCommentsIDString
{
    NSString *result = nil;
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
            result = [ids componentsJoinedByString:@","];
        }
    }
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman zzCommentsIDString];
    }
    return result;
}

- (NSString *)videoSubjectID
{
    NSString *result = nil;
    if ([self hasVideoSubjectID]) {
        id subjectID = [self.videoDetailInfo valueForKey:kArticleInfoRelatedVideoSubjectIDKey];
        if ([subjectID isKindOfClass:[NSNumber class]]) {
            NSString *str = [subjectID stringValue];
            if (!isEmptyString(str) && ![str isEqualToString:@"0"]) {
                result = str;
            }
        } else if ([subjectID isKindOfClass:[NSString class]] && !isEmptyString(((NSString *)subjectID))) {
            result = subjectID;
        }
    }
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman videoSubjectID];
    }
    return result;
}

- (BOOL)shouldDirectShowVideoSubject
{
    // TODEL
    return NO;
}

- (BOOL)directPlay
{
    BOOL result = @(self.article.videoDetailInfo.directPlay);
    if (!result && self.articleMiddleman) {
        result = [self.articleMiddleman directPlay];
    }
    return result;
}

- (NSString *)relatedLogExtra
{
    NSString *result = [self.relatedVideoExtraInfo tt_stringValueForKey:kArticleInfoRelatedVideoLogExtraKey];
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman relatedLogExtra];
    }
    return result;
}

- (BOOL)hasVideoSubjectID
{
    BOOL result = [[self.videoDetailInfo allKeys] containsObject:kArticleInfoRelatedVideoSubjectIDKey];
    if (!result && self.articleMiddleman) {
        result = [self.articleMiddleman hasVideoSubjectID];
    }
    return result;
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
    if (!hasUrl && self.articleMiddleman) {
        hasUrl = [self.articleMiddleman hasVideoPlayInfoUrl];
    }
    return hasUrl;
}

- (BOOL)isVideoUrlValid
{
    BOOL isValid = NO;
    if (self.ttv_requestTime) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - self.ttv_requestTime;
        isValid = interval - 60 * 40 < 0;
    }
    if (!isValid) {
        self.article.videoPlayInfo = nil;
    }
    return isValid;
}

- (NSString *)videoIDOfVideoDetailInfo
{
    NSString *result = self.videoID;
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman videoIDOfVideoDetailInfo];
    }
    return result;
}

- (id<TTAdFeedModel>)adModel
{
    id<TTAdFeedModel> result = nil;
    NSError *error = nil;
    NSDictionary *dict = [NSString tt_objectWithJSONString:self.article.embededAdInfoStr error:&error];
    NSDictionary *rawAdData = [NSString tt_objectWithJSONString:self.article.rawAdDataString error:&error];
    if ([rawAdData isKindOfClass:[NSDictionary class]] && rawAdData.count >= 2) {
        return [[TTAdFeedModel alloc] initWithDictionary:rawAdData error:&error];
    } else if ([dict isKindOfClass:[NSDictionary class]] && dict.count > 0) {
        result = [[ExploreOrderedADModel alloc] initWithDictionary:dict];
        if ([dict[@"effective_play_time"] isKindOfClass:[NSNumber class]] || [dict[@"effective_play_time"] isKindOfClass:[NSString class]]) {
            result.effectivePlayTime = [dict[@"effective_play_time"] floatValue];
        }
        result.click_track_url_list = dict[@"click_track_url_list"];
        result.playTrackUrls = dict[@"play_track_url_list"];
        result.activePlayTrackUrls = dict[@"active_play_track_url_list"];
        result.effectivePlayTrackUrls = dict[@"effective_play_track_url_list"];
        result.playOverTrackUrls = dict[@"playover_track_url_list"];
    }
    if (!result && self.articleMiddleman) {
        result = [self.articleMiddleman adModel];
    }
    return result;
}

- (NSDictionary *)h5Extra
{
    NSDictionary *h5Extra = [NSString tt_objectWithJSONString:self.article.h5Extra error:nil];
    if (!h5Extra && self.articleMiddleman){
        h5Extra = self.articleMiddleman.h5Extra;
    }
    return h5Extra;
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
    if (!show && self.articleMiddleman) {
        show = [self.articleMiddleman showExtendLink];
    }
    return show;
}

- (BOOL)isContentFetchedWithForceLoadNative:(BOOL)forceLoadNative
{
    BOOL result = !isEmptyString(self.article.extend.content);
    if (!result && self.articleMiddleman) {
        result = [self.articleMiddleman isContentFetchedWithForceLoadNative:forceLoadNative];
    }
    return result;
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
    self.userInfoEntity.follow = followed;
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

- (NSDictionary *)logPbDic
{
    if (!self.extend.logPbDic) {
        NSDictionary *dic = [self.logPb tt_JSONValue];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            self.extend.logPbDic = dic;
        }
    }
    return self.extend.logPbDic;
}


- (NSDictionary *)novelData
{
    return nil;
}

- (NSString *)logExtra
{
    NSString *result = self.adModel.log_extra;
    if (isEmptyString(result)) {
        result = self.article.logExtra;
    }
    return result;
}

- (NSString *)adIDStr
{
    NSString *result = self.adModel.ad_id;
    if (isEmptyString(result)) {
        result = self.article.adId;
    }
    return result;
}

- (NSArray *)commoditys {
    
    if (!self.extend.commoditys) {
        NSArray *array = [self.article.commodityString tt_JSONValue];
        if ([array isKindOfClass:[NSArray class]]) {
            self.extend.commoditys = array;
        }
    }
    return self.extend.commoditys;
}

- (NSString *)rawAdData
{
    return nil;
}

- (NSDictionary *)activityDic
{
    if (!self.extend.activityDic) {
        NSDictionary *dic = [self.activity tt_JSONValue];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            self.extend.activityDic = dic;
        }
    }
    return self.extend.activityDic;
}
@end




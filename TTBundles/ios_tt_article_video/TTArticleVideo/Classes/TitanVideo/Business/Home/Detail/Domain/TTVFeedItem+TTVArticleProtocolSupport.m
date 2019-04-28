//
//  TTVFeedItem+TTVArticleProtocolSupport.m
//  Article
//
//  Created by pei yun on 2017/4/9.
//
//

#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+Extension.h"
#import "TTImageInfosModel+Extention.h"
#import "TTAccountManager.h"
#import "Article.h"
#import "TTVFeedItem+Extension.h"
#import "TTVVideoArticle+Extension.h"
#import "TTVUserInfo+Extension.h"
#include <objc/runtime.h>
#import "TTVFeedItem+TTVConvertToArticle.h"
#import <TTBaseLib/JSONAdditions.h>
#import "ExploreOrderedADModel+TTVADSupport.h"
#import "JSONAdditions.h"
#import "TTAdFeedModel.h"

#define kArticleInfoRelatedVideoSubjectIDKey @"video_subject_id"
#define kArticleInfoRelatedVideoLogExtraKey  @"log_extra"

@interface TTVFeedItemProperty : NSObject
@property (nonatomic, strong) NSDictionary *logPbDic;
@property (nonatomic, strong) NSArray *commoditys;
@property (nonatomic, strong) NSDictionary *rawAdData;
@end

@implementation TTVFeedItemProperty

@end


@implementation TTVFeedItem (TTVArticleProtocolSupport)
- (TTVFeedItemProperty *)extend {
    
    TTVFeedItemProperty *object = objc_getAssociatedObject(self, @"TTVFeedItemProperty");
    if (!object) {
        object = [[TTVFeedItemProperty alloc] init];
        self.extend = object;
    }
    return object;
}

- (void)setExtend:(TTVFeedItemProperty *)extend {
    if ([extend isKindOfClass:[TTVFeedItemProperty class]]) {
        objc_setAssociatedObject(self, @"TTVFeedItemProperty", extend, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (int64_t)uniqueID
{
    return [[self uniqueIDStr] longLongValue];
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
    return @(self.videoBusinessType);
}

- (NSNumber *)articleDeleted
{
    return @(self.article.extend.deleted);
}

- (void)setUserRepined:(BOOL)userRepined
{
    [self.article setUserRepin:userRepined];
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
    return nil;
    //TODEL
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
    return [self.videoCell.userInfo dictionary];
}

- (NSDictionary *)detailUserInfo
{
    return self.userInfo;
}

- (NSArray *)zzComments
{
    return nil;
}

- (TTAdVideoRelateAdModel *)videoAdExtra
{
    // TODEL
    return nil;
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

- (void)setLogExtra:(NSString *)logExtra
{
    [self.article setLogExtra:logExtra];
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

- (NSString *)sourceAvatar
{
    return self.article.sourceAvatar;
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
    NSString *logExtr = [self.relatedVideoExtraInfo tt_stringValueForKey:kArticleInfoRelatedVideoLogExtraKey];
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
    BOOL isValid = NO;
    if (self.requestTime) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - self.requestTime;
        isValid = interval - 60 * 40 < 0;
    }
    if (!isValid) {
        self.article.videoPlayInfo = nil;
    }
    return isValid;
}

- (NSString *)videoIDOfVideoDetailInfo
{
    return self.videoID;
}

- (id<TTAdFeedModel>)adModel
{
    if (self.rawAdData.count >= 2) {
        return [[TTAdFeedModel alloc] initWithDictionary:self.rawAdData error:nil];
    }
    if (self.hasAdCell) {
        ExploreOrderedADModel *model = [ExploreOrderedADModel adModelWithTTVADInfo:self.adCell article:self.adCell.article];
        return model;
    }
    return nil;
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
    self.videoCell.userInfo.follow = followed;
}

- (Article *)ttv_convertedArticle
{
    Article *article = [Article objectWithDictionary:nil];
    for (NSString *propertyName in ttv_propertyNamesInProtocol(NSStringFromProtocol(@protocol(TTVArticleProtocol)))) {
        if ([self respondsToSelector:NSSelectorFromString(propertyName)]) {
            if ([self valueForKey:propertyName]) {
                //                SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]);
                [article setValue:[self valueForKey:propertyName] forKey:propertyName];
            }
        }
    }
    article.convertedFromFeedItem = YES;
    article.hasVideo = @(self.article.hasVideo);
    article.raw_ad_data = self.rawAdData;
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
    if (self.article.logExtra) {
        return self.article.logExtra;
    }
    return self.adModel.log_extra;
}

- (NSString *)adIDStr
{
    if (self.article.adId) {
        return self.article.adId;
    }
    return self.adModel.ad_id;
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

- (NSDictionary *)rawAdData {
    
    if (!self.extend.rawAdData) {
        NSDictionary *obj = [self.article.rawAdDataString tt_JSONValue];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            self.extend.rawAdData = obj;
        }
    }
    return self.extend.rawAdData;
}

@end

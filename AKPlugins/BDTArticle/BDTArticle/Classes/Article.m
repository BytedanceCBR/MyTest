//
//  Article.m
//  Article
//
//  Created by Hu Dianwei on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Article.h"
#import <TTBaseLib/JSONAdditions.h>
#import "NSStringAdditions.h"
#import "NSDictionary+TTAdditions.h"
#import "NSString-Extension.h"
#import "TTFollowManager.h"
#import "TTBlockManager.h"
#import "TTAdConstant.h"
#import "TTAccountBusiness.h"
#import <TTNetworkManager/TTNetworkDefine.h>
#import <TTSettingsManager/TTSettingsManager.h>


@implementation TTArticleReadQualityModel

- (NSString *)description {
    return [NSString stringWithFormat:@"[ReadQuality]read_pct:%@%%, staytime:%d(s)", self.readPct, (int)[self.stayTimeMs doubleValue]/1000];
}

@end

@implementation ArticleDetail
+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"primaryID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[@"primaryID", @"content", @"updateTime"];
    };
    return properties;
}

+ (void)cleanEntities {
    NSTimeInterval t1 = CFAbsoluteTimeGetCurrent();
    
    float oneM = 1024.f *1024.f;
    float dbSize = [ArticleDetail dbSize] / oneM;
    
    NSNumber *countBeforeClean = [self aggregate:@"count(*)" where:nil arguments:nil];
    if (countBeforeClean) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        });
    }
    
    // 表中保留的最大记录数
    int maxCountToKeep = 300;
    
    // 触发清理的阈值
    int threshold = 500;
    
    if (countBeforeClean.longLongValue > threshold) {
        NSArray<ArticleDetail *> *dataArray = [self objectsWithQuery:nil orderBy:@"updateTime DESC" offset:maxCountToKeep limit:1];
        if (dataArray.count > 0) {
            ArticleDetail *detail = dataArray.firstObject;
            if (detail.updateTime > 0) {
                [self deleteObjectsWhere:@"WHERE (updateTime <= ?)" arguments:@[@(detail.updateTime)]];
                
                NSNumber *countAfterClean = [self aggregate:@"count(*)" where:nil arguments:nil];
                LOGD(@"%@ : %@ -> %@", NSStringFromClass(self), countBeforeClean, countAfterClean);
                
                NSTimeInterval t2 = CFAbsoluteTimeGetCurrent();
                
            }
        }
    }
    else {
#if DEBUG
        LOGD(@"%@ : %@", NSStringFromClass(self), countBeforeClean);
#endif
    }
}

@end

@interface Article () {
    ListViewDisplayType _displayType;
    NSDictionary *_detailMediaInfo;
    NSDictionary *_detailUserInfo;
    NSDictionary *_relatedVideoExtraInfo;
    TTAdVideoRelateAdModel *_videoAdExtra;
    NSDictionary *_videoExtendLink;
}
@property (nonatomic, retain) ArticleDetail *detail;
@end

@implementation Article

@synthesize detailMediaInfo = _detailMediaInfo;
@synthesize detailUserInfo = _detailUserInfo;
@synthesize relatedVideoExtraInfo = _relatedVideoExtraInfo;
@synthesize videoAdExtra = _videoAdExtra;
@synthesize videoExtendLink = _videoExtendLink;
@synthesize commoditys = _commoditys;

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"primaryID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        NSMutableArray *props = [NSMutableArray arrayWithArray:[super persistentProperties]];
        [props removeObject:@"commentCount"];
        [props removeObject:@"diggCount"];
        [props removeObject:@"userDigg"];
        [props removeObject:@"hasRead"];
        [props removeObject:@"likeCount"];
        [props removeObject:@"userLike"];
        
        properties = [props arrayByAddingObjectsFromArray:@[
                                                            @"primaryID",
                                                            @"abstract",
                                                            @"articleSubType",
                                                            @"articleType",
                                                            @"articleURLString",
                                                            @"banComment",
                                                            @"comment",
                                                            @"comments",
                                                            @"zzComments",
                                                            //@"content",
                                                            @"detailNoComments",
                                                            @"displayTitle",
                                                            @"displayURL",
                                                            @"openURL",
                                                            @"goDetailCount",
                                                            @"groupType",
                                                            @"hasImage",
                                                            @"hasVideo",
                                                            @"imageDetailListString",
                                                            @"itemVersion",
                                                            @"keywords",
                                                            @"middleImageDict",
                                                            @"natantLevel",
                                                            @"preloadWeb",
                                                            @"source",
                                                            @"sourceURL",
                                                            @"tcHeadText",
                                                            @"thumbnailListString",
                                                            @"title",
                                                            @"subtitle",
                                                            @"topicGroupId",
                                                            @"listGroupImgDicts",
                                                            @"filterWords",
                                                            @"sourceIconDict",
                                                            @"sourceIconNightDict",
                                                            @"videoID",
                                                            @"videoDuration",
                                                            @"videoDetailInfo",
                                                            @"ugcVideoCover",
                                                            @"mediaName",
                                                            @"isOriginal",
                                                            @"ignoreWebTranform",
                                                            @"articlePublishTime",
                                                            @"sourceAvatar",
                                                            @"isSubscribe",
                                                            @"articlePosition",
                                                            
                                                            @"itemID",
                                                            @"aggrType",
                                                            
                                                            @"adPromoter",
                                                            @"embededAdInfo",
                                                            @"raw_ad_data",
                                                            
                                                            @"largeImageDict",
                                                            @"galleries",
                                                            @"gallaryFlag",
                                                            @"gallaryImageCount",
                                                            @"mediaInfo",
                                                            @"imageMode",
                                                            
                                                            @"entityWordInfoDict",
                                                            @"wapHeaders",
                                                            @"h5Extra",
                                                            @"novelData",
                                                            
                                                            @"sourceOpenUrl",
                                                            @"sourceDesc",
                                                            @"sourceDescOpenUrl",
                                                            @"sourceIconStyle",
                                                            @"wendaExtra",
                                                            @"videoType",
                                                            @"videoSource",
                                                            @"videoProportion",
                                                            @"videoLocalURL",
                                                            @"userInfo",
                                                            @"createdTime",
                                                            @"videoPlayInfo",
                                                            @"recommendReason",
                                                            @"showPortrait",
                                                            @"detailVideoProportion",
                                                            @"detailShowPortrait",
                                                            @"userRelation",
                                                            @"ugcInfo",
                                                            @"mediaUserID",
                                                            @"adIDStr",
                                                            @"logExtra",
                                                            @"schema",
                                                            @"banBury",
                                                            @"banDigg",
                                                            @"share_count",
                                                            @"articleOpenURL",
                                                            @"showMaxLine",
                                                            @"picDisplayType",
                                                            @"recommendDict",
                                                            @"happyKnocking",
                                                            @"commoditys",
                                                            @"payStatus",
                                                            @"titleRichSpanJSONString",
                                                            @"navTitleUrl",
                                                            @"navTitleType",
                                                            @"navOpenUrl",
                                                            @"navTitleNightUrl",
                                                            @"contentDecoration"
                                                            ]];
    };
    return properties;
}

//注.此处的映射，客户端以topic表示专题， 服务器端后面修改为subject。
+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"embededAdInfo":@"ad_button",
                                         @"adPromoter":@"ad_data",
                                         @"aggrType":@"aggr_type",
                                         @"articlePosition":@"article_position",
                                         @"articleSubType":@"article_sub_type",
                                         @"articleType":@"article_type",
                                         @"articleURLString":@"article_url",
                                         @"banComment":@"ban_comment",
                                         @"buryCount":@"bury_count",
                                         @"detailNoComments":@"detail_no_comments",
                                         @"displayTitle":@"display_title",
                                         @"displayURL":@"display_url",
                                         @"gallaryFlag":@"gallary_flag",
                                         @"gallaryImageCount":@"gallary_image_count",
                                         @"galleries":@"gallery",
                                         @"goDetailCount":@"go_detail_count",
                                         @"groupFlags":@"group_flags",
                                         @"groupType":@"group_type",
                                         @"hasImage":@"has_image",
                                         @"hasVideo":@"has_video",
                                         @"ignoreWebTranform":@"ignore_web_transform",
                                         @"infoDesc":@"info_desc",
                                         @"isOriginal":@"is_original",
                                         @"isSubscribe":@"is_subscribe",
                                         @"itemVersion":@"item_version",
                                         @"likeCount":@"like_count",
                                         @"likeDesc":@"like_desc",
                                         @"logExtra":@"log_extra",
                                         @"mediaName":@"media_name",
                                         @"natantLevel":@"natant_level",
                                         @"notInterested":@"not_interested",
                                         @"novelData":@"novel_data",
                                         @"openURL":@"open_url",
                                         @"preloadWeb":@"preload_web",
                                         @"articlePublishTime":@"publish_time",
                                         @"recommendReason":@"recommend_reason",
                                         @"repinCount":@"repin_count",
                                         @"schema":@"schema",
                                         @"shareURL":@"share_url",
                                         @"showPortrait":@"show_portrait",
                                         @"detailShowPortrait":@"show_portrait_article",
                                         @"sourceAvatar":@"source_avatar",
                                         @"sourceDesc":@"source_desc",
                                         @"sourceDescOpenUrl":@"source_desc_open_url",
                                         @"sourceIconStyle":@"source_icon_style",
                                         @"sourceOpenUrl":@"source_open_url",
                                         @"subtitle":@"sub_title",
                                         @"topicGroupId":@"subject_group_id",
                                         @"tcHeadText":@"tc_head_text",
                                         @"ugcInfo":@"ugc_info",
                                         @"sourceURL":@"url",
                                         @"userBury":@"user_bury",
                                         @"userLike":@"user_like",
                                         @"userRelation":@"user_relation",
                                         @"userRepined":@"user_repin",
                                         @"userRepinTime":@"user_repin_time",
                                         @"videoDuration":@"video_duration",
                                         @"videoID":@"video_id",
                                         @"videoLocalURL":@"video_local_url",
                                         @"videoProportion":@"video_proportion",
                                         @"detailVideoProportion":@"video_proportion_article",
                                         @"videoSource":@"video_source",
                                         @"share_count":@"share_count",
                                         @"banBury":@"ban_bury",
                                         @"banDigg":@"ban_digg",
                                         @"articleOpenURL":@"article_open_url",
                                         @"showMaxLine":@"show_max_line",
                                         @"picDisplayType" : @"display_type",
                                         @"recommendDict":@"ugc_recommend",
                                         @"galleryAdditional": @"gallery_additional",
                                         @"payStatus": @"pay_status",
                                         @"titleRichSpanJSONString":@"title_rich_span",
                                         }];
        properties = [dict copy];
    }
    return properties;
}

+ (GYCacheLevel)cacheLevel {
    return GYCacheLevelResident;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addObserveNotification];
    }
    return self;
}

- (void)dealloc {
    [self removeObserveNotification];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    Article *other = (Article *)object;
    if (self.uniqueID != other.uniqueID) {
        return NO;
    }
    
    if ((self.itemID || other.itemID) && ![self.itemID isEqual:other.itemID]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return [self.primaryID hash];
}

- (NSString*)commentContent
{
    NSMutableString *result = [NSMutableString stringWithCapacity:50];
    
    // 是否推荐转载
    BOOL isZZ;
    NSDictionary *comment;
    
    
    if (self.zzComments.count > 0) {
        // 优先显示推荐转载的评论信息
        comment = self.zzComments[0];
        isZZ    = YES;
    }
    else if (self.comment) {
        // 普通评论
        comment = self.comment;
        isZZ    = NO;
    }
    else {
        comment = nil;
        isZZ    = NO;
    }
    
    if (comment) {
        NSDictionary *mediaInfo = [comment tt_dictionaryValueForKey:@"media_info"];
        NSString *userName      = [comment tt_stringValueForKey:@"user_name"];
        NSString *mediaName     = [mediaInfo tt_stringValueForKey:@"name"];
        NSString *name          = isZZ ? mediaName : userName;
        
        if (name) {
            [result appendFormat:@"%@：", name];
        }
        
        NSString *text = [comment tt_stringValueForKey:@"text"];
        
        if (text) {
            [result appendFormat:@"%@", text];
        }
    }
    
    return result;
}

+ (NSString *)primaryIDFromDictionary:(NSDictionary *)dictionary {
    id itemId = [dictionary valueForKey:@"item_id"]?:dictionary[@"itemID"];
    if (itemId) {
        itemId = [NSString stringWithFormat:@"%@", itemId];
    }
    
    int64_t uniqueID = [dictionary longlongValueForKey:@"uniqueID" defaultValue:0];
    NSString *adIDStr = [dictionary tt_stringValueForKey:@"ad_id"];
    
    return [Article primaryIDByUniqueID:uniqueID itemID:itemId adID:adIDStr];
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
    Article *object = [super objectWithDictionary:dictionary];
    object.primaryID = [self primaryIDFromDictionary:dictionary];
    return object;
}

- (void)updateWithDictionary:(NSDictionary*)dataDict
{
    @try
    {
        if ([dataDict valueForKey:@"aggr_type"]) {
            self.aggrType = @([dataDict[@"aggr_type"] longLongValue]);
        }
        
        int oldBury = self.buryCount;
        int oldDigg = self.diggCount;
        int oldLike = [self.likeCount intValue];
        BOOL digged = self.userDigg;
        BOOL buried = self.userBury;
        BOOL liked  = [self.userLike boolValue];
        
        NSString *content = [dataDict stringValueForKey:@"content" defaultValue:nil];
        
        // the content updated by super method will be igonred
        //        NSString *tmpContent = self.content;
        
        [super updateWithDictionary:dataDict];
        
        self.actionDataModel = [GET_SERVICE(FRActionDataService) modelWithUniqueID:[NSString stringWithFormat:@"%lld", self.uniqueID] type:FRActionDataModelTypeArticle];
        if ([dataDict objectForKey:@"comment_count"]) { //避免server未下发导致置0
            self.actionDataModel.commentCount = [dataDict tt_longValueForKey:@"comment_count"];
        }
        if ([dataDict objectForKey:@"digg_count"]) { //避免server未下发导致置0
            self.actionDataModel.diggCount = [dataDict tt_longValueForKey:@"digg_count"];
        }
        NSDictionary *forwardInfo = [dataDict dictionaryValueForKey:@"forward_info" defalutValue:nil];
        if ([forwardInfo objectForKey:@"forward_count"]) {
            self.actionDataModel.repostCount = [forwardInfo tt_longValueForKey:@"forward_count"];
        }
        if ([dataDict objectForKey:@"read_count"]) { //避免server未下发导致置0
            self.actionDataModel.readCount = [dataDict tt_longValueForKey:@"read_count"];
        }
        if ([dataDict objectForKey:@"like_count"]) {//避免server未下发导致置0
            self.actionDataModel.articleLikeCount = [dataDict tt_longValueForKey:@"like_count"];
        }
        if ([dataDict objectForKey:@"user_digg"]) { //避免server未下发导致置0
            self.actionDataModel.hasDigg = [dataDict tt_boolValueForKey:@"user_digg"];
        }
        if ([dataDict objectForKey:@"has_read"]) { //避免server未下发导致置0
            self.actionDataModel.hasRead = [dataDict tt_boolValueForKey:@"has_read"];
        }
        if ([dataDict objectForKey:@"delete"]) { //避免server未下发导致置0
            self.actionDataModel.hasDelete = [dataDict tt_boolValueForKey:@"delete"];
        }
        if ([dataDict objectForKey:@"user_like"]) {
            self.actionDataModel.articleHasLike = [dataDict tt_boolValueForKey:@"user_like"];
        }
        if ([dataDict objectForKey:@"content_decoration"]) { //避免server未下发导致置0
            NSData *jsonData = [[dataDict tt_stringValueForKey:@"content_decoration"] dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            if (jsonData) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&err];
                self.contentDecoration = [dic tt_stringValueForKey:@"url"];
            } else {
                self.contentDecoration = nil;
            }
        } else {
            self.contentDecoration = nil;
        }
        
        //LOGD(@"%@", self.title);
        //LOGD(@"%@", dataDict[@"is_subscribe"]);
        
        if (!self.itemID) {
            self.itemID = [dataDict stringValueForKey:@"item_id" defaultValue:nil];
        }
        
        NSString *abstract = [dataDict stringValueForKey:@"answer_abstract" defaultValue:nil];
        if (!self.abstract && abstract) {
            self.abstract = abstract;
        }
        
        //        self.content = tmpContent;
        
        if ([dataDict objectForKey:@"gallery"]) {
            self.galleries = [dataDict arrayValueForKey:@"gallery" defaultValue:nil];
        }
        
        //单篇文章导流超时加载转码的开关改为默认关
        if ([dataDict objectForKey:@"ignore_web_transform"]) {
            self.ignoreWebTranform = @([dataDict integerValueForKey:@"ignore_web_transform" defaultValue:YES]);
        }
        else {
            //info不下发，加此逻辑，后续改为sqlite后需要review
            if (nil == self.ignoreWebTranform) {
                self.ignoreWebTranform = @(YES);
            }
        }
        
        if(!isEmptyString(content))
        {
            //self.content = content;
            if (!_detail) {
                ArticleDetail *detail = [[ArticleDetail alloc] init];
                self.detail = detail;
            }
            if (!isEmptyString(self.primaryID)) {
                _detail.primaryID = self.primaryID;
            } else {
                _detail.primaryID = [Article primaryIDFromDictionary:dataDict];
            }
            _detail.content = content;
            _detail.updateTime = [[NSDate date] timeIntervalSince1970];
        }
        
        BOOL banBury = [self.banBury boolValue];//如果禁止踩，踩的数量会变成0/1，需要允许其变小
        BOOL banDigg = [self.banDigg boolValue];//如果禁止顶／踩，顶／踩的数量会变成0/1，需要允许其变小
        
        if(oldBury > self.buryCount && !banBury)
        {
            self.buryCount = oldBury;
        }
        
        if(oldDigg > self.diggCount && !banDigg)
        {
            self.diggCount = oldDigg;
        }
        
        if (oldLike > [self.likeCount intValue] && !banDigg) {
            self.likeCount = [NSNumber numberWithInt:oldLike];
        }
        
        self.userBury = buried | self.userBury;
        self.userDigg = digged | self.userDigg;
        self.userLike = [NSNumber numberWithBool:liked | [self.userLike boolValue]];
        
        if([dataDict objectForKey:@"image_list"])
        {
            self.listGroupImgDicts = [dataDict arrayValueForKey:@"image_list"
                                                   defaultValue:nil];
        }
        
        NSArray *filterWords = [dataDict objectForKey:@"filter_words"];
        if ([filterWords isKindOfClass:[NSArray class]])
        {
            self.filterWords = filterWords;
        }
        
        if([dataDict objectForKey:@"image_detail"])
        {
            NSArray *imageList = [dataDict arrayValueForKey:@"image_detail"
                                               defaultValue:nil];
            if ([imageList count] > 0) {
                self.imageDetailListString = [imageList tt_JSONRepresentation];
            }
            else {
                self.imageDetailListString = nil;
            }
        }
        
        if ([dataDict objectForKey:@"thumb_image"]) {
            NSArray * thumbList = [dataDict arrayValueForKey:@"thumb_image"
                                                defaultValue:nil];
            if ([thumbList count] > 0) {
                self.thumbnailListString = [thumbList tt_JSONRepresentation];
            }
            else {
                self.thumbnailListString = nil;
            }
        }
        
        if([dataDict objectForKey:@"comment"])
        {
            self.comment = [dataDict dictionaryValueForKey:@"comment"
                                              defalutValue:nil];
        }
        
        if([dataDict objectForKey:@"comments"])
        {
            self.comments = [dataDict arrayValueForKey:@"comments"
                                          defaultValue:nil];
        }
        
        if ([dataDict objectForKey:@"zzcomment"])
        {
            self.zzComments = [dataDict arrayValueForKey:@"zzcomment" defaultValue:nil];
        }
        
        if([dataDict objectForKey:@"middle_image"])
        {
            self.middleImageDict = [dataDict dictionaryValueForKey:@"middle_image"
                                                      defalutValue:nil];
        }
        
        if([dataDict objectForKey:@"large_image_list"])
        {
            NSArray *imageLists = [dataDict arrayValueForKey:@"large_image_list"
                                                defaultValue:nil];
            if ([imageLists count] > 0) {
                NSDictionary *dataDict = [imageLists objectAtIndex:0];
                self.largeImageDict = dataDict;
            }
            else {
                self.largeImageDict = nil;
            }
        }
        
        if([dataDict objectForKey:@"source"])
        {
            self.source = [[dataDict stringValueForKey:@"source" defaultValue:nil] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        
        if ([dataDict objectForKey:@"natant_level"]) {
            self.natantLevel = @([dataDict integerValueForKey:@"natant_level" defaultValue:0]);
        } else {
            self.natantLevel = self.natantLevel? :@(0);
        }
        
        
        if([dataDict objectForKey:@"source_icon"])
        {
            self.sourceIconDict = [dataDict dictionaryValueForKey:@"source_icon"
                                                     defalutValue:nil];
        }
        
        if([dataDict objectForKey:@"source_icon_night"])
        {
            self.sourceIconNightDict = [dataDict dictionaryValueForKey:@"source_icon_night"
                                                          defalutValue:nil];
        }
        
        //        if ([dataDict objectForKey:@"media_info"]) {
        //            NSDictionary *mediaInfo = [dataDict dictionaryValueForKey:@"media_info" defalutValue:nil];
        //            if ([self hasVideoSubjectID]) {
        //                self.detailMediaInfo = mediaInfo;
        //            } else {
        //                self.mediaInfo = mediaInfo;
        //            }
        //
        //            // 没有下发订阅状态时，查询本地
        //            /*if (![dataDict objectForKey:@"is_subscribe"]) {
        //                NSString *mediaId = [self.mediaInfo tt_stringValueForKey:@"media_id"];
        //                if (!isEmptyString(mediaId)) {
        //                    ExploreEntry *item = [[ExploreEntryManager sharedManager] fetchEntyWithMediaID:mediaId];
        //                    if (item) {
        //                        self.isSubscribe = item.subscribed;
        //                    }
        //                }
        //            }*/
        //        }
        
        //只更新key相同的,保留不同key的字段
        if ([[dataDict allKeys] containsObject:@"media_info"]) {
            NSDictionary *mediaInfo = [dataDict dictionaryValueForKey:@"media_info" defalutValue:nil];
            if ([self hasVideoSubjectID]) {
                NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:30];
                if ([self.detailMediaInfo count] > 0) {
                    [tmpDict addEntriesFromDictionary:self.detailMediaInfo];
                }
                [mediaInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [tmpDict setValue:obj forKey:key];
                }];
                self.detailMediaInfo = [tmpDict copy];
            } else {
                NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:30];
                if ([self.mediaInfo count] > 0) {
                    [tmpDict addEntriesFromDictionary:self.mediaInfo];
                }
                [mediaInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [tmpDict setValue:obj forKey:key];
                }];
                self.mediaInfo = [tmpDict copy];
            }
        }
        
        
        //        if ([dataDict objectForKey:@"user_info"]) {
        //            NSDictionary *userInfo = [dataDict dictionaryValueForKey:@"user_info" defalutValue:nil];
        //            if ([self hasVideoSubjectID]) {
        //                self.detailUserInfo = userInfo;
        //            } else {
        //                self.userInfo = userInfo;
        //            }
        //        }
        //只更新key相同的,保留不同key的字段
        if ([[dataDict allKeys] containsObject:@"user_info"]) {
            NSDictionary *userInfo = [dataDict dictionaryValueForKey:@"user_info" defalutValue:nil];
            if ([self hasVideoSubjectID]) {
                NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:30];
                if ([self.detailUserInfo count] > 0) {
                    [tmpDict addEntriesFromDictionary:self.detailUserInfo];
                }
                [userInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [tmpDict setValue:obj forKey:key];
                }];
                self.detailUserInfo = [tmpDict copy];
            } else {
                NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:30];
                if ([self.userInfo count] > 0) {
                    [tmpDict addEntriesFromDictionary:self.userInfo];
                }
                [userInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [tmpDict setValue:obj forKey:key];
                }];
                self.userInfo = [tmpDict copy];
            }
        }
        
        
        if ([dataDict objectForKey:@"media_user_id"]) {
            self.mediaUserID = [dataDict tt_stringValueForKey:@"media_user_id"];
        }
        
        ///...
        // 实体词
        NSString *entityText = dataDict[kEntityText];
        if (!isEmptyString(entityText)) {
            NSMutableDictionary *entityDict = [NSMutableDictionary dictionaryWithCapacity:7];
            [entityDict setValue:dataDict[kEntityId] forKey:kEntityId];
            [entityDict setValue:dataDict[kEntityWord] forKey:kEntityWord];
            [entityDict setValue:dataDict[kEntityText] forKey:kEntityText];
            [entityDict setValue:dataDict[kEntityScheme] forKey:kEntityScheme];
            [entityDict setValue:dataDict[kEntityFollowed] forKey:kEntityFollowed];
            [entityDict setValue:dataDict[kEntityStyle] forKey:kEntityStyle];
            [entityDict setValue:dataDict[kEntityConcernID] forKey:kEntityConcernID];
            NSArray *rangeArray = dataDict[kEntityMark];
            NSMutableArray *wordRangeArray = [NSMutableArray arrayWithCapacity:2];
            [rangeArray enumerateObjectsUsingBlock:^(NSArray * _Nonnull range, NSUInteger idx, BOOL * _Nonnull stop) {
                if (range.count == 2) {
                    NSString *rangeString = [NSString stringWithFormat:@"[%@, %@]", range[0], range[1]];
                    [wordRangeArray addObject:[NSValue valueWithRange:NSRangeFromString(rangeString)]];
                }
            }];
            [entityDict setValue:wordRangeArray forKey:kEntityMark];
            self.entityWordInfoDict = entityDict;
        }
        
        // 导流页Header
        if ([dataDict objectForKey:@"wap_headers"]) {
            self.wapHeaders = [dataDict dictionaryValueForKey:@"wap_headers" defalutValue:nil];
        }
        
        if ([dataDict objectForKey:@"h5_extra"]) {
            self.h5Extra = [dataDict dictionaryValueForKey:@"h5_extra" defalutValue:nil];
            if (self.h5Extra[@"is_original"]) {
                self.isOriginal = [self.h5Extra objectForKey:@"is_original"];
            }
        }
        if ([dataDict objectForKey:@"wenda_extra"]) {
            self.wendaExtra = [dataDict tt_dictionaryValueForKey:@"wenda_extra"];
        }
        
        if ([dataDict objectForKey:@"video_detail_info"]) {
            self.videoDetailInfo = [dataDict dictionaryValueForKey:@"video_detail_info"
                                                      defalutValue:nil];
        }
        
        if ([dataDict objectForKey:@"ugc_video_cover"]) {
            self.ugcVideoCover = [dataDict dictionaryValueForKey:@"ugc_video_cover"
                                                    defalutValue:nil];
        }
        
        if ([dataDict objectForKey:@"commoditys"]) {
            self.commoditys = [dataDict arrayValueForKey:@"commoditys" defaultValue:nil];
        }
        
        
        if ([dataDict objectForKey:@"video_play_info"]) {
            //相关视频 直接播放url
            BOOL isVideoFeedURLEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"video_feed_url" defaultValue:@NO freeze:NO] boolValue];
            if (isVideoFeedURLEnabled) {
                NSString *videoid = [dataDict valueForKeyPath:@"video_detail_info.video_id"];
                if (videoid) {
                    NSString *videoPlayInfo = [dataDict valueForKey:@"video_play_info"];
                    if ([videoPlayInfo isKindOfClass:[NSString class]] && videoPlayInfo.length > 0) {
                        NSError *error = nil;
                        NSData *stringData = [videoPlayInfo dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:&error];
                        if (!error) {
                            if ([self respondsToSelector:@selector(videoPlayInfo)]) {
                                NSMutableDictionary *muDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
                                NSString *uid = [TTAccountManager userID];
                                [muDic setValue:(uid?uid:@"0") forKey:@"user_id"];
                                [muDic setValue:videoid forKey:@"video_id"];
                                self.videoPlayInfo = muDic;
                                if (self.videoPlayInfo.count > 0) {
                                    [self settingArticleCreatedTime];
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        
        if ([dataDict objectForKey:@"ad_button"]) {
            self.embededAdInfo = [dataDict dictionaryValueForKey:@"ad_button"
                                                    defalutValue:nil];
        }
        
        if ([dataDict objectForKey:@"novel_data"]) {
            self.novelData = [dataDict dictionaryValueForKey:@"novel_data" defalutValue:nil];
        }
        
        if ([dataDict objectForKey:@"ad_id"]) {
            self.adIDStr = [dataDict stringValueForKey:@"ad_id" defaultValue:nil];
        }
        
        
        if (![dataDict objectForKey:@"requestTime"]) {
            self.requestTime = [[NSDate date] timeIntervalSince1970];
        }
        
        if ([dataDict objectForKey:@"ugc_recommend"]) {
            self.recommendDict = [dataDict dictionaryValueForKey:@"ugc_recommend" defalutValue:nil];
        }
        
        if ([dataDict objectForKey:@"happy_knocking"]) {
            self.happyKnocking = [dataDict dictionaryValueForKey:@"happy_knocking" defalutValue:nil];
        }
        
        if ([dataDict objectForKey:@"title_image"]) {
            NSDictionary *dict = [dataDict dictionaryValueForKey:@"title_image" defalutValue:nil];
            if (dict != nil) {
                if ([dict objectForKey:@"type"]) {
                    self.navTitleType = [dict stringValueForKey:@"type" defaultValue:nil];
                }
                if ([dict objectForKey:@"title_image_url"]) {
                    self.navTitleUrl = [dict stringValueForKey:@"title_image_url" defaultValue:nil];
                }
                if ([dict objectForKey:@"title_image_night_url"]) {
                    self.navTitleNightUrl = [dict stringValueForKey:@"title_image_night_url" defaultValue:nil];
                }
                if ([dict objectForKey:@"title_image_open_url"]) {
                    self.navOpenUrl = [dict stringValueForKey:@"title_image_open_url" defaultValue:nil];
                }
            }
        }
    }
    @catch (NSException *exception)
    {
        if ([[exception name] isEqualToString:NSObjectInaccessibleException])
            return;
    }
}

- (BOOL)isClientEscapeType
{
    if (self.articleType == ArticleTypeWebContent && (([self.groupFlags longLongValue] & kArticleGroupFlagsClientEscape) > 0)) {
        return YES;
    }
    return NO;
}

/**
 *  判断是否需要再调用content接口获取正文
 *
 *  @param forceLoadNative 特别处理导流页/web图集超时导致的loadNative
 */
- (BOOL)isContentFetchedWithForceLoadNative:(BOOL)forceLoadNative
{
    BOOL articleContentFetched = !isEmptyString(self.detail.content);
    //    if ((([self.articleType intValue] == ArticleTypeWebContent) && !isEmptyString(self.articleURLString)) || !isEmptyString(self.content)) {
    //        //文章正文是否已获取到，与文章类型无关
    //        articleContentFetched = YES;
    //    }
    
    if ([self isVideoSubject]) {
        //视频
        //        return !SSIsEmptyDictionary(self.videoDetailInfo);
        return articleContentFetched;// 视频详情页中的摘要需要从content中获取，所以需要content接口
    }
    else if ([self isImageSubject]) {
        if (self.articleType == ArticleTypeWebContent && !forceLoadNative) {
            //web图集
            return articleContentFetched;
        }
        else {
            //本地图集
            return !SSIsEmptyArray(self.galleries);
        }
    }
    else {
        //普通文章
        BOOL hasTitle = !isEmptyString(self.title);
        return articleContentFetched && hasTitle;
    }
}

- (BOOL)isContentFetched
{
    return [self isContentFetchedWithForceLoadNative:NO];
}

- (BOOL)isImageSubject {
    return !!([self.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeImageSubject);
}

- (BOOL)isVideoSubject
{
    return !!([self.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeVideoSubject);
}

- (BOOL)isWenDaSubject{
    return !!([self.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeWenDaSubject);
}

- (BOOL)isGroupGallery {
    return !!([self.groupFlags longLongValue] & ArticleGroupFlagsGallery);
}

- (BOOL)shouldUseCustomUserAgent
{
    // 置1时表示不要修改UA
    if ([self.groupFlags longLongValue] & ArticleGroupFlagsNoCustomUserAgent) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSString *)primaryIDByUniqueID:(int64_t)uniqueID
                           itemID:(NSString *)itemID
                             adID:(NSString *)adID {
    return [NSString stringWithFormat:@"%lld%@%@", uniqueID, itemID ?: @"", adID ?: @""];
}


- (void)digg
{
    self.userDigg = YES;
    self.diggCount = self.diggCount + 1;
}

- (void)bury
{
    self.userBury = YES;
    self.buryCount = self.buryCount + 1;
}

//- (ListViewDisplayType)displayType
//{
//    return _displayType;
//}
//
//- (void)setDisplayType:(ListViewDisplayType)displayType
//{
//    _displayType = displayType;
//}


// without KVO
//- (void)setPrimaryDisplayType:(ListViewDisplayType)displayType
//{
//    _displayType = displayType;
//}

// title和comment改变时，cell高度缓存失效
//- (NSString *)md5Hash {
//    return [[NSString stringWithFormat:@"%@%@", self.title, self.comment] MD5HashString];
//}

//- (NSString*)mdHashForData:(NSDictionary*)data
//{
//    return [NSString stringWithFormat:@"%@%@%@%@", self.title, self.abstract, self.comment, data];
//}
//
//- (NSString*)md5Hash:(BOOL)displayImage
//{
//    return [[NSString stringWithFormat:@"%@%@%@%@%@%d", self.title, self.abstract, self.listGroupImgDicts, self.comment, self.largeImageDict, displayImage] MD5HashString];
//}

//- (void)setTip:(NSNumber *)tip
//{
//    NSNumber * primitiveTip = (NSNumber *)[self primitiveValueForKey:@"tip"];
//    [self setPrimitiveValue:[NSNumber numberWithInt:[primitiveTip intValue] | [tip intValue]] forKey:@"tip"];
//}
//
- (TTImageInfosModel *)listLargeImageModel
{
    if (![self.largeImageDict isKindOfClass:[NSDictionary class]] || [self.largeImageDict count] == 0) {
        return nil;
    }
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:self.largeImageDict];
    model.imageType = TTImageTypeLarge;
    return model;
}

- (TTImageInfosModel *)listMiddleImageModel
{
    if (![self.middleImageDict isKindOfClass:[NSDictionary class]] || [self.middleImageDict count] == 0) {
        return nil;
    }
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:self.middleImageDict];
    model.imageType = TTImageTypeMiddle;
    return model;
}

- (NSArray *)listGroupImgModels
{
    if (![self.listGroupImgDicts isKindOfClass:[NSArray class]] || [self.listGroupImgDicts count] == 0) {
        return nil;
    }
    NSMutableArray * ary = [NSMutableArray arrayWithCapacity:10];
    int index = 0;
    for (NSDictionary * dict in self.listGroupImgDicts) {
        if ([dict isKindOfClass:[NSDictionary class]] && [dict count] > 0) {
            TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:dict];
            model.imageType = TTImageTypeThumb;
            model.userInfo = @{kArticleImgsIndexKey:@(index)};
            index ++;
            if (model) {
                [ary addObject:model];
            }
        }
    }
    return ary;
}

- (NSArray *)detailLargeImageModels
{
    if (isEmptyString(self.imageDetailListString)) {
        return nil;
    }
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:10];
    NSArray *images = [self.imageDetailListString tt_JSONValue];
    int index = 0;
    for(NSDictionary *dict in images)
    {
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        model.imageType = TTImageTypeLarge;
        model.userInfo = @{kArticleImgsIndexKey:@(index)};
        index ++;
        if (model) {
            [result addObject:model];
        }
    }
    return result;
}

- (NSArray *)detailThumbImageModels
{
    if (isEmptyString(self.thumbnailListString)) {
        return nil;
    }
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:10];
    NSArray *images = [self.thumbnailListString tt_JSONValue];
    int index = 0;
    for(NSDictionary *dict in images)
    {
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        model.imageType = TTImageTypeThumb;
        model.userInfo = @{kArticleImgsIndexKey:@(index)};
        index ++;
        if (model) {
            [result addObject:model];
        }
    }
    return result;
}

- (BOOL)isTopic
{
    return [self.groupType intValue] == ArticleGroupTypeTopic;
}

- (TTImageInfosModel *)listSourceIconModel {
    if (![self.sourceIconDict isKindOfClass:[NSDictionary class]] || [self.sourceIconDict count] == 0) {
        return nil;
    }
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:self.sourceIconDict];
    return model;
}

- (TTImageInfosModel *)listSourceIconNightModel {
    if (![self.sourceIconNightDict isKindOfClass:[NSDictionary class]] || [self.sourceIconNightDict count] == 0) {
        return nil;
    }
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:self.sourceIconNightDict];
    return model;
}

- (TTGroupModel *)groupModel {
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:[NSString stringWithFormat:@"%lld", self.uniqueID] itemID:self.itemID impressionID:nil aggrType:[self.aggrType integerValue]];
    return groupModel;
}

- (NSArray *)sourceIconBackgroundColors {
    switch (self.sourceIconStyle.integerValue) {
        case 2:
            return @[@"90ccff", @"48667f"];
        case 3:
            return @[@"cccccc", @"666666"];
        case 4:
            return @[@"bfa1d0", @"5f5068"];
        case 5:
            return @[@"80c184", @"406042"];
        case 6:
            return @[@"e7ad90", @"735648"];
        case 1:
        default:
            return @[@"ff9090", @"7f4848"];
    }
}

- (BOOL)directPlay
{
    return [[self.videoDetailInfo objectForKey:VideoInfoDirectPlayKey] boolValue];
}

- (NSDictionary *)displayComment
{
    NSMutableDictionary *comment = nil;
    
    if (self.zzComments.count > 0) {
        if ([self.zzComments[0] isKindOfClass:[NSDictionary class]]) {
            comment = [NSMutableDictionary dictionaryWithDictionary:self.zzComments[0]];
            [comment setValue:@(YES) forKey:@"isZZ"];
        }
    }
    else {
        if ([self.comment isKindOfClass:[NSDictionary class]]) {
            comment = [NSMutableDictionary dictionaryWithDictionary:self.comment];
            [comment setValue:@(NO) forKey:@"isZZ"];
        }
    }
    return comment;
}

- (nullable NSString *)zzCommentsIDString
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

- (nullable NSString *)firstZzCommentMediaId {
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

- (BOOL)shouldDirectShowVideoSubject
{
    ArticleRelatedVideoType cardType = [self.relatedVideoExtraInfo unsignedIntegerValueForKey:kArticleInfoRelatedVideoCardTypeKey defaultValue:ArticleRelatedVideoTypeUnknown];
    if (!(cardType == ArticleRelatedVideoTypeAlbum || cardType == ArticleRelatedVideoTypeSubject)) {
        return NO;
    }
    if ([[self.relatedVideoExtraInfo allKeys] containsObject:kArticleInfoRelatedVideoAutoLoadKey]) {
        return [self.relatedVideoExtraInfo[kArticleInfoRelatedVideoAutoLoadKey] boolValue];
    }
    return NO;
}

- (BOOL)hasVideoBookID
{
    return [[self.videoDetailInfo allKeys] containsObject:VideoInfoBookIDKey];
}

- (BOOL)hasVideoID
{
    return [[self.videoDetailInfo allKeys] containsObject:VideoInfoIDKey];
}

- (BOOL)hasVideoSubjectID
{
    return [[self.videoDetailInfo allKeys] containsObject:kArticleInfoRelatedVideoSubjectIDKey];
}

- (NSString *)videoSubjectID
{
    if ([self hasVideoSubjectID]) {
        id subjectID = [self.videoDetailInfo valueForKey:kArticleInfoRelatedVideoSubjectIDKey];
        if ([subjectID isKindOfClass:[NSNumber class]]) {
            NSString *str = [subjectID stringValue];
            if (!isEmptyString(str)) {
                return str;
            }
        } else if ([subjectID isKindOfClass:[NSString class]] && !isEmptyString(((NSString *)subjectID))) {
            return subjectID;
        }
    }
    return nil;
}

- (BOOL)isPreloadVideoEnabled
{
    BOOL isPreload = [self.videoDetailInfo tt_boolValueForKey:kArticlePreloadVideoFlagKey];
#if DEBUG
    isPreload = [[NSUserDefaults standardUserDefaults] boolForKey:@"__TTEnableVideoCacheDebug"];
#endif
    return isPreload;
}

- (NSString *)waterMarkURLString
{
    NSString *url = [self.videoDetailInfo tt_stringValueForKey:@"cover_image_watermark"];
    //#if DEBUG
    //    NSArray *names = @[@"视", @"曲", @"乐"];
    //    [names enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //        if ([self.mediaName rangeOfString:obj].location != NSNotFound) {
    //            url = @"http://www.crainsnewyork.com/assets/40s/2016/40-under-40_2016_Small.png";
    //            *stop = YES;
    //        }
    //    }];
    //#endif
    return url;
}

- (NSUInteger)relatedVideoType
{
    ArticleRelatedVideoType type = [self.relatedVideoExtraInfo unsignedIntegerValueForKey:kArticleInfoRelatedVideoCardTypeKey defaultValue:ArticleRelatedVideoTypeUnknown];
    return type;
}

- (NSString *)relatedLogExtra
{
    NSString *logExtr = [self.relatedVideoExtraInfo tt_stringValueForKey:kArticleInfoRelatedVideoLogExtraKey];
    return logExtr;
}

- (NSNumber *)relatedAdId
{
    NSNumber *ad_id = nil;
    if ([self.relatedVideoExtraInfo valueForKey:kArticleInfoRelatedVideoAdIDKey]) {
        ad_id = self.relatedVideoExtraInfo[kArticleInfoRelatedVideoAdIDKey];
        if (![ad_id isKindOfClass:[NSNumber class]]) {
            ad_id = nil;
        }
    }
    return ad_id;
}

//过了一个小时,VideoUrl就失效
- (BOOL)isVideoUrlValid
{
    BOOL isValid = NO;
    if (self.createdTime) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.createdTime];
        isValid = interval - 60 * 40 < 0;
    }
    if (!isValid) {
        self.videoPlayInfo = nil;
    }
    return isValid;
}

- (void)settingArticleCreatedTime
{
    if (!self.createdTime) {
        self.createdTime = [NSDate date];
    }
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

- (BOOL)isVideoSourceUGCVideoOrHuoShan
{
    return [self isVideoSourceUGCVideo] || [self isVideoSourceHuoShan];
}

- (BOOL)isVideoSourceUGCVideo
{
    if (!isEmptyString(self.videoSource)) {
        if ([self.videoSource isEqualToString:@"ugc_video"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isVideoSourceHuoShan
{
    if (!isEmptyString(self.videoSource)) {
        if ([self.videoSource isEqualToString:@"huoshan"]){
            return YES;
        }
    }
    return NO;
}
//C1:发布了文章 C2:回答了问题 C6:赞了文章
//wiki https://wiki.bytedance.net/pages/viewpage.action?pageId=67307942
//u11 C2回答了问题user_info
- (nullable NSDictionary *)userInfoForAction
{
    NSDictionary *userInfoForAction = nil;
    if ([self.userRelation tt_dictionaryValueForKey:@"user_info"]) {
        userInfoForAction = [self.userRelation tt_dictionaryValueForKey:@"user_info"];
    }
    else {
        userInfoForAction = self.userInfo;
    }
    return userInfoForAction;
}
//u11头像
- (nullable NSString *)userImgaeURL
{
    NSString *userImgaeURL = nil;
    if ([self.userInfoForAction count] > 0) {
        userImgaeURL = [self.userInfoForAction tt_stringValueForKey:@"avatar_url"];
    }//留着保底 以后会删掉
    else if ([self.mediaInfo objectForKey:@"avatar_url"]){
        userImgaeURL = [self.mediaInfo tt_stringValueForKey:@"avatar_url"];
    }
    return userImgaeURL;
}

//u11用户名
- (nullable NSString *)userName
{
    NSString *userName = nil;
    if ([self.userInfoForAction count] > 0){
        userName = [self.userInfoForAction tt_stringValueForKey:@"name"];
    }//留着保底 以后会删掉
    else if ([self.mediaInfo objectForKey:@"name"]) {
        userName = [self.mediaInfo tt_stringValueForKey:@"name"];
    }
    return userName;
}

//u11认证信息
//- (nullable NSString *)userVerifiedContent
//{
//    NSString *userVerifiedContent = nil;
//    if ([self.userInfoForAction count] > 0){
//        userVerifiedContent = [self.userInfoForAction tt_stringValueForKey:@"verified_content"];
//    }//留着保底 以后会删掉
//    else if ([self.mediaInfo objectForKey:@"verified_content"]) {
//        userVerifiedContent = [self.mediaInfo tt_stringValueForKey:@"verified_content"];
//    }
//    return userVerifiedContent;
//}

//u11认证展现信息
- (NSString *)userAuthInfo
{
    NSString *userAuthInfo = nil;
    if ([self.userInfoForAction count] > 0) {
        userAuthInfo = [self.userInfoForAction tt_stringValueForKey:@"user_auth_info"];
    }//留着保底 以后会删掉
    else if ([self.mediaInfo objectForKey:@"user_auth_info"]) {
        userAuthInfo = [self.mediaInfo tt_stringValueForKey:@"user_auth_info"];
    }
    return userAuthInfo;
}

- (NSString *)userDecoration {
    return [self.userInfoForAction tt_stringValueForKey:@"user_decoration"];
}

- (nullable NSString *)userIDForAction
{
    NSString *userIDForAction = nil;
    if ([self.userInfoForAction count] > 0){
        userIDForAction = [self.userInfoForAction tt_stringValueForKey:@"user_id"];
    }//留着保底 以后会删掉
    else if ([self.mediaInfo objectForKey:@"media_id"]) {
        userIDForAction = [self.mediaInfo tt_stringValueForKey:@"media_id"];
    }
    return userIDForAction;
}

- (nullable NSString *)recommendReasonForActivity
{
    NSString *recommendReasonForAction = nil;
    if (!isEmptyString([self.recommendDict tt_stringValueForKey:@"activity"])) {
        recommendReasonForAction = [self.recommendDict tt_stringValueForKey:@"activity"];
    } else if ([self.userRelation objectForKey:@"recommend_reason"]){
        recommendReasonForAction = [self.userRelation tt_stringValueForKey:@"recommend_reason"];
    }//留着保底 以后会删掉
    else {
        recommendReasonForAction = [self.recommendReason copy];
    }
    return recommendReasonForAction;
}

- (nullable NSString *)recommendReasonSecondLine {
    return [self.recommendDict tt_stringValueForKey:@"reason"];
}

- (BOOL)isFollowed
{
    BOOL isFollowed = NO;
    if ([[self userRelation] count] > 0) {
        isFollowed = [[self userRelation] tt_boolValueForKey:@"is_subscribe"];
    }
    else if([[self userInfo] objectForKey:@"follow"]){
        isFollowed = [[self userInfo] tt_boolValueForKey:@"follow"];
    }//留着保底 以后会删掉
    else if ([[self mediaInfo] objectForKey:@"follow"]){
        isFollowed = [[self mediaInfo] tt_boolValueForKey:@"follow"];
    }
    else{
        isFollowed = [[self isSubscribe] boolValue];
    }
    return isFollowed;
}

- (BOOL)userIsFollowed
{
    BOOL userIsFollowed = NO;
    if ([[self userRelation] count] > 0) {
        userIsFollowed = [[self userRelation] tt_boolValueForKey:@"is_followed"];
    }
    else if ([[self userInfo] objectForKey:@"is_followed"]) {
        userIsFollowed = [[self userInfo] tt_boolValueForKey:@"is_followed"];
    }
    return userIsFollowed;
}

- (void)updateFollowed:(BOOL)followed
{
    if ([[self userRelation] count] > 0) {
        [self willChangeValueForKey:@"isFollowed"];
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:self.userRelation];
        [mutDict setValue:@(followed) forKey:@"is_subscribe"];
        self.userRelation = [mutDict copy];
        [self didChangeValueForKey:@"isFollowed"];
    }
    else if([[self userInfo] objectForKey:@"follow"]){
        [self willChangeValueForKey:@"isFollowed"];
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
        BOOL preFollowed = [mutDict tt_boolValueForKey:@"follow"];
        if (preFollowed != followed){
            long long fansCount = [mutDict tt_longlongValueForKey:@"fans_count"];
            if (followed){
                fansCount += 1;
            }else{
                fansCount -= 1;
            }
            [mutDict setValue:@(fansCount) forKey:@"fans_count"];
        }
        [mutDict setValue:@(followed) forKey:@"follow"];
        self.userInfo = [mutDict copy];
        [self didChangeValueForKey:@"isFollowed"];
    }//留着保底 以后会删掉
    else if ([[self mediaInfo] objectForKey:@"follow"]){
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:self.mediaInfo];
        [mutDict setValue:@(followed) forKey:@"follow"];
        self.mediaInfo = [mutDict copy];
    }
    else {
        self.isSubscribe = @(followed);
    }
    [self save];
}

- (id<FRActionDataProtocol>)actionDataModel {
    if (_actionDataModel == nil) {
        _actionDataModel = [GET_SERVICE(FRActionDataService) modelWithUniqueID:[NSString stringWithFormat:@"%lld", self.uniqueID]
                                                                          type:FRActionDataModelTypeArticle];
    }
    return _actionDataModel;
}


- (int)commentCount {
    return (int)self.actionDataModel.commentCount;
}

- (void)setCommentCount:(int)commentCount {
    self.actionDataModel.commentCount = commentCount;
}

- (int)diggCount {
    return (int)self.actionDataModel.diggCount;
}

- (void)setDiggCount:(int)diggCount {
    self.actionDataModel.diggCount = diggCount;
}

- (long long)readCount {
    return self.actionDataModel.readCount;
}

- (void)setReadCount:(long long)readCount {
    self.actionDataModel.readCount = readCount;
}

- (NSNumber *)likeCount {
    return @(self.actionDataModel.articleLikeCount);
}

- (void)setLikeCount:(NSNumber *)likeCount
{
    self.actionDataModel.articleLikeCount = likeCount.longValue;
}

- (NSNumber *)articleDeleted {
    return @(self.actionDataModel.hasDelete);
}

- (void)setArticleDeleted:(NSNumber *)articleDeleted {
    self.actionDataModel.hasDelete = articleDeleted.boolValue;
}

- (BOOL)userDigg {
    return self.actionDataModel.hasDigg;
}

- (void)setUserDigg:(BOOL)userDigg {
    self.actionDataModel.hasDigg = userDigg;
}

- (NSNumber *)hasRead {
    return @(self.actionDataModel.hasRead);
}

- (void)setHasRead:(NSNumber *)hasRead {
    self.actionDataModel.hasRead = hasRead.boolValue;
}

- (NSNumber *)userLike {
    return @(self.actionDataModel.articleHasLike);
}

- (void)setUserLike:(NSNumber *)userLike
{
    self.actionDataModel.articleHasLike = userLike.boolValue;
}

#pragma make - Notification

- (void)addObserveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:@"RelationActionSuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockNotification:) name:@"kHasBlockedUnblockedUserNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editUserInfoDidFinish:) name:@"kTTEditUserInfoDidFinishNotificationName" object:nil];
}

- (void)removeObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)followNotification:(NSNotification *)notify
{
    NSString * userID = notify.userInfo[@"kRelationActionSuccessNotificationUserIDKey"];
    if (!isEmptyString(userID) && [userID isEqualToString:self.userIDForAction]) {
        NSInteger actionType = [(NSNumber *)notify.userInfo[@"kRelationActionSuccessNotificationActionTypeKey"] integerValue];
        if (actionType == FriendActionTypeFollow) {
            [self updateFollowed:YES];
        }else if (actionType == FriendActionTypeUnfollow) {
            [self updateFollowed:NO];
        }
        [self save];
    }
}

- (void)blockNotification:(NSNotification *)notify
{
    NSString * userID = notify.userInfo[kBlockedUnblockedUserIDKey];
    if (!isEmptyString(userID) && [userID isEqualToString:self.userIDForAction]) {
        BOOL isBlocking = [notify.userInfo[kIsBlockingKey] boolValue];
        if (isBlocking) {
            [self updateFollowed:NO];
        }
        [self save];
    }
}

- (void)editUserInfoDidFinish:(NSNotification *)notification {
    if ([[self userIDForAction] isEqualToString:[TTAccountManager userID]]) {
        NSString * screenName = [self userName];
        if (![screenName isEqualToString:[TTAccountManager userName]]) {
            if (self.userInfo) {
                NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
                [userInfo setValue:[TTAccountManager userName] forKey:@"name"];
                self.userInfo = userInfo.copy;
                [self save];
            }
        }
        
        NSString * avatarUrl = [self userImgaeURL];
        if (![avatarUrl isEqualToString:[TTAccountManager avatarURLString]]) {
            if (self.userInfo) {
                NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
                [userInfo setValue:[TTAccountManager avatarURLString] forKey:@"avatar_url"];
                self.userInfo = userInfo.copy;
                [self save];
            }
        }
    }
}

- (NSString *)articleURLString {
    NSString *articleURLString = _articleURLString;
    if (!isEmptyString(articleURLString) && !isEmptyString(self.adIDStr) && self.logExtra != nil) {
        articleURLString = [articleURLString tt_adChangeUrlWithLogExtra:self.logExtra];
    }
    return articleURLString;
}

- (NSString *)videoThirdMonitorUrl
{
    return [self.videoDetailInfo valueForKey:@"video_third_monitor_url"];
}

- (ArticleDetail *)detail {
    if (!_detail && self.primaryID) {
        _detail = [ArticleDetail objectForPrimaryKey:self.primaryID];
    }
    return _detail;
}

- (TTAdFeedDataDisplayType)articlePictureDidsplayType{
    
    TTAdFeedDataDisplayType picType = -1;
    
    if (self.picDisplayType) {
        
        if (self.picDisplayType.longValue == 1) {
            picType = TTAdFeedDataDisplayTypeeSmall;
        }
        else if (self.picDisplayType.longValue == 2)
        {
            picType = TTAdFeedDataDisplayTypeLarge;
        }
        
        else if (self.picDisplayType.longValue == 3){
            picType = TTAdFeedDataDisplayTypeGroup;
        }
        else if (self.picDisplayType.longValue == 4){
            picType = TTAdFeedDataDisplayTypeeRight;
        }
        else if (self.picDisplayType.longValue == 5){
            picType = TTAdFeedDataDisplayTypeLoop;
        }
    }
    
    return picType;
    
}

- (void)save {
    [super save];
    if (!isEmptyString(_detail.primaryID)) {
        [_detail save];
    }
}

+ (void)removeAllEntities {
    [super removeAllEntities];
    [ArticleDetail removeAllEntities];
}

@end


//
//  TTVVideoDetailAlbumVIewModel.m
//  Article
//
//  Created by lishuangyang on 2017/6/19.
//
//

#import "TTVVideoDetailAlbumViewModel.h"
#import <TTNetworkManager.h>
#import "CommonURLSetting.h"

//#import "Article.h"
#import <TTVideoService/VideoFeed.pbobjc.h>
#import <TTVideoService/Common.pbobjc.h>
#import "TTVFeedItem+Extension.h"
#import "TTVRelatedItem+TTVArticleProtocolSupport.h"

#import "GYDataContext.h"
#import "GYReflection.h"
#import <objc/runtime.h>
#import "GYDCUtilities.h"
#import "NSDictionary+TTEntityAdditions.h"
#define kArticleInfoRelatedVideoIDKey @"video_id"

@interface TTVVideoDetailAlbumViewModel ()

@end

@implementation TTVVideoDetailAlbumViewModel

- (void)setItem:(TTVRelatedItem *)item
{
    if (_item != item) {
        _item = item;
        self.reloadFlag = YES;
    
        NSString *leftTitle = @"合辑";
        NSString *logoText = item.relatedVideoExtraInfo[kArticleInfoRelatedVideoTagKey];
        if (!isEmptyString(logoText)) {
            leftTitle = logoText;
        }
        self.albumName = [leftTitle stringByAppendingFormat:@"：%@" ,item.title];
        self.albumItems = nil;
    }
}


- (void)fetchAlbumsWithURL:(NSString *)url completion:(TTAlbumFetchCompletion)completion
{
    NSString *requestURL = [NSString stringWithFormat:@"%@%@", [CommonURLSetting baseURL], url];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:requestURL params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        self.reloadFlag = NO;
        if (!error) {
            NSArray *albums = [jsonObj valueForKey:@"data"];
            if ([albums isKindOfClass:[NSArray class]]) {
                NSArray *albumArticles = [self albumArticlesWithArr:albums];
                if(albumArticles.count > 0){
                    self.albumItems = albumArticles;
                    completion(albumArticles, error);

                }
            }
        } else {
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (NSArray *)albumArticlesWithArr:(NSArray *)arr
{
    
    NSMutableArray *albumArticles = [NSMutableArray arrayWithCapacity:arr.count];
    for (NSDictionary * dict in arr) {
        
        if ([[dict allKeys] containsObject:@"log_pb"]) {
            self.logPb = [dict valueForKey:@"log_pb"];
        }
        NSMutableDictionary * mutDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        id groupID = dict[@"group_id"];
        if (groupID) {
            groupID = [NSString stringWithFormat:@"%@", groupID];
        }
        NSNumber * gID = [NSNumber numberWithLongLong:[groupID longLongValue]];
        if ([gID longLongValue] == 0) {
            continue;
        }
        [mutDict setValue:gID forKey:@"uniqueID"];
        id itemID = dict[@"item_id"];
        if (itemID) {
            [mutDict setValue:[NSString stringWithFormat:@"%@", itemID] forKey:@"item_id"];
            [mutDict setValue:[NSString stringWithFormat:@"%@", itemID] forKey:@"itemID"];
        }
        
        if (![[dict allKeys] containsObject:@"video_detail_info"]) {
            mutDict[@"video_detail_info"] = @{@"" : @""};
        }
        
        NSMutableDictionary * containerDict = [NSMutableDictionary dictionaryWithCapacity:10];
        
        Article *tArticle = [Article objectWithDictionary:mutDict];
        [tArticle save];
        NSError *error = nil;
        TTVVideoDetailAlbumModel *test = [[TTVVideoDetailAlbumModel alloc] initWithDictionary:mutDict error:&error];
        
        if (tArticle != nil) {
            
            [containerDict setValue:tArticle forKey:@"article"];
            [containerDict setValue:test forKey:@"protoedArticle"];
        }
        

        if ([containerDict count] > 0) {
            [albumArticles addObject:containerDict];
        }
    }
    
    if ([albumArticles count] > 0) {
        return albumArticles;
    }
    return nil;
}

@end

@implementation TTVVideoDetailAlbumModel

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err{
    
    self = [super initWithDictionary:dict error:err];
    if (self) {
        return self;
    }
    
    return nil;
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                       @"diggCount":@"digg_count",
                                                       @"groupFlags":@"group_flags",
                                                       @"hasRead":@"has_read",
                                                       @"uniqueID":@"uniqueID",
                                                       @"itemID":@"itemID",
                                                       @"likeCount":@"like_count",
                                                       @"likeDesc":@"like_desc",
                                                       @"notInterested":@"not_interested",
                                                       @"repinCount":@"repin_count",
                                                       @"shareURL":@"share_url",
                                                       @"userBury":@"user_bury",
                                                       @"userDigg":@"user_digg",
                                                       @"userLike":@"user_like",
                                                       @"userRepined":@"user_repin",
                                                       @"userRepinTime":@"user_repin_time",
                                                       @"embededAdInfo":@"ad_button",
                                                       @"adPromoter":@"ad_data",
                                                       @"aggrType":@"aggr_type",
                                                       @"articlePosition":@"article_position",
                                                       @"articleURLString":@"article_url",
                                                       @"banComment":@"ban_comment",
                                                       @"buryCount":@"bury_count",
                                                       @"cacheToken":@"cache_token",
                                                       @"commentCount":@"comment_count",
                                                       @"middleImageDict":@"middle_image",
                                                       @"videoDetailInfo":@"video_detail_info",
                                                       
                                                       @"articleDeleted":@"delete",
                                                       @"detailNoComments":@"detail_no_comments",
                                                       @"displayTitle":@"display_title",
                                                       @"displayURL":@"display_url",
                                                       @"gallaryFlag":@"gallary_flag",
                                                       @"gallaryImageCount":@"gallary_image_count",
                                                       @"galleries":@"gallery",
                                                       @"goDetailCount":@"go_detail_count",
                                                       @"groupType":@"group_type",
                                                       @"hasImage":@"has_image",
                                                       @"hasVideo":@"has_video",
                                                       @"ignoreWebTranform":@"ignore_web_transform",
                                                       @"infoDesc":@"info_desc",
                                                       @"isOriginal":@"is_original",
                                                       @"isSubscribe":@"is_subscribe",
                                                       @"logExtra":@"log_extra",
                                                       @"mediaName":@"media_name",
                                                       @"natantLevel":@"natant_level",
                                                       @"novelData":@"novel_data",
                                                       @"openURL":@"open_url",
                                                       @"articlePublishTime":@"publish_time",
                                                       @"recommendReason":@"recommend_reason",
                                                       @"schema":@"schema",
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
                                                       @"userRelation":@"user_relation",
                                                       @"videoDuration":@"video_duration",
                                                       @"videoID":@"video_id",
                                                       @"videoLocalURL":@"ffvideo_local_url",
                                                       @"videoProportion":@"video_proportion",
                                                       @"detailVideoProportion":@"video_proportion_article",
                                                       @"videoSource":@"video_source",
                                                       @"share_count":@"share_count",
                                                       @"showOrigin":@"show_origin",
                                                       @"showTips":@"show_tips",
                                                       @"banBury":@"ban_bury",
                                                       @"banDigg":@"ban_digg",
                                                       @"forwardInfo" : @"forward_info"
                                                       }];
}

- (NSDictionary *)largeImageDict
{
    return [_middleImageDict copy];
}

- (NSString *)mediaUserID
{
    return _mediaName;
}

- (NSString *)firstZzCommentMediaId
{
    return nil;
}

- (NSString *)articleDetailContent
{
    return nil;
}

- (NSString *)articleURLString
{
    return nil;
}

- (BOOL)isVideoSourceUGCVideo
{
    return YES;
}

- (BOOL)isVideoSourceHuoShan
{
    return NO;
}

- (BOOL)isVideoSourceUGCVideoOrHuoShan
{
    return [self isVideoSourceUGCVideo] || [self isVideoSourceHuoShan];
}

- (NSString *)zzCommentsIDString
{
    return nil;
}

- (NSString *)videoSubjectID
{
    if ([self hasVideoSubjectID]) {
        id subjectID = [self.videoDetailInfo valueForKey:kArticleInfoRelatedVideoIDKey];
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

- (BOOL)shouldDirectShowVideoSubject
{
    return NO;
}

- (BOOL)directPlay
{
    return [[self.videoDetailInfo objectForKey:VideoInfoDirectPlayKey] boolValue];
}

- (NSString *)relatedLogExtra
{
    return nil;
}

- (BOOL)hasVideoSubjectID
{
    return YES;
}

- (BOOL)hasVideoPlayInfoUrl
{
    return YES;
}

- (BOOL)isVideoUrlValid
{
    return YES;
}

- (NSString *)videoIDOfVideoDetailInfo
{
    return nil;
}

- (BOOL)showExtendLink
{
    return NO;
}

- (BOOL)isContentFetchedWithForceLoadNative:(BOOL)forceLoadNative
{
    return NO;
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
    return;
}

- (TTGroupModel *)groupModel{
    return [[TTGroupModel alloc] initWithGroupID:[NSString stringWithFormat:@"%lld",self.uniqueID] itemID:self.itemID impressionID:nil aggrType:self.aggrType];
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
    return article;
}

- (NSDictionary *)rawAdData {
    return nil;
}

@end

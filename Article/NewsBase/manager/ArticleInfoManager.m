//
//  ArticleInfoManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-6.
//
//

#import "ArticleInfoManager.h"
#import "TTInstallIDManager.h"
#import "ArticleURLSetting.h"
#import "FriendModel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleCategoryManager.h"
#import "NetworkUtilities.h"
#import "NewsUserSettingManager.h"
#import "NSDictionary+TTAdditions.h"
#import "TTGroupModel.h"
#import "TTNetworkManager.h"
#import "TTTagItem.h"

#import "TTRoute.h"
#import "TTAdVideoRelateAdModel.h"
#import "TTDetailModel.h"
#import <TTImage/TTWebImageManager.h>
#import <JSONModel/JSONModel.h>
#import "TTAdPromotionManager.h"
#import "TTPhotoSearchWordModel.h"
#import "TTUserSettings/TTUserSettingsManager+NetworkTraffic.h"
#import "TTLocationManager.h"
#import "FRApiModel.h"

#define GENERATE_SETTER_GETTER(PROPERTY, TYPE, SETTER) \
\
- (void)SETTER:(TYPE)PROPERTY { \
self.infoModel.PROPERTY = PROPERTY;\
}\
\
- (TYPE)PROPERTY {\
return self.infoModel.PROPERTY;\
}

@protocol NSDictionary;

@interface _ArticleInfoManagerModel : JSONModel

@property (nonatomic, copy) NSString *webViewTrackKey;
@property (nonatomic, copy) NSString *insertedJavaScript;
@property (nonatomic, copy) NSString *insertedContextJS;

#pragma mark - Article
@property (nonatomic, strong) NSNumber  *articlePosition;
@property (nonatomic, strong) NSDictionary *corperationVideoDict;
@property (nonatomic, assign) ArticleLikeAndShareFlags likeAndShareFlag;
@property (nonatomic, strong) NSArray<NSDictionary> *dislikeWords;

#pragma mark - Video
@property (nonatomic, strong) NSArray *relateVideoArticles; //todo 手动解析
@property (nonatomic, strong) NSDictionary *videoBanner;
@property (nonatomic, copy) NSString *videoAbstract;
@property (nonatomic, strong) NSDictionary *videoExtendLink; //todo 手动解析
@property(nonatomic, retain, readwrite)NSMutableDictionary *video_detail_tags;

#pragma mark - Photo
@property (nonatomic, strong) NSArray *relateImagesArticles; //todo 手动解析
@property (nonatomic, strong) NSArray *webRecommandPhotosArray;
@property (nonatomic, strong) NSArray *relateSearchWordsArray;//todo 手动解析

#pragma mark - AD
@property (nonatomic, copy) NSString<Optional> *videoAdUrl;
@property (nonatomic, strong) NSDictionary *detailADJsonDict;
@property (nonatomic, strong) NSDictionary *videoEmbededAdInfo;
@property (nonatomic, strong) NSDictionary *adShareInfo; //todo 解析后 需要直接使用
@property (nonatomic, strong) NSDictionary *adminDebugInfo;
@property (nonatomic, strong) TTActivityModel *promotionModel;

#pragma mark - Natant
@property (nonatomic, strong) NSNumber *relateVideoSection;
@property (nonatomic, strong) NSDictionary *relateEnterJson;
@property (nonatomic, copy) NSString *riskWarningTip;  //todo 解析后 需要直接使用
@property (nonatomic, strong) NSMutableDictionary *ordered_info; //todo 手动解析
@property (nonatomic, strong) NSMutableArray<Ignore> *classNameList; //todo 根据ordered_info生成

@property (nonatomic, strong) NSDictionary *logPb;
#pragma mark - Deprecated
@property (nonatomic, strong) NSString *pgcActionEnterTitleStr;
@property (nonatomic, strong) NSArray *wendaArray;
@property (nonatomic, strong) NSNumber *flags;
@property (nonatomic, strong) NSArray *keywordJsons;
@property (nonatomic, strong) NSDictionary *forumLinkJson;

#pragma mark - Activity
@property (nonatomic, strong) FRActivityStructModel * activity;

#pragma mark - GuideAmount
@property (nonatomic, copy) NSString<Optional> * ug_install_aid;


@end

@implementation _ArticleInfoManagerModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *keyMapperDic = @{@"webview_track_key": @"webViewTrackKey",
                                   @"script": @"insertedJavaScript",
                                   @"context": @"insertedContextJS",
                                   @"article_position": @"articlePosition",
                                   @"related_video": @"corperationVideoDict",
                                   @"info_flag": @"likeAndShareFlag",
                                   @"partner_video": @"videoBanner",
                                   @"video_label_html": @"videoAbstract",
                                   @"video_extend_link": @"videoExtendLink",
                                   @"related_gallery": @"webRecommandPhotosArray",
                                   @"landing_page_url": @"videoAdUrl",
                                   @"ad": @"detailADJsonDict",
                                   @"ad_video_info": @"videoEmbededAdInfo",
                                   @"ad_info": @"adShareInfo",
                                   @"recommend_sponsor" : @"promotionModel",
                                   @"admin_debug": @"adminDebugInfo",
                                   @"related_video_section": @"relateVideoSection",
                                   @"link": @"relateEnterJson",
                                   @"alert_text": @"riskWarningTip",
                                   @"action_desc": @"pgcActionEnterTitleStr",
                                   @"related_wenda": @"wendaArray",
                                   @"forum_link": @"forumLinkJson",
                                   @"video_detail_tags": @"video_detail_tags",
                                   @"label_list": @"keywordJsons",
                                   @"filter_words": @"dislikeWords",
                                   @"activity": @"activity",
                                   @"log_pb": @"logPb"};
    return [[JSONKeyMapper alloc] initWithDictionary:keyMapperDic];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@interface ArticleInfoManager()
@property (nonatomic, strong) TTGroupModel *groupModel;
@property (nonatomic, strong) _ArticleInfoManagerModel *infoModel;
@end

@implementation ArticleInfoManager

- (void)dealloc
{
    [self cancelAllRequest];
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)cancelAllRequest
{
}

- (void)startFetchArticleInfo:(NSDictionary *)condition
                  finishBlock:(TTArticleDetailFetchInformationBlock)finishBlock
{
    if (![condition objectForKey:kArticleInfoManagerConditionGroupModelKey]) {
        SSLog(@"If want fetch article info,must set kArticleInfoManagerConditionGroupModelKey key");
        return;
    }
    
    _groupModel = condition[kArticleInfoManagerConditionGroupModelKey];
    NSUInteger flagCondition = [[condition objectForKey:kArticleInfoManagerConditionFlagKey] intValue];
    
    NSMutableDictionary * getParam = [NSMutableDictionary dictionaryWithCapacity:10];
    [getParam setValue:_groupModel.groupID forKey:@"group_id"];
    [getParam setValue:_groupModel.itemID forKey:@"item_id"];
    [getParam setValue:@(_groupModel.aggrType) forKey:@"aggr_type"];
    if ([condition.allKeys containsObject:@"flags"]) {
        [getParam setValue:condition[@"flags"] forKey:@"flags"];
    }
    
    if ([[condition allKeys] containsObject:kArticleInfoManagerConditionTopCommentIDKey]) {
        [getParam setValue:[condition objectForKey:kArticleInfoManagerConditionTopCommentIDKey] forKey:@"top_comment_id"];
    }
    
    if ([[condition allKeys] containsObject:@"zzids"]) {
        [getParam setValue:[condition objectForKey:@"zzids"] forKey:@"zzids"];
    }
    
    if ([[condition allKeys] containsObject:@"ad_id"]) {
        [getParam setValue:[condition objectForKey:@"ad_id"] forKey:@"ad_id"];
    }
    if ([[condition allKeys]containsObject:@"log_extra"]) {
        [getParam setValue:[condition objectForKey:@"log_extra"] forKey:@"log_extra"];
    }
    if ([[condition allKeys] containsObject:@"article_page"]) {
        [getParam setValue:[condition objectForKey:@"article_page"] forKey:@"article_page"];
    }
    
    if ([[condition allKeys] containsObject:@"video_scene"]) {
        [getParam setValue:[condition objectForKey:@"video_scene"] forKey:@"video_scene"];
    }
    
    if (flagCondition > 0) {
        [getParam setValue:[NSString stringWithFormat:@"%li", (long)flagCondition] forKey:@"flag"];
    }
    
    if ([[condition allKeys] containsObject:kArticleInfoManagerConditionCategoryIDKey]) {
        NSString * categoryID = [condition objectForKey:kArticleInfoManagerConditionCategoryIDKey];
        if ([categoryID isEqualToString:kTTMainCategoryID]) {
            [getParam setValue:kMainCategoryAPINameKey forKey:@"from_category"];
        }
        else {
            [getParam setValue:categoryID forKey:@"from_category"];
        }
    }
    
    NSString *from = [condition valueForKey:@"from"];
    if (!isEmptyString(from)) {
        [getParam setValue:from forKey:@"from"];
    }
    
    [getParam setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    
    TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItem;
    if(placemarkItem.coordinate.longitude > 0) {
        [getParam setValue:@(placemarkItem.coordinate.latitude) forKey:@"latitude"];
        [getParam setValue:@(placemarkItem.coordinate.longitude) forKey:@"longitude"];
    }
    
    NSString *video_subject_id = [condition valueForKey:kArticleInfoRelatedVideoSubjectIDKey];
    if (!isEmptyString(video_subject_id)) {
        [getParam setValue:video_subject_id forKey:kArticleInfoRelatedVideoSubjectIDKey];
    }
    NSString *baseUrl = [ArticleURLSetting newArticleInfoString];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:baseUrl params:getParam method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (error) {
            if (_delegate && [_delegate respondsToSelector:@selector(articleInfoManagerFetchInfoFailed:)]) {
                [_delegate articleInfoManagerFetchInfoFailed:self];
            }
            if (finishBlock) {
                finishBlock(self, error);
            }
        }
        else {
            [self parseResponseObj:jsonObj error:error finishBlock:finishBlock];
        }
    }];
}

-(void)parseResponseObj:(NSDictionary *)jsonObj error:(NSError *)error finishBlock:(TTArticleDetailFetchInformationBlock)finishBlock{
    @try {
        NSMutableDictionary *data = [[jsonObj objectForKey:@"data"] mutableCopy];
        self.infoModel = [[_ArticleInfoManagerModel alloc] initWithDictionary:data error:nil];
        self.ug_install_aid = self.infoModel.ug_install_aid;
        if (!isEmptyString(self.insertedContextJS) &&
            _delegate && [_delegate respondsToSelector:@selector(articleInfoManager:fetchedJSContext:)]) {
            [_delegate articleInfoManager:self fetchedJSContext:self.insertedContextJS];
        }
        
        self.flags = @([data intValueForKey:@"flags" defaultValue:0]);
        
        //get stats
        if (_delegate && [_delegate respondsToSelector:@selector(articleInfoManager:getStatus:)]) {
            [_delegate articleInfoManager:self getStatus:data];
        }
        
        if (!isEmptyString(self.insertedJavaScript) &&
            _delegate && [_delegate respondsToSelector:@selector(articleInfoManager:scriptString:)])
        {
            [_delegate articleInfoManager:self scriptString:self.insertedJavaScript];
        }
        
        //ordered_info
        NSArray * orderedInfo = [data arrayValueForKey:@"ordered_info" defaultValue:nil];
        if (orderedInfo.count>0) {
            [self relatedOrderInfoWithArr:orderedInfo];
        }
        
        if (!isEmptyString(self.riskWarningTip)) {
            [self.ordered_info setValue:self.riskWarningTip forKey:kDetailNatantRiskWarning];
            [self.classNameList insertObject:@"TTDetailNatantRiskWarningView" atIndex:0];
        }
        
        //related video
        NSArray *relatedVideos = [data arrayValueForKey:@"related_video_toutiao" defaultValue:nil];
        self.relateVideoArticles = [self relatedVideosWithArr:relatedVideos];
        if (![TTDeviceHelper isPadDevice]) {
            self.videoExtendLink = [data tt_dictionaryValueForKey:@"video_extend_link"];
        }

        //related articles
        NSArray *relatedImages = [data arrayValueForKey:@"related_gallery" defaultValue:nil];
        self.relateImagesArticles = [self relatedArticlesWithArr:relatedImages];
        
        //related search words
        self.relateSearchWordsArray = [self relatedSearchWordsWithArr:[data tt_arrayValueForKey:@"related_gallery_labels"]];
        
        
        //视频详情页相关视频分页首页展示视频数
        self.relateVideoSection = @([data integerValueForKey:@"related_video_section" defaultValue:0]);
        
        
        //文章喜欢信息
        self.likeAndShareFlag = [data intValueForKey:@"info_flag"
                                        defaultValue:ArticleShowLike|ArticleShowWeixin|ArticleShowWeixinMoment];

        self.articlePosition = @([data floatValueForKey:@"article_position" defaultValue:-1.f]);

        if (self.adShareInfo) {
            NSDictionary *imageInfo = [self.adShareInfo tt_dictionaryValueForKey:@"share_icon"];
            TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:imageInfo];
            if (model) {
                [[TTWebImageManager shareManger] downloadWithImageModel:model options:0 progress:nil completed:nil];
            }

        }
    }
    @catch (NSException *exception) {
        
        NSString * reason = [NSString stringWithFormat:@"article/info modelling error %@",exception.reason];
        NSAssert(!exception, reason);
        
        NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
        [params setValue:_groupModel.groupID forKey:@"gid"];
        [params setValue:reason forKey:@"exception"];
        [[TTMonitor shareManager] trackData:params logTypeStr:@"articleInfo"];
        
        self.keywordJsons = nil;
        self.relateEnterJson = nil;
        self.forumLinkJson = nil;
        self.pgcActionEnterTitleStr = nil;
        self.detailADJsonDict = nil;
        self.corperationVideoDict = nil;
        self.videoAbstract = nil;
        self.relateVideoArticles = nil;
        self.relateImagesArticles = nil;
        self.relateSearchWordsArray = nil;
        self.activity = nil;
    }
    @finally {
        if (_delegate && [_delegate respondsToSelector:@selector(articleInfoManagerLoadDataFinished:)]) {
            [_delegate articleInfoManagerLoadDataFinished:self];
        }
        
        if (finishBlock) {
            finishBlock(self, error);
        }
    }
}

- (void)startFetchArticleInfo:(NSDictionary *)condition
{
    return [self startFetchArticleInfo:condition finishBlock:nil];
}

-(void)relatedOrderInfoWithArr:(NSArray *)arr {
    if (!arr || ![arr isKindOfClass:[NSArray class]]) {
        return;
    }
    NSMutableArray * natantClassNameList = [NSMutableArray arrayWithCapacity:arr.count];
    NSMutableDictionary * orderedInfo = [[NSMutableDictionary alloc] init];
    for (NSDictionary * dict in arr) {
        if ([[dict valueForKey:@"name"] isEqualToString:@"labels"]) {
            [natantClassNameList addObject:@"TTDetailNatantTagsView"];
            [orderedInfo setValue:[dict valueForKey:@"data"] forKey:kDetailNatantTagsKey];
        }else if ([[dict valueForKey:@"name"] isEqualToString:@"ad"]){
            [natantClassNameList addObject:@"ExploreDetailADContainerView"];
            NSDictionary *adData = nil;
            NSString *ad_data_jsonString = [dict tt_stringValueForKey:@"ad_data"];
            if (ad_data_jsonString) {
                NSData *jsonData = [ad_data_jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *jsonError;
                adData = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
            } else {
                adData = [dict tt_dictionaryValueForKey:@"data"];
            }
            [orderedInfo setValue:adData forKey:kDetailNatantAdsKey];
        }else if ([[dict valueForKey:@"name"] isEqualToString:@"like_and_rewards"]){
            [natantClassNameList addObject:@"TTDetailNatantRewardView"];
            [orderedInfo setValue:[dict valueForKey:@"data"] forKey:kDetailNatantLikeAndReWardsKey];
        }else if ([[dict valueForKey:@"name"] isEqualToString:@"related_news"]){
            if (![[dict valueForKey:@"data"] isKindOfClass:[NSArray class]] || [(NSArray *)[dict valueForKey:@"data"] count]<=0) {
                continue;
            }
            [natantClassNameList addObject:@"TTDetailNatantRelateArticleGroupView"];
            [orderedInfo setValue:[dict valueForKey:@"data"] forKey:kDetailNatantRelatedKey];
        }else if ([[dict stringValueForKey:@"name" defaultValue:nil] isEqualToString:@"admin_debug"]) {
            [natantClassNameList addObject:@"ExploreDetailTextlinkADView"];
            [orderedInfo setValue:[dict valueForKey:@"data"] forKey:kDetailNatantAdminDebug];
        }
    }
    self.ordered_info = orderedInfo;
    self.classNameList = natantClassNameList;
}

- (NSArray *)relatedArticlesWithArr:(NSArray *)arr
{
    NSMutableArray *relatedArticles = [NSMutableArray arrayWithCapacity:arr.count];
    for (NSDictionary * dict in arr) {
        if ([[dict allKeys] containsObject:@"group_id"] && ([[dict objectForKey:@"cell_type"] intValue] == ExploreOrderedDataCellTypeArticle)) {
            
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
            //如果不是文章，使用关联index的特殊gID防重复
            if (![dict[@"is_article"] boolValue]) {
                NSInteger index = [arr indexOfObject:dict];
                gID = @([gID longLongValue] + index);
                [mutDict setValue:gID forKey:@"uniqueID"];
            }
            NSMutableDictionary * containerDict = [NSMutableDictionary dictionaryWithCapacity:10];
//            Article * tArticle = [Article insertInManager:[SSModelManager sharedManager] entityWithDictionary:mutDict];
            
            Article *tArticle = [Article objectWithDictionary:mutDict];
            
            if (tArticle != nil) {
                [containerDict setValue:tArticle forKey:@"article"];
                if ([[dict allKeys] containsObject:@"outer_schema"] || [[dict allKeys] containsObject:@"open_page_url"]) {
                    NSMutableDictionary * actions = [NSMutableDictionary dictionaryWithCapacity:10];
                    [actions setValue:[dict objectForKey:@"outer_schema"] forKey:@"outer_schema"];
                    [actions setValue:[dict objectForKey:@"open_page_url"] forKey:@"open_page_url"];
                    [containerDict setValue:actions forKey:@"actions"];
                }
            }
            
            if ([[dict allKeys] containsObject:@"tags"]) {
                [containerDict setValue:dict[@"tags"] forKey:@"tags"];
            }
            
            if ([containerDict count] > 0) {
                [relatedArticles addObject:containerDict];
            }
        }
    }
    
    if ([relatedArticles count] > 0) {
        //[[SSModelManager sharedManager] save:nil];
        return relatedArticles;
    }
    return nil;
}

- (NSArray *)relatedSearchWordsWithArr:(NSArray *)arr{
    if(SSIsEmptyArray(arr)){
        return nil;
    }
    
    NSMutableArray *searchWordsArr = [[NSMutableArray alloc] initWithCapacity:arr.count];
    for(NSDictionary * dict in arr){
        TTPhotoSearchWordModel *item = [[TTPhotoSearchWordModel alloc] initWithDictionary:dict];
        if(item){
            /*对数据进行过滤*/
            if((arr.count > 1 && [item isValidMultiSearchWord]) || (arr.count == 1 && [item isValidSingleSearchWord])){
                [searchWordsArr addObject:item];
            }
        }
    }
    return [searchWordsArr copy];
}

- (NSArray *)relatedVideosWithArr:(NSArray *)arr
{
    NSMutableArray *relatedVideos = [NSMutableArray arrayWithCapacity:arr.count];
    NSInteger count = 0;
    for (NSDictionary *dict in arr) {
        if ([[dict objectForKey:@"cell_type"] intValue] == ExploreOrderedDataCellTypeArticle) {
            
            NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            id groupID = dict[@"group_id"];
            if (groupID) {
                groupID = [NSString stringWithFormat:@"%@", groupID];
            }
            NSNumber * gID = [NSNumber numberWithLongLong:[groupID longLongValue]];
            if ([gID longLongValue] == 0) {
                gID = @(++count);
            }
            [mutDict setValue:gID forKey:@"uniqueID"];
            id itemID = dict[@"item_id"];
            if (itemID) {
                [mutDict setValue:[NSString stringWithFormat:@"%@", itemID] forKey:@"item_id"];
                [mutDict setValue:[NSString stringWithFormat:@"%@", itemID] forKey:@"itemID"];
            }
            //如果不是文章，使用关联index的特殊gID防重复
            if (![dict[@"is_article"] boolValue]) {
                NSInteger index = [arr indexOfObject:dict];
                gID = @([gID longLongValue] + index);
                [mutDict setValue:gID forKey:@"uniqueID"];
            }
            NSMutableDictionary *containerDict = [NSMutableDictionary dictionaryWithCapacity:10];
            
            NSString *primaryID = [Article primaryIDFromDictionary:mutDict];
            Article *tArticle = [Article updateWithDictionary:mutDict forPrimaryKey:primaryID];
            //只保存广告
            NSString* ad_id = [dict tt_stringValueForKey:@"ad_id"];
            if (!isEmptyString(ad_id)) {
                [tArticle save]; //相关视频里的广告视频需要ExploreOrderedData中查询article，所以需要save
            }
            
            if (tArticle != nil) {
                [containerDict setValue:tArticle forKey:@"article"];
                if ([[dict allKeys] containsObject:@"outer_schema"] || [[dict allKeys] containsObject:@"open_page_url"]) {
                    NSMutableDictionary * actions = [NSMutableDictionary dictionaryWithCapacity:10];
                    [actions setValue:[dict objectForKey:@"outer_schema"] forKey:@"outer_schema"];
                    [actions setValue:[dict objectForKey:@"open_page_url"] forKey:@"open_page_url"];
                    [containerDict setValue:actions forKey:@"actions"];
                }
                if ([[dict allKeys] containsObject:kArticleInfoRelatedVideoCardTypeKey]) {
                    tArticle.relatedVideoExtraInfo = [self relatedVideoExtraDictFromDict:dict];
                }
                
                NSMutableDictionary *detailInfo = [NSMutableDictionary dictionary];
                [detailInfo addEntriesFromDictionary:tArticle.videoDetailInfo];
                
                if ([[dict allKeys] containsObject:kArticleInfoRelatedVideoSubjectIDKey]) {
                    detailInfo[kArticleInfoRelatedVideoSubjectIDKey] = dict[kArticleInfoRelatedVideoSubjectIDKey];
                }
                
                if ([[dict allKeys] containsObject:@"col_no"]) {
                    detailInfo[@"col_no"] = dict[@"col_no"];
                }
                
                if ([[detailInfo allKeys] count] > 0 && ![[dict allKeys] containsObject:@"video_detail_info"]) {
                    //如果没有video_detail_info数据，则补全
                    tArticle.videoDetailInfo = detailInfo;
                }
                
                if ([detailInfo objectForKey:@"commoditys"]) {
                    tArticle.commoditys = [detailInfo dictionaryValueForKey:@"commoditys"
                                                         defalutValue:nil];
                }
                
                NSString* car_type = [dict objectForKey:@"card_type"];
                
                if (!isEmptyString(car_type)&&[car_type isEqualToString:@"ad_textlink"]) {
                    TTAdVideoRelateAdModel* videoAdExtra = [[TTAdVideoRelateAdModel alloc] initWithDict:dict];
                    tArticle.videoAdExtra = videoAdExtra;
                }
                if (!isEmptyString(car_type)&&[car_type isEqualToString:@"ad_video"]) {
                    TTAdVideoRelateAdModel* videoAdExtra = [[TTAdVideoRelateAdModel alloc] initWithDict:dict];
                    tArticle.videoAdExtra = videoAdExtra;
                }
                
                if ([[dict allKeys] containsObject:@"log_pb"]) {
                    [containerDict setValue: dict[@"log_pb"] forKey:@"logPb"];
                }
                
            }
            
            if ([containerDict count] > 0) {
                [relatedVideos addObject:containerDict];
            }
        }
    }
    
    if ([relatedVideos count] > 0) {
        //[[SSModelManager sharedManager] save:nil];
        return relatedVideos;
    }
    return nil;
}

- (NSDictionary *)relatedVideoExtraDictFromDict:(NSDictionary *)fromDict
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    NSString *cardType = [fromDict valueForKey:kArticleInfoRelatedVideoCardTypeKey];
    ArticleRelatedVideoType type = [self relatedVideoTypeFromString:cardType];
    [mutableDict setValue:@(type) forKey:kArticleInfoRelatedVideoCardTypeKey];
    
    if ([[fromDict allKeys] containsObject:kArticleInfoRelatedVideoAutoLoadKey]) {
        mutableDict[kArticleInfoRelatedVideoAutoLoadKey] = fromDict[kArticleInfoRelatedVideoAutoLoadKey];
    }
    if ([[fromDict allKeys] containsObject:kArticleInfoRelatedVideoAdIDKey]) {
        mutableDict[kArticleInfoRelatedVideoAdIDKey] = fromDict[kArticleInfoRelatedVideoAdIDKey];
    }
    if ([[fromDict allKeys] containsObject:kArticleInfoRelatedVideoTagKey]) {
        mutableDict[kArticleInfoRelatedVideoTagKey] = fromDict[kArticleInfoRelatedVideoTagKey];
    }
    if ([[fromDict allKeys] containsObject:kArticleInfoRelatedVideoLogExtraKey]) {
        mutableDict[kArticleInfoRelatedVideoLogExtraKey] = fromDict[kArticleInfoRelatedVideoLogExtraKey];
    }
    
    if ([[mutableDict allKeys] count] > 0) {
        return mutableDict;
    }
    return nil;
}

- (ArticleRelatedVideoType)relatedVideoTypeFromString:(NSString *)string
{
    if (isEmptyString(string)) {
        return ArticleRelatedVideoTypeUnknown;
    }
    ArticleRelatedVideoType type = ArticleRelatedVideoTypeArticle;
    if ([string isEqualToString:@"video"]) {
        type = ArticleRelatedVideoTypeArticle;
    } else if ([string isEqualToString:@"album"]) {
        type = ArticleRelatedVideoTypeAlbum;
    } else if ([string isEqualToString:@"video_subject"]) {
        type = ArticleRelatedVideoTypeSubject;
    } else if ([string isEqualToString:@"ad_video"] || [string isEqualToString:@"ad_textlink"]) {
        type = ArticleRelatedVideoTypeAd;
    }
    return type;
}

- (BOOL)needShowCorperationVideoView
{
    if ([self.corperationVideoDict count] == 0) {
        return NO;
    }
    if ([(NSArray *)[self.corperationVideoDict objectForKey:@"large_image"] count] == 0) {
        return NO;
    }
    /*
     申紫方在15-1-9的下午5:44输入：
     > 对于大图模式：
     > 不显示图，整个相关视频区域都不展示；较省流量，先不做特殊处理。
     */
    if (!TTNetworkWifiConnected() && [TTUserSettingsManager networkTrafficSetting] == TTNetworkTrafficSave) {
        return NO;
    }
    return YES;
    
}

- (BOOL)needShowAdShare {
    if (SSIsEmptyDictionary(self.adShareInfo)) {
        return NO;
    }
    NSMutableDictionary *shareInfo = [self.adShareInfo mutableCopy];
    NSString *shareTitle = [shareInfo tt_stringValueForKey:@"share_title"];
    if (isEmptyString(shareTitle)) {
        return NO;
    }
    NSString *shareDesc = [shareInfo tt_stringValueForKey:@"share_desc"];
    if (isEmptyString(shareDesc)) {
        return NO;
    }
    NSDictionary *imageInfo = [shareInfo tt_dictionaryValueForKey:@"share_icon"];
    if (SSIsEmptyDictionary(imageInfo)) {
        return NO;
    }
    return YES;
}

- (NSMutableDictionary *)makeADShareInfo {
    NSMutableDictionary *shareInfo = [self.adShareInfo mutableCopy];
    if (self.detailModel.article.groupModel) {
        shareInfo[@"groupModel"] = self.detailModel.article.groupModel;
    }
    if(self.detailModel.adID) {
        shareInfo[@"adID"] = [NSString stringWithFormat:@"%@", self.detailModel.adID];
    }
    if (isEmptyString(self.detailModel.article.shareURL)) {
        shareInfo[@"share_url"] = self.detailModel.article.articleURLString ?: @"https://m.toutiao.com";
    } else {
        shareInfo[@"share_url"] = self.detailModel.article.shareURL;
    }
    return shareInfo;
}

- (id)adNatantDataModel:(NSString *)key4Data {
    return self.ordered_info[key4Data];
}

GENERATE_SETTER_GETTER(webViewTrackKey, NSString *, setWebViewTrackKey)
GENERATE_SETTER_GETTER(insertedJavaScript, NSString *, setInsertedJavaScript)
GENERATE_SETTER_GETTER(insertedContextJS, NSString *, setInsertedContextJS)
GENERATE_SETTER_GETTER(riskWarningTip, NSString *, setRiskWarningTip)
GENERATE_SETTER_GETTER(videoAdUrl, NSString *, setVideoAdUrl)
GENERATE_SETTER_GETTER(keywordJsons, NSArray *, setKeywordJsons)
GENERATE_SETTER_GETTER(relateVideoArticles, NSArray *, setRelateVideoArticles)
GENERATE_SETTER_GETTER(videoBanner, NSDictionary *, setVideoBanner)
GENERATE_SETTER_GETTER(videoEmbededAdInfo, NSDictionary *, setVideoEmbededAdInfo)
GENERATE_SETTER_GETTER(videoAbstract, NSString *, setVideoAbstract)
GENERATE_SETTER_GETTER(relateImagesArticles, NSArray *, setRelateImagesArticles)
GENERATE_SETTER_GETTER(wendaArray, NSArray *, setWendaArray)
GENERATE_SETTER_GETTER(webRecommandPhotosArray, NSArray *, setWebRecommandPhotosArray)
GENERATE_SETTER_GETTER(relateVideoSection, NSNumber *, setRelateVideoSection)
GENERATE_SETTER_GETTER(relateEnterJson, NSDictionary *, setRelateEnterJson)
GENERATE_SETTER_GETTER(detailADJsonDict, NSDictionary *, setDetailADJsonDict)
GENERATE_SETTER_GETTER(adminDebugInfo, NSDictionary *, setAdminDebugInfo)
GENERATE_SETTER_GETTER(pgcActionEnterTitleStr, NSString *, setPgcActionEnterTitleStr)
GENERATE_SETTER_GETTER(corperationVideoDict, NSDictionary *, setCorperationVideoDict)
GENERATE_SETTER_GETTER(forumLinkJson, NSDictionary *, setForumLinkJson)
GENERATE_SETTER_GETTER(ordered_info, NSMutableDictionary *, setOrdered_info)
GENERATE_SETTER_GETTER(classNameList, NSMutableArray *, setClassNameList)
GENERATE_SETTER_GETTER(videoExtendLink, NSDictionary *, setVideoExtendLink)
GENERATE_SETTER_GETTER(likeAndShareFlag, ArticleLikeAndShareFlags, setLikeAndShareFlag)
GENERATE_SETTER_GETTER(articlePosition, NSNumber *, setArticlePosition)
GENERATE_SETTER_GETTER(adShareInfo, NSDictionary *, setAdShareInfo)
GENERATE_SETTER_GETTER(promotionModel, TTActivityModel *, setPromotionModel)
GENERATE_SETTER_GETTER(flags, NSNumber *, setFlags)
GENERATE_SETTER_GETTER(dislikeWords, NSArray *, setDislikeWords)
GENERATE_SETTER_GETTER(logPb, NSDictionary *, setLogPb)
GENERATE_SETTER_GETTER(relateSearchWordsArray, NSArray *, setRelateSearchWordsArray)
GENERATE_SETTER_GETTER(activity, FRActivityStructModel *, setActivity)
@end

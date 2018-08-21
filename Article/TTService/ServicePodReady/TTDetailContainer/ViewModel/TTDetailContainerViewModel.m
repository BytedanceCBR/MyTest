//
//  TTDetailContainerViewModel.m
//  Article
//
//  Created by Ray on 16/3/31.
//

#import "TTDetailContainerViewModel.h"
#import "TTDetailModel.h"
#import "NewsFetchArticleDetailManager.h"
#import "NewsDetailLogicManager.h"
#import "NewsDetailConstant.h"
#import "Article.h"
#import "NSDictionary+TTAdditions.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+Extension.h"
#import "TTVVideoArticle+Extension.h"
#import "TTDetailModel+TTVTrackToolbarMode.h"
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "TTDetailModel+videoArticleProtocol.h"

#import <TTBaseLib/NSStringAdditions.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/JSONAdditions.h>
#import "Article+TTVArticleProtocolSupport.h"
#import "TTVSettingsConfiguration.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTFFantasyTracker.h"

@interface TTDetailContainerViewModel ()
@property (nonatomic, assign) long long flags;
@property (nonatomic, assign) BOOL hasLoadedArticle;
@property (nonatomic, assign) BOOL disableNewVideoDetailViewController;
@end

@implementation TTDetailContainerViewModel

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithDictionary:(nullable NSDictionary *)condition{
    self = [super init];
    if (self) {
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contentLoadFinished:)
                                                     name:kNewsFetchArticleDetailFinishedNotification
                                                   object:nil];
        [self updateLastGid:[condition valueForKey:@"group_id"]];
    }
    return self;
}

- (TTDetailModel *)detailModel{
    if (!_detailModel) {
        _detailModel = [[TTDetailModel alloc] init];
    }
    return _detailModel;
}

- (void)configArticleExtraInfo {
    TTVArticleExtraInfo *extraInfo = [[TTVArticleExtraInfo alloc] init];
    extraInfo.logExtra = self.detailModel.adLogExtra;
    extraInfo.adIDStr = [self.detailModel.adID stringValue];
    extraInfo.adID = self.detailModel.adID;
    extraInfo.categoryID = self.detailModel.categoryID;
    if ([self.detailModel.article isKindOfClass:[TTVFeedItem class]]) {
        TTVFeedItem *item = (TTVFeedItem *)self.detailModel.article;
        extraInfo.adClickTrackURLs = item.adInfo.trackURL.clickTrackURLListArray;
    } else {
        extraInfo.adClickTrackURLs = self.detailModel.orderedData.adClickTrackURLs;
    }
    self.detailModel.articleExtraInfo = extraInfo;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contentLoadFinished:)
                                                     name:kNewsFetchArticleDetailFinishedNotification
                                                   object:nil];

        Article *tArticle = nil;
        NSDictionary *params = paramObj.allParams;
        
        self.detailModel.baseCondition = [params copy];
        //原始schema
        self.detailModel.originalSchema = [paramObj.sourceURL absoluteString];
        //动态ID
        self.detailModel.dongtaiID = [params stringValueForKey:@"dongtai_id" defaultValue:@""];
        self.disableNewVideoDetailViewController = [params tt_boolValueForKey:@"disableNewVideoDetailViewController"];
        self.detailModel.transitionAnimated = paramObj.userInfo.animated ? NO : YES;
        if ([params valueForKey:@"ttDragToRoot"]) {
            self.detailModel.ttDragToRoot = [[params valueForKey:@"ttDragToRoot"] boolValue];
        }
        if ([params valueForKey:@"isFloatVideoController"]) {
            self.detailModel.isFloatVideoController = [[params valueForKey:@"isFloatVideoController"] boolValue];
        }
        if ([params valueForKey:@"log_pb"]) {
            self.detailModel.logPb = [params valueForKey:@"log_pb"];
        }
        NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
        id groupIdValue = params[@"groupid"]?:params[@"group_id"];
        
        self.detailModel.rid = [params tt_stringValueForKey:@"rid"];
        self.detailModel.originalGroupID = [NSString stringWithFormat:@"%@", groupIdValue];

        if ([[params allKeys] containsObject:@"video_feed"]) {
            id item = [params objectForKey:@"video_feed"];
            self.detailModel.article = item;
            if ([item isKindOfClass:[TTVFeedItem class]]) {
                TTVFeedItem *feedItem = (TTVFeedItem *)item;
                tArticle = [feedItem ttv_convertedArticle];
                ((TTVFeedItem *)item).savedConvertedArticle = tArticle;
            }
            else if ([item isKindOfClass:[Article class]]){
                tArticle = item;
            }
        }

        if (groupIdValue) {
            NSNumber *groupID = @([[NSString stringWithFormat:@"%@", groupIdValue] longLongValue]);
            NSNumber *fixedgroupID = [SSCommonLogic fixNumberTypeGroupID:groupID];
            NSString *itemID = [params objectForKey:@"item_id"];
            NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:3];
            [query setValue:fixedgroupID forKey:@"uniqueID"];
            [query setValue:itemID forKey:@"itemID"];
            
            NSString * gdLabel = [params objectForKey:@"gd_label"];
            
            if ([params.allKeys containsObject:@"ordered_data"]) {
                self.detailModel.orderedData = [params objectForKey:@"ordered_data"];
                
                //优先从orderedData.logPb取，如果为空，会从routeParams取，逻辑在后面
                self.detailModel.logPb = self.detailModel.orderedData.logPb;
            }
            
            NSString *adOpenUrl = [params objectForKey:@"article_url"];
            if (!isEmptyString(adOpenUrl)) {
                self.detailModel.adOpenUrl = adOpenUrl;
            }
            
            NewsGoDetailFromSource fSource = NewsGoDetailFromSourceUnknow;
            if (!isEmptyString(gdLabel)) {
                self.detailModel.gdLabel = gdLabel;
                fSource = [NewsDetailLogicManager fromSourceByString:gdLabel];
            }
            else if ([[params allKeys] containsObject:kNewsGoDetailFromSourceKey]) {
                fSource = [params[kNewsGoDetailFromSourceKey] intValue];
            }
            
            self.detailModel.fromSource = fSource;
            
            ///...
            if ([params valueForKey:@"from_gid"]) {
                self.detailModel.relateReadFromGID = [params valueForKey:@"from_gid"];
            }

            NSNumber * adID = nil;
            if ([[params allKeys] containsObject:@"ad_id"]) {
                adID = @([[params objectForKey:@"ad_id"] longLongValue]);
                [condition setValue:adID forKey:kNewsDetailViewConditionADIDKey];
                [query setValue:adID forKey:@"ad_id"];
                self.detailModel.adID = adID;
            }
            if ([[params allKeys] containsObject:@"log_extra"]) {
                NSString * logExtra = [params objectForKey:@"log_extra"] ?  [params objectForKey:@"log_extra"] : @"";
                [condition setValue:logExtra forKey:kNewsDetailViewConditionADLogExtraKey];
                self.detailModel.adLogExtra = logExtra;
            }
            
            if (isEmptyString(self.detailModel.adLogExtra)) {
                NSString *logExtra = !isEmptyString(self.detailModel.orderedData.log_extra)?self.detailModel.orderedData.log_extra : @"";
                [condition setValue:logExtra forKey:kNewsDetailViewConditionADLogExtraKey];
                self.detailModel.adLogExtra = logExtra;
            }
            
            if (!tArticle) {
                tArticle = self.detailModel.orderedData.article;
            }
            if (!tArticle) {
                NSString *primaryID = [Article primaryIDByUniqueID:[fixedgroupID longLongValue] itemID:itemID adID:[adID stringValue]];
                tArticle = [Article objectForPrimaryKey:primaryID];
            }
            
            if (!tArticle) {
                tArticle = [Article objectWithDictionary:query];
            }
            if (!self.detailModel.article) {
                self.detailModel.article = tArticle;
            }
            if ([[params allKeys] containsObject:@"group_flags"]) {
                tArticle.groupFlags = @([[params objectForKey:@"group_flags"] intValue]);
            }else{
                if (tArticle.groupFlags.integerValue==0 || tArticle.groupFlags.integerValue==kArticleGroupFlagsDetailTypeArticleSubject) {
                 tArticle.groupFlags = @(kArticleGroupFlagsDetailTypeArticleSubject);
                }
            }
            if (params[@"aggr_type"]) {
                tArticle.aggrType = @([params[@"aggr_type"] integerValue]);
            }
            if (params[@"flags"]) {
                long long flags = [params[@"flags"] longLongValue];
                tArticle.articleType = flags & 0x1;
            } else {
                if ([params[@"article_type"] respondsToSelector:@selector(integerValue)]) {
                    tArticle.articleType = [params[@"article_type"] integerValue];
                }
            }
            if ([[params allKeys] containsObject:@"natant_level"]) {
                tArticle.natantLevel = @([[params objectForKey:@"natant_level"] intValue]);
            }
            if ([[params allKeys] containsObject:@"stat_params"] && [[params objectForKey:@"stat_params"] isKindOfClass:[NSDictionary class]]) {
                self.detailModel.statParams = [params objectForKey:@"stat_params"];
            }
            if ([[params allKeys] containsObject:@"video_type"]) {
                tArticle.videoType = @([[params objectForKey:@"video_type"] intValue]);
            }
            if (isEmptyString(tArticle.logExtra) &&  [[params allKeys] containsObject:@"log_extra"]) {
                tArticle.logExtra = [params objectForKey:@"log_extra"];
            }
            self.detailModel.isArticleReliable = [self.detailModel tt_isArticleReliable];
            [tArticle save];
            
            NSString * categoryID = [params objectForKey:kNewsDetailViewConditionCategoryIDKey];
            if (!isEmptyString(categoryID)) {
                [condition setValue:categoryID forKey:kNewsDetailViewConditionCategoryIDKey];
                self.detailModel.categoryID = categoryID;
            }
            
            NSString *gdExtJson = [params objectForKey:@"gd_ext_json"];
            if (!isEmptyString(gdExtJson)) {
                gdExtJson = [gdExtJson stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSDictionary *dict = [NSString tt_objectWithJSONString:gdExtJson error:&error];;
                if (!error && [dict isKindOfClass:[NSDictionary class]]) {
                    self.detailModel.gdExtJsonDict = dict;
                }
                else{//如果解析有问题，替换+号后解析
                    gdExtJson = [gdExtJson stringByReplacingOccurrencesOfString:@"+" withString:@" "];
                    error = nil;
                    NSDictionary *dict = [NSString tt_objectWithJSONString:gdExtJson error:&error];;
                    if (!error && [dict isKindOfClass:[NSDictionary class]]) {
                        self.detailModel.gdExtJsonDict = dict;
                    }
                }
            }
            if (params[@"flags"]) {
                _flags = [params[@"flags"] longLongValue];
            }
            
//看代码逻辑, hiddenWebView不可能传进来. 故注释掉 @zengruihuan
//            // 隐藏的预加载webview
//            if ([[params allKeys] containsObject:@"hidden_web_view"]) {
//                self.detailModel.hiddenWebView = [params objectForKey:@"hidden_web_view"];
//            }
//            
//            // 隐藏的预加载webview的delegate对象
//            if ([[params allKeys] containsObject:@"hidden_web_view_delegate"]) {
//                self.detailModel.jsBridgeDelegate = [params objectForKey:@"hidden_web_view_delegate"];
//            }
            
            if ([params objectForKey:@"msg_id"]) {
                self.detailModel.msgID = [params tt_stringValueForKey:@"msg_id"];
            }
            
            self.detailModel.needQuickExit = [params tt_boolValueForKey:@"is_quick_exit"];
            
            //added log v3.0
            id logPb = [params objectForKey:@"log_pb"];
            if (!self.detailModel.logPb && logPb) {
                if ([logPb isKindOfClass:[NSDictionary class]]) {
                    self.detailModel.logPb = (NSDictionary *)logPb;
                }
                else if ([logPb isKindOfClass:[NSString class]]) {
                    NSError *error = nil;
                    NSDictionary *logPbDict = [NSJSONSerialization JSONObjectWithData:[((NSString *)logPb) dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                    if (!error) {
                        self.detailModel.logPb = logPbDict;
                    }
                }
                else {
                    self.detailModel.logPb = nil;
                }
            }
        }
        [self configArticleExtraInfo];
        [self updateLastGid:self.detailModel.originalGroupID];
    }
    return self;
}

- (nullable id)initWithArticle:(nullable id<TTVArticleProtocol> )tArticle
               source:(NewsGoDetailFromSource)source
            condition:(nullable NSDictionary *)condition {
    self = [self init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contentLoadFinished:)
                                                     name:kNewsFetchArticleDetailFinishedNotification
                                                   object:nil];

        self.detailModel.article = tArticle;
        self.detailModel.fromSource = source;
        self.detailModel.isArticleReliable = [self.detailModel tt_isArticleReliable];
        NSString * categoryID = [condition objectForKey:kNewsDetailViewConditionCategoryIDKey];
        self.detailModel.categoryID = categoryID;
        if ([[condition allKeys] containsObject:kNewsDetailViewConditionADIDKey] &&
            [[condition objectForKey:kNewsDetailViewConditionADIDKey] longLongValue] > 0) {
            self.detailModel.adID = @([[condition objectForKey:kNewsDetailViewConditionADIDKey] longLongValue]);
        }
        if ([[condition allKeys] containsObject:kNewsDetailViewConditionADLogExtraKey]) {
            self.detailModel.adLogExtra = [condition objectForKey:kNewsDetailViewConditionADLogExtraKey];
        }
        if ([[condition objectForKey:kNewsDetailViewConditionRelateReadFromGID] longLongValue] > 0) {
            self.detailModel.relateReadFromGID = @([[condition objectForKey:kNewsDetailViewConditionRelateReadFromGID] longLongValue]);
        }
        if ([condition objectForKey:kNewsDetailViewConditionOriginalStatusBarHidden]) {
            self.detailModel.originalStatusBarHiddenNumber = [condition objectForKey:kNewsDetailViewConditionOriginalStatusBarHidden];
        }
        if ([condition objectForKey:kNewsDetailViewConditionOriginalStatusBarStyle]) {
            self.detailModel.originalStatusBarStyleNumber = [condition objectForKey:kNewsDetailViewConditionOriginalStatusBarStyle];
        }
        if ([[condition objectForKey:kNewsDetailViewConditionRelateReadFromAlbumKey] longLongValue] > 0) {
            self.detailModel.relateReadFromGID = @([[condition objectForKey:kNewsDetailViewConditionRelateReadFromAlbumKey] longLongValue]);
        }
        if ([[condition valueForKey:@"logPb"] isKindOfClass:[NSDictionary class]]) {
            self.detailModel.logPb = [condition valueForKey:@"logPb"];
        }
        [self configArticleExtraInfo];
        [self updateLastGid:tArticle.groupModel.groupID];
    }
    return self;
}

- (void)updateLastGid:(NSString *)gid
{
    if (!isEmptyString(gid) && [self.detailModel.adID longLongValue] <= 0) {
        [TTFFantasyTracker sharedInstance].lastGid = gid;
    }
}

- (nullable NSString *)classNameForSpecificDetailViewController:(NSError **)error isFromNet:(BOOL)isFromNet{
    
    NSError *(^errorCreater)(id <TTVArticleProtocol>) = ^(id <TTVArticleProtocol> article) {
        NSMutableDictionary *extract = [NSMutableDictionary dictionaryWithCapacity:3];
        [extract setValue:article.groupFlags forKey:@"groupFlags"];
        [extract setValue:article.itemID forKey:@"itemID"];
        [extract setValue:article.groupModel.groupID forKey:@"groupID"];
        [extract setValue:article.videoDetailInfo forKey:@"videoDetailInfo"];
        [extract setValue:article.adIDStr forKey:@"adid"];
        [extract setValue:article.logExtra forKey:@"logExtra"];
        NSError *innerError  = [NSError errorWithDomain:@"toutiao.detail" code:0 userInfo:extract];
        return innerError;
    };
    
    //如果无法判断是哪个业务，返回nil
    if (!self.detailModel.article.groupFlags) {
        if (error) {
            *error = errorCreater(self.detailModel.article);
        }
        return nil;
    }
    if ([self.detailModel.article isKindOfClass:[TTVFeedItem class]]) {
        TTVFeedItem *feed = (TTVFeedItem *)self.detailModel.article;
        if (feed.videoCell.article.videoDetailInfo == nil) {
            if (error) {
                *error = errorCreater(self.detailModel.article);
            }
            return nil;
        }
    }
    
    if ([self.detailModel.article isVideoSubject] && SSIsEmptyDictionary(self.detailModel.article.videoDetailInfo)) {
        if (error) {
            *error = errorCreater(self.detailModel.article);
        }
        return nil;
    }
    
    BOOL isVideoSubject = [self isVideoDetail];
    if (!isFromNet && isVideoSubject) {
        if ([self.detailModel.article respondsToSelector:@selector(detailVideoProportion)]) {
            if (self.detailModel.article.detailVideoProportion == nil) {  //需要有这个,进入视频详情页才能确定按比例显示.
                return nil;
            }
        }
    }
    if (isVideoSubject) {
        if (self.detailModel.isFloatVideoController) {
            return @"TTVideoFloatViewController";
        }
        if (!ttvs_isTitanVideoBusiness()) {
            return @"TTVideoDetailViewController";
        }
        
        if (self.disableNewVideoDetailViewController) {
            return @"TTVideoDetailViewController";
        } else {
            return @"TTVVideoDetailViewController";
        }
    } else if ([self.detailModel.article isKindOfClass:[Article class]]) {
        Article *article = (Article *)self.detailModel.article;
        
        BOOL isPhotoSubject = ([article isImageSubject]) || !!(_flags & kArticleGroupFlagsDetailTypeSchemaImageSubject);
        
        if ([SSCommonLogic strictDetailJudgementEnabled]) {
            //加保护，如果没有videoDetailInfo则不进视频详情页
            if (article.groupFlags.integerValue==kArticleGroupFlagsDetailTypeArticleSubject) {
                return nil;
            }
        } else {
            //加保护，如果没有videoDetailInfo但是flags判断为图集可以先进入详情页加载
            if (article.groupFlags.integerValue==kArticleGroupFlagsDetailTypeArticleSubject && !isPhotoSubject) {
                return nil;
            }
        }
        
        if ([article isVideoSubject] && SSIsEmptyDictionary(article.videoDetailInfo)) {
            return nil;
        }

        BOOL isWenda = ([article isWenDaSubject]) || !! (_flags & kArticleGroupFlagsDetailTypeWenDaSubject);
        if (isVideoSubject) {
            if (self.detailModel.isFloatVideoController) {
                return @"TTVideoFloatViewController";
            }
            return @"TTVideoDetailViewController";
        } else if (isPhotoSubject) {
            if ([SSCommonLogic appGalleryTileSwitchOn]) {
                return @"TTArticleDetailViewController";
            } else {
                if ([SSCommonLogic appGallerySlideOutSwitchOn]) {
                    return @"TTPhotoDetailContainerViewController";
                }
                else{
                    return @"TTPhotoDetailViewController";
                    
                }
            }
        } else if (isWenda) {
            wrapperTrackEvent(@"detail", @"wenda_subject");
        }
    }
    
    
    return @"TTArticleDetailViewController";
}

- (void)fetchContentFromRemoteIfNeededWithComplete:(nullable FetchRemoteContentBlock)block {
    self.fetchContentBlock = block;
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
    [extra setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
    [extra setValue:@(self.detailModel.article.groupModel.aggrType) forKey:@"aggr_type"];
    [extra setValue:self.detailModel.adID forKey:@"ad_id"];

    if ([self.detailModel.article isKindOfClass:[Article class]] && (![(id <TTVArticleProtocol>)self.detailModel.article isContentFetchedWithForceLoadNative:NO] ||
        [self.detailModel.article.articleDeleted boolValue])) {
        __weak __typeof(self)weakSelf = self;
        if ([SSCommonLogic CDNBlockEnabled]) {
            [[NewsFetchArticleDetailManager sharedManager] fetchDetailForArticle:self.detailModel.article withPriority:NSOperationQueuePriorityVeryHigh forceLoadNative:NO completion:^(Article *article, NSError *error) {
                if (!weakSelf) {
                    return;
                }
                [weakSelf contentLoadFinishedWithArticle:article error:error];
            }];
        } else {
            [[NewsFetchArticleDetailManager sharedManager] fetchDetailForArticle:(Article *)self.detailModel.article
                                                       withOperationPriority:NSOperationQueuePriorityVeryHigh
                                                notifyCompleteBeforRealFetch:YES
                                                                 notifyError:YES
                                                             forceLoadNative:NO];
        }
    }else{
        if ([self.detailModel.article isKindOfClass:[TTVFeedItem class]]) {
            TTVVideoArticle *videoArticle = ((TTVFeedItem *)self.detailModel.article).article;
            if (!videoArticle) {
                videoArticle = [[TTVVideoArticle alloc] init];
            }
            self.detailModel.videoArticle = videoArticle;
            [self fetchVideoDetailContent:videoArticle];
        }
        else
        {
            [self fetchDoneWithCompleteWithExtra:extra];
        }

    }
}

- (void)fetchDoneWithCompleteWithExtra:(NSDictionary *)extra
{
    if (self.detailModel.article.groupFlags.integerValue==kArticleGroupFlagsDetailTypeArticleSubject) {
        self.detailModel.article.groupFlags = @(0);
    }
    _hasLoadedArticle = YES;
    [[self.detailModel sharedDetailManager] setHasLoadedArticle];
    self.detailModel.hasLoadedArticle = YES;
    if (self.fetchContentBlock) {
        self.fetchContentBlock(ExploreDetailManagerFetchResultTypeDone);
        self.fetchContentBlock = nil;
    }
    [[TTMonitor shareManager] trackService:@"cdn_finish_load" status:0 extra:extra];
}

- (void)fetchVideoDetailContent:(TTVVideoArticle *)videoArticle
{
    TTVFeedItem *feedItem = (TTVFeedItem *)self.detailModel.article;
    if (![feedItem isKindOfClass:[TTVFeedItem class]]) {
        return;
    }
    if (!isEmptyString(feedItem.article.extend.content)) {
        return;
    }
    BOOL full = isEmptyString(feedItem.title) || isEmptyString(feedItem.article.displayURL);
    TTVFetchEntity *entity = [[TTVFetchEntity alloc] init];
    entity.full = full;
    entity.notifyError = YES;
    entity.priority = NSOperationQueuePriorityVeryHigh;
    entity.itemID = feedItem.itemID;
    entity.uniqueID = @(feedItem.uniqueID).stringValue;
    entity.aggrType = feedItem.aggrType.integerValue;
    [[NewsFetchArticleDetailManager sharedManager] fetchVideoDetailForVideoArticle:videoArticle withRequestEntity:entity];
}

- (void)contentLoadFinished:(NSNotification *)nofitication {
    id<TTVArticleProtocol> newArticle = [[nofitication userInfo] objectForKey:@"data"];
    [self contentLoadFinishedWithArticle:newArticle error:[nofitication.userInfo objectForKey:@"error"]];
}

- (void)contentLoadFinishedWithArticle:(id<TTVArticleProtocol> )newArticle error:(NSError *)error {
    if (self.detailModel.article.groupFlags.integerValue==kArticleGroupFlagsDetailTypeArticleSubject) {
        self.detailModel.article.groupFlags = @(0);
    }
    if (![self.detailModel.article isKindOfClass:[Article class]]) {
        return;
    }
    id <TTVArticleProtocol>article = (id <TTVArticleProtocol>)self.detailModel.article;
    if(article == nil || article.managedObjectContext == nil) // don't have valid article
    {
        if (self.fetchContentBlock) {
            self.fetchContentBlock(ExploreDetailManagerFetchResultTypeFailed);
            self.fetchContentBlock = nil;
        }
        return ;
    }
    
    if(self.detailModel.article != nil && newArticle != nil &&
       ![[@(self.detailModel.article.uniqueID) stringValue] isEqualToString:[@(newArticle.uniqueID) stringValue]]){
        if (self.fetchContentBlock) {
            self.fetchContentBlock(ExploreDetailManagerFetchResultTypeEndLoading);
            self.fetchContentBlock = nil;
        }
        return;
    }

    if(error == nil)
    {
        if(!_hasLoadedArticle)
        {
            self.detailModel.article = newArticle;
            _hasLoadedArticle = YES;
            if (self.fetchContentBlock) {
                self.fetchContentBlock(ExploreDetailManagerFetchResultTypeDone);
                self.fetchContentBlock = nil;
            }
        }
    }
    else if(![article isContentFetchedWithForceLoadNative:NO])//_forceLoadNativeContent
    {
        if (!TTNetworkConnected()) {
            if (self.fetchContentBlock) {
                self.fetchContentBlock(ExploreDetailManagerFetchResultTypeNoNetworkConnect);
                self.fetchContentBlock = nil;
            }
        }
        else {
            if (self.fetchContentBlock) {
                self.fetchContentBlock(ExploreDetailManagerFetchResultTypeFailed);
                self.fetchContentBlock = nil;
            }
        }
    }
    if (self.fetchContentBlock) {
        self.fetchContentBlock = nil;
    }
}

- (BOOL)isImageDetail
{
    if (![self.detailModel.article isKindOfClass:[Article class]]) {
        return NO;
    }
    Article *currentArticle = (Article *)self.detailModel.article;
    return ([currentArticle isImageSubject] || _flags & 0x10000);
}


- (BOOL)isVideoDetail
{   
    return ([self.detailModel.article isVideoSubject] &&
            !SSIsEmptyDictionary(self.detailModel.article.videoDetailInfo))
    || !!(_flags & kArticleGroupFlagsDetailTypeVideoSubject);
}

- (BOOL)isNativeImageDetail
{
    Article *currentArticle = self.detailModel.article;
//    /// 和秋良老师确认，如果Article能找到title，则认为是可依赖的
    BOOL isArticleReliable = !isEmptyString(currentArticle.title);
    return ([self isImageDetail] && (isArticleReliable && currentArticle.articleType == ArticleTypeNativeContent))
            || ((_flags & 0x10000) && currentArticle.articleType == ArticleTypeNativeContent) ;
}

#pragma mark SSTrack
-(void)logEnter{
    BOOL isImageSubject = [self isImageDetail];
    NSString *tag = isImageSubject ? @"slide_detail" : @"detail";
    wrapperTrackEvent(tag, @"enter");
}

@end

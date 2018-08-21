//
//  TTPhotoDetailViewModel.m
//  Article
//
//  Created by yuxin on 4/19/16.
//
//

#import "TTPhotoDetailViewModel.h"
#import "NewsDetailLogicManager.h"
#import "NetworkUtilities.h"
#import "ExploreEntry.h"
#import "ExploreEntryManager.h"
#import "SSWebViewUtil.h"
#import "ExploreDetailManager.h"
#import "TTStringHelper.h"
//#import "SSCommon+UIApplication.h"
#import "TTUIResponderHelper.h"
#import "TTServiceCenter.h"
#import "TTAdManagerProtocol.h"
#import "TTAdManager.h"

@interface TTPhotoDetailViewModel () <ArticleInfoManagerDelegate>


@property (nonatomic, strong) TTDetailModel *detailModel;

@end

@implementation TTPhotoDetailViewModel

- (instancetype) initViewModel:(TTDetailModel *)model {
    self = [super init];
    if (self) {
        self.articleInfoManager = [[ArticleInfoManager alloc] init];
        self.articleInfoManager.detailModel = model;
        self.articleInfoManager.delegate = self;
        self.detailModel = model;
    }
    return self;
}

#pragma mark - logic

- (void)tt_startFetchInformationWithFinishBlock:(TTArticleDetailFetchInformationBlock)block
{
    
    //请求information接口
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setObject:self.detailModel.article.groupModel forKey:kArticleInfoManagerConditionGroupModelKey];
    if ([[self.detailModel.article.comment allKeys] containsObject:@"comment_id"]) {
        [condition setValue:[self.detailModel.article.comment objectForKey:@"comment_id"] forKey:kArticleInfoManagerConditionTopCommentIDKey];
    }
    
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
    [condition setValue:@(2) forKey:@"article_page"];
    
    [self.articleInfoManager startFetchArticleInfo:condition finishBlock:block];
}


- (ArticleType)p_currentArticleType
{
    if (!self.detailModel.article.managedObjectContext) {
        return ArticleTypeNativeContent;
    }
    return self.detailModel.article.articleType;
}

- (NSString *)p_webContentArticleLoadURLString:(UIView *)view
{
    NSString * webURLString = [self.detailModel.article.articleURLString copy];
    
    // 处理合作网站
    // 图集没有高亮词，夜间模式，文字大小，有图无图 - wangwei
    if (self.detailModel.article.articleSubType == ArticleSubTypeCooperationWap) {
        BOOL hasHash = YES;
        
        if ([webURLString rangeOfString:@"#"].location == NSNotFound) {
            hasHash = NO;
        }
        
        NSString * categoryName = [self.detailModel.categoryID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        webURLString = [NSString stringWithFormat:@"%@%@category_name=%@&group_id=%@&support_gallery=true&descpadding=%@", webURLString, hasHash?@"&":@"#", categoryName, @(self.detailModel.article.uniqueID).stringValue, @([TTUIResponderHelper paddingForViewWidth:view.frame.size.width])];
    }
    
    /**
     *  added 5.2.1
     *
     *  如果开屏广告透传了openUrl，则使用其作为落地页打开
     */
    if(!isEmptyString(self.detailModel.adOpenUrl) && !isEmptyString(self.detailModel.adID.stringValue)) {
        webURLString = [NSMutableString stringWithString:self.detailModel.adOpenUrl];
    }
    
    return webURLString;
}

- (NSString *)infomationAntiHijackJS {
    return self.articleInfoManager.insertedJavaScript;
}

- (void)p_updateArticleByDict:(NSDictionary *)dict
{
    //added 5.9.9 info更新转码开关
    if ([[dict allKeys] containsObject:@"ignore_web_transform"]) {
        self.detailModel.article.ignoreWebTranform = [dict objectForKey:@"ignore_web_transform"];
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
    
    if ([[dict allKeys] containsObject:@"gallery_additional"]) {
        self.detailModel.article.galleryAdditional = [dict tt_arrayValueForKey:@"gallery_additional"];
    }
    
    BOOL bannComment = [[dict objectForKey:@"ban_comment"] boolValue];
    self.detailModel.article.banComment = bannComment;
    
    if ([dict objectForKey:@"ban_bury"]) {
        self.detailModel.article.banBury = [NSNumber numberWithInteger:[dict integerValueForKey:@"ban_bury" defaultValue:0]];
    }
    if ([dict objectForKey:@"ban_digg"]) {
        self.detailModel.article.banDigg = [NSNumber numberWithInteger:[dict integerValueForKey:@"ban_digg" defaultValue:0]];
    }
    
    if ([[dict allKeys] containsObject:@"repin_count"]) {
        int repinCount = [[dict objectForKey:@"repin_count"] intValue];
        self.detailModel.article.repinCount = @(repinCount);
    }
    
    if ([[dict allKeys] containsObject:@"digg_count"]) {
        int diggCount = [[dict objectForKey:@"digg_count"] intValue];
        self.detailModel.article.diggCount = diggCount;
    }
    
    if ([[dict allKeys] containsObject:@"like_count"]) {
        int likeCount = [[dict objectForKey:@"like_count"] intValue];
        self.detailModel.article.likeCount = @(likeCount);
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
    
    if ([[dict allKeys] containsObject:@"user_repin"]) {
        BOOL userRepin = [[dict objectForKey:@"user_repin"] boolValue];
        self.detailModel.article.userRepined = userRepin;
    }
    
    if ([[dict allKeys] containsObject:@"user_digg"]) {
        BOOL userDigg = [[dict objectForKey:@"user_digg"] boolValue];
        self.detailModel.article.userDigg = userDigg;
    }
    
    BOOL delArticle = [[dict objectForKey:@"delete"] boolValue];
    self.detailModel.article.articleDeleted = @(delArticle);
    
    if ([[dict allKeys] containsObject:@"user_like"]) {
        BOOL userLike = [[dict objectForKey:@"user_like"] boolValue];
        self.detailModel.article.userLike = @(userLike);
    }
    
    if ([[dict allKeys] containsObject:@"media_info"]) {
        NSDictionary *mediaInfo = [dict objectForKey:@"media_info"];
        self.detailModel.article.mediaInfo = mediaInfo;
        
        if ([[mediaInfo allKeys] containsObject:@"subcribed"]) {
            BOOL subscribed = [mediaInfo tt_boolValueForKey:@"subcribed"];
            self.detailModel.article.isSubscribe = @(subscribed);
            [self.detailModel.article save];
            
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
    
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_fetchAdModelDict:)]) {
        NSArray<NSDictionary *> *order_info = [dict arrayValueForKey:@"ordered_info" defaultValue:nil];
        __block NSDictionary *adData = nil;
        [order_info enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj[@"name"] isEqualToString:@"ad"]) {
                    NSString *ad_data_jsonString = [obj tt_stringValueForKey:@"ad_data"];
                    if (ad_data_jsonString) {
                        NSData *jsonData = [ad_data_jsonString dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *jsonError;
                        adData = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
                    } else {
                        adData = [obj tt_dictionaryValueForKey:@"data"];
                    }
                }
            }
        }];
        
        if ([adData isKindOfClass:[NSDictionary class]] && adData.count > 0) {
            [adManagerInstance photoAlbum_fetchAdModelDict:adData];
        } else {
            [adManagerInstance photoAlbum_fetchAdModelDict:nil];
        }
    }
    
    [self.detailModel.article save];
}

- (nullable NSURLRequest *)tt_requstForWebContentPhotoView:(UIView *)view
{
    if ([self p_currentArticleType] != ArticleTypeWebContent) {
        return nil;
    }
    NSString *webURLString = [self p_webContentArticleLoadURLString:view];
    NSURL *webURL = [TTStringHelper URLWithURLString:webURLString];
    NSDictionary *wapHeaders = self.detailModel.article.wapHeaders;
    
    NSMutableURLRequest * urlRequest = nil;
    if (TTNetworkConnected()) {
        urlRequest = (NSMutableURLRequest*)[SSWebViewUtil requestWithURL:webURL httpHeaderDict:wapHeaders];
    }
    else {
        urlRequest = (NSMutableURLRequest*)[SSWebViewUtil requestWithURL:webURL httpHeaderDict:wapHeaders cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    }
    
    return urlRequest;
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

- (void)sendEvent4ImageRecommendShow {
    NSDictionary *data = @{@"category": @"umeng",
                           @"tag":      @"slide_detail",
                           @"label":    kEventLabel4ImageRecommendShow,
                           @"value":    @(self.detailModel.article.uniqueID) ? : @"",
                           @"item_id":  self.detailModel.article.groupModel.itemID ? : @""
                           };
    [TTTrackerWrapper eventData:data];
}

- (void)sendEvent4ImageRecommendClick:(NSDictionary *)queryItems {
    NSDictionary *base = @{@"category": @"umeng",
                           @"tag":      @"slide_detail",
                           @"label":    kEventLabel4ImageRecommendClicked,
                           //                           @"value":    [self currentArticle].uniqueID ? : @"",
                           //                           @"item_id":  [self currentArticle].groupModel.itemID ? : @""
                           };
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:base];
    
    if ([queryItems isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        // 当前文章的gid
        [extra setValue:@(self.detailModel.article.uniqueID) forKey:@"from_gid"];
        
        // 跳转目标的groupid
        NSString *gid = [queryItems tt_stringValueForKey:@"groupid"];
        [extra setValue:gid forKey:@"value"];
        
        // 跳转目标的item_id
        NSString *itemID = [queryItems tt_stringValueForKey:@"item_id"];
        [extra setValue:itemID forKey:@"item_id"];
        
        [data addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:data];
}
@end

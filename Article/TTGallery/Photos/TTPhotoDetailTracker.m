//
//  TTPhotoDetailTracker.m
//  Article
//
//  Created by Chen Hong on 16/4/22.
//
//

#import "TTPhotoDetailTracker.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "NewsDetailLogicManager.h"
#import "Article.h"
#import "SSWebViewUtil.h"
#import "SSImpressionManager.h"
#import "TTDetailModel.h"
#import "TTDetailWebviewContainer.h"
#import "ExploreDetailManager.h"
#import "TTAdSiteWebPreloadManager.h"
#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"

@implementation TTPhotoDetailTracker

- (instancetype)initWithDetailModel:(TTDetailModel *)detailModel
                      detailWebView:(TTDetailWebviewContainer *)detailWebView
{
    self = [super init];
    if (self) {
        _detailModel = detailModel;
        _detailWebView = detailWebView;
        
        //有ADID的需要统计webview的加载时间,从进入就开始计时
        _startLoadDate = [NSDate date];
        _jumpLinks = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)tt_resetStartLoadDate
{
    self.startLoadDate = nil;
}

- (void)tt_sendStartLoadDateTrackIfNeeded
{
    if (self.startLoadDate) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@"wap_stat" forKey:@"category"];
        [dict setValue:[NSString stringWithFormat:@"%lld", self.detailModel.orderedData.originalData.uniqueID] forKey:@"value"];
        [dict setValue:@"domReady" forKey:@"tag"];
        [dict setValue:[NSString stringWithFormat:@"%lld", self.detailModel.adID.longLongValue] forKey:@"ext_value"];
        
        if (!isEmptyString(self.detailModel.orderedData.log_extra)) {
            [dict setValue:self.detailModel.orderedData.log_extra forKey:@"log_extra"];
        }
        else if (!isEmptyString(self.detailModel.adLogExtra)) {
            [dict setValue:self.detailModel.adLogExtra forKey:@"log_extra"];
        }
        else {
            [dict setValue:@"" forKey:@"log_extra"];
        }
        //加载时间 等扩展字段
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.startLoadDate];
        [dict setValue:[NSString stringWithFormat:@"%.0f", timeInterval*1000] forKey:@"load_time"];
        [dict setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        [dict setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
        [TTTrackerWrapper eventData:dict];
    }
}

- (void)tt_sendJumpLinksTrackWithKey:(NSString *)webViewTrackKey
{
    if (!webViewTrackKey) {
        return;
    }
    NSString *URLString = [self.jumpLinks firstObject];
    NSString *articleURLString = self.detailModel.article.articleURLString;
    
    if (!isEmptyString(articleURLString) && [URLString isEqualToString:articleURLString]) {
        /// 删除第一次落地也跳转
        [self.jumpLinks removeObject:URLString];
    }
    if (self.jumpLinks.count == 0) {
        return;
    }
    NSArray *URLs = [self.jumpLinks copy];
    NSNumber *adID = self.detailModel.adID;
    
    NSString * logExtra = @"";
    if (!isEmptyString(self.detailModel.orderedData.log_extra)) {
        logExtra = self.detailModel.orderedData.log_extra;
    }
    else if (!isEmptyString(self.detailModel.orderedData.adModel.log_extra)) {
        logExtra = self.detailModel.orderedData.adModel.log_extra;
        
    }
    else if (!isEmptyString(self.detailModel.adLogExtra)) {
        logExtra = self.detailModel.adLogExtra;
        
    }
    [SSWebViewUtil trackWebViewLinksWithKey:webViewTrackKey
                                 URLStrings:URLs adID:adID.stringValue
                                   logExtra:logExtra];
    [self.jumpLinks removeAllObjects];
}

- (void)tt_sendStatStayEventTrack:(SSWebViewStayStat)stat error:(NSError *)error
{
    /// 这里的顺序与 _SSWebViewStat 定义的顺序一致
    NSArray *tags = @[@"load", @"load_finish", @"load_fail"];
    if (stat >= tags.count) {
        return;
    }
    // 客户端转码页
    NSNumber *adID = _detailModel.adID;
    //之前是针对ad的 现在扩展到所有详情页-- add 5.1 nick
    if (!_detailWebView.webView.canGoBack && self.startLoadDate) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        if ([[TTAdSiteWebPreloadManager sharedManager].preloadURLSet containsObject:_detailModel.article.articleURLString]) {
            [dict setValue:@1 forKey:@"preload"];
        } else {
            [dict setValue:@0 forKey:@"preload"];
        }
        [dict setValue:@"wap_stat" forKey:@"category"];
        [dict setValue:[NSString stringWithFormat:@"%lld",_detailModel.orderedData.originalData.uniqueID] forKey:@"value"];
        [dict setValue:tags[stat] forKey:@"tag"];
        [dict setValue:[NSString stringWithFormat:@"%lld", adID.longLongValue] forKey:@"ext_value"];
        // 这里的加载时间是指从一开始LoadRequest就开始记时，到加载结束
        if (stat == SSWebViewStayStatLoadFail && error) {
            [dict setValue:[NSString stringWithFormat:@"%ld", (long)error.code] forKey:@"error"];
        } else {
            /// 需要减去后台停留时间
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_startLoadDate];
            [dict setValue:[NSString stringWithFormat:@"%.0f", timeInterval*1000] forKey:@"load_time"];
        }
        if (_userHasClickLink) {
            [dict setValue:@(YES) forKey:@"hasClickLink"];
        }
        if (!isEmptyString(_detailModel.orderedData.log_extra)) {
            [dict setValue:_detailModel.orderedData.log_extra forKey:@"log_extra"];
        }
        else if (!isEmptyString(_detailModel.adLogExtra)) {
            [dict setValue:_detailModel.adLogExtra forKey:@"log_extra"];
        }
        else {
            [dict setValue:@"" forKey:@"log_extra"];
        }
        [TTTrackerWrapper eventData:dict];
        // 这里要把这个变成空的，下次如果看到时间是空的，则不重新发送统计。
        [self tt_resetStartLoadDate];
    }
}

- (void)tt_sendJumpToAppStoreTrackWithReuqestURLStr:(NSString *)requestURLStr
                                        inWhiteList:(BOOL)inWhiteList
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    if (self.detailModel.gdExtJsonDict) {
        [dict setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
    }
    
    [dict setValue:@"wap_stat" forKey:@"category"];
    [dict setValue:(inWhiteList ? @"app_download" : @"app_download_banned") forKey:@"tag"];
    [dict setValue:@"browser" forKey:@"label"];
    [dict setValue:requestURLStr forKey:@"url"];
    [dict setValue:self.detailModel.article.articleURLString forKey:@"referer_url"];
    [dict setValue:self.detailModel.orderedData.log_extra forKey:@"log_extra"];
    [dict setValue:self.detailModel.adLogExtra forKey:@"log_extra"];
    if (inWhiteList) {
        [dict setValue:@(1) forKey:@"in_white_list"];
    }
    
    [TTTrackerWrapper eventData:dict];
}

- (void)tt_sendJumpEventTrack
{
    NSNumber *adID = self.detailModel.adID;
    // 只统计广告的页面停留时间，和qiuliang约定，如果停留时常<3s，则忽略
    if (self.jumpCount <= 0 || adID.longLongValue == 0) {
        return;
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    if (self.detailModel.gdExtJsonDict) {
        [dict setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
    }
    [dict setValue:@"wap_stat" forKey:@"category"];
    [dict setValue:@"jump_count" forKey:@"tag"];
    if (self.clickLinkCount > 0) {
        [dict setValue:@(self.clickLinkCount) forKey:@"click_link"];
    }
    [dict setValue:[NSString stringWithFormat:@"%ld", (long)self.jumpCount] forKey:@"value"];
    [dict setValue:adID forKey:@"ext_value"];
    if (!isEmptyString(self.detailModel.orderedData.log_extra)) {
        [dict setValue:self.detailModel.orderedData.log_extra forKey:@"log_extra"];
    }
    else if (!isEmptyString(self.detailModel.adLogExtra)) {
        [dict setValue:self.detailModel.adLogExtra forKey:@"log_extra"];
    }
    else {
        [dict setValue:@"" forKey:@"log_extra"];
    }
    
    [TTTrackerWrapper eventData:dict];
}

- (void)tt_sendReadTrackWithPCT:(CGFloat)pct
                      pageCount:(NSInteger)pageCount
{
    NSInteger percent = 0;        //百分比
    percent = (NSInteger)(pct * 100);
    if (percent <= 0) {
        percent = 0;
    }
    if (percent >= 100) {
        percent = 100;
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    if (self.detailModel.gdExtJsonDict) {
        [dict setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
    }
    
    [dict setValue:@"article" forKey:@"category"];
    [dict setValue:@"read_pct" forKey:@"tag"];
    [dict setValue:self.detailModel.clickLabel forKey:@"label"];
    [dict setValue:@(self.detailModel.article.uniqueID) forKey:@"value"];
    [dict setValue:self.detailModel.adID forKey:@"ext_value"];
    [dict setValue:self.detailModel.logPb forKey:@"log_pb"];
    [dict setValue:@(percent) forKey:@"pct"];
    [dict setValue:@(pageCount) forKey:@"page_count"];
    if (!isEmptyString(self.detailModel.article.groupModel.itemID)) {
        [dict setValue:@(self.detailModel.article.groupModel.aggrType) forKey:@"aggr_type"];
        [dict setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
    }
    
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTrackerWrapper eventData:dict];
    }
    
    
    [TTTrackerWrapper eventV3:@"read_pct" params:({
        NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:10];
        if (self.detailModel.gdExtJsonDict) {
            [param setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
        }
        [param setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [param setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        [param setValue:[self.detailModel.article.novelData tt_stringValueForKey:@"book_id"] forKey:@"novel_id"];
        [param setValue:[NewsDetailLogicManager enterFromValueForLogV3WithClickLabel:self.detailModel.clickLabel categoryID:self.detailModel.categoryID] forKey:@"enter_from"];
        NewsGoDetailFromSource fromSource = self.detailModel.fromSource;
        if (fromSource == NewsGoDetailFromSourceHeadline ||
            fromSource == NewsGoDetailFromSourceCategory) {
            [param setValue:self.detailModel.categoryID forKey:@"category_name"];
        }
        [param setValue:[self.detailModel.article.entityWordInfoDict tt_stringValueForKey:kEntityConcernID] forKey:@"concern_id"];
        [param setValue:self.detailModel.orderedData.groupSource.stringValue forKey:@"group_source"];
        [param setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
        [param setValue:@(percent) forKey:@"percent"];
        [param setValue:@(pageCount) forKey:@"page_count"];
        [param setValue:self.detailModel.logPb forKey:@"log_pb"];
        [param setValue:[self.detailModel.statParams tt_stringValueForKey:@"card_id"] forKey:@"card_id"];
        [param setValue:[self.detailModel.statParams tt_stringValueForKey:@"card_position"] forKey:@"card_position"];
        [param copy];
    }) isDoubleSending:YES];

}

- (void)tt_sendStartLoadNativeContentForWebTimeoffTrack
{
    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionary];
    [extValueDic setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
    wrapperTrackEventWithCustomKeys(@"detail", @"transcode_start", self.detailModel.article.groupModel.groupID, nil, extValueDic);
}

- (void)tt_sendStayTimeImpresssion
{
    // record UnitStayTime
    if ([SSImpressionManager fetchImpressionPolicy] & 0x20) {
        NSMutableDictionary * impressionGroup = [_detailWebView readUnitStayTimeImpressionGroup];
        // key_name与android格式保持一致<groupid>_<index>_<url>，index和url目前用不到，暂时为0，后台有需求时再加
        NSString *keyName = [NSString stringWithFormat:@"%lld_0_0", self.detailModel.article.uniqueID];
        [impressionGroup setValue:keyName forKey:@"key_name"];
        
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
        [extra setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        [impressionGroup setValue:extra forKey:@"extra"];
        
        //NSLog(@"%@", impressionGroup);
        [[SSImpressionManager shareInstance] addImpressionGroupFromDictionary:impressionGroup];
    }
}

- (void)tt_sendDetailTrackEventWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra {
    NSString *groupId = [NSString stringWithFormat:@"%lld", self.detailModel.article.uniqueID];
    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionaryWithDictionary:extra];
    
    if ([self.detailModel.adID longLongValue]) {
        NSString *adId = [NSString stringWithFormat:@"%lld", [self.detailModel.adID longLongValue]];
        extValueDic[@"ext_value"] = adId;
    }
    [extValueDic setValue:@([self.detailModel.article.itemID longLongValue]) forKey:@"item_id"];
    [extValueDic setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
    
    NSString *source;
    if (!isEmptyString(self.detailModel.gdLabel)) {
        source = self.detailModel.gdLabel;
    }
    else {
        source = self.detailModel.clickLabel;
    }
    wrapperTrackEventWithCustomKeys(tag, label, groupId, source, extValueDic);
}

- (void)tt_sendDetailLoadTimeOffLeave
{
    BOOL stayTooLong = [self.detailModel.sharedDetailManager currentStayDuration] > 3000.f;
    if (stayTooLong) {
        [self.detailWebView.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML;" completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
            if (error || isEmptyString(result)) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:self.detailModel.article.groupModel.groupID forKey:@"value"];
                [TTTrackerWrapper category:@"article"
                              event:@"detail_load"
                              label:@"loading"
                               dict:dict];
            }
        }];
    }
}

- (void)tt_sendDetailDeallocTrack:(BOOL)fromBackButton
{
    if (fromBackButton) {
        wrapperTrackEvent(@"detail", @"back_button");
    }
    else {
        wrapperTrackEvent(@"detail", @"back_gesture");
    }
}


- (void)tt_trackGalleryWithTag:(NSString *)tag
                      label:(NSString *)label
               appendExtkey:(NSString *)key
             appendExtValue:(NSNumber *)extValue
{
    Article *currentArticle = self.detailModel.article;
    NSMutableDictionary *extDict = [NSMutableDictionary dictionary];
    [extDict setValue:currentArticle.groupModel.itemID forKey:@"item_id"];
    if (!isEmptyString(key)) {
        [extDict setValue:extValue forKey:key];
    }
    wrapperTrackEventWithCustomKeys(tag, label, currentArticle.groupModel.groupID, nil, extDict);
}


- (void)tt_trackTitleBarAdWithTag:(NSString *)tag
                            label:(NSString *)label
                            value:(NSString *)value
                         extraDic:(NSDictionary *)dic
{
    wrapperTrackEventWithCustomKeys(tag, label, value, nil, dic);
}

@end

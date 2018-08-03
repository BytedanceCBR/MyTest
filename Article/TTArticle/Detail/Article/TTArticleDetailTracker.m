//
//  TTArticleDetailTracker.m
//  Article
//
//  Created by muhuai on 2017/7/30.
//
//

#import "TTArticleDetailTracker.h"
#import "TTAdSiteWebPreloadManager.h"
#import "SSWebViewContainer.h"
#import "NewsDetailLogicManager.h"
#import "Article+TTADComputedProperties.h"

#import "TTAdManager.h"
#import <AKWebViewBundlePlugin/SSWebViewUtil.h>
#import <TTServiceKit/TTServiceCenter.h>
#import <TTAdModule/TTAdManagerProtocol.h>
#import <TTImpression/SSImpressionManager.h>
#import <TTBaseLib/JSONAdditions.h>
#import <TTTracker/TTTrackerProxy.h>
#import "ExploreOrderedData+TTAd.h"


@interface TTArticleDetailTracker ()

@property(nonatomic, assign) NSTimeInterval loadTime;
@property(nonatomic, assign) NSInteger preload_num;
@property(nonatomic, assign) NSInteger match_num;

@end

@implementation TTArticleDetailTracker

- (NSDictionary *)detailTrackerCommonParams
{
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
    [extra setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
    [extra setValue:@(self.detailModel.article.groupModel.aggrType) forKey:@"aggr_type"];
    [extra setValue:self.detailModel.adID forKey:@"ad_id"];
    return [extra copy];
}

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
        _loadState = @"load";
        _loadTime = 0;
        _preload_num = 0;
        _match_num = 0;
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
        self.loadTime = timeInterval;
        [dict setValue:[NSString stringWithFormat:@"%.0f", timeInterval*1000] forKey:@"load_time"];
        [dict setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        [dict setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
        [TTTrackerWrapper eventData:dict];
    }
    [self tt_sendWKUIWebViewLoadDateIfNeed];
}

- (void)tt_sendWKUIWebViewLoadDateIfNeed {
    if (!self.startLoadDate) {
        return;
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.startLoadDate];
    [[TTMonitor shareManager] trackService:self.detailWebView.webView.isWKWebView? @"article_detail_wk_load_time": @"article_detail_ui_load_time" value:@(timeInterval * 1000) extra:nil];
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
        // 添加预加载字段，0表示未预加载，1表示已预加载
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
            [dict setValue:[NSString stringWithFormat:@"%@", [error.userInfo valueForKey:@"NSErrorFailingURLKey"]]  forKey:@"error_url"];
        } else {
            /// 需要减去后台停留时间
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_startLoadDate];
            if (adID.longLongValue > 0 && timeInterval >90) {//超过90秒 当90秒处理
                timeInterval = 90;
            }
            self.loadTime = timeInterval;
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
        //添加三方广告落地页预加载打点字段
        if (!isEmptyString(adID.stringValue)) {
            
            if ([TTAdManageInstance preloadWebRes_isFirstEnterPageAdid:adID.stringValue]) {
                [dict setValue:@"1" forKey:@"first_open"];
            }
            else{
                [dict setValue:@"0" forKey:@"first_open"];
            }
            
            if ([TTAdManageInstance preloadWebRes_hasPreloadResource:adID.stringValue] == YES) {
                [dict setValue:@"ad_wap_stat" forKey:@"label"];
                [dict setValue:adID.stringValue forKey:@"value"];
                [dict setValue:@"1" forKey:@"is_ad_event"];
                NSInteger preload_total = [TTAdManageInstance preloadWebRes_preloadTotalAdID:adID.stringValue];
                if (preload_total > 0) {
                    NSInteger rate = 0;
                    NSInteger preload_num = [TTAdManageInstance preloadWebRes_preloadNumInWebView];
                    self.preload_num = preload_num;
                    rate =100 * preload_num / preload_total;
                    NSMutableDictionary *ad_extra_data = [NSMutableDictionary dictionary];
                    [ad_extra_data setValue:@(rate<100?rate:100) forKey:@"load_percent"];
                    
                    CGFloat match_rate = 0;
                    NSInteger match_num = [TTAdManageInstance preloadWebRes_matchNumInWebView];
                    self.match_num = match_num;
                    match_rate = 100* match_num / preload_total;
                    [ad_extra_data setValue:@(match_rate>100? 100:match_rate) forKey:@"match_percent"];
                    
                    [dict setValue:[ad_extra_data tt_JSONRepresentation] forKey:@"ad_extra_data"];
                    [dict setValue:@1 forKey:@"preload"];
                    [TTAdManageInstance preloadWebRes_finishCaptureThePage];
                }
            }
        }
        [TTTrackerWrapper eventData:dict];
        // 这里要把这个变成空的，下次如果看到时间是空的，则不重新发送统计。
        [self tt_resetStartLoadDate];
    }
}



- (void)tt_sendDomCompleteEventTrack
{
    if (![SSCommonLogic isWebDomCompleteEnable]) {
        return;
    }
    if ([TTDeviceHelper OSVersionNumber] < 9) {
        return;
    }
    if (self.detailModel.adID.longLongValue > 0) {
        NSString* timeStr = nil;
        @try {
            timeStr = [self.detailWebView.webView stringByEvaluatingJavaScriptFromString:@"performance.timing.domComplete - performance.timing.navigationStart" completionHandler:nil];
        } @catch (NSException *exception) {
            NSLog(@"performance.timing.domComplete--exception:%@",exception.description);
        } @finally {
            
        }
        if (isEmptyString(timeStr)) {
            timeStr = @"90000";
        }
        
        NSTimeInterval timeInterval = timeStr.longLongValue;
        if (timeStr.longLongValue < 0 || timeStr.longLongValue >90000) {
            timeInterval = 90000;
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"dom_complete_time" forKey:@"tag"];
        [dict setValue:@"ad_wap_stat" forKey:@"label"];
        [dict setValue:self.detailModel.adID.stringValue forKey:@"value"];
        [dict setValue:self.detailModel.adLogExtra forKey:@"log_extra"];
        [dict setValue:@"wap_stat" forKey:@"category"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
        [dict setValue:@(connectionType) forKey:@"nt"];
        NSMutableDictionary* extraDict = [NSMutableDictionary dictionary];
        [extraDict setValue:@(timeInterval) forKey:@"dom_complete_time"];
        [dict setValue:[extraDict tt_JSONRepresentation] forKey:@"ad_extra_data"];
        [TTTrackerWrapper eventData:dict];
    }
}

- (void)tt_sendLandingPageEventTrack
{
    NSString* timeStr = nil;
    @try {
        timeStr = [self.detailWebView.webView stringByEvaluatingJavaScriptFromString:@"performance.timing.domComplete - performance.timing.navigationStart" completionHandler:nil];
    } @catch (NSException *exception) {
        NSLog(@"performance.timing.domComplete--exception:%@",exception.description);
    } @finally {
        
    }
    if (isEmptyString(timeStr)) {
        timeStr = @"90000";
    }
    
    NSTimeInterval timeInterval = timeStr.longLongValue;
    if (timeStr.longLongValue < 0 || timeStr.longLongValue >90000) {
        timeInterval = 90000;
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"wap_stat" forKey:@"tag"];
    [dict setValue:@"landing_page" forKey:@"label"];
    [dict setValue:self.detailModel.adID.stringValue forKey:@"value"];
    [dict setValue:self.detailModel.adLogExtra forKey:@"log_extra"];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:@(connectionType) forKey:@"nt"];
    
    NSMutableDictionary* ad_extra_data = [NSMutableDictionary dictionary];
    [ad_extra_data setValue:@(timeInterval) forKey:@"dom_complete_time"];
    [ad_extra_data setValue:self.loadState forKey:@"load_status"];

    if ([[TTAdSiteWebPreloadManager sharedManager].preloadURLSet containsObject:_detailModel.article.articleURLString]) {
        [ad_extra_data setValue:@1 forKey:@"preload"];
    } else {
        [ad_extra_data setValue:@0 forKey:@"preload"];
    }
    
    if (self.startLoadDate) {
        timeInterval = [[NSDate date] timeIntervalSinceDate:self.startLoadDate];
    } else {
        timeInterval = self.loadTime;
    }
    [ad_extra_data setValue:[NSString stringWithFormat:@"%.0f", timeInterval*1000] forKey:@"load_time"];

    NSInteger preload_total = [TTAdManageInstance preloadWebRes_preloadTotalAdID:self.detailModel.adID.stringValue];
    if (preload_total > 0) {
        NSInteger rate = 0;
        NSInteger preload_num = [TTAdManageInstance preloadWebRes_preloadNumInWebView];
        if (self.preload_num || self.match_num) {
            preload_num = self.preload_num;
        }
        rate =100 * preload_num / preload_total;
        [ad_extra_data setValue:@(rate<100?rate:100) forKey:@"load_percent"];
        
        CGFloat match_rate = 0;
        NSInteger match_num = [TTAdManageInstance preloadWebRes_matchNumInWebView];
        if (self.preload_num || self.match_num) {
            match_num = self.match_num;
        }
        match_rate = 100* match_num / preload_total;
        [ad_extra_data setValue:@(match_rate>100? 100:match_rate) forKey:@"match_percent"];
        [ad_extra_data setValue:@1 forKey:@"preload"];
        [TTAdManageInstance preloadWebRes_finishCaptureThePage];
    }

    [dict setValue:[ad_extra_data tt_JSONRepresentation] forKey:@"ad_extra_data"];
    [TTTrackerWrapper eventData:dict];
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

- (void)tt_sendJumpOutAppEventTrack
{
    NSNumber *adID = self.detailModel.adID;
    if (adID.longLongValue == 0) {
        return;
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"wap_stat" forKey:@"category"];
    [dict setValue:@"jump_out_app" forKey:@"tag"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    [dict setValue:adID forKey:@"value"];
    
    if (!isEmptyString(self.detailModel.orderedData.log_extra)) {
        [dict setValue:self.detailModel.orderedData.log_extra forKey:@"log_extra"];
    }
    else if (!isEmptyString(self.detailModel.adLogExtra)) {
        [dict setValue:self.detailModel.adLogExtra forKey:@"log_extra"];
    }
    else {
        [dict setValue:@"" forKey:@"log_extra"];
    }
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:@(connectionType) forKey:@"nt"];
    
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
        
        //LOGD(@"%@", impressionGroup);
        [[SSImpressionManager shareInstance] addImpressionGroupFromDictionary:impressionGroup];
    }
}

@end

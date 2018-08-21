//
//  TTVFeedCellAction.m
//  Article
//
//  Created by panxiang on 2017/4/26.
//
//

#import "TTVFeedCellAction.h"
#import "TTVFeedCellSelectContext.h"
#import "TTVFeedListItem.h"
#import "SSADEventTracker.h"
#import "TTAdImpressionTracker.h"
#import "TTVFeedCellEndDisplayContext.h"
#import "TTVFeedCellForRowContext.h"
#import "TTVFeedListCell.h"
#import "SSADActionManager.h"
#import "PBModelHeader.h"
#import "TTVFeedItem+Extension.h"
#import "TTAdManager.h"
#import "TTTrackerProxy.h"
#import "TTADEventTrackerEntity.h"

@implementation TTVFeedCellAction

- (TTVFeedListCell *)listCellWithItem:(TTVFeedListItem *)item
{
    if ([item.cell isKindOfClass:[TTVFeedListCell class]]) {
        return (TTVFeedListCell *)item.cell;
    }
    return nil;
}

- (void)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    [[self listCellWithItem:item] didSelectWithContext:context];
    [TTVFeedCellDefaultSelectHandler didSelectItem:item context:context];

}

- (NSDictionary *)adExtraDataWithItem:(TTVFeedListItem *)item {
    NSMutableDictionary *extraData = [NSMutableDictionary dictionary];
    NSMutableDictionary *status = [NSMutableDictionary dictionary];
    if ([item isKindOfClass:[TTVFeedListItem class]]) {
        if (item.comefrom == TTVFromOptionPullUp ) {
            status[@"source"] = @2;
            status[@"first_in_cache"] = @(item.isFirstCached ? 1 : 0);
        } else if (item.comefrom == TTVFromOptionPullDown ) {
            status[@"source"] = @0;
            status[@"first_in_cache"] = @(1);
        } else {
            status[@"source"] = @1;
            status[@"first_in_cache"] = @0;
        }
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:status options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        extraData[@"ad_extra_data"] = json;
        return extraData;
    }
    return nil;
}

- (void)willDisplayItem:(TTVFeedListItem *)item context:(TTVFeedCellWillDisplayContext *)context
{
    [[self listCellWithItem:item] willDisplayWithContext:context];
    NSString *adID = item.originData.article.adId;
    NSString *logExtra = item.originData.article.logExtra;
    if (!isEmptyString(adID)) {
        [[SSADEventTracker sharedManager] willShowAD:adID scene:TTADShowRefreshScene];
        if ([SSCommonLogic videoVisibleEnabled] &&
            [item.cell conformsToProtocol:@protocol(TTVAutoPlayingCell)]) {
            [[TTAdImpressionTracker sharedImpressionTracker] track:adID visible:item.cell.frame scrollView:item.cell.tableView movieCell:(id<TTVAutoPlayingCell>)item.cell];
        } else {
            [[TTAdImpressionTracker sharedImpressionTracker] track:adID visible:item.cell.frame scrollView:item.cell.tableView];
        }
        
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        if ([self adExtraDataWithItem:item]) {
            [extra addEntriesFromDictionary:[self adExtraDataWithItem:item]];
        }
        // 标记show类型
        TTADEventTrackerEntity *entity = [TTADEventTrackerEntity entityWithData:item.originData item:item];
        entity.showScene = TTADShowRefreshScene;
        [[SSADEventTracker sharedManager] trackEventWithEntity:entity label:@"show" eventName:@"embeded_ad" extra:extra duration:0];
    }
}

- (void)endDisplayCell:(TTVFeedListCell *)cell context:(TTVFeedCellEndDisplayContext *)context
{
    [cell endDisplayWithContext:context];
    [TTVFeedEndDisplayHandler defaultADShowOverWithEntity:[TTADEventTrackerEntity entityWithData:cell.item.originData] context:context];
}

- (void)cellForRowItem:(TTVFeedListItem *)item context:(TTVFeedCellForRowContext *)context
{
    [[self listCellWithItem:item] cellForRowContext:context];
}
@end

@implementation TTVFeedCellAdAppAction

- (void)openAppAdTrackerWithItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    if (![item isKindOfClass:[TTVFeedListItem class]]) {
        return;
    }
    TTVFeedListCell *cell = (TTVFeedListCell *)item.cell;
    if (![cell isKindOfClass:[TTVFeedListCell class]]) {
        return;
    }
    TTVVideoArticle *article = item.originData.article;
    NSString *adid = isEmptyString(article.adId) ? nil : [NSString stringWithFormat:@"%@", article.adId];

    TTADEventTrackerEntity *trackerEntity = [TTADEventTrackerEntity entityWithData:item.originData];
    NSMutableDictionary *adExtra = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString *trackInfo = [[TTAdImpressionTracker sharedImpressionTracker] endTrack:adid];
    [adExtra setValue:trackInfo forKey:@"ad_extra_data"];
    NSTimeInterval duration = [[SSADEventTracker sharedManager] durationForAdThisTime:adid];
    [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"show_over" eventName:@"embeded_ad" extra:adExtra duration:duration];
}

- (void)willDisplayItem:(TTVFeedListItem *)item context:(TTVFeedCellWillDisplayContext *)context
{
    [super willDisplayItem:item context:context];
    if (context.isDisplayView) {
        [[SSADEventTracker sharedManager] trackEventWithEntity:[TTADEventTrackerEntity entityWithData:item.originData] label:@"card_show" eventName:@"feed_download_ad" extra:nil];
    }
}

- (void)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
//    [self openAppAdTrackerWithItem:item context:context];
//    [[SSADActionManager sharedManager] openAppWithParameter:[TTVOpenAppParameter parameterWithFeedItem:item.originData]];

    if (item.originData.cellType == 10) {
        
        NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:1];
        [extrData setValue:[TTTouchContext format2JSON:[item.lastTouchContext touchInfo]] forKey:@"ad_extra_data"];
        //只有下载广告需要extra(groupid)为1
        [extrData setValue:@"1" forKey:@"ext_value"];
        [extrData setValue:@"1" forKey:@"has_v3"];
        [[self class] trackRealTime:item extraData:extrData];
        [[SSADEventTracker sharedManager] trackEventWithEntity:[TTADEventTrackerEntity entityWithData:item.originData item:item] label:@"click" eventName:@"embeded_ad" extra:extrData duration:0];
        
        [[SSADActionManager sharedManager] openAppWithParameter:[TTVOpenAppParameter parameterWithFeedItem:item.originData]];
        [self openAppAdTrackerWithItem:item context:context];
        
    }
    else
    {
        [[SSADEventTracker sharedManager] trackEventWithEntity:[TTADEventTrackerEntity entityWithData:item.originData] label:@"detail_show" eventName:@"embeded_ad" extra:nil];
        [super didSelectItem:item context:context];
    }
//    item.ttv_command.showAlert = YES;
//    [item.ttv_command executeAction];
}

+ (void)trackRealTime:(TTVFeedListItem *)feedListItem extraData:(NSDictionary *)extraData
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:feedListItem.article.adId forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:feedListItem.article.logExtra forKey:@"log_extra"];
    [params setValue:@"1" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [params addEntriesFromDictionary:[feedListItem realTimeAdExtraData:@"embeded_ad" label:@"click" extraData:extraData]];
    [TTTracker eventV3:@"realtime_click" params:params];
}

@end

@implementation TTVFeedCellAdPhoneAction

- (void)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    [super didSelectItem:item context:context];
}

- (void)willDisplayItem:(TTVFeedListItem *)item context:(TTVFeedCellWillDisplayContext *)context
{
    [super willDisplayItem:item context:context];
    if (context.isDisplayView) {
        [[SSADEventTracker sharedManager] trackEventWithEntity:[TTADEventTrackerEntity entityWithData:item.originData] label:@"card_show" eventName:@"feed_call" extra:nil];
    }
}

@end


@implementation TTVFeedCellAdWebAction
- (void)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    [super didSelectItem:item context:context];
}


- (void)willDisplayItem:(TTVFeedListItem *)item context:(TTVFeedCellWillDisplayContext *)context
{
    [super willDisplayItem:item context:context];
    if (context.isDisplayView) {
        [[SSADEventTracker sharedManager] trackEventWithEntity:[TTADEventTrackerEntity entityWithData:item.originData] label:@"card_show" eventName:@"feed_call" extra:nil];
    }
}

@end

@implementation TTVFeedCellAdFormAction
- (void)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    [super didSelectItem:item context:context];
}

- (void)willDisplayItem:(TTVFeedListItem *)item context:(TTVFeedCellWillDisplayContext *)context
{
    [super willDisplayItem:item context:context];
    if (context.isDisplayView) {
        [[SSADEventTracker sharedManager] trackEventWithEntity:[TTADEventTrackerEntity entityWithData:item.originData] label:@"card_show" eventName:@"feed_form" extra:nil];
    }
}
@end

@implementation TTVFeedCellAdCounselAction

- (void)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    [super didSelectItem:item context:context];
}

- (void)willDisplayItem:(TTVFeedListItem *)item context:(TTVFeedCellWillDisplayContext *)context
{
    [super willDisplayItem:item context:context];
    if (context.isDisplayView) {
        [[SSADEventTracker sharedManager] trackEventWithEntity:[TTADEventTrackerEntity entityWithData:item.originData] label:@"card_show" eventName:@"feed_counsel" extra:nil];
    }
}
@end


@implementation TTVFeedCellAdNormalAction
- (void)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    [super didSelectItem:item context:context];
}

@end


@implementation TTVFeedCellVideoAction
- (void)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    [super didSelectItem:item context:context];
}
@end

@implementation TTVFeedCellWebAction

- (void)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    [super didSelectItem:item context:context];
}
@end



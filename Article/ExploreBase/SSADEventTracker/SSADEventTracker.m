//
//  SSADEventTracker.m
//  Article
//
//  Created by Zhang Leonardo on 13-11-4.
//
//

#import "SSADEventTracker.h"

#import "Article.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOrderedData+TTAd.h"
#import "PBModelCategory.h"
#import "TTAdFeedModel.h"
#import "TTGroupModel.h"
#import "TTURLTracker.h"
#import <Foundation/Foundation.h>
#import <TTBaseLib/JSONAdditions.h>
#import <TTTracker/TTTrackerProxy.h>
#import "TTADTrackEventLinkModel.h"
#import "TTVFeedListItem.h"
#import "TTADEventTrackerEntity.h"

@interface SSADEventTracker()
@property(nonatomic, strong)NSMutableDictionary * adCellDict;
//用来记录show与showover的配对关系
@property(nonatomic, strong)NSMutableDictionary * adCellSceneDict;
@end

static SSADEventTracker * sharedManager;

@implementation SSADEventTracker

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.adCellDict = [[NSMutableDictionary alloc] init];
        self.adCellSceneDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SSADEventTracker alloc] init];
    });
    return sharedManager;
}

- (void) trackEventWithOrderedData:(ExploreOrderedData *) orderedData
                             label:(NSString *) label
                         eventName:(NSString *) eventName {
    [self trackEventWithOrderedData:orderedData label:label eventName:eventName extra:nil duration:0 clickTrackUrl:YES];
}

- (void) trackEventWithOrderedData:(ExploreOrderedData *) orderedData
                             label:(NSString *) label
                         eventName:(NSString *) eventName
                      clickTrackUrl:(BOOL)showTrackUrl
{
    [self trackEventWithOrderedData:orderedData label:label eventName:eventName extra:nil duration:0 clickTrackUrl:showTrackUrl];
}

- (void) trackEventWithOrderedData:(ExploreOrderedData *) orderedData
                             label:(NSString *) label
                         eventName:(NSString *) eventName
                             extra:(NSString *) extra
                      clickTrackUrl:(BOOL)showTrackUrl
{
    NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:1];
    [extrData setValue:extra forKey:@"ext_value"];
    [self trackEventWithOrderedData:orderedData label:label eventName:eventName extra:extrData duration:0 clickTrackUrl:showTrackUrl];
}

- (void) trackEventWithOrderedData:(ExploreOrderedData *) orderedData
                             label:(NSString *) label
                         eventName:(NSString *) eventName
                             extra:(NSDictionary *) extra
                          duration:(NSTimeInterval)duration
{
    [self trackEventWithOrderedData:orderedData label:label eventName:eventName extra:extra duration:duration clickTrackUrl:YES];
}

- (void) trackEventWithOrderedData:(ExploreOrderedData *) orderedData
                             label:(NSString *) label
                         eventName:(NSString *) eventName
                             extra:(NSDictionary *) extra
                          duration:(NSTimeInterval)duration
                      clickTrackUrl:(BOOL)showTrackUrl
{
    NSParameterAssert(label != nil);
    NSParameterAssert(eventName != nil);
    NSParameterAssert(orderedData != nil);
    
    if (isEmptyString(label) || isEmptyString(eventName) || !orderedData) {
        return;
    }
    
    if ([label isEqualToString:@"show_over"] && duration <= 0.00) {
        return;
    }
    
    // 所有feed_call的不重复发送track url事件，否则会和embeded的重复了。
    BOOL sendTrackEvent = !([eventName isEqualToString:@"feed_call"]);
    
    const NSArray * clicks = @[@"ad_click",@"click", @"click_card",@"click_landingpage",@"click_call",@"click_start",@"click_button"];
    BOOL showThisLabel = [clicks containsObject:label] || ([label isEqualToString:@"detail_show"] && [eventName isEqualToString:@"detail_landingpage"]);

    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:orderedData.ad_id logExtra:orderedData.log_extra];
    if (sendTrackEvent && showThisLabel && showTrackUrl) {
        if (!SSIsEmptyArray(orderedData.adClickTrackURLs)) {
            ttTrackURLsModel(orderedData.adClickTrackURLs, trackModel);
        } else if (orderedData.raw_ad) {
            TTAdFeedModel *raw_ad = orderedData.raw_ad;
            [SSADEventTracker sendTrackURLs:raw_ad.click_track_url_list with:raw_ad];
        }
    }
    
    const NSArray * shows = @[@"show"];
    if (sendTrackEvent && [shows containsObject:label]) {
        if (!SSIsEmptyArray(orderedData.adTrackURLs)) {
            ttTrackURLsModel(orderedData.adTrackURLs, trackModel);
        } else if (orderedData.raw_ad) {
            TTAdFeedModel *raw_ad = orderedData.raw_ad;
            [SSADEventTracker sendTrackURLs:raw_ad.track_url_list with:raw_ad];
        }
    }
    
    TTInstallNetworkConnection nt = [TTTrackerProxy sharedProxy].connectionType;
    NSMutableDictionary *events = [NSMutableDictionary dictionary];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:eventName forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    [events setValue:@(nt) forKey:@"nt"];
    
    [events setValue:orderedData.ad_id forKey:@"value"];
    [events setValue:orderedData.log_extra forKey:@"log_extra"];
    
        
    if (!SSIsEmptyDictionary(extra)) {
        [events addEntriesFromDictionary:extra];
    }
    
    if (orderedData && orderedData.adEventLinkModel) {
        NSDictionary *adEventLinkExtra = [orderedData.adEventLinkModel adEventLinkDictionaryWithTag:eventName WithLabel:label];
        
        if (!SSIsEmptyDictionary(adEventLinkExtra)) {
            
            NSMutableDictionary *adEventExtra = [NSMutableDictionary dictionary];
            
            if (!SSIsEmptyDictionary(extra)) {
                
                id extra_data_obj = [extra objectForKey:@"ad_extra_data"];
                if (extra_data_obj && [extra_data_obj isKindOfClass:[NSString class]]) {
                    
                    NSString *extra_data_jsonString = (NSString *)extra_data_obj;
                    if (!isEmptyString(extra_data_jsonString)) {
                        NSError *error = nil;
                        NSDictionary *extra_data_JsonDic = [NSString tt_objectWithJSONString:extra_data_jsonString error:&error];
                        
                        if (!SSIsEmptyDictionary(extra_data_JsonDic)) {
                            [adEventExtra addEntriesFromDictionary:extra_data_JsonDic];
                        }
                    }
                }
            }
            
            [adEventExtra addEntriesFromDictionary:adEventLinkExtra];
            
            if (!SSIsEmptyDictionary(adEventExtra)) {
                
                NSString *finalEventExtraString = [adEventExtra tt_JSONRepresentation];
                if (!isEmptyString(finalEventExtraString)) {
                    [events setValue:finalEventExtraString forKey:@"ad_extra_data"];
                }
            }
        }
    }
    
    if (orderedData.article) {
        [events setValue:[@(orderedData.article.uniqueID) stringValue] forKey:@"group_id"];
        [events setValue:orderedData.article.itemID forKey:@"item_id"];
        [events setValue:orderedData.article.aggrType forKey:@"aggr_type"];
    }
    
    if (duration > 0) {
        [events setValue:[NSNumber numberWithLong:duration*1000] forKey:@"duration"];
    }
    [TTTrackerWrapper eventData:events];
}

- (void)trackShowWithOrderedData:(ExploreOrderedData *) orderedData
                           extra:(NSDictionary *) extra
                           scene:(TTADShowScene)  scene
{
    if (![orderedData isKindOfClass:[ExploreOrderedData class]]) {
        return;
    }
    
    NSString *ad_id = orderedData.ad_id;
    
    [[SSADEventTracker sharedManager] willShowAD:ad_id scene:scene];
    
    [self trackEventWithOrderedData:orderedData label:@"show" eventName:@"embeded_ad" extra:extra duration:0 scene:scene];
}

- (void)trackShowOverWithOrderedData:(ExploreOrderedData *) orderedData
                               extra:(NSDictionary *) extra
                               scene:(TTADShowScene)  scene
                            duration:(NSTimeInterval) duration
{
    [self trackEventWithOrderedData:orderedData label:@"show_over" eventName:@"embeded_ad" extra:extra duration:duration scene:scene];
}

- (void)trackShowOverWithOrderedData:(ExploreOrderedData *) orderedData
                               extra:(NSDictionary *) extra
{
    if (![orderedData isKindOfClass:[ExploreOrderedData class]]) {
        return;
    }
    NSString *ad_id = orderedData.ad_id;
    
    NSTimeInterval duration = [self durationForAdThisTime:ad_id];
    TTADShowScene scene = [self showOverSceneForAd:ad_id];
    [self trackShowOverWithOrderedData:orderedData extra:extra scene:scene duration:duration];
}

- (void)trackEventWithOrderedData:(ExploreOrderedData *) orderedData
                            label:(NSString *) label
                        eventName:(NSString *) eventName
                            extra:(NSDictionary *) extra
                        duration:(NSTimeInterval)duration
                           scene:(TTADShowScene) scene
{
    NSParameterAssert(label != nil);
    NSParameterAssert(eventName != nil);
    NSParameterAssert(orderedData != nil);
    
    if (isEmptyString(label) || isEmptyString(eventName) || !orderedData) {
        return;
    }
    
    if ([label isEqualToString:@"show_over"] && duration <= 0.00) {
        return;
    }
    
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:orderedData.ad_id logExtra:orderedData.log_extra];
    
    if ([label isEqualToString:@"show"]) {
        if (!SSIsEmptyArray(orderedData.adTrackURLs)) {
            ttTrackURLsModel(orderedData.adTrackURLs, trackModel);
        } else if (orderedData.raw_ad) {
            TTAdFeedModel *raw_ad = orderedData.raw_ad;
            [SSADEventTracker sendTrackURLs:raw_ad.track_url_list with:raw_ad];
        }
    }
    
    TTInstallNetworkConnection nt = [TTTrackerProxy sharedProxy].connectionType;
    NSMutableDictionary *events = [NSMutableDictionary dictionary];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:eventName forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    [events setValue:@(nt) forKey:@"nt"];
    [events setValue:orderedData.ad_id forKey:@"value"];
    [events setValue:orderedData.log_extra forKey:@"log_extra"];
    
    
    if (!SSIsEmptyDictionary(extra)) {
        [events addEntriesFromDictionary:extra];
    }
    
    if (orderedData && orderedData.adEventLinkModel) {
        NSDictionary *adEventLinkExtra = [orderedData.adEventLinkModel adEventLinkDictionaryWithTag:eventName WithLabel:label];
        
        if (!SSIsEmptyDictionary(adEventLinkExtra)) {
            
            NSMutableDictionary *adEventExtra = [NSMutableDictionary dictionary];
            
            if (!SSIsEmptyDictionary(extra)) {
                
                id extra_data_obj = [extra objectForKey:@"ad_extra_data"];
                if (extra_data_obj && [extra_data_obj isKindOfClass:[NSString class]]) {
                    
                    NSString *extra_data_jsonString = (NSString *)extra_data_obj;
                    if (!isEmptyString(extra_data_jsonString)) {
                        NSError *error = nil;
                        NSDictionary *extra_data_JsonDic = [NSString tt_objectWithJSONString:extra_data_jsonString error:&error];
                        
                        if (!SSIsEmptyDictionary(extra_data_JsonDic)) {
                            [adEventExtra addEntriesFromDictionary:extra_data_JsonDic];
                        }
                    }
                }
            }
            
            [adEventExtra addEntriesFromDictionary:adEventLinkExtra];
            
            if (!SSIsEmptyDictionary(adEventExtra)) {
                
                NSString *finalEventExtraString = [adEventExtra tt_JSONRepresentation];
                if (!isEmptyString(finalEventExtraString)) {
                    [events setValue:finalEventExtraString forKey:@"ad_extra_data"];
                }
            }
        }
    }
    
    if (orderedData.article) {
        [events setValue:[@(orderedData.article.uniqueID) stringValue] forKey:@"group_id"];
        [events setValue:orderedData.article.itemID forKey:@"item_id"];
        [events setValue:orderedData.article.aggrType forKey:@"aggr_type"];
    }
    
    if (duration > 0) {
        [events setValue:[NSNumber numberWithLong:duration*1000] forKey:@"duration"];
    }
    
    NSString *scene_label = @"refresh";
    switch (scene) {
        case TTADShowReturnScene:
            scene_label = @"return";
            break;
        case TTADShowChangechannelScene:
            scene_label = @"change_channel";
            break;
        default:
            break;
    }
    [events setValue:scene_label forKey:@"scene"];

    [TTTrackerWrapper eventData:events];
}

- (void)sendADWithOrderedData:(ExploreOrderedData *)orderedData event:(NSString *)event label:(NSString *)label extra:(NSDictionary *)extra
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:event forKey:@"tag"];
    [dict setValue:label forKey:@"label"];
    
    [dict setValue:orderedData.ad_id forKey:@"value"];
    [dict setValue:orderedData.log_extra forKey:@"log_extra"];
    
    if (orderedData.article.groupModel.groupID) {
        [dict setValue:orderedData.article.groupModel.groupID forKey:@"ext_value"];
    } else {
        [dict setValue:@"0" forKey:@"ext_value"];
    }
    TTInstallNetworkConnection nt = [TTTrackerProxy sharedProxy].connectionType;
    [dict setValue:@(nt) forKey:@"nt"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    
    if (extra) {
        [dict addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:dict];
}

#pragma mark - show_over duration

- (void)willShowAD:(NSString *)adID scene:(TTADShowScene)scene{
    NSDate *dateWhenStartShow = [NSDate date];
    if (adID) {
        [self.adCellDict setValue:dateWhenStartShow forKey:adID];
        if (scene != TTADShowRefreshScene) {
            [self.adCellSceneDict setValue:@(scene) forKey:adID];
        }
    }
}

- (NSTimeInterval)durationForAdThisTime:(NSString *)adID{
    NSString *key = [NSString stringWithFormat:@"%@", adID];
    NSDate * date = [self.adCellDict valueForKey:key];
    if (date) {
        @synchronized (self) {
            [self.adCellDict removeObjectForKey:key];
        }
        return [[NSDate date] timeIntervalSinceDate:date];
    }
    return 0;
}

- (TTADShowScene)showOverSceneForAd:(NSString *)adID
{
    TTADShowScene scene = TTADShowRefreshScene;
    NSString *key = [NSString stringWithFormat:@"%@", adID];
    scene = [[self.adCellSceneDict valueForKey:key] integerValue];
    if (scene) {
        @synchronized (self) {
            [self.adCellSceneDict removeObjectForKey:key];
        }
        return scene;
    }
    
    return scene;
}

- (void)clearAllAdShow {
    @synchronized (self) {
        if (self.adCellDict.count>0) {
         [self.adCellDict removeAllObjects];
        }
        
        if (self.adCellSceneDict.count > 0) {
            [self.adCellSceneDict removeAllObjects];
        }
    }
}

- (void)trackEventWithEntity:(TTADEventTrackerEntity *)entity
                       label:(NSString *)label
                   eventName:(NSString *)eventName {
    [self trackEventWithEntity:entity label:label eventName:eventName extra:nil];
}

- (void)trackEventWithEntity:(TTADEventTrackerEntity *)entity
                             label:(NSString *)label
                         eventName:(NSString *)eventName
                     clickTrackUrl:(BOOL)showTrackUrl
{
    [self trackEventWithEntity:entity label:label eventName:eventName extra:nil duration:0 clickTrackUrl:showTrackUrl];
}

- (void)trackEventWithEntity:(TTADEventTrackerEntity *)entity
                       label:(NSString *)label
                   eventName:(NSString *)eventName
                       extra:(NSString *)extra
               clickTrackUrl:(BOOL)showTrackUrl
{
    NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:1];
    [extrData setValue:extra forKey:@"ext_value"];
    [self trackEventWithEntity:entity label:label eventName:eventName extra:extrData duration:0 clickTrackUrl:showTrackUrl];
}

- (void)trackEventWithEntity:(TTADEventTrackerEntity *)entity
                       label:(NSString *)label
                   eventName:(NSString *)eventName
                       extra:(NSString *)extra {
    NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:1];
    [extrData setValue:extra forKey:@"ext_value"];
    [self trackEventWithEntity:entity label:label eventName:eventName extra:extrData duration:0 clickTrackUrl:YES];
}

- (void)trackEventWithEntity:(TTADEventTrackerEntity *)entity
                       label:(NSString *)label
                   eventName:(NSString *)eventName
                       extra:(NSDictionary *)extra
                    duration:(NSTimeInterval)duration
{
    [self trackEventWithEntity:entity label:label eventName:eventName extra:extra duration:duration clickTrackUrl:YES];
}

- (void)trackEventWithEntity:(TTADEventTrackerEntity *)entity
                       label:(NSString *)label
                   eventName:(NSString *)eventName
                       extra:(NSDictionary *)extra
                    duration:(NSTimeInterval)duration
               clickTrackUrl:(BOOL)showTrackUrl
{
    NSParameterAssert(label != nil);
    NSParameterAssert(eventName != nil);
    
    if (isEmptyString(label) || isEmptyString(eventName) || !entity) {
        return;
    }
    
    if ([label isEqualToString:@"show_over"] && duration<=0.00) {
        return;
    }
    NSArray *adClickTrackURLs = entity.adClickTrackURLs;
    NSArray *adTrackURLs = entity.adTrackURLs;
    NSString *adID = entity.ad_id;
    NSString *logExtra = entity.log_extra;
    NSString *itemID = entity.itemID;
    NSNumber *aggrType = entity.aggrType;
    NSString *uniqueid = entity.uniqueid;
    
    // 所有feed_call的不重复发送track url事件，否则会和embeded的重复了。
    BOOL sendTrackEvent = !([eventName isEqualToString:@"feed_call"]);
    
    const NSArray * clicks = @[@"ad_click",@"click", @"click_card",@"click_landingpage",@"click_call",@"click_start",@"click_button"];

    BOOL showThisLabel = [clicks containsObject:label] || ([label isEqualToString:@"detail_show"] && [eventName isEqualToString:@"detail_landingpage"]);
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:adID logExtra:logExtra];
    if (sendTrackEvent && showThisLabel && showTrackUrl) {
        if (!SSIsEmptyArray(adClickTrackURLs)) {
            ttTrackURLsModel(adClickTrackURLs, trackModel);
        }
    }
    
    const NSArray * shows = @[@"show"];
    if (sendTrackEvent && [shows containsObject:label]) {
        TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:adID logExtra:logExtra];
        if (!SSIsEmptyArray(adTrackURLs)) {
            ttTrackURLsModel(adTrackURLs, trackModel);
        }
    }
    if (!isEmptyString(adID)) {
        TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
        NSMutableDictionary * events = [@{@"category":@"umeng", @"tag":eventName, @"label":label, @"nt":@(connectionType), @"is_ad_event":@"1"} mutableCopy];
        [events setValue:adID forKey:@"value"];
        if (!SSIsEmptyDictionary(extra)) {
            [events addEntriesFromDictionary:extra];
        }
        TTADTrackEventLinkModel *linkModel = entity.feedListItem.adEventLinkModel;
        if (linkModel) {
            NSDictionary *adEventLinkExtra = [linkModel adEventLinkDictionaryWithTag:eventName WithLabel:label];
            
            if (!SSIsEmptyDictionary(adEventLinkExtra)) {
                
                NSMutableDictionary *adEventExtra = [[NSMutableDictionary alloc] init];
                
                if (!SSIsEmptyDictionary(extra)) {
                    
                    id extra_data_obj = [extra objectForKey:@"ad_extra_data"];
                    if (extra_data_obj && [extra_data_obj isKindOfClass:[NSString class]]) {
                        
                        NSString *extra_data_jsonString = (NSString *)extra_data_obj;
                        if (!isEmptyString(extra_data_jsonString)) {
                            NSError *error = nil;
                            NSDictionary *extra_data_JsonDic = [NSString tt_objectWithJSONString:extra_data_jsonString error:&error];
                            
                            if (!SSIsEmptyDictionary(extra_data_JsonDic)) {
                                [adEventExtra addEntriesFromDictionary:extra_data_JsonDic];
                            }
                            
                        }
                    }
                }
                
                [adEventExtra addEntriesFromDictionary:adEventLinkExtra];
                
                if (!SSIsEmptyDictionary(adEventExtra)) {
                    
                    NSString *finalEventExtraString = [adEventExtra tt_JSONRepresentation];
                    if (!isEmptyString(finalEventExtraString)) {
                        [events setValue:finalEventExtraString forKey:@"ad_extra_data"];
                    }
                }
            }
        }
        
        if (!isEmptyString(uniqueid)) {
            [events setValue:uniqueid forKey:@"group_id"];
            [events setValue:itemID forKey:@"item_id"];
            [events setValue:aggrType forKey:@"aggr_type"];
        }
        if (!isEmptyString(logExtra)) {
            [events setValue:logExtra forKey:@"log_extra"];
        } else {
            [events setValue:@"" forKey:@"log_extra"];
        }
        
        if (duration>0) {
            [events setValue:[NSNumber numberWithLong:duration*1000] forKey:@"duration"];
        } else {
            if ([label isEqualToString:@"show_over"]) {
                LOGD(@"stop heer");
            }
        }
        
        if (([label isEqualToString:@"show"] || [label isEqualToString:@"show_over"]) && [SSCommonLogic showWithScensEnabled]) {
            TTADShowScene scene = TTADShowRefreshScene;
            if ([label isEqualToString:@"show"]) {
                scene = entity.showScene;
            } else if ([label isEqualToString:@"show_over"]) {
                // show_over标签的处理在方法内部做，就不在外部再处理了                
                scene = [self showOverSceneForAd:adID];
            }
            NSString *scene_label = @"refresh";
            switch (scene) {
                case TTADShowReturnScene:
                    scene_label = @"return";
                    break;
                case TTADShowChangechannelScene:
                    scene_label = @"change_channel";
                    break;
                default:
                    break;
            }
            [events setValue:scene_label forKey:@"scene"];
        }
        
        [TTTrackerWrapper eventData:events];
    } else {
        wrapperTrackEventWithOption([TTSandBoxHelper appName], eventName, label, false);
    }
}

+ (void)sendTrackURLs:(NSArray<NSString *> *)urls with:(id<TTAd>) model {
    if (!urls || !model) {
        LOGE(@"此处  ad 打点错误 %s", __PRETTY_FUNCTION__);
        return;
    }
    
    NSParameterAssert([model conformsToProtocol:@protocol(TTAd)]);
    NSParameterAssert([urls isKindOfClass:[NSArray class]]);
    
    if (![model conformsToProtocol:@protocol(TTAd)]) {
        return;
    }
    
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:model.ad_id logExtra:model.log_extra];
    [[TTURLTracker shareURLTracker] trackURLs:urls model:trackModel];
}

+ (void)trackWithModel:(id<TTAd>)model tag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra {
    if (!model) {
        return;
    }
    
    NSParameterAssert([model conformsToProtocol:@protocol(TTAd)]);
    NSParameterAssert(tag != nil);
    NSParameterAssert(label != nil);
    
    if (![model conformsToProtocol:@protocol(TTAd)]) {
        return;
    }
    
    NSMutableDictionary *events = [NSMutableDictionary dictionary];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:tag forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:model.ad_id forKey:@"value"];
    [events setValue:model.log_extra forKey:@"log_extra"];
    
    TTInstallNetworkConnection nt = [TTTrackerProxy sharedProxy].connectionType;
    [events setValue:@(nt) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    
    if (extra) {
        [events addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:events];
}

@end

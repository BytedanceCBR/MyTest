//
//  TTVMidInsertADTracker.m
//  Article
//
//  Created by lijun.thinker on 08/09/2017.
//
//

#import "TTVMidInsertADTracker.h"
#import "TTVMidInsertADModel.h"
#import "TTURLTracker.h"
#import "TTTrackerProxy.h"
#import "JSONAdditions.h"

@implementation TTVMidInsertADTracker

+ (void)sendADEventWithlabel:(NSString *)label
                     adModel:(TTVMidInsertADModel *)adModel
                    duration:(NSTimeInterval)duration
                       extra:(NSDictionary *)extra {
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if ([label isEqualToString:@"click"]) {
        [self p_trackWithURLs:adModel.midInsertADInfoModel.clickTrackURLList adModel:adModel];
    }
    
    if ([label isEqualToString:@"show"]) {
        [self p_trackWithURLs:adModel.midInsertADInfoModel.trackURLList adModel:adModel];
    }
    
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    [dict setValue:@"embeded_ad" forKey:@"tag"];
    [dict setValue:label forKey:@"label"];
    [dict setValue:[adModel.midInsertADInfoModel.adID stringValue] forKey:@"value"];
    [dict setValue:adModel.midInsertADInfoModel.logExtra forKey:@"log_extra"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:@(connectionType) forKey:@"nt"];
    if (duration > 0) {
        dict[@"duration"] = @(duration);
    }
    
    if ([[extra allKeys] count] > 0) {
        [dict addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:dict];
}

+ (void)p_trackWithURLs:(NSArray *)URLs adModel:(TTVMidInsertADModel *)adModel {
    
    if (SSIsEmptyArray(URLs)) {
        
        return ;
    }
    
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:[adModel.midInsertADInfoModel.adID stringValue] logExtra:adModel.midInsertADInfoModel.logExtra];
    ttTrackURLsModel(URLs, trackModel);
}

+ (NSString *)getFromByIsInDetail:(BOOL)isInDetail {
    
    return (isInDetail) ? @"detail_": @"feed_";
}

+ (NSDictionary *)getADExtraDataWithIsPicture:(BOOL)isPicture isDetail:(BOOL)isDetail {
    
    NSMutableDictionary *adExtra = [NSMutableDictionary dictionaryWithCapacity:2];
    NSMutableDictionary *extraData = [NSMutableDictionary dictionaryWithCapacity:2];
    extraData[@"trigger_position"] = [[self getFromByIsInDetail:isDetail] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    if (isPicture) {
        extraData[@"is_picture"] = @1;
    }
    adExtra[@"ad_extra_data"] = [extraData tt_JSONRepresentation];
    return adExtra;
}


+ (void)sendIconADShowEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail {
    
    [self sendADEventWithlabel:@"show" adModel:adModel duration:duration extra:[self getADExtraDataWithIsPicture:YES isDetail:isInDetail]];
}

+ (void)sendIconADShowOverEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail {
    
    NSString *label = @"show_over";
    [self sendADEventWithlabel:label adModel:adModel duration:duration extra:[self getADExtraDataWithIsPicture:NO isDetail:isInDetail]];
}

+ (void)sendIconADClickEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail extra:(NSDictionary *)extra {
    NSMutableDictionary *dict = [@{} mutableCopy];
    [dict addEntriesFromDictionary:extra];
    [dict addEntriesFromDictionary:[self getADExtraDataWithIsPicture:YES isDetail:isInDetail]];
    [self sendADEventWithlabel:@"ad_click" adModel:adModel duration:duration extra:dict];
    [self sendADEventWithlabel:@"click" adModel:adModel duration:duration extra:dict];
}

+ (void)sendMidInsertADPlayOverEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail {
    
    [self p_trackWithURLs:adModel.midInsertADInfoModel.videoInfo.effectivePlayTrackURLList adModel:adModel];
    [self p_trackWithURLs:adModel.midInsertADInfoModel.videoInfo.playOverTrackURLList adModel:adModel];
    
    NSString *label = [[self getFromByIsInDetail:isInDetail] stringByAppendingString:@"over"];
    [self sendADEventWithlabel:label adModel:adModel duration:duration extra:nil];
}

+ (void)sendMidInsertADPlayBreakEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration effective:(BOOL)effective isInDetail:(BOOL)isInDetail {
    
    if (effective) {
        
        [self p_trackWithURLs:adModel.midInsertADInfoModel.videoInfo.effectivePlayTrackURLList adModel:adModel];
    }
    
    NSString *label = [[self getFromByIsInDetail:isInDetail] stringByAppendingString:@"break"];
    [self sendADEventWithlabel:label adModel:adModel duration:duration extra:nil];
}

+ (void)sendMidInsertADClickCloseEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration effective:(BOOL)effective isInDetail:(BOOL)isInDetail {
    
    NSString *label = [[self getFromByIsInDetail:isInDetail] stringByAppendingString:@"close"];
    [self sendADEventWithlabel:label adModel:adModel duration:duration extra:[self getADExtraDataWithIsPicture:NO isDetail:isInDetail]];
}

+ (void)sendMidInsertADClickDetailEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail extra:(NSDictionary *)extra {
    NSMutableDictionary *dict = [@{} mutableCopy];
    [dict addEntriesFromDictionary:extra];
    [dict addEntriesFromDictionary:[self getADExtraDataWithIsPicture:NO isDetail:isInDetail]];
    [self sendADEventWithlabel:@"ad_click" adModel:adModel duration:duration extra:dict];
    [self sendADEventWithlabel:@"click" adModel:adModel duration:duration extra:dict];
}

+ (void)sendMidInsertADClickVideoEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail {
    
    [self sendADEventWithlabel:@"click_screen" adModel:adModel duration:duration extra:[self getADExtraDataWithIsPicture:NO isDetail:isInDetail]];
    [self sendADEventWithlabel:@"click" adModel:adModel duration:duration extra:[self getADExtraDataWithIsPicture:NO isDetail:isInDetail]];
}

+ (void)sendMidInsertADPlayEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail {
    
    NSString *label = [[self getFromByIsInDetail:isInDetail] stringByAppendingString:@"auto_play"];
    [self sendADEventWithlabel:label adModel:adModel duration:duration extra:nil];
    [self p_trackWithURLs:adModel.midInsertADInfoModel.videoInfo.playTrackURLList adModel:adModel];
}

+ (void)sendMidInsertADShowEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail {
    
    [self sendADEventWithlabel:@"show" adModel:adModel duration:duration extra:[self getADExtraDataWithIsPicture:NO isDetail:isInDetail]];
}

+ (void)sendMidInsertADFullScreenEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail {
    
    NSString *label = [[self getFromByIsInDetail:isInDetail] stringByAppendingString:@"fullscreen"];
    [self sendADEventWithlabel:label adModel:adModel duration:duration extra:[self getADExtraDataWithIsPicture:NO isDetail:isInDetail]];
}

+ (void)sendMidInsertADShowOverEventForADModel:(TTVMidInsertADModel *)adModel duration:(NSTimeInterval)duration isInDetail:(BOOL)isInDetail {
    
    NSString *label = @"show_over";
    [self sendADEventWithlabel:label adModel:adModel duration:duration extra:[self getADExtraDataWithIsPicture:NO isDetail:isInDetail]];
}

+ (void)sendRealTimeDownloadWithModel:(TTVMidInsertADModel *)adModel
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:[adModel.midInsertADInfoModel.adID stringValue] forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:adModel.midInsertADInfoModel.logExtra forKey:@"log_extra"];
    [params setValue:@"1" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [TTTracker eventV3:@"realtime_click" params:params];
}

@end

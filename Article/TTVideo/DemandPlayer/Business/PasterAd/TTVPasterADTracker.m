//
//  TTVPasterADTracker.m
//  Article
//
//  Created by Dai Dongpeng on 6/22/16.
//
//

#import "TTVPasterADTracker.h"
#import "TTVPasterADModel.h"
#import "TTURLTracker.h"
#import "TTAVPlayerItemAccessLog.h"
#import "TTTrackerProxy.h"
#import "TTVPlayVideo.h"
#import "JSONAdditions.h"


static NSString *const kEmbededADKey = @"embeded_ad";

@interface TTVPasterADTracker()

@property (nonatomic, strong) NSMutableDictionary *showOverInfo;

@end

@implementation TTVPasterADTracker

- (void)sendADEventWithlabel:(NSString *)label
                       extra:(NSDictionary *)extra
                    duration:(NSInteger)duration
                     isADTag:(BOOL)isADTag
{
    NSString *tag = (isADTag) ? kEmbededADKey: @"back_embeded_ad";

    [self sendADEventWithlabel:label tag:tag extra:extra duration:duration];
}

- (void)sendADEventWithlabel:(NSString *)label
                         tag:(NSString *)tag
                       extra:(NSDictionary *)extra
                    duration:(NSInteger)duration {
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if ([label isEqualToString:@"click"]) {
        
        [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.clickTrackURLList];
    }
    
    [dict setValue:@"umeng" forKey:@"category"];
    
    [dict setValue:@(1) forKey:@"is_ad_event"];
    [dict setValue:tag forKey:@"tag"];
    [dict setValue:label forKey:@"label"];
    [dict setValue:[self.adModel.videoPasterADInfoModel.adID stringValue] forKey:@"value"];
    [dict setValue:self.adModel.videoPasterADInfoModel.logExtra forKey:@"log_extra"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:@(connectionType) forKey:@"nt"];
    
    if (duration > 0) {
        
        if (TTVPasterADStyleVideo == self.adModel.style) {
            [dict setValue:@(self.playVideo.player.context.totalWatchTime) forKey:@"duration"];
        } else {
            
            [dict setValue:@(duration * 1000) forKey:@"duration"];
        }
    }
    
    if ([[extra allKeys] count] > 0) {
        [dict addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:dict];
    
    if ([label isEqualToString:@"show"]) {
        
        self.showOverInfo = [dict mutableCopy];
        self.showOverInfo[@"duration"] = self.adModel.videoPasterADInfoModel.duration;
    }
}

- (void)p_trackWithURLs:(NSArray *)URLs {
    
    if (SSIsEmptyArray(URLs)) {
        
        return ;
    }
    
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:[self.adModel.videoPasterADInfoModel.adID stringValue] logExtra:self.adModel.videoPasterADInfoModel.logExtra];
    ttTrackURLsModel(URLs, trackModel);
}
@end

@implementation TTVPasterADTracker (Convenience)

- (void)sendPlayStartEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail
{
    // play
    if (TTVPasterADStyleVideo == self.adModel.style) {
        NSString *label = [[self getFromByIsInDetail:isInDetail] stringByAppendingString:@"auto_play"];
        [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
        [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.videoInfo.playTrackURLList];
    }
    
    // show
    NSMutableDictionary *adExtra = [[NSMutableDictionary alloc] initWithCapacity:1];
    if ([extra allKeys].count > 0) {
        
        [adExtra addEntriesFromDictionary:extra];
    }
    NSMutableDictionary *extraData = [[NSMutableDictionary alloc] initWithCapacity:1];
    extraData[@"trigger_position"] = [[self getFromByIsInDetail:isInDetail] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    adExtra[@"ad_extra_data"] = [extraData tt_JSONRepresentation];
    [self sendADEventWithlabel:@"show" extra:adExtra duration:duration isADTag:YES];
    [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.trackURLList];
}

- (void)sendClickADEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail
{
    NSString *label = @"click_screen";
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
    
    [self sendADEventWithlabel:@"click" extra:@{@"has_v3": @"1"} duration:duration isADTag:YES];
}

- (void)sendDetailClickButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail
{
    NSString *label = @"ad_click";
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
    [self sendADEventWithlabel:@"click" extra:extra duration:duration isADTag:YES];
}

- (void)sendDownloadClickButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail {
    
    NSString *label = @"click_start";
    
    [self sendADEventWithlabel:label tag:[[self getFromByIsInDetail:isInDetail] stringByAppendingString:@"download_ad"] extra:extra duration:duration];
    [self sendADEventWithlabel:@"click" extra:@{@"has_v3": @"1"} duration:duration isADTag:YES];
}

- (void)sendPlayBreakEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail effectivePlay:(BOOL)effective
{
    if (effective) {
        
        [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.videoInfo.effectivePlayTrackURLList];
    }
    
    NSString *label = [[self getFromByIsInDetail:isInDetail] stringByAppendingString:@"break"];
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}

- (void)sendPlayOverEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail
{
    [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.videoInfo.effectivePlayTrackURLList];
    [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.videoInfo.playOverTrackURLList];
    
    NSString *label = [[self getFromByIsInDetail:isInDetail] stringByAppendingString:@"over"];
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}

- (void)sendSkipEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail effectivePlay:(BOOL)effective
{
    if (effective) {
        
        [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.videoInfo.effectivePlayTrackURLList];
    }
    
    NSString *label = [[self getFromByIsInDetail:isInDetail] stringByAppendingString:@"close"];
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}

- (void)sendFullscreenWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail
{
    NSString *label = [[self getFromByIsInDetail:isInDetail] stringByAppendingString:@"fullscreen"];
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}

- (void)sendRequestDataWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail {
    
    NSString *label = @"ad_resp";
    
    [self sendADEventWithlabel:label extra:nil duration:duration isADTag:NO];
}

- (void)sendResponsErrorWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail {
    
    NSString *label = @"ad_resp_nodata";
    
    [self sendADEventWithlabel:label extra:nil duration:duration isADTag:NO];
}

- (void)sendShowOverWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail {
    if (!(self.showOverInfo.allKeys.count > 0)) {
        
        return ;
    }
    
    if ([self.showOverInfo[@"duration"] isKindOfClass:[NSNumber class]]) {
        
        self.showOverInfo[@"duration"] = @((((NSNumber *)self.showOverInfo[@"duration"]).integerValue - duration) * 1000);
    }
    self.showOverInfo[@"label"] = @"show_over";
    NSMutableDictionary *extraData = [[NSMutableDictionary alloc] initWithCapacity:1];
    extraData[@"trigger_position"] = [[self getFromByIsInDetail:isInDetail] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    self.showOverInfo[@"ad_extra_data"] = [extraData tt_JSONRepresentation];
    
    [TTTrackerWrapper eventData:self.showOverInfo];
}

- (void)sendWithRealTimeDownload
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:[self.adModel.videoPasterADInfoModel.adID stringValue] forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:self.adModel.videoPasterADInfoModel.logExtra forKey:@"log_extra"];
    [params setValue:@"1" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [TTTracker eventV3:@"realtime_click" params:params];
}

- (void)sendClickReplayButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail {
    
    NSString *label = @"replay";
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}

- (NSString *)getFromByIsInDetail:(BOOL)isInDetail
{
    return (isInDetail) ? @"detail_": @"feed_";
}

@end

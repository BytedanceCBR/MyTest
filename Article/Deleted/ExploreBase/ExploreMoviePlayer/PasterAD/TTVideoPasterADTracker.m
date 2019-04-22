//
//  TTVideoPasterADTracker.m
//  Article
//
//  Created by Dai Dongpeng on 6/22/16.
//
//

#import "ExploreMovieView.h"
#import "TTAVPlayerItemAccessLog.h"
#import "TTAdCommonUtil.h"
#import "TTTrackerProxy.h"
#import "TTURLTracker.h"
#import "TTVideoPasterADModel.h"
#import "TTVideoPasterADTracker.h"
//#import "SSURLTracker.h"
#import "JSONAdditions.h"

static NSString *const kEmbededADKey = @"embeded_ad";

@interface TTVideoPasterADTracker()

@property (nonatomic, strong) NSMutableDictionary *showOverInfo;

@end

@implementation TTVideoPasterADTracker

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
        
        if (TTVideoPasterADStyleVideo == self.adModel.style) {
            
            NSUInteger watched = (NSUInteger)([self watchedDuration] * 1000);
            [dict setValue:@(watched) forKey:@"duration"];
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

- (NSTimeInterval)watchedDuration
{
    NSTimeInterval durationWatched = 0;
    if (self.movieView.moviePlayerController.accessLog) {
        for (TTAVPlayerItemAccessLogEvent * event in self.movieView.moviePlayerController.accessLog.events) {
            durationWatched += event.durationWatched;
        }
    }
    return durationWatched;
}

- (void)p_trackWithURLs:(NSArray *)URLs {
    
    if (SSIsEmptyArray(URLs)) {
        
        return ;
    }
    
//    TTAdBaseModel *adBaseModel = [[TTAdBaseModel alloc] init];
//    adBaseModel.ad_id = [self.adModel.videoPasterADInfoModel.adID stringValue];
//    adBaseModel.log_extra = self.adModel.videoPasterADInfoModel.logExtra;
//    
//    [[SSURLTracker shareURLTracker] trackURLs:URLs model:adBaseModel];
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:[self.adModel.videoPasterADInfoModel.adID stringValue] logExtra:self.adModel.videoPasterADInfoModel.logExtra];
    ttTrackURLsModel(URLs, trackModel);
    
}
@end

@implementation TTVideoPasterADTracker (Convenience)

- (void)sendPlayStartEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type
{
    // play
    if (TTVideoPasterADStyleVideo == self.adModel.style) {
        NSString *label = [[self stringForViewType:type] stringByAppendingString:@"auto_play"];
        [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
        [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.videoInfo.playTrackURLList];
    }
    
    // show
    NSMutableDictionary *adExtra = [[NSMutableDictionary alloc] initWithCapacity:1];
    if ([extra allKeys].count > 0) {
        
        [adExtra addEntriesFromDictionary:extra];
    }
    NSMutableDictionary *extraData = [[NSMutableDictionary alloc] initWithCapacity:1];
    extraData[@"trigger_position"] = [[self stringForViewType:type] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    adExtra[@"ad_extra_data"] = [extraData tt_JSONRepresentation];
    [self sendADEventWithlabel:@"show" extra:adExtra duration:duration isADTag:YES];
    [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.trackURLList];
}

- (void)sendClickADEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type
{
    if (!(self.adModel.videoPasterADInfoModel.appleID)) {
        
        [self sendADEventWithlabel:@"detail_show" tag:[[self stringForViewType:type] stringByAppendingString:@"download_ad"] extra:extra duration:duration];
    }
    
    NSString *label = @"click_screen";
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];

    
    [self sendADEventWithlabel:@"click" extra:extra duration:duration isADTag:YES];
}

- (void)sendDetailClickButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type
{
    NSString *label = @"ad_click";
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
    [self sendADEventWithlabel:@"click" extra:extra duration:duration isADTag:YES];
}

- (void)sendDownloadClickButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type {
    
    NSString *label = @"click_start";
    
    [self sendADEventWithlabel:label tag:[[self stringForViewType:type] stringByAppendingString:@"download_ad"] extra:extra duration:duration];
    [self sendADEventWithlabel:@"click" extra:extra duration:duration isADTag:YES];
}

- (void)sendPlayBreakEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type effectivePlay:(BOOL)effective
{
    if (effective) {
        
        [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.videoInfo.effectivePlayTrackURLList];
    }
    
    NSString *label = [[self stringForViewType:type] stringByAppendingString:@"break"];
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}

- (void)sendPlayOverEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type
{
    [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.videoInfo.effectivePlayTrackURLList];
    [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.videoInfo.playOverTrackURLList];
    
    NSString *label = [[self stringForViewType:type] stringByAppendingString:@"over"];
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}

- (void)sendSkipEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type effectivePlay:(BOOL)effective
{
    if (effective) {
        
        [self p_trackWithURLs:self.adModel.videoPasterADInfoModel.videoInfo.effectivePlayTrackURLList];
    }
    
    NSString *label = [[self stringForViewType:type] stringByAppendingString:@"close"];
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}

- (void)sendFullscreenWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type
{
    NSString *label = [[self stringForViewType:type] stringByAppendingString:@"fullscreen"];
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}

- (void)sendPauseWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type
{
    NSString *label = [[self stringForViewType:type] stringByAppendingString:@"pause"];
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}
- (void)sendContinueWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type
{
    NSString *label = [[self stringForViewType:type] stringByAppendingString:@"continue"];
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}

- (void)sendRequestDataWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type {
    
    NSString *label = @"ad_resp";
    
    [self sendADEventWithlabel:label extra:nil duration:duration isADTag:NO];
}

- (void)sendResponsErrorWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type {
    
    NSString *label = @"ad_resp_nodata";
    
    [self sendADEventWithlabel:label extra:nil duration:duration isADTag:NO];
}

- (void)sendShowOverWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type {
    if (!(self.showOverInfo.allKeys.count > 0)) {
        
        return ;
    }
    
    if ([self.showOverInfo[@"duration"] isKindOfClass:[NSNumber class]]) {
        
        self.showOverInfo[@"duration"] = @((((NSNumber *)self.showOverInfo[@"duration"]).integerValue - duration) * 1000);
    }
    self.showOverInfo[@"label"] = @"show_over";
    NSMutableDictionary *extraData = [[NSMutableDictionary alloc] initWithCapacity:1];
    extraData[@"trigger_position"] = [[self stringForViewType:type] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    self.showOverInfo[@"ad_extra_data"] = [extraData tt_JSONRepresentation];
    
    [TTTrackerWrapper eventData:self.showOverInfo];
}

- (void)sendClickReplayButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type {
    
    NSString *label = @"replay";
    [self sendADEventWithlabel:label extra:extra duration:duration isADTag:YES];
}

//
- (NSString *)stringForViewType:(ExploreMovieViewType)viewType
{
    NSString *type = @"feed_";
    
    if (viewType == ExploreMovieViewTypeList) {
        type = @"feed_";
    } else if (viewType == ExploreMovieViewTypeDetail) {
        type = @"detail_";
    }
    
    return type;
}

@end

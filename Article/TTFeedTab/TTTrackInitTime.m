//
//  TTTrackInitTime.m
//  Article
//
//  Created by panxiang on 15/11/4.
//
//

#import "TTTrackInitTime.h"
#import "TTMonitor.h"
#import "TTMonitorConfiguration.h"
#import "NSObject+TTAdditions.h"
#import "TTSettingsManager.h"
#import "TTStartupTasksTracker.h"

@implementation TTTrackInitTime
+ (void)trackInitTime
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [TTTrackInitTime doTrackInitTime];
    });
}

+ (void)doTrackInitTime
{
    //切换UI不在调用,app启动只发送一次.
    CGFloat load = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kTrackTime_load"] longLongValue];
    CGFloat start = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kTrackTime_didFinishLaunch_start"] longLongValue];
    CGFloat end = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kTrackTime_didFinishLaunch_end"]longLongValue];
    
    CGFloat appear = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kTrackTime_mainList_viewAppear"]longLongValue];
    CGFloat appearwithoutAd = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kTrackTime_noad_mainList_viewAppear"]longLongValue];
    
    CGFloat newsAppearWithAd = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kTrackTime_mainList_newsAppear_withAd"] longLongValue];
    CGFloat newsAppearWithoutAd = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kTrackTime_mainList_newsAppear_withoutAd"] longLongValue];

    double pre_init_time = [NSObject machTimeToSecs:start - load];
    double init_time = [NSObject machTimeToSecs:end - start];
    double show = [NSObject machTimeToSecs:appear - end];
    double total = pre_init_time + init_time + show;
    double showWithoutAd = 0;
    if (appearwithoutAd>0) {
        showWithoutAd = [NSObject machTimeToSecs:appearwithoutAd - end];
    }
    double news_appear_time_with_ad = 0;
    if (newsAppearWithAd > 0) {
        news_appear_time_with_ad = [NSObject machTimeToSecs:newsAppearWithAd - start];
    }
    double news_appear_time_without_ad = 0;
    if (newsAppearWithoutAd > 0) {
        news_appear_time_without_ad = [NSObject machTimeToSecs:newsAppearWithoutAd - start];
    }
    
    NSNumber *totalTime = [NSNumber numberWithDouble:total * 1000];
    NSNumber *preTime = [NSNumber numberWithDouble:pre_init_time * 1000];
    NSNumber *initTime = [NSNumber numberWithDouble:init_time * 1000];
    NSNumber *showTime = [NSNumber numberWithDouble:show * 1000];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:@"launch_stat" forKey:@"tag"];
    [dict setValue:@"finish" forKey:@"label"];
    [dict setValue:totalTime forKey:@"value"];
    [dict setValue:preTime forKey:@"pre_init_time"];
    [dict setValue:initTime forKey:@"init_time"];
    [dict setValue:showTime forKey:@"render_time"];
    [TTTrackerWrapper eventData:dict];
    NSLog(@"pre_init_time %f,init_time %f ,show %f,total %F,news_appear %f %f",pre_init_time,init_time,show,total,news_appear_time_with_ad, news_appear_time_without_ad);
        [[TTMonitor shareManager] event:@"monitor_appStartTime"  //启动总耗时
                                  label:@"duration"
                               duration:total*1000
                          needAggregate:NO];
        [[TTMonitor shareManager] event:@"monitor_launchInitTime"//launch耗时
                                  label:@"duration"
                               duration:init_time*1000
                          needAggregate:NO];
        [[TTMonitor shareManager] event:@"monitor_launchShowTime"//主视图耗时
                                  label:@"duration"
                               duration:show*1000
                          needAggregate:NO];
    if (showWithoutAd > 0) {
        [[TTMonitor shareManager] event:@"monitor_launchWithoutAdTime"//主视图耗时
                                  label:@"duration"
                               duration:showWithoutAd*1000
                          needAggregate:NO];
    }
    if (news_appear_time_without_ad > 0) {
        [[TTMonitor shareManager] event:@"monitor_launchNewsAppearWithoutAdTime"
                                  label:@"duration"
                               duration:news_appear_time_without_ad*1000
                          needAggregate:NO];
    }
    if (news_appear_time_with_ad > 0) {
        [[TTMonitor shareManager] event:@"monitor_launchNewsAppearWithAdTime"
                                  label:@"duration"
                               duration:news_appear_time_with_ad*1000
                          needAggregate:NO];
    }
    NSMutableDictionary *launchDic = [[NSMutableDictionary alloc] init];
    [launchDic setValue:@(total*1000) forKey:@"launch"];
    if (news_appear_time_without_ad > 0) {
        [launchDic setValue:@(news_appear_time_without_ad*1000) forKey:@"appear_without_ad"];
    }
    if (news_appear_time_with_ad > 0) {
        [launchDic setValue:@(news_appear_time_with_ad*1000) forKey:@"appear_with_ad"];
    }
    int statusNum = 1;
    //未开启为0
    if (![[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue]) {
        statusNum = 0;
    }
    [launchDic setValue:@(statusNum) forKey:@"status"];

    [[TTMonitor shareManager] trackService:@"tt_launch_time" value:launchDic extra:nil];
    [[TTStartupTasksTracker sharedTracker] sendTasksIntervalsWithStatus:statusNum];

}
@end

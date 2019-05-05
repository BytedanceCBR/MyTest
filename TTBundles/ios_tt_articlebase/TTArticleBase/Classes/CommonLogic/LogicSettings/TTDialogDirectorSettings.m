//
//  TTDialogDirectorSettings.m
//  Article
//
//  Created by zuopengliu on 7/11/2017.
//

#import "TTDialogDirectorSettings.h"
#import <TTSettingsManager.h>
#import <TTDialogDirector/TTDialogDirector.h>



@implementation TTDialogDirectorSettings

+ (void)load
{
    [self readConfigsFromSettings];
}

+ (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDialogConfDidReceiveNote:) name:TTSettingsManagerDidUpdateNotification object:nil];
}

+ (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTSettingsManagerDidUpdateNotification object:nil];
}

+ (void)updateDialogConfDidReceiveNote:(NSNotification *)note
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadDialogDirectorConf];
    });
}

+ (void)readConfigsFromSettings
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self addNotification];
        [self loadDialogDirectorConf];
    });
}

+ (void)loadDialogDirectorConf
{
    NSDictionary *conf = [[TTSettingsManager sharedManager] settingForKey:@"tt_dialog_director" defaultValue:@{} freeze:NO];
    
    if (conf && [conf isKindOfClass:[NSDictionary class]] && [conf count] > 0) {
        NSNumber *enabledNumber = [conf valueForKey:@"enabled"];
        NSNumber *hookEnabledNumber = [conf valueForKey:@"system_hook_enabled"];
        NSNumber *reqMaxStayTime = [conf valueForKey:@"max_stay_time_of_req"];
        if (enabledNumber && [enabledNumber respondsToSelector:@selector(boolValue)]) {
            [TTDialogDirector setEnabled:[enabledNumber boolValue]];
        }
        if (hookEnabledNumber && [hookEnabledNumber respondsToSelector:@selector(boolValue)]) {
            [TTDialogDirector setHookEnabled:[hookEnabledNumber boolValue]];
        }
        if (reqMaxStayTime && [reqMaxStayTime respondsToSelector:@selector(doubleValue)]) {
            [TTDialogDirector setDlgMaxStayTime:[reqMaxStayTime doubleValue]];
        }
    }
}

@end

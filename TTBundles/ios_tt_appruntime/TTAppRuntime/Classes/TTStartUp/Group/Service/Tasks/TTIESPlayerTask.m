//
//  TTIESPlayerTask.m
//  Article
//
//  Created by 邱鑫玥 on 2018/1/7.
//

#import "TTIESPlayerTask.h"
#import "TTHTSVideoConfiguration.h"
#import "TTLaunchDefine.h"
#import "NSDictionary+TTAdditions.h"

DEC_TASK("TTIESPlayerTask",FHTaskTypeService,TASK_PRIORITY_HIGH+14);

@implementation TTIESPlayerTask

- (NSString *)taskIdentifier
{
    return @"IESPlayer";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    BOOL startupOptimizeClose =  [[self fhSettings] tt_boolValueForKey:@"f_startup_optimize_close"];
    if(startupOptimizeClose){
        [TTHTSVideoConfiguration setup];
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [TTHTSVideoConfiguration setup];
        });
    }
}

- (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

@end

//
//  TTIESPlayerTask.m
//  Article
//
//  Created by 邱鑫玥 on 2018/1/7.
//

#import "TTIESPlayerTask.h"
#import "TTHTSVideoConfiguration.h"
#import "TTLaunchDefine.h"

DEC_TASK("TTIESPlayerTask",FHTaskTypeService,TASK_PRIORITY_HIGH+14);

@implementation TTIESPlayerTask

- (NSString *)taskIdentifier
{
    return @"IESPlayer";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TTHTSVideoConfiguration setup];
    });
}

@end

//
//  TTSetUseBDWebImageTask.m
//  Article
//
//  Created by yxj on 07/02/2018.
//

#import "TTSetUseBDWebImageTask.h"
#import "TTSettingsManager.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "TTLaunchDefine.h"

DEC_TASK("TTSetUseBDWebImageTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+9);

@implementation TTSetUseBDWebImageTask

- (NSString *)taskIdentifier {
    return @"TTSetUseBDWebImageTask";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method
- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [SDWebImageAdapter setUseBDWebImage:[self isBDWebImageEnable]];
}

- (BOOL)isBDWebImageEnable {
    NSNumber *value = @NO;
    return value.boolValue;
}



@end

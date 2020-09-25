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
#import <BDWebImage/BDWebImageRequest.h>
#import <BDWebImage/BDWebImageManager.h>
#import <Bytedancebase/BDPlatformSDKUtils.h>

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
    
    [BDWebImageRequest setIsMonitorLargeImage:YES];
    [BDWebImageManager sharedManager].bizTagURLFilterBlock = ^NSString * _Nullable(NSURL * _Nullable url) {
        if ([url isKindOfClass:[NSURL class]] && url.query.length > 0) {
            NSDictionary *dic = [url bdplatform_queryDictionary];
            return [dic valueForKey:@"from"];
        }
        return nil;
    };
}

- (BOOL)isBDWebImageEnable {
    NSNumber *value = @NO;
    return value.boolValue;
}



@end

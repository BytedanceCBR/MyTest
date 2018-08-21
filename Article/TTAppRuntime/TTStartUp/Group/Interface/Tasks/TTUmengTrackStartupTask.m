//
//  TTUmengTrackStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTUmengTrackStartupTask.h"
#import "NewsBaseDelegate.h"

@implementation TTUmengTrackStartupTask

- (NSString *)taskIdentifier {
    return @"UmengTrack";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    // for umeng track
    NSString * appKey = [SharedAppDelegate umengTrackAppkey];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString * deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * mac = [TTDeviceHelper MACAddress];
    NSString * idfa = [TTDeviceHelper idfaString];
    NSString * idfv = [TTDeviceHelper idfvString];
    
    NSString * urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@&idfa=%@&idfv=%@", appKey,deviceName,mac,idfa,idfv];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [TTStringHelper URLWithURLString:urlString]] delegate:nil];
    });
}

@end

//
//  TTIESPlayerTask.m
//  Article
//
//  Created by 邱鑫玥 on 2018/1/7.
//

#import "TTIESPlayerTask.h"
#import "TTHTSVideoConfiguration.h"

@implementation TTIESPlayerTask

- (NSString *)taskIdentifier
{
    return @"IESPlayer";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    
    [TTHTSVideoConfiguration setup];
}

@end

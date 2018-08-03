//
//  TTFantasySDKRegister.m
//  Article
//
//  Created by 王霖 on 2017/12/29.
//

#import "TTFantasySDKRegister.h"
#import "TTToutiaoFantasyManager.h"

@implementation TTFantasySDKRegister

- (NSString *)taskIdentifier {
    return @"TTFFantasySDKRegisterTaskIdentifier";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[TTToutiaoFantasyManager sharedManager] fantasyConfig];
}

@end

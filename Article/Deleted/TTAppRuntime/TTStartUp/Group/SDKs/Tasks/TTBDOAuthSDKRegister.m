//
//  TTBDOAuthSDKRegister.m
//  Article
//
//  Created by zuopengliu on 27/9/2017.
//

#import "TTBDOAuthSDKRegister.h"
#import "TTPlatformOAuthSDKManager.h"



@implementation TTBDOAuthSDKRegister

- (NSString *)taskIdentifier
{
    return @"BytedanceOAuthSDKRegister";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    
    [[self class] bindToutiaoOAuthConf];
}

+ (void)bindToutiaoOAuthConf
{
    [TTPlatformOAuthSDKManager startConfiguration];
}

@end

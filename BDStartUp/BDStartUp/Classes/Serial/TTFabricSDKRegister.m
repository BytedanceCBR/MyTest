//
//  TTFabricSDKRegister.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTFabricSDKRegister.h"
#import "BDStartUpManager.h"

#if BD_Fabric
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "TTSandBoxHelper.h"
#endif

@implementation TTFabricSDKRegister

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
#if BD_Fabric
    if (!CrashlyticsKit.delegate) {
        [CrashlyticsKit setDelegate:self];
        
        [Fabric with:@[CrashlyticsKit]];
        NSString *APIKey = [BDStartUpManager sharedInstance].APIKey;
        NSAssert(APIKey.length, @"APIKey不能为空！");

        [Crashlytics startWithAPIKey:APIKey];
        
    }
#endif
}

@end


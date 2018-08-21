//
//  TSVPushLaunchManager.m
//  Article
//
//  Created by dingjinlu on 2017/12/18.
//

#import "TSVPushLaunchManager.h"
#import "TTArticleTabBarController.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTRoute.h"
#import "NewsBaseDelegate.h"
#import "TTTabBarManager.h"

@implementation TSVPushLaunchManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static TSVPushLaunchManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[TSVPushLaunchManager alloc] init];
    });
    return manager;
}

- (void)launchIntoTSVTabIfNeedWithURL:(NSString *)openURL
{
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:[NSURL URLWithString:openURL]];
    if ([paramObj.host isEqualToString:@"awemevideo"]){
        int tsvTabDefault = [[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_push_launch_config" defaultValue:@(0) freeze:YES] intValue];
         if (tsvTabDefault == 1 && [SharedAppDelegate isColdLaunch]) {
            [SharedAppDelegate setIsColdLaunch:NO];
            self.shouldAutoRefresh = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:TTArticleTabBarControllerChangeSelectedIndexNotification object:nil userInfo:@{@"tag":kTTTabHTSTabKey}];
        }
    }
}

@end

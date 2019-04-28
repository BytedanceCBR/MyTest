//
//  TTSetHookTask.m
//  Article
//
//  Created by Chen Hong on 2017/6/29.
//
//

#import "TTSetHookTask.h"
#import "CommonURLSetting.h"
#import "TTURLDomainHelper.h"
#import "SSCommonLogic.h"
#import "TTLocationManager.h"
#import "TTArticleCategoryManager.h"

@implementation TTSetHookTask

- (NSString *)taskIdentifier {
    return @"TTSetHookTask";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    
    [self setDomainFromTypeBlock];
    
    [self setCategoryManagerHook];
}

- (void)setDomainFromTypeBlock {
    [[TTURLDomainHelper shareInstance] setDomainFromTypeBlock:^NSString *(TTURLDomainType type) {
        switch (type) {
            case TTURLDomainTypeNormal:
                return [CommonURLSetting baseURL];   //@"i"
                
            case TTURLDomainTypeSecurity:  //@"si"
                return [CommonURLSetting securityURL];
                
            case TTURLDomainTypeSNS:     //@"isub"
                return [CommonURLSetting SNSBaseURL];
                
            case TTURLDomainTypeLog:     //@"log"
                return [CommonURLSetting logBaseURL];
                
            case TTURLDomainTypeChannel: //@"ichannel"
                return [CommonURLSetting channelBaseURL];
                
            case TTURLDomainTypeAppMonitor: //@"mon"
                return [CommonURLSetting monitorBaseURL];
                
            default:
                break;
        }
        return [CommonURLSetting baseURL];   //@"i"
    }];
}

- (void)setCategoryManagerHook {
    [[TTArticleCategoryManager sharedManager] setIARBlock:^BOOL{
        return [SSCommonLogic iar];
    }];
    
    [[TTArticleCategoryManager sharedManager] setCityBlock:^NSString *{
        return [TTLocationManager sharedManager].city;
    }];
    
    [[TTArticleCategoryManager sharedManager] setSysLocationBlock:^NSString *{
        CLLocationCoordinate2D coord = [TTLocationManager sharedManager].placemarkItem.coordinate;
        return [NSString stringWithFormat:@"%f,%f", coord.longitude, coord.latitude];
    }];
}

@end

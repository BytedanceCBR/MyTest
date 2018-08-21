//
//  TTTrackerOpenURLTask.m
//  Article
//
//  Created by fengyadong on 2017/8/4.
//
//

#import "TTTrackerOpenURLTask.h"
#import <TTSandBoxHelper.h>
#import <TTTrackerSessionHandler.h>

@implementation TTTrackerOpenURLTask

- (NSString *)taskIdentifier {
    return @"TTTrackerOpenURL";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[self class] handleLaunchURLForTTTracker:url];
    return NO;
}

+ (void)handleLaunchURLForTTTracker:(NSURL *)url {
    if (!url) {
        return;
    }
    
    NSURLComponents *com = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSString *ownURLScheme = [TTSandBoxHelper appOwnURL];
    if ([com.scheme isEqualToString:ownURLScheme]) {
        
        BOOL isFromWidgetClickItem = com.query && [com.query rangeOfString:@"click_today_extenstion"].location != NSNotFound;
        BOOL isFRomWidgetClickMore = com.query && [com.query rangeOfString:@"today_extenstion_more"].location != NSNotFound;
        
        [TTTrackerSessionHandler sharedHandler].launchFrom = (isFromWidgetClickItem || isFRomWidgetClickMore) ? TTTrackerLaunchFromWidget : TTTrackerLaunchFromExternal; //schema为snssdkxxx的url除了来自today_extension的，其它都归在external下
        
    }else if ([self.allSupportedURLSchemes containsObject:com.scheme]) {
        
        [TTTrackerSessionHandler sharedHandler].launchFrom = TTTrackerLaunchFromExternal;
    }
}

+ (NSArray *)allSupportedURLSchemes {
    NSArray <NSDictionary *> *urlTypes = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleURLTypes"];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:urlTypes.count];
    
    [urlTypes enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *schemes = [obj objectForKey:@"CFBundleURLSchemes"];
        [result addObjectsFromArray:schemes];
    }];
    
    return [result copy];
}

@end

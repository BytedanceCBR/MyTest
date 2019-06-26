//
//  TTUGCImageKitchen.m
//  TTUGCFoundation
//
//  Created by song on 2019/1/15.
//

#import "TTUGCImageKitchen.h"
#import <TTMonitor/TTMonitor.h>
#import <objc/runtime.h>
#import <TTGaiaExtension/GAIAEngine+TTBase.h>

@implementation TTUGCImageKitchen
TTRegisterKitchenFunction() {
    TTKitchenRegisterBlock(^{
        TTKConfigArray(kTTKUGCImageCacheOptimizeHosts, @"TTUGCImage缓存优化host", @[@"pstatp.com", @"bytecdn.cn"]);
    });
}

+ (BOOL)matchImageCacheOptimizeHost:(NSString *)aHost {
    if (![aHost isKindOfClass:[NSString class]] || aHost.length == 0) {
        return NO;
    }
    
    NSArray *hosts = [TTKitchen getArray:kTTKUGCImageCacheOptimizeHosts];
    BOOL match = NO;
    for (NSString *host in hosts) {
        if ([aHost containsString:host]) {
            match = YES;
            break;
        }
    }
 
    if (!match && ![[self unmatchHosts] containsObject:aHost]) { // 只报1次
        [[self unmatchHosts] addObject:aHost];
        [[TTMonitor shareManager] trackService:@"tt_ugc_image_cache_unmatch_host" status:1 extra:@{@"host" : aHost}];
    }
    
    return match;
}

+ (NSMutableArray *)unmatchHosts {
    NSMutableArray *unmatchHosts = objc_getAssociatedObject(self, @selector(unmatchHosts));
    if (unmatchHosts == nil) {
        unmatchHosts = [NSMutableArray new];
        objc_setAssociatedObject(self, @selector(unmatchHosts), unmatchHosts, OBJC_ASSOCIATION_RETAIN);
    }
    return unmatchHosts;
}
@end


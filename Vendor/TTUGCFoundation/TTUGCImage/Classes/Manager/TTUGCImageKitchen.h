//
//  TTUGCImageKitchen.h
//  TTUGCFoundation
//
//  Created by song on 2019/1/15.
//

#import <Foundation/Foundation.h>
#import <TTKitchen/TTKitchen.h> 
#import <TTKitchen/TTCommonKitchenConfig.h>

static NSString * kTTKUGCImageCacheOptimizeHosts = @"tt_ugc_base_config.image_cache_optimize_hosts"; // TTUGCImage缓存优化host

@interface TTUGCImageKitchen : NSObject

+ (BOOL)matchImageCacheOptimizeHost:(NSString *)aHost;

@end

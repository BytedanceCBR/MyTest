//
//  TTProfileShareService.m
//  Article
//
//  Created by liuzuopeng on 8/30/16.
//
//

#import "TTProfileShareService.h"
#import <objc/runtime.h>
#import <BDWebImage/SDWebImageAdapter.h>
#import "TTStringHelper.h"



NSMutableDictionary *gShareObjectDict;
@implementation TTProfileShareService
+ (void)setShareObject:(NSDictionary *)data forUID:(NSString *)uid {
    uid = uid ? : [data valueForKey:@"user_id"];
    if (uid && [uid isKindOfClass:[NSNumber class]]) uid = [((NSNumber *)uid) stringValue];
    if (!uid) return;
    
    if (!gShareObjectDict) {
        gShareObjectDict = [NSMutableDictionary dictionary];
    }
    [gShareObjectDict setValue:data forKey:uid];
    
    if ([data valueForKey:@"avatar_url"]) {
        // 图片预下载
        [[SDWebImageAdapter sharedAdapter] prefetchURLs:@[[TTStringHelper URLWithURLString:[data valueForKey:@"avatar_url"]]]];
    }
}

+ (NSDictionary *)shareObjectForUID:(NSString *)uid {
    if (uid && [uid isKindOfClass:[NSNumber class]]) uid = [((NSNumber *)uid) stringValue];
    if (!uid) return nil;
    
    return [gShareObjectDict valueForKey:uid];
}

+ (BOOL)isBlockingForUID:(NSString *)uid {
    if (uid && [uid isKindOfClass:[NSNumber class]]) uid = [((NSNumber *)uid) stringValue];
    if (!uid) return YES;
    
    NSMutableDictionary *data = [[gShareObjectDict valueForKey:uid] mutableCopy];
    if (!data) return YES;
    return ![[data valueForKey:@"is_blocking"] boolValue];
}

+ (void)setBlocking:(BOOL)isBlocking forUID:(NSString *)uid {
    if (uid && [uid isKindOfClass:[NSNumber class]]) uid = [((NSNumber *)uid) stringValue];
    if (!uid) return;
    
    NSMutableDictionary *data = [[gShareObjectDict valueForKey:uid] mutableCopy];
    if (!data) return;
    [data setValue:@(isBlocking) forKey:@"is_blocking"];
    [gShareObjectDict setValue:data forKey:uid];
}
@end

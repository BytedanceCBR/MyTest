//
//  TTAdShortVideoModel.m
//  HTSVideoPlay
//
//  Created by carl on 2017/12/8.
//

#import "TTAdShortVideoModel.h"

#import "TTURLTracker.h"
#import "TTTracker.h"
#import "TTTrackerProxy.h"

@implementation TTAdShortVideoModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *mapper = @{
                             @"id" : @"ad_id",
                             @"draw_log_extra" : @"log_extra2",
                             @"appleid" : @"apple_id",
                             @"phone_number" : @"phoneNumber"
                             };
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapper];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    NSSet<NSString *> *required = [[NSSet alloc] initWithObjects:@"ad_id", nil];
    
    if ([required containsObject:propertyName]) {
        return NO;
    }
    return YES;
}

@end

@implementation TTAdShortVideoModel (TTAdTracker)

- (void)sendTrackURLs:(NSArray<NSString *> *) urls {
    if (![urls isKindOfClass:[NSArray class]] || urls.count <= 0) {
        return;
    }
    
    TTURLTrackerModel *trackModel = [[TTURLTrackerModel alloc] initWithAdId:self.ad_id logExtra:self.log_extra];
    ttTrackURLsModel(urls, trackModel);
}

- (void)trackFeedWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra {
    NSCParameterAssert(tag != nil);
    NSCParameterAssert(label != nil);
    
    TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:tag forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:@(nt) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    [events setValue:self.ad_id forKey:@"value"];
    [events setValue:self.log_extra forKey:@"log_extra"];
    if (extra) {
        [events addEntriesFromDictionary:extra];
    }
    [TTTracker eventData:events];
}

- (void)trackDrawWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra {
    NSCParameterAssert(tag != nil);
    NSCParameterAssert(label != nil);
    
    TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:tag forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:@(nt) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    [events setValue:self.ad_id forKey:@"value"];
    [events setValue:self.log_extra2 forKey:@"log_extra"];
    if (extra) {
        [events addEntriesFromDictionary:extra];
    }
    [TTTracker eventData:events];
}

@end

@implementation TTAdShortVideoModel (TTAdFactory)

- (BOOL)isExpire:(NSTimeInterval)beginTimestamp {
    NSTimeInterval nowTimestamp = [[NSDate date] timeIntervalSince1970];
    if ((beginTimestamp + self.expire_seconds) < nowTimestamp) { // 广告过期
        return YES;
    }
    return NO;
}

- (BOOL)ignoreApp {
    if (![self.type isEqualToString:@"app"]) {
        return NO;
    }
    if (!self.hide_if_exists) {
        return NO;
    }
    if (self.open_url.length <= 1) {
        return NO;
    }
    NSURL *openURL = [NSURL URLWithString:self.open_url];
    BOOL canopen = [[UIApplication sharedApplication] canOpenURL:openURL];
    return canopen;
}

- (NSString *)appUrl {
    NSRange seperateRange = [self.open_url rangeOfString:@"://"];
    if (seperateRange.length > 0) {
        return [self.open_url substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];
    } else {
        return self.open_url;
    }
}

- (NSString *)tabUrl {
    NSRange seperateRange = [self.open_url rangeOfString:@"://"];
    if (seperateRange.length > 0) {
        return [self.open_url substringWithRange:NSMakeRange(NSMaxRange(seperateRange), [self.open_url length] - NSMaxRange(seperateRange))];
    }
    return nil;
}

- (NSString *)actionButtonText {
    NSString *buttonText = self.button_text;
    if (self.type != nil && buttonText == nil) {
        NSDictionary *mapper = @{
                                 @"web"     : NSLocalizedString(@"查看详情", @"查看详情"),
                                 @"app"     : NSLocalizedString(@"立即下载", @"立即下载"),
                                 @"counsel" : NSLocalizedString(@"在线咨询", @"在线咨询"),
                                 @"action"  : NSLocalizedString(@"拨打电话", @"拨打电话"),
                                 @"form"    : NSLocalizedString(@"立即预约", @"立即预约")
                                 };
        buttonText = mapper[self.type];
    }
    
    return buttonText;
}

- (NSString *)actionButtonIcon {
    return [NSString stringWithFormat:@"ad_draw_%@", self.type];
}

@end

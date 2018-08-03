//
//  TTAdCanvasModel.m
//  Article
//
//  Created by yin on 2016/12/13.
//
//

#import "TTAdCanvasModel.h"

#define kTTAdCanvasProjectClearInterval 3600*24*30

@implementation TTAdCanvasModel

@end

@implementation TTAdCanvasDataModel

- (void)updateReqeustDate
{
    if (self.request_after.longValue <= 0) {
        self.requestTime = [NSDate date];
        return;
    }
    self.requestTime = [NSDate dateWithTimeIntervalSinceNow:self.request_after.longValue];
}

@end


@implementation TTAdCanvasProjectModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id" : @"ad_ids"}];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (void)updateClearTime
{
    self.clearTime = [NSDate dateWithTimeIntervalSinceNow:kTTAdCanvasProjectClearInterval];
}

@end

@implementation TTAdCanvasResourceModel

- (NSString*)jsonString
{
    if (!SSIsEmptyArray(self.json)) {
        NSString* str = (NSString*)self.json[0];
        if (!isEmptyString(str)) {
            return str;
        }
    }
    return nil;
}

- (NSString*)rootViweColorString
{
    if (!SSIsEmptyArray(self.rootViewColor)) {
        NSString* str = (NSString*)self.rootViewColor[0];
        if (!isEmptyString(str)) {
            return str;
        }
    }
    return nil;
}

- (NSNumber *)animationStyle {
    if (SSIsEmptyArray(self.anim_style)) {
        return nil;
    }
    return self.anim_style.firstObject;
}

- (BOOL)hasCreateFeedData {
    if (SSIsEmptyArray(self.hasCreatedata)) {
        return NO;
    }
    return self.hasCreatedata.firstObject.boolValue;
}

@end

@implementation TTAdCanvasResVideoModel

@end

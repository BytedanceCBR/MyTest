//
//  TTTrackerWrapper.m
//  Article
//
//  Created by fengyadong on 2017/5/11.
//
//

static NSString *const kTTTrackerV3DoubleSendingEnableKey = @"kTTTrackerV3DoubleSendingEnableKey";
static NSString *const kTTTrackerOnlyV3SendingEnableKey = @"kTTTrackerOnlyV3SendingEnableKey";

#import "TTTrackerWrapper.h"

@implementation TTTrackerWrapper

+ (void)event:(nonnull NSString*)event label:(nonnull NSString*)label {
    [BDTrackerProtocol event:event label:label];
}

+ (void)eventData:(nonnull NSDictionary*)event {
    [BDTrackerProtocol eventData:event];
}

+ (void)event:(nonnull NSString*)event
        label:(nonnull NSString*)label
        value:(nullable id)value
     extValue:(nullable id)extValue
    extValue2:(nullable id)extValue2 {
    [BDTrackerProtocol event:event label:label value:value extValue:extValue extValue2:extValue2];
}

+ (void)event:(nonnull NSString*)event
        label:(nonnull NSString*)label
        value:(nullable id)value
     extValue:(nullable id)extValue
    extValue2:(nullable id)extValue2
         dict:(nullable NSDictionary *)aDict {
    [BDTrackerProtocol event:event label:label value:value extValue:extValue extValue2:extValue2 dict:aDict];
}

+ (void)event:(nonnull NSString *)event label:(nonnull NSString *)label json:(nullable NSString *)json {
    [BDTrackerProtocol event:event label:label json:json];
}

+ (void)category:(nonnull NSString *)category event:(nonnull NSString *)event label:(nonnull NSString *)label json:(nullable NSString *)json {
    [BDTrackerProtocol category:category event:event label:label json:json];
}

+ (void)category:(nonnull NSString *)category event:(nonnull NSString *)event label:(nonnull NSString *)label dict:(nullable NSDictionary *)aDict {
    [BDTrackerProtocol category:category event:event label:label dict:aDict];
}

+ (void)category:(nonnull NSString *)category event:(nonnull NSString *)event label:(nonnull NSString *)label dict:(nullable NSDictionary *)aDict json:(nullable NSString *)json {
    [BDTrackerProtocol category:category event:event label:label dict:aDict json:json];
}

+ (void)ttTrackEventWithCustomKeys:(nonnull NSString *)event label:(nonnull NSString *)label value:(nullable NSString *)value source:(nullable NSString *)source extraDic:(nullable NSDictionary *)extraDic {
    [BDTrackerProtocol trackEventWithCustomKeys:event label:label value:value source:source extraDic:extraDic];
}

+ (void)eventV3:(nonnull NSString *)event params:(nullable NSDictionary *)params {
    [self eventV3:event params:params isDoubleSending:NO];
}

+ (void)eventV3:(NSString *_Nonnull)event params:(NSDictionary *_Nullable)params isDoubleSending:(BOOL)isDoubleSending {
    if (isDoubleSending && ![self isV3DoubleSendingEnanle]) {
        return;
    }
    
    if ([self isOnlyV3SendingEnable]) {
        isDoubleSending = NO;
    }
    [BDTrackerProtocol eventV3:event params:params isDoubleSending:isDoubleSending];
}

#pragma mark - Helper

+ (void)setOnlyV3SendingEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTTrackerOnlyV3SendingEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isOnlyV3SendingEnable {
    static BOOL onlyV3SendingEnable = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kTTTrackerOnlyV3SendingEnableKey]) {
            onlyV3SendingEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTTTrackerOnlyV3SendingEnableKey];
        }
    });
    return onlyV3SendingEnable;
}

+ (BOOL)isV3DoubleSendingEnanle {
    static BOOL v3DoubleSendingEnable = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kTTTrackerV3DoubleSendingEnableKey]) {
            v3DoubleSendingEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTTTrackerV3DoubleSendingEnableKey];
        }
    });
    return v3DoubleSendingEnable;
}

+ (void)setV3DoubleSendingEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTTrackerV3DoubleSendingEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

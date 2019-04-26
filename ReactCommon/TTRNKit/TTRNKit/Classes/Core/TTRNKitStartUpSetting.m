//
//  TTRNKitStartUpSetting.m
//  AFgzipRequestSerializer
//
//  Created by renpeng on 2018/7/11.
//

#import "TTRNKitStartUpSetting.h"

@interface TTRNKitStartUpSetting ()

@property(nonatomic, strong) NSMutableDictionary *startUpParameters;

@end

@implementation TTRNKitStartUpSetting
+ (instancetype)sharedSetting {
    static TTRNKitStartUpSetting *s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [[TTRNKitStartUpSetting alloc] init];
        s.startUpParameters = [NSMutableDictionary dictionary];
    });
    return s;
}

+ (id)startUpParameterForKey:(NSString *)key {
    return key.length ? [[TTRNKitStartUpSetting sharedSetting].startUpParameters objectForKey:key] : nil;
}

+ (void)setStartUpParameters:(NSDictionary *)params {
    if (params.allKeys.count) {
        [[TTRNKitStartUpSetting sharedSetting].startUpParameters setValuesForKeysWithDictionary:params];
    }
}

+ (void)setStartUpParameter:(id)value forKey:(NSString *)key {
    if (key.length) {
        if (value) {
            return [[TTRNKitStartUpSetting sharedSetting].startUpParameters setObject:value forKey:key];
        }
        return [[TTRNKitStartUpSetting sharedSetting].startUpParameters removeObjectForKey:key];
    }
}

+ (void)setValue:(id)value forKey:(id)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (value) {
        [defaults setObject:value forKey:key];
    } else {
        [defaults removeObjectForKey:key];
    }
    [defaults synchronize];
}

+ (id)valueForKey:(id)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

@end

//
//  TTTestCommonLogicModule.m
//  Article
//
//  Created by carl on 2017/4/10.
//
//

#import "TTTestCommonLogicModule.h"
#import "ArticleFetchSettingsManager.h"
#import <objc/runtime.h>

@interface TTTestCommonLogicModule ()
@property (nonatomic, strong) NSDictionary *setting;
@end

@interface ArticleFetchSettingsManager (TTTestSwizzle)

@end

@implementation ArticleFetchSettingsManager (TTTestSwizzle)

- (void)empty_dealAppSettingResult:(NSDictionary *)info {
    NSMutableDictionary *mergeSettings = [info mutableCopy];
    NSDictionary *setting = [TTTestCommonLogicModule shareModule].setting;
    if (setting) {
        [mergeSettings addEntriesFromDictionary:setting];
    }
    [self empty_dealAppSettingResult:mergeSettings];
}

@end

@implementation TTTestCommonLogicModule

+ (instancetype)shareModule {
    static dispatch_once_t onceToken;
    static TTTestCommonLogicModule *shareModule = nil;
    dispatch_once(&onceToken, ^{
        shareModule = [TTTestCommonLogicModule new];
    });
    return shareModule;
}

+ (void)swizzle_method {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(dealAppSettingResult:);
        SEL swizzleSelector = @selector(empty_dealAppSettingResult:);
        
        Method originalMethod = class_getInstanceMethod([ArticleFetchSettingsManager class], originalSelector);
        Method swizzleMethod = class_getInstanceMethod([ArticleFetchSettingsManager class], swizzleSelector);
        
        BOOL didAddMethod = class_addMethod([ArticleFetchSettingsManager class], originalSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
        if (didAddMethod) {
            class_replaceMethod([ArticleFetchSettingsManager class], originalSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzleMethod);
        }
    });
}

@end

@implementation TTTestCommonLogicModule (TTConfig)

+ (void)configWith:(NSDictionary *)info {
    if (info == nil) {
        return;
    }
    [TTTestCommonLogicModule shareModule].setting = [info copy];
    [[ArticleFetchSettingsManager shareInstance] dealAppSettingResult:info];
    [TTTestCommonLogicModule swizzle_method];
}

@end

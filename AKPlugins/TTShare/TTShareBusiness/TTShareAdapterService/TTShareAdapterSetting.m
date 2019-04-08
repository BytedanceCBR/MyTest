//
//  TTShareAdapterSetting.m
//  Pods
//
//  Created by 张 延晋 on 3/7/15.
//
//

#import "TTShareAdapterSetting.h"

@interface TTShareAdapterSetting()

@property (nonatomic, copy) NSString * panelClassName;
@property (nonatomic, copy) NSString * forwardSharePanelClassName;

@end

@implementation TTShareAdapterSetting

+ (instancetype)sharedService
{
    static TTShareAdapterSetting *setting;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setting = [[TTShareAdapterSetting alloc] init];
    });
    return setting;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _panelClassName = @"TTActivityPanelController";
        _forwardSharePanelClassName = @"TTForwardSharePanelController";
    }
    return self;
}

- (BOOL)isPadDevice
{
    if ([self.methodSource respondsToSelector:@selector(isPadDevice)]) {
        return [self.methodSource isPadDevice];
    }
    
    return NO;
}

- (BOOL)isZoneVersion
{
    if ([self.methodSource respondsToSelector:@selector(isZoneVersion)]) {
        return [self.methodSource isZoneVersion];
    }
    
    return NO;
}

- (UIViewController *)topmostViewController
{
    if ([self.methodSource respondsToSelector:@selector(topmostViewController)]) {
        return [self.methodSource topmostViewController];
    }
    
    return nil;
}

- (void)activityWillSharedWith:(id<TTActivityProtocol>)activity
{
    if ([self.methodSource respondsToSelector:@selector(activityWillSharedWith:)]) {
        [self.methodSource activityWillSharedWith:activity];
    }
}

- (void)activityHasSharedWith:(id<TTActivityProtocol>)activity error:(NSError *)error desc:(NSString *)desc
{
    if ([self.methodSource respondsToSelector:@selector(activityHasSharedWith:error:desc:)]) {
        [self.methodSource activityHasSharedWith:activity error:error desc:desc];
    }
}

- (void)setPanelClassName:(NSString *)panelClassName {
    if (0 == panelClassName.length) {
        return;
    }
    if ([_panelClassName isEqualToString:panelClassName]) {
        return;
    }
    _panelClassName = panelClassName;
}

- (NSString *)getPanelClassName {
    return _panelClassName;
}

- (void)setForwardSharePanelClassName:(NSString *)forwardSharePanelClassName {
    if (0 == forwardSharePanelClassName.length) {
        return;
    }
    if ([_forwardSharePanelClassName isEqualToString:forwardSharePanelClassName]) {
        return;
    }
    _forwardSharePanelClassName = forwardSharePanelClassName;
}

- (NSString *)getForwardSharePanelClassName {
    return _forwardSharePanelClassName;
}
@end

//
//  TTRNBridgeEngine.m
//  BridgeUnifyDemo
//
//  Created by 李琢鹏 on 2018/11/6.
//  Copyright © 2018年 tt. All rights reserved.
//

#import "TTRNBridgeEngine.h"
#import "TTBridgeCommand.h"
#import "TTBridgeForwarding.h"
#import <TTBridgeAuthManager.h>
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>

@interface TTRNBridgeEngine ()

@property (nonatomic, weak) NSObject *sourceObject;

@end

@implementation TTRNBridgeEngine

- (instancetype)init {
    self = [super init];
    if (self) {
        self.authorization = [TTBridgeAuthManager sharedManager];
    }
    return self;
}

- (RCTUIManager *)UIManager {
    return [self.bridge moduleForClass:[RCTUIManager class]];
}

- (NSMutableArray<NSString *> *)events {
    if (!_events) {
        _events = [NSMutableArray array];
    }
    return _events;
}

- (NSArray<NSString *> *)supportedEvents
{
    return self.events;
}

- (void)calendarEventReminderReceived:(NSNotification *)notification
{
    NSString *eventName = notification.userInfo[@"name"];
    [self sendEventWithName:@"EventReminder" body:@{@"name": eventName}];
}

#pragma mark - RCTBridgeModule

RCT_EXPORT_MODULE(TTBridge)

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(call:(NSString *)methodName params:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    if ([params[@"rootTag"] isKindOfClass:NSNumber.class]) {
        NSNumber *rootTag = params[@"rootTag"];
        self.sourceObject = [[self UIManager] viewForReactTag:rootTag];
    }
    TTBridgeCommand *command = [[TTBridgeCommand alloc] init];
    command.fullName = methodName;
    command.params = [params copy];
    [[TTBridgeForwarding sharedInstance] forwardWithCommand:command engine:self completion:^(TTBridgeMsg msg, NSDictionary *dict) {
        if (callback) {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"code"] = @(msg);
            param[@"data"] = dict ?: @{};
            callback(@[[param copy]]);
        }
    }];
}

RCT_EXPORT_METHOD(on:(NSString *)methodName params:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    NSParameterAssert(methodName);
    if (!methodName) {
        return;
    }
    if ([self.events containsObject:methodName]) {
        return;
    }
    if ([params[@"rootTag"] isKindOfClass:NSNumber.class]) {
        NSNumber *rootTag = params[@"rootTag"];
        self.sourceObject = [[self UIManager] viewForReactTag:rootTag];
    }

    [self.events addObject:methodName];
    [self addListener:methodName];
    TTBridgeCommand *command = [[TTBridgeCommand alloc] init];
    command.fullName = methodName;
    command.params = [params copy];
    command.bridgeType = TTBridgeTypeOn;
    __weak typeof(self) wself = self;
    [[TTBridgeForwarding sharedInstance] forwardWithCommand:command engine:self completion:^(TTBridgeMsg msg, NSDictionary *dict) {
        __strong typeof(wself) self = wself;
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[@"code"] = @(msg);
        param[@"data"] = dict ?: @{};
        [self sendEventWithName:methodName body:[param copy]];
    }];
}

#pragma mark - TTBridgeEngine

- (NSURL *)sourceURL {
    return self.bridge.bundleURL;
}

- (UIViewController *)sourceController {
    if (!_sourceController) {
        return [self.class correctTopViewControllerFor:(UIView *)self.sourceObject];
    }
    return _sourceController;
}

- (TTBridgeRegisterEngineType)engineType {
    return TTBridgeRegisterRN;
}

+ (UIViewController*)correctTopViewControllerFor:(UIResponder*)responder
{
    UIResponder *topResponder = responder;
    for (; topResponder; topResponder = [topResponder nextResponder]) {
        if ([topResponder isKindOfClass:[UIViewController class]]) {
            UIViewController *viewController = (UIViewController *)topResponder;
            while (viewController.parentViewController && viewController.parentViewController != viewController.navigationController && viewController.parentViewController != viewController.tabBarController) {
                viewController = viewController.parentViewController;
            }
            return viewController;
        }
    }
    if(!topResponder)
    {
        topResponder = [[[UIApplication sharedApplication] delegate].window rootViewController];
    }
    
    return (UIViewController*)topResponder;
}

@end

@implementation RCTBridge (TTRNBridgeEngine)

- (TTRNBridgeEngine *)tt_engine {
    return [self moduleForName:@"TTBridge"];
}

@end

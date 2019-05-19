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
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import "TTBridgeAuthorization.h"

@interface TTRNBridgeAuthorization : NSObject<TTBridgeAuthorization>

@end

@implementation TTRNBridgeAuthorization

- (BOOL)engine:(id<TTBridgeEngine>)engine isAuthorizedBridge:(TTBridgeCommand *)command domain:(NSString *)domain {
    return YES;
}

- (void)engine:(id<TTBridgeEngine>)engine isAuthorizedBridge:(TTBridgeCommand *)command domain:(NSString *)domain completion:(void (^)(BOOL))completion {
    if (completion) {
        completion([self engine:engine isAuthorizedBridge:command domain:domain]);
    }
}

- (BOOL)engine:(id<TTBridgeEngine>)engine isAuthorizedMeta:(NSString *)meta domain:(NSString *)domain {
    return [self engine:engine isAuthorizedBridge:nil domain:domain];
}

@end

@interface TTRNBridgeEngine ()

@property (nonatomic, weak) NSObject *sourceObject;

@end

@implementation TTRNBridgeEngine

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
    command.bridgeType = TTBridgeTypeCall;
    NSDate *startDate = [NSDate date];
    [[TTBridgeForwarding sharedInstance] forwardWithCommand:command weakEngine:self completion:^(TTBridgeMsg msg, NSDictionary *dict, void (^resultBlock)(NSString *result)) {
        if (callback) {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"code"] = @(msg);
            param[@"data"] = dict ?: @{};
      
            callback(@[[param copy]]);
            if (resultBlock) {
                resultBlock(nil);
            }
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
    [[TTBridgeForwarding sharedInstance] forwardWithCommand:command weakEngine:self completion:^(TTBridgeMsg msg, NSDictionary *dict, void (^resultBlock)(NSString *result)) {
        __strong typeof(wself) self = wself;
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[@"code"] = @(msg);
        param[@"data"] = dict ?: @{};
        [self sendEventWithName:methodName body:[param copy]];
        if (resultBlock) {
            resultBlock(nil);
        }
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

- (void)callbackBridge:(TTBridgeName)bridgeName params:(NSDictionary *)params {
    [self callbackBridge:bridgeName params:params resultBlock:nil];
}

- (void)callbackBridge:(TTBridgeName)bridgeName params:(NSDictionary *)params resultBlock:(void (^)(NSString *))resultBlock {
    [self callbackBridge:bridgeName msg:TTBridgeMsgSuccess params:params resultBlock:resultBlock];
}

- (void)callbackBridge:(TTBridgeName)bridgeName msg:(TTBridgeMsg)msg params:(NSDictionary *)params resultBlock:(void (^)(NSString *))resultBlock {
    TTBridgeCommand *command = [TTBridgeCommand new];
    command.callbackID = bridgeName;
    command.origName = bridgeName;
    command.bridgeType = TTBridgeTypeOn;
    if ([self.authorization respondsToSelector:@selector(engine:isAuthorizedBridge:domain:completion:)]) {
        if (![self.authorization engine:self isAuthorizedBridge:command domain:self.sourceURL.host.lowercaseString]) {
            resultBlock([NSString stringWithFormat:@"'%@' is not permitted at '%@'.", bridgeName, self.sourceURL]);
            return;
        }
    }
    NSMutableDictionary *wrapParams = [NSMutableDictionary dictionary];
    wrapParams[@"code"] = @(msg);
    wrapParams[@"data"] = params ?: @{};
    [self sendEventWithName:bridgeName body:[wrapParams copy]];
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

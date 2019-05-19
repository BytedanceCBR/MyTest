//
//  TTBridgeCommand.m
//  TTBridgeUnify
//
//  Modified from TTRexxar of muhuai.
//  Created by 李琢鹏 on 2018/10/30.
//

#import "TTBridgeCommand.h"

@implementation TTBridgeCommand

- (instancetype)initWithDictonary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        _fullName = [dic objectForKey:@"func"];
        _messageType = [dic objectForKey:@"__msg_type"];
        _params = [dic objectForKey:@"params"];
        _callbackID = [dic objectForKey:@"__callback_id"];
        _JSSDKVersion = [dic objectForKey:@"JSSDK"];
        [self amendDynamicPluginNameWithFullName:_fullName];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    TTBridgeCommand *command = [[TTBridgeCommand allocWithZone:zone] init];
    command.className = self.className;
    command.methodName = self.methodName;
    command.fullName = self.fullName;
    command.messageType = self.messageType;
    command.params = self.params;
    command.callbackID = self.callbackID;
    command.JSSDKVersion = self.JSSDKVersion;
    command.bridgeType = self.bridgeType;
    command.startTime = self.startTime;
    command.endTime = self.endTime;
    return command;
}

- (void)amendDynamicPluginNameWithFullName:(NSString *)fullName {
    NSArray<NSString *> *components = [fullName componentsSeparatedByString:@"."];
    if (components.count < 2) {
        return;
    }
    NSMutableString *className = [[NSMutableString alloc] init];
    for (int i=0; i<components.count-1; i++) {
        [className appendString:components[i]];
        if (i != components.count-2) {
            [className appendString:@"."];
        }
    }
    self.className = className.copy;
    self.methodName = components.lastObject;
}

- (void)setFullName:(NSString *)fullName {
    if (_fullName == fullName) {
        return;
    }
    _fullName = fullName;
    [self amendDynamicPluginNameWithFullName:fullName];
}

- (NSString *)toJSONString {
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
    [jsonDic setValue:[self.messageType copy] forKey:@"__msg_type"];
    [jsonDic setValue:[self.eventID copy]forKey:@"__event_id"];
    [jsonDic setValue:[self.callbackID copy]forKey:@"__callback_id"];
    [jsonDic setValue:self.params forKey:@"__params"];
    NSData * data = [NSJSONSerialization dataWithJSONObject:jsonDic options:0 error:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    string = [string stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    string = [string stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    return string;
}

@end

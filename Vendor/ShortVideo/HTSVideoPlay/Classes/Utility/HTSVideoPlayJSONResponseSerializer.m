//
//  HTSVideoPlayJSONResponseSerializer.m
//  LiveStreaming
//
//  Created by Quan Quan on 16/2/18.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "HTSVideoPlayJSONResponseSerializer.h"
#import "HTSVideoPlayAccountBridge.h"
#import "HTSVideoPlayNetworkResultModel.h"
#import "HTSVideoPlayNetworkErrorModel.h"
#import "BTDJSONHelper.h"
#import <Mantle/Mantle.h>
#import "BTDResponder.h"
#import "BTDMacros.h"

@implementation HTSVideoPlayJSONResponseSerializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"application/octet-stream", nil];
        NSMutableSet *acceptableContentTypes = [self.acceptableContentTypes mutableCopy];
        [acceptableContentTypes addObject:@"text/html"];
        self.acceptableContentTypes = acceptableContentTypes;
    }
    return self;
}

+ (NSObject<TTJSONResponseSerializerProtocol> *)serializer
{
    return [HTSVideoPlayJSONResponseSerializer new];
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                        jsonObj:(id)jsonObj
                  responseError:(NSError *)responseError
                    resultError:(NSError *__autoreleasing *)resultError
{
    if (responseError) {
        
        //网络通用错误，直接返回
        if (resultError) {
            *resultError = responseError;
        }
        return nil;
        
    } else {
        
        //NSData -> JSON
        if ([jsonObj isKindOfClass:[NSData class]]) {
            
            NSError *jsonConvertError = nil;
            NSDictionary *jsonConvertDictionary = [NSDictionary dictionaryWithJSONData:jsonObj error:&jsonConvertError];
            
            if (jsonConvertError) {
                //Convert JSON Error
                if (resultError) {
                    *resultError = jsonConvertError;
                }
                return nil;
                
            } else {
                
                jsonObj = jsonConvertDictionary;
            }
        }
        
        
        //API定义，Http State Code 统一为200， 服务端Custom了status_code
        //status_code is  0, success, 给上层返回json object
        //status_code not 0, error,   返回Error
        
        HTSVideoPlayNetworkResultModel *resultModel = [MTLJSONAdapter modelOfClass:[HTSVideoPlayNetworkResultModel class] fromJSONDictionary:jsonObj error:nil];

        if ([resultModel.statusCode integerValue] == 0) {
            
            return jsonObj;
            
        } else {
        
            HTSVideoPlayNetworkErrorModel *errorModel = [MTLJSONAdapter modelOfClass:[HTSVideoPlayNetworkErrorModel class] fromJSONDictionary:jsonObj error:nil];
            
            if ([errorModel.code integerValue] == 20003) {
                
                //只清空直播LiveUser，不再自动弹出登录界面
                [HTSVideoPlayAccountBridge clearLoginUser];
                
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                
                if (errorModel.message.length > 0) {
                    errorInfo[@"message"] = errorModel.message;
                }
                
                if (errorModel.prompts.length > 0) {
                    errorInfo[@"prompts"] = errorModel.prompts;
                }
                
                errorInfo[@"locol_message"] = @"用户未登录，Serializer会做统一处理，业务层无需关心Account逻辑，只需关心自己的逻辑即可";
                
                NSError *customError = [NSError errorWithDomain:@"com.bytedance.LiveStreamingNetworkError" code:[errorModel.code integerValue] userInfo:errorInfo];
                
                if (resultError) {
                    *resultError = customError;
                }
                
                return nil;
                
            } else if ([errorModel.code integerValue] == 10012) {
                
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                
                if (errorModel.message.length > 0) {
                    errorInfo[@"message"] = errorModel.message;
                }
                
                if (errorModel.prompts.length > 0) {
                    errorInfo[@"prompts"] = errorModel.prompts;
                }
                
                NSError *customError = [NSError errorWithDomain:@"com.bytedance.LiveStreamingNetworkError" code:[errorModel.code integerValue] userInfo:errorInfo];
                
                if (resultError) {
                    *resultError = customError;
                }
                
                //return nil
                return nil;
                
            } else{
                
                //custom error
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                
                if (errorModel.message.length > 0) {
                    errorInfo[@"message"] = errorModel.message;
                }
                
                if (errorModel.prompts.length > 0) {
                    errorInfo[@"prompts"] = errorModel.prompts;
                }
                
                NSError *customError = [NSError errorWithDomain:@"com.bytedance.LiveStreamingNetworkError" code:[errorModel.code integerValue] userInfo:errorInfo];
                
                if (resultError) {
                    *resultError = customError;
                }
                
                //return nil
                return nil;
            }
        }
    }
}

@end

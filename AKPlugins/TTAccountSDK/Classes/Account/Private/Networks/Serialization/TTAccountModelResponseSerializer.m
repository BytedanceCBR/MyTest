//
//  TTAccountModelResponseSerializer.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "TTAccountModelResponseSerializer.h"



@implementation TTAccountModelResponseSerializer

- (NSObject<TTResponseModelProtocol> *)responseObjectForResponse:(TTHttpResponse *)response
                                                         jsonObj:(id)jsonObj
                                                    requestModel:(TTRequestModel *)requestModel
                                                   responseError:(NSError *)responseError
                                                     resultError:(NSError *__autoreleasing *)resultError
{
    __autoreleasing NSError *jsonError = nil;
    id responseObject = [self responseObjectForResponse:response jsonObj:jsonObj responseError:responseError resultError:&jsonError];
    
    if (jsonError) {
        if (resultError) {
            *resultError = jsonError;
        }
    }
    
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSAssert(requestModel._response, @"requestModel必须包含response信息");
    
    Class class = NSClassFromString(requestModel._response);
    if (!class) {
        return nil;
    }
    
    id resultModel = nil;
    @try {
        NSError *modelError = nil;
        resultModel = [[class alloc] initWithDictionary:responseObject error:&modelError];
        if (resultError && !(*resultError)) {
            *resultError = modelError;
        }
    } @catch (NSException *exception) {
        NSLog(@"API出错了！！！！！%@", exception);
    } @finally {
        
    }
    
    return resultModel;
}

+ (NSObject<TTJSONResponseSerializerProtocol> *)serializer
{
    return [[[self class] alloc] init];
}

@end

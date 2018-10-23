//
//  TTDefaultJSONResponseSerializer.h
//  Article
//
//  Created by Huaqing Luo on 10/9/15.
//
//

#import "TTHTTPResponseSerializerBase.h"

extern NSString * const kTTNetworkErrorResponseErrorCodeKey; //后端业务错误 封在error的userinfo里面
extern NSString * const kTTNetworkErrorResponseErrorTipsKey; //后端业务错误 封在error的userinfo里面
 extern NSString * const kTTNetworkErrorOldResponseErrorCodeKey; //后端业务错误（老逻辑） 封在error的userinfo里面

@interface TTDefaultJSONResponseSerializer : TTHTTPJSONResponseSerializerBase

- (void)error:(NSError*__autoreleasing *)error addHTTPStatusCodeWithResponse:(TTHttpResponse *)response;

@end

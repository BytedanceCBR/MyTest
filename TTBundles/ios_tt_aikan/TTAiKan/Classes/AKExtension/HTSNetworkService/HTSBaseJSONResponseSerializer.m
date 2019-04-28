//
//  HTSNetworkResponseSerializer.m
//  LiveStreaming
//
//  Created by 权泉 on 2017/5/11.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import "HTSBaseJSONResponseSerializer.h"

@implementation HTSBaseJSONResponseSerializer

+ (NSObject<TTJSONResponseSerializerProtocol> *)serializer
{
    return [[HTSBaseJSONResponseSerializer alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    }
    return self;
}

- (id)responseObjectForResponse:(TTHttpResponse *)response
                        jsonObj:(id)jsonObj
                  responseError:(NSError *)responseError
                    resultError:(NSError *__autoreleasing *)resultError
{
    if (resultError) {
        *resultError = responseError;
    }
    
    if ([jsonObj isKindOfClass:[NSData class]]) {
        jsonObj = [NSJSONSerialization JSONObjectWithData:jsonObj options:NSJSONReadingAllowFragments error:nil];
    }
    
    if (![jsonObj isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return jsonObj;
}

@end

//
//  HTSNetworkDefaultIMP.m
//  Pods
//
//  Created by 权泉 on 2017/5/11.
//
//

#import "HTSNetworkDefaultIMP.h"
#import "HTSBaseHTTPRequestSerializer.h"
#import "HTSBaseJSONResponseSerializer.h"

@implementation HTSNetworkDefaultIMP

+ (HTSNetworkServiceMode)networkMode
{
    return HTSNetworkServiceModeProduction;
}

+ (void)handleSessionExpired
{
    //Do nothing
}

+ (Class<TTHTTPRequestSerializerProtocol>)requestSerializerClass
{
    return [HTSBaseHTTPRequestSerializer class];
}

+ (Class<TTJSONResponseSerializerProtocol>)responseSerializerClass
{
    return [HTSBaseJSONResponseSerializer class];
}

@end

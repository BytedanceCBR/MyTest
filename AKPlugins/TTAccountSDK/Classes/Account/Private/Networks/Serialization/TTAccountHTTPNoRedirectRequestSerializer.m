//
//  TTAccountHTTPNoRedirectRequestSerializer.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/9/16.
//  Copyright © 2016 com.bytedance.news. All rights reserved.
//

#import "TTAccountHTTPNoRedirectRequestSerializer.h"
#import <UIKit/UIKit.h>



@implementation TTAccountHTTPNoRedirectRequestSerializer

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
                              params:(NSDictionary *)params
                              method:(NSString *)method
               constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
                        commonParams:(NSDictionary *)commonParam
{
    TTHttpRequest *httpRequest = [super URLRequestWithURL:URL
                                                   params:params
                                                   method:method
                                    constructingBodyBlock:bodyBlock
                                             commonParams:commonParam];
    httpRequest.followRedirect = NO;
    return httpRequest;
}

@end

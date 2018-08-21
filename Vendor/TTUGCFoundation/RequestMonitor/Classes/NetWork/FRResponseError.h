//
//  FRResponseError.h
//  Article
//
//  Created by ranny_90 on 2017/10/17.
//

#import <Foundation/Foundation.h>
#import "FRForumNetWorkMonitor.h"

static NSString * const kTTNetworkServerDataFormatErrorDomain = @"kTTNetworkServerDataFormatErrorDomain"; //接口后端业务逻辑错误domain
static NSString * const kTTNetworkServerErrorDomain = @"kTTNetworkServerErrorDomain"; //后端json解析错误

@interface FRResponseError : NSObject

+ (NSError *)mapResponseError:(NSError *)responseError;

+ (kTTNetworkErrorDomainType)responseErrorDomain:(NSError *)responseError;


@end

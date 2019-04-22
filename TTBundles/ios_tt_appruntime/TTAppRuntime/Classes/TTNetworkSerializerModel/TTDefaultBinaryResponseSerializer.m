//
//  TTDefaultBinaryResponseSerializer.m
//  Article
//
//  Created by Huaqing Luo on 10/9/15.
//
//

#import "TTDefaultBinaryResponseSerializer.h"
#import "SSHTTPProcesser.h"

@implementation TTDefaultBinaryResponseSerializer

- (id)responseObjectForResponse:(TTHttpResponse *)response
                           data:(NSData *)data
                  responseError:(NSError *)responseError
                    resultError:(NSError *__autoreleasing *)resultError
{
    if (responseError) {
        if (resultError) {
            *resultError = responseError;
        }
        return nil;
    } else {
        if (resultError) {
            *resultError = nil;
        }

        #warning todo 将SSHTTPProcesser 替换为 TTHTTPProcesser
        
        //文章下架在response header里 所以header先行处理
        SSHTTPResponseProtocolItem *item = [[SSHTTPResponseProtocolItem alloc] init];
        item.responseData = data;
        NSDictionary *allHeaderFields = nil;
        if ([response respondsToSelector:@selector(allHeaderFields)]) {
            allHeaderFields = [response allHeaderFields];
        }
        item.allHeaderFields = allHeaderFields;
        
        //传入SSHTTPProcesser做预处理
        int64_t total = 0;
        Class chromRespClass = NSClassFromString(@"TTHttpResponseChromium");
        if ([response isKindOfClass:chromRespClass]) {
            if ([response respondsToSelector:NSSelectorFromString(@"timingInfo")]) {
                id timingInfo = [response valueForKey:@"timingInfo"];
                if ([timingInfo respondsToSelector:NSSelectorFromString(@"wait")]) {
                    total += [[timingInfo valueForKey:@"wait"] longLongValue];
                }
                if ([timingInfo respondsToSelector:NSSelectorFromString(@"receive")]) {
                    total += [[timingInfo valueForKey:@"receive"] longLongValue];
                }
            }
        }
        [[SSHTTPProcesser sharedProcesser] preprocessHTTPResponse:item requestTotalTimeInterval:total requestURL:response.URL];

        return data;
    }
}

+ (NSObject<TTJSONResponseSerializerProtocol> *)serializer
{
    return [[[self class] alloc] init];
}

@end

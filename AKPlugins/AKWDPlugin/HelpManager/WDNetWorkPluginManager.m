//
//  WDNetWorkPluginManager.m
//  Article
//
//  Created by 延晋 张 on 2016/10/8.
//
//

#import "WDNetWorkPluginManager.h"

#import "TTMonitor.h"
#import "WDDefines.h"

NSString * const kWDApiVersion = @"wd_version";

static NSUInteger kWDInvalidDataCode = 3;
static NSString * const kWDInvalidDataObjectKey = @"kJSONModelKeyPath";
static NSString * const kWDInvalidDataMissingKeys = @"kJSONModelMissingKeys";

@implementation WDNetWorkPluginManager

- (TTHttpTask *)requestModel:(TTRequestModel *)model
                    callback:(TTNetworkResponseModelFinishBlock)callback
{
    NSMutableDictionary *additionGetParams = [NSMutableDictionary dictionaryWithDictionary:@{kWDApiVersion:WD_API_VERSION}];
    model._additionGetParams = [additionGetParams copy];

    return [[TTNetworkManager shareInstance] requestModel:model callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (error && error.code == kJSONModelErrorInvalidData) {
            [[TTMonitor shareManager] trackService:[[self class] serviceNameWithUri:model._uri] status:kWDInvalidDataCode extra:[[self class] extraValueWithError:error]];
        }
        
        if (callback) {
            callback(error, responseModel);
        }
    }];
}

+ (NSString *)serviceNameWithUri:(NSString *)uri
{
    if (isEmptyString(uri)) {
        return nil;
    }
    
    NSString *serviceName = [uri stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    if ([serviceName hasPrefix:@"_"] && serviceName.length > 0) {
        serviceName = [serviceName substringFromIndex:1];
    }
    return serviceName;
}

+ (NSDictionary *)extraValueWithError:(NSError *)error
{
    NSMutableDictionary *extraValue = @{}.mutableCopy;
    if (error.userInfo[kWDInvalidDataObjectKey]) {
        extraValue[kWDInvalidDataObjectKey] = error.userInfo[kWDInvalidDataObjectKey];
    }
    if (error.userInfo[kWDInvalidDataMissingKeys]) {
        extraValue[kWDInvalidDataMissingKeys] = error.userInfo[kWDInvalidDataMissingKeys];
    }
    return [extraValue copy];
}

@end

//
//  FHErrorHubManagerUtil.h
//  FHHouseBase
//
//  Created by liuyu on 2020/7/11.
//

#import <Foundation/Foundation.h>
#import "TTHttpResponse.h"
#import "FHMainApi.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHErrorHubManagerProtocol <NSObject>
@optional
- (void)checkRequestResponseWithHost:(NSString *)host requestParams:(NSDictionary *)params responseStatus:(TTHttpResponse *)responseStatus response:(id)response analysisError:(NSError *)analysisError changeModelType:(FHNetworkMonitorType )type errorHubType:(NSInteger)errorHubType;
- (void)checkBuryingPointWithEvent:(NSString *)eventName Params:(NSDictionary* )eventParams;
@end

@interface FHErrorHubManagerUtil : NSObject<FHErrorHubManagerProtocol>
+ (void)checkRequestResponseWithHost:(NSString *)host requestParams:(NSDictionary *)params responseStatus:(TTHttpResponse *)responseStatus response:(id)response analysisError:(NSError *)analysisError changeModelType:(FHNetworkMonitorType )type;
+ (void)checkBuryingPointWithEvent:(NSString *)eventName Params:(NSDictionary* )eventParams;
@end

NS_ASSUME_NONNULL_END

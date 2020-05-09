//
//  FHErrorHubMonitor.h
//  FHHouseBase
//
//  Created by liuyu on 2020/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHErrorHubMonitor : NSObject
 + (void)errorErrorReportingMessage:(NSString *)errorInfo extr:(NSDictionary *)extr;
@end

NS_ASSUME_NONNULL_END

//
//  FHErrorHubProcotol.h
//  Pods
//
//  Created by liuyu on 2020/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHeErrorHubProtocol <NSObject>

@required
- (NSDictionary *)returunAbnormalReportData;

- (NSString *)associatedKey;

@end


NS_ASSUME_NONNULL_END

//
//  FHMessageBridgeProtocol.h
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHMessageBridgeProtocol <NSObject>

- (NSInteger)getMessageTabBarBadgeNumber;

- (void)clearMessageTabBarBadgeNumber;

- (void)reduceMessageTabBarBadgeNumber:(NSInteger)number;

@end

NS_ASSUME_NONNULL_END

//
//  FHWeakProxy.h
//  FHBMain
//
//  Created by 春晖 on 2019/2/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHWeakProxy : NSProxy

@property (nonatomic, weak, readonly) id target;
+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END

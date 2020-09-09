//
//  FHEventShowProtocol.h
//  Pods
//
//  Created by bytedance on 2020/9/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHEventShowProtocol <NSObject>

@optional

// element_show 的时候:element_type，返回为空不上报
- (NSString *)elementType;

// 适用于一个cell多个elementshow的情况
- (NSArray<NSString *> *)elementTypes;

@end

NS_ASSUME_NONNULL_END

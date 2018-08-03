//
//  TTMonitorLogIDGenerator.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/29.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  用于生成log_id ,long类型, 可用于去重, 对于单个客户端不重复
 *  卸载重装后重新计算，会重复
 *
 */
@interface TTMonitorLogIDGenerator : NSObject

///**
// *  调用该方法后，会生成一个logID, 一定不要浪费。
// *
// *  @return 整数
// */
//+ (NSInteger)generateALogID;

+ (NSString *)generateALogID;

@end

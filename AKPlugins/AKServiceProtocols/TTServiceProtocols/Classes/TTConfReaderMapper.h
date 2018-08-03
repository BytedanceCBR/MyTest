//
//  TTConfReaderMapper.h
//  Pods
//
//  Created by fengyadong on 2017/4/14.
//
//

#import <Foundation/Foundation.h>

@protocol TTConfReaderMapper <NSObject>

@required
/**
 *  Mapper的唯一标识，必须实现
 *
 *  @return 唯一标识
 */
- (NSString *)key;

@optional
/**
 *  对TTConfReader查询字符串结果进行映射
 *
 *  @param target 映射目标
 *
 *  @return 如果查询到返回映射结果，否则返回nil
 */
- (NSString *)mapString:(NSString *)target;

@end

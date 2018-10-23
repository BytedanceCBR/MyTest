
/**
 * @file NSArrayAddtions
 * @author David<gaotianpo@songshulin.net>
 *
 * @brief NSArray的扩展
 * 
 * @details NSArray 一些功能的扩展
 *
 *  Created by David Fox on 2/23/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 * 
 */

/**
 * @brief NSArray的扩展
 */
#import <Foundation/Foundation.h>
#import <objc/message.h>

#define ARRAY(__args...) [NSArray arrayWithObjects:__args, nil]

@interface NSArray(SSNSArrayAddtions)

/**
 * @brief 使用compare:函数排序数组,数组内的对象必须支持compare:方法
 * @return 返回一个自动释放的已经排好序的数组
 */
- (NSArray *)sortedArray;

/**
 * @brief 将一个NSArray合并到当前的NSArray中，使用默认的compare:的方法,数组内的对象必须支持compare:
 * @param newArray是将要合并的NSArray
 * @param merger 是合并使用的函数，可以不提供的
 * @return 返回一个新的自动释放的NSArray
 */
- (NSArray *)mergeArray:(NSArray *)newArray
              mergeSelector:(SEL)merger;

/**
 * @brief 将一个NSArray合并到当前的NSArray中
 * @param newArray是将要合并的NSArray
 * @param merger 是合并使用的函数
 * @param comparer 是指定的比较函数
 * @return 返回一个新的自动释放的NSArray
 */
- (NSArray *)mergeArray:(NSArray *)newArray
            compareSelector:(SEL)comparer
              mergeSelector:(SEL)merger;
/**
 * @brief 将自己压缩成NSData
 * @return 返回一个新的自动释放的NSData
 */
- (NSData *)archivedArray;

@end

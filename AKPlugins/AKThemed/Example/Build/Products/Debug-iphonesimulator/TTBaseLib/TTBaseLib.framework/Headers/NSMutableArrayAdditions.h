//
//  NSMutableArrayAdditions.h
//  Article
//
//  Created by fengyadong on 16/4/25.
//
//

#import <Foundation/Foundation.h>
#import "NSDataAdditions.h"

@interface NSMutableArray (Sorted)
/**
 *  对一个已经排好序的数组去重
 *
 *  @param sortedArray 已经排好序的数组
 *
 *  @return 去重之后的排序数组
 */
+ (NSMutableArray *)distinguishArrayItemsWithSortedArray:(NSArray *)sortedArray;
/**
 *  对两个排序数组进行合并并去重
 *
 *  @param firstArray  第一个排序数组
 *  @param secondArray 第二个排序数组
 *
 *  @return 合并之后并且没有重复元素的数组
 */
+ (NSMutableArray *)mergeTwoSortedArrayWithoutSameElementWithFirstArray:(NSArray *)firstArray secondArray:(NSArray *)secondArray;


@end

@interface NSMutableArray (TTFingerprint)

/**
 *  将NSMutableArray根据TTFingerprintType转换为相应的Base64格式字符串
 *
 *  @param type
 *
 *  @return 
 */
- (NSString *)tt_base64StringWithFingerprintType:(TTFingerprintType)type;

@end

@interface NSArray (JSONValue)

- (NSString *)JSONRepresentation;

@end

//
//  NSString+TTLength.h
//  Article
//
//  Created by liuzuopeng on 9/7/16.
//
//

#import <Foundation/Foundation.h>

@interface NSString (TTLength)
/**
 *  统计字符串中字的数目
 *  规则如下: 一个中文算一个字，两个英文算一个字，结果会向上取整，不足一个字时算一个字
 *
 *  @return 字数
 */
- (NSUInteger)tt_lengthOfWords;
/**
 *  统计字符串所占字节数
 *  规则如下: 一个中文算两字节，一个英文算一个字节
 *
 *  @return 字节数
 */
- (NSUInteger)tt_lengthOfBytes;

/**
*  计算字符串容纳maxCount字节数时的长度
*  规则如下: 一个中文算两字节，一个英文算一个字节
*
*  @return 字节数
*/
- (NSUInteger)limitedLengthOfMaxCount:(NSUInteger)maxCount;
@end

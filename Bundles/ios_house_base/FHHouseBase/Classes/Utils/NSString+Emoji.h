//
//  NSString+Emoji.h
//  FHHouseBase
//
//  Created by 春晖 on 2019/4/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Emoji)

-(NSString *)stringByRemoveEmoji;

-(BOOL)containsEmoji;

/**
 *  统计字符串所占字节数
 *  规则如下: 一个中文算两字节，一个英文算一个字节
 *
 *  @return 字节数
 */
- (NSUInteger)tt_lengthOfBytes;

- (NSUInteger)limitedIndexOfMaxCount:(NSUInteger)maxCount;

- (NSUInteger)limitedIndexOfMaxCount:(NSUInteger)maxCount;

- (NSUInteger)tt_lengthOfBytesIncludeOnlyBlank;

@end

NS_ASSUME_NONNULL_END

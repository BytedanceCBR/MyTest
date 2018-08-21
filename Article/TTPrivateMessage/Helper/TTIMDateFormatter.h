//
//  TTIMDateFormatter.h
//  EyeU
//
//  Created by matrixzk on 11/2/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTIMMessage;
@interface TTIMDateFormatter : NSObject
+ (instancetype)sharedInstance;
/**
 *  按一定规则显示聊天列表中消息的发送时间，若需要显示则返回格式化后的时间，否则返回空，有缓存机制
 */
+ (NSString *)showFormattedDateIfNeededWithMessage:(TTIMMessage *)message lastMsg:(TTIMMessage *)lastMsg;

/**
 *  用于显示会话列表上显示的最后一条消息的发送时间
 */
+ (NSString *)formattedDate4ChatCenter:(NSDate *)aDate;

- (NSString *)formattedDateWithSourceDate:(NSDate *)aDate showTime:(BOOL)showTime;

@end

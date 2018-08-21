//
//  TTIMDateFormatter.h
//  EyeU
//
//  Created by matrixzk on 11/2/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTIMDateFormatter : NSObject
+ (instancetype)sharedInstance;

/**
 *  用于显示会话列表上显示的最后一条消息的发送时间
 */
+ (NSString *)formattedDate4ChatCenter:(NSDate *)aDate;

- (NSString *)formattedDateWithSourceDate:(NSDate *)aDate showTime:(BOOL)showTime;

@end

//
//  VideoURLSetting.h
//  Video
//
//  Created by Dianwei on 12-7-27.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonURLSetting.h"

@interface VideoURLSetting : CommonURLSetting

+ (NSString*)recentURLString;
+ (NSString*)topURLString;
+ (NSString*)hotURLString;
+ (NSString*)getStatsURLString;
+ (NSString*)getUpdatesString;
+ (NSString*)getFavoritesURLString;
+ (NSString*)videoFailedFeedbackURLString;

@end

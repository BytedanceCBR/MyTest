//
//  TTWidgetTool.h
//  Article
//
//  Created by xushuangqing on 2017/6/19.
//
//

#import <UIKit/UIKit.h>


@interface TTWidgetTool : NSObject

/**
 拷贝自TTBaseLib/TTStringHelper
 */
+ (NSURL *)URLWithURLString:(NSString *)str;


/**
 拷贝自TTDeviceHelper/TTDeviceHelper
 */
+ (float)OSVersionNumber;

/**
 拷贝自TTDeviceHelper/TTDeviceHelper
 */
+ (CGFloat)ssOnePixel;

/**
 拷贝自TTSandBoxHelper/TTSandBoxHelper
 */
+ (NSString *)ssAppScheme;

/**
 拷贝自TTToolService，给URL增加通用参数
 */
+ (NSString*)customURLStringFromString:(NSString*)urlStr supportedMix:(BOOL)supportedMix;

/**
 拷贝自TTBusinessManager/TTBusinessManager+StringUtils
 */
+ (NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval;

@end

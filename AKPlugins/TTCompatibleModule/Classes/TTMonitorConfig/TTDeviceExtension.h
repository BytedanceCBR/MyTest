//
//  TTDeviceExtension.h
//  TTLive
//
//  Created by Ray on 16/3/9.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

//设备类型
typedef NS_ENUM(NSUInteger, TTMonitorDeviceMode) {
    //iPad
    TTMonitorDeviceModePad,
    //iPhone X
    TTMonitorDeviceMode812,
    //iPhone6plus,iPhone6Splus
    TTMonitorDeviceMode736,
    //iPhone6,iPhone6S
    TTMonitorDeviceMode667,
    //iPhone5,iPhone5C,iPhone5S,iPhoneSE
    TTMonitorDeviceMode568,
    //iPhone4,iPhone4s
    TTMonitorDeviceMode480
};

@interface TTDeviceExtension : NSObject

+ (NSString *)platformString;
+ (TTMonitorDeviceMode)getDeviceType;
@end

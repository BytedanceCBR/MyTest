//
//  TTDeviceHelper.h
//  Pods
//
//  Created by zhaoqin on 8/11/16.
//
//

#import <Foundation/Foundation.h>

//分屏情况
typedef NS_ENUM(NSUInteger, TTSplitScreenMode) {
    TTSplitScreenFullMode,
    TTSplitScreenBigMode,
    TTSplitScreenMiddleMode,
    TTSplitScreenSmallMode
};

//设备类型
typedef NS_ENUM(NSUInteger, TTDeviceMode) {
    //iPad
    TTDeviceModePad,
    //iPhone XR XS Max
    TTDeviceMode896,
    //iPhone X
    TTDeviceMode812,
    //iPhone6plus,iPhone6Splus
    TTDeviceMode736,
    //iPhone6,iPhone6S
    TTDeviceMode667,
    //iPhone5,iPhone5C,iPhone5S,iPhoneSE
    TTDeviceMode568,
    //iPhone4,iPhone4s
    TTDeviceMode480
};

@interface TTDeviceHelper : NSObject

/**
 *  获取当前设备的类型
 *
 *  @return "iPhone"/"iPad"
 */
+ (nullable NSString *)platformName;

/**
 *  判断设备是iPhone4, iPhone4S
 *
 *  @return Yes or No
 */
+ (BOOL)is480Screen;

/**
 *  判断设备是iPhone5, iPhone5C, iPhone5S, iPhoneSE
 *
 *  @return Yes or No
 */
+ (BOOL)is568Screen;

/**
 *  判断设备是iPhone6,iPhone6S
 *
 *  @return Yes or No
 */
+ (BOOL)is667Screen;

/**
 *  判断设备是iPhone6plus, iPhone6Splus
 *
 *  @return Yes or No
 */
+ (BOOL)is736Screen;
// iphone6，iphone6 plus

/**
 *  判断设备的宽度大于320
 *
 *  @return Yes or No
 */
+ (BOOL)isScreenWidthLarge320;

/**
 *  对375屏幕的比例
 *
 *  @return Yes or No
 */
+ (CGFloat)scaleToScreen375;

/**
 *  判断设备是iPhone X
 *
 *  @return Yes or No
 */
+ (BOOL)isIPhoneXDevice;

/**
 *  判断设备是iPad
 *
 *  @return Yes or No
 */
+ (BOOL)isPadDevice;

/**
 *  判断设备是iPad pro
 *
 *  @return Yes or No
 */
+ (BOOL)isIpadProDevice;

/**
 *  判断设备是否越狱
 *
 *  @return Yes or No
 */
+ (BOOL)isJailBroken;

/**
 *  获取设备类型
 *
 *  @return TTDeviceType类型
 */
+ (TTDeviceMode)getDeviceType;

/**
 *  获取idfa
 *
 *  @return idfa
 */
+ (nullable NSString*)idfaString;

/**
 *  获取idfv
 *
 *  @return idfv
 */
+ (nullable NSString *)idfvString;

/**
 *  获取系统版本号
 *
 *  @return 系统版本号
 */
+ (float)OSVersionNumber;

/**
 *  获取MAC地址
 *
 *  @return MAC地址
 */
+ (nullable NSString*)MACAddress;

/**
 *  获取当前语言种类
 *
 *  @return 当前语言种类
 */
+ (nullable NSString*)currentLanguage;

/**
 *  获取openUDID
 *
 *  @return openUDID
 */
+ (nullable NSString*)openUDID;

/**
 *  返回一像素的大小，对于2x屏幕返回0.5， 1x屏幕返回1
 *
 *  @return 一像素的大小
 */
+ (CGFloat)ssOnePixel;

/**
 *  获取mainScreen的scale
 *
 *  @return scale
 */
+ (CGFloat)screenScale;

/**
 *  获取当前屏幕范围
 *
 *  @return 当前屏幕范围
 */
+ (nullable NSString *)resolutionString;


@end

@interface TTDeviceHelper (TTDiskSpace)

//获取硬盘大小，单位Byte
+ (long long)getTotalDiskSpace;

//获取可用空间大小，单位Byte
+ (long long)getFreeDiskSpace;

@end

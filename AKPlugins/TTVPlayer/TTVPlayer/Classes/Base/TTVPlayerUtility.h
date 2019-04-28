//
//  TTVPlayerUtility.h
//  Article
//
//  Created by panxiang on 2018/12/11.
//

#import <Foundation/Foundation.h>


//设备类型
typedef NS_ENUM(NSUInteger, TTVDeviceMode) {
    //iPad
    TTVDeviceModePad,
    //iPhone XS Max, iPhone XR
    TTVDeviceMode896,
    //iPhone X, iPhone XS
    TTVDeviceMode812,
    //iPhone6plus,iPhone6Splus, iPhone 7 plus, iPhone 7S plus, iPhone 8 plus
    TTVDeviceMode736,
    //iPhone6,iPhone6S, iPhone 7, iPhone 7S, iPhone 8
    TTVDeviceMode667,
    //iPhone5,iPhone5C,iPhone5S,iPhoneSE
    TTVDeviceMode568,
    //iPhone4,iPhone4s
    TTVDeviceMode480
};

@interface TTVPlayerUtility : NSObject
/**
 *  根据设备获取文字字号（UI新规则）
 *
 *  @param normalSize normalSize
 *
 *  @return 文字字号
 */
+ (CGFloat)tt_fontSize:(CGFloat)normalSize;
+ (UIFont *)tt_semiboldFontOfSize:(CGFloat)size;

/**
 *  根据设备获取间距，普通的规则，特殊元素的特殊规则见下面
 *
 *  @param normalPadding normalPadding
 *
 *  @return 间距
 */
+ (CGFloat)tt_padding:(CGFloat)normalPadding;

+ (UIFont *)fullScreenPlayerTitleFont:(NSInteger)fontSetting;

+ (NSAttributedString *)attributedVideoTitleFromString:(NSString *)text;

+ (UIFont *)ttv_distinctTitleFont;

+ (UIColor *)colorWithHexString:(NSString *)hexStr;

+ (NSString *)transformProgressToTimeString:(CGFloat)progress duration:(NSTimeInterval)duration;

+ (void)quitCurrentViewController;

@end


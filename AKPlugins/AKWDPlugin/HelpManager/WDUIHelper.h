//
//  WDUIHelper.h
//  Article
//
//  Created by 延晋 张 on 16/7/19.
//
//

#import <Foundation/Foundation.h>

#define kWDCellLeftPadding 15
#define kWDCellRightPadding 15

#define WDPadding(padding) [WDUIHelper wd_padding:padding]
#define WDFontSize(fontSize) [WDUIHelper wd_fontSize:fontSize]
#define WDConstraintPadding(padding) [WDUIHelper wd_paddingWithConstraint:padding]
#define WDConstraintFontSize(fontSize) [WDUIHelper wd_fontSizeWithConstraint:fontSize]
#define WDFont(fontSize) [UIFont systemFontOfSize:[WDUIHelper wd_fontSize:fontSize]]
#define WDLabelPadding(padding, fontSize) [WDUIHelper wd_labelPadding:padding withFontSize:fontSize]

#define WDUserSettingFont(fontSize) [UIFont systemFontOfSize:[WDUIHelper wdUserSettingFontSizeWithFontSize:fontSize]]
#define WDUserSettingFontSize(fontSize) [WDUIHelper wdUserSettingFontSizeWithFontSize:fontSize]

@interface WDUIHelper : NSObject

+ (CGFloat)wd_fontSize:(CGFloat)normalSize;

// 只放大不缩小
+ (CGFloat)wd_fontSizeWithConstraint:(CGFloat)baseSize;

+ (CGFloat)wd_padding:(CGFloat)normalPadding;

// 只放大不缩小
+ (CGFloat)wd_paddingWithConstraint:(CGFloat)basePadding;

+ (CGFloat)wd_labelPadding:(CGFloat)normalPadding withFontSize:(CGFloat)fontSize;

+ (CGSize)wd_size:(CGSize)normalSize;

// 支持用户选择字体 ，行高
+ (CGFloat)wdUserSettingFontSizeWithFontSize:(CGFloat)fontSize;

+ (CGFloat)wdUserSettingTransferWithLineHeight:(CGFloat)height;

// 只放大，不缩小
+ (CGFloat)wdUserSettingFontSizeWithConstraintFontSize:(CGFloat)fontSize;

+ (CGFloat)wdUserSettingTransferWithConstraintLineHeight:(CGFloat)height;

@end

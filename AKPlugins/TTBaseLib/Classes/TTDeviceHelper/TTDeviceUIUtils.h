//
//  TTDeviceUIUtils.h
//  Pods
//
//  Created by 冯靖君 on 17/5/16.
//
//

#import <Foundation/Foundation.h>
#import "TTDeviceHelper.h"

@interface TTDeviceUIUtils : NSObject

/**
 *  根据设备获取文字字号
 *
 *  @param normalSize normalSize
 *
 *  @return 文字字号
 */
+ (CGFloat)tt_fontSize:(CGFloat)normalSize;

/**
 *  根据设备获取间距
 *
 *  @param normalPadding normalPadding
 *
 *  @return 间距
 */
+ (CGFloat)tt_padding:(CGFloat)normalPadding;

/**
 *  根据设备获取行高
 *
 *  @param normalHeight normalHeight
 *
 *  @return 行高
 */
+ (CGFloat)tt_lineHeight:(CGFloat)normalHeight;

/**
 *  特殊for动态 高寒5.5的需求 6与6p保持一致
 *
 *  @param normalSize normalSize
 *
 *  @return 文字字号
 */
+ (CGFloat)tt_fontSizeForMoment:(CGFloat)normalSize;

/**
 *  特殊for动态 高寒5.5的需求 6与6p保持一致
 *
 *  @param normalPadding normalPadding
 *
 *  @return 间距
 */
+ (CGFloat)tt_paddingForMoment:(CGFloat)normalPadding;

/**
 *  根据设备获取文字字号（UI新规则）
 *
 *  @param normalSize normalSize
 *
 *  @return 文字字号
 */
+ (CGFloat)tt_newFontSize:(CGFloat)normalSize;

/**
 *  根据设备获取间距，普通的规则，特殊元素的特殊规则见下面
 *
 *  @param normalPadding normalPadding
 *
 *  @return 间距
 */
+ (CGFloat)tt_newPadding:(CGFloat)normalPadding;

/**
 *  以下3中情况iPhone5s不乘于0.9  iPad iPad Pro 需要乘以1.3
 *  1.和切图在一起的文字
 *  2.所有的Bar(除了顶部TitleBar和底部Tabbar)
 *  3.屏幕最外边沿
 *
 *  @param normalPadding normalPadding
 *
 *  @return 间距
 */
+ (CGFloat)tt_newPaddingSpecialElement:(CGFloat)normalPadding;

/**
 *  分屏情况
 *
 *  @param size size
 *
 *  @return 分屏情况
 */
+ (TTSplitScreenMode)currentSplitScreenWithSize:(CGSize)size;

@end

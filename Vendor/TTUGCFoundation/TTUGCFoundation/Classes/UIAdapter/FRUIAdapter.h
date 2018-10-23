//
//  FRUIAdapter.h
//  Article
//
//  Created by 王霖 on 16/7/15.
//
//

#import <Foundation/Foundation.h>

@interface FRUIAdapter : NSObject

/**
 *  字体三端适配
 *
 *  @param normalSize 原始字体
 *
 *  @return 三端适配的字体
 */
+ (CGFloat)tt_fontSize:(CGFloat)normalSize;

/**
 *  间距三端适配
 *
 *  @param normalPadding 原始间距
 *
 *  @return 三端适配的间距
 */
+ (CGFloat)tt_padding:(CGFloat)normalPadding;

@end

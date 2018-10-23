//
//  WDButtonLabel.h
//  Pods
//
//  Created by wangqi.kaisa on 2017/8/25.
//
//

#import "SSThemed.h"

/*
 * 8.25 可以点击的label
 */

@interface WDButtonLabel : SSThemedLabel

@property (nonatomic, copy, nullable) IBInspectable NSString * highlightedTitleColorThemeKey;
@property (nonatomic, copy, nullable) void(^tapHandle)(void);

@end

//
//  UIColor+Theme.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import <UIKit/UIKit.h>

#define RGB(r,g,b)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Theme)

// #081f33
+(UIColor *)themeBlack;

// #a1aab3
+(UIColor *)themeGray;

// #f2f4f5
+(UIColor *)themeGrayPale;
// #ff5b4c
+(UIColor *)themeRed;

@end


NS_ASSUME_NONNULL_END

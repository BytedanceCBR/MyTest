//
//  UIFont+House.m
//  Article
//
//  Created by 谷春晖 on 2018/11/1.
//

#import "UIFont+House.h"

@implementation UIFont (House)

+(UIFont *)themeFontRegular:(CGFloat)fontSize
{
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize];
    if (!font) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}

+(UIFont *)themeFontMedium:(CGFloat)fontSize
{
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Medium" size:fontSize];
    if (!font) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    return font;
}

+(UIFont *)themeFontSemibold:(CGFloat)fontSize
{
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize];
    if (!font) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    return font;
}

@end

/*
 class Font {
 static let pingFangRegular: (CGFloat) -> UIFont = { (size) in
 UIFont(name: "PingFangSC-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
 }
 
 static let pingFangMedium: (CGFloat) -> UIFont = { (size) in
 UIFont(name: "PingFangSC-Medium", size: size) ?? UIFont.boldSystemFont(ofSize: size)
 }
 
 static let pingFangSemibold: (CGFloat) -> UIFont = { (size) in
 UIFont(name: "PingFangSC-Semibold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
 }
 }
 */

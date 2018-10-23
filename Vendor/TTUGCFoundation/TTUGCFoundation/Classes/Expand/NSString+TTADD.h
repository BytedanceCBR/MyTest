//
//  NSString+TTAdd.h
//  Article
//
//  Created by tyh on 2017/4/5.
//
//

#import <Foundation/Foundation.h>

@interface NSString (TTAdd)

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;
- (CGFloat)widthForFont:(UIFont *)font;
- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width;

@end

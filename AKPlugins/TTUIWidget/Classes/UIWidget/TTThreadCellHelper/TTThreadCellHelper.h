//
//  TTThreadCellHelper.h
//  Article
//
//  Created by chenjiesheng on 2016/12/27.
//
//

#import <Foundation/Foundation.h>

extern NSString *const kContentTruncationLinkURLString;
extern NSString *const kForwardContentTruncationLinkURLString;

@interface TTThreadCellHelper : NSObject

+ (NSAttributedString *)truncationFont:(UIFont *)font
                          contentColor:(UIColor *)contentColor
                                 color:(UIColor *)color
                               linkUrl:(NSString *)linkUrl;

+ (NSAttributedString *)truncationString:(NSString *)string
                                    font:(UIFont *)font
                            contentColor:(UIColor *)contentColor
                                   color:(UIColor *)color
                                 linkUrl:(NSString *)linkUrl;

+ (CGSize)sizeThatFitsAttributedString:(NSAttributedString *)attrStr
                       withConstraints:(CGSize)size
                      maxNumberOfLines:(NSUInteger)maxLine
                limitedToNumberOfLines:(NSUInteger*)numberOfLines;
@end

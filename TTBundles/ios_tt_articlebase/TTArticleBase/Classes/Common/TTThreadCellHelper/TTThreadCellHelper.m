//
//  TTThreadCellHelper.m
//  Article
//
//  Created by chenjiesheng on 2016/12/27.
//
//

#import "TTThreadCellHelper.h"
#import "TTUGCAttributedLabel.h"

NSString * const kContentTruncationLinkURLString = @"www.bytedance.contentTruncationLinkURLString";
NSString * const kForwardContentTruncationLinkURLString = @"www.bytedance.forwardContentTruncationLinkURLString";

@implementation TTThreadCellHelper

//...全文处理
+ (NSAttributedString *)truncationFont:(UIFont *)font contentColor:(UIColor *)contentColor color:(UIColor *)color linkUrl:(NSString *)linkUrl {
    NSString * moreStr = NSLocalizedString(@"...全文", nil);
    NSMutableDictionary * attrDic = @{}.mutableCopy;
    if (font) {
        [attrDic setValue:font forKey:NSFontAttributeName];
    }
    if (color) {
        [attrDic setValue:color forKey:NSForegroundColorAttributeName];
    }
    NSMutableAttributedString * truncationString = [[NSMutableAttributedString alloc] initWithString:moreStr attributes:attrDic];
    // TODO 其实这里使用了错误的方式来修复点击无效的 bug，暂且如此
    [truncationString addAttribute:NSLinkAttributeName  // 修复点击问题的bug 强制加一个无用action
                             value:[NSURL URLWithString:linkUrl ?: kContentTruncationLinkURLString]
                             range:NSMakeRange(0, moreStr.length)];
    if (contentColor) {
        [truncationString addAttribute:NSForegroundColorAttributeName value:contentColor range:NSMakeRange(0, @"...".length)];
    }
    return truncationString.copy;
}

+ (NSAttributedString *)truncationString:(NSString *)string font:(UIFont *)font contentColor:(UIColor *)contentColor color:(UIColor *)color linkUrl:(NSString *)linkUrl {
    NSString * moreStr = NSLocalizedString(string, nil);
    NSMutableDictionary * attrDic = @{}.mutableCopy;
    if (font) {
        [attrDic setValue:font forKey:NSFontAttributeName];
    }
    if (color) {
        [attrDic setValue:color forKey:NSForegroundColorAttributeName];
    }
    NSMutableAttributedString * truncationString = [[NSMutableAttributedString alloc] initWithString:moreStr attributes:attrDic];
    // TODO 其实这里使用了错误的方式来修复点击无效的 bug，暂且如此
    [truncationString addAttribute:NSLinkAttributeName  // 修复点击问题的bug 强制加一个无用action
                             value:[NSURL URLWithString:linkUrl ?: kContentTruncationLinkURLString]
                             range:NSMakeRange(0, moreStr.length)];
    if (contentColor) {
        [truncationString addAttribute:NSForegroundColorAttributeName value:contentColor range:NSMakeRange(0, @"...".length)];
    }
    return truncationString.copy;
}

+ (CGSize)sizeThatFitsAttributedString:(NSAttributedString *)attrStr
                       withConstraints:(CGSize)size
                      maxNumberOfLines:(NSUInteger)maxLine
                limitedToNumberOfLines:(NSUInteger*)numberOfLines {
    long lines = [TTUGCAttributedLabel numberOfLinesAttributedString:attrStr withConstraints:size.width];
    
    if (lines <= maxLine) { //用最大行数能显示全，就用最大行数显示
        *numberOfLines = maxLine;
    }

    return [TTUGCAttributedLabel sizeThatFitsAttributedString:attrStr
                                              withConstraints:CGSizeMake(size.width, FLT_MAX)
                                       limitedToNumberOfLines:*numberOfLines];
}
@end

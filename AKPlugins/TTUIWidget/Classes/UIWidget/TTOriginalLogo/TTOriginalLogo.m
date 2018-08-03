//
//  TTOriginalLogo.m
//  Article
//
//  Created by Yang Xinyu on 12/9/15.
//
//

#import "TTOriginalLogo.h"
#import "TTLabelTextHelper.h"
#import <CoreText/CoreText.h>
#import "TTDeviceHelper.h"

@implementation TTOriginalLogo

+ (void)addOriginalLogoOnLabel:(UILabel *)label
                      withText:(NSString *)text
                     frameSize:(CGSize)logoSize
                         space:(CGFloat)space
                  textFontSize:(CGFloat)textFontSize
                  textColorKey:(NSString *)textColor
                  lineColorKey:(NSString *)lineColor
                  cornerRadius:(CGFloat)cornerRadius
                    lineNumber:(int)lineNumber
                    lineHeight:(CGFloat)lineHeight
{
    [self addOriginalLogoOnLabel:label withLabelSize:label.frame.size text:text frameSize:logoSize space:space textFontSize:textFontSize textColorKey:textColor lineColorKey:lineColor cornerRadius:cornerRadius lineNumber:lineNumber lineHeight:lineHeight];
}

+ (void)addOriginalLogoOnLabel:(UILabel *)label
                 withLabelSize:(CGSize)maxSize
                          text:(NSString *)text
                     frameSize:(CGSize)logoSize
                         space:(CGFloat)spacing
                  textFontSize:(CGFloat)textFontSize
                  textColorKey:(NSString *)textColor
                  lineColorKey:(NSString *)lineColor
                  cornerRadius:(CGFloat)cornerRadius
                    lineNumber:(int)lineNumber
                    lineHeight:(CGFloat)heightOfLine
{
    if (logoSize.width > maxSize.width) {
        return;
    }
    
    NSArray *lines = [self linesFromLabel:label ForWidth:maxSize.width];
    if ([lines count] == 0) {
        return;
    }

    CGPoint lastPoint;
    CGFloat lineHeight = maxSize.height;
    
    NSString *firstLineString = lines[0];
    
    [self removeAllOriginalLogoSubLabelsForLabel:label];
    
    if (lineNumber == 1) {
        CGSize size = [firstLineString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:label.font} context:nil].size;
        if ([lines count] == 1 || size.width + logoSize.width + spacing <= maxSize.width) {
            lastPoint = CGPointMake(size.width + spacing, maxSize.height / 2 - logoSize.height / 2);
        }
        else {
            firstLineString = @"";
            CGFloat subLabelWidth = maxSize.width - logoSize.width - spacing;

            UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, subLabelWidth, maxSize.height)];
            subTitleLabel.numberOfLines = 1;
            subTitleLabel.textColor = label.textColor;
            [subTitleLabel setAttributedText:[TTLabelTextHelper attributedStringWithString:label.text fontSize:label.font.pointSize lineHeight:lineHeight lineBreakMode:NSLineBreakByTruncatingTail]];
            [label addSubview:subTitleLabel];
            lastPoint = CGPointMake(subLabelWidth + spacing, maxSize.height / 2 - logoSize.height / 2);
        }
    }
    else if (lineNumber == 2) {
        if ([lines count] == 1) {
            CGSize size = [firstLineString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:label.font} context:nil].size;
            
            if(size.width + logoSize.width + spacing <= maxSize.width) {
                lastPoint = CGPointMake(size.width + spacing, maxSize.height / 2 - logoSize.height / 2);
            } else {
                lastPoint = CGPointMake(0, maxSize.height * 3 / 2 - logoSize.height / 2);
                firstLineString = [NSString stringWithFormat:@"%@\n ", firstLineString];
            }
        } else {
            lineHeight = label.font.lineHeight;
            firstLineString = [NSString stringWithFormat:@"%@\n ", firstLineString];
            NSString *secondLineString = lines[1];
            for (int i = 2; i < [lines count]; i++) {
                secondLineString = [NSString stringWithFormat:@"%@%@", secondLineString, lines[i]];
            }
            CGSize size = [secondLineString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:label.font} context:nil].size;
            
            CGFloat subLabelWidth = size.width;
            
            if(size.width + logoSize.width + spacing >= maxSize.width) {
                subLabelWidth = maxSize.width - logoSize.width - spacing;
            }
            UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, lineHeight, subLabelWidth, lineHeight)];
            subTitleLabel.numberOfLines = 1;
            subTitleLabel.textColor = label.textColor;
            [subTitleLabel setAttributedText:[TTLabelTextHelper attributedStringWithString:secondLineString fontSize:label.font.pointSize lineHeight:lineHeight lineBreakMode:NSLineBreakByTruncatingTail]];
            [label addSubview:subTitleLabel];
            lastPoint = CGPointMake(subLabelWidth + spacing, (lineHeight * 3 - logoSize.height) / 2);
        }
    } else {
        return;
    }
    
    [label setAttributedText:[TTLabelTextHelper attributedStringWithString:firstLineString fontSize:label.font.pointSize lineHeight:heightOfLine lineBreakMode:NSLineBreakByTruncatingTail]];
    
    UILabel * originalLogo;
    originalLogo = [self originalLabelWithRect:CGRectMake(lastPoint.x, lastPoint.y, logoSize.width, logoSize.height) text:text textFontSize:textFontSize textColorKey:textColor lineColorKey:lineColor cornerRadius:cornerRadius];
    [label addSubview:originalLogo];
}

+ (void)removeAllOriginalLogoSubLabelsForLabel:(UILabel *)label
{
    for (UIView *view in label.subviews) {
        [view removeFromSuperview];
    }
}

+ (SSThemedLabel *)originalLabelWithRect:(CGRect)rect text:(NSString *)text textFontSize:(CGFloat)textFontSize textColorKey:(NSString *)textColor lineColorKey:(NSString *)lineColor cornerRadius:(CGFloat)cornerRadius
{
    SSThemedLabel * originalLogo;
    originalLogo = [[SSThemedLabel alloc] init];
    originalLogo.frame = rect;
    originalLogo.textAlignment = NSTextAlignmentCenter;
    originalLogo.font = [UIFont systemFontOfSize:textFontSize];
    originalLogo.text = text;
    originalLogo.textColorThemeKey = textColor;
    originalLogo.layer.cornerRadius = cornerRadius;
    originalLogo.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    originalLogo.borderColorThemeKey = lineColor;
    [originalLogo.layer setMasksToBounds:YES];
    return originalLogo;
}

+ (NSArray*) linesFromLabel:(UILabel *)label ForWidth:(CGFloat)width
{
    
    UIFont   *font = label.font;
    CGRect    rect = label.frame;
    
    NSMutableAttributedString *attStr;
    if (label.attributedText) {
        attStr = [label.attributedText mutableCopy];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attStr length])];
    } else {
        attStr = [[NSMutableAttributedString alloc] initWithString:label.text];
        CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName
                       value:(__bridge id)myFont
                       range:NSMakeRange(0, attStr.length)];
    }
    
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    if (label.attributedText) {
        for (id line in lines)
        {
            CTLineRef lineRef = (__bridge CTLineRef )line;
            CFRange lineRange = CTLineGetStringRange(lineRef);
            NSRange range = NSMakeRange(lineRange.location, lineRange.length);
            NSAttributedString *lineString = [label.attributedText attributedSubstringFromRange:range];
            if (lineString.string) {
                [linesArray addObject:lineString.string];
            }
        }
    }else{
        for (id line in lines)
        {
            CTLineRef lineRef = (__bridge CTLineRef )line;
            CFRange lineRange = CTLineGetStringRange(lineRef);
            NSRange range = NSMakeRange(lineRange.location, lineRange.length);
            
            NSString *lineString = [label.text substringWithRange:range];
            [linesArray addObject:lineString];
        }
    }
    
    return (NSArray *)linesArray;
}

+ (NSString *)removeSurplusSpace:(NSString *)string {
    NSString *newString = [string stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    BOOL flag = true;
    for (int i = (int)(newString.length - 1); i >= 0; i--) {
        char ch = [newString characterAtIndex:i];
        if (flag || ch != ' ') {
            flag = true;
            if (ch == ' ') {
                flag = false;
            }
        } else {
            [newString stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:@""];
        }
    }
    return newString;
}

@end

//
//  TTOriginalLogo.m
//  Article
//
//  Created by Yang Xinyu on 12/9/15.
//
//

#import "TTOriginalLogo.h"
#import "ExploreCellHelper.h"

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
{
    [self addOriginalLogoOnLabel:label withLabelSize:label.frame.size text:text frameSize:logoSize space:space textFontSize:textFontSize textColorKey:textColor lineColorKey:lineColor cornerRadius:cornerRadius lineNumber:lineNumber];
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
{
    if (logoSize.width > maxSize.width) {
        return;
    }
    
    NSArray *lines = [self getSeparatedLinesFromLabel:label maxSize:maxSize];
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
            [subTitleLabel setAttributedText:[ExploreCellHelper attributedStringWithString:label.text fontSize:label.font.pointSize lineHeight:lineHeight lineBreakMode:NSLineBreakByTruncatingTail]];
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
            lineHeight /= lineNumber;
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
            UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, label.frame.size.height / 2, subLabelWidth, label.frame.size.height / 2)];
            subTitleLabel.numberOfLines = 1;
            subTitleLabel.textColor = label.textColor;
            [subTitleLabel setAttributedText:[ExploreCellHelper attributedStringWithString:secondLineString fontSize:label.font.pointSize lineHeight:lineHeight lineBreakMode:NSLineBreakByTruncatingTail]];
            [label addSubview:subTitleLabel];
            lastPoint = CGPointMake(subLabelWidth + spacing, maxSize.height * 3 / 4 - logoSize.height / 2);
        }
    } else {
        return;
    }
    
    [label setAttributedText:[ExploreCellHelper attributedStringWithString:firstLineString fontSize:label.font.pointSize lineHeight:lineHeight lineBreakMode:NSLineBreakByTruncatingTail]];
    
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
    originalLogo.layer.borderWidth = [SSCommon ssOnePixel];
    originalLogo.borderColorThemeKey = lineColor;
    [originalLogo.layer setMasksToBounds:YES];
    return originalLogo;
}

+ (NSArray *)getSeparatedLinesFromLabel:(UILabel *)label maxSize:(CGSize)maxSize
{
    NSString *text = [self removeSurplusSpace:[label text]];
    UIFont   *font = [label font];
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,maxSize.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    
    CFRelease(myFont);
    CFRelease(frame);
    CFRelease(frameSetter);
    CGPathRelease(path);
    
    return linesArray;
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

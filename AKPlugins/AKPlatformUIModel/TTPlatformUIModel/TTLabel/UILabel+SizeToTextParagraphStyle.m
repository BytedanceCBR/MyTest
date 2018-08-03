//
//  UILabel+SizeToTextParagraphStyle.m
//  Article
//
//  Created by liuzuopeng on 22/07/2017.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "UILabel+SizeToTextParagraphStyle.h"



@implementation UILabel (SizeToTextParagraphStyle)

#pragma mark - helper

- (NSMutableParagraphStyle *)_selfParagraphStyle_
{
    NSMutableParagraphStyle *paraStyle = [NSMutableParagraphStyle new];
    paraStyle.lineSpacing = 0;
    paraStyle.firstLineHeadIndent = 0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.minimumLineHeight = [UIFont systemFontOfSize:self.font.pointSize * self.minimumScaleFactor].lineHeight;
    paraStyle.maximumLineHeight = self.font.lineHeight;
    paraStyle.alignment = self.textAlignment;
    
    return paraStyle;
}

- (CGSize)_tt_sizeForString:(NSString *)aString
               withMaxWidth:(CGFloat)maxWidth
                lineSpacing:(NSInteger)lineSpacing
                kernSpacing:(NSInteger)kernSpacing
{
    NSString *textString = aString;
    if ([textString length] <= 0) return CGSizeZero;
    
    NSInteger numberOfLines = self.numberOfLines;
    CGFloat adjustedLineSpacing = (numberOfLines == 1 ? 0 : MAX(0, lineSpacing - (self.font.lineHeight - self.font.pointSize)));
    
    NSMutableParagraphStyle *paraStyle = [self _selfParagraphStyle_];
    paraStyle.lineSpacing = adjustedLineSpacing;
    
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setValue:paraStyle forKey:NSParagraphStyleAttributeName];
    [mutDict setValue:self.font forKey:NSFontAttributeName];
    [mutDict setValue:@(kernSpacing) forKey:NSKernAttributeName];
    
    CGFloat contraintedHeight = (numberOfLines > 0) ? (numberOfLines * self.font.lineHeight + (numberOfLines - 1) * adjustedLineSpacing) : CGFLOAT_MAX;
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(maxWidth, contraintedHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:mutDict context:nil];
    
    if ((rect.size.height - self.font.lineHeight <= adjustedLineSpacing) && numberOfLines != 1) {
        // 说明只有一行文本，调整计算的高度和NSMutableParagraphStyle的lineSpacing
        // rect.size.height -= paraStyle.lineSpacing;
        paraStyle.lineSpacing = 0;
    }
    
    return CGSizeMake(ceil(MIN(maxWidth, rect.size.width)), ceil(rect.size.height));
}


+ (CGSize)tt_sizeForLabel:(UILabel *)label
             withMaxWidth:(NSInteger)maxWidth
              lineSpacing:(NSInteger)lineSpacing
{
    if (!label) return CGSizeZero;
    return [label tt_sizeWithMaxWidth:maxWidth lineSpacing:lineSpacing];
}

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)maxWidth
{
    return [self tt_sizeWithMaxWidth:maxWidth lineSpacing:0];
}

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)maxWidth
                  lineSpacing:(NSInteger)lineSpacing
{
    return [self tt_sizeWithMaxWidth:maxWidth lineSpacing:lineSpacing kernSpacing:0];
}

- (CGSize)tt_sizeWithMaxWidth:(CGFloat)maxWidth
                  lineSpacing:(NSInteger)lineSpacing
                  kernSpacing:(NSInteger)kernSpacing
{
    NSString *textString = self.text.length > 0 ? self.text : self.attributedText.string;
    if ([textString length] <= 0) return CGSizeZero;
    
    return [self _tt_sizeForString:textString withMaxWidth:maxWidth lineSpacing:lineSpacing kernSpacing:kernSpacing];
}

- (void)tt_sizeToFitMaxWidth:(CGFloat)maxWidth /** 文本最大的宽度 */
{
    [self tt_sizeToFitMaxWidth:maxWidth lineSpacing:0];
}

- (void)tt_sizeToFitMaxWidth:(CGFloat)maxWidth
                 lineSpacing:(NSInteger)lineSpacing
{
    [self tt_sizeToFitMaxWidth:maxWidth lineSpacing:lineSpacing kernSpacing:0];
}

- (void)tt_sizeToFitMaxWidth:(CGFloat)maxWidth /** 最大的宽度 */
                 lineSpacing:(NSInteger)lineSpacing /** 行间距 */
                 kernSpacing:(NSInteger)kernSpacing /** 单词间的间距 */
{
    NSString *textString = self.text.length > 0 ? self.text : self.attributedText.string;
    if ([textString length] <= 0) return;
    
    NSInteger numberOfLines = self.numberOfLines;
    CGFloat adjustedLineSpacing = (numberOfLines == 1 ? 0 : MAX(0, lineSpacing - (self.font.lineHeight - self.font.pointSize)));
    
    NSMutableParagraphStyle *paraStyle = [self _selfParagraphStyle_];
    paraStyle.lineSpacing = adjustedLineSpacing;
    
    NSRange range = NSMakeRange(0, textString.length);
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:textString];
    [attrString addAttribute:NSFontAttributeName value:self.font range:range];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:range];
    [attrString addAttribute:NSKernAttributeName value:@(kernSpacing) range:range];
    
    CGFloat contraintedHeight = (numberOfLines > 0) ? (numberOfLines * self.font.lineHeight + (numberOfLines - 1) * adjustedLineSpacing) : CGFLOAT_MAX;
    CGRect rect = [attrString boundingRectWithSize:CGSizeMake(maxWidth, contraintedHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    // correct 计算的高度和lineSpacing
    if ((rect.size.height - self.font.lineHeight <= adjustedLineSpacing) && numberOfLines != 1) {
        // 说明只有一行文本，调整计算的高度和NSMutableParagraphStyle的lineSpacing
        rect.size.height -= paraStyle.lineSpacing;
        paraStyle.lineSpacing = 0;
    }
    // correct UILabel的lineBreakMode
    paraStyle.lineBreakMode = self.lineBreakMode;
    
    // 设置文本
    self.attributedText = attrString;
    self.frame = CGRectIntegral(CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), rect.size.width, rect.size.height));
}

@end



#pragma mark - NSString (UILabelAttrsParagraphStyle)

@implementation NSString (UILabelAttrsParagraphStyle)

- (CGSize)tt_sizeForLabel:(UILabel *)label
             withMaxWidth:(NSInteger)maxWidth /** 文本最大的宽度 */
{
    return [self tt_sizeForLabel:label withMaxWidth:maxWidth lineSpacing:0];
}

- (CGSize)tt_sizeForLabel:(UILabel *)label
             withMaxWidth:(NSInteger)maxWidth /** 文本最大的宽度 */
              lineSpacing:(NSInteger)lineSpacing /** 行间距 */
{
    if (self.length <= 0) return CGSizeZero;
    if (!label) return CGSizeZero;
    
    return [label _tt_sizeForString:self withMaxWidth:maxWidth lineSpacing:lineSpacing kernSpacing:0];
}

@end


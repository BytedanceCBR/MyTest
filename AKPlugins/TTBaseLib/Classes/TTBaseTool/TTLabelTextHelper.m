//
//  TTLabelTextHelper.m
//  TTLive
//
//  Created by 冯靖君 on 16/1/13.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import "TTLabelTextHelper.h"
#import "TTBaseMacro.h"
#import "TTModuleBridge.h"

@implementation TTLabelTextHelper

#pragma mark - 计算高度
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width
{
    return [[self class] heightOfText:text fontSize:fontSize forWidth:width forLineHeight:[UIFont systemFontOfSize:fontSize].lineHeight];
}

/**
 *  @param numberOfLines 最大行数 行高为font.lineHeight
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width constraintToMaxNumberOfLines:(NSInteger)numberOfLines
{
    return [[self class] heightOfText:text fontSize:fontSize forWidth:width forLineHeight:[UIFont systemFontOfSize:fontSize].lineHeight constraintToMaxNumberOfLines:numberOfLines];
}

/**
 *  @param lineHeight 行高
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight
{
    return [[self class] heightOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:0];
}

/**
 *  @param numberOfLines 最大行数
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines
{
    return [[self class] heightOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:0];
}

+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines isBold:(BOOL)isBold
{
    return [[self class] heightOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:0 isBold:isBold];
}

/**
 *  @param indent 首行缩进值
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent
{
    return [[self class] heightOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:indent textAlignment:NSTextAlignmentLeft];
}

+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent isBold:(BOOL)isBold
{
    return [[self class] heightOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:indent textAlignment:NSTextAlignmentLeft isBold:isBold];
}

/**
 *  @param alignment 对齐方式
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment
{
    return [[self class] heightOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:indent textAlignment:alignment lineBreakMode:NSLineBreakByWordWrapping];
}

+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment isBold:(BOOL)isBold
{
    return [[self class] heightOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:indent textAlignment:alignment lineBreakMode:NSLineBreakByWordWrapping isBold:isBold];
}

/**
 *  @param alignment 断行方式
 */
+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize size = [[self class] sizeOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:indent textAlignment:alignment lineBreakMode:lineBreakMode];
    size.height = ceil(size.height);
    return size.height;
}

+ (CGFloat)heightOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment lineBreakMode:(NSLineBreakMode)lineBreakMode isBold:(BOOL)isBold
{
    CGSize size = [[self class] sizeOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:indent textAlignment:alignment lineBreakMode:lineBreakMode isBold:isBold];
    size.height = ceil(size.height);
    return size.height;
}

#pragma mark - 计算size
+ (CGSize)sizeOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment
{
    return [[self class] sizeOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:indent textAlignment:alignment lineBreakMode:NSLineBreakByWordWrapping isBold:NO];
}

+ (CGSize)sizeOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment isBold:(BOOL)isBold
{
    return [[self class] sizeOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:indent textAlignment:alignment lineBreakMode:NSLineBreakByWordWrapping isBold:isBold];
}


+ (CGSize)sizeOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    return [[self class] sizeOfText:text fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:indent textAlignment:alignment lineBreakMode:lineBreakMode isBold:NO];
}

+ (CGSize)sizeOfText:(NSString *)text fontSize:(CGFloat)fontSize forWidth:(CGFloat)width forLineHeight:(CGFloat)lineHeight constraintToMaxNumberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment lineBreakMode:(NSLineBreakMode)lineBreakMode isBold:(BOOL)isBold
{
    CGSize size = CGSizeZero;
    if ([text length] > 0) {
        UIFont *font = isBold ? [UIFont boldSystemFontOfSize:fontSize]:[UIFont systemFontOfSize:fontSize];
        CGFloat constraintHeight = numberOfLines ? numberOfLines * (lineHeight + 1) : 9999.f;
        CGFloat lineHeightMultiple = lineHeight / font.lineHeight;
        
        if ([self _shouldHandleJailBrokenCase]) {
            NSAttributedString *attrString = [self attributedStringWithString:text fontSize:fontSize lineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping isBoldFontStyle:isBold firstLineIndent:indent textAlignment:alignment];
            size = [attrString boundingRectWithSize:CGSizeMake(width, constraintHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        }
        else {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineBreakMode = lineBreakMode;
            style.alignment = alignment;
            style.lineHeightMultiple = lineHeightMultiple;
            style.minimumLineHeight = font.lineHeight * lineHeightMultiple;
            style.maximumLineHeight = font.lineHeight * lineHeightMultiple;
            style.firstLineHeadIndent = indent;
            size = [text boundingRectWithSize:CGSizeMake(width, constraintHeight)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:font,
                                                NSParagraphStyleAttributeName:style,
                                                }
                                      context:nil].size;
        }
        
    }
    return size;
}

// 解耦TTDeviceHelper依赖
+ (BOOL)_shouldHandleJailBrokenCase
{
    static float currentOsVersionNumber = 0;
    static BOOL s_is_jailBroken = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentOsVersionNumber = [[[UIDevice currentDevice] systemVersion] floatValue];
        NSString *filePath = @"/Applications/Cydia.app";
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            s_is_jailBroken = YES;
        }
        
        filePath = @"/private/var/lib/apt";
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            s_is_jailBroken = YES;
        }
        
    });
    
    return currentOsVersionNumber < 9.f && s_is_jailBroken;
}

#pragma mark - 生成attributedString
+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize
{
    return [self attributedStringWithString:string fontSize:fontSize lineHeight:[UIFont systemFontOfSize:fontSize].lineHeight];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight
{
    return [self attributedStringWithString:string fontSize:fontSize lineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    return [self attributedStringWithString:string fontSize:fontSize lineHeight:lineHeight lineBreakMode:lineBreakMode isBoldFontStyle:NO];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode isBoldFontStyle:(BOOL)isBold
{
    return [self attributedStringWithString:string fontSize:fontSize lineHeight:lineHeight lineBreakMode:lineBreakMode isBoldFontStyle:isBold firstLineIndent:0];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode isBoldFontStyle:(BOOL)isBold firstLineIndent:(CGFloat)indent
{
    return [self attributedStringWithString:string fontSize:fontSize lineHeight:lineHeight lineBreakMode:lineBreakMode isBoldFontStyle:isBold firstLineIndent:indent textAlignment:NSTextAlignmentLeft];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode isBoldFontStyle:(BOOL)isBold firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment
{
    if (isEmptyString(string)) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    NSDictionary *attributes = [self _attributesWithFontSize:fontSize lineHeight:lineHeight lineBreakMode:lineBreakMode isBoldFontStyle:isBold firstLineIndent:indent textAlignment:alignment];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[self parseEmojiInTextKitContext:string fontSize:fontSize]];;
    
    [attributedString addAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}

#pragma mark - private

+ (NSDictionary *)_attributesWithFontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode isBoldFontStyle:(BOOL)isBold firstLineIndent:(CGFloat)indent textAlignment:(NSTextAlignment)alignment
{
//    UIFont *font = isBold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
    //f项目统一修改成平方
    UIFont *font = isBold ? [UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize] : [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize];

    CGFloat lineHeightMultiple = lineHeight / font.lineHeight;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = lineBreakMode;
    style.alignment = alignment;
    style.lineHeightMultiple = lineHeightMultiple;
    style.minimumLineHeight = font.lineHeight * lineHeightMultiple;
    style.maximumLineHeight = font.lineHeight * lineHeightMultiple;
    style.firstLineHeadIndent = indent;
    NSDictionary * attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
    return attributes;
}

+ (NSAttributedString *)parseEmojiInTextKitContext:(NSString *)text fontSize:(CGFloat)fontSize
{
    if (isEmptyString(text)) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    __block NSAttributedString *string = nil;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:text forKey:@"text"];
    [param setValue:@(fontSize) forKey:@"fontSize"];
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"TTUGCEmojiParser.parseInTextKitContext" object:nil withParams:param complete:^(id  _Nullable result) {
        string = result;
    }];
    if (string == nil) {
        string = [[NSAttributedString alloc] initWithString:text];
    }
    return string;
}

@end

//
//  FHUGCCellHelper.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/6.
//

#import "FHUGCCellHelper.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"

@implementation FHUGCCellHelper

//...全文处理
+ (NSAttributedString *)truncationFont:(UIFont *)font contentColor:(UIColor *)contentColor color:(UIColor *)color {
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
                             value:[NSURL URLWithString:defaultTruncationLinkURLString]
                             range:NSMakeRange(0, moreStr.length)];
    if (contentColor) {
        [truncationString addAttribute:NSForegroundColorAttributeName value:contentColor range:NSMakeRange(0, @"...".length)];
    }
    return truncationString.copy;
}

+ (void)setRichContent:(TTUGCAttributedLabel *)label model:(FHFeedUGCCellModel *)model numberOfLines:(NSInteger)numberOfLines {
    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:model.contentRichSpan];
    TTRichSpanText *richContent = [[TTRichSpanText alloc] initWithText:model.content richSpans:richSpans];
    
    TTRichSpanText *threadContent = [[TTRichSpanText alloc] initWithText:@"" richSpanLinks:nil imageInfoModelDictionary:nil];
    
    if (!isEmptyString(model.title)) {
        [threadContent appendText:[NSString stringWithFormat:@"【%@】",model.title]];
    }
    if (!isEmptyString(model.content)) {
        [threadContent appendRichSpanText:richContent];
    }
    
    if (!isEmptyString(threadContent.text)) {
        NSInteger parseEmojiCount = -1;
        if (numberOfLines > 0) {
            parseEmojiCount = (100 * (numberOfLines + 1));// 只需解析这么多，其他解析无用~~
        }
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:threadContent.text fontSize:16 needParseCount:parseEmojiCount];
        if (attrStr) {
            UIFont *font = [UIFont themeFontRegular:16];
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
            paragraphStyle.minimumLineHeight = 21;
            paragraphStyle.maximumLineHeight = 21;
            paragraphStyle.lineSpacing = 2;
            
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
            
            //内容
            label.numberOfLines = numberOfLines;
            [label setText:mutableAttributedString];
            if(model.showLookMore){
                label.attributedTruncationToken = [FHUGCCellHelper truncationFont:[attributes objectForKey:NSFontAttributeName]
                                                                 contentColor:attributes[NSForegroundColorAttributeName]
                                                                        color:[UIColor themeRed3]];
            }
        }
    }
}

+ (void)setRichContent:(TTUGCAttributedLabel *)label content:(NSString *)content font:(UIFont *)font numberOfLines:(NSInteger)numberOfLines {
    TTRichSpanText *richContent = [[TTRichSpanText alloc] initWithText:content richSpans:nil];
    
    TTRichSpanText *threadContent = [[TTRichSpanText alloc] initWithText:@"" richSpanLinks:nil imageInfoModelDictionary:nil];
    
    if (!isEmptyString(content)) {
        [threadContent appendRichSpanText:richContent];
    }
    
    if (!isEmptyString(threadContent.text)) {
        NSInteger parseEmojiCount = -1;
        if (numberOfLines > 0) {
            parseEmojiCount = (100 * (numberOfLines + 1));// 只需解析这么多，其他解析无用~~
        }
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:threadContent.text fontSize:font.pointSize needParseCount:parseEmojiCount];
        if (attrStr) {
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            paragraphStyle.minimumLineHeight = 21;
            paragraphStyle.maximumLineHeight = 21;
            paragraphStyle.lineSpacing = 2;
            
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
            
            //内容
            label.numberOfLines = numberOfLines;
            [label setText:mutableAttributedString];
        }
    }
}

+ (void)setRichContentWithModel:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:model.contentRichSpan];
    TTRichSpanText *richContent = [[TTRichSpanText alloc] initWithText:model.content richSpans:richSpans];
    
    TTRichSpanText *threadContent = [[TTRichSpanText alloc] initWithText:@"" richSpanLinks:nil imageInfoModelDictionary:nil];
    
    model.richContent = richContent;
    
    if (!isEmptyString(model.title)) {
        [threadContent appendText:[NSString stringWithFormat:@"【%@】",model.title]];
    }
    if (!isEmptyString(model.content)) {
        [threadContent appendRichSpanText:richContent];
    }
    
    if (!isEmptyString(threadContent.text)) {
        NSInteger parseEmojiCount = -1;
        if (model.numberOfLines > 0) {
            parseEmojiCount = (100 * (model.numberOfLines + 1));// 只需解析这么多，其他解析无用~~
        }
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:threadContent.text fontSize:16 needParseCount:parseEmojiCount];
        if (attrStr) {
            UIFont *font = [UIFont themeFontRegular:16];
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            paragraphStyle.minimumLineHeight = 21;
            paragraphStyle.maximumLineHeight = 21;
            paragraphStyle.lineSpacing = 2;
            
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
            
            model.contentAStr = mutableAttributedString;
            
            CGSize size = [self sizeThatFitsAttributedString:mutableAttributedString
                                                              withConstraints:CGSizeMake(width, FLT_MAX)
                                                             maxNumberOfLines:numberOfLines
                                                       limitedToNumberOfLines:&numberOfLines];
            model.contentHeight = size.height;
        }
    }else{
        model.contentHeight = 0;
    }
}

+ (void)setArticleRichContentWithModel:(FHFeedUGCCellModel *)model width:(CGFloat)width {
    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:model.contentRichSpan];
    TTRichSpanText *richContent = [[TTRichSpanText alloc] initWithText:model.title richSpans:richSpans];
    
    TTRichSpanText *threadContent = [[TTRichSpanText alloc] initWithText:@"" richSpanLinks:nil imageInfoModelDictionary:nil];
    
    if (!isEmptyString(model.title)) {
        [threadContent appendRichSpanText:richContent];
    }
    
    if (!isEmptyString(threadContent.text)) {
        NSInteger parseEmojiCount = -1;
        if (model.numberOfLines > 0) {
            parseEmojiCount = (100 * (model.numberOfLines + 1));// 只需解析这么多，其他解析无用~~
        }
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:threadContent.text fontSize:16 needParseCount:parseEmojiCount];
        if (attrStr) {
            UIFont *font = [UIFont themeFontRegular:16];
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            paragraphStyle.minimumLineHeight = 21;
            paragraphStyle.maximumLineHeight = 21;
            paragraphStyle.lineSpacing = 2;
            
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
            
            model.contentAStr = mutableAttributedString;
            
            NSInteger numberOfLines = 3;
            
            CGSize size = [self sizeThatFitsAttributedString:mutableAttributedString
                                             withConstraints:CGSizeMake(width, FLT_MAX)
                                            maxNumberOfLines:numberOfLines
                                      limitedToNumberOfLines:&numberOfLines];
            model.contentHeight = size.height;
        }
    }else{
        model.contentHeight = 0;
    }
}

+ (void)setRichContent:(TTUGCAttributedLabel *)label model:(FHFeedUGCCellModel *)model {
    //内容
    [label setText:model.contentAStr];
    if(model.showLookMore){
        label.attributedTruncationToken = [FHUGCCellHelper truncationFont:[UIFont themeFontRegular:16]
                                                             contentColor:[UIColor themeGray1]
                                                                    color:[UIColor themeRed3]];
    }
    
    if(model.needLinkSpan && model.richContent){
        NSArray <TTRichSpanLink *> *richSpanLinks = [model.richContent richSpanLinksOfAttributedString];
        for (TTRichSpanLink *richSpanLink in richSpanLinks) {
            NSRange range = NSMakeRange(richSpanLink.start, richSpanLink.length);
            if (NSMaxRange(range) <= label.attributedText.length) {
                if(model.supportedLinkType){
                    if(model.supportedLinkType.count > 0 && [model.supportedLinkType containsObject:@(richSpanLink.type)]){
                        [label addLinkToURL:[NSURL URLWithString:richSpanLink.link] withRange:range];
                    }
                }else{
                    //不设置默认全部支持
                    [label addLinkToURL:[NSURL URLWithString:richSpanLink.link] withRange:range];
                }
            }
        }
    }
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

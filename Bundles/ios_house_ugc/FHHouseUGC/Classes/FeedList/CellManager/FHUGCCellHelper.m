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
    if(linkUrl){
        [truncationString addAttribute:NSLinkAttributeName  // 修复点击问题的bug 强制加一个无用action
                                 value:[NSURL URLWithString:linkUrl ?: @"www.bytedance.contentTruncationLinkURLString"]
                                 range:NSMakeRange(0, moreStr.length)];
    }
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
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:threadContent.text fontSize:16];
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
                                                                        color:[UIColor themeRed3]
                                                                      linkUrl:nil];
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
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:threadContent.text fontSize:font.pointSize];
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

@end

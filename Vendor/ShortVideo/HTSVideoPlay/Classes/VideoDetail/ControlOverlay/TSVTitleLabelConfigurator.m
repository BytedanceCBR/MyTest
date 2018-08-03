//
//  TSVTitleLabelConfigurator.m
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 22/12/2017.
//

#import "TSVTitleLabelConfigurator.h"
#import "TTUGCAttributedLabel.h"
#import "TTBaseMacro.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Link.h"
#import "TTRichSpanText+Emoji.h"
#import "TTUGCEmojiParser.h"
#import "ReactiveObjC.h"

@implementation TSVTitleLabelConfigurator

+ (void)updateAttributeTitleForLabel:(TTUGCAttributedLabel *)label
                        trimHashTags:(BOOL)trimHashTags
                                text:(NSString *)text
                 richTextStyleConfig:(NSString *)styleConfig
                         allBoldFont:(BOOL)allBoldFont
                            fontSize:(CGFloat)fontSize
                        activityName:(NSString *)activityName
                     prependUserName:(BOOL)prependUserName
                            userName:(NSString *)userName
                        linkTapBlock:(void (^)(TTRichSpanText *richSpanText, TTUGCAttributedLabelLink *curLink))linkTapBlock
                    userNameTapBlock:(void (^)(void))userNameTapBlock
{
    NSString *titleStr = text;
    if (isEmptyString(titleStr) && !prependUserName) {
        label.attributedText = nil;
        return;
    }
    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:styleConfig];
    TTRichSpanText *richTitle = [[TTRichSpanText alloc] initWithText:titleStr richSpans:richSpans];
    if (trimHashTags) {
        NSRange subStrRange = [titleStr rangeOfString:activityName];
        if (subStrRange.location != NSNotFound) {
            NSInteger startIndex = subStrRange.location - 1;
            [richTitle trimmingHashtagsWithStartIndex:startIndex];
        }
    }
    TTRichSpanText *titleRichSpanText = [richTitle replaceWhitelistLinks];

    NSString *prependString;
    if (prependUserName) {
        if (!isEmptyString(text)) {
            prependString = [NSString stringWithFormat:@"@%@：", userName];
        } else {
            prependString = [NSString stringWithFormat:@"@%@", userName];
        }
        [titleRichSpanText insertText:prependString atIndex:0];
    }
    NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:titleRichSpanText.text fontSize:fontSize];

    NSDictionary *attrDic = [self titleLabelAttributedDictionaryWithAllBoldFont:allBoldFont
                                                                       fontSize:fontSize];
    NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
    [mutableAttributedString addAttributes:attrDic range:NSMakeRange(0, attrStr.length)];

    [label setText:[mutableAttributedString copy]];

    NSArray <TTRichSpanLink *> *richSpanLinks = [titleRichSpanText richSpanLinksOfAttributedString];
    NSDictionary *attributesDict = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize]};
    if (richSpanLinks) {
        for (TTRichSpanLink *current in richSpanLinks) {
            NSRange linkRange = NSMakeRange(current.start, current.length);
            if (linkRange.location + linkRange.length <= attrStr.length) {
                NSTextCheckingResult *checkingResult = [NSTextCheckingResult transitInformationCheckingResultWithRange:linkRange components:@{}];
                TTUGCAttributedLabelLink *link =
                [[TTUGCAttributedLabelLink alloc] initWithAttributes:attributesDict
                                                    activeAttributes:attributesDict
                                                  inactiveAttributes:nil
                                                  textCheckingResult:checkingResult];
                link.linkURL = [NSURL URLWithString:current.link];

                link.linkTapBlock = ^(TTUGCAttributedLabel * curLabel, TTUGCAttributedLabelLink * curLink) {
                    linkTapBlock(richTitle, curLink);
                };
                [label addLink:link];
            }
        }
    }

    if (prependUserName) {
        NSTextCheckingResult *userNameTextCheckingResult = [NSTextCheckingResult transitInformationCheckingResultWithRange:NSMakeRange(0, [prependString length]) components:@{}];
        TTUGCAttributedLabelLink *userNameLink = [[TTUGCAttributedLabelLink alloc] initWithAttributes:attributesDict
                                                                                     activeAttributes:attributesDict
                                                                                   inactiveAttributes:nil
                                                                                   textCheckingResult:userNameTextCheckingResult];
        userNameLink.linkTapBlock = ^(TTUGCAttributedLabel *label, TTUGCAttributedLabelLink *link) {
            if (userNameTapBlock) {
                userNameTapBlock();
            }
        };
        [label addLink:userNameLink];
    }
}

+ (NSDictionary *)titleLabelAttributedDictionaryWithAllBoldFont:(BOOL)allBoldFont fontSize:(CGFloat)fontSize
{
    NSMutableDictionary * attributeDictionary = @{}.mutableCopy;
    UIFont *font;
    if (allBoldFont) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont systemFontOfSize:fontSize];
    }

    [attributeDictionary setValue:font forKey:NSFontAttributeName];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];

    CGFloat lineHeightMultiple = [self titleLineHeight] / font.lineHeight;
    paragraphStyle.minimumLineHeight = [self titleLineHeight];
    paragraphStyle.maximumLineHeight = [self titleLineHeight];
    paragraphStyle.lineHeightMultiple = lineHeightMultiple;

    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [attributeDictionary setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributeDictionary setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return attributeDictionary.copy;
}

+ (CGFloat)titleLineHeight
{
    return 19;
}

@end

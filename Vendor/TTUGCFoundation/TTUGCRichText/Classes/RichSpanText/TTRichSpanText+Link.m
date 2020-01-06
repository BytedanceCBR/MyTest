//
//  TTRichSpanText+Link.m
//  Article
//
//  Created by Jiyee Sheng on 26/10/2017.
//
//

#import "TTRichSpanText+Link.h"
#import "TTUGCEmojiParser.h"
#import <objc/runtime.h>
#import "TTBaseMacro.h"
#import "NSDictionary+TTAdditions.h"

static char kReplaceLinksAsInactiveLinksKey;

@implementation TTRichSpanText (Link)

- (void)setReplaceLinksAsInactiveLinks:(BOOL)replaceLinksAsInactiveLinks {
    objc_setAssociatedObject(self, &kReplaceLinksAsInactiveLinksKey, @(replaceLinksAsInactiveLinks), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)replaceLinksAsInactiveLinks {
    return [objc_getAssociatedObject(self, &kReplaceLinksAsInactiveLinksKey) boolValue];
}

- (NSUInteger)numberOfWhitelistLinks {
    NSUInteger maxLength = self.text.length;
    TTRichSpans *richSpans = self.richSpans;

    NSUInteger number = 0;
    if (richSpans.links.count == 0) {
        return number;
    }

    for (TTRichSpanLink *link in richSpans.links) {
        if ([self ifMatchCorrectLinkType:link.type] && !isEmptyString(link.text)
            && link.start + link.length <= maxLength) {
            number++;
        }
    }

    return number;
}

#pragma mark - replace methods

- (TTRichSpanText *)replaceWhitelistLinks {
    self.replaceLinksAsInactiveLinks = NO;

    TTRichSpanText *richSpanTextWithReplacedWhitelistLink = [[TTRichSpanText alloc] initWithText:self.replacedText richSpanLinks:self.replacedRichSpanLinks imageInfoModelDictionary:self.richSpans.imageInfoModesDict];

    return richSpanTextWithReplacedWhitelistLink;
}

- (TTRichSpanText *)replaceWhitelistLinksAsInactiveLinks {
    self.replaceLinksAsInactiveLinks = YES;

    TTRichSpanText *richSpanTextWithReplacedWhitelistLink = [[TTRichSpanText alloc] initWithText:self.replacedText richSpanLinks:self.replacedRichSpanLinks imageInfoModelDictionary:self.richSpans.imageInfoModesDict];

    return richSpanTextWithReplacedWhitelistLink;
}

- (NSString *)replacedText {
    NSUInteger maxLength = self.text.length;
    NSString *text = self.text;
    TTRichSpans *richSpans = self.richSpans;

    if (richSpans.links.count == 0) {
        return text;
    }

    NSArray <TTRichSpanLink *> *richSpanLinks = [self sortedRichSpanLinks:richSpans.links];

    NSInteger offset = 0;
    for (TTRichSpanLink *link in richSpanLinks) {
        if ([self ifMatchCorrectLinkType:link.type] && !isEmptyString(link.text)
            && link.start + link.length <= maxLength) {
            NSInteger linkStart = link.start - offset;
            if (linkStart < 0) {
                linkStart = 0;
            }
            NSUInteger start = linkStart;
            NSUInteger length = link.length;
            NSString *replaceText = [self replacementText:link.text linkType:link.type linkFlagType:link.flagType];
            offset += link.length - replaceText.length;
            text = [text stringByReplacingCharactersInRange:NSMakeRange(start, length) withString:replaceText];
        }
    }

    return text;
}


- (NSArray <TTRichSpanLink *> *)replacedRichSpanLinks {
    NSUInteger maxLength = self.text.length;
    NSString *text = self.text;
    TTRichSpans *richSpans = self.richSpans;

    if (richSpans.links.count == 0) {
        return nil;
    }

    NSArray <TTRichSpanLink *> *richSpanLinks = [self sortedRichSpanLinks:richSpans.links];

    NSMutableArray <TTRichSpanLink *> *replacedLinkRichSpanLinks = [[NSMutableArray alloc] initWithCapacity:richSpanLinks.count];
    NSInteger offset = 0;
    for (TTRichSpanLink *link in richSpanLinks) {
        if (link.start + link.length <= maxLength) {
            NSString *content = [text substringWithRange:NSMakeRange(link.start, link.length)];
            NSInteger linkStart = link.start - offset;
            if (linkStart < 0) {
                linkStart = 0;
            }
            NSUInteger start = linkStart;
            NSUInteger length = link.length;

            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:link.userInfo];
            // 如果是网页链接，替换为 link.text 字符
            if ([self ifMatchCorrectLinkType:link.type] && !isEmptyString(link.text)) {
                NSString *replaceText = [self replacementText:link.text linkType:link.type linkFlagType:link.flagType];
                offset += link.length - replaceText.length;
                length = replaceText.length;
                [userInfo setValue:content forKey:@"content"];
            }

            TTRichSpanLink *replacedLink = [[TTRichSpanLink alloc] initWithStart:start length:length link:link.link text:link.text imageInfoModels:link.imageInfoModels type:link.type flagType:link.flagType];

            replacedLink.userInfo = userInfo;
            replacedLink.idStr = link.idStr;
            [replacedLinkRichSpanLinks addObject:replacedLink];
        }
    }

    return replacedLinkRichSpanLinks;
}

#pragma mark - restore methods

- (TTRichSpanText *)restoreWhitelistLinks {
    TTRichSpanText *richSpanTextWithRestoredWhitelistLink = [[TTRichSpanText alloc] initWithText:self.restoredText richSpanLinks:self.restoredRichSpanLinks imageInfoModelDictionary:self.richSpans.imageInfoModesDict];

    return richSpanTextWithRestoredWhitelistLink;
}

- (NSString *)restoredText {
    NSUInteger maxLength = self.text.length;
    NSString *text = self.text;
    TTRichSpans *richSpans = self.richSpans;

    if (richSpans.links.count == 0) {
        return text;
    }

    NSArray <TTRichSpanLink *> *richSpanLinks = [self sortedRichSpanLinks:richSpans.links];

    NSInteger offset = 0;
    for (TTRichSpanLink *link in richSpanLinks) {
        if ([self ifMatchCorrectLinkType:link.type] && !isEmptyString(link.link)
            && link.start + link.length <= maxLength) {
            NSString *replaceText = [self replacementText:link.text linkType:link.type linkFlagType:link.flagType];
            NSString *content = link.userInfo[@"content"];

            if (isEmptyString(content)) {
                continue;
            }

            NSInteger linkStart = link.start + offset;
            if (linkStart < 0) {
                linkStart = 0;
            }
            NSUInteger start = linkStart;
            NSUInteger length = replaceText.length;
            offset += content.length - replaceText.length;
            text = [text stringByReplacingCharactersInRange:NSMakeRange(start, length) withString:content];
        }
    }

    return text;
}

- (NSArray <TTRichSpanLink *> *)restoredRichSpanLinks {
    NSUInteger maxLength = self.text.length;
    TTRichSpans *richSpans = self.richSpans;

    if (richSpans.links.count == 0) {
        return nil;
    }

    NSArray <TTRichSpanLink *> *richSpanLinks = [self sortedRichSpanLinks:richSpans.links];

    NSInteger offset = 0;
    NSMutableArray <TTRichSpanLink *> *replacedLinkRichSpanLinks = [[NSMutableArray alloc] initWithCapacity:richSpanLinks.count];
    for (TTRichSpanLink *link in richSpanLinks) {
        if (link.start + link.length <= maxLength) {
            NSInteger linkStart = link.start + offset;
            if (linkStart < 0) {
                linkStart = 0;
            }
            NSUInteger start = linkStart;
            NSUInteger length = link.length;
            NSString *content = link.userInfo[@"content"];

            // 如果是网页链接，替换为 link.text 字符
            if ([self ifMatchCorrectLinkType:link.type] && !isEmptyString(content)) {
                length = content.length;
                NSString *replaceText = [self replacementText:link.text linkType:link.type linkFlagType:link.flagType];
                offset += content.length - replaceText.length;
            }

            TTRichSpanLink *replacedLink = [[TTRichSpanLink alloc] initWithStart:start length:length link:link.link text:link.text imageInfoModels:link.imageInfoModels type:link.type flagType:link.flagType];
            replacedLink.userInfo = link.userInfo;
            replacedLink.idStr = link.idStr;
            [replacedLinkRichSpanLinks addObject:replacedLink];
        }
    }

    return replacedLinkRichSpanLinks;
}

#pragma mark - utils

- (NSString *)replacementText:(NSString *)text linkType:(TTRichSpanLinkType)linkType linkFlagType:(TTRichSpanLinkFlagType)linkFlagType {
    if (isEmptyString(text)) return nil;

    if (linkType == TTRichSpanLinkTypeLink || linkType == TTRichSpanLinkTypeMicroApp || linkType == TTRichSpanLinkTypeMicroGame) {
        if (linkFlagType & TTRichSpanLinkFlagTypeHideIcon) { // 不需要拼接前面的icon
            return text;
        }

        if (linkType == TTRichSpanLinkTypeLink) {
            NSString *link = self.replaceLinksAsInactiveLinks ? kTTUGCEmojiInactiveLinkReplacementText : kTTUGCEmojiLinkReplacementText;
            return [NSString stringWithFormat:@"%@%@", link, text];
        } else if (linkType == TTRichSpanLinkTypeMicroApp || linkType == TTRichSpanLinkTypeMicroGame) {
            NSString *link = self.replaceLinksAsInactiveLinks ? kTTUGCEmojiInactiveMicroAppReplacementText : kTTUGCEmojiMicroAppReplacementText;
            return [NSString stringWithFormat:@"%@%@", link, text];
        }
    }
    return nil;
}

- (BOOL)ifMatchCorrectLinkType:(TTRichSpanLinkType)linkType {
    return (linkType == TTRichSpanLinkTypeLink || linkType == TTRichSpanLinkTypeMicroApp || linkType == TTRichSpanLinkTypeMicroGame);
}

@end

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
        if (link.type == TTRichSpanLinkTypeLink && !isEmptyString(link.text)
            && link.start + link.length <= maxLength) {
            number++;
        }
    }

    return number;
}

#pragma mark - replace methods

- (TTRichSpanText *)replaceWhitelistLinks {
    self.replaceLinksAsInactiveLinks = NO;

    TTRichSpanText *richSpanTextWithReplacedWhitelistLink = [[TTRichSpanText alloc] initWithText:self.replacedText richSpanLinks:self.replacedRichSpanLinks];

    return richSpanTextWithReplacedWhitelistLink;
}

- (TTRichSpanText *)replaceWhitelistLinksAsInactiveLinks {
    self.replaceLinksAsInactiveLinks = YES;

    TTRichSpanText *richSpanTextWithReplacedWhitelistLink = [[TTRichSpanText alloc] initWithText:self.replacedText richSpanLinks:self.replacedRichSpanLinks];

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

    NSUInteger offset = 0;
    for (TTRichSpanLink *link in richSpanLinks) {
        if (link.type == TTRichSpanLinkTypeLink && !isEmptyString(link.text)
            && link.start + link.length <= maxLength) {
            NSUInteger start = link.start - offset;
            NSUInteger length = link.length;
            NSString *replaceText = [self replacementText:link.text];
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
    NSUInteger offset = 0;
    for (TTRichSpanLink *link in richSpanLinks) {
        if (link.start + link.length <= maxLength) {
            NSString *content = [text substringWithRange:NSMakeRange(link.start, link.length)];
            NSUInteger start = link.start - offset;
            NSUInteger length = link.length;

            // 如果是网页链接，替换为 link.text 字符
            if (link.type == TTRichSpanLinkTypeLink && !isEmptyString(link.text)) {
                NSString *replaceText = [self replacementText:link.text];
                offset += link.length - replaceText.length;
                length = replaceText.length;
            }

            TTRichSpanLink *replacedLink = [[TTRichSpanLink alloc] initWithStart:start length:length link:link.link text:link.text type:link.type];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:link.userInfo];
            [userInfo setValue:content forKey:@"content"];
            replacedLink.userInfo = userInfo;
            [replacedLinkRichSpanLinks addObject:replacedLink];
        }
    }

    return replacedLinkRichSpanLinks;
}

#pragma mark - restore methods

- (TTRichSpanText *)restoreWhitelistLinks {
    TTRichSpanText *richSpanTextWithRestoredWhitelistLink = [[TTRichSpanText alloc] initWithText:self.restoredText richSpanLinks:self.restoredRichSpanLinks];

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

    NSUInteger offset = 0;
    for (TTRichSpanLink *link in richSpanLinks) {
        if (link.type == TTRichSpanLinkTypeLink && !isEmptyString(link.link)
            && link.start + link.length <= maxLength) {
            NSString *replaceText = [self replacementText:link.text];
            NSString *content = link.userInfo[@"content"];

            if (isEmptyString(content)) {
                continue;
            }

            NSUInteger start = link.start + offset;
            NSUInteger length = replaceText.length;
            offset += content.length - replaceText.length;
            text = [text stringByReplacingCharactersInRange:NSMakeRange(start, length) withString:content];
        }
    }

    return text;
}

- (NSArray <TTRichSpanLink *> *)restoredRichSpanLinks {
    NSUInteger maxLength = self.text.length;
    NSString *text = self.text;
    TTRichSpans *richSpans = self.richSpans;

    if (richSpans.links.count == 0) {
        return nil;
    }

    NSArray <TTRichSpanLink *> *richSpanLinks = [self sortedRichSpanLinks:richSpans.links];

    NSUInteger offset = 0;
    NSMutableArray <TTRichSpanLink *> *replacedLinkRichSpanLinks = [[NSMutableArray alloc] initWithCapacity:richSpanLinks.count];
    for (TTRichSpanLink *link in richSpanLinks) {
        if (link.start + link.length <= maxLength) {
            NSUInteger start = link.start + offset;
            NSUInteger length = link.length;
            NSString *content = link.userInfo[@"content"];

            // 如果是网页链接，替换为 link.text 字符
            if (link.type == TTRichSpanLinkTypeLink && !isEmptyString(content)) {
                length = content.length;
                NSString *replaceText = [self replacementText:link.text];
                offset += content.length - replaceText.length;
            }

            TTRichSpanLink *replacedLink = [[TTRichSpanLink alloc] initWithStart:start length:length link:link.link text:link.text type:link.type];
            replacedLink.userInfo = link.userInfo;
            [replacedLinkRichSpanLinks addObject:replacedLink];
        }
    }

    return replacedLinkRichSpanLinks;
}

#pragma mark - utils

- (NSString *)replacementText:(NSString *)text {
    if (isEmptyString(text)) return nil;

    NSString *link = self.replaceLinksAsInactiveLinks ? kTTUGCEmojiInactiveLinkReplacementText : kTTUGCEmojiLinkReplacementText;
    return [NSString stringWithFormat:@"%@%@", link, text];
}

- (NSArray <TTRichSpanLink *> *)sortedRichSpanLinks:(NSArray <TTRichSpanLink *> *)richSpanLinks {
    return [richSpanLinks sortedArrayUsingComparator:^NSComparisonResult(TTRichSpanLink *link1, TTRichSpanLink *link2) {
        if (link1.start < link2.start) {
            return NSOrderedAscending;
        } else if (link1.start > link2.start) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

@end

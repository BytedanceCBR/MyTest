//
//  TTRichSpanText+Image.m
//  TTUGCFoundation-TTUGCRichText
//
//  Created by ranny_90 on 2018/3/20.
//

#import "TTRichSpanText+Image.h"
#import "TTUGCEmojiParser.h"
#import <objc/runtime.h>
#import "TTBaseMacro.h"
#import "NSDictionary+TTAdditions.h"

@implementation TTRichSpanText (Image)

- (NSUInteger)numberOfImageLinks {
    NSUInteger maxLength = self.text.length;
    TTRichSpans *richSpans = self.richSpans;

    NSUInteger number = 0;
    if (richSpans.links.count == 0) {
        return number;
    }

    for (TTRichSpanLink *link in richSpans.links) {
        if (link.type == TTRichSpanLinkTypeImage && !isEmptyString(link.text)
            && link.start + link.length <= maxLength) {
            number++;
        }
    }

    return number;
}

#pragma mark - replace methods

- (TTRichSpanText *)replaceImageLinksWithIgnoreFlag:(BOOL)ignoreFlag {

    TTRichSpanText *richSpanTextWithReplacedWhitelistLink = [[TTRichSpanText alloc] initWithText:[self replacedImageTextWithIgnoreFlag:ignoreFlag] richSpanLinks:[self replacedImageRichSpanLinksWithIgnoreFlag:ignoreFlag] imageInfoModelDictionary:self.richSpans.imageInfoModesDict];

    return richSpanTextWithReplacedWhitelistLink;
}


- (NSString *)replacedImageTextWithIgnoreFlag:(BOOL)ignoreFlag {
    NSUInteger maxLength = self.text.length;
    NSString *text = self.text;
    TTRichSpans *richSpans = self.richSpans;

    if (richSpans.links.count == 0) {
        return text;
    }

    NSArray <TTRichSpanLink *> *richSpanLinks = [self sortedImageRichSpanLinks:richSpans.links];

    NSInteger offset = 0;
    for (TTRichSpanLink *link in richSpanLinks) {
        if (link.type == TTRichSpanLinkTypeImage && !isEmptyString(link.text) && (link.flagType == TTRichSpanLinkFlagTypeDefault || ignoreFlag)
            && link.start + link.length <= maxLength) {
            NSInteger linkStart = link.start - offset;
            if (linkStart < 0) {
                linkStart = 0;
            }
            NSUInteger start = linkStart;
            NSUInteger length = link.length;
            NSString *replaceText = [self replacementImageText:link.text linkFlagType:link.flagType];
            offset += link.length - replaceText.length;

            text = [text stringByReplacingCharactersInRange:NSMakeRange(start, length) withString:replaceText];

        }
    }

    return text;
}

- (NSArray <TTRichSpanLink *> *)replacedImageRichSpanLinksWithIgnoreFlag:(BOOL)ignoreFlag  {
    NSUInteger maxLength = self.text.length;
    NSString *text = self.text;
    TTRichSpans *richSpans = self.richSpans;

    if (richSpans.links.count == 0) {
        return nil;
    }

    NSArray <TTRichSpanLink *> *richSpanLinks = [self sortedImageRichSpanLinks:richSpans.links];

    NSMutableArray <TTRichSpanLink *> *replacedLinkRichSpanLinks = [[NSMutableArray alloc] initWithCapacity:richSpanLinks.count];
    NSInteger offset = 0;
    for (TTRichSpanLink *link in richSpanLinks) {
        if (link.start + link.length <= maxLength) {

            //此处注意content = nil / content = @"" 的情况？？？？？？？？？？？？
            NSString *content = [text substringWithRange:NSMakeRange(link.start, link.length)];
            NSInteger linkStart = link.start - offset;
            if (linkStart < 0) {
                linkStart = 0;
            }
            NSUInteger start = linkStart;
            NSUInteger length = link.length;
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:link.userInfo];

            if (link.type == TTRichSpanLinkTypeImage && !isEmptyString(link.text) && (link.flagType == TTRichSpanLinkFlagTypeDefault || ignoreFlag)) {
                NSString *replaceText = [self replacementImageText:link.text linkFlagType:link.flagType];
                offset += link.length - replaceText.length;
                length = replaceText.length;
                [userInfo setValue:content forKey:@"content"];
            }

            TTRichSpanLink *replacedLink = [[TTRichSpanLink alloc] initWithStart:start length:length link:link.link text:link.text imageInfoModels:link.imageInfoModels type:link.type flagType:link.flagType];
            replacedLink.userInfo = userInfo;
            [replacedLinkRichSpanLinks addObject:replacedLink];
        }
    }

    return replacedLinkRichSpanLinks;
}

#pragma mark - restore methods

- (TTRichSpanText *)restoreImageLinksWithIgnoreFlag:(BOOL)ignoreFlag {
    TTRichSpanText *richSpanTextWithRestoredWhitelistLink = [[TTRichSpanText alloc] initWithText:[self restoredImageTextWithIgnoreFlag:ignoreFlag] richSpanLinks:[self restoredImageRichSpanLinksWithIgnoreFlag:ignoreFlag] imageInfoModelDictionary:self.richSpans.imageInfoModesDict];

    return richSpanTextWithRestoredWhitelistLink;
}



- (NSString *)restoredImageTextWithIgnoreFlag:(BOOL)ignoreFlag  {
    NSUInteger maxLength = self.text.length;
    NSString *text = self.text;
    TTRichSpans *richSpans = self.richSpans;

    if (richSpans.links.count == 0) {
        return text;
    }

    NSArray <TTRichSpanLink *> *richSpanLinks = [self sortedImageRichSpanLinks:richSpans.links];

    NSInteger offset = 0;
    for (TTRichSpanLink *link in richSpanLinks) {
        if (link.type == TTRichSpanLinkTypeImage && !isEmptyString(link.text) && (link.flagType == TTRichSpanLinkFlagTypeDefault || ignoreFlag)
            && link.start + link.length <= maxLength) {
            NSString *replaceText = [self replacementImageText:link.text linkFlagType:link.flagType];
            NSString *content = link.userInfo[@"content"]?:@"";

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

- (NSArray <TTRichSpanLink *> *)restoredImageRichSpanLinksWithIgnoreFlag:(BOOL)ignoreFlag  {
    NSUInteger maxLength = self.text.length;
    TTRichSpans *richSpans = self.richSpans;

    if (richSpans.links.count == 0) {
        return nil;
    }

    NSArray <TTRichSpanLink *> *richSpanLinks = [self sortedImageRichSpanLinks:richSpans.links];

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

            if (link.type == TTRichSpanLinkTypeImage && (link.flagType == TTRichSpanLinkFlagTypeDefault || ignoreFlag)) {
                NSString *content = link.userInfo[@"content"];
                length = content.length;
                NSString *replaceText = [self replacementImageText:link.text linkFlagType:link.flagType];
                offset += content.length - replaceText.length;
            }

            TTRichSpanLink *replacedLink = [[TTRichSpanLink alloc] initWithStart:start length:length link:link.link text:link.text imageInfoModels:link.imageInfoModels type:link.type flagType:link.flagType];
            replacedLink.userInfo = link.userInfo;
            [replacedLinkRichSpanLinks addObject:replacedLink];
        }
    }

    return replacedLinkRichSpanLinks;
}

#pragma mark - utils

- (NSString *)replacementImageText:(NSString *)text linkFlagType:(TTRichSpanLinkFlagType)linkFlagType {
    if (isEmptyString(text)) return nil;

    if (linkFlagType & TTRichSpanLinkFlagTypeHideIcon) { // 不需要拼接前面的icon
        return text;
    }

    NSString *link = kTTUGCEmojiImageReplacementText;
    return [NSString stringWithFormat:@"%@%@", link, text];
}

- (NSArray <TTRichSpanLink *> *)sortedImageRichSpanLinks:(NSArray <TTRichSpanLink *> *)richSpanLinks {
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

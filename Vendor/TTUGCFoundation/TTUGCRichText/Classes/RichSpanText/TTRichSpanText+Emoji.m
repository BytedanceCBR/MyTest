//
//  TTRichSpanText+Emoji.m
//  Article
//
//  Created by Jiyee Sheng on 12/11/2017.
//
//

#import "TTRichSpanText+Emoji.h"
#import "TTUGCEmojiParser.h"


@implementation TTRichSpanText (Emoji)

- (NSArray <TTRichSpanLink *> *)richSpanLinksOfAttributedString {
    NSArray <NSValue *> *emojiRangeValues = [TTUGCEmojiParser parseEmojiRangeValues:self.text];

    NSUInteger maxLength = self.text.length;
    TTRichSpans *richSpans = self.richSpans;

    if (richSpans.links.count == 0) {
        return nil;
    }

    NSArray <TTRichSpanLink *> *richSpanLinks = [self sortedRichSpanLinks:richSpans.links];

    NSMutableArray <TTRichSpanLink *> *transformedRichSpanLinks = [[NSMutableArray alloc] initWithCapacity:richSpanLinks.count];
    for (TTRichSpanLink *link in richSpanLinks) {
        if (link.start + link.length <= maxLength) {
            NSUInteger start = link.start - [self offsetAheadLinkLocation:link.start emojiRangeValues:emojiRangeValues];
            NSUInteger length = link.length - [self offsetInLinkLocation:link.start length:link.length emojiRangeValues:emojiRangeValues];

            TTRichSpanLink *replacedLink = [[TTRichSpanLink alloc] initWithStart:start length:length link:link.link text:link.text type:link.type];
            [transformedRichSpanLinks addObject:replacedLink];
        }
    }

    return transformedRichSpanLinks;
}

- (NSUInteger)offsetAheadLinkLocation:(NSUInteger)location emojiRangeValues:(NSArray <NSValue *> *)emojiRangeValues {
    NSUInteger offset = 0;

    for (NSUInteger i = 0; i < emojiRangeValues.count; ++i) {
        if ([emojiRangeValues[i] isKindOfClass:[NSValue class]]) {
            NSRange emojiRange = [emojiRangeValues[i] rangeValue];

            if (emojiRange.location + emojiRange.length <= location) {
                offset += emojiRange.length - 1;
            }
        }
    }

    return offset;
}

- (NSUInteger)offsetInLinkLocation:(NSUInteger)location length:(NSUInteger)length emojiRangeValues:(NSArray <NSValue *> *)emojiRangeValues {
    NSUInteger offset = 0;

    for (NSUInteger i = 0; i < emojiRangeValues.count; ++i) {
        if ([emojiRangeValues[i] isKindOfClass:[NSValue class]]) {
            NSRange emojiRange = [emojiRangeValues[i] rangeValue];

            if (emojiRange.location + emojiRange.length > location && emojiRange.location + emojiRange.length < location + length) {
                offset += emojiRange.length - 1;
            }
        }
    }

    return offset;
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

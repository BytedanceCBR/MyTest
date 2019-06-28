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
            NSInteger start = link.start - [self offsetAheadLinkLocation:link.start emojiRangeValues:emojiRangeValues];
            NSInteger length = link.length - [self offsetInLinkLocation:link.start length:link.length emojiRangeValues:emojiRangeValues];
            //对于某些richspan数据错误的情况，eg。[我要静静](120，6)，link:(122，4)会导致上面那个offsetInLink方法返回5，然后导致length = -1
            //错误数据：http://web_admin.byted.org/pirate/stream/get_history_detail/?device_id=47850862307&start_time=1527161603720&end_time=1527161603720
            //先按下面做了保护
            length = MAX(length, 0);
            start = MAX(start, 0);
            
            if (link.length == 0) {
                length = 0;
            }
            TTRichSpanLink *replacedLink = [[TTRichSpanLink alloc] initWithStart:start length:length link:link.link text:link.text imageInfoModels:link.imageInfoModels type:link.type flagType:link.flagType];
            replacedLink.userInfo = link.userInfo;
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

            if (emojiRange.location + emojiRange.length > location && emojiRange.location + emojiRange.length <= location + length) {
                offset += emojiRange.length - 1;
            }
        }
    }

    return offset;
}

@end

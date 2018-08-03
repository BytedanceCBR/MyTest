//
//  TTRichSpanText.m
//  Article
//
//  Created by 徐霜晴 on 17/3/13.
//
//

#import "TTRichSpanText.h"
#import "TTBaseMacro.h"
#import <objc/runtime.h>

@interface TTRichSpanLink ()

@property (nonatomic, assign) NSUInteger start;
@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) TTRichSpanLinkType type;

@end

@implementation TTRichSpanLink

- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link {
    self = [super init];
    if (self) {
        _start = start;
        _length = length;
        _link = [link copy];
        _text = nil;
        _type = TTRichSpanLinkTypeUnknown;
    }

    return self;
}

- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link text:(NSString *)text type:(TTRichSpanLinkType)type {
    self = [super init];
    if (self) {
        _start = start;
        _length = length;
        _link = [link copy];
        _text = text;
        _type = type;
    }

    return self;
}

+ (NSDictionary *)dictionaryForRichSpanLink:(TTRichSpanLink *)link {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@(link.start) forKey:@"start"];
    [dict setValue:@(link.length) forKey:@"length"];
    if (link.link) {
        [dict setValue:link.link forKey:@"link"];
    }
    if (link.text) {
        [dict setValue:link.text forKey:@"text"];
    }
    if (link.type != TTRichSpanLinkTypeUnknown) {
        [dict setValue:@(link.type) forKey:@"type"];
    }
    return [dict copy];
}

+ (NSArray<NSDictionary *> *)arrayForRichSpanLinks:(NSArray<TTRichSpanLink *> *)links {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = [self dictionaryForRichSpanLink:obj];
        [array addObject:dic];
    }];
    return [array copy];
}

+ (NSString *)JSONStringForRichSpanLinks:(NSArray<TTRichSpanLink *> *)links {
    NSArray *spanDicArray = [self arrayForRichSpanLinks:links];
    if (!spanDicArray) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:spanDicArray options:0 error:&error];
    if (!jsonData) {
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (TTRichSpanLink *)richSpanLinkForDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (![dictionary objectForKey:@"start"] || ![dictionary objectForKey:@"length"]) {
        return nil;
    }
    TTRichSpanLink *richSpanLink = [[TTRichSpanLink alloc] initWithStart:[[dictionary valueForKey:@"start"] integerValue]
                                                                  length:[[dictionary valueForKey:@"length"] integerValue]
                                                                    link:[dictionary valueForKey:@"link"]
                                                                    text:[dictionary valueForKey:@"text"]
                                                                    type:[[dictionary valueForKey:@"type"] integerValue]];
    return richSpanLink;
}

+ (NSArray<TTRichSpanLink *> *)richSpanLinksForDictionaries:(NSArray<NSDictionary *>*)linkDictionaries {
    if (!linkDictionaries || ![linkDictionaries isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray<TTRichSpanLink *> *richSpanLinks = [[NSMutableArray alloc] initWithCapacity:[linkDictionaries count]];
    [linkDictionaries enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTRichSpanLink *richSpanLink = [self richSpanLinkForDictionary:obj];
        [richSpanLinks addObject:richSpanLink];
    }];
    return [richSpanLinks copy];
}

+ (NSArray<TTRichSpanLink *> *)richSpanLinksForJSONString:(NSString *)linksJSONString {
    if (!isEmptyString(linksJSONString)) {
        return nil;
    }
    NSData *data = [linksJSONString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    NSError *error;
    NSArray *richSpansArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!richSpansArray) {
        return nil;
    }
    return [self richSpanLinksForDictionaries:richSpansArray];
}

@end

static NSString * const TTRichSpansKeyLinks = @"links";

@interface TTRichSpans ()

@property (nonatomic, strong, readwrite) NSMutableArray<TTRichSpanLink *> *innerLinks;

@end

@implementation TTRichSpans

- (instancetype)initWithRichSpanLinks:(NSArray<TTRichSpanLink *> *)links {
    self = [super init];
    if (self) {
        self.innerLinks = [links mutableCopy];
    }
    return self;
}

- (NSArray<TTRichSpanLink *> *)links {
    return [self.innerLinks copy];
}

+ (NSDictionary *)dictionaryForRichSpans:(TTRichSpans *)richSpans {
    NSMutableDictionary *richSpansDic = [[NSMutableDictionary alloc] init];
    NSArray<NSDictionary *> *links = [TTRichSpanLink arrayForRichSpanLinks:richSpans.links];
    if ([links count] > 0) {
        [richSpansDic setValue:links forKey:TTRichSpansKeyLinks];
    }
    return [richSpansDic copy];
}

+ (NSString *)JSONStringForRichSpans:(TTRichSpans *)richSpans {
    NSDictionary *richSpansDic = [TTRichSpans dictionaryForRichSpans:richSpans];
    if (!richSpansDic) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:richSpansDic options:0 error:&error];
    if (!jsonData) {
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (TTRichSpans *)richSpansForDictionary:(NSDictionary *)dictionary {
    NSArray<NSDictionary *> *linkDictionaries = [dictionary valueForKey:TTRichSpansKeyLinks];
    if (!linkDictionaries || ![linkDictionaries isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSArray<TTRichSpanLink *> *links = [TTRichSpanLink richSpanLinksForDictionaries:linkDictionaries];
    if ([links count] == 0) {
        return nil;
    }
    TTRichSpans *richSpans = [[TTRichSpans alloc] init];
    richSpans.innerLinks = [links mutableCopy];
    return richSpans;
}

+ (TTRichSpans *)richSpansForJSONString:(NSString *)JSONString {
    if (isEmptyString(JSONString)) {
        return nil;
    }
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    NSError *error;
    NSDictionary *richSpansDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!richSpansDic || ![richSpansDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [TTRichSpans richSpansForDictionary:richSpansDic];
}

+ (NSString *)filterValidRichSpanString:(NSString *)richSpanString {
    if (isEmptyString(richSpanString)) {
        return nil;
    }

    TTRichSpans *contentRichSpans = [TTRichSpans richSpansForJSONString:richSpanString];
    if (!contentRichSpans) {
        return nil;
    }

    TTRichSpans *optimizeRichSpans = nil;
    if (!SSIsEmptyArray(contentRichSpans.links) ) {

        NSMutableArray *richSpanLinkArray = [[NSMutableArray alloc] init];

        for (TTRichSpanLink *link in contentRichSpans.links) {
            if (link.type >= TTRichSpanLinkTypeQuotedCommentUser) {
                link.type = TTRichSpanLinkTypeUnknown;
            }
            [richSpanLinkArray addObject:link];
        }

        optimizeRichSpans = [[TTRichSpans alloc] initWithRichSpanLinks:richSpanLinkArray];
    }

    NSString *optimizeContentRichSpanString = nil;
    if (optimizeRichSpans) {
        optimizeContentRichSpanString = [TTRichSpans JSONStringForRichSpans:optimizeRichSpans];
    }
    return optimizeContentRichSpanString;
}

+ (NSInteger)richSpanCountRichSpans:(TTRichSpans *)richSpans forRichSpanLinkType:(TTRichSpanLinkType)linkType{
    
    if(!richSpans || SSIsEmptyArray(richSpans.links)){
        return 0;
    }
    
    __block NSInteger finalCount = 0;
    
    [richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj && [obj isKindOfClass:[TTRichSpanLink class]]){
            if(obj.type == linkType){
                finalCount += 1;
            }
        }
    }];
    
    return finalCount;
}

@end

@interface TTRichSpanText ()

@property (nonatomic, copy, readwrite) NSString *text;
@property (nonatomic, strong, readwrite) TTRichSpans *richSpans;

@end

@implementation TTRichSpanText

- (instancetype)initWithText:(NSString *)text richSpansJSONString:(NSString *)richSpansJSONString {
    self = [super init];
    if (self) {
        return [self initWithText:text richSpans:[TTRichSpans richSpansForJSONString:richSpansJSONString]];
    }

    return self;
}

- (instancetype)initWithText:(NSString *)text richSpans:(TTRichSpans *)richSpans {
    self = [super init];
    if (self) {
        return [self initWithText:text richSpanLinks:richSpans.links];
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text richSpanLinks:(NSArray <TTRichSpanLink *>*)links {
    self = [super init];
    if (self) {
        self.text = text;
        NSMutableArray<TTRichSpanLink *> *finalLinks = [[NSMutableArray alloc] initWithCapacity:[links count]];
        [links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[TTRichSpanLink class]]) {
                if ((obj.start >= 0) &&
                    (obj.length >= 0) &&
                    (obj.start + obj.length <= [text length])) {
                    [finalLinks addObject:obj];
                }
            }
        }];
        TTRichSpans *richSpans = [[TTRichSpans alloc] init];
        richSpans.innerLinks = finalLinks;
        self.richSpans = richSpans;
    }
    return self;
}

- (void)appendRichSpanText:(TTRichSpanText *)aRichSpanText {
    NSMutableArray<TTRichSpanLink *> *offsetLinks = [[NSMutableArray alloc] initWithCapacity:[aRichSpanText.richSpans.links count]];
    [aRichSpanText.richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            if ((obj.start >= 0) &&
                (obj.length >= 0) &&
                (obj.start + obj.length <= [aRichSpanText.text length])) {
                NSUInteger offset = [self.text length];
                TTRichSpanLink *offsetLink = [[TTRichSpanLink alloc] initWithStart:(obj.start + offset)
                                                                            length:obj.length
                                                                              link:obj.link
                                                                              text:obj.text
                                                                              type:obj.type];
                offsetLink.userInfo = obj.userInfo;
                [offsetLinks addObject:offsetLink];
            }
        }
    }];
    if (!isEmptyString(aRichSpanText.text)) {
        self.text = [self.text stringByAppendingString:aRichSpanText.text];
        [self.richSpans.innerLinks addObjectsFromArray:offsetLinks];
    }
}

- (void)insertRichSpanText:(TTRichSpanText *)aRichSpanText atIndex:(NSUInteger)atIndex {
    __block TTRichSpanLink *brokenLink = nil;
    [self.richSpans.innerLinks enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            if ((obj.start <= atIndex) &&
                (obj.start + obj.length <= atIndex)) {
                //Do Nothing
            }
            else if ((obj.start < atIndex) &&
                (obj.start + obj.length > atIndex)) {
                //Break
                brokenLink = obj;
            }
            else if ((obj.start >= atIndex)) {
                //Add Offset
                obj.start += aRichSpanText.text.length;
            }
        }
    }];

    if (brokenLink) {
        [self.richSpans.innerLinks removeObject:brokenLink];
    }

    NSMutableArray<TTRichSpanLink *> *insertLinks = [[NSMutableArray alloc] initWithCapacity:[aRichSpanText.richSpans.links count]];
    [aRichSpanText.richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            if ((obj.start >= 0) &&
                (obj.length >= 0) &&
                (obj.start + obj.length <= aRichSpanText.text.length)) {
                TTRichSpanLink *insertLink = [[TTRichSpanLink alloc] initWithStart:(atIndex + obj.start)
                                                                            length:obj.length
                                                                              link:obj.link
                                                                              text:obj.text
                                                                              type:obj.type];
                insertLink.userInfo = obj.userInfo;
                [insertLinks addObject:insertLink];
            }
        }
    }];

    if (!isEmptyString(aRichSpanText.text)) {
        self.text = [self.text stringByReplacingCharactersInRange:NSMakeRange(atIndex, 0) withString:aRichSpanText.text];
        [self.richSpans.innerLinks addObjectsFromArray:insertLinks];
    }
}

- (void)appendText:(NSString *)aText {
    if (!isEmptyString(aText)) {
        self.text  = [self.text stringByAppendingString:aText];
    }
}

- (void)insertText:(NSString *)aText atIndex:(NSUInteger)atIndex {
    __block TTRichSpanLink *brokenLink = nil;
    [self.richSpans.innerLinks enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            if ((obj.start <= atIndex) &&
                (obj.start + obj.length <= atIndex)) {
                //Do Nothing
            }
            else if ((obj.start < atIndex) &&
                     (obj.start + obj.length > atIndex)) {
                //Break
                brokenLink = obj;
            }
            else if ((obj.start >= atIndex)) {
                //Add Offset
                obj.start += [aText length];
            }
        }
    }];

    if (brokenLink) {
        [self.richSpans.innerLinks removeObject:brokenLink];
    }

    self.text = [self.text stringByReplacingCharactersInRange:NSMakeRange(atIndex, 0) withString:aText ?: @""];
}

- (NSArray <TTRichSpanLink *> *)replaceCharactersInRange:(NSRange)range withText:(NSString *)aText {
    NSMutableArray<TTRichSpanLink *> *brokenLinks = [[NSMutableArray alloc] init];
    [self.richSpans.innerLinks enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            if ((obj.start <= range.location) &&
                (obj.start + obj.length <= range.location)) {
                //Do Nothing
            }
            else if ((obj.start >= range.location + range.length) &&
                     (obj.start + obj.length >= range.location + range.length)) {
                //Add Offset
                obj.start += ([aText length] - range.length);
            }
            else {
                //Break
                [brokenLinks addObject:obj];
            }
        }
    }];

    [self.richSpans.innerLinks removeObjectsInArray:brokenLinks];

    self.text = [self.text stringByReplacingCharactersInRange:range withString:aText ?: @""];

    return brokenLinks;
}

- (void)trimmingCharactersInSet:(NSCharacterSet *)characterSet {
    [self trimmingLeftCharactersInSet:characterSet];
    [self trimmingRightCharactersInSet:characterSet];
}

- (void)trimmingLeftCharactersInSet:(NSCharacterSet *)characterSet {
    NSUInteger location = 0;
    NSUInteger length = [self.text length];
    unichar charBuffer[length];
    [self.text getCharacters:charBuffer];
    
    for ( ; location < length; location++) {
        if (![characterSet characterIsMember:charBuffer[location]]) {
            break;
        }
    }
    [self replaceCharactersInRange:NSMakeRange(0, location) withText:@""];
}

- (void)trimmingRightCharactersInSet:(NSCharacterSet *)characterSet {
    NSUInteger length = [self.text length];
    unichar charBuffer[length];
    [self.text getCharacters:charBuffer];
    for (; length > 0; length--) {
        if (![characterSet characterIsMember:charBuffer[length - 1]]) {
            break;
        }
    }
    [self replaceCharactersInRange:NSMakeRange(length, [self.text length] - length) withText:@""];
}

- (void)trimmingHashtagsWithStartIndex:(NSInteger)startIndex {
    __block TTRichSpanLink *firstHashtag = nil;
    [self.richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull link, NSUInteger idx, BOOL * _Nonnull stop) {
        if (link.type == TTRichSpanLinkTypeHashtag && link.start == startIndex) {
            firstHashtag = link;
            *stop = YES;
        }
    }];
    if (firstHashtag) {
        [self replaceCharactersInRange:NSMakeRange(firstHashtag.start, firstHashtag.length) withText:@""];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    NSString *text = self.text;
    NSMutableArray<TTRichSpanLink *> *links = [[NSMutableArray alloc] initWithCapacity:[self.richSpans.links count]];
    [self.richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRichSpanLink class]]) {
            if ((obj.start >= 0) &&
                (obj.length >= 0) &&
                (obj.start + obj.length <= [text length])) {
                TTRichSpanLink *link = [[TTRichSpanLink alloc] initWithStart:obj.start
                                                                      length:obj.length
                                                                        link:obj.link
                                                                        text:obj.text
                                                                        type:obj.type];
                link.userInfo = obj.userInfo;
                [links addObject:link];
            }
        }
    }];

    TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:text richSpanLinks:links];
    return richSpanText;
}

#pragma mark - detectAndAddLinks

- (void)detectAndAddLinks {
    if (isEmptyString(self.text)) {
        return;
    }
    
    BOOL isDetectLinks = [objc_getAssociatedObject(self, @selector(detectAndAddLinks)) boolValue];
    if (isDetectLinks) {
        return;
    }
    objc_setAssociatedObject(self, @selector(detectAndAddLinks), @(YES), OBJC_ASSOCIATION_ASSIGN);
    
    NSArray *matches = [[self dataDetector] matchesInString:self.text options:0 range:NSMakeRange(0, self.text.length)];
    NSArray<TTRichSpanLink *> *richSpansLinks = self.richSpans.links;
    
    if (matches.count > 0) {
        for (NSTextCheckingResult *result in matches) {
            NSRange linkRange = result.range;
            NSString *linkString = result.URL.absoluteString;
            if (NSMaxRange(linkRange) <= self.text.length) {
                if (![self linkRange:linkRange inRichSpansLinks:richSpansLinks]) {
                    TTRichSpanLink *detectedLink = [[TTRichSpanLink alloc] initWithStart:linkRange.location
                                                                                  length:linkRange.length
                                                                                    link:linkString
                                                                                    text:nil
                                                                                    type:TTRichSpanLinkTypeAutoDetectLink];
                    [self.richSpans.innerLinks addObject:detectedLink];
                }
            }
        }
    }
}

- (BOOL)linkRange:(NSRange)linkRange inRichSpansLinks:(NSArray<TTRichSpanLink *> *)richSpansLinks {
    BOOL inRichSpansLinks = NO;
    NSUInteger startInsertIndex = linkRange.location;
    NSUInteger endInsertIndex = linkRange.location + linkRange.length - 1;
    for (TTRichSpanLink *link in richSpansLinks) {
        NSUInteger startIndex = link.start;
        NSUInteger endIndex = link.start + link.length - 1;
        
        if (startInsertIndex >= startIndex && startInsertIndex <= endIndex) {
            inRichSpansLinks = YES;
            break;
        }
        if (endInsertIndex >= startIndex && endInsertIndex <= endIndex) {
            inRichSpansLinks = YES;
            break;
        }
    }
    
    return inRichSpansLinks;
}

- (NSDataDetector *)dataDetector {
    NSDataDetector *dataDetector = objc_getAssociatedObject(self, @selector(dataDetector));
    if (!dataDetector) {
        dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        objc_setAssociatedObject(self, @selector(dataDetector), dataDetector, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return dataDetector;
}

@end

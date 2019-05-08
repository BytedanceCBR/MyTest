//
//  TTUGCEmojiParser.m
//  Article
//
//  Created by Jiyee Sheng on 5/15/17.
//
//

#import <CoreText/CoreText.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTUGCEmojiParser.h"
#import "TTUGCEmojiTextAttachment.h"
#import "TTModuleBridge.h"
#import <BDTFactoryConfigurator/BDTFactoryConfigurator.h>
#import "TTBaseMacro.h"
#import "FRApiModel.h"
#import "TTLabelTextHelper.h"

@interface TTUGCEmoji : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *emojiId;
@property (nonatomic, strong) NSNumber *count;

@end

@implementation TTUGCEmoji

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.key forKey:@"key"];
    [coder encodeObject:self.emojiId forKey:@"emojiId"];
    [coder encodeObject:self.count forKey:@"count"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.key = [coder decodeObjectForKey:@"key"];
        self.emojiId = [coder decodeObjectForKey:@"emojiId"];
        self.count = [coder decodeObjectForKey:@"count"];
    }

    return self;
}

@end

typedef NS_ENUM(NSUInteger, TTUGCEmojiContext) {
    TTUGCEmojiCoreTextContext,
    TTUGCEmojiTextKitContext,
};

static CGFloat ascentCallback(void *ref) {
    TTUGCEmojiTextAttachment *textAttachment = (__bridge TTUGCEmojiTextAttachment *)ref;

    return textAttachment.emojiSize + textAttachment.descender;
}

static CGFloat descentCallback(void *ref) {
    TTUGCEmojiTextAttachment *textAttachment = (__bridge TTUGCEmojiTextAttachment *)ref;

    return textAttachment.descender;
}

static CGFloat widthCallback(void *ref) {
    TTUGCEmojiTextAttachment *textAttachment = (__bridge TTUGCEmojiTextAttachment *)ref;

    return textAttachment.coreTextImage.size.width / textAttachment.coreTextImage.size.height * textAttachment.emojiSize + textAttachment.padding * 2;
}

static void deallocationCallback(void *ref) {
    if (ref) {
        CFRelease((CFTypeRef)ref); // TTUGCEmojiTextAttachment
        ref = NULL;
    }
}

#define TTUsedEmojisKey @"TTUsedEmojiKey"
#define TTMostUsedEmojisKey @"TTMostUsedEmojiKey"
#define TTUserExpressionConfigSortArrayKey @"TTUserExpressionConfigSortArrayKey"
#define TTUserExpressionConfigRequestDateKey @"TTUserExpressionConfigRequestDateKey"

NSString *const kTTUGCEmojiLinkReplacementText = @"[链接]";
NSString *const kTTUGCEmojiInactiveLinkReplacementText = @"[链接2]";

static TTUGCEmojiParser *shareManager;
static NSRegularExpression *emojiRegex;

@interface TTUGCEmojiParser ()

@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *emojiDictionary;
@property (nonatomic, strong) NSArray <NSString *> *emojiSortArray;
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *emojiMappingDictionary; // 用于微博、微信表情映射
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *customEmojiDictionary; // 仅供内部字符替换，实现诸如网页链接之类的需求

@end

@implementation TTUGCEmojiParser

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[self alloc] init];
        NSString *emojiPattern = @"\\[[^ \\[\\]]+\\]"; // 表情文本正则表达式，形如 [微笑]
        emojiRegex = [NSRegularExpression regularExpressionWithPattern:emojiPattern
                                                               options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                 error:nil];

        [shareManager requestUserExpressionConfig];

        shareManager.customEmojiDictionary = @{
            kTTUGCEmojiLinkReplacementText : @"link",
            kTTUGCEmojiInactiveLinkReplacementText : @"link2",
        };
    });

    return shareManager;
}

+ (void)load
{
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTUGCEmojiParser.stringify" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        NSAttributedString *text = (NSAttributedString *)[params valueForKey:@"stringifyText"];
        NSString *result = nil;
        if ([text isKindOfClass:[NSAttributedString class]]) {
            result = [TTUGCEmojiParser stringify:text];
        }
        return result;
    }];
    
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTUGCEmojiParser.parseInTextKitContext" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        NSString *text = (NSString *)[params valueForKey:@"text"];
        CGFloat fontSize = (CGFloat) [(NSNumber *)[params valueForKey:@"fontSize"] doubleValue];
        NSAttributedString *result = nil;
        if (!isEmptyString(text)) {
            result = [TTUGCEmojiParser parseInTextKitContext:text fontSize:fontSize];
        }
        return result;
    }];

    [[BDTFactoryConfigurator sharedConfigurator] registerFactoryBlock:^NSAttributedString *(NSString *name, NSDictionary *info) {
        if ([name isEqualToString:@"TTUGCEmojiParser/parseInTextKitContext"]) {
            NSString *text = (NSString *)[info valueForKey:@"text"];
            CGFloat fontSize = (CGFloat) [(NSNumber *)[info valueForKey:@"fontSize"] doubleValue];
            NSAttributedString *result = nil;
            if (!isEmptyString(text)) {
                result = [TTUGCEmojiParser parseInTextKitContext:text fontSize:fontSize];
            }
            return result;
        }
        return nil;
    } forKey:@"TTUGC"];

    [[BDTFactoryConfigurator sharedConfigurator] registerFactoryBlock:^NSAttributedString *(NSString *name, NSDictionary *info) {
        if ([name isEqualToString:@"TTUGCEmojiParser/parseInCoreTextContext"]) {
            NSString *text = (NSString *)[info valueForKey:@"text"];
            CGFloat fontSize = (CGFloat) [(NSNumber *)[info valueForKey:@"fontSize"] doubleValue];
            NSAttributedString *result = nil;
            if (!isEmptyString(text)) {
                result = [TTUGCEmojiParser parseInCoreTextContext:text fontSize:fontSize];
            }
            return result;
        }
        return nil;
    } forKey:@"TTUGC"];
}

- (void)requestUserExpressionConfig {
    if (self.emojiSortArray) return;

    if (![self shouldRequestUserExpressionConfig]) {
        self.emojiSortArray = [[NSUserDefaults standardUserDefaults] arrayForKey:TTUserExpressionConfigSortArrayKey];
        return;
    }

//    FRUserExpressionConfigRequestModel *requestModel = [[FRUserExpressionConfigRequestModel alloc] init];
//
//    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
//        if (!error && [responseModel isKindOfClass:[FRUserExpressionConfigResponseModel class]]) {
//            FRUserExpressionConfigResponseModel *response = (FRUserExpressionConfigResponseModel *)responseModel;
//
//            NSMutableArray <NSString *> *sortArray = [[NSMutableArray alloc] init];
//            for (NSNumber *idx in response.data.default_seq) {
//                [sortArray addObject:[idx stringValue]];
//            }
//
//            self.emojiSortArray = [sortArray copy];
//
//            [[NSUserDefaults standardUserDefaults] setObject:[sortArray copy] forKey:TTUserExpressionConfigSortArrayKey];
//            [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:TTUserExpressionConfigRequestDateKey];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    }];
}

- (BOOL)shouldRequestUserExpressionConfig {
    NSArray *sortArray = [[NSUserDefaults standardUserDefaults] arrayForKey:TTUserExpressionConfigSortArrayKey];
    if (sortArray) {
        NSTimeInterval dateLast = [[NSUserDefaults standardUserDefaults] doubleForKey:TTUserExpressionConfigRequestDateKey];
        NSTimeInterval dateNow = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval timeInterval = [TTUGCEmojiParser userExpressionConfigTimeInterval];

        return (dateNow - dateLast) > timeInterval;
    }

    return YES;
}

static NSString *const kUserExpressionConfigTimeInterval = @"tt_user_expression_config_time_interval";
+ (void)setUserExpressionConfigTimeInterval:(NSTimeInterval)timeInterval {
    if (timeInterval == 0) {
        timeInterval = 8 * 60 * 60;
    }
    [[NSUserDefaults standardUserDefaults] setValue:@(timeInterval) forKey:kUserExpressionConfigTimeInterval];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)userExpressionConfigTimeInterval {
    NSTimeInterval timeInterval = 8 * 60 * 60;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kUserExpressionConfigTimeInterval]) {
        timeInterval = [[[NSUserDefaults standardUserDefaults] valueForKey:kUserExpressionConfigTimeInterval] doubleValue];
    }
    return timeInterval;
}

- (void)loadPlistFileContentsIfNeeded {
    if (![TTUGCEmojiParser sharedManager].emojiDictionary) {
        NSString *emojiPath = [TTUGCEmojiParser pathForFileName:@"emoji"];
        shareManager.emojiDictionary = [[NSDictionary alloc] initWithContentsOfFile:emojiPath];
    }

    if (![TTUGCEmojiParser sharedManager].emojiMappingDictionary) {
        NSString *emojiMappingPath = [TTUGCEmojiParser pathForFileName:@"emoji_mapping"];
        shareManager.emojiMappingDictionary = [[NSDictionary alloc] initWithContentsOfFile:emojiMappingPath];
    }
}

+ (NSArray <TTUGCEmojiTextAttachment *> *)top4EmojiTextAttachments {
    [[TTUGCEmojiParser sharedManager] loadPlistFileContentsIfNeeded];

    NSMutableArray *top4EmojiNames = [[NSMutableArray alloc] initWithCapacity:4];

    // 默认出 2, 7, 6, 21
    NSArray *defaultTop4EmojiNames = @[@"[爱慕]", @"[发怒]", @"[流泪]", @"[大笑]"];

    NSArray *mostUsedEmojis = [[NSUserDefaults standardUserDefaults] objectForKey:TTMostUsedEmojisKey];
    [top4EmojiNames addObjectsFromArray:mostUsedEmojis];

    // 用默认表情补全
    for (NSUInteger j = 0; j < 4; ++j) {
        if (top4EmojiNames.count < 4 && ![top4EmojiNames containsObject:defaultTop4EmojiNames[j]]) {
            [top4EmojiNames addObject:defaultTop4EmojiNames[j]];
        }
    }

    NSMutableArray *as = [[NSMutableArray alloc] init];
    for (NSString *plainText in top4EmojiNames) {
        TTUGCEmojiTextAttachment *at = [[TTUGCEmojiTextAttachment alloc] init];
        NSString *emojiId = [TTUGCEmojiParser sharedManager].emojiDictionary[plainText];

        at.idx = 1;
        at.imageName = [NSString stringWithFormat:@"emoji_%@", emojiId];
        at.plainText = plainText;
        at.padding = 1.f;

        [as addObject:at];
    }

    return [as copy];
}

+ (NSArray <TTUGCEmojiTextAttachment *> *)emojiTextAttachments {
    [[TTUGCEmojiParser sharedManager] loadPlistFileContentsIfNeeded];

    NSArray <NSString *> *sortArray = [TTUGCEmojiParser sharedManager].emojiSortArray;
    if (!sortArray) {
        NSString *sortPlistFilePath = [self pathForFileName:@"emoji_sort"];
        sortArray = [[NSArray alloc] initWithContentsOfFile:sortPlistFilePath];
    }

    NSMutableArray *as = [[NSMutableArray alloc] init];

    [[TTUGCEmojiParser sharedManager].emojiDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *imageName, BOOL *stop) {
        NSInteger idx = 0;
        NSUInteger value = [sortArray indexOfObject:imageName];
        if (value != NSNotFound) {
            idx = value + 1;
        } else {
            return;
        }

        TTUGCEmojiTextAttachment *at = [[TTUGCEmojiTextAttachment alloc] init];
        at.idx = idx;
        at.imageName = [NSString stringWithFormat:@"emoji_%@", imageName];
        at.plainText = key;
        at.padding = 1.f;

        [as addObject:at];
    }];

    // 根据 idx 排序
    // 排序数据结构，设置 idx 作为排序依据，排序结果输出到数组:
    // {微笑:1, 送心:2, 委屈:3}
    [as sortUsingComparator:^NSComparisonResult(TTUGCEmojiTextAttachment *att1, TTUGCEmojiTextAttachment *att2) {
        return att1.idx < att2.idx ? NSOrderedAscending : NSOrderedDescending;
    }];

    return [as copy];
}

+ (NSString *)stringify:(NSAttributedString *)attributedText {
    return [TTUGCEmojiParser stringify:attributedText ignoreCustomEmojis:NO];
}

+ (NSString *)stringify:(NSAttributedString *)attributedText ignoreCustomEmojis:(BOOL)ignoreCustomEmojis {
    if (!attributedText) return nil;

    NSMutableString *plainString = [NSMutableString stringWithString:attributedText.string];
    __block NSUInteger location = 0;

    [attributedText enumerateAttribute:NSAttachmentAttributeName
                               inRange:NSMakeRange(0, attributedText.length)
                               options:0
                            usingBlock:^(id value, NSRange range, __unused BOOL *stop) {
                                if (value && [value isKindOfClass:[TTUGCEmojiTextAttachment class]]) {
                                    for (int i = 0; i < range.length; ++i) { // 相同的 Emoji 合并返回
                                        NSString *plainText = ((TTUGCEmojiTextAttachment *) value).plainText;
                                        if (ignoreCustomEmojis && [TTUGCEmojiParser sharedManager].customEmojiDictionary[plainText]) {
                                            plainText = @"";
                                        }

                                        [plainString replaceCharactersInRange:NSMakeRange(range.location + location + i, 1)
                                                                   withString:plainText];
                                        location += plainText.length - 1;
                                    }
                                }
                            }];

    return [plainString copy];
}

+ (NSAttributedString *)parseInTextKitContext:(NSString *)text fontSize:(CGFloat)fontSize {
    return [[self class] parse:text context:TTUGCEmojiTextKitContext fontSize:fontSize];
}

+ (NSAttributedString *)parseInCoreTextContext:(NSString *)text fontSize:(CGFloat)fontSize {
    return [[self class] parse:text context:TTUGCEmojiCoreTextContext fontSize:fontSize];
}

+ (NSAttributedString *)parse:(NSString *)text context:(TTUGCEmojiContext)context fontSize:(CGFloat)fontSize {
    if (!text) return nil;

    [[TTUGCEmojiParser sharedManager] loadPlistFileContentsIfNeeded];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    UIFont *font = [UIFont systemFontOfSize:fontSize];

    NSArray *emojiMatches = [emojiRegex matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    // 文本处理位置
    NSUInteger location = 0;
    for (NSTextCheckingResult *match in emojiMatches) {
        // 处理非表情 prefix 字符
        NSRange range = match.range;
        if (range.location != location) {
            NSString *substring = [text substringWithRange:NSMakeRange(location, range.location - location)];
            NSMutableAttributedString *prefixAttributedString = [[NSMutableAttributedString alloc] initWithString:substring];
            [attributedString appendAttributedString:prefixAttributedString];
        }

        // 处理下一段
        location = range.location + range.length;

        // 获取表情图片名字
        NSString *key = [text substringWithRange:range];
        NSString *imageName = [TTUGCEmojiParser sharedManager].emojiDictionary[key];

        // 判断是否是映射表情
        if (!imageName) {
            imageName = [TTUGCEmojiParser sharedManager].emojiMappingDictionary[key];
        }

        // 判断是否是自定义字符
        if (!imageName) {
            imageName = [TTUGCEmojiParser sharedManager].customEmojiDictionary[key];
        }

        if (!imageName) {
            // 处理非预制表情文本
            NSMutableAttributedString *plainAttributedString = [[NSMutableAttributedString alloc] initWithString:key];
            [attributedString appendAttributedString:plainAttributedString];
        } else {
            // 替换预制表情文本
            // 重设 Emoji 尺寸，同步页面字体大小设置
            TTUGCEmojiTextAttachment *emojiTextAttachment = [[TTUGCEmojiTextAttachment alloc] init];
            emojiTextAttachment.imageName = [NSString stringWithFormat:@"emoji_%@", imageName];
            emojiTextAttachment.fontSize = font.pointSize;
            emojiTextAttachment.descender = font.descender;
            emojiTextAttachment.padding = 1.f;
            emojiTextAttachment.plainText = key;
            [emojiTextAttachment coreTextImage]; // 预存储 UIImage

            if (context == TTUGCEmojiTextKitContext) {
                NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:emojiTextAttachment];
                [attributedString appendAttributedString:emojiAttributedString];
            } else if (context == TTUGCEmojiCoreTextContext) {
                CTRunDelegateCallbacks callbacks;
                memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));

                callbacks.version = kCTRunDelegateVersion1;
                callbacks.getAscent = ascentCallback;
                callbacks.getDescent = descentCallback;
                callbacks.getWidth = widthCallback;
                callbacks.dealloc = deallocationCallback;

                CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)emojiTextAttachment);
                unichar objectReplacementChar = 0xFFFC;
                NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
                NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content];
                CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef) space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
                CFRelease(delegate);

                [attributedString appendAttributedString:space];
            }
        }
    }

    // 处理非表情 suffix 字符
    if (location < text.length) {
        NSRange range = NSMakeRange(location, text.length - location);
        NSString *substring = [text substringWithRange:range];
        NSMutableAttributedString *suffixAttributeString = [[NSMutableAttributedString alloc] initWithString:substring];
        [attributedString appendAttributedString:suffixAttributeString];
    }

    return [attributedString copy];
}

+ (NSArray <NSValue *> *)parseEmojiRangeValues:(NSString *)text {
    if (!text) return nil;

    [[TTUGCEmojiParser sharedManager] loadPlistFileContentsIfNeeded];

    NSMutableArray *emojis = [[NSMutableArray alloc] init];
    NSArray *emojiMatches = [emojiRegex matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    for (NSTextCheckingResult *match in emojiMatches) {
        // 获取表情图片名字，包含内部表情(如链接)
        NSString *key = [text substringWithRange:match.range];
        if ([TTUGCEmojiParser sharedManager].emojiDictionary[key] || [TTUGCEmojiParser sharedManager].emojiMappingDictionary[key] || [TTUGCEmojiParser sharedManager].customEmojiDictionary[key]) {
            [emojis addObject:[NSValue valueWithRange:match.range]];
        }
    }

    return [emojis copy];
}

+ (NSDictionary <NSString *, NSString *> *)parseEmojis:(NSString *)text {
    if (!text) return nil;

    [[TTUGCEmojiParser sharedManager] loadPlistFileContentsIfNeeded];

    NSMutableDictionary <NSString *, NSString *> *emojis = [[NSMutableDictionary alloc] init];
    NSArray *emojiMatches = [emojiRegex matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    for (NSTextCheckingResult *match in emojiMatches) {
        // 获取表情图片名字
        NSString *key = [text substringWithRange:match.range];
        NSString *emojiId = [TTUGCEmojiParser sharedManager].emojiDictionary[key];
        if (emojiId) {
            emojis[emojiId] = key;
        }
    }

    return [emojis copy];
}

+ (void)markEmojisAsUsed:(NSDictionary <NSString *, NSString *> *)emojis {
    NSArray *mostUsedEmojis = [[NSUserDefaults standardUserDefaults] arrayForKey:TTMostUsedEmojisKey];
    NSMutableArray *newMostUsedEmojis = [NSMutableArray arrayWithArray:mostUsedEmojis];

    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:TTUsedEmojisKey];
    NSArray <TTUGCEmoji *> *usedEmojis = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableArray <TTUGCEmoji *> *newUsedEmojis = [NSMutableArray arrayWithArray:usedEmojis];

    NSMutableArray *uniqueEmojiIds = [NSMutableArray array];

    // 数组去重，单次提交多个表情只记一次
    for (NSString *emoji in emojis.allKeys) {
        if (![uniqueEmojiIds containsObject:emoji]) {
            [uniqueEmojiIds addObject:emoji];
        }
    }

    for (NSString *emojiId in uniqueEmojiIds) {
        TTUGCEmoji *aEmoji = nil;

        for (NSUInteger i = 0; i < usedEmojis.count; ++i) {
            TTUGCEmoji *emoji = usedEmojis[i];

            // 找到存在的 emoji
            if ([emoji.emojiId isEqualToString:emojiId]) {
                aEmoji = emoji;
                aEmoji.count = @(aEmoji.count.integerValue + 1);
            }
        }

        if (!aEmoji) {
            aEmoji = [[TTUGCEmoji alloc] init];
            aEmoji.key = emojis[emojiId];
            aEmoji.emojiId = emojiId;
            aEmoji.count = @1;

            [newUsedEmojis addObject:aEmoji];
        }

        // 达到 1 次就清零，并提到头部
        if (aEmoji.count.integerValue >= 1) {
            aEmoji.count = @0;

            if ([newMostUsedEmojis containsObject:aEmoji.key]) {
                [newMostUsedEmojis removeObject:aEmoji.key];
            }

            [newMostUsedEmojis insertObject:aEmoji.key atIndex:0];
        }
    }

    NSArray *top4MostUsedEmojis;
    if (newMostUsedEmojis.count > 4) {
        top4MostUsedEmojis = [newMostUsedEmojis subarrayWithRange:NSMakeRange(0, 4)];
    } else {
        top4MostUsedEmojis = [newMostUsedEmojis copy];
    }

    [[NSUserDefaults standardUserDefaults] setObject:top4MostUsedEmojis forKey:TTMostUsedEmojisKey];
    NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:newUsedEmojis];
    [[NSUserDefaults standardUserDefaults] setObject:newData forKey:TTUsedEmojisKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


/**
 方法用于处理NSBundle的转换

 @param fileName pod中的plist文件名
 @return 真实地址
 */
+ (NSString *)pathForFileName:(NSString*)fileName {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TTUGCRichText" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *path = [bundle pathForResource:fileName ofType:@"plist"];
    return path;
}
@end
